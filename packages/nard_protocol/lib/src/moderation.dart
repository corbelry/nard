import 'messages.dart';
import 'read.dart';

/// API → game server, `POST /internal/moderation` (signed like tournament
/// pairings, `X-Nard-Signature`; ADR-045): a player's current moderation
/// state, pushed whenever an admin or the fair-play scan changes it. The
/// game server applies it to the live session: [banned] closes the socket
/// (the match continues as a disconnect), [muted] drops emotes and
/// [queueCooldownUntil] (epoch seconds, null = none) refuses `queue.join`.
/// It is the whole state, not a delta, so a repeated push is harmless.
/// Mirrored by `schema/moderation.schema.json`.
class ModerationPayload {
  const ModerationPayload({
    required this.userId,
    required this.banned,
    required this.muted,
    this.queueCooldownUntil,
  });

  final String userId;
  final bool banned;
  final bool muted;

  /// Seconds since epoch; null when there is no cooldown.
  final int? queueCooldownUntil;

  Map<String, Object?> toJson() => {
    'userId': userId,
    'banned': banned,
    'muted': muted,
    'queueCooldownUntil': queueCooldownUntil,
  };

  static ModerationPayload fromJson(Map<String, Object?> j) =>
      ModerationPayload(
        userId: j.str('userId', max: 64),
        banned: j.req<bool>('banned'),
        muted: j.req<bool>('muted'),
        queueCooldownUntil: j.opt<int>('queueCooldownUntil'),
      );
}
