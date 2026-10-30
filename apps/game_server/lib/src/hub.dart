import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:nard_ai/nard_ai.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'bot_driver.dart';
import 'match_room.dart';
import 'matchmaker.dart';
import 'ticket.dart';

/// Receives finished matches (the API in production, ADR-031).
abstract interface class ResultSink {
  Future<void> report(MatchResult result);
}

/// Keeps results in memory (development and tests).
class MemoryResultSink implements ResultSink {
  final results = <MatchResult>[];

  @override
  Future<void> report(MatchResult result) async => results.add(result);
}

class _Connection {
  _Connection(this.channel);

  final WebSocketChannel channel;
  Ticket? user;

  void send(Envelope e) => channel.sink.add(jsonEncode(e.toJson()));
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

/// Routes WebSocket connections to the matchmaker and match rooms. One live
/// connection per user; a new connection takes over (reconnect).
class Hub {
  Hub({
    required this.ticketSecret,
    required this.results,
    this.clock = ClockConfig.standard,
    this.botAfter = const Duration(seconds: 30),
    this.botLevel = BotLevel.medium,
    Random? random,
    int Function()? now,
  }) : _random = random ?? Random.secure(),
       _now = now ?? (() => DateTime.now().millisecondsSinceEpoch) {
    matchmaker = Matchmaker(
      onMatch: _pair,
      onBot: _pairWithBot,
      botAfter: botAfter,
      now: _now,
    )..start();
  }

  final String ticketSecret;
  final ResultSink results;
  final ClockConfig clock;
  final Duration botAfter;
  final BotLevel botLevel;
  final Random _random;
  final int Function() _now;
  late final Matchmaker matchmaker;

  final _online = <String, _Connection>{};
  final _seats = <String, _Seat>{};
  final _bots = <BotDriver>[];
  final _privateRooms = <String, _PrivateRoom>{};
  final _live = <String, MatchRoom>{};
  final _watching = <_Connection, MatchRoom>{};

  /// How long a private room waits for the second player.
  static const roomTtl = Duration(minutes: 15);
  int _matches = 0;

  int get activeMatches => _seats.values.map((s) => s.room).toSet().length;

  void attach(WebSocketChannel channel) {
    final conn = _Connection(channel);
    channel.stream.listen(
      (frame) => _onFrame(conn, frame),
      onDone: () => _onClose(conn),
      onError: (_) => _onClose(conn),
    );
  }

  void _onFrame(_Connection conn, Object? frame) {
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
        room.addSpectator(conn, conn.send);
      case MessageType.spectateLeave:
        _watching.remove(conn)?.removeSpectator(conn);
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
      default:
        if (seat == null) {
          conn.send(_error(msg.id, ErrorCode.notInMatch));
        } else {
          seat.room.handle(seat.side, msg);
        }
    }
  }

  void _auth(_Connection conn, Envelope msg) {
    final token = msg.payload['ticket'];
    final ticket =
        token is String
            ? Ticket.verify(token, ticketSecret, nowSeconds: _now() ~/ 1000)
            : null;
    if (ticket == null) {
      conn.send(_error(msg.id, ErrorCode.unauthorized));
      return;
    }
    conn.user = ticket;
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
        payload: {'userId': ticket.userId},
      ),
    );
    final seat = _seats[ticket.userId];
    if (seat != null && !seat.room.isOver) {
      seat.room.connected(seat.side);
    }
  }

  void _onClose(_Connection conn) {
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
  }) {
    final id = 'm${_now()}-${_matches++}-${_random.nextInt(1 << 20)}';
    late final MatchRoom room;
    final drivers = <Side, BotDriver>{};
    room = MatchRoom(
      matchId: id,
      variant: request.variant,
      matchLength: request.matchLength,
      mode: request.mode,
      white: white,
      black: black,
      clock: clock,
      now: _now,
      send: (side, msg) {
        final player = room.player(side);
        if (player.bot) {
          drivers[side]?.receive(msg);
        } else {
          _online[player.userId]?.send(msg);
        }
      },
      onEnd: (result) {
        unawaited(results.report(result));
        _live.remove(id);
        for (final d in drivers.values) {
          d.dispose();
          _bots.remove(d);
        }
        for (final p in [white, black]) {
          if (_seats[p.userId]?.room == room) _seats.remove(p.userId);
        }
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
                  clock: clock,
                ).toJson(),
          ),
        );
      }
    }
    _live[id] = room;
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
    for (final r in _privateRooms.values) {
      r.expires.cancel();
    }
    for (final b in _bots) {
      b.dispose();
    }
    for (final s in _seats.values) {
      s.room.dispose();
    }
  }
}
