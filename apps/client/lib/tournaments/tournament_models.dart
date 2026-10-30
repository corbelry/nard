import 'package:nard_core/nard_core.dart' show Variant;
import 'package:nard_protocol/nard_protocol.dart' show defaultNoShowSeconds;

/// Tournament shapes of `docs/api/tournaments.md`.

enum TournamentType { knockout, swiss, roundRobin }

enum TournamentKind { scheduled, sitAndGo, private }

enum TournamentStatus { registering, running, finished, cancelled }

enum MyTournamentStatus {
  none,
  registered,
  playing,
  eliminated,
  champion,
  finished,
}

enum EntryKind { free, coins, invite }

enum PairingStatus { pending, ready, finished, walkover, bye }

/// List tabs of 4.1 (`GET /tournaments?tab=`).
enum TournamentTab { live, upcoming, mine, finished }

int _int(Object? v, [int fallback = 0]) => v is num ? v.toInt() : fallback;

int? _intOrNull(Object? v) => v is num ? v.toInt() : null;

DateTime? _date(Object? v) =>
    v is String ? DateTime.tryParse(v)?.toLocal() : null;

String _camel(String snake) {
  final parts = snake.split('_');
  return parts.first +
      parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
}

T _enum<T extends Enum>(List<T> values, Object? name, T fallback) {
  if (name is! String) return fallback;
  final key = _camel(name);
  for (final v in values) {
    if (v.name == key) return v;
  }
  return fallback;
}

Variant variantFromApi(Object? name) =>
    name == 'longNard' ? Variant.longNard : Variant.shortNard;

class UserLite {
  const UserLite({
    required this.id,
    required this.name,
    this.country,
    this.avatar,
  });

  final String id;
  final String name;
  final String? country;
  final String? avatar;

  static UserLite? maybe(Object? json) =>
      json is Map<String, Object?> ? fromJson(json) : null;

  static UserLite fromJson(Map<String, Object?> j) => UserLite(
    id: '${j['id']}',
    name: j['name'] as String? ?? '',
    country: j['country'] as String?,
    avatar: j['avatar'] as String?,
  );
}

/// Places [from]..[to] each get [coins] and [items] (titles are `title.*`).
class Prize {
  const Prize({
    required this.from,
    required this.to,
    this.coins = 0,
    this.items = const [],
  });

  final int from;
  final int to;
  final int coins;
  final List<String> items;

  static Prize fromJson(Map<String, Object?> j) => Prize(
    from: _int(j['from'], 1),
    to: _int(j['to'], _int(j['from'], 1)),
    coins: _int(j['coins']),
    items: [
      for (final i in (j['items'] as List?) ?? const [])
        if (i is String) i,
    ],
  );
}

List<Prize> _prizes(Object? v) => [
  for (final p in (v as List?) ?? const [])
    if (p is Map<String, Object?>) Prize.fromJson(p),
];

/// Tournament summary (list rows, register responses).
class Tournament {
  const Tournament({
    required this.id,
    required this.names,
    required this.type,
    required this.kind,
    required this.status,
    required this.variant,
    required this.matchLength,
    required this.size,
    this.clockReserveMs = 180000,
    this.clockDelayMs = 12000,
    this.minPlayers = 2,
    this.entrants = 0,
    this.entryKind = EntryKind.free,
    this.entryCoins = 0,
    this.minRating,
    this.private = false,
    this.startsAt,
    this.expiresAt,
    this.startedAt,
    this.finishedAt,
    this.cancelReason,
    this.currentRound = 0,
    this.totalRounds,
    this.prizes = const [],
    this.prizeFund = 0,
    this.myStatus = MyTournamentStatus.none,
    this.myPlace,
  });

  final String id;

  /// Locale → name (private ones: `{default}`).
  final Map<String, String> names;
  final TournamentType type;
  final TournamentKind kind;
  final TournamentStatus status;
  final Variant variant;
  final int matchLength;
  final int clockReserveMs;
  final int clockDelayMs;
  final int size;
  final int minPlayers;
  final int entrants;
  final EntryKind entryKind;
  final int entryCoins;
  final int? minRating;
  final bool private;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final String? cancelReason;
  final int currentRound;
  final int? totalRounds;
  final List<Prize> prizes;
  final int prizeFund;
  final MyTournamentStatus myStatus;
  final int? myPlace;

  String nameFor(String locale) =>
      names[locale] ??
      names['en'] ??
      names['default'] ??
      (names.isEmpty ? '' : names.values.first);

  bool get paid => entryKind == EntryKind.coins && entryCoins > 0;
  bool get live => status == TournamentStatus.running;
  bool get registering => status == TournamentStatus.registering;
  bool get full => entrants >= size;

