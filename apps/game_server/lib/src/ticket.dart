import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:nard_core/nard_core.dart';

/// A short-lived game-server ticket issued by the API (docs/PROTOCOL.md):
/// `base64url(json) "." base64url(HMAC-SHA256(secret, base64url(json)))`,
/// unpadded. The JSON carries the user and their ratings.
class Ticket {
  const Ticket({
    required this.userId,
    required this.name,
    required this.expiresAt,
    this.country,
    this.ratings = const {},
    this.cosmetics = const {},
  });

  final String userId;
  final String name;
  final String? country;

  /// Per-variant rating used for ranked matchmaking.
  final Map<Variant, int> ratings;

  /// Equipped items, category → item id.
  final Map<String, String> cosmetics;

  /// Seconds since epoch.
  final int expiresAt;

  int rating(Variant v) => ratings[v] ?? 1500;

  Map<String, Object?> toJson() => {
    'sub': userId,
    'name': name,
    if (country != null) 'country': country,
    'ratings': {for (final e in ratings.entries) e.key.name: e.value},
    if (cosmetics.isNotEmpty) 'cosmetics': cosmetics,
    'exp': expiresAt,
  };

  static String _b64(List<int> bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');

  static List<int> _unb64(String s) =>
      base64Url.decode(s.padRight((s.length + 3) ~/ 4 * 4, '='));

  /// Signs [ticket] with [secret] (used by tests; the API signs in PHP).
  static String sign(Ticket ticket, String secret) {
    final body = _b64(utf8.encode(jsonEncode(ticket.toJson())));
    final mac = Hmac(sha256, utf8.encode(secret)).convert(utf8.encode(body));
    return '$body.${_b64(mac.bytes)}';
  }

  /// Returns the ticket if the signature is valid and it has not expired.
  static Ticket? verify(
    String token,
    String secret, {
    required int nowSeconds,
  }) {
    final parts = token.split('.');
    if (parts.length != 2) return null;
    final expected = _b64(
      Hmac(sha256, utf8.encode(secret)).convert(utf8.encode(parts[0])).bytes,
    );
    if (!_constantTimeEquals(expected, parts[1])) return null;
    try {
      final json = jsonDecode(utf8.decode(_unb64(parts[0])));
      if (json is! Map<String, Object?>) return null;
      final exp = json['exp'];
      final sub = json['sub'];
      final name = json['name'];
      if (exp is! int || sub is! String || name is! String) return null;
      if (exp < nowSeconds) return null;
      final ratings = <Variant, int>{};
      final raw = json['ratings'];
      if (raw is Map<String, Object?>) {
        for (final v in Variant.values) {
          final r = raw[v.name];
          if (r is int) ratings[v] = r;
        }
      }
      final country = json['country'];
      final rawCosmetics = json['cosmetics'];
      final cosmetics = <String, String>{
        if (rawCosmetics is Map<String, Object?>)
          for (final e in rawCosmetics.entries)
            if (e.value is String) e.key: e.value! as String,
      };
      return Ticket(
        userId: sub,
        name: name,
        country: country is String ? country : null,
        ratings: ratings,
        cosmetics: cosmetics,
        expiresAt: exp,
      );
    } on FormatException {
      return null;
    }
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
