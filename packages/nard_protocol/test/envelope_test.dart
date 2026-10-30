import 'dart:convert';

import 'package:nard_protocol/nard_protocol.dart';
import 'package:test/test.dart';

void main() {
  test('round trips through JSON', () {
    const e = Envelope(
      type: MessageType.ping,
      id: 'a1',
      ts: 5,
      payload: {'x': 1},
    );
    final back = Envelope.fromJson(jsonDecode(jsonEncode(e.toJson())));
    expect(back.toJson(), e.toJson());
    expect(back.version, protocolVersion);
  });

  test('rejects malformed frames', () {
    for (final bad in <Object?>[
      'text',
      {'type': 'nope', 'id': 'a', 'ts': 1},
      {'type': 'ping', 'id': '', 'ts': 1},
      {'type': 'ping', 'id': 'a', 'ts': '1'},
      {'type': 'ping', 'id': 'a', 'ts': 1, 'payload': <int>[]},
      {'type': 'ping', 'id': 'a', 'ts': 1, 'v': '1'},
    ]) {
      expect(
        () => Envelope.fromJson(bad),
        throwsFormatException,
        reason: '$bad',
      );
    }
  });
}
