import 'package:nard_core/nard_core.dart';

import 'read.dart';

/// Thrown when a payload does not match its schema.
class ProtocolException implements FormatException {
  const ProtocolException(this.message);

  @override
  final String message;

  @override
  int? get offset => null;

  @override
  Object? get source => null;

  @override
  String toString() => 'ProtocolException: $message';
}

/// Optional protocol features a client announces in `auth` (ADR-048). The
/// server enables those it knows and lists them in `hello.features`; a
/// client that announces nothing gets the original behaviour.
abstract final class ProtocolFeature {
  /// `game.state` deltas: only the record actions appended since the last
  /// state this connection received (see [GameStateDelta]).
  static const stateDelta = 'stateDelta';
}

/// `auth` (client → server): a game-server ticket issued by the API, plus
/// the optional [ProtocolFeature]s the client understands.
class AuthPayload {
  const AuthPayload(this.ticket, {this.features = const {}});

  final String ticket;

  /// Unknown names are kept (and ignored by the server).
  final Set<String> features;

  Map<String, Object?> toJson() => {
    'ticket': ticket,
    if (features.isNotEmpty) 'features': features.toList(),
  };

  static AuthPayload fromJson(Map<String, Object?> j) {
    final raw = j.opt<List<Object?>>('features') ?? const [];
    if (raw.length > 16) throw const ProtocolException('Too many "features"');
    return AuthPayload(
      j.str('ticket', max: 2048),
      features: {
        for (final f in raw)
          if (f is String && f.length <= 32)
            f
          else
            throw const ProtocolException('"features" must be short strings'),
      },
    );
  }
}

/// How a match was made. `tournament` matches are assigned by the API
/// (never queued) and are unrated (QUESTIONS #33).
enum QueueMode { casual, ranked, tournament }

/// Online time controls (spec §7.3, QUESTIONS #20, ADR-044): reserve per
/// player plus a delay per turn. Players only meet others of the same
/// control. Correspondence ("Gündəlik") is a later, separate product.
enum TimeControl {
  /// "Blits": 1 min + 8 s.
  blitz(ClockConfig(reserveMs: 60 * 1000, delayMs: 8000)),

  /// "Sürətli": 3 min + 12 s, the default.
  rapid(ClockConfig.standard),

  /// "Klassik": 5 min + 15 s.
  classic(ClockConfig(reserveMs: 5 * 60 * 1000, delayMs: 15000));

  const TimeControl(this.clock);

  final ClockConfig clock;

  /// The optional `timeControl` field of [j]; [rapid] when absent (older
  /// clients and servers).
  static TimeControl read(Map<String, Object?> j) {
    final name = j.opt<String>('timeControl');
    return name == null
        ? rapid
        : readEnum(TimeControl.values, name, 'timeControl');
  }
}

/// `queue.join` (client → server).
class QueueJoinPayload {
  const QueueJoinPayload({
    required this.variant,
    required this.matchLength,
    required this.mode,
    this.timeControl = TimeControl.rapid,
  });

  final Variant variant;

  /// 1, 3, 5 or 7 points.
  final int matchLength;
  final QueueMode mode;

  /// Optional on the wire; [TimeControl.rapid] when absent.
  final TimeControl timeControl;

  static const lengths = {1, 3, 5, 7};

  QueueJoinPayload copyWith({
    Variant? variant,
    int? matchLength,
    QueueMode? mode,
    TimeControl? timeControl,
  }) => QueueJoinPayload(
    variant: variant ?? this.variant,
    matchLength: matchLength ?? this.matchLength,
    mode: mode ?? this.mode,
    timeControl: timeControl ?? this.timeControl,
  );

  Map<String, Object?> toJson() => {
    'variant': variant.name,
    'matchLength': matchLength,
    'mode': mode.name,
    'timeControl': timeControl.name,
  };

  static QueueJoinPayload fromJson(Map<String, Object?> j) {
    final length = j.req<int>('matchLength');
    if (!lengths.contains(length)) {
      throw const ProtocolException('"matchLength" must be 1, 3, 5 or 7');
    }
    final mode = readEnum(QueueMode.values, j.str('mode'), 'mode');
    if (mode == QueueMode.tournament) {
      throw const ProtocolException('"mode" must be casual or ranked');
    }
    return QueueJoinPayload(
      variant: readEnum(Variant.values, j.str('variant'), 'variant'),
      matchLength: length,
      mode: mode,
      timeControl: TimeControl.read(j),
    );
  }
}

