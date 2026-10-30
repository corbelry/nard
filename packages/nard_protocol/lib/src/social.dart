import 'package:nard_core/nard_core.dart';

import 'messages.dart';

/// Emotes and quick phrases (2.7). Ids only: no free text in games
/// (spec §8.5). The client maps ids to localized strings and art.
abstract final class Emotes {
  static const emotes = {
    'smile',
    'laugh',
    'wow',
    'think',
    'sad',
    'angry',
    'tea',
    'clap',
  };
  static const phrases = {
    'hello',
    'good_luck',
    'well_played',
    'nice_roll',
    'oops',
    'thanks',
    'sorry',
    'good_game',
  };

  static bool isValid(String id) => emotes.contains(id) || phrases.contains(id);
}

/// `chat.emote`: client → server `{id}`; server → players and spectators
/// `{id, from}`.
class EmotePayload {
  const EmotePayload(this.id, {this.from});

  final String id;
  final Side? from;

  Map<String, Object?> toJson() => {
    'id': id,
    if (from != null) 'from': from!.name,
  };

  static EmotePayload fromJson(Map<String, Object?> j) {
    final id = j['id'];
    if (id is! String || !Emotes.isValid(id)) {
      throw const ProtocolException('Unknown emote');
    }
    final from = j['from'];
    return EmotePayload(
      id,
      from: from is String ? Side.values.asNameMap()[from] : null,
    );
  }
}

/// `room.create` (client → server): a private room, always unrated.
class RoomCreatePayload {
  const RoomCreatePayload({required this.variant, required this.matchLength});

  final Variant variant;
  final int matchLength;

  Map<String, Object?> toJson() => {
    'variant': variant.name,
    'matchLength': matchLength,
  };

  static RoomCreatePayload fromJson(Map<String, Object?> j) {
    final q = QueueJoinPayload.fromJson({...j, 'mode': QueueMode.casual.name});
    return RoomCreatePayload(variant: q.variant, matchLength: q.matchLength);
  }
}

/// `room.created` (server → client) and `room.join` (client → server).
class RoomCodePayload {
  const RoomCodePayload(this.code, {this.expiresAt});

  /// Six characters, shared with a friend (6.3).
  final String code;

  /// Ms since epoch (room.created only).
  final int? expiresAt;

  Map<String, Object?> toJson() => {
    'code': code,
    if (expiresAt != null) 'expiresAt': expiresAt,
  };

  static RoomCodePayload fromJson(Map<String, Object?> j) {
    final code = j['code'];
    if (code is! String || !RegExp(r'^[A-Z2-9]{6}$').hasMatch(code)) {
      throw const ProtocolException('Bad room code');
    }
    return RoomCodePayload(code, expiresAt: j['expiresAt'] as int?);
  }
}

/// `presence.query {userIds}` → `presence {players: {userId: matchId?}}`:
/// who of the given users is in a running match (for spectating, 6.4).
class PresencePayload {
  const PresencePayload(this.matches);

  /// userId → matchId for users currently playing.
  final Map<String, String> matches;

  Map<String, Object?> toJson() => {'matches': matches};

  static PresencePayload fromJson(Map<String, Object?> j) => PresencePayload({
    for (final e
        in ((j['matches'] as Map<String, Object?>?) ?? const {}).entries)
      if (e.value is String) e.key: e.value! as String,
  });
}
