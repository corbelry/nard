import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:nard_ai/nard_ai.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'bot_driver.dart';
import 'error_reporter.dart';
import 'limits.dart';
import 'log.dart';
import 'match_room.dart';
import 'matchmaker.dart';
import 'metrics.dart';
import 'ticket.dart';

/// Receives finished matches (the API in production, ADR-031).
abstract interface class ResultSink {
  Future<void> report(MatchResult result);

  /// Neither player of a tournament match showed up.
  Future<void> reportNoShow(TournamentNoShow noShow);
}

/// Keeps results in memory (development and tests).
class MemoryResultSink implements ResultSink {
  final results = <MatchResult>[];
  final noShows = <TournamentNoShow>[];

  @override
  Future<void> report(MatchResult result) async => results.add(result);

  @override
  Future<void> reportNoShow(TournamentNoShow noShow) async =>
      noShows.add(noShow);
}

class _Connection {
  _Connection(this.channel, this.onSend, this.remote, this.bucket);

  final WebSocketChannel channel;
  final void Function(Envelope) onSend;

  /// Client address, for the per-address connection cap.
  final String remote;
  final TokenBucket bucket;

  /// Refused messages in a row (rate limit).
  int strikes = 0;
  Timer? authDeadline;
  bool closed = false;
  Ticket? user;

  /// Announced [ProtocolFeature.stateDelta] in `auth` (ADR-048).
  bool stateDeltas = false;

  void send(Envelope e) {
    if (closed) return;
    onSend(e);
    channel.sink.add(jsonEncode(e.toJson()));
  }
}

class _PrivateRoom {
  _PrivateRoom(this.code, this.owner, this.request, this.expires);

  final String code;
  final Ticket owner;
  final QueueJoinPayload request;
  final Timer expires;
}

class _Seat {
  _Seat(this.room, this.side);

  final MatchRoom room;
  final Side side;
}

/// A tournament pairing from the API waiting for both players.
class _Assignment {
  _Assignment(this.match, this.deadline);

  final TournamentMatchPayload match;

  /// No-show deadline, ms since epoch.
  final int deadline;

  /// Sides that connected or sent `tournament.ready` (sticky).
  final present = <Side>{};
  Timer? timer;

  String get id => match.matchId;

  PlayerInfo player(Side side) =>
      side == Side.white ? match.white : match.black;

  Side? sideOf(String userId) =>
      match.white.userId == userId
          ? Side.white
          : match.black.userId == userId
          ? Side.black
          : null;
}

/// Routes WebSocket connections to the matchmaker and match rooms. One live
/// connection per user; a new connection takes over (reconnect).
class Hub {
  Hub({
    required this.ticketSecret,
    required this.results,
    this.botAfter = const Duration(seconds: 30),
    this.botLevel = BotLevel.medium,
    Random? random,
    int Function()? now,
    Metrics? metrics,
    Logger? log,
    this.errors = const NoopErrorReporter(),
    this.limits = const WsLimits(),
  }) : _random = random ?? Random.secure(),
       _now = now ?? (() => DateTime.now().millisecondsSinceEpoch),
       metrics = metrics ?? Metrics(),
       log = log ?? Logger.silent() {
    matchmaker = Matchmaker(
      onMatch: _pair,
      onBot: _pairWithBot,
      botAfter: botAfter,
      now: _now,
    )..start();
    _registerMetrics();
  }

  final String ticketSecret;
  final ResultSink results;
  final Duration botAfter;
  final BotLevel botLevel;
  final Random _random;
  final int Function() _now;
  late final Matchmaker matchmaker;

  /// Prometheus registry served at `/metrics` (ADR-043).
  final Metrics metrics;
  final Logger log;

  /// Unexpected errors (a bug, not a refused intent) go here and to [log].
  final ErrorReporter errors;

  /// Frame size, auth deadline, message rate and connection caps (ADR-045).
  final WsLimits limits;

  final _connections = <_Connection>{};
  final _online = <String, _Connection>{};
  final _seats = <String, _Seat>{};
  final _bots = <BotDriver>[];
  final _privateRooms = <String, _PrivateRoom>{};
  final _live = <String, MatchRoom>{};
  final _watching = <_Connection, MatchRoom>{};
  final _assignments = <String, _Assignment>{};
  final _perRemote = <String, int>{};

