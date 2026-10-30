import 'package:nard_core/nard_core.dart';

import '../clans/clan_models.dart';

int _int(Object? v, [int fallback = 0]) => v is num ? v.toInt() : fallback;

DateTime? _date(Object? v) => v is String ? DateTime.tryParse(v) : null;

/// The API's `publicCard` of another player.
class PublicUser {
  const PublicUser({
    required this.id,
    required this.name,
    this.country,
    this.avatar,
    this.level = 1,
    this.title,
    this.online = false,
    this.ratings = const {},
    this.clan,
  });

  final String id;
  final String name;
  final String? country;
  final String? avatar;
  final int level;
  final String? title;

  /// Seen by the API within the last 2 minutes.
  final bool online;

  /// variant name → rating.
  final Map<String, int> ratings;
  final ClanBadge? clan;

  int? ratingOf(Variant variant) => ratings[variant.name];

  /// The best rating over both variants (clan rating rules, ADR-036).
  int? get bestRating =>
      ratings.isEmpty ? null : ratings.values.reduce((a, b) => a > b ? a : b);

  static PublicUser fromJson(Map<String, Object?> j) {
    final ratings = j['ratings'];
    final clan = j['clan'];
    return PublicUser(
      id: '${j['id']}',
      name: j['name'] as String? ?? '',
      country: j['country'] as String?,
      avatar: j['avatar'] as String?,
      level: _int(j['level'], 1),
      title: j['title'] as String?,
      online: j['online'] == true,
      ratings:
          ratings is Map
              ? {
                for (final e in ratings.entries)
                  if (e.value is num) '${e.key}': (e.value as num).toInt(),
              }
              : const {},
      clan: clan is Map<String, Object?> ? ClanBadge.fromJson(clan) : null,
    );
  }
}

/// A friendship or pending request (`requestId` accepts / dismisses it).
class FriendEntry {
  const FriendEntry({required this.requestId, required this.user});

  final int requestId;
  final PublicUser user;

  static FriendEntry fromJson(Map<String, Object?> j) => FriendEntry(
    requestId: _int(j['requestId']),
    user: PublicUser.fromJson(j['user']! as Map<String, Object?>),
  );
}

/// An incoming friend challenge: a private room waiting for me.
class Challenge {
  const Challenge({
    required this.id,
    required this.from,
    required this.code,
    required this.variant,
    required this.matchLength,
    this.expiresAt,
  });

  final int id;
  final PublicUser from;
  final String code;
  final Variant variant;
  final int matchLength;
  final DateTime? expiresAt;

  static Challenge fromJson(Map<String, Object?> j) => Challenge(
    id: _int(j['id']),
    from: PublicUser.fromJson(j['from']! as Map<String, Object?>),
    code: j['code'] as String? ?? '',
    variant:
        j['variant'] == Variant.longNard.name
            ? Variant.longNard
            : Variant.shortNard,
    matchLength: _int(j['matchLength'], 1),
    expiresAt: _date(j['expiresAt']),
  );
}

/// `GET /friends`.
class FriendsOverview {
  const FriendsOverview({
    this.friends = const [],
    this.incoming = const [],
    this.outgoing = const [],
    this.friendCode = '',
    this.challenges = const [],
  });

  final List<FriendEntry> friends;
  final List<FriendEntry> incoming;
  final List<FriendEntry> outgoing;
  final String friendCode;
  final List<Challenge> challenges;

  bool isFriend(String userId) => friends.any((f) => f.user.id == userId);

  bool isRequested(String userId) => outgoing.any((f) => f.user.id == userId);

  static FriendsOverview fromJson(Map<String, Object?> j) {
    List<FriendEntry> list(String key) => [
      for (final e in (j[key] as List?) ?? const [])
        if (e is Map<String, Object?>) FriendEntry.fromJson(e),
    ];
    return FriendsOverview(
      friends: list('friends'),
      incoming: list('incoming'),
      outgoing: list('outgoing'),
      friendCode: j['friendCode'] as String? ?? '',
      challenges: [
        for (final e in (j['challenges'] as List?) ?? const [])
          if (e is Map<String, Object?>) Challenge.fromJson(e),
      ],
    );
  }
}

/// `POST /friends/requests` outcome.
enum FriendRequestStatus { requested, accepted }

/// Report reasons (`config/social.php`), in the 14.2 order.
enum ReportReason { abuse, name, cheating, stalling, leaving, other }

/// Presence shown on 6.1 / 5.5: in a running game (WS `presence`), seen
/// by the API recently, or offline.
enum Presence { inGame, online, offline }

Presence presenceOf(PublicUser user, Map<String, String> matches) =>
    matches.containsKey(user.id)
        ? Presence.inGame
        : user.online
        ? Presence.online
        : Presence.offline;

/// 6.1 order: available (online or in game) first, then offline; by name
/// inside each group.
List<PublicUser> sortByPresence(
  Iterable<PublicUser> users,
  Map<String, String> matches,
) {
  int group(PublicUser u) => presenceOf(u, matches) == Presence.offline ? 1 : 0;
  return users.toList()..sort((a, b) {
    final g = group(a) - group(b);
    if (g != 0) return g;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
}
