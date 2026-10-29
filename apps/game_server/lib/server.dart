import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'src/hub.dart';

export 'src/http_result_sink.dart';
export 'src/hub.dart';
export 'src/ticket.dart';

/// HTTP + WebSocket handler: `/healthz` and `/ws` (docs/PROTOCOL.md).
Handler buildHandler(Hub hub) {
  final router =
      Router()
        ..get('/healthz', (Request _) => Response.ok('ok'))
        ..get(
          '/ws',
          webSocketHandler((WebSocketChannel ch, String? _) => hub.attach(ch)),
        );
  return const Pipeline().addMiddleware(logRequests()).addHandler(router.call);
}
