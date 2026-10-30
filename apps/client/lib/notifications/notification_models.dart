import '../tournaments/tournament_models.dart' show UserLite;

/// Server notification types (docs/api/notifications.md).
enum NotificationType {
  friendRequest('friend_request'),
  friendAccepted('friend_accepted'),
  challenge('challenge'),
  clanInvite('clan_invite'),
  clanJoined('clan_joined'),
  clanWar('clan_war'),
  tournamentReminder('tournament_reminder'),
  tournamentStarted('tournament_started'),
  tournamentRound('tournament_round'),
  tournamentEliminated('tournament_eliminated'),
  tournamentWon('tournament_won'),
  tournamentFinished('tournament_finished'),
  seasonEnd('season_end'),
  levelUp('level_up'),
  moderationWarning('moderation_warning'),
  unknown('');

  const NotificationType(this.api);

  final String api;

  static NotificationType parse(String? api) => values.firstWhere(
    (t) => t.api == api && t != unknown,
    orElse: () => unknown,
  );
}

/// The 16.2 filter chips.
enum InboxTab { all, game, social, tournament }

/// One inbox row (16.2).
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.createdAt,
    this.data = const {},
    this.from,
    this.read = false,
  });

  final int id;
  final NotificationType type;
  final Map<String, Object?> data;
  final UserLite? from;
  final bool read;
  final DateTime createdAt;

  String text(String key) => '${data[key] ?? ''}';

  int number(String key) => switch (data[key]) {
    final num n => n.toInt(),
    final String s => int.tryParse(s) ?? 0,
    _ => 0,
  };

  /// A per-locale name map (tournament names).
  Map<String, String> names(String key) => switch (data[key]) {
    final Map<String, Object?> m => {
      for (final e in m.entries)
        if (e.value is String) e.key: e.value! as String,
    },
    _ => const {},
  };

  DateTime? time(String key) => DateTime.tryParse(text(key))?.toLocal();

  InboxTab get tab => switch (type) {
    NotificationType.challenge => InboxTab.game,
    NotificationType.friendRequest ||
    NotificationType.friendAccepted ||
    NotificationType.clanInvite ||
    NotificationType.clanJoined ||
    NotificationType.clanWar => InboxTab.social,
    NotificationType.tournamentReminder ||
    NotificationType.tournamentStarted ||
    NotificationType.tournamentRound ||
    NotificationType.tournamentEliminated ||
    NotificationType.tournamentWon ||
    NotificationType.tournamentFinished => InboxTab.tournament,
    _ => InboxTab.all,
  };

  AppNotification copyWith({bool? read}) => AppNotification(
    id: id,
    type: type,
    data: data,
    from: from,
    read: read ?? this.read,
    createdAt: createdAt,
  );

  static AppNotification fromJson(Map<String, Object?> j) => AppNotification(
    id: (j['id']! as num).toInt(),
    type: NotificationType.parse(j['type'] as String?),
    data:
        j['data'] is Map<String, Object?>
            ? j['data']! as Map<String, Object?>
            : const {},
    from: UserLite.maybe(j['from']),
    read: j['read'] == true,
    createdAt:
        DateTime.tryParse(j['createdAt'] as String? ?? '')?.toLocal() ??
        DateTime.now(),
  );
}

/// `GET /notifications`: newest first.
class InboxPage {
  const InboxPage({required this.items, required this.unread});

  final List<AppNotification> items;
  final int unread;

  static InboxPage fromJson(Map<String, Object?> j) => InboxPage(
    items: [
      for (final n in (j['notifications'] as List?) ?? const [])
        if (n is Map<String, Object?>) AppNotification.fromJson(n),
    ],
    unread: (j['unread'] as num?)?.toInt() ?? 0,
  );
}

/// 16.1 categories, in screen order (server keys).
enum NotificationCategory {
  gameInvites('game_invites'),
  tournamentStart('tournament_start'),
  tournamentRound('tournament_round'),
  friendRequests('friend_requests'),
  clan('clan'),
  clanWar('clan_war'),
  rewards('rewards');

  const NotificationCategory(this.api);

  final String api;
}

/// `GET /me/notification-settings` (16.1).
class NotificationSettings {
  const NotificationSettings({
    this.push = true,
    this.quietEnabled = true,
    this.quietStart = '23:00',
    this.quietEnd = '08:00',
    this.categories = const {},
    this.pushAvailable = false,
  });

  final bool push;
  final bool quietEnabled;
  final String quietStart;
  final String quietEnd;
  final Map<NotificationCategory, bool> categories;

  /// The server can send pushes (FCM configured).
  final bool pushAvailable;

  bool isOn(NotificationCategory c) => categories[c] ?? true;

  NotificationSettings copyWith({
    bool? push,
    bool? quietEnabled,
    String? quietStart,
    String? quietEnd,
    Map<NotificationCategory, bool>? categories,
  }) => NotificationSettings(
    push: push ?? this.push,
    quietEnabled: quietEnabled ?? this.quietEnabled,
    quietStart: quietStart ?? this.quietStart,
    quietEnd: quietEnd ?? this.quietEnd,
    categories: categories ?? this.categories,
    pushAvailable: pushAvailable,
  );

  static NotificationSettings fromJson(Map<String, Object?> j) {
    final quiet =
        j['quietHours'] is Map<String, Object?>
            ? j['quietHours']! as Map<String, Object?>
            : const <String, Object?>{};
    final cats =
        j['categories'] is Map<String, Object?>
            ? j['categories']! as Map<String, Object?>
            : const <String, Object?>{};
    return NotificationSettings(
      push: j['push'] != false,
      quietEnabled: quiet['enabled'] != false,
      quietStart: quiet['start'] as String? ?? '23:00',
      quietEnd: quiet['end'] as String? ?? '08:00',
      categories: {
        for (final c in NotificationCategory.values) c: cats[c.api] != false,
      },
      pushAvailable: j['pushAvailable'] == true,
    );
  }
}
