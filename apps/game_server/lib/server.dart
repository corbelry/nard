import 'dart:convert';

import 'package:nard_protocol/nard_protocol.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'src/hub.dart';
import 'src/log.dart';
import 'src/metrics.dart';
import 'src/signature.dart';

export 'src/error_reporter.dart';
export 'src/http_result_sink.dart';
export 'src/hub.dart';
export 'src/log.dart';
export 'src/metrics.dart';
export 'src/signature.dart';
export 'src/ticket.dart';

/// HTTP + WebSocket handler: `/healthz` (liveness), `/readyz` (readiness:
/// [ready] returns true once the server listens and false while it drains),
/// `/metrics` (Prometheus, ADR-043), `/ws` (docs/PROTOCOL.md) and the API's
/// signed `POST /internal/tournament-matches`. Requests are logged as JSON
/// lines through the hub's logger.
Handler buildHandler(Hub hub, {bool Function()? ready}) {
  final router =
      Router()
        ..get('/healthz', (Request _) => Response.ok('ok'))
        ..get(
          '/readyz',
          (Request _) =>
              (ready?.call() ?? true)
                  ? Response.ok('ready')
                  : Response(503, body: 'not ready'),
        )
        ..get(
          '/metrics',
          (Request _) => Response.ok(
            hub.metrics.render(),
            headers: {'Content-Type': Metrics.contentType},
          ),
        )
        ..get(
          '/ws',
          webSocketHandler((WebSocketChannel ch, String? _) => hub.attach(ch)),
        )
        ..post(
          '/internal/tournament-matches',
          (Request req) => _assignTournamentMatch(hub, req),
        );
  return const Pipeline()
      .addMiddleware(jsonRequestLogger(hub.log, errors: hub.errors))
      .addHandler(router.call);
}

Response _json(int status, Map<String, Object?> body) => Response(
  status,
  body: jsonEncode(body),
  headers: {'Content-Type': 'application/json'},
);

Future<Response> _assignTournamentMatch(Hub hub, Request req) async {
  final body = await req.readAsString();
  final signature = req.headers['x-nard-signature'] ?? '';
  if (!Signature.verify(body, signature, hub.ticketSecret)) {
    return _json(401, {'code': 'bad_signature'});
  }
  final TournamentMatchPayload match;
  try {
    final json = jsonDecode(body);
    if (json is! Map<String, Object?>) {
      throw const FormatException('Object expected');
    }
    match = TournamentMatchPayload.fromJson(json);
  } on FormatException catch (e) {
    return _json(400, {'code': 'bad_request', 'message': e.message});
  }
  final created = hub.assignTournamentMatch(match);
  return _json(created ? 201 : 200, {
    'matchId': match.matchId,
    'status': created ? 'assigned' : 'known',
  });
}
