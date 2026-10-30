import 'dart:convert';
import 'dart:io';

import 'package:nard_protocol/nard_protocol.dart';
import 'package:test/test.dart';

void main() {
  test('moderation pushes round-trip and are validated (ADR-045)', () {
    const push = ModerationPayload(
      userId: '42',
      banned: false,
      muted: true,
      queueCooldownUntil: 1767225600,
    );
    final back = ModerationPayload.fromJson(
      jsonDecode(jsonEncode(push.toJson())) as Map<String, Object?>,
    );
    expect(
      (back.userId, back.banned, back.muted, back.queueCooldownUntil),
      ('42', false, true, 1767225600),
    );
    // No cooldown: sent as null (the field is always present).
    final cleared = ModerationPayload.fromJson(
      const ModerationPayload(
        userId: '42',
        banned: true,
        muted: false,
      ).toJson(),
    );
    expect(cleared.queueCooldownUntil, isNull);
    expect(cleared.toJson(), containsPair('queueCooldownUntil', null));
    expect(cleared.banned, isTrue);
    Map<String, Object?> bad(String key, Object? value) => {
      ...push.toJson(),
      key: value,
    };
    for (final (key, value) in [
      ('userId', null),
      ('userId', 'x' * 65),
      ('banned', 'yes'),
      ('muted', null),
      ('queueCooldownUntil', '1767225600'),
    ]) {
      expect(
        () => ModerationPayload.fromJson(bad(key, value)),
        throwsA(isA<ProtocolException>()),
        reason: '$key=$value',
      );
    }
    expect(ErrorCode.banned, 'banned');
    // Servers may only send 1000 or 3000-4999 (package:web_socket).
    expect((CloseCode.policy, CloseCode.tooLarge), (4008, 4009));
  });

  test('the moderation schema matches the model and the committed file', () {
    const push = ModerationPayload(userId: '1', banned: false, muted: false);
    final schema = Schemas.moderation;
    expect(
      push.toJson().keys.toSet(),
      (schema['properties']! as Map<String, Object?>).keys.toSet(),
    );
    expect((schema['required']! as List).toSet(), {
      'userId',
      'banned',
      'muted',
    });
    expect(
      jsonDecode(File('schema/moderation.schema.json').readAsStringSync()),
      schema,
    );
  });
}
