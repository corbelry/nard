import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:game_server/server.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:test/test.dart';
import 'package:web_socket_channel/io.dart';

const secret = 'test-secret-test-secret-test-secret!';

class RecordingReporter implements ErrorReporter {
  final events = <(Object, Map<String, Object?>)>[];

  @override
  void capture(
    Object error,
    StackTrace? stack, {
    Map<String, Object?> context = const {},
  }) => events.add((error, context));
}

/// Samples of one metric, keyed by their label text (`{mode="casual"}`).
Map<String, num> samples(String text, String name) => {
  for (final line in const LineSplitter().convert(text))
    if (line.startsWith('$name{') || line.startsWith('$name '))
      line.substring(name.length, line.lastIndexOf(' ')): num.parse(
        line.substring(line.lastIndexOf(' ') + 1),
      ),
};

void main() {
  group('Metrics', () {
    test('renders counters, labelled gauges and histograms', () {
      final m = Metrics();
      final c = m.counter('jobs_total', 'Jobs.');
      c.inc();
      c.inc({'kind': 'a"b\\c\nd'}, 2);
      m
        ..gauge('up', 'Up.', () => 1)
        ..gauges(
          'queue',
          'Queue.',
          () => {
            {'queue': 'shortNard/1/casual'}: 3,
          },
        );
      m.histogram('lat_seconds', 'Latency.', const [0.01, 0.1])
        ..observe(0.005)
        ..observe(0.05)
        ..observe(2);
      final text = m.render();
      expect(
        text,
        contains('# HELP jobs_total Jobs.\n# TYPE jobs_total counter'),
      );
      expect(text, contains('jobs_total 1\n'));
      expect(text, contains(r'jobs_total{kind="a\"b\\c\nd"} 2'));
      expect(text, contains('# TYPE up gauge\nup 1\n'));
      expect(text, contains('queue{queue="shortNard/1/casual"} 3'));
      expect(text, contains('# TYPE lat_seconds histogram'));
      expect(text, contains('lat_seconds_bucket{le="0.01"} 1'));
      expect(text, contains('lat_seconds_bucket{le="0.1"} 2'));
      expect(text, contains('lat_seconds_bucket{le="+Inf"} 3'));
      expect(text, contains('lat_seconds_sum 2.055'));
      expect(text, contains('lat_seconds_count 3'));
      expect(c.value({'kind': 'a"b\\c\nd'}), 2);
    });

    test('an unused counter renders as zero; names are registered once', () {
      final m = Metrics();
      final a = m.counter('x_total', 'X.');
      expect(identical(a, m.counter('x_total', 'X.')), isTrue);
      expect(m.render(), contains('x_total 0\n'));
    });

    test('process metrics report memory', () {
      final m = Metrics()..addProcessMetrics();
      final rss = samples(m.render(), 'process_resident_memory_bytes');
      expect(rss.values.single, greaterThan(0));
    });
  });

  group('Logger', () {
    test('writes one JSON line with level, ts, msg and fields', () {
      final lines = <String>[];
      final log = Logger(
        write: lines.add,
        clock: () => DateTime.utc(2026, 11, 7, 12),
      );
      log.info('match started', {'matchId': 'm1', 'msg': 'not overridden'});
      log.debug('hidden');
      final line = jsonDecode(lines.single) as Map<String, Object?>;
      expect(line.keys.take(3), ['level', 'ts', 'msg']);
      expect(line, {
        'matchId': 'm1',
        'level': 'info',
        'ts': '2026-11-07T12:00:00.000Z',
        'msg': 'match started',
      });
      expect(LogLevel.parse('WARNING'), LogLevel.warn);
      expect(LogLevel.parse(null), LogLevel.info);
    });

    test('request logger logs requests and turns errors into 500s', () async {
      final lines = <String>[];
      final errors = RecordingReporter();
      final handler = const Pipeline()
          .addMiddleware(
            jsonRequestLogger(Logger(write: lines.add), errors: errors),
          )
          .addHandler((req) {
            if (req.url.path == 'boom') throw StateError('boom');
            return Response(204);
          });
      final ok = await handler(Request('GET', Uri.parse('http://x/ok')));
      expect(ok.statusCode, 204);
      final failed = await handler(Request('GET', Uri.parse('http://x/boom')));
      expect(failed.statusCode, 500);
      final logged = [
        for (final l in lines) jsonDecode(l) as Map<String, Object?>,
      ];
      expect(logged[0]['msg'], 'http request');
      expect(logged[0]['path'], '/ok');
      expect(logged[0]['status'], 204);
      expect(logged[0]['durationMs'], isA<num>());
      expect(logged[1]['level'], 'error');
      expect(logged[1]['status'], 500);
      expect(errors.events.single.$1, isA<StateError>());
      expect(errors.events.single.$2, {'path': '/boom'});
    });
  });

  group('SentryReporter', () {
    test('parses the DSN and posts an event with the auth header', () async {
      final seen = <http.Request>[];
      final reporter =
          SentryReporter.fromDsn(
            'https://pubkey@o1.ingest.example.com/42',
            environment: 'staging',
            client: MockClient((req) async {
              seen.add(req);
              return http.Response('{}', 200);
            }),
          )!;
      expect(
        reporter.endpoint.toString(),
        'https://o1.ingest.example.com/api/42/store/',
      );
      reporter.capture(
        StateError('bad'),
        StackTrace.current,
        context: {'matchId': 'm1'},
      );
      await Future<void>.delayed(Duration.zero);
      final req = seen.single;
      expect(req.headers['X-Sentry-Auth'], contains('sentry_key=pubkey'));
      final event = jsonDecode(req.body) as Map<String, Object?>;
      expect(event['environment'], 'staging');
      expect(event['event_id'], matches(RegExp(r'^[0-9a-f]{32}$')));
      final value =
          ((event['exception']! as Map)['values'] as List).single as Map;
      expect(value['type'], 'StateError');
      expect((event['extra']! as Map)['matchId'], 'm1');
    });

    test('invalid DSNs are refused; events are capped per minute', () async {
      expect(SentryReporter.fromDsn('not a dsn'), isNull);
      expect(SentryReporter.fromDsn('https://o1.example.com/42'), isNull);
      var now = 0;
      var posts = 0;
      final failures = <String>[];
      final reporter =
          SentryReporter.fromDsn(
            'https://k@sentry.example.com/prefix/7',
            perMinute: 2,
            now: () => now,
            onFailure: failures.add,
            client: MockClient((_) async {
              posts++;
              return http.Response('', 429);
            }),
          )!;
      expect(
        reporter.endpoint.toString(),
        'https://sentry.example.com/prefix/api/7/store/',
      );
      for (var i = 0; i < 5; i++) {
        reporter.capture('e$i', null);
      }
      now = 60000;
      reporter.capture('later', null);
      await Future<void>.delayed(Duration.zero);
      expect(posts, 3);
      expect(failures, everyElement(contains('429')));
    });
  });

  group('HTTP endpoints', () {
    late HttpServer server;
    late Hub hub;
    var ready = false;

    setUp(() async {
      ready = false;
      hub = Hub(ticketSecret: secret, results: MemoryResultSink());
      server = await io.serve(
        buildHandler(hub, ready: () => ready),
        InternetAddress.loopbackIPv4,
        0,
      );
    });

    tearDown(() async {
      hub.dispose();
      await server.close(force: true);
    });

    Uri url(String path) => Uri.parse('http://localhost:${server.port}$path');

    test('/readyz follows the readiness flag', () async {
      expect((await http.get(url('/readyz'))).statusCode, 503);
      ready = true;
      final res = await http.get(url('/readyz'));
      expect(res.statusCode, 200);
      expect(res.body, 'ready');
    });

    test('/metrics counts connections, queues, matches and intents', () async {
      final a = _Client(server.port)..auth('alice');
      final b = _Client(server.port)..auth('bob');
      await a.next(MessageType.hello);
      await b.next(MessageType.hello);
      a.send(
        MessageType.queueJoin,
        const QueueJoinPayload(
          variant: Variant.longNard,
          matchLength: 3,
          mode: QueueMode.ranked,
        ).toJson(),
      );
      // A malformed frame and a forged ticket.
      b.ws.sink.add('garbage');
      await b.next(MessageType.error);
      b.send(MessageType.auth, {'ticket': 'forged'});
      await b.next(MessageType.error);
      b.auth('bob');
      await b.next(MessageType.hello);

      var text = (await http.get(url('/metrics'))).body;
      expect(samples(text, 'nard_ws_connections'), {'': 2});
      expect(samples(text, 'nard_ws_authenticated_users'), {'': 2});
      expect(samples(text, 'nard_queue_size'), {
        '{queue="longNard/3/ranked/rapid"}': 1,
      });
      expect(samples(text, 'nard_ws_auth_failures_total'), {'': 1});
      expect(samples(text, 'nard_ws_errors_sent_total'), {
        '{code="bad_request"}': 1,
        '{code="unauthorized"}': 1,
      });

      // A casual match, resigned after the opening roll.
      a.send(MessageType.queueLeave);
      const casual = QueueJoinPayload(
        variant: Variant.shortNard,
        matchLength: 1,
        mode: QueueMode.casual,
      );
      a.send(MessageType.queueJoin, casual.toJson());
      b.send(MessageType.queueJoin, casual.toJson());
      await a.next(MessageType.matchFound);
      await b.next(MessageType.matchFound);
      text = (await http.get(url('/metrics'))).body;
      expect(samples(text, 'nard_rooms_active'), {'': 1});
      expect(samples(text, 'nard_matches_started_total'), {
        '{mode="casual"}': 1,
      });
      a.send(MessageType.gameSeed, const SeedPayload('sa').toJson());
      b.send(MessageType.gameSeed, const SeedPayload('sb').toJson());
      GameStatePayload s;
      do {
        s = GameStatePayload.fromJson(
          (await a.next(MessageType.gameState)).payload,
        );
      } while (s.state.phase == GamePhase.opening);
      a.send(MessageType.gameResign, {'kind': 'single'});
      do {
        s = GameStatePayload.fromJson(
          (await a.next(MessageType.gameState)).payload,
        );
      } while (!s.state.isOver);
      text = (await http.get(url('/metrics'))).body;
      expect(samples(text, 'nard_rooms_active'), {'': 0});
      expect(samples(text, 'nard_matches_finished_total'), {
        '{mode="casual",reason="resigned"}': 1,
      });
      expect(
        samples(text, 'nard_room_handle_seconds_count')['{type="game.resign"}'],
        1,
      );
      // alice 6 frames, bob 6 (two auths, garbage, forged ticket, join, seed).
      expect(samples(text, 'nard_ws_messages_received_total')[''], 12);
      await a.ws.sink.close();
      await b.ws.sink.close();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      text = (await http.get(url('/metrics'))).body;
      expect(samples(text, 'nard_ws_connections'), {'': 0});
    });
  });
}

class _Client {
  _Client(int port)
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
