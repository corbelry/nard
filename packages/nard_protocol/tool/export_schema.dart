import 'dart:convert';
import 'dart:io';

import 'package:nard_protocol/nard_protocol.dart';

/// Writes the JSON Schemas consumed by the PHP API into `schema/`.
void main() {
  const encoder = JsonEncoder.withIndent('  ');
  for (final e in Schemas.all.entries) {
    File('schema/${e.key}').writeAsStringSync('${encoder.convert(e.value)}\n');
    stdout.writeln('schema/${e.key}');
  }
}
