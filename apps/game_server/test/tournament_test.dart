import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fake_async/fake_async.dart';
import 'package:game_server/server.dart';
import 'package:http/http.dart' as http;
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:test/test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const secret = 'test-secret-test-secret-test-secret!';
const base = 1767225600000;

/// An in-memory WebSocket: frames sent by the hub land in [inbox].
class FakeSocket implements WebSocketChannel {
  final _incoming = StreamController<dynamic>();
  final inbox = <Envelope>[];
  late final _sink = _FakeSink(inbox);
  int _id = 0;

  @override
  Stream<dynamic> get stream => _incoming.stream;

  @override
  WebSocketSink get sink => _sink;

  void send(String type, [Map<String, Object?> payload = const {}]) =>
      _incoming.add(
        jsonEncode(
          Envelope(
            type: type,
            id: 'c${_id++}',
            ts: 0,
            payload: payload,
          ).toJson(),
        ),
      );

  void auth(String user) => send(MessageType.auth, {
    'ticket': Ticket.sign(
      Ticket(userId: user, name: user, expiresAt: base ~/ 1000 + 3600),
      secret,
    ),
  });

  void disconnect() => _incoming.close();

  List<Envelope> of(String type) => inbox.where((e) => e.type == type).toList();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSink implements WebSocketSink {
  _FakeSink(this.inbox);

  final List<Envelope> inbox;

  @override
  void add(dynamic data) =>
      inbox.add(Envelope.fromJson(jsonDecode(data as String)));

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

TournamentMatchPayload pairing(String id, {int noShow = 60}) =>
    TournamentMatchPayload(
      matchId: id,
      tournamentId: '7',
      round: 2,
      variant: Variant.shortNard,
      matchLength: 3,
      white: const PlayerInfo(userId: 'alice', name: 'Alice', rating: 1700),
      black: const PlayerInfo(userId: 'bob', name: 'Bob'),
      noShowSeconds: noShow,
    );

class Harness {
  Harness(this.async) {
    hub = Hub(
      ticketSecret: secret,
      results: results,
      now: () => base + async.elapsed.inMilliseconds,
    );
  }

  final FakeAsync async;
  final results = MemoryResultSink();
  late final Hub hub;

  FakeSocket connect(String user) {
    final s = FakeSocket();
    hub.attach(s);
    s.auth(user);
    async.flushMicrotasks();
    return s;
  }
}

void main() {
  test('an assigned match starts once both players are present', () {
    fakeAsync((async) {
      final h = Harness(async);
      final alice = h.connect('alice');
      expect(h.hub.assignTournamentMatch(pairing('t7-2-0')), isTrue);
      // Idempotent: the API may push the same pairing again.
      expect(h.hub.assignTournamentMatch(pairing('t7-2-0')), isFalse);
      final waiting = TournamentReadyStatePayload.fromJson(
        alice.of(MessageType.tournamentReadyState).last.payload,
      );
      expect(waiting.you, Side.white);
      expect(waiting.ready, {Side.white: true, Side.black: false});
      expect(waiting.deadline, base + 60000);
      // Alice may not queue for another match meanwhile.
      alice.send(MessageType.queueJoin, {
        'variant': 'shortNard',
        'matchLength': 1,
        'mode': 'casual',
      });
      async.flushMicrotasks();
      expect(
        alice.of(MessageType.error).last.payload['message'],
        'Tournament match pending',
      );
      async.elapse(const Duration(seconds: 30));
      // Carol is not in this match.
      final carol = h.connect('carol');
      carol.send(MessageType.tournamentReady, {'matchId': 't7-2-0'});
      async.flushMicrotasks();
      expect(
        carol.of(MessageType.error).last.payload['code'],
        ErrorCode.notInMatch,
      );
      final bob = h.connect('bob');
      expect(h.hub.pendingTournamentMatches, 0);
      final found = MatchFoundPayload.fromJson(
        bob.of(MessageType.matchFound).single.payload,
      );
      expect(found.matchId, 't7-2-0');
      expect(found.mode, QueueMode.tournament);
      expect((found.tournamentId, found.round), ('7', 2));
      expect(found.you, Side.black);
      // Unrated: no ratings in the seats.
      expect(found.white.rating, isNull);
      expect(alice.of(MessageType.matchFound), hasLength(1));
      // The no-show timer was cancelled.
      async.elapse(const Duration(seconds: 60));
      expect(h.results.results, isEmpty);
      alice.send(MessageType.gameSeed, {'clientSeed': 'a'});
      bob.send(MessageType.gameSeed, {'clientSeed': 'b'});
      // Three points end the 3-point match at once.
      bob.send(MessageType.gameResign, {'kind': 'backgammon'});
      async.flushMicrotasks();
      final result = h.results.results.single;
      expect(result.matchId, 't7-2-0');
      expect(result.mode, QueueMode.tournament);
      expect(result.tournamentId, '7');
      expect(result.winner, Side.white);
      expect(result.reason, MatchEndReason.resigned);
      // A played match is never assigned again.
      expect(h.hub.assignTournamentMatch(pairing('t7-2-0')), isFalse);
      h.hub.dispose();
    });
  });

  test('tournament.ready marks a player present', () {
    fakeAsync((async) {
      final h = Harness(async);
      h.hub.assignTournamentMatch(pairing('m1'));
      final alice = h.connect('alice');
      final bob = FakeSocket();
      h.hub.attach(bob);
      bob.send(MessageType.tournamentReady, {'matchId': 'm1'});
      async.flushMicrotasks();
      expect(
        bob.of(MessageType.error).single.payload['code'],
        ErrorCode.unauthorized,
      );
      bob.auth('bob');
      bob.send(MessageType.tournamentReady, {'matchId': 'm1'});
      bob.send(MessageType.tournamentReady, {'matchId': 7});
      async.flushMicrotasks();
      expect(
        bob.of(MessageType.error).last.payload['code'],
        ErrorCode.badRequest,
      );
      expect(alice.of(MessageType.matchFound), hasLength(1));
      h.hub.dispose();
    });
  });

  test('no-show: the present player wins by walkover', () {
    fakeAsync((async) {
      final h = Harness(async);
      h.hub.assignTournamentMatch(pairing('m1'));
      final bob = h.connect('bob');
      // Leaving after arriving still counts as present.
      bob.disconnect();
      async.elapse(const Duration(seconds: 59));
      expect(h.results.results, isEmpty);
      final bobAgain = h.connect('bob');
      async.elapse(const Duration(seconds: 1));
      final result = h.results.results.single;
      expect(result.reason, MatchEndReason.walkover);
      expect(result.winner, Side.black);
      expect((result.whiteScore, result.blackScore), (0, 3));
      expect(result.games, isEmpty);
      expect(result.tournamentId, '7');
      expect(result.mode, QueueMode.tournament);
      final walkover = TournamentWalkoverPayload.fromJson(
        bobAgain.of(MessageType.tournamentWalkover).single.payload,
      );
      expect(walkover.winner, Side.black);
      expect(h.hub.pendingTournamentMatches, 0);
      expect(h.hub.assignTournamentMatch(pairing('m1')), isFalse);
      // Alice arriving late finds nothing to play.
      final alice = h.connect('alice');
      expect(alice.of(MessageType.matchFound), isEmpty);
      h.hub.dispose();
    });
  });

  test('no-show: nobody came, both are reported absent', () {
    fakeAsync((async) {
      final h = Harness(async);
      h.hub.assignTournamentMatch(pairing('m1', noShow: 30));
      async.elapse(const Duration(seconds: 30));
      expect(h.results.results, isEmpty);
      final noShow = h.results.noShows.single;
      expect((noShow.matchId, noShow.tournamentId), ('m1', '7'));
      expect(noShow.endedAt, base + 30000);
      h.hub.dispose();
    });
  });

  test('a busy player starts the tournament match after the current one', () {
    fakeAsync((async) {
      final h = Harness(async);
      final alice = h.connect('alice');
      final carol = h.connect('carol');
      carol.send(MessageType.roomCreate, {
        'variant': 'shortNard',
        'matchLength': 1,
      });
      async.flushMicrotasks();
      final code = carol.of(MessageType.roomCreated).single.payload['code'];
      alice.send(MessageType.roomJoin, {'code': code});
      async.flushMicrotasks();
      expect(alice.of(MessageType.matchFound), hasLength(1));
      h.hub.assignTournamentMatch(pairing('m1'));
      final bob = h.connect('bob');
      // Both present, Alice still playing: past the deadline nothing is
      // decided, the match waits.
      async.elapse(const Duration(seconds: 61));
      expect(h.results.results, isEmpty);
      expect(bob.of(MessageType.matchFound), isEmpty);
      alice.send(MessageType.gameSeed, {'clientSeed': 'a'});
      carol.send(MessageType.gameSeed, {'clientSeed': 'c'});
      alice.send(MessageType.gameResign, {'kind': 'single'});
      async.flushMicrotasks();
      async.elapse(Duration.zero);
      expect(h.results.results.single.mode, QueueMode.casual);
      final found = MatchFoundPayload.fromJson(
        bob.of(MessageType.matchFound).single.payload,
      );
      expect(found.matchId, 'm1');
      expect(alice.of(MessageType.matchFound), hasLength(2));
      h.hub.dispose();
    });
  });

  group('POST /internal/tournament-matches', () {
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

    Future<http.Response> post(String body, {String? signature}) => http.post(
      Uri.parse('http://localhost:${server.port}/internal/tournament-matches'),
      headers: {
        'Content-Type': 'application/json',
        'X-Nard-Signature': signature ?? Signature.sign(body, secret),
      },
      body: body,
    );

    test('accepts signed pairings once and refuses the rest', () async {
      final body = jsonEncode(pairing('t7-1-3').toJson());
      final first = await post(body);
      expect(first.statusCode, 201);
      expect(jsonDecode(first.body), {
        'matchId': 't7-1-3',
        'status': 'assigned',
      });
      expect(hub.pendingTournamentMatches, 1);
      expect((await post(body)).statusCode, 200);
      expect((await post(body, signature: 'forged')).statusCode, 401);
      expect(
        (await post(
          body,
          signature: Signature.sign(body, 'x' * 40),
        )).statusCode,
        401,
      );
      expect((await post('[1]')).statusCode, 400);
      expect((await post('{"matchId":"x"}')).statusCode, 400);
      // Secrets shorter than 32 characters are never accepted.
      expect(
        Signature.verify(body, Signature.sign(body, 'short'), 'short'),
        isFalse,
      );
    });
  });
}
