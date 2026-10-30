import '../social/social_models.dart';

int _int(Object? v, [int fallback = 0]) => v is num ? v.toInt() : fallback;

int? _intOrNull(Object? v) => v is num ? v.toInt() : null;

DateTime? _date(Object? v) => v is String ? DateTime.tryParse(v) : null;

/// Clan roles, lowest first so `index` compares rank (ADR-036: roles
/// stack, leader > co-leader > elder > member).
enum ClanRole {
  member('member'),
  elder('elder'),
  coLeader('co_leader'),
  leader('leader');

  const ClanRole(this.api);

  /// The API value.
  final String api;

  bool operator >(ClanRole other) => index > other.index;
  bool operator >=(ClanRole other) => index >= other.index;
  bool operator <(ClanRole other) => index < other.index;

  static ClanRole parse(Object? value) => ClanRole.values.firstWhere(
    (r) => r.api == value,
    orElse: () => ClanRole.member,
  );
}

enum JoinPolicy {
  open,
  request,
  invite;

  static JoinPolicy parse(Object? value) => JoinPolicy.values.firstWhere(
    (p) => p.name == value,
    orElse: () => JoinPolicy.request,
  );
}

/// `myStatus` of `GET /clans/{id}`.
enum ClanStatus {
  none,
  pending,
  invited,
  member;

  static ClanStatus parse(Object? value) => ClanStatus.values.firstWhere(
    (s) => s.name == value,
    orElse: () => ClanStatus.none,
  );
}

/// Emblem ids (the drawing data lives in `emblem_catalog.dart`).
class Emblem {
  const Emblem({
    this.shape = 'shield',
    this.symbol = 'diamond',
    this.color = 'garnet',
    this.pattern = 'none',
  });

  final String shape;
  final String symbol;
  final String color;
  final String pattern;

  Emblem copyWith({
    String? shape,
    String? symbol,
    String? color,
    String? pattern,
  }) => Emblem(
    shape: shape ?? this.shape,
    symbol: symbol ?? this.symbol,
    color: color ?? this.color,
    pattern: pattern ?? this.pattern,
  );

  Map<String, Object?> toJson() => {
    'shape': shape,
    'symbol': symbol,
    'color': color,
    'pattern': pattern,
  };

