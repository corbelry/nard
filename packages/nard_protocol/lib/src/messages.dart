import 'package:nard_core/nard_core.dart';

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

/// Typed reads from a decoded JSON object.
extension _Read on Map<String, Object?> {
  T req<T>(String key) {
    final v = this[key];
    if (v is! T) throw ProtocolException('"$key" must be $T');
    return v;
  }

  T? opt<T>(String key) {
    final v = this[key];
    if (v == null) return null;
    if (v is! T) throw ProtocolException('"$key" must be $T');
    return v as T;
  }

  String str(String key, {int max = 256}) {
    final v = req<String>(key);
    if (v.length > max) throw ProtocolException('"$key" is too long');
    return v;
  }

  Map<String, Object?> obj(String key) => req<Map<String, Object?>>(key);
}

T _enum<T extends Enum>(List<T> values, String name, String key) =>
    values.asNameMap()[name] ??
    (throw ProtocolException('"$key" has unknown value $name'));

/// `auth` (client → server): a game-server ticket issued by the API.
class AuthPayload {
  const AuthPayload(this.ticket);

  final String ticket;

  Map<String, Object?> toJson() => {'ticket': ticket};

  static AuthPayload fromJson(Map<String, Object?> j) =>
      AuthPayload(j.str('ticket', max: 2048));
}

enum QueueMode { casual, ranked }

/// `queue.join` (client → server).
class QueueJoinPayload {
  const QueueJoinPayload({
    required this.variant,
    required this.matchLength,
    required this.mode,
  });

  final Variant variant;

  /// 1, 3, 5 or 7 points.
  final int matchLength;
  final QueueMode mode;

  static const lengths = {1, 3, 5, 7};

  Map<String, Object?> toJson() => {
    'variant': variant.name,
    'matchLength': matchLength,
    'mode': mode.name,
  };

  static QueueJoinPayload fromJson(Map<String, Object?> j) {
    final length = j.req<int>('matchLength');
    if (!lengths.contains(length)) {
      throw const ProtocolException('"matchLength" must be 1, 3, 5 or 7');
    }
    return QueueJoinPayload(
      variant: _enum(Variant.values, j.str('variant'), 'variant'),
      matchLength: length,
      mode: _enum(QueueMode.values, j.str('mode'), 'mode'),
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
  });

  final String userId;
  final String name;

  /// Null for unrated (casual) games.
  final int? rating;

  /// ISO 3166-1 alpha-2.
  final String? country;

  /// Bots are always labelled (spec §7.4, ADR-024).
  final bool bot;

  Map<String, Object?> toJson() => {
    'userId': userId,
    'name': name,
    if (rating != null) 'rating': rating,
    if (country != null) 'country': country,
    'bot': bot,
  };

  static PlayerInfo fromJson(Map<String, Object?> j) => PlayerInfo(
    userId: j.str('userId', max: 64),
    name: j.str('name', max: 64),
    rating: j.opt<int>('rating'),
    country: j.opt<String>('country'),
    bot: j.opt<bool>('bot') ?? false,
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

  Map<String, Object?> toJson() => {
    'matchId': matchId,
    'variant': variant.name,
    'matchLength': matchLength,
    'mode': mode.name,
    'you': you.name,
    'white': white.toJson(),
    'black': black.toJson(),
    'clock': clock.toJson(),
  };

  static MatchFoundPayload fromJson(Map<String, Object?> j) =>
      MatchFoundPayload(
        matchId: j.str('matchId', max: 64),
        variant: _enum(Variant.values, j.str('variant'), 'variant'),
        matchLength: j.req<int>('matchLength'),
        mode: _enum(QueueMode.values, j.str('mode'), 'mode'),
        you: _enum(Side.values, j.str('you'), 'you'),
        white: PlayerInfo.fromJson(j.obj('white')),
        black: PlayerInfo.fromJson(j.obj('black')),
        clock: ClockConfig.fromJson(j.obj('clock')),
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
      ResignPayload(_enum(WinKind.values, j.str('kind'), 'kind'));
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
            : _enum(Side.values, j.str('running'), 'running'),
    sentAt: j.req<int>('sentAt'),
  );
}

/// `game.state` (server → client): the full authoritative state. Clients
/// rebuild positions by replaying [record] with nard_core.
class GameStatePayload {
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

  /// Increases with every state the server sends for this match.
  final int seq;
  final String matchId;
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

  Map<String, Object?> toJson() => {
    'seq': seq,
    'matchId': matchId,
    'gameIndex': gameIndex,
    'record': record.toJson(),
    'match': match.toJson(),
    'pending': [
      for (final m in pending)
        {'from': m.from, 'to': m.to, 'die': m.die, 'hit': m.hit},
    ],
    'clock': clock.toJson(),
    'commitment': commitment,
    if (serverSeed != null) 'serverSeed': serverSeed,
    'clientSeeds': {for (final e in clientSeeds.entries) e.key.name: e.value},
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
      pending: [
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
      ],
      clock: ClockState.fromJson(j.obj('clock')),
      commitment: j.str('commitment', max: 64),
      serverSeed: j.opt<String>('serverSeed'),
      clientSeeds: {
        for (final e in j.obj('clientSeeds').entries)
          _enum(Side.values, e.key, 'clientSeeds'):
              e.value is String
                  ? e.value! as String
                  : throw const ProtocolException(
                    'Client seeds must be strings',
                  ),
      },
      opponentConnected: j.opt<bool>('opponentConnected') ?? true,
      reconnectDeadline: j.opt<int>('reconnectDeadline'),
    );
  }
}

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
            : _enum(MoveRejection.values, j.str('rejection'), 'rejection'),
  );
}

/// Why a match ended.
enum MatchEndReason { completed, resigned, timeout, abandoned }

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
  };

  static MatchResult fromJson(Map<String, Object?> j) => MatchResult(
    matchId: j.str('matchId', max: 64),
    variant: _enum(Variant.values, j.str('variant'), 'variant'),
    matchLength: j.req<int>('matchLength'),
    mode: _enum(QueueMode.values, j.str('mode'), 'mode'),
    white: PlayerInfo.fromJson(j.obj('white')),
    black: PlayerInfo.fromJson(j.obj('black')),
    winner: _enum(Side.values, j.str('winner'), 'winner'),
    whiteScore: j.req<int>('whiteScore'),
    blackScore: j.req<int>('blackScore'),
    reason: _enum(MatchEndReason.values, j.str('reason'), 'reason'),
    games: j.req<List<Object?>>('games').cast<Map<String, Object?>>(),
    startedAt: j.req<int>('startedAt'),
    endedAt: j.req<int>('endedAt'),
  );
}