  /// The latest moderation push per user with the time it arrived (ms):
  /// applied to tickets presented within [moderationMemory] (ADR-045).
  final _moderation = <String, (ModerationPayload, int)>{};

  /// How long a pushed moderation state overrides presented tickets: longer
  /// than the API's ticket lifetime (5 min), so a ticket signed before a
  /// ban cannot be used after it.
  static const moderationMemory = Duration(minutes: 10);

  /// Tournament matches already played or decided here (the API may push a
  /// pairing again until it has the result).
  final _decided = <String>{};

  /// How long a private room waits for the second player.
  static const roomTtl = Duration(minutes: 15);
  int _matches = 0;

  int get activeMatches => _seats.values.map((s) => s.room).toSet().length;

  /// Open WebSocket connections.
  int get connectionCount => _connections.length;

  /// Tournament matches waiting for their players.
  int get pendingTournamentMatches => _assignments.length;

  // ---- Metrics ----------------------------------------------------------

  late final Counter _connectionsOpened;
  late final Counter _authFailures;
  late final Counter _rejected;
  late final Counter _messagesIn;
  late final Counter _messagesOut;
  late final Counter _errorsOut;
  late final Counter _matchesStarted;
  late final Counter _matchesFinished;
  late final Counter _internalErrors;
  late final Histogram _handleSeconds;

  /// Client intents a room handles; other types share the `other` label so
  /// a client cannot create new time series.
  static const _roomIntents = {
    MessageType.gameSeed,
    MessageType.gameRoll,
    MessageType.gameMove,
    MessageType.gameUndo,
    MessageType.gameConfirmTurn,
    MessageType.gameResign,
    MessageType.cubeOffer,
    MessageType.cubeTake,
    MessageType.cubeDrop,
    MessageType.chatEmote,
  };

  void _registerMetrics() {
    final m = metrics;
    m
      ..gauge(
        'nard_ws_connections',
        'Open WebSocket connections.',
        () => _connections.length,
      )
      ..gauge(
        'nard_ws_authenticated_users',
        'Users with an authenticated connection.',
        () => _online.length,
      )
      ..gauge(
        'nard_rooms_active',
        'Match rooms in progress (including bot matches).',
        () => _live.length,
      )
      ..gauge('nard_bots_active', 'Bot seats in progress.', () => _bots.length)
      ..gauge(
        'nard_spectators',
        'Connections watching a match.',
        () => _watching.length,
      )
      ..gauge(
        'nard_private_rooms',
        'Private rooms waiting for the second player.',
        () => _privateRooms.length,
      )
      ..gauge(
        'nard_tournament_matches_pending',
        'Tournament pairings waiting for their players.',
        () => _assignments.length,
      )
      ..gauges(
        'nard_queue_size',
        'Players waiting in each matchmaking queue (variant/length/mode).',
        () => {
          for (final e in matchmaker.queueSizes().entries)
            {'queue': e.key}: e.value,
        },
      );
    _connectionsOpened = m.counter(
      'nard_ws_connections_opened_total',
      'WebSocket connections accepted.',
    );
    _authFailures = m.counter(
      'nard_ws_auth_failures_total',
      'Rejected auth messages (bad or expired ticket).',
    );
    _rejected = m.counter(
      'nard_ws_rejected_total',
      'Connections refused or closed by an abuse limit, by reason '
          '(ip_limit, frame_too_large, auth_timeout, rate_limited).',
    );
    _messagesIn = m.counter(
      'nard_ws_messages_received_total',
      'WebSocket frames received from clients.',
    );
    _messagesOut = m.counter(
      'nard_ws_messages_sent_total',
      'WebSocket messages sent to clients.',
    );
    _errorsOut = m.counter(
      'nard_ws_errors_sent_total',
      'Error messages sent to clients, by code.',
    );
    _matchesStarted = m.counter(
      'nard_matches_started_total',
      'Matches started, by mode.',
    );
    _matchesFinished = m.counter(
      'nard_matches_finished_total',
      'Matches finished, by mode and reason.',
    );
    _internalErrors = m.counter(
      'nard_internal_errors_total',
      'Unexpected errors while handling a client message.',
    );
    _handleSeconds = m.histogram(
      'nard_room_handle_seconds',
      'Time to apply one client intent in its match room.',
      const [0.0001, 0.00025, 0.0005, 0.001, 0.0025, 0.005, 0.01, 0.025],
    );
  }

