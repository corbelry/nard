import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nard_protocol/nard_protocol.dart';

import 'hub.dart';
import 'signature.dart';

/// Posts finished matches (and tournament no-shows) to the API, signed with
/// the shared secret (`X-Nard-Signature: hex(HMAC-SHA256(secret, body))`).
/// Retries with backoff; the API stores reports idempotently by match id.
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
      Signature.sign(body, secret);

  @override
  Future<void> report(MatchResult result) => _post(
    '/api/v1/internal/match-results',
    result.toJson(),
    'match ${result.matchId}',
  );

  @override
  Future<void> reportNoShow(TournamentNoShow noShow) => _post(
    '/api/v1/internal/tournament-no-shows',
    noShow.toJson(),
    'no-show ${noShow.matchId}',
  );

  Future<void> _post(
    String path,
    Map<String, Object?> json,
    String what,
  ) async {
    final body = jsonEncode(json);
    final url = apiUrl.resolve(path);
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
        if (res.statusCode >= 200 && res.statusCode < 300) return;
        // 4xx other than rate limiting will not get better on retry.
        if (res.statusCode >= 400 &&
            res.statusCode < 500 &&
            res.statusCode != 429) {
          _log('$what rejected: ${res.statusCode} ${res.body}');
          return;
        }
      } on Object catch (e) {
        _log('$what report failed ($i/$attempts): $e');
      }
      if (i < attempts) await Future<void>.delayed(backoff * i);
    }
    _log('$what result lost after $attempts attempts');
  }
}