  static Emblem fromJson(Object? j) {
    if (j is! Map) return const Emblem();
    return Emblem(
      shape: j['shape'] as String? ?? 'shield',
      symbol: j['symbol'] as String? ?? 'diamond',
      color: j['color'] as String? ?? 'garnet',
      pattern: j['pattern'] as String? ?? 'none',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Emblem &&
      other.shape == shape &&
      other.symbol == symbol &&
      other.color == color &&
      other.pattern == pattern;

  @override
  int get hashCode => Object.hash(shape, symbol, color, pattern);
}

/// `publicCard.clan` / `/me` `user.clan`.
class ClanBadge {
  const ClanBadge({
    required this.id,
    required this.tag,
    this.emblem = const Emblem(),
    this.name,
    this.role,
  });

  final String id;
  final String tag;
  final Emblem emblem;

  /// `/me` only.
  final String? name;
  final ClanRole? role;

  static ClanBadge fromJson(Map<String, Object?> j) => ClanBadge(
    id: '${j['id']}',
    tag: j['tag'] as String? ?? '',
    emblem: Emblem.fromJson(j['emblem']),
    name: j['name'] as String?,
    role: j['role'] == null ? null : ClanRole.parse(j['role']),
  );
}

/// `ClanSummary` of the API.
class ClanSummary {
  const ClanSummary({
    required this.id,
    required this.name,
    required this.tag,
    this.emblem = const Emblem(),
    this.level = 1,
    this.xp = 0,
    this.memberCount = 0,
    this.maxMembers = 50,
    this.rating,
    this.language = 'az',
    this.joinPolicy = JoinPolicy.request,
    this.minRating,
  });

  final String id;
  final String name;
  final String tag;
  final Emblem emblem;
  final int level;
  final int xp;
  final int memberCount;
  final int maxMembers;
  final int? rating;
  final String language;
  final JoinPolicy joinPolicy;
  final int? minRating;

  bool get full => memberCount >= maxMembers;

  static ClanSummary fromJson(Map<String, Object?> j) => ClanSummary(
    id: '${j['id']}',
    name: j['name'] as String? ?? '',
    tag: j['tag'] as String? ?? '',
    emblem: Emblem.fromJson(j['emblem']),
    level: _int(j['level'], 1),
    xp: _int(j['xp']),
    memberCount: _int(j['memberCount']),
    maxMembers: _int(j['maxMembers'], 50),
    rating: _intOrNull(j['rating']),
    language: j['language'] as String? ?? 'az',
    joinPolicy: JoinPolicy.parse(j['joinPolicy']),
    minRating: _intOrNull(j['minRating']),
  );
}

class ClanMember {
  const ClanMember({
    required this.user,
    required this.role,
    this.joinedAt,
    this.weeklyDonated = 0,
  });

  final PublicUser user;
  final ClanRole role;
  final DateTime? joinedAt;
  final int weeklyDonated;

  static ClanMember fromJson(Map<String, Object?> j) => ClanMember(
    user: PublicUser.fromJson(j['user']! as Map<String, Object?>),
    role: ClanRole.parse(j['role']),
    joinedAt: _date(j['joinedAt']),
    weeklyDonated: _int(j['weeklyDonated']),
  );
}

/// The weekly shared chest (5.4).
class ClanChest {
  const ClanChest({
    this.week = '',
    this.coins = 0,
    this.target = 10000,
    this.myDonated,
  });

  final String week;
  final int coins;
  final int target;
  final int? myDonated;

  bool get full => coins >= target;

  static ClanChest fromJson(Map<String, Object?> j) => ClanChest(
    week: '${j['week'] ?? ''}',
    coins: _int(j['coins']),
    target: _int(j['target'], 10000),
    myDonated: _intOrNull(j['myDonated']),
  );
}

/// `GET /clans/{id}` (5.2, 5.4, 5.5).
class ClanDetail {
  const ClanDetail({
    required this.summary,
    this.description,
    this.xpNext,
    this.onlineCount = 0,
    this.myStatus = ClanStatus.none,
    this.myRole,
    this.ratingMet = true,
    this.chest,
    this.members = const [],
  });

  final ClanSummary summary;
  final String? description;
  final int? xpNext;
  final int onlineCount;
  final ClanStatus myStatus;
  final ClanRole? myRole;
  final bool ratingMet;
  final ClanChest? chest;

  /// By role (leader first), then join date.
  final List<ClanMember> members;

  String get id => summary.id;

  ClanDetail copyWith({ClanChest? chest, ClanSummary? summary}) => ClanDetail(
    summary: summary ?? this.summary,
    description: description,
    xpNext: xpNext,
    onlineCount: onlineCount,
    myStatus: myStatus,
    myRole: myRole,
    ratingMet: ratingMet,
    chest: chest ?? this.chest,
    members: members,
  );

  static ClanDetail fromJson(Map<String, Object?> j) {
    final chest = j['chest'];
    final met = j['requirementsMet'];
    return ClanDetail(
      summary: ClanSummary.fromJson(j),
      description: j['description'] as String?,
      xpNext: _intOrNull(j['xpNext']),
      onlineCount: _int(j['onlineCount']),
      myStatus: ClanStatus.parse(j['myStatus']),
      myRole: j['myRole'] == null ? null : ClanRole.parse(j['myRole']),
      ratingMet: met is Map ? met['rating'] != false : true,
      chest: chest is Map<String, Object?> ? ClanChest.fromJson(chest) : null,
      members: [
        for (final m in (j['members'] as List?) ?? const [])
          if (m is Map<String, Object?>) ClanMember.fromJson(m),
      ],
    );
  }
}

class MessageAuthor {
  const MessageAuthor({required this.id, required this.name});

  final String id;
  final String name;
}

/// A clan chat line: text from a member, or a system event.
class ClanMessage {
  const ClanMessage({
    required this.id,
    required this.system,
    this.author,
    this.text,
    this.event,
    this.data = const {},
    this.createdAt,
  });

  final int id;
  final bool system;
  final MessageAuthor? author;
  final String? text;

  /// created, joined, left, kicked, promoted, demoted, leader, renamed,
  /// donated, chest_full, war_started, war_win, war_ended.
  final String? event;
  final Map<String, Object?> data;
  final DateTime? createdAt;

  static ClanMessage fromJson(Map<String, Object?> j) {
    final a = j['author'];
    final data = j['data'];
    return ClanMessage(
      id: _int(j['id']),
      system: j['kind'] == 'system',
      author:
          a is Map
              ? MessageAuthor(id: '${a['id']}', name: '${a['name'] ?? ''}')
              : null,
      text: j['text'] as String?,
      event: j['event'] as String?,
      data: data is Map<String, Object?> ? data : const {},
      createdAt: _date(j['createdAt']),
    );
  }
}

class WarPlayer {
  const WarPlayer({required this.id, required this.name});

  final String id;
  final String name;

  static WarPlayer? fromJson(Object? j) =>
      j is Map ? WarPlayer(id: '${j['id']}', name: '${j['name'] ?? ''}') : null;
}

/// A counted war match (winner, loser, score).
class WarMatch {
  const WarMatch({
    required this.matchId,
    this.winner,
    this.loser,
    this.score = const [0, 0],
    this.won = false,
    this.createdAt,
  });

  final String matchId;
  final WarPlayer? winner;
  final WarPlayer? loser;
  final List<int> score;

  /// My clan won it.
  final bool won;
  final DateTime? createdAt;

  static WarMatch fromJson(Map<String, Object?> j) {
    final score = j['score'];
    return WarMatch(
      matchId: '${j['matchId'] ?? ''}',
      winner: WarPlayer.fromJson(j['winner']),
      loser: WarPlayer.fromJson(j['loser']),
      score:
          score is List && score.length == 2
              ? [_int(score[0]), _int(score[1])]
              : const [0, 0],
      won: j['won'] == true,
      createdAt: _date(j['createdAt']),
    );
  }
}

/// The weekly war (5.6); `opponent` is null when no clan was paired.
class ClanWar {
  const ClanWar({
    required this.live,
    required this.clan,
    this.opponent,
    this.startsAt,
    this.endsAt,
    this.mine = 0,
    this.theirs = 0,
    this.matchesCounted = 0,
    this.maxMatches = 25,
    this.pointsPerWin = 3,
    this.result,
    this.matches = const [],
  });

  final bool live;
  final ClanSummary clan;
  final ClanSummary? opponent;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int mine;
  final int theirs;
  final int matchesCounted;
  final int maxMatches;
  final int pointsPerWin;

  /// won | lost | draw once finished.
  final String? result;
  final List<WarMatch> matches;

  static ClanWar fromJson(Map<String, Object?> j) {
    final score = j['score'];
    final opp = j['opponent'];
    return ClanWar(
      live: j['status'] == 'live',
      clan: ClanSummary.fromJson(j['clan']! as Map<String, Object?>),
      opponent: opp is Map<String, Object?> ? ClanSummary.fromJson(opp) : null,
      startsAt: _date(j['startsAt']),
      endsAt: _date(j['endsAt']),
      mine: score is Map ? _int(score['mine']) : 0,
      theirs: score is Map ? _int(score['theirs']) : 0,
      matchesCounted: _int(j['matchesCounted']),
      maxMatches: _int(j['maxMatches'], 25),
      pointsPerWin: _int(j['pointsPerWin'], 3),
      result: j['result'] as String?,
      matches: [
        for (final m in (j['matches'] as List?) ?? const [])
          if (m is Map<String, Object?>) WarMatch.fromJson(m),
      ],
    );
  }
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.clan,
    required this.points,
  });

