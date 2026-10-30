import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nard_protocol/nard_protocol.dart';

import 'error_reporter.dart';
import 'hub.dart';
import 'log.dart';
import 'metrics.dart';
import 'signature.dart';

/// Posts finished matches (and tournament no-shows) to the API, signed with
/// the shared secret (`X-Nard-Signature: hex(HMAC-SHA256(secret, body))`).
/// Retries with backoff; the API stores reports idempotently by match id.
/// Outcomes are counted in `nard_results_{reported,failed}_total` (ADR-043).
class HttpResultSink implements ResultSink {
  HttpResultSink({
    required this.apiUrl,
    required this.secret,
    http.Client? client,
    this.attempts = 5,
    this.backoff = const Duration(seconds: 2),
    Logger? log,
    Metrics? metrics,
    this.errors = const NoopErrorReporter(),
  }) : _client = client ?? http.Client(),
       _log = log ?? Logger() {
    final m = metrics ?? Metrics();
    _reported = m.counter(
      'nard_results_reported_total',
      'Results and no-shows accepted by the API, by kind.',
    );
    _failed = m.counter(
      'nard_results_failed_total',
      'Results the API rejected (4xx) or that were lost after all retries.',
    );
    _retries = m.counter(
      'nard_results_retries_total',
      'Result posts retried after a network error or 5xx/429.',
    );
  }

  final Uri apiUrl;
  final String secret;
  final int attempts;
  final Duration backoff;
  final ErrorReporter errors;
  final http.Client _client;
  final Logger _log;
  late final Counter _reported;
  late final Counter _failed;
  late final Counter _retries;

  static String signature(String body, String secret) =>
      Signature.sign(body, secret);

  @override
  Future<void> report(MatchResult result) => _post(
    '/api/v1/internal/match-results',
    result.toJson(),
    'result',
    result.matchId,
  );

  @override
  Future<void> reportNoShow(TournamentNoShow noShow) => _post(
    '/api/v1/internal/tournament-no-shows',
    noShow.toJson(),
    'no_show',
    noShow.matchId,
  );

  Future<void> _post(
    String path,
    Map<String, Object?> json,
    String kind,
    String matchId,
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
        if (res.statusCode >= 200 && res.statusCode < 300) {
          _reported.inc({'kind': kind});
          return;
        }
        // 4xx other than rate limiting will not get better on retry.
        if (res.statusCode >= 400 &&
            res.statusCode < 500 &&
            res.statusCode != 429) {
          _failed.inc({'kind': kind, 'reason': 'rejected'});
          _log.error('result rejected', {
            'kind': kind,
            'matchId': matchId,
            'status': res.statusCode,
            'body': res.body,
          });
          return;
        }
        _log.warn('result post failed', {
          'kind': kind,
          'matchId': matchId,
          'attempt': i,
          'status': res.statusCode,
        });
      } on Object catch (e) {
        _log.warn('result post failed', {
          'kind': kind,
          'matchId': matchId,
          'attempt': i,
          'error': '$e',
        });
      }
      if (i < attempts) {
        _retries.inc({'kind': kind});
        await Future<void>.delayed(backoff * i);
      }
    }
    _failed.inc({'kind': kind, 'reason': 'lost'});
    _log.error('result lost', {
      'kind': kind,
      'matchId': matchId,
      'attempts': attempts,
    });
    errors.capture(
      StateError('$kind $matchId lost after $attempts attempts'),
      StackTrace.current,
      context: {'matchId': matchId, 'kind': kind},
    );
  }
}
