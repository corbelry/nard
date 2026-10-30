import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Internal HTTP between the API and the game server is signed with the
/// shared ticket secret: `X-Nard-Signature: hex(HMAC-SHA256(secret, body))`.
abstract final class Signature {
  static String sign(String body, String secret) =>
      Hmac(sha256, utf8.encode(secret)).convert(utf8.encode(body)).toString();

  /// Constant-time check of [signature] against [body].
  static bool verify(String body, String signature, String secret) {
    if (secret.length < 32) return false;
    final expected = sign(body, secret);
    if (expected.length != signature.length) return false;
    var diff = 0;
    for (var i = 0; i < expected.length; i++) {
      diff |= expected.codeUnitAt(i) ^ signature.codeUnitAt(i);
    }
    return diff == 0;
  }
}