  final int rank;
  final ClanSummary clan;
  final int points;
}

/// `GET /clans/leaderboard` (5.7).
class ClanLeaderboard {
  const ClanLeaderboard({
    this.entries = const [],
    this.myRank,
    this.myPoints,
    this.myClan,
  });

  final List<LeaderboardEntry> entries;
  final int? myRank;
  final int? myPoints;
  final ClanBadge? myClan;

  static ClanLeaderboard fromJson(Map<String, Object?> j) {
    final me = j['me'];
    return ClanLeaderboard(
      entries: [
        for (final e in (j['entries'] as List?) ?? const [])
          if (e is Map<String, Object?>)
            LeaderboardEntry(
              rank: _int(e['rank']),
              clan: ClanSummary.fromJson(e['clan']! as Map<String, Object?>),
              points: _int(e['points']),
            ),
      ],
      myRank: me is Map ? _intOrNull(me['rank']) : null,
      myPoints: me is Map ? _intOrNull(me['points']) : null,
      myClan:
          me is Map && me['clan'] is Map<String, Object?>
              ? ClanBadge.fromJson(me['clan']! as Map<String, Object?>)
              : null,
    );
  }
}

/// `GET /me/clan-invites`.
class ClanInvite {
  const ClanInvite({
    required this.id,
    required this.clan,
    this.invitedBy,
    this.expiresAt,
  });