  void _counted(Envelope e) {
    _messagesOut.inc();
    if (e.type == MessageType.error) {
      final code = e.payload['code'];
      _errorsOut.inc({'code': code is String ? code : 'unknown'});
    }
  }

  /// Whether another connection from [remote] is allowed (checked before
  /// the WebSocket upgrade; refusals are counted).
  bool admits(String remote) {
    final cap = limits.maxConnectionsPerIp;
    if (cap <= 0 || (_perRemote[remote] ?? 0) < cap) return true;
    _rejected.inc({'reason': 'ip_limit'});
    return false;
  }

  void attach(WebSocketChannel channel, {String remote = ''}) {
    final conn = _Connection(
      channel,
      _counted,
      remote,
      TokenBucket(limits.messagesPerSecond, limits.burst, _now()),
    );
    _connections.add(conn);
    _perRemote[remote] = (_perRemote[remote] ?? 0) + 1;
    _connectionsOpened.inc();
    if (limits.authTimeout > Duration.zero) {
      conn.authDeadline = Timer(limits.authTimeout, () {
        if (conn.user == null) _reject(conn, 'auth_timeout', CloseCode.policy);
      });
    }
    channel.stream.listen(
      (frame) {
        if (conn.closed) return;
        try {
          _onFrame(conn, frame);
        } on Object catch (e, stack) {
          _internalErrors.inc();
          log.error('message handling failed', {
            'userId': conn.user?.userId,
            'error': '$e',
          });
          errors.capture(e, stack, context: {'userId': conn.user?.userId});
        }
      },
      onDone: () => _onClose(conn),
      onError: (_) => _onClose(conn),
    );
  }

  /// Closes [conn] for breaking a limit ([reason] is the metric label and
  /// the close reason).
  void _reject(_Connection conn, String reason, int code) {
    _rejected.inc({'reason': reason});
    log.info('connection rejected', {
      'reason': reason,
      'userId': conn.user?.userId,
    });
    _close(conn, code, reason);
  }

  /// Tears the connection down at once (like a disconnect) and closes the
  /// socket; frames still in flight are ignored.
  void _close(_Connection conn, int code, String reason) {
    _onClose(conn);
    unawaited(conn.channel.sink.close(code, reason));
  }

