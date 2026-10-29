import 'dart:io';

import 'package:game_server/server.dart';
import 'package:shelf/shelf_io.dart' as io;

Future<void> main() async {
  final env = Platform.environment;
  final port = int.tryParse(env['PORT'] ?? '') ?? 8080;
  final secret = env['GAME_TICKET_SECRET'];
  if (secret == null || secret.length < 32) {
    stderr.writeln('GAME_TICKET_SECRET (>= 32 chars) is required');
    exitCode = 64;
    return;
  }
  // Results go to the API once it is wired (Phase 3 step 3).
  final hub = Hub(ticketSecret: secret, results: MemoryResultSink());
  final server = await io.serve(
    buildHandler(hub),
    InternetAddress.anyIPv4,
    port,
  );
  stdout.writeln('game_server listening on :${server.port}');
}
