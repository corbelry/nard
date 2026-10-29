import 'dart:convert';

import 'package:nard_protocol/nard_protocol.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// HTTP + WebSocket handler. Phase 0: health check and ping/pong only; the
/// authoritative game loop arrives in Phase 3.
Handler buildHandler() {
  final router =
      Router()
        ..get('/healthz', (Request _) => Response.ok('ok'))
        ..get('/ws', webSocketHandler(_onConnection));
  return const Pipeline().addMiddleware(logRequests()).addHandler(router.call);
}

void _onConnection(WebSocketChannel channel, String? _) {
  void send(Envelope e) => channel.sink.add(jsonEncode(e.toJson()));

  channel.stream.listen((frame) {
    final now = DateTime.now().millisecondsSinceEpoch;
    try {
      if (frame is! String) throw const FormatException('Text frames only');
      final msg = Envelope.fromJson(jsonDecode(frame));
      if (msg.type == MessageType.ping) {
        send(Envelope(type: MessageType.pong, id: msg.id, ts: now));
      } else {
        send(
          Envelope(
            type: MessageType.error,
            id: msg.id,
            ts: now,
            payload: const {'code': 'not_implemented'},
          ),
        );
      }
    } on FormatException catch (e) {
      send(
        Envelope(
          type: MessageType.error,
          id: 'invalid',
          ts: now,
          payload: {'code': 'bad_request', 'message': e.message},
        ),
      );
    }
  });
}