/// A seat in a match.
class PlayerInfo {
  const PlayerInfo({
    required this.userId,
    required this.name,
    this.rating,
    this.country,
    this.bot = false,
    this.cosmetics = const {},
  });

  final String userId;
  final String name;

  /// Null for unrated (casual) games.
  final int? rating;

  /// ISO 3166-1 alpha-2.
  final String? country;

  /// Bots are always labelled (spec §7.4, ADR-024).
  final bool bot;

  /// Equipped items, category → item id (spec §8.6, "show opponent's
  /// cosmetics").
  final Map<String, String> cosmetics;

  Map<String, Object?> toJson() => {
    'userId': userId,
    'name': name,
    if (rating != null) 'rating': rating,
    if (country != null) 'country': country,
    'bot': bot,
    if (cosmetics.isNotEmpty) 'cosmetics': cosmetics,
  };

  static PlayerInfo fromJson(Map<String, Object?> j) => PlayerInfo(
    userId: j.str('userId', max: 64),
    name: j.str('name', max: 64),
    rating: j.opt<int>('rating'),
    country: j.opt<String>('country'),
    bot: j.opt<bool>('bot') ?? false,
    cosmetics: {
      for (final e
          in (j.opt<Map<String, Object?>>('cosmetics') ?? const {}).entries)
        if (e.value is String && e.key.length <= 24)
          e.key: (e.value! as String),
    },
  );
}

/// Chess-style clock settings (spec §7.3).
class ClockConfig {
  const ClockConfig({required this.reserveMs, required this.delayMs});

  /// Reserve per player for the whole match.
  final int reserveMs;

  /// Free time per turn before the reserve runs.
  final int delayMs;

  static const standard = ClockConfig(reserveMs: 3 * 60 * 1000, delayMs: 12000);

  Map<String, Object?> toJson() => {'reserveMs': reserveMs, 'delayMs': delayMs};

  static ClockConfig fromJson(Map<String, Object?> j) => ClockConfig(
    reserveMs: j.req<int>('reserveMs'),
    delayMs: j.req<int>('delayMs'),
  );
}

/// `match.found` (server → client).
class MatchFoundPayload {
  const MatchFoundPayload({
    required this.matchId,
    required this.variant,
    required this.matchLength,
    required this.mode,
    required this.you,
    required this.white,
    required this.black,
    required this.clock,
    this.tournamentId,
    this.round,
  });

  final String matchId;
  final Variant variant;
  final int matchLength;
  final QueueMode mode;

  /// The receiving player's side.
  final Side you;
  final PlayerInfo white;
  final PlayerInfo black;
  final ClockConfig clock;

  /// Tournament matches only (2.5 "RAUND 1" overline).
  final String? tournamentId;
  final int? round;

  Map<String, Object?> toJson() => {
    'matchId': matchId,
    'variant': variant.name,
    'matchLength': matchLength,
    'mode': mode.name,
    'you': you.name,
    'white': white.toJson(),
    'black': black.toJson(),
    'clock': clock.toJson(),
    if (tournamentId != null) 'tournamentId': tournamentId,
    if (round != null) 'round': round,
  };

  static MatchFoundPayload fromJson(Map<String, Object?> j) =>
      MatchFoundPayload(
        matchId: j.str('matchId', max: 64),
        variant: readEnum(Variant.values, j.str('variant'), 'variant'),
        matchLength: j.req<int>('matchLength'),
        mode: readEnum(QueueMode.values, j.str('mode'), 'mode'),
        you: readEnum(Side.values, j.str('you'), 'you'),
        white: PlayerInfo.fromJson(j.obj('white')),
        black: PlayerInfo.fromJson(j.obj('black')),
        clock: ClockConfig.fromJson(j.obj('clock')),
        tournamentId: j.opt<String>('tournamentId'),
        round: j.opt<int>('round'),
      );
}

/// `game.seed` (client → server): the player's fair-dice seed (FD-02).
class SeedPayload {
  const SeedPayload(this.clientSeed);

  final String clientSeed;

  Map<String, Object?> toJson() => {'clientSeed': clientSeed};

