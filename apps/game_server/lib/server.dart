import 'dart:convert';
import 'dart:io';

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
export 'src/limits.dart';
export 'src/log.dart';
export 'src/metrics.dart';
export 'src/signature.dart';
export 'src/ticket.dart';

/// HTTP + WebSocket handler: `/healthz` (liveness), `/readyz` (readiness:
/// [ready] returns true once the server listens and false while it drains),
/// `/metrics` (Prometheus, ADR-043), `/ws` (docs/PROTOCOL.md; per-address
/// cap and pings from [Hub.limits], ADR-045) and the API's signed
/// `POST /internal/tournament-matches`, `POST /internal/moderation`,
/// `POST /internal/notify` and `POST /internal/tournament-updated`
/// (ADR-049).
/// Requests are logged as JSON lines through the hub's logger.
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
        ..get('/ws', (Request req) {
          final remote = clientAddress(req, trustProxy: hub.limits.trustProxy);
          if (!hub.admits(remote)) {
            return Response(429, body: 'too many connections');
          }
          return webSocketHandler(
            (WebSocketChannel ch, String? _) => hub.attach(ch, remote: remote),
            pingInterval: hub.limits.pingInterval,
          )(req);
        })
        ..post(
          '/internal/tournament-matches',
          (Request req) => _assignTournamentMatch(hub, req),
        )
        ..post('/internal/moderation', (Request req) => _moderate(hub, req))
        ..post(
          '/internal/notify',
          (Request req) => _signed(
            req,
            hub,
            NotifyPayload.fromJson,
            (push) => {'delivered': hub.notify(push)},
          ),
        )
        ..post(
          '/internal/tournament-updated',
          (Request req) => _signed(
            req,
            hub,
            TournamentUpdatedPush.fromJson,
            (push) => {'delivered': hub.tournamentUpdated(push)},
          ),
        );
  return const Pipeline()
      .addMiddleware(jsonRequestLogger(hub.log, errors: hub.errors))
      .addHandler(router.call);
}

/// The client's address: the TCP peer, or with [trustProxy] (behind the
/// ingress) the rightmost `X-Forwarded-For` entry, which the proxy itself
/// appended; entries left of it are client-controlled (ADR-045).
String clientAddress(Request req, {required bool trustProxy}) {
  if (trustProxy) {
    final hops = (req.headers['x-forwarded-for'] ?? '')
        .split(',')
        .map((h) => h.trim())
        .where((h) => h.isNotEmpty);
    if (hops.isNotEmpty) return hops.last;
  }
  final info = req.context['shelf.io.connection_info'];
  return info is HttpConnectionInfo ? info.remoteAddress.address : '';
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

Future<Response> _moderate(Hub hub, Request req) async {
  final body = await req.readAsString();
  final signature = req.headers['x-nard-signature'] ?? '';
  if (!Signature.verify(body, signature, hub.ticketSecret)) {
    return _json(401, {'code': 'bad_signature'});
  }
  final ModerationPayload push;
  try {
    final json = jsonDecode(body);
    if (json is! Map<String, Object?>) {
      throw const FormatException('Object expected');
    }
    push = ModerationPayload.fromJson(json);
  } on FormatException catch (e) {
    return _json(400, {'code': 'bad_request', 'message': e.message});
  }
  return _json(200, {'userId': push.userId, 'connected': hub.moderate(push)});
}

/// A signed API push: 401 on a bad signature, 400 when [parse] refuses the
/// body, else 200 with what [apply] returns.
Future<Response> _signed<T>(
  Request req,
  Hub hub,
  T Function(Map<String, Object?>) parse,
  Map<String, Object?> Function(T) apply,
) async {
  final body = await req.readAsString();
  final signature = req.headers['x-nard-signature'] ?? '';
  if (!Signature.verify(body, signature, hub.ticketSecret)) {
    return _json(401, {'code': 'bad_signature'});
  }
  final T push;
  try {
    final json = jsonDecode(body);
    if (json is! Map<String, Object?>) {
      throw const FormatException('Object expected');
    }
    push = parse(json);
  } on FormatException catch (e) {
    return _json(400, {'code': 'bad_request', 'message': e.message});
  }
  return _json(200, apply(push));
}
