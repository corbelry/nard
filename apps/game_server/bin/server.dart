import 'dart:io';

import 'package:game_server/server.dart';
import 'package:shelf/shelf_io.dart' as io;

Future<void> main() async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final server = await io.serve(buildHandler(), InternetAddress.anyIPv4, port);
  stdout.writeln('game_server listening on :${server.port}');
}