  static SeedPayload fromJson(Map<String, Object?> j) =>
      SeedPayload(j.str('clientSeed', max: 64));
}

/// `game.move` (client → server): one checker of the turn being built.
class MovePayload {
  const MovePayload(this.from, this.to, {this.die});

  /// Mover's own slots (25 = bar, 0 = off).
  final int from;
  final int to;

  /// The die to use when several fit (bearing off); the server picks the
  /// smallest when omitted.
  final int? die;

  Map<String, Object?> toJson() => {
    'from': from,
    'to': to,
    if (die != null) 'die': die,
  };

  static MovePayload fromJson(Map<String, Object?> j) {
    final from = j.req<int>('from');
    final to = j.req<int>('to');
    final die = j.opt<int>('die');
    if (from < 1 || from > 25 || to < 0 || to > 24) {
      throw const ProtocolException('Slot out of range');
    }
    if (die != null && (die < 1 || die > 6)) {
      throw const ProtocolException('Die out of range');
    }
    return MovePayload(from, to, die: die);
  }
}

/// `game.resign` (client → server).
class ResignPayload {
  const ResignPayload(this.kind);

  final WinKind kind;

  Map<String, Object?> toJson() => {'kind': kind.name};

  static ResignPayload fromJson(Map<String, Object?> j) =>
      ResignPayload(readEnum(WinKind.values, j.str('kind'), 'kind'));
}

/// Remaining time; the running side's clock is measured from [sentAt].
class ClockState {
  const ClockState({
    required this.whiteMs,
    required this.blackMs,
    required this.delayMs,
    this.running,
    required this.sentAt,
  });

  final int whiteMs;
  final int blackMs;

  /// Delay left for the running side's current turn.
  final int delayMs;
  final Side? running;

  /// Server time (ms since epoch) when these values were taken.
  final int sentAt;

  Map<String, Object?> toJson() => {
    'whiteMs': whiteMs,
    'blackMs': blackMs,
    'delayMs': delayMs,
    if (running != null) 'running': running!.name,
    'sentAt': sentAt,
  };

  static ClockState fromJson(Map<String, Object?> j) => ClockState(
    whiteMs: j.req<int>('whiteMs'),
    blackMs: j.req<int>('blackMs'),
    delayMs: j.req<int>('delayMs'),
    running:
        j.opt<String>('running') == null
            ? null
            : readEnum(Side.values, j.str('running'), 'running'),
    sentAt: j.req<int>('sentAt'),
  );
}

/// A `game.state` payload: a full [GameStatePayload] or, for clients that
/// announced [ProtocolFeature.stateDelta], a [GameStateDelta] (ADR-048).
sealed class GameStateFrame {
  /// Increases with every state the server sends for this match.
  int get seq;
  String get matchId;
  int get gameIndex;

  Map<String, Object?> toJson();

  /// A frame with `delta` is a [GameStateDelta], otherwise a full state.
  static GameStateFrame fromJson(Map<String, Object?> j) =>
      j.containsKey('delta')
          ? GameStateDelta.fromJson(j)
          : GameStatePayload.fromJson(j);
}

/// `game.state` (server → client): the full authoritative state. Clients
/// rebuild positions by replaying [record] with nard_core.
class GameStatePayload implements GameStateFrame {
  const GameStatePayload({
    required this.seq,
    required this.matchId,
    required this.gameIndex,
    required this.record,
    required this.match,
    required this.pending,
    required this.clock,
    required this.commitment,
    this.serverSeed,
    this.clientSeeds = const {},
    this.opponentConnected = true,
    this.reconnectDeadline,
  });

  @override
  final int seq;
  @override
  final String matchId;
  @override
  final int gameIndex;
  final GameRecord record;

  /// Score before the current game.
  final MatchState match;

  /// Moves of the turn being built by the side to move.
  final List<Move> pending;
  final ClockState clock;

  /// FD-01 commitment of the current game.
  final String commitment;

  /// Revealed once the game is over (FD-05).
  final String? serverSeed;
  final Map<Side, String> clientSeeds;
  final bool opponentConnected;

  /// When the absent opponent forfeits (ms since epoch).
  final int? reconnectDeadline;

  GameState get state => record.replay();