  void _onFrame(_Connection conn, Object? frame) {
    _messagesIn.inc();
    if (limits.messagesPerSecond > 0 && !conn.bucket.take(_now())) {
      conn.strikes++;
      if (conn.strikes > limits.burst) {
        _reject(conn, 'rate_limited', CloseCode.policy);
      } else if (conn.strikes == 1) {
        conn.send(_error('rate_limited', ErrorCode.rateLimited));
      }
      return;
    }
    conn.strikes = 0;
    final size =
        frame is String
            ? frame.length
            : frame is List<int>
            ? frame.length
            : 0;
    if (limits.maxFrameBytes > 0 && size > limits.maxFrameBytes) {
      _reject(conn, 'frame_too_large', CloseCode.tooLarge);
      return;
    }
    Envelope msg;
    try {
      if (frame is! String) throw const FormatException('Text frames only');
      msg = Envelope.fromJson(jsonDecode(frame));
    } on FormatException catch (e) {
      conn.send(_error('invalid', ErrorCode.badRequest, e.message));
      return;
    }
    if (msg.type == MessageType.ping) {
      conn.send(Envelope(type: MessageType.pong, id: msg.id, ts: _now()));
      return;
    }
    if (msg.type == MessageType.auth) return _auth(conn, msg);
    final user = conn.user;
    if (user == null) {
      conn.send(_error(msg.id, ErrorCode.unauthorized));
      return;
    }
    final seat = _seats[user.userId];
    switch (msg.type) {
      case MessageType.queueJoin ||
              MessageType.roomCreate ||
              MessageType.roomJoin
          when _hasAssignment(user.userId):
        conn.send(
          _error(msg.id, ErrorCode.illegalAction, 'Tournament match pending'),
        );
      case MessageType.queueJoin when user.inQueueCooldown(_now() ~/ 1000):
        conn.send(
          _error(msg.id, ErrorCode.queueCooldown, '${user.queueCooldownUntil}'),
        );
      case MessageType.queueJoin:
        if (seat != null && !seat.room.isOver) {
          conn.send(_error(msg.id, ErrorCode.illegalAction, 'In a match'));
          return;
        }
        try {
          matchmaker.join(user, QueueJoinPayload.fromJson(msg.payload));
        } on ProtocolException catch (e) {
          conn.send(_error(msg.id, ErrorCode.badRequest, e.message));
        }
      case MessageType.queueLeave:
        matchmaker.leave(user.userId);
      case MessageType.roomCreate:
        _createRoom(conn, user, msg, seat);
      case MessageType.roomJoin:
        _joinRoom(conn, user, msg, seat);
      case MessageType.roomCancel:
        _cancelRooms(user.userId);
      case MessageType.spectateJoin:
        final room = _live[msg.payload['matchId']];
        if (room == null || room.isOver) {
          conn.send(_error(msg.id, ErrorCode.notInMatch));
          return;
        }
        _watching.remove(conn)?.removeSpectator(conn);
        _watching[conn] = room;
        room.addSpectator(conn, conn.send, deltas: conn.stateDeltas);
      case MessageType.spectateLeave:
        _watching.remove(conn)?.removeSpectator(conn);
      // A delta did not fit the client's state: resend the full one of the
      // match it plays or watches (ADR-048).
      case MessageType.gameSync:
        final matchId = msg.payload['matchId'];
        final watched = _watching[conn];
        if (seat != null &&
            !seat.room.isOver &&
            (matchId == null || matchId == seat.room.matchId)) {
          seat.room.resend(seat.side);
        } else if (watched != null &&
            !watched.isOver &&
            (matchId == null || matchId == watched.matchId)) {
          watched.resendSpectator(conn);
        } else {
          conn.send(_error(msg.id, ErrorCode.notInMatch));
        }
      case MessageType.tournamentReady:
        final String matchId;
        try {
          matchId = TournamentReadyPayload.fromJson(msg.payload).matchId;
        } on ProtocolException catch (e) {
          conn.send(_error(msg.id, ErrorCode.badRequest, e.message));
          return;
        }
        final a = _assignments[matchId];
        final side = a?.sideOf(user.userId);
        if (a == null || side == null) {
          conn.send(_error(msg.id, ErrorCode.notInMatch));
          return;
        }
        _arrive(a, side);
      case MessageType.presenceQuery:
        final ids = msg.payload['userIds'];
        final matches = <String, String>{};
        if (ids is List) {
          for (final id in ids.take(200)) {
            final s = _seats[id];
            if (id is String && s != null && !s.room.isOver) {
              matches[id] = s.room.matchId;
            }
          }
        }
        conn.send(
          Envelope(
            type: MessageType.presence,
            id: msg.id,
            ts: _now(),
            payload: PresencePayload(matches).toJson(),
          ),
        );
      // Muted by a moderator (ticket flag): emotes are dropped silently.
      case MessageType.chatEmote when user.muted && seat != null:
        return;
      default:
        if (seat == null) {
          conn.send(_error(msg.id, ErrorCode.notInMatch));
        } else {
          final watch = Stopwatch()..start();
          seat.room.handle(seat.side, msg);
          _handleSeconds.observe(watch.elapsedMicroseconds / 1e6, {
            'type': _roomIntents.contains(msg.type) ? msg.type : 'other',
          });
        }
    }
  }

  void _auth(_Connection conn, Envelope msg) {
    final token = msg.payload['ticket'];
    var ticket =
        token is String
            ? Ticket.verify(token, ticketSecret, nowSeconds: _now() ~/ 1000)
            : null;
    if (ticket == null) {
      _authFailures.inc();
      conn.send(_error(msg.id, ErrorCode.unauthorized));
      return;
    }
    // A moderation push newer than the ticket wins (ADR-045).
    final pushed = _pushedState(ticket.userId);
    if (pushed != null && pushed.banned) {
      _authFailures.inc();
      conn.send(_error(msg.id, ErrorCode.banned));
      _close(conn, CloseCode.policy, 'banned');
      return;
    }
    if (pushed != null) {
      ticket = ticket.moderated(
        muted: pushed.muted,
        queueCooldownUntil: pushed.queueCooldownUntil,
      );
    }
    conn.authDeadline?.cancel();
    conn.user = ticket;
    // Optional features (ADR-048); a malformed list just enables none.
    var features = const <String>{};
    try {
      features = AuthPayload.fromJson(msg.payload).features;
    } on ProtocolException {
      // None enabled.
    }
    conn.stateDeltas = features.contains(ProtocolFeature.stateDelta);
    final previous = _online[ticket.userId];
    _online[ticket.userId] = conn;
    if (previous != null && previous != conn) {
      previous.user = null;
      unawaited(previous.channel.sink.close());
    }
    conn.send(
      Envelope(
        type: MessageType.hello,
        id: msg.id,
        ts: _now(),
        payload: {
          'userId': ticket.userId,
          if (conn.stateDeltas) 'features': [ProtocolFeature.stateDelta],
        },
      ),
    );
    final seat = _seats[ticket.userId];
    if (seat != null && !seat.room.isOver) {
      seat.room.connected(seat.side);
    }
    for (final a in _assignments.values.toList()) {
      final side = a.sideOf(ticket.userId);
      if (side != null) _arrive(a, side);
    }
  }