  /// Registered, playing or eliminated (still my tournament).
  bool get joined => myStatus != MyTournamentStatus.none;

  bool get stillIn =>
      myStatus == MyTournamentStatus.registered ||
      myStatus == MyTournamentStatus.playing;

  static Tournament fromJson(Map<String, Object?> j) {
    final name = j['name'];
    final entry = j['entry'];
    final clock = j['clock'];
    return Tournament(
      id: '${j['id']}',
      names:
          name is Map
              ? {
                for (final e in name.entries)
                  if (e.value is String) '${e.key}': e.value as String,
              }
              : {if (name is String) 'default': name},
      type: _enum(TournamentType.values, j['type'], TournamentType.knockout),
      kind: _enum(TournamentKind.values, j['kind'], TournamentKind.scheduled),
      status: _enum(
        TournamentStatus.values,
        j['status'],
        TournamentStatus.registering,
      ),
      variant: variantFromApi(j['variant']),
      matchLength: _int(j['matchLength'], 1),
      clockReserveMs: clock is Map ? _int(clock['reserveMs'], 180000) : 180000,
      clockDelayMs: clock is Map ? _int(clock['delayMs'], 12000) : 12000,
      size: _int(j['size'], 2),
      minPlayers: _int(j['minPlayers'], 2),
      entrants: _int(j['entrants']),
      entryKind:
          entry is Map
              ? _enum(EntryKind.values, entry['kind'], EntryKind.free)
              : EntryKind.free,
      entryCoins: entry is Map ? _int(entry['coins']) : 0,
      minRating: _intOrNull(j['minRating']),
      private: j['private'] == true,
      startsAt: _date(j['startsAt']),
      expiresAt: _date(j['expiresAt']),
      startedAt: _date(j['startedAt']),
      finishedAt: _date(j['finishedAt']),
      cancelReason: j['cancelReason'] as String?,
      currentRound: _int(j['currentRound']),
      totalRounds: _intOrNull(j['totalRounds']),
      prizes: _prizes(j['prizes']),
      prizeFund: _int(j['prizeFund']),
      myStatus: _enum(
        MyTournamentStatus.values,
        j['myStatus'],
        MyTournamentStatus.none,
      ),
      myPlace: _intOrNull(j['myPlace']),
    );
  }
}

/// One bracket cell (`Match` in the contract).
class BracketMatch {
  const BracketMatch({
    required this.slot,
    this.matchId,
    this.white,
    this.black,
    this.status = PairingStatus.pending,
    this.result,
    this.winnerId,
    this.score,
  });

  final int slot;
  final String? matchId;
  final UserLite? white;
  final UserLite? black;
  final PairingStatus status;

  /// `white | black | none`, null while unplayed.
  final String? result;
  final String? winnerId;

  /// [white, black] points.
  final (int, int)? score;

  bool involves(String? userId) =>
      userId != null && (white?.id == userId || black?.id == userId);

  bool get decided =>
      status == PairingStatus.finished ||
      status == PairingStatus.walkover ||
      status == PairingStatus.bye;

  static BracketMatch fromJson(Map<String, Object?> j) {
    final score = j['score'];
    return BracketMatch(
      slot: _int(j['slot']),
      matchId: j['matchId'] as String?,
      white: UserLite.maybe(j['white']),
      black: UserLite.maybe(j['black']),
      status: _enum(PairingStatus.values, j['status'], PairingStatus.pending),
      result: j['result'] as String?,
      winnerId: j['winnerId'] == null ? null : '${j['winnerId']}',
      score:
          score is List && score.length == 2
              ? (_int(score[0]), _int(score[1]))
              : null,
    );
  }
}

class TournamentRound {
  const TournamentRound({
    required this.number,
    required this.stage,
    required this.finished,
    required this.matches,
  });

  final int number;

  /// Knockout: `final`, `1/2`, `1/4` …; otherwise the round number.
  final String stage;
  final bool finished;
  final List<BracketMatch> matches;

  static TournamentRound fromJson(Map<String, Object?> j) => TournamentRound(
    number: _int(j['number'], 1),
    stage: '${j['stage'] ?? j['number']}',
    finished: j['status'] == 'finished',
    matches: [
      for (final m in (j['matches'] as List?) ?? const [])
        if (m is Map<String, Object?>) BracketMatch.fromJson(m),
    ]..sort((a, b) => a.slot.compareTo(b.slot)),
  );
}

class StandingRow {
  const StandingRow({
    required this.rank,
    required this.user,
    required this.wins,
    required this.losses,
    required this.points,
    required this.buchholz,
  });

  final int rank;
  final UserLite user;
  final int wins;
  final int losses;
  final int points;
  final int buchholz;

