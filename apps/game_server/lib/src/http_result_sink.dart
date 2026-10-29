import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:nard_protocol/nard_protocol.dart';

import 'hub.dart';

/// Posts finished matches to the API, signed with the shared secret
/// (`X-Nard-Signature: hex(HMAC-SHA256(secret, body))`). Retries with
/// backoff; the API stores results idempotently by match id.
class HttpResultSink implements ResultSink {
  HttpResultSink({
    required this.apiUrl,
    required this.secret,
    http.Client? client,
    this.attempts = 5,
    this.backoff = const Duration(seconds: 2),
    void Function(String message)? log,
  }) : _client = client ?? http.Client(),
       _log = log ?? print;

  final Uri apiUrl;
  final String secret;
  final int attempts;
  final Duration backoff;
  final http.Client _client;
  final void Function(String) _log;

  static String signature(String body, String secret) =>
      Hmac(sha256, utf8.encode(secret)).convert(utf8.encode(body)).toString();

  @override
  Future<void> report(MatchResult result) async {
    final body = jsonEncode(result.toJson());
    final url = apiUrl.resolve('/api/v1/internal/match-results');
    for (var i = 1; i <= attempts; i++) {
      try {
        final res = await _client.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-Nard-Signature': signature(body, secret),
          },
          body: body,
        );
        if (res.statusCode == 201) return;
        // 4xx other than rate limiting will not get better on retry.
        if (res.statusCode >= 400 &&
            res.statusCode < 500 &&
            res.statusCode != 429) {
          _log(
            'match ${result.matchId} rejected: ${res.statusCode} ${res.body}',
          );
          return;
        }
      } on Object catch (e) {
        _log('match ${result.matchId} report failed ($i/$attempts): $e');
      }
      if (i < attempts) await Future<void>.delayed(backoff * i);
    }
    _log('match ${result.matchId} result lost after $attempts attempts');
  }
}
