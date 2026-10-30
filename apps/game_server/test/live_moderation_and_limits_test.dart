import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fake_async/fake_async.dart';
import 'package:game_server/server.dart';
import 'package:http/http.dart' as http;
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:test/test.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const secret = 'test-secret-test-secret-test-secret!';
const base = 1767225600000;

/// An in-memory WebSocket that records what the hub sends and how it
/// closes the socket (closing ends the incoming stream, like dart:io).
class FakeSocket implements WebSocketChannel {
  final _incoming = StreamController<dynamic>();
  final inbox = <Envelope>[];
  late final _sink = _FakeSink(this);
  int _id = 0;
  @override
  int? closeCode;
  @override
  String? closeReason;

  bool get closed => closeCode != null;

  @override
  Stream<dynamic> get stream => _incoming.stream;

  @override
  WebSocketSink get sink => _sink;

  void raw(Object frame) {
    if (!_incoming.isClosed) _incoming.add(frame);
  }

  void send(String type, [Map<String, Object?> payload = const {}]) => raw(
    jsonEncode(
      Envelope(type: type, id: 'c${_id++}', ts: 0, payload: payload).toJson(),
    ),
  );

  void auth(String user, {bool muted = false, int? queueCooldownUntil}) =>
      send(MessageType.auth, {
        'ticket': Ticket.sign(
          Ticket(
            userId: user,
            name: user,
            expiresAt: base ~/ 1000 + 3600,
            muted: muted,
            queueCooldownUntil: queueCooldownUntil,
          ),
          secret,
        ),
      });

  List<Envelope> of(String type) => inbox.where((e) => e.type == type).toList();