  /// This state for a receiver that already holds the first [from] actions
  /// of [record] (same match and game). [withMatch] / [withSeeds] false
  /// leave out [match] / [clientSeeds] when the receiver has them already.
  GameStateDelta deltaSince(
    int from, {
    bool withMatch = true,
    bool withSeeds = true,
  }) => GameStateDelta(
    seq: seq,
    matchId: matchId,
    gameIndex: gameIndex,
    from: from,
    actions: record.actions.sublist(from),
    match: withMatch ? match : null,
    pending: pending,
    clock: clock,
    serverSeed: serverSeed,
    clientSeeds: withSeeds ? clientSeeds : null,
    opponentConnected: opponentConnected,
    reconnectDeadline: reconnectDeadline,
  );

  @override
  Map<String, Object?> toJson() => {
    'seq': seq,
    'matchId': matchId,
    'gameIndex': gameIndex,
    'record': record.toJson(),
    'match': match.toJson(),
    'pending': _pendingJson(pending),
    'clock': clock.toJson(),
    'commitment': commitment,
    if (serverSeed != null) 'serverSeed': serverSeed,
    'clientSeeds': _seedsJson(clientSeeds),
    'opponentConnected': opponentConnected,
    if (reconnectDeadline != null) 'reconnectDeadline': reconnectDeadline,
  };

  static GameStatePayload fromJson(Map<String, Object?> j) {
    final GameRecord record;
    try {
      record = GameRecord.fromJson(j.obj('record'));
    } on ProtocolException {
      rethrow;
    } on Object catch (e) {
      throw ProtocolException('Invalid record: $e');
    }
    return GameStatePayload(
      seq: j.req<int>('seq'),
      matchId: j.str('matchId', max: 64),
      gameIndex: j.req<int>('gameIndex'),
      record: record,
      match: MatchState.fromJson(j.obj('match')),
      pending: _readPending(j),
      clock: ClockState.fromJson(j.obj('clock')),
      commitment: j.str('commitment', max: 64),
      serverSeed: j.opt<String>('serverSeed'),
      clientSeeds: _readSeeds(j),
      opponentConnected: j.opt<bool>('opponentConnected') ?? true,
      reconnectDeadline: j.opt<int>('reconnectDeadline'),
    );
  }
}

/// A `game.state` that carries only the record actions appended since the
/// receiver's previous state of the same game (ADR-048): `delta: {from,
/// actions}` instead of `record`, and no `commitment` (fixed per game).
/// `match` and `clientSeeds` are sent only when they changed since that
/// state; every other field is complete. The server sends one only to a
/// connection that announced [ProtocolFeature.stateDelta] and already got a
/// state of this game; [applyTo] rebuilds the full state.
class GameStateDelta implements GameStateFrame {
  const GameStateDelta({
    required this.seq,
    required this.matchId,
    required this.gameIndex,
    required this.from,
    required this.actions,
    this.match,
    required this.pending,
    required this.clock,
    this.serverSeed,
    this.clientSeeds,
    this.opponentConnected = true,
    this.reconnectDeadline,
  });

  @override
  final int seq;
  @override
  final String matchId;
  @override
  final int gameIndex;

  /// How many record actions the receiver must already hold.
  final int from;

  /// The actions after the first [from].
  final List<GameAction> actions;

  /// Null: unchanged since the base state.
  final MatchState? match;
  final List<Move> pending;
  final ClockState clock;
  final String? serverSeed;

  /// Null: unchanged since the base state.
  final Map<Side, String>? clientSeeds;
  final bool opponentConnected;
  final int? reconnectDeadline;

  /// The full state this delta leads to from [base]; throws
  /// [StateGapException] when [base] is not the state it builds on
  /// (another match or game, or a different number of actions).
  GameStatePayload applyTo(GameStatePayload base) {
    if (base.matchId != matchId ||
        base.gameIndex != gameIndex ||
        base.record.actions.length != from) {
      throw StateGapException(
        'Delta from $matchId/$gameIndex@$from does not fit '
        '${base.matchId}/${base.gameIndex}@${base.record.actions.length}',
      );
    }
    return GameStatePayload(
      seq: seq,
      matchId: matchId,
      gameIndex: gameIndex,
      record: GameRecord(
        variant: base.record.variant,
        config: base.record.config,
        actions: [...base.record.actions, ...actions],
      ),
      match: match ?? base.match,
      pending: pending,
      clock: clock,
      commitment: base.commitment,
      serverSeed: serverSeed,
      clientSeeds: clientSeeds ?? base.clientSeeds,
      opponentConnected: opponentConnected,
      reconnectDeadline: reconnectDeadline,
    );
  }

