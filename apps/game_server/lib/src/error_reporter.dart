import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

/// Where unexpected errors go besides the log (ADR-043). The default does
/// nothing; `SENTRY_DSN` switches on [SentryReporter].
abstract interface class ErrorReporter {
  void capture(
    Object error,
    StackTrace? stack, {
    Map<String, Object?> context = const {},
  });
}

class NoopErrorReporter implements ErrorReporter {
  const NoopErrorReporter();

  @override
  void capture(
    Object error,
    StackTrace? stack, {
    Map<String, Object?> context = const {},
  }) {}
}

/// Sends errors to a Sentry-compatible endpoint (the DSN's `store` API) with
/// the existing `http` client — no SDK dependency. Fire-and-forget, at most
/// [perMinute] events per minute so an error loop cannot flood the project.
class SentryReporter implements ErrorReporter {
  SentryReporter._(
    this.endpoint,
    this.publicKey, {
    required this.environment,
    required this.release,
    required this.perMinute,
    required http.Client client,
    required int Function() now,
    required void Function(String) onFailure,
  }) : _client = client,
       _now = now,
       _onFailure = onFailure;

  /// Parses `https://<key>@<host>[/<path>]/<project>`; null when invalid.
  static SentryReporter? fromDsn(
    String dsn, {
    String environment = 'production',
    String release = 'game_server@0.1.0',
    int perMinute = 30,
    http.Client? client,
    int Function()? now,
    void Function(String message)? onFailure,
  }) {
    final uri = Uri.tryParse(dsn.trim());
    if (uri == null ||
        !uri.hasScheme ||
        uri.host.isEmpty ||
        uri.userInfo.isEmpty ||
        uri.pathSegments.isEmpty) {
      return null;
    }
    final project = uri.pathSegments.last;
    final prefix = uri.pathSegments.sublist(0, uri.pathSegments.length - 1);
    final endpoint = uri.replace(
      userInfo: '',
      pathSegments: [...prefix, 'api', project, 'store', ''],
    );
    return SentryReporter._(
      endpoint,
      uri.userInfo.split(':').first,
      environment: environment,
      release: release,
      perMinute: perMinute,
      client: client ?? http.Client(),
      now: now ?? (() => DateTime.now().millisecondsSinceEpoch),
      onFailure: onFailure ?? (_) {},
    );
  }

  final Uri endpoint;
  final String publicKey;
  final String environment;
  final String release;
  final int perMinute;
  final http.Client _client;
  final int Function() _now;
  final void Function(String) _onFailure;
  final _random = Random.secure();
  int _windowStart = 0;
  int _sent = 0;

  @override
  void capture(
    Object error,
    StackTrace? stack, {
    Map<String, Object?> context = const {},
  }) {
    final now = _now();
    if (now - _windowStart >= 60000) {
      _windowStart = now;
      _sent = 0;
    }
    if (_sent >= perMinute) return;
    _sent++;
    final event = <String, Object?>{
      'event_id':
          List.generate(
            16,
            (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
          ).join(),
      'timestamp': now / 1000,
      'platform': 'other',
      'level': 'error',
      'logger': 'game_server',
      'environment': environment,
      'release': release,
      'exception': {
        'values': [
          {'type': error.runtimeType.toString(), 'value': '$error'},
        ],
      },
      'extra': {...context, if (stack != null) 'stack': '$stack'},
    };
    unawaited(_send(jsonEncode(event, toEncodable: (o) => o.toString())));
  }

  Future<void> _send(String body) async {
    try {
      final res = await _client.post(
        endpoint,
        headers: {
          'Content-Type': 'application/json',
          'X-Sentry-Auth':
              'Sentry sentry_version=7, '
              'sentry_client=nard-game-server/0.1.0, '
              'sentry_key=$publicKey',
        },
        body: body,
      );
      if (res.statusCode >= 300) {
        _onFailure('sentry rejected event: ${res.statusCode}');
      }
    } on Object catch (e) {
      _onFailure('sentry unreachable: $e');
    }
  }
}
