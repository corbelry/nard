import 'dart:async';
import 'dart:io';

import 'package:game_server/server.dart';
import 'package:shelf/shelf_io.dart' as io;

/// Environment: `PORT`, `GAME_TICKET_SECRET` (required), `API_URL`,
/// `LOG_LEVEL` (debug|info|warn|error), `SENTRY_DSN` / `SENTRY_ENVIRONMENT`
/// (optional error reporting, ADR-043), `SHUTDOWN_GRACE_SECONDS`.
Future<void> main() async {
  final env = Platform.environment;
  final log = Logger(level: LogLevel.parse(env['LOG_LEVEL']));
  final dsn = env['SENTRY_DSN'] ?? '';
  final ErrorReporter errors =
      dsn.isEmpty
          ? const NoopErrorReporter()
          : SentryReporter.fromDsn(
                dsn,
                environment: env['SENTRY_ENVIRONMENT'] ?? 'production',
                onFailure:
                    (m) => log.warn('error reporter failed', {'error': m}),
              ) ??
              const NoopErrorReporter();
  if (dsn.isNotEmpty && errors is NoopErrorReporter) {
    log.warn('SENTRY_DSN is not a valid DSN; error reporting is off');
  }
  await runZonedGuarded(() => _serve(env, log, errors), (error, stack) {
    log.error('uncaught error', {'error': '$error'});
    errors.capture(error, stack, context: {'uncaught': true});
  });
}

Future<void> _serve(
  Map<String, String> env,
  Logger log,
  ErrorReporter errors,
) async {
  final port = int.tryParse(env['PORT'] ?? '') ?? 8080;
  final secret = env['GAME_TICKET_SECRET'];
  if (secret == null || secret.length < 32) {
    log.error('GAME_TICKET_SECRET (>= 32 chars) is required');
    exitCode = 64;
    return;
  }
  final metrics = Metrics()..addProcessMetrics();
  final api = env['API_URL'];
  final ResultSink results =
      api == null
          ? MemoryResultSink()
          : HttpResultSink(
            apiUrl: Uri.parse(api),
            secret: secret,
            log: log,
            metrics: metrics,
            errors: errors,
          );
  final hub = Hub(
    ticketSecret: secret,
    results: results,
    metrics: metrics,
    log: log,
    errors: errors,
  );
  var ready = false;
  final server = await io.serve(
    buildHandler(hub, ready: () => ready),
    InternetAddress.anyIPv4,
    port,
  );
  ready = true;
  log.info('game_server listening', {'port': server.port});

  // Kubernetes sends SIGTERM: fail readiness first so no new connections
  // are routed here, then close after the grace period.
  final grace = Duration(
    seconds: int.tryParse(env['SHUTDOWN_GRACE_SECONDS'] ?? '') ?? 5,
  );
  var stopping = false;
  Future<void> stop(ProcessSignal signal) async {
    if (stopping) return;
    stopping = true;
    ready = false;
    log.info('shutting down', {
      'signal': '$signal',
      'activeRooms': hub.activeMatches,
      'graceSeconds': grace.inSeconds,
    });
    await Future<void>.delayed(grace);
    hub.dispose();
    await server.close(force: true);
    exit(0);
  }

  ProcessSignal.sigterm.watch().listen(stop);
  ProcessSignal.sigint.watch().listen(stop);
}