  @override
  Map<String, Object?> toJson() => {
    'seq': seq,
    'matchId': matchId,
    'gameIndex': gameIndex,
    'delta': {
      'from': from,
      'actions': [for (final a in actions) a.toJson()],
    },
    if (match != null) 'match': match!.toJson(),
    'pending': _pendingJson(pending),
    'clock': clock.toJson(),
    if (serverSeed != null) 'serverSeed': serverSeed,
    if (clientSeeds != null) 'clientSeeds': _seedsJson(clientSeeds!),
    'opponentConnected': opponentConnected,
    if (reconnectDeadline != null) 'reconnectDeadline': reconnectDeadline,
  };

  static GameStateDelta fromJson(Map<String, Object?> j) {
    final delta = j.obj('delta');
    final from = delta.req<int>('from');
    if (from < 0) throw const ProtocolException('"from" must be >= 0');
    final List<GameAction> actions;
    try {
      actions = [
        for (final a in delta.req<List<Object?>>('actions'))
          if (a is Map<String, Object?>)
            GameAction.fromJson(a)
          else
            throw const ProtocolException('"actions" items must be objects'),
      ];
    } on ProtocolException {
      rethrow;
    } on Object catch (e) {
      throw ProtocolException('Invalid actions: $e');
    }
    return GameStateDelta(
      seq: j.req<int>('seq'),
      matchId: j.str('matchId', max: 64),
      gameIndex: j.req<int>('gameIndex'),
      from: from,
      actions: actions,
      match: j['match'] == null ? null : MatchState.fromJson(j.obj('match')),
      pending: _readPending(j),
      clock: ClockState.fromJson(j.obj('clock')),
      serverSeed: j.opt<String>('serverSeed'),
      clientSeeds: j['clientSeeds'] == null ? null : _readSeeds(j),
      opponentConnected: j.opt<bool>('opponentConnected') ?? true,
      reconnectDeadline: j.opt<int>('reconnectDeadline'),
    );
  }
}

/// A [GameStateDelta] that does not build on the receiver's state: the
/// client asks for a full state (`game.sync`) instead of guessing.
class StateGapException implements Exception {
  const StateGapException(this.message);

  final String message;

  @override
  String toString() => 'StateGapException: $message';
}

List<Map<String, Object?>> _pendingJson(List<Move> pending) => [
  for (final m in pending)
    {'from': m.from, 'to': m.to, 'die': m.die, 'hit': m.hit},
];

List<Move> _readPending(Map<String, Object?> j) => [
  for (final m in j.req<List<Object?>>('pending'))
    if (m is Map<String, Object?>)
      Move(
        m.req<int>('from'),
        m.req<int>('to'),
        m.req<int>('die'),
        hit: m.opt<bool>('hit') ?? false,
      )
    else
      throw const ProtocolException('"pending" items must be objects'),
];

Map<String, String> _seedsJson(Map<Side, String> seeds) => {
  for (final e in seeds.entries) e.key.name: e.value,
};

Map<Side, String> _readSeeds(Map<String, Object?> j) => {
  for (final e in j.obj('clientSeeds').entries)
    readEnum(Side.values, e.key, 'clientSeeds'):
        e.value is String
            ? e.value! as String
            : throw const ProtocolException('Client seeds must be strings'),
};

/// Error codes of `error` replies.
abstract final class ErrorCode {
  static const badRequest = 'bad_request';
  static const unauthorized = 'unauthorized';
  static const notInMatch = 'not_in_match';
  static const notYourTurn = 'not_your_turn';
  static const illegalMove = 'illegal_move';
  static const illegalAction = 'illegal_action';
  static const rateLimited = 'rate_limited';
  static const notImplemented = 'not_implemented';

  /// Abandonment penalty: the public queue is closed until the time (epoch
  /// seconds) in the message (ADR-042).
  static const queueCooldown = 'queue_cooldown';

  /// Banned by a moderator while connected: sent just before the server
  /// closes the socket ([CloseCode.policy], ADR-045).
  static const banned = 'banned';
}

