import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:game_server/server.dart';
import 'package:http/http.dart' as http;
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:test/test.dart';
import 'package:web_socket_channel/io.dart';

const secret = 'test-secret-test-secret-test-secret!';

class Client {
  Client(int port)
    : ws = IOWebSocketChannel.connect('ws://localhost:$port/ws') {
    it = StreamIterator(
      ws.stream.map((f) => Envelope.fromJson(jsonDecode(f as String))),
    );
  }

  final IOWebSocketChannel ws;
  late final StreamIterator<Envelope> it;
  int _id = 0;

  void send(String type, [Map<String, Object?> payload = const {}]) =>
      ws.sink.add(
        jsonEncode(
          Envelope(
            type: type,
            id: 'c${_id++}',
            ts: 0,
            payload: payload,
          ).toJson(),
        ),
      );

  /// Next message of [type], skipping others.
  Future<Envelope> next(String type) async {
    while (await it.moveNext().timeout(const Duration(seconds: 5))) {
      if (it.current.type == type) return it.current;
    }
    throw StateError('Stream closed');
  }

  void auth(String user) => send(MessageType.auth, {
    'ticket': Ticket.sign(
      Ticket(
        userId: user,
        name: user,
        expiresAt: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 60,
      ),
      secret,
    ),
  });
}

