import 'dart:async';

import 'dart:convert';
import 'dart:io';

import 'package:game_server/server.dart';
import 'package:http/http.dart' as http;
import 'package:nard_protocol/nard_protocol.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:test/test.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  late HttpServer server;

  setUp(() async {
    server = await io.serve(buildHandler(), InternetAddress.loopbackIPv4, 0);
  });

  tearDown(() => server.close(force: true));

  test('health check', () async {
    final res = await http.get(
      Uri.parse('http://localhost:${server.port}/healthz'),
    );
    expect(res.statusCode, 200);
    expect(res.body, 'ok');
  });

  test('WebSocket ping/pong and error replies', () async {
    final ws = IOWebSocketChannel.connect('ws://localhost:${server.port}/ws');
    final replies = ws.stream.map(
      (f) => Envelope.fromJson(jsonDecode(f as String)),
    );
    final it = StreamIterator(replies);
    ws.sink.add(
      jsonEncode(
        const Envelope(type: MessageType.ping, id: 'p1', ts: 0).toJson(),
      ),
    );
    expect(await it.moveNext(), isTrue);
    expect(it.current.type, MessageType.pong);
    expect(it.current.id, 'p1');
    ws.sink.add('garbage');
    expect(await it.moveNext(), isTrue);
    expect(it.current.type, MessageType.error);
    expect(it.current.payload['code'], 'bad_request');
    ws.sink.add(
      jsonEncode(
        const Envelope(type: MessageType.gameRoll, id: 'r', ts: 0).toJson(),
      ),
    );
    expect(await it.moveNext(), isTrue);
    expect(it.current.payload['code'], 'not_implemented');
    await ws.sink.close();
  });
}