/// WebSocket close codes the server uses (ADR-045). Application range
/// (4000 + the RFC 6455 code it stands for): servers may only send 1000 or
/// 3000-4999 through `package:web_socket`.
abstract final class CloseCode {
  /// Policy violation; the close reason says which: `banned`,
  /// `auth_timeout` or `rate_limited`.
  static const policy = 4008;

  /// A frame over the size limit (reason `frame_too_large`).
  static const tooLarge = 4009;
}

/// `error` (server → client), echoing the request id.
class ErrorPayload {
  const ErrorPayload({required this.code, this.message = '', this.rejection});

  final String code;
  final String message;

  /// Why a `game.move` was refused (ADR-026).
  final MoveRejection? rejection;

  Map<String, Object?> toJson() => {
    'code': code,
    'message': message,
    if (rejection != null) 'rejection': rejection!.name,
  };

  static ErrorPayload fromJson(Map<String, Object?> j) => ErrorPayload(
    code: j.str('code', max: 64),
    message: j.opt<String>('message') ?? '',
    rejection:
        j.opt<String>('rejection') == null
            ? null
            : readEnum(MoveRejection.values, j.str('rejection'), 'rejection'),
  );
}

/// Why a match ended. `walkover`: a tournament opponent did not show up
/// within the no-show time; no game was played.
enum MatchEndReason { completed, resigned, timeout, abandoned, walkover }

/// Result the game server reports to the API (Redis stream `match.results`
/// and signed HTTP). Mirrored by the JSON schema in `schema/`.
class MatchResult {
  const MatchResult({
    required this.matchId,
    required this.variant,
    required this.matchLength,
    required this.mode,
    required this.white,
    required this.black,
    required this.winner,
    required this.whiteScore,
    required this.blackScore,
    required this.reason,
    required this.games,
    required this.startedAt,
    required this.endedAt,
    this.tournamentId,
    this.timeControl,
  });

  final String matchId;
  final Variant variant;
  final int matchLength;
  final QueueMode mode;
  final PlayerInfo white;
  final PlayerInfo black;
  final Side winner;
  final int whiteScore;
  final int blackScore;
  final MatchEndReason reason;

  /// Per game: record JSON plus its revealed seeds.
  final List<Map<String, Object?>> games;
  final int startedAt;
  final int endedAt;

  /// Set for tournament matches (mode `tournament`): the API advances the
  /// bracket with this result.
  final String? tournamentId;

  /// The clock the match was played with (ADR-044). Optional in the
  /// schema: ratings are shared across controls, the API may ignore it.
  final TimeControl? timeControl;

  Map<String, Object?> toJson() => {
    'matchId': matchId,
    'variant': variant.name,
    'matchLength': matchLength,
    'mode': mode.name,
    'white': white.toJson(),
    'black': black.toJson(),
    'winner': winner.name,
    'whiteScore': whiteScore,
    'blackScore': blackScore,
    'reason': reason.name,
    'games': games,
    'startedAt': startedAt,
    'endedAt': endedAt,
    if (tournamentId != null) 'tournamentId': tournamentId,
    if (timeControl != null) 'timeControl': timeControl!.name,
  };

  static MatchResult fromJson(Map<String, Object?> j) => MatchResult(
    matchId: j.str('matchId', max: 64),
    variant: readEnum(Variant.values, j.str('variant'), 'variant'),
    matchLength: j.req<int>('matchLength'),
    mode: readEnum(QueueMode.values, j.str('mode'), 'mode'),
    white: PlayerInfo.fromJson(j.obj('white')),
    black: PlayerInfo.fromJson(j.obj('black')),
    winner: readEnum(Side.values, j.str('winner'), 'winner'),
    whiteScore: j.req<int>('whiteScore'),
    blackScore: j.req<int>('blackScore'),
    reason: readEnum(MatchEndReason.values, j.str('reason'), 'reason'),
    games: j.req<List<Object?>>('games').cast<Map<String, Object?>>(),
    startedAt: j.req<int>('startedAt'),
    endedAt: j.req<int>('endedAt'),
    tournamentId: j.opt<String>('tournamentId'),
    timeControl: j['timeControl'] == null ? null : TimeControl.read(j),
  );
}
