import 'messages.dart';
import 'read.dart';

/// One inbox row for one player inside [NotifyPayload]: [notification] is
/// the API's Notification object (docs/api/notifications.md: `{id, type,
/// category, data, from, read, createdAt}`). The game server only checks
/// `id` and `type` and forwards it unchanged as the `notification` message.
class LiveNotification {
  const LiveNotification({required this.userId, required this.notification});

  final String userId;
  final Map<String, Object?> notification;

  Map<String, Object?> toJson() => {
    'userId': userId,
    'notification': notification,
  };

  static LiveNotification fromJson(Map<String, Object?> j) {
    final n = j.obj('notification');
    if (n['id'] is! int) {
      throw const ProtocolException('"notification.id" must be int');
    }
    final type = n['type'];
    if (type is! String || type.isEmpty || type.length > 64) {
      throw const ProtocolException('"notification.type" must be a name');
    }
    return LiveNotification(userId: j.str('userId', max: 64), notification: n);
  }
}

/// API → game server, `POST /internal/notify` (signed like tournament
/// pairings, `X-Nard-Signature`; ADR-049): inbox rows just written, sent
/// to the players' open sockets as `notification`. Best effort: players
/// without a socket read them from the inbox. Mirrored by
/// `schema/notify.schema.json`.
class NotifyPayload {
  const NotifyPayload(this.notifications);

  /// Rows per request (the API sends larger batches in chunks).
  static const maxItems = 500;

  final List<LiveNotification> notifications;

  Map<String, Object?> toJson() => {
    'notifications': [for (final n in notifications) n.toJson()],
  };

  static NotifyPayload fromJson(Map<String, Object?> j) {
    final list = j.req<List<Object?>>('notifications');
    if (list.length > maxItems) {
      throw const ProtocolException('"notifications" has too many items');
    }
    return NotifyPayload([
      for (final n in list)
        if (n is Map<String, Object?>)
          LiveNotification.fromJson(n)
        else
          throw const ProtocolException('"notifications" must hold objects'),
    ]);
  }
}

/// API → game server, `POST /internal/tournament-updated` (signed; ADR-049):
/// the tournament's state changed (entries, a round, a result, the end or
/// a cancellation). The game server sends `tournament.updated` to those of
/// [userIds] (the entrants) that are connected. Mirrored by
/// `schema/tournament_updated.schema.json`.
class TournamentUpdatedPush {
  const TournamentUpdatedPush({
    required this.tournamentId,
    required this.userIds,
  });

  /// Entrants per push (the largest tournament has far fewer).
  static const maxUsers = 1000;

  final String tournamentId;
  final List<String> userIds;

  Map<String, Object?> toJson() => {
    'tournamentId': tournamentId,
    'userIds': userIds,
  };

  static TournamentUpdatedPush fromJson(Map<String, Object?> j) {
    final ids = j.req<List<Object?>>('userIds');
    if (ids.length > maxUsers) {
      throw const ProtocolException('"userIds" has too many items');
    }
    return TournamentUpdatedPush(
      tournamentId: j.str('tournamentId', max: 64),
      userIds: [
        for (final id in ids)
          if (id is String && id.isNotEmpty && id.length <= 64)
            id
          else
            throw const ProtocolException('"userIds" must hold user ids'),
      ],
    );
  }
}

/// Server → client `tournament.updated {tournamentId}` (ADR-049): refetch
/// that tournament (bracket, standings, sit-and-go table, lists). Clients
/// that miss it still poll.
class TournamentUpdatedPayload {
  const TournamentUpdatedPayload(this.tournamentId);

  final String tournamentId;

  Map<String, Object?> toJson() => {'tournamentId': tournamentId};

  static TournamentUpdatedPayload fromJson(Map<String, Object?> j) =>
      TournamentUpdatedPayload(j.str('tournamentId', max: 64));
}