  // ---- Moderation (pushed by the API, ADR-045) ----------------------------

  /// Applies a moderation push (`POST /internal/moderation`) to the user's
  /// live session: a ban closes it (the match continues as a disconnect), a
  /// mute drops emotes, a cooldown refuses `queue.join` and takes the player
  /// out of the queue. Remembered for [moderationMemory] so a ticket signed
  /// before the push cannot undo it. Returns whether the user was connected.
  bool moderate(ModerationPayload m) {
    final now = _now();
    _moderation
      ..removeWhere((_, e) => now - e.$2 > moderationMemory.inMilliseconds)
      ..[m.userId] = (m, now);
    final conn = _online[m.userId];
    final user = conn?.user;
    log.info('moderation push', {
      'userId': m.userId,
      'banned': m.banned,
      'muted': m.muted,
      'queueCooldownUntil': m.queueCooldownUntil,
      'connected': user != null,
    });
    if (m.banned) {
      matchmaker.leave(m.userId);
      _cancelRooms(m.userId);
      if (conn == null || user == null) return false;
      conn.send(_error('s-moderation', ErrorCode.banned));
      _close(conn, CloseCode.policy, 'banned');
      return true;
    }
    if (conn == null || user == null) return false;
    final updated =
        conn.user = user.moderated(
          muted: m.muted,
          queueCooldownUntil: m.queueCooldownUntil,
        );
    if (updated.inQueueCooldown(now ~/ 1000) && matchmaker.isQueued(m.userId)) {
      matchmaker.leave(m.userId);
      conn.send(
        _error(
          's-moderation',
          ErrorCode.queueCooldown,
          '${updated.queueCooldownUntil}',
        ),
      );
    }
    return true;
  }

  // ---- Live notifications (pushed by the API, ADR-049) -----------------------

  /// Forwards inbox rows (`POST /internal/notify`) to the players' open
  /// sockets as `notification`, unchanged. Players without a socket read
  /// them from the inbox later. Returns how many were delivered.
  int notify(NotifyPayload push) {
    var delivered = 0;
    for (final n in push.notifications) {
      final conn = _online[n.userId];
      if (conn == null || conn.user == null) continue;
      conn.send(
        Envelope(
          type: MessageType.notification,
          id: 's-n${n.notification['id']}',
          ts: _now(),
          payload: n.notification,
        ),
      );
      delivered++;
    }
    log.info('notify push', {
      'notifications': push.notifications.length,
      'delivered': delivered,
    });
    return delivered;
  }

  /// Tells the connected entrants of a tournament that it changed
  /// (`POST /internal/tournament-updated`), so open screens refetch.
  /// Returns how many sockets got `tournament.updated`.
  int tournamentUpdated(TournamentUpdatedPush push) {
    var delivered = 0;
    final payload = TournamentUpdatedPayload(push.tournamentId).toJson();
    for (final userId in push.userIds.toSet()) {
      final conn = _online[userId];
      if (conn == null || conn.user == null) continue;
      conn.send(
        Envelope(
          type: MessageType.tournamentUpdated,
          id: 's-t${push.tournamentId}',
          ts: _now(),
          payload: payload,
        ),
      );
      delivered++;
    }
    return delivered;
  }

  ModerationPayload? _pushedState(String userId) {
    final e = _moderation[userId];
    if (e == null) return null;
    if (_now() - e.$2 > moderationMemory.inMilliseconds) {
      _moderation.remove(userId);
      return null;
    }
    return e.$1;
  }

  // ---- Tournament matches (assigned by the API) ----------------------------

