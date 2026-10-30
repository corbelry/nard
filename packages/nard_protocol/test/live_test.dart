import 'dart:convert';
import 'dart:io';

import 'package:nard_protocol/nard_protocol.dart';
import 'package:test/test.dart';

Map<String, Object?> roundTrip(Map<String, Object?> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, Object?>;

const row = {
  'id': 7,
  'type': 'tournament_round',
  'category': 'tournament_round',
  'data': {'tournamentId': '3', 'round': 2},
  'from': null,
  'read': false,
  'createdAt': '2026-11-08T12:00:00+00:00',
};

void main() {
  group('live notifications (ADR-049)', () {
    test('notify pushes round-trip and keep the row unchanged', () {
      const push = NotifyPayload([
        LiveNotification(userId: '42', notification: row),
      ]);
      final back = NotifyPayload.fromJson(roundTrip(push.toJson()));
      expect(back.notifications.single.userId, '42');
      expect(back.notifications.single.notification, row);
      expect(
        NotifyPayload.fromJson({'notifications': <Object?>[]}).notifications,
        isEmpty,
      );
    });

    test('notify pushes are validated', () {
      Map<String, Object?> one(Object? userId, Object? n) => {
        'notifications': [
          {'userId': userId, 'notification': n},
        ],
      };
      for (final bad in [
        <String, Object?>{},
        {'notifications': 'x'},
        {
          'notifications': [1],
        },
        one(null, row),
        one('x' * 65, row),
        one('1', null),
        one('1', {...row, 'id': '7'}),
        one('1', {...row, 'type': ''}),
        one('1', {...row, 'type': 'x' * 65}),
        {
          'notifications': List.filled(NotifyPayload.maxItems + 1, {
            'userId': '1',
            'notification': row,
          }),
        },
      ]) {
        expect(
          () => NotifyPayload.fromJson(bad),
          throwsA(isA<ProtocolException>()),
          reason: '$bad'.substring(0, 60.clamp(0, '$bad'.length)),
        );
      }
    });

    test('tournament updates round-trip and are validated', () {
      const push = TournamentUpdatedPush(
        tournamentId: '5',
        userIds: ['1', '2'],
      );
      final back = TournamentUpdatedPush.fromJson(roundTrip(push.toJson()));
      expect(back.tournamentId, '5');
      expect(back.userIds, ['1', '2']);
      for (final bad in [
        {'tournamentId': '5'},
        {'tournamentId': 5, 'userIds': <Object?>[]},
        {
          'tournamentId': '5',
          'userIds': [1],
        },
        {
          'tournamentId': '5',
          'userIds': [''],
        },
        {
          'tournamentId': '5',
          'userIds': List.filled(TournamentUpdatedPush.maxUsers + 1, '1'),
        },
      ]) {
        expect(
          () => TournamentUpdatedPush.fromJson(bad),
          throwsA(isA<ProtocolException>()),
        );
      }
      const msg = TournamentUpdatedPayload('5');
      expect(
        TournamentUpdatedPayload.fromJson(roundTrip(msg.toJson())).tournamentId,
        '5',
      );
      expect(
        () => TournamentUpdatedPayload.fromJson(const {}),
        throwsA(isA<ProtocolException>()),
      );
    });

    test('the new server messages are known types in an envelope', () {
      for (final type in [
        MessageType.notification,
        MessageType.tournamentUpdated,
      ]) {
        final e = Envelope.fromJson(
          roundTrip(Envelope(type: type, id: 's1', ts: 1).toJson()),
        );
        expect(e.type, type);
      }
      // An older build does not know them: the frame fails to parse and
      // GameSocket drops it (it ignores FormatException frames).
      expect(
        () => Envelope.fromJson({
          'v': 1,
          'type': 'some.future.type',
          'id': 's1',
          'ts': 1,
          'payload': <String, Object?>{},
        }),
        throwsFormatException,
      );
    });

    test('the schemas match the models and the committed files', () {
      const push = TournamentUpdatedPush(tournamentId: '1', userIds: ['1']);
      expect(
        push.toJson().keys.toSet(),
        (Schemas.tournamentUpdated['properties']! as Map).keys.toSet(),
      );
      const notify = NotifyPayload([
        LiveNotification(userId: '1', notification: row),
      ]);
      expect(
        notify.toJson().keys.toSet(),
        (Schemas.notify['properties']! as Map).keys.toSet(),
      );
      for (final (file, schema) in [
        ('notify', Schemas.notify),
        ('tournament_updated', Schemas.tournamentUpdated),
      ]) {
        expect(
          jsonDecode(File('schema/$file.schema.json').readAsStringSync()),
          schema,
        );
      }
    });
  });
}