  static StandingRow fromJson(Map<String, Object?> j) => StandingRow(
    rank: _int(j['rank'], 1),
    user: UserLite.fromJson(j['user']! as Map<String, Object?>),
    wins: _int(j['wins']),
    losses: _int(j['losses']),
    points: _int(j['points']),
    buchholz: _int(j['buchholz']),
  );
}

class Entrant {
  const Entrant({required this.user, this.seed, this.rating, this.place});

  final UserLite user;
  final int? seed;
  final int? rating;
  final int? place;

  static Entrant fromJson(Map<String, Object?> j) => Entrant(
    user: UserLite.fromJson(j['user']! as Map<String, Object?>),
    seed: _intOrNull(j['seed']),
    rating: _intOrNull(j['rating']),
    place: _intOrNull(j['place']),
  );
}

class NextMatch {
  const NextMatch({
    required this.matchId,
    required this.round,
    this.status = PairingStatus.pending,
    this.opponent,
    this.noShowSeconds = defaultNoShowSeconds,
  });

  final String matchId;
  final int round;
  final PairingStatus status;
  final UserLite? opponent;
  final int noShowSeconds;

  static NextMatch? maybe(Object? json) {
    if (json is! Map<String, Object?>) return null;
    return NextMatch(
      matchId: '${json['matchId']}',
      round: _int(json['round'], 1),
      status: _enum(
        PairingStatus.values,
        json['status'],
        PairingStatus.pending,
      ),
      opponent: UserLite.maybe(json['opponent']),
      noShowSeconds: _int(json['noShowSeconds'], defaultNoShowSeconds),
    );
  }
}

/// `GET /tournaments/{id}`: summary + bracket, standings, entrants.
class TournamentDetail {
  const TournamentDetail({
    required this.tournament,
    this.organizerId,
    this.inviteCode,
    this.entrants = const [],
    this.rounds = const [],
    this.standings,
    this.nextMatch,
  });

  final Tournament tournament;
  final String? organizerId;
  final String? inviteCode;
  final List<Entrant> entrants;
  final List<TournamentRound> rounds;

  /// Swiss / round-robin only.
  final List<StandingRow>? standings;
  final NextMatch? nextMatch;

  static TournamentDetail fromJson(Map<String, Object?> j) {
    final standings = j['standings'];
    return TournamentDetail(
      tournament: Tournament.fromJson(j),
      organizerId: j['organizerId'] == null ? null : '${j['organizerId']}',
      inviteCode: j['inviteCode'] as String?,
      entrants: [
        for (final e in (j['entrantsList'] as List?) ?? const [])
          if (e is Map<String, Object?>) Entrant.fromJson(e),
      ],
      rounds: [
        for (final r in (j['rounds'] as List?) ?? const [])
          if (r is Map<String, Object?>) TournamentRound.fromJson(r),
      ]..sort((a, b) => a.number.compareTo(b.number)),
      standings:
          standings is List
              ? [
                for (final s in standings)
                  if (s is Map<String, Object?>) StandingRow.fromJson(s),
              ]
              : null,
      nextMatch: NextMatch.maybe(j['myNextMatch']),
    );
  }
}

/// One sit-and-go table (`GET /tournaments/sng`).
class SngTable {
  const SngTable({
    required this.size,
    required this.variant,
    required this.matchLength,
    required this.entryCoins,
    required this.prizeFund,
    this.clockReserveMs = 180000,
    this.clockDelayMs = 12000,
    this.prizes = const [],
    this.tournamentId,
    this.joined = 0,
    this.expiresAt,
    this.registered = false,
  });

  final int size;
  final Variant variant;
  final int matchLength;
  final int clockReserveMs;
  final int clockDelayMs;
  final int entryCoins;
  final int prizeFund;
  final List<Prize> prizes;
  final String? tournamentId;
  final int joined;
  final DateTime? expiresAt;
  final bool registered;

  static SngTable fromJson(Map<String, Object?> j) {
    final entry = j['entry'];
    final clock = j['clock'];
    return SngTable(
      size: _int(j['size'], 8),
      variant: variantFromApi(j['variant']),
      matchLength: _int(j['matchLength'], 3),
      clockReserveMs: clock is Map ? _int(clock['reserveMs'], 180000) : 180000,
      clockDelayMs: clock is Map ? _int(clock['delayMs'], 12000) : 12000,
      entryCoins: entry is Map ? _int(entry['coins']) : 0,
      prizeFund: _int(j['prizeFund']),
      prizes: _prizes(j['prizes']),
      tournamentId: j['tournamentId'] == null ? null : '${j['tournamentId']}',
      joined: _int(j['joined']),
      expiresAt: _date(j['expiresAt']),
      registered: j['registered'] == true,
    );
  }
}