  /// Accepts a pairing pushed by the API (`POST /internal/tournament-matches`).
  /// Returns false when the match is already known here (idempotent).
  bool assignTournamentMatch(TournamentMatchPayload match) {
    final id = match.matchId;
    if (_assignments.containsKey(id) ||
        _live.containsKey(id) ||
        _decided.contains(id)) {
      return false;
    }
    final a =
        _assignments[id] = _Assignment(
          match,
          _now() + match.noShowSeconds * 1000,
        );
    a.timer = Timer(Duration(seconds: match.noShowSeconds), () => _noShow(a));
    for (final side in Side.values) {
      if (_online.containsKey(a.player(side).userId)) a.present.add(side);
    }
    _sendReadyState(a);
    _tryStart(a);
    return true;
  }

  bool _hasAssignment(String userId) =>
      _assignments.values.any((a) => a.sideOf(userId) != null);

  void _arrive(_Assignment a, Side side) {
    a.present.add(side);
    _sendReadyState(a);
    _tryStart(a);
  }

  void _sendReadyState(_Assignment a) {
    final m = a.match;
    for (final side in Side.values) {
      _online[a.player(side).userId]?.send(
        Envelope(
          type: MessageType.tournamentReadyState,
          id: 's-${m.matchId}-ready',
          ts: _now(),
          payload:
              TournamentReadyStatePayload(
                matchId: m.matchId,
                tournamentId: m.tournamentId,
                round: m.round,
                you: side,
                white: m.white,
                black: m.black,
                ready: {for (final s in Side.values) s: a.present.contains(s)},
                deadline: a.deadline,
                noShowSeconds: m.noShowSeconds,
              ).toJson(),
        ),
      );
    }
  }

  /// Starts the match once both players are present and neither is still
  /// playing another match.
  void _tryStart(_Assignment a) {
    if (a.present.length < 2 || _assignments[a.id] != a) return;
    for (final side in Side.values) {
      final seat = _seats[a.player(side).userId];
      if (seat != null && !seat.room.isOver) return;
    }
    _assignments.remove(a.id);
    a.timer?.cancel();
    final m = a.match;
    for (final side in Side.values) {
      final userId = a.player(side).userId;
      matchmaker.leave(userId);
      _cancelRooms(userId);
    }
    _startRoom(
      QueueJoinPayload(
        variant: m.variant,
        matchLength: m.matchLength,
        mode: QueueMode.tournament,
      ),
      white: _unrated(m.white),
      black: _unrated(m.black),
      matchId: m.matchId,
      tournamentId: m.tournamentId,
      round: m.round,
    );
  }

  /// The no-show time is over: one present player wins by walkover; if
  /// nobody came the API is told both were absent. When both are present
  /// (one still busy in another match) the match starts once they are free.
  void _noShow(_Assignment a) {
    if (_assignments[a.id] != a || a.present.length == 2) return;
    _assignments.remove(a.id);
    _decided.add(a.id);
    final m = a.match;
    final now = _now();
    final winner = a.present.isEmpty ? null : a.present.single;
    log.info('tournament no-show', {
      'matchId': m.matchId,
      'tournamentId': m.tournamentId,
      'winner': winner?.name,
    });
    if (winner == null) {
      unawaited(
        results.reportNoShow(
          TournamentNoShow(
            matchId: m.matchId,
            tournamentId: m.tournamentId,
            endedAt: now,
          ),
        ),
      );
    } else {
      unawaited(
        results.report(
          MatchResult(
            matchId: m.matchId,
            variant: m.variant,
            matchLength: m.matchLength,
            mode: QueueMode.tournament,
            white: _unrated(m.white),
            black: _unrated(m.black),
            winner: winner,
            whiteScore: winner == Side.white ? m.matchLength : 0,
            blackScore: winner == Side.black ? m.matchLength : 0,
            reason: MatchEndReason.walkover,
            games: const [],
            startedAt: now,
            endedAt: now,
            tournamentId: m.tournamentId,
          ),
        ),
      );
    }
    for (final side in Side.values) {
      _online[a.player(side).userId]?.send(
        Envelope(
          type: MessageType.tournamentWalkover,
          id: 's-${m.matchId}-walkover',
          ts: now,
          payload:
              TournamentWalkoverPayload(
                matchId: m.matchId,
                tournamentId: m.tournamentId,
                winner: winner,
              ).toJson(),
        ),
      );
    }
  }

