import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fake_async/fake_async.dart';
import 'package:game_server/server.dart';
import 'package:http/http.dart' as http;
import 'package:nard_protocol/nard_protocol.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:test/test.dart';
import 'package:web_socket_channel/io.dart';

import 'live_moderation_and_limits_test.dart' show Harness, secret;

Map<String, Object?> row(int id, {String type = 'tournament_round'}) => {
  'id': id,
  'type': type,
  'category': 'tournament_round',
  'data': {'tournamentId': '3', 'round': 2},
  'from': null,
  'read': false,
  'createdAt': '2026-11-08T12:00:00+00:00',
};

NotifyPayload notify(Map<String, Map<String, Object?>> rows) => NotifyPayload([
  for (final e in rows.entries)
    LiveNotification(userId: e.key, notification: e.value),
]);

void main() {
  group('live notifications (ADR-049)', () {
    test('inbox rows reach the players\' live sockets unchanged', () {
      fakeAsync((async) {
        final h = Harness(async);
        final alice = h.connect('alice');
        final bob = h.connect('bob');
        // Connected but never authenticated: not a player yet.
        final anonymous = h.open();
        final delivered = h.hub.notify(
          notify({'alice': row(7), 'bob': row(8), 'carol': row(9)}),
        );
        async.flushMicrotasks();
        expect(delivered, 2);
        expect(alice.of(MessageType.notification).single.payload, row(7));
        expect(bob.of(MessageType.notification).single.payload, row(8));
        expect(anonymous.inbox, isEmpty);
        h.hub.dispose();
      });
    });

    test('a reconnect takes over: only the newest socket gets rows', () {
      fakeAsync((async) {
        final h = Harness(async);
        final old = h.connect('alice');
        final current = h.connect('alice');
        expect(h.hub.notify(notify({'alice': row(1)})), 1);
        async.flushMicrotasks();
        expect(old.of(MessageType.notification), isEmpty);
        expect(current.of(MessageType.notification), hasLength(1));
        h.hub.dispose();
      });
    });

    test('tournament.updated goes to the connected entrants only', () {
      fakeAsync((async) {
        final h = Harness(async);
        final alice = h.connect('alice');
        final bob = h.connect('bob');
        final eve = h.connect('eve');
        final sent = h.hub.tournamentUpdated(
          const TournamentUpdatedPush(
            tournamentId: '5',
            userIds: ['alice', 'bob', 'bob', 'carol'],
          ),
        );
        async.flushMicrotasks();
        expect(sent, 2);
        for (final s in [alice, bob]) {
          final msg = s.of(MessageType.tournamentUpdated).single;
          expect(
            TournamentUpdatedPayload.fromJson(msg.payload).tournamentId,
            '5',
          );
        }
        expect(eve.of(MessageType.tournamentUpdated), isEmpty);
        h.hub.dispose();
      });
    });
  });

  group('HTTP (ADR-049)', () {
    late HttpServer server;
    late Hub hub;

    setUp(() async {
      hub = Hub(ticketSecret: secret, results: MemoryResultSink());
      server = await io.serve(
        buildHandler(hub),
        InternetAddress.loopbackIPv4,
        0,
      );
    });

    tearDown(() async {
      hub.dispose();
      await server.close(force: true);
    });

    Future<http.Response> post(String path, String body, {String? signature}) =>
        http.post(
          Uri.parse('http://localhost:${server.port}$path'),
          headers: {
            'Content-Type': 'application/json',
            'X-Nard-Signature': signature ?? Signature.sign(body, secret),
          },
          body: body,
        );

    test('both pushes are signed and validated', () async {
      for (final (path, body, bad) in [
        (
          '/internal/notify',
          jsonEncode(notify({'alice': row(1)}).toJson()),
          '{"notifications":[{"userId":"a"}]}',
        ),
        (
          '/internal/tournament-updated',
          jsonEncode(
            const TournamentUpdatedPush(
              tournamentId: '5',
              userIds: ['alice'],
            ).toJson(),
          ),
          '{"tournamentId":"5"}',
        ),
      ]) {
        final ok = await post(path, body);
        expect(ok.statusCode, 200, reason: path);
        expect(jsonDecode(ok.body), {'delivered': 0});
        expect((await post(path, body, signature: 'forged')).statusCode, 401);
        expect(
          (await post(
            path,
            body,
            signature: Signature.sign(body, 'x' * 40),
          )).statusCode,
          401,
        );
        expect((await post(path, '[1]')).statusCode, 400);
        expect((await post(path, bad)).statusCode, 400, reason: bad);
      }
    });

    test('a notification reaches a real socket', () async {
      final ws = IOWebSocketChannel.connect('ws://localhost:${server.port}/ws');
      await ws.ready;
      final frames = StreamIterator(ws.stream);
      ws.sink.add(
        jsonEncode(
          Envelope(
            type: MessageType.auth,
            id: 'a',
            ts: 0,
            payload: {
              'ticket': Ticket.sign(
                Ticket(
                  userId: 'alice',
                  name: 'Alice',
                  expiresAt: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 60,
                ),
                secret,
              ),
            },
          ).toJson(),
        ),
      );
      expect(await frames.moveNext(), isTrue);
      final hello = Envelope.fromJson(jsonDecode(frames.current as String));
      expect(hello.type, MessageType.hello);

      final res = await post(
        '/internal/notify',
        jsonEncode(notify({'alice': row(42)}).toJson()),
      );
      expect(jsonDecode(res.body), {'delivered': 1});
      expect(
        await frames.moveNext().timeout(const Duration(seconds: 5)),
        isTrue,
      );
      final msg = Envelope.fromJson(jsonDecode(frames.current as String));
      expect((msg.type, msg.payload['id']), (MessageType.notification, 42));
      await ws.sink.close();
    });
  });
}
