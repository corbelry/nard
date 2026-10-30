import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

import 'error_reporter.dart';

enum LogLevel {
  debug,
  info,
  warn,
  error;

  static LogLevel parse(String? name) => switch (name?.toLowerCase()) {
    'debug' => debug,
    'warn' || 'warning' => warn,
    'error' => error,
    _ => info,
  };
}

/// Structured JSON logs: one line per event with `level`, `ts` (UTC ISO
/// 8601), `msg` and the event's fields at the top level (ADR-043). Fields
/// never override the three reserved keys.
class Logger {
  Logger({
    this.level = LogLevel.info,
    void Function(String line)? write,
    DateTime Function()? clock,
  }) : _write = write ?? stdout.writeln,
       _clock = clock ?? DateTime.now;

  /// Discards everything (tests).
  Logger.silent() : this(level: LogLevel.error, write: (_) {});

  final LogLevel level;
  final void Function(String) _write;
  final DateTime Function() _clock;

  bool enabled(LogLevel l) => l.index >= level.index;

  void log(LogLevel l, String msg, [Map<String, Object?> fields = const {}]) {
    if (!enabled(l)) return;
    final line = <String, Object?>{
      'level': l.name,
      'ts': _clock().toUtc().toIso8601String(),
      'msg': msg,
    };
    fields.forEach((k, v) => line.putIfAbsent(k, () => v));
    _write(jsonEncode(line, toEncodable: (o) => o.toString()));
  }

  void debug(String msg, [Map<String, Object?> fields = const {}]) =>
      log(LogLevel.debug, msg, fields);
  void info(String msg, [Map<String, Object?> fields = const {}]) =>
      log(LogLevel.info, msg, fields);
  void warn(String msg, [Map<String, Object?> fields = const {}]) =>
      log(LogLevel.warn, msg, fields);
  void error(String msg, [Map<String, Object?> fields = const {}]) =>
      log(LogLevel.error, msg, fields);
}

/// Probe and scrape paths, logged at debug level only.
const _quietPaths = {'healthz', 'readyz', 'metrics'};

/// Replaces shelf's `logRequests`: one JSON line per request (method, path,
/// status, duration). Unhandled handler errors become a 500, a log line and
/// an [ErrorReporter] event.
Middleware jsonRequestLogger(Logger log, {ErrorReporter? errors}) =>
    (inner) => (request) async {
      final watch = Stopwatch()..start();
      final path = '/${request.url.path}';
      Map<String, Object?> fields(int status) => {
        'method': request.method,
        'path': path,
        'status': status,
        'durationMs': watch.elapsedMicroseconds / 1000,
      };
      try {
        final response = await inner(request);
        log.log(
          _quietPaths.contains(request.url.path)
              ? LogLevel.debug
              : LogLevel.info,
          'http request',
          fields(response.statusCode),
        );
        return response;
      } on HijackException {
        // WebSocket upgrade: the connection now belongs to the hub.
        log.debug('websocket upgrade', fields(101));
        rethrow;
      } on Object catch (e, stack) {
        log.error('http request failed', {...fields(500), 'error': '$e'});
        errors?.capture(e, stack, context: {'path': path});
        return Response.internalServerError(body: 'internal error');
      }
    };