  /// Tournament matches are unrated (QUESTIONS #33).
  static PlayerInfo _unrated(PlayerInfo p) => PlayerInfo(
    userId: p.userId,
    name: p.name,
    country: p.country,
    cosmetics: p.cosmetics,
  );

  void _onClose(_Connection conn) {
    if (conn.closed) return;
    conn.closed = true;
    conn.authDeadline?.cancel();
    final left = (_perRemote[conn.remote] ?? 1) - 1;
    if (left <= 0) {
      _perRemote.remove(conn.remote);
    } else {
      _perRemote[conn.remote] = left;
    }
    _connections.remove(conn);
    _watching.remove(conn)?.removeSpectator(conn);
    final user = conn.user;
    if (user == null || _online[user.userId] != conn) return;
    _online.remove(user.userId);
    matchmaker.leave(user.userId);
    _cancelRooms(user.userId);
    final seat = _seats[user.userId];
    if (seat != null && !seat.room.isOver) seat.room.disconnected(seat.side);
  }

  static const _codeAlphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

  void _createRoom(_Connection conn, Ticket user, Envelope msg, _Seat? seat) {
    if (seat != null && !seat.room.isOver) {
      conn.send(_error(msg.id, ErrorCode.illegalAction, 'In a match'));
      return;
    }
    final RoomCreatePayload req;
    try {
      req = RoomCreatePayload.fromJson(msg.payload);
    } on ProtocolException catch (e) {
      conn.send(_error(msg.id, ErrorCode.badRequest, e.message));
      return;
    }
    _cancelRooms(user.userId);
    matchmaker.leave(user.userId);
    String code;
    do {
      code =
          List.generate(
            6,
            (_) => _codeAlphabet[_random.nextInt(_codeAlphabet.length)],
          ).join();
    } while (_privateRooms.containsKey(code));
    final request = QueueJoinPayload(
      variant: req.variant,
      matchLength: req.matchLength,
      mode: QueueMode.casual,
      timeControl: req.timeControl,
    );
    final finalCode = code;
    _privateRooms[code] = _PrivateRoom(
      code,
      user,
      request,
      Timer(roomTtl, () => _privateRooms.remove(finalCode)),
    );
    conn.send(
      Envelope(
        type: MessageType.roomCreated,
        id: msg.id,
        ts: _now(),
        payload:
            RoomCodePayload(
              code,
              expiresAt: _now() + roomTtl.inMilliseconds,
            ).toJson(),
      ),
    );
  }

  void _joinRoom(_Connection conn, Ticket user, Envelope msg, _Seat? seat) {
    if (seat != null && !seat.room.isOver) {
      conn.send(_error(msg.id, ErrorCode.illegalAction, 'In a match'));
      return;
    }
    final String code;
    try {
      code = RoomCodePayload.fromJson(msg.payload).code;
    } on ProtocolException catch (e) {
      conn.send(_error(msg.id, ErrorCode.badRequest, e.message));
      return;
    }
    final room = _privateRooms[code];
    if (room == null || room.owner.userId == user.userId) {
      conn.send(_error(msg.id, ErrorCode.notInMatch, 'No such room'));
      return;
    }
    _privateRooms.remove(code)?.expires.cancel();
    matchmaker.leave(user.userId);
    final now = _now();
    final a = QueueEntry(room.owner, room.request, now);
    final b = QueueEntry(user, room.request, now);
    _pair(a, b);
  }

  void _cancelRooms(String userId) {
    _privateRooms.removeWhere((_, r) {
      if (r.owner.userId != userId) return false;
      r.expires.cancel();
      return true;
    });
  }

  PlayerInfo _info(QueueEntry e) => PlayerInfo(
    userId: e.ticket.userId,
    name: e.ticket.name,
    country: e.ticket.country,
    rating: e.request.mode == QueueMode.ranked ? e.rating : null,
    cosmetics: e.ticket.cosmetics,
  );

  void _pair(QueueEntry a, QueueEntry b) {
    final aWhite = _random.nextBool();
    _startRoom(
      a.request,
      white: aWhite ? _info(a) : _info(b),
      black: aWhite ? _info(b) : _info(a),
    );
  }