  final int id;
  final ClanSummary clan;
  final PublicUser? invitedBy;
  final DateTime? expiresAt;

  static ClanInvite fromJson(Map<String, Object?> j) {
    final by = j['invitedBy'];
    return ClanInvite(
      id: _int(j['id']),
      clan: ClanSummary.fromJson(j['clan']! as Map<String, Object?>),
      invitedBy: by is Map<String, Object?> ? PublicUser.fromJson(by) : null,
      expiresAt: _date(j['expiresAt']),
    );
  }
}

/// A pending join request (leaders' view).
class JoinRequest {
  const JoinRequest({required this.id, required this.user});

  final int id;
  final PublicUser user;

  static JoinRequest fromJson(Map<String, Object?> j) => JoinRequest(
    id: _int(j['id']),
    user: PublicUser.fromJson(j['user']! as Map<String, Object?>),
  );
}

/// Fields of `POST /clans`.
class ClanDraft {
  const ClanDraft({
    this.name = '',
    this.tag = '',
    this.emblem = const Emblem(),
    this.language = 'az',
    this.joinPolicy = JoinPolicy.request,
    this.minRating,
    this.description,
  });

  final String name;
  final String tag;
  final Emblem emblem;
  final String language;
  final JoinPolicy joinPolicy;

  /// null = anyone ("Hamı").
  final int? minRating;
  final String? description;

  ClanDraft copyWith({
    String? name,
    String? tag,
    Emblem? emblem,
    String? language,
    JoinPolicy? joinPolicy,
    int? Function()? minRating,
    String? Function()? description,
  }) => ClanDraft(
    name: name ?? this.name,
    tag: tag ?? this.tag,
    emblem: emblem ?? this.emblem,
    language: language ?? this.language,
    joinPolicy: joinPolicy ?? this.joinPolicy,
    minRating: minRating != null ? minRating() : this.minRating,
    description: description != null ? description() : this.description,
  );

  Map<String, Object?> toJson() => {
    'name': name.trim(),
    'tag': tag.trim().toUpperCase(),
    'emblem': emblem.toJson(),
    'language': language,
    'joinPolicy': joinPolicy.name,
    'minRating': minRating,
    if (description != null && description!.trim().isNotEmpty)
      'description': description!.trim(),
  };
}