void main() {
  late HttpServer server;
  late Hub hub;
  late MemoryResultSink results;

  setUp(() async {
    results = MemoryResultSink();
    hub = Hub(ticketSecret: secret, results: results);
    server = await io.serve(buildHandler(hub), InternetAddress.loopbackIPv4, 0);
  });

  tearDown(() async {
    hub.dispose();
    await server.close(force: true);
  });

  test('health check', () async {
    final res = await http.get(
      Uri.parse('http://localhost:${server.port}/healthz'),
    );
    expect(res.statusCode, 200);
    expect(res.body, 'ok');
  });

  test('ping, bad frames and unauthenticated intents', () async {
    final c = Client(server.port);
    c.send(MessageType.ping);
    expect((await c.next(MessageType.pong)).id, 'c0');
    c.ws.sink.add('garbage');
    expect(
      (await c.next(MessageType.error)).payload['code'],
      ErrorCode.badRequest,
    );
    c.send(MessageType.gameRoll);
    expect(
      (await c.next(MessageType.error)).payload['code'],
      ErrorCode.unauthorized,
    );
    c.send(MessageType.auth, {'ticket': 'forged.ticket'});
    expect(
      (await c.next(MessageType.error)).payload['code'],
      ErrorCode.unauthorized,
    );
    c.auth('u1');
    expect((await c.next(MessageType.hello)).payload['userId'], 'u1');
    c.send(MessageType.gameRoll);
    expect(
      (await c.next(MessageType.error)).payload['code'],
      ErrorCode.notInMatch,
    );
    c.send(MessageType.queueJoin, {'variant': 'x'});
    expect(
      (await c.next(MessageType.error)).payload['code'],
      ErrorCode.badRequest,
    );
    await c.ws.sink.close();
  });

  test(
    'two players are matched and play on the authoritative server',
    () async {
      final a = Client(server.port)..auth('alice');
      final b = Client(server.port)..auth('bob');
      await a.next(MessageType.hello);
      await b.next(MessageType.hello);
      const join = QueueJoinPayload(
        variant: Variant.shortNard,
        matchLength: 1,
        mode: QueueMode.casual,
      );
      a.send(MessageType.queueJoin, join.toJson());
      b.send(MessageType.queueJoin, join.toJson());
      final fa = MatchFoundPayload.fromJson(
        (await a.next(MessageType.matchFound)).payload,
      );
      final fb = MatchFoundPayload.fromJson(
        (await b.next(MessageType.matchFound)).payload,
      );
      expect(fa.matchId, fb.matchId);
      expect(fa.you, fb.you.opponent);
      a.send(MessageType.gameSeed, const SeedPayload('sa').toJson());
      b.send(MessageType.gameSeed, const SeedPayload('sb').toJson());
      GameStatePayload s;
      do {
        s = GameStatePayload.fromJson(
          (await a.next(MessageType.gameState)).payload,
        );
      } while (s.state.phase == GamePhase.opening);
      // Short Nard: the opening dice are played (SN-02).
      expect(s.state.phase, GamePhase.awaitingMove);
      final mover = s.state.turn == fa.you ? a : b;
      final turn = s.state.legalTurns.first;
      for (final m in turn.moves) {
        mover.send(
          MessageType.gameMove,
          MovePayload(m.from, m.to, die: m.die).toJson(),
        );
      }
      mover.send(MessageType.gameConfirmTurn);
      do {
        s = GameStatePayload.fromJson(
          (await a.next(MessageType.gameState)).payload,
        );
      } while (s.state.phase == GamePhase.awaitingMove);
      expect(s.state.phase, GamePhase.awaitingRoll);
      expect(s.record.actions.whereType<PlayTurn>(), hasLength(1));
      // Reconnect: a new connection takes over and gets the state again.
      final loser = s.state.turn == fa.you ? a : b;
      final user = loser == a ? 'alice' : 'bob';
      final again = Client(server.port)..auth(user);
      await again.next(MessageType.hello);
      final resumed = GameStatePayload.fromJson(
        (await again.next(MessageType.gameState)).payload,
      );
      expect(resumed.matchId, fa.matchId);
      again.send(
        MessageType.gameResign,
        const ResignPayload(WinKind.single).toJson(),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(results.results.single.reason, MatchEndReason.resigned);
      expect(hub.activeMatches, 0);
      for (final c in [a, b, again]) {
        await c.ws.sink.close();
      }
    },
  );

  test('private room by code, spectator, presence and emotes', () async {
    final a = Client(server.port)..auth('alice');
    final b = Client(server.port)..auth('bob');
    final c = Client(server.port)..auth('carol');
    for (final x in [a, b, c]) {
      await x.next(MessageType.hello);
    }
    a.send(
      MessageType.roomCreate,
      const RoomCreatePayload(
        variant: Variant.longNard,
        matchLength: 1,
      ).toJson(),
    );
    final code =
        RoomCodePayload.fromJson(
          (await a.next(MessageType.roomCreated)).payload,
        ).code;
    expect(code, matches(RegExp(r'^[A-Z2-9]{6}$')));
    b.send(MessageType.roomJoin, {'code': 'ZZZZZZ'});
    expect(
      (await b.next(MessageType.error)).payload['code'],
      ErrorCode.notInMatch,
    );
    b.send(MessageType.roomJoin, RoomCodePayload(code).toJson());
    final found = MatchFoundPayload.fromJson(
      (await a.next(MessageType.matchFound)).payload,
    );
    expect(found.mode, QueueMode.casual);
    expect(found.variant, Variant.longNard);
    await b.next(MessageType.matchFound);
    // Carol finds Alice's match and watches it.
    c.send(MessageType.presenceQuery, {
      'userIds': ['alice', 'bob', 'nobody'],
    });
    final presence = PresencePayload.fromJson(
      (await c.next(MessageType.presence)).payload,
    );
    expect(presence.matches, {'alice': found.matchId, 'bob': found.matchId});
    c.send(MessageType.spectateJoin, {'matchId': found.matchId});
    final watched = GameStatePayload.fromJson(
      (await c.next(MessageType.gameState)).payload,
    );
    expect(watched.matchId, found.matchId);
    // Emotes reach the opponent and spectators; free text is refused.
    a.send(MessageType.chatEmote, const EmotePayload('good_luck').toJson());
    final heard = EmotePayload.fromJson(
      (await b.next(MessageType.chatEmote)).payload,
    );
    expect((heard.id, heard.from), ('good_luck', found.you));
    expect(
      EmotePayload.fromJson((await c.next(MessageType.chatEmote)).payload).id,
      'good_luck',
    );
    a.send(MessageType.chatEmote, {'id': 'some insult'});
    expect(
      (await a.next(MessageType.error)).payload['code'],
      ErrorCode.badRequest,
    );
    // Spectators cannot act.
    c.send(MessageType.gameRoll);
    expect(
      (await c.next(MessageType.error)).payload['code'],
      ErrorCode.notInMatch,
    );
    c.send(MessageType.spectateLeave);
    for (final x in [a, b, c]) {
      await x.ws.sink.close();
    }
  });
}