  void _pairWithBot(QueueEntry e) {
    final humanWhite = _random.nextBool();
    final bot = PlayerInfo(
      userId: 'bot-${_random.nextInt(1 << 32)}',
      name: 'Bot',
      bot: true,
    );
    _startRoom(
      e.request,
      white: humanWhite ? _info(e) : bot,
      black: humanWhite ? bot : _info(e),
    );
  }

  void _startRoom(
    QueueJoinPayload request, {
    required PlayerInfo white,
    required PlayerInfo black,
    String? matchId,
    String? tournamentId,
    int? round,
  }) {
    final id =
        matchId ?? 'm${_now()}-${_matches++}-${_random.nextInt(1 << 20)}';
    late final MatchRoom room;
    final drivers = <Side, BotDriver>{};
    room = MatchRoom(
      matchId: id,
      variant: request.variant,
      matchLength: request.matchLength,
      mode: request.mode,
      white: white,
      black: black,
      clock: request.timeControl.clock,
      timeControl: request.timeControl,
      tournamentId: tournamentId,
      now: _now,
      // Bots read the room directly; humans per their socket (ADR-048).
      deltas: (side) {
        final player = room.player(side);
        return player.bot || (_online[player.userId]?.stateDeltas ?? false);
      },
      send: (side, msg) {
        final player = room.player(side);
        if (player.bot) {
          drivers[side]?.receive(msg);
        } else {
          _online[player.userId]?.send(msg);
        }
      },
      onEnd: (result) {
        _matchesFinished.inc({
          'mode': request.mode.name,
          'reason': result.reason.name,
        });
        log.info('match ended', {
          'matchId': id,
          'mode': request.mode.name,
          'reason': result.reason.name,
          'winner': result.winner.name,
          'score': '${result.whiteScore}-${result.blackScore}',
          'durationMs': result.endedAt - result.startedAt,
        });
        unawaited(results.report(result));
        _live.remove(id);
        for (final d in drivers.values) {
          d.dispose();
          _bots.remove(d);
        }
        for (final p in [white, black]) {
          if (_seats[p.userId]?.room == room) _seats.remove(p.userId);
        }
        if (tournamentId != null) _decided.add(id);
        // A tournament match may have waited for these players to finish.
        Timer.run(() {
          for (final a in _assignments.values.toList()) {
            if (a.sideOf(white.userId) != null ||
                a.sideOf(black.userId) != null) {
              _tryStart(a);
            }
          }
        });
      },
    );
    for (final side in Side.values) {
      final p = room.player(side);
      if (p.bot) {
        final d =
            drivers[side] = BotDriver(
              room: room,
              side: side,
              level: botLevel,
              random: Random(_random.nextInt(1 << 32)),
            );
        _bots.add(d);
      } else {
        _seats[p.userId] = _Seat(room, side);
        _online[p.userId]?.send(
          Envelope(
            type: MessageType.matchFound,
            id: 's-$id',
            ts: _now(),
            payload:
                MatchFoundPayload(
                  matchId: id,
                  variant: request.variant,
                  matchLength: request.matchLength,
                  mode: request.mode,
                  you: side,
                  white: white,
                  black: black,
                  clock: request.timeControl.clock,
                  tournamentId: tournamentId,
                  round: round,
                ).toJson(),
          ),
        );
      }
    }
    _live[id] = room;
    _matchesStarted.inc({'mode': request.mode.name});
    log.info('match started', {
      'matchId': id,
      'mode': request.mode.name,
      'variant': request.variant.name,
      'matchLength': request.matchLength,
      'timeControl': request.timeControl.name,
      'white': white.userId,
      'black': black.userId,
      if (tournamentId != null) 'tournamentId': tournamentId,
    });
    room.start();
    for (final side in Side.values) {
      final p = room.player(side);
      if (p.bot || _online.containsKey(p.userId)) {
        room.connected(side);
      } else {
        room.disconnected(side);
      }
    }
  }

  Envelope _error(String id, String code, [String message = '']) => Envelope(
    type: MessageType.error,
    id: id,
    ts: _now(),
    payload: ErrorPayload(code: code, message: message).toJson(),
  );

  void dispose() {
    matchmaker.dispose();
    for (final c in _connections) {
      c.authDeadline?.cancel();
    }
    for (final r in _privateRooms.values) {
      r.expires.cancel();
    }
    for (final a in _assignments.values) {
      a.timer?.cancel();
    }
    for (final b in _bots) {
      b.dispose();
    }
    for (final s in _seats.values) {
      s.room.dispose();
    }
  }
}