  List<String> get errors => [
    for (final e in of(MessageType.error)) e.payload['code']! as String,
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSink implements WebSocketSink {
  _FakeSink(this.socket);

  final FakeSocket socket;

  @override
  void add(dynamic data) {
    if (socket.closed) return;
    socket.inbox.add(Envelope.fromJson(jsonDecode(data as String)));
  }

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    if (socket.closed) return;
    socket
      ..closeCode = closeCode ?? 1005
      ..closeReason = closeReason;
    await socket._incoming.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class Harness {
  Harness(this.async, {WsLimits limits = const WsLimits()}) {
    hub = Hub(
      ticketSecret: secret,
      results: results,
      limits: limits,
      now: () => base + async.elapsed.inMilliseconds,
    );
  }

  final FakeAsync async;
  final results = MemoryResultSink();
  late final Hub hub;

  FakeSocket open({String remote = '203.0.113.1'}) {
    final s = FakeSocket();
    hub.attach(s, remote: remote);
    return s;
  }

  FakeSocket connect(String user, {bool muted = false, int? cooldown}) {
    final s = open()..auth(user, muted: muted, queueCooldownUntil: cooldown);
    async.flushMicrotasks();
    return s;
  }

  /// Two players in a private match; returns (alice, bob).
  (FakeSocket, FakeSocket) match() {
    final a = connect('alice');
    final b = connect('bob');
    a.send(
      MessageType.roomCreate,
      const RoomCreatePayload(
        variant: Variant.shortNard,
        matchLength: 1,
      ).toJson(),
    );
    async.flushMicrotasks();
    final code = RoomCodePayload.fromJson(
      a.of(MessageType.roomCreated).single.payload,
    );
    b.send(MessageType.roomJoin, RoomCodePayload(code.code).toJson());
    async.flushMicrotasks();
    expect(a.of(MessageType.matchFound), hasLength(1));
    return (a, b);
  }
}

const join = QueueJoinPayload(
  variant: Variant.shortNard,
  matchLength: 1,
  mode: QueueMode.ranked,
);

ModerationPayload push(
  String user, {
  bool banned = false,
  bool muted = false,
  int? cooldown,
}) => ModerationPayload(
  userId: user,
  banned: banned,
  muted: muted,
  queueCooldownUntil: cooldown,
);

void main() {
  group('WebSocket limits (ADR-045)', () {
    test(
      'a text frame over the size limit closes the socket (CloseCode.tooLarge)',
      () {
        fakeAsync((async) {
          final h = Harness(async, limits: const WsLimits(maxFrameBytes: 1024));
          final s = h.connect('alice');
          expect(s.of(MessageType.hello), hasLength(1));
          s.raw('x' * 1025);
          async.flushMicrotasks();
          expect(s.closeCode, CloseCode.tooLarge);
          expect(s.errors, isEmpty);
          // Binary frames are measured too.
          final b = h.open()..raw(List.filled(1025, 0));
          async.flushMicrotasks();
          expect(b.closeCode, CloseCode.tooLarge);
          expect(
            h.hub.metrics.render(),
            contains('nard_ws_rejected_total{reason="frame_too_large"} 2'),
          );
          expect(h.hub.connectionCount, 0);
          h.hub.dispose();
        });
      },
    );

    test('a socket that does not authenticate in time is closed', () {
      fakeAsync((async) {
        final h = Harness(async);
        final idle = h.open();
        // Pings and failed auths do not stop the clock.
        idle
          ..send(MessageType.ping)
          ..send(MessageType.auth, {'ticket': 'forged.ticket'});
        final authed = h.connect('alice');
        async.elapse(const Duration(seconds: 9));
        expect(idle.closed, isFalse);
        async.elapse(const Duration(seconds: 1));
        expect(
          (idle.closeCode, idle.closeReason),
          (CloseCode.policy, 'auth_timeout'),
        );
        expect(authed.closed, isFalse);
        async.elapse(const Duration(minutes: 5));
        expect(authed.closed, isFalse);
        expect(
          h.hub.metrics.render(),
          contains('nard_ws_rejected_total{reason="auth_timeout"} 1'),
        );
        h.hub.dispose();
      });
    });

    test('messages over the rate are refused, then the socket is closed', () {
      fakeAsync((async) {
        final h = Harness(
          async,
          limits: const WsLimits(messagesPerSecond: 20, burst: 40),
        );
        final s = h.connect('alice');
        // The auth message used one token: 39 more fit in the burst.
        for (var i = 0; i < 39; i++) {
          s.send(MessageType.ping);
        }
        async.flushMicrotasks();
        expect(s.of(MessageType.pong), hasLength(39));
        s.send(MessageType.ping);
        async.flushMicrotasks();
        expect(s.errors, [ErrorCode.rateLimited]);
        expect(s.of(MessageType.pong), hasLength(39));
        // Tokens come back at the rate; an accepted message forgives.
        async.elapse(const Duration(milliseconds: 100));
        s
          ..send(MessageType.ping)
          ..send(MessageType.ping);
        async.flushMicrotasks();
        expect(s.of(MessageType.pong), hasLength(41));
        expect(s.closed, isFalse);
        // Sustained flooding: one error per run, then closed.
        for (var i = 0; i < 41; i++) {
          s.send(MessageType.ping);
        }
        async.flushMicrotasks();
        expect(s.errors, [ErrorCode.rateLimited, ErrorCode.rateLimited]);
        expect(
          (s.closeCode, s.closeReason),
          (CloseCode.policy, 'rate_limited'),
        );
        expect(
          h.hub.metrics.render(),
          contains('nard_ws_rejected_total{reason="rate_limited"} 1'),
        );
        h.hub.dispose();
      });
    });

    test('concurrent connections are capped per remote address', () {
      fakeAsync((async) {
        final h = Harness(
          async,
          limits: const WsLimits(maxConnectionsPerIp: 2),
        );
        expect(h.hub.admits('198.51.100.7'), isTrue);
        final a = h.open(remote: '198.51.100.7');
        h.open(remote: '198.51.100.7');
        expect(h.hub.admits('198.51.100.7'), isFalse);
        expect(h.hub.admits('198.51.100.8'), isTrue);
        unawaited(a.sink.close());
        async.flushMicrotasks();
        expect(h.hub.admits('198.51.100.7'), isTrue);
        expect(
          h.hub.metrics.render(),
          contains('nard_ws_rejected_total{reason="ip_limit"} 1'),
        );
        // 0 turns the cap off.
        final off = Harness(
          async,
          limits: const WsLimits(maxConnectionsPerIp: 0),
        );
        for (var i = 0; i < 50; i++) {
          off.open(remote: '198.51.100.7');
        }
        expect(off.hub.admits('198.51.100.7'), isTrue);
        h.hub.dispose();
        off.hub.dispose();
      });
    });

    test('limits are read from the environment with defaults', () {
      const d = WsLimits();
      expect(
        (
          d.maxFrameBytes,
          d.authTimeout,
          d.messagesPerSecond,
          d.burst,
          d.maxConnectionsPerIp,
          d.pingInterval,
          d.trustProxy,
        ),
        (
          16384,
          const Duration(seconds: 10),
          20,
          40,
          20,
          const Duration(seconds: 30),
          false,
        ),
      );
      final env = WsLimits.fromEnv({
        'WS_MAX_FRAME_BYTES': '1024',
        'WS_AUTH_TIMEOUT_SECONDS': '5',
        'WS_MESSAGES_PER_SECOND': '10',
        'WS_BURST': '15',
        'WS_MAX_CONNECTIONS_PER_IP': '0',
        'WS_PING_SECONDS': '0',
        'TRUST_PROXY': 'true',
      });
      expect(
        (
          env.maxFrameBytes,
          env.authTimeout,
          env.messagesPerSecond,
          env.burst,
          env.maxConnectionsPerIp,
          env.pingInterval,
          env.trustProxy,
        ),
        (1024, const Duration(seconds: 5), 10, 15, 0, null, true),
      );
      expect(WsLimits.fromEnv({'WS_BURST': 'x'}).burst, 40);
    });

    test('the client address: the peer, or the proxy\'s last hop', () {
      Request req(String? xff) => Request(
        'GET',
        Uri.parse('http://localhost/ws'),
        headers: {if (xff != null) 'x-forwarded-for': xff},
        context: {
          'shelf.io.connection_info': _ConnectionInfo(
            InternetAddress('10.0.0.5'),
          ),
        },
      );
      expect(clientAddress(req('1.1.1.1'), trustProxy: false), '10.0.0.5');
      expect(
        clientAddress(req('6.6.6.6, 203.0.113.9'), trustProxy: true),
        '203.0.113.9',
      );
      expect(clientAddress(req(null), trustProxy: true), '10.0.0.5');
      expect(clientAddress(req(' , '), trustProxy: true), '10.0.0.5');
    });
  });

  group('live moderation (ADR-045)', () {
    test('a mute push drops the live session\'s emotes; unmute restores', () {
      fakeAsync((async) {
        final h = Harness(async);
        final (a, b) = h.match();
        expect(h.hub.moderate(push('alice', muted: true)), isTrue);
        a.send(MessageType.chatEmote, const EmotePayload('good_luck').toJson());
        async.flushMicrotasks();
        expect(b.of(MessageType.chatEmote), isEmpty);
        h.hub.moderate(push('alice'));
        a.send(MessageType.chatEmote, const EmotePayload('good_luck').toJson());
        async.flushMicrotasks();
        expect(b.of(MessageType.chatEmote), hasLength(1));
        h.hub.dispose();
      });
    });

    test('a cooldown push refuses queue.join and leaves the queue', () {
      fakeAsync((async) {
        final h = Harness(async);
        final a = h.connect('alice');
        a.send(MessageType.queueJoin, join.toJson());
        async.flushMicrotasks();
        expect(h.hub.matchmaker.isQueued('alice'), isTrue);
        final until = base ~/ 1000 + 3600;
        expect(h.hub.moderate(push('alice', cooldown: until)), isTrue);
        expect(h.hub.matchmaker.isQueued('alice'), isFalse);
        expect(a.errors, [ErrorCode.queueCooldown]);
        expect(a.of(MessageType.error).single.payload['message'], '$until');
        a.send(MessageType.queueJoin, join.toJson());
        async.flushMicrotasks();
        expect(a.errors, [ErrorCode.queueCooldown, ErrorCode.queueCooldown]);
        expect(h.hub.matchmaker.isQueued('alice'), isFalse);
        // Cleared by an admin: the queue is open again.
        h.hub.moderate(push('alice'));
        a.send(MessageType.queueJoin, join.toJson());
        async.flushMicrotasks();
        expect(h.hub.matchmaker.isQueued('alice'), isTrue);
        // Offline players are not touched (their next ticket carries it).
        expect(h.hub.moderate(push('carol', cooldown: until)), isFalse);
        h.hub.dispose();
      });
    });

    test('a ban push closes the socket and the match runs as a disconnect', () {
      fakeAsync((async) {
        final h = Harness(async);
        final (a, b) = h.match();
        final watcher = h.connect('dave');
        expect(h.hub.moderate(push('alice', banned: true)), isTrue);
        async.flushMicrotasks();
        expect(a.errors.last, ErrorCode.banned);
        expect((a.closeCode, a.closeReason), (CloseCode.policy, 'banned'));
        expect(b.closed, isFalse);
        expect(watcher.closed, isFalse);
        // A ticket issued before the ban is refused on reconnect.
        final again = h.connect('alice');
        expect(again.errors, [ErrorCode.banned]);
        expect(again.closeCode, CloseCode.policy);
        expect(again.of(MessageType.hello), isEmpty);
        // Nobody reconnects: Bob wins by abandonment after the grace.
        async.elapse(const Duration(seconds: 61));
        final result = h.results.results.single;
        expect(result.reason, MatchEndReason.abandoned);
        final bobSide = result.white.userId == 'bob' ? Side.white : Side.black;
        expect(result.winner, bobSide);
        // Unbanned: a fresh ticket is accepted again.
        h.hub.moderate(push('alice'));
        final back = h.connect('alice');
        expect(back.of(MessageType.hello), hasLength(1));
        h.hub.dispose();
      });
    });

    test(
      'a pushed state applies to tickets issued before it, then expires',
      () {
        fakeAsync((async) {
          final h = Harness(async);
          h.hub.moderate(push('alice', muted: true));
          final (a, b) = h.match();
          a.send(
            MessageType.chatEmote,
            const EmotePayload('good_luck').toJson(),
          );
          async.flushMicrotasks();
          expect(b.of(MessageType.chatEmote), isEmpty);
          h.hub.moderate(push('bob', banned: true));
          async.flushMicrotasks();
          async.elapse(Hub.moderationMemory + const Duration(seconds: 1));
          // Older pushes are forgotten: every valid ticket postdates them.
          expect(h.connect('bob').of(MessageType.hello), hasLength(1));
          h.hub.dispose();
        });
      },
    );
  });

  group('HTTP', () {
    late HttpServer server;
    late Hub hub;

    setUp(() async {
      hub = Hub(
        ticketSecret: secret,
        results: MemoryResultSink(),
        limits: const WsLimits(maxConnectionsPerIp: 1),
      );
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
      Uri.parse('http://localhost:${server.port}/internal/moderation'),
      headers: {
        'Content-Type': 'application/json',
        'X-Nard-Signature': signature ?? Signature.sign(body, secret),
      },
      body: body,
    );

    test('POST /internal/moderation is signed and applied', () async {
      final body = jsonEncode(push('alice', muted: true).toJson());
      final res = await post(body);
      expect(res.statusCode, 200);
      expect(jsonDecode(res.body), {'userId': 'alice', 'connected': false});
      expect((await post(body, signature: 'forged')).statusCode, 401);
      expect(
        (await post(
          body,
          signature: Signature.sign(body, 'x' * 40),
        )).statusCode,
        401,
      );
      expect((await post('[1]')).statusCode, 400);
      expect((await post('{"userId":"a"}')).statusCode, 400);
    });

    test(
      'a ban push reaches a real socket; extra connections get 429',
      () async {
        final ws = IOWebSocketChannel.connect(
          'ws://localhost:${server.port}/ws',
        );
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
                    expiresAt:
                        DateTime.now().millisecondsSinceEpoch ~/ 1000 + 60,
                  ),
                  secret,
                ),
              },
            ).toJson(),
          ),
        );
        expect(await frames.moveNext(), isTrue);
        // Same address, cap of one: refused before the upgrade.
        final second = await http.get(
          Uri.parse('http://localhost:${server.port}/ws'),
          headers: {
            'Connection': 'Upgrade',
            'Upgrade': 'websocket',
            'Sec-WebSocket-Version': '13',
            'Sec-WebSocket-Key': 'dGhlIHNhbXBsZSBub25jZQ==',
          },
        );
        expect(second.statusCode, 429);
        final res = await post(
          jsonEncode(push('alice', banned: true).toJson()),
        );
        expect(jsonDecode(res.body), {'userId': 'alice', 'connected': true});
        while (await frames.moveNext().timeout(const Duration(seconds: 5))) {}
        expect(ws.closeCode, CloseCode.policy);
      },
    );
  });
}

class _ConnectionInfo implements HttpConnectionInfo {
  _ConnectionInfo(this.remoteAddress);

  @override
  final InternetAddress remoteAddress;

  @override
  int get remotePort => 40000;

  @override
  int get localPort => 8080;
}
