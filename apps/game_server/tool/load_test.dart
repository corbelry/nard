// Load test against a running stack (docs/LOAD_TEST.md):
//   docker compose -f infra/docker-compose.yml up --build -d
//   (cd apps/game_server && dart run tool/load_test.dart --matches 100)
//
// Creates (or reuses) 2×M guest accounts through the API, gets a game
// ticket for each, and keeps M casual matches running between pairs of
// simulated clients for --duration seconds: after a match ends both players
// queue again. Each client plays with the easy heuristic bot after a
// --think delay. Measured: move round trip (intent sent → the game.state
// that applies it), ping round trip, matches started/completed, errors, and
// the game server's /metrics (memory, rooms, connections) sampled every 5 s.
// Clients are spread over --workers isolates so bot moves and JSON parsing
// on the client side do not distort the latencies.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:nard_ai/nard_ai.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';
import 'package:web_socket_channel/io.dart';

class Config {
  Config(Map<String, String> a)
    : api = Uri.parse(a['api'] ?? 'http://localhost:18000'),
      ws = a['ws'] ?? 'ws://localhost:18080/ws',
      metrics = Uri.parse(a['metrics'] ?? 'http://localhost:18080/metrics'),
      matches = int.parse(a['matches'] ?? '20'),
      duration = Duration(seconds: int.parse(a['duration'] ?? '120')),
      think = Duration(milliseconds: int.parse(a['think'] ?? '500')),
      ramp = Duration(seconds: int.parse(a['ramp'] ?? '10')),
      workers = int.parse(
        a['workers'] ?? '${min(8, Platform.numberOfProcessors)}',
      ),
      accounts = a['accounts'] ?? '.dart_tool/load_test_accounts.json',
      json = a['json'],
      deltas = a['deltas'] != 'false';

  final Uri api;
  final String ws;
  final Uri metrics;
  final int matches;
  final Duration duration;
  final Duration think;
  final Duration ramp;
  final int workers;
  final String accounts;
  final String? json;

  /// Announce `stateDelta` (ADR-048); `--deltas false` plays as an old
  /// client that gets full states.
  final bool deltas;
}

Future<void> main(List<String> args) async {
  final opts = <String, String>{};
  for (var i = 0; i < args.length; i++) {
    if (!args[i].startsWith('--')) continue;
    final key = args[i].substring(2);
    final eq = key.indexOf('=');
    if (eq > 0) {
      opts[key.substring(0, eq)] = key.substring(eq + 1);
    } else if (i + 1 < args.length) {
      opts[key] = args[++i];
    }
  }
  final cfg = Config(opts);
  final players = cfg.matches * 2;
  stdout.writeln(
    'load test: ${cfg.matches} concurrent matches ($players clients), '
    '${cfg.duration.inSeconds}s, think ${cfg.think.inMilliseconds}ms, '
    '${cfg.workers} workers, '
    '${cfg.deltas ? 'state deltas' : 'full states only'}',
  );
  final tokens = await _accounts(cfg, players);
  final before = await _scrape(cfg.metrics);
  final samples = <Map<String, num>>[];
  final sampler = Timer.periodic(const Duration(seconds: 5), (_) async {
    final m = await _scrape(cfg.metrics);
    if (m.isNotEmpty) samples.add(m);
  });
  final started = DateTime.now();
  final slices = List.generate(cfg.workers, (_) => <String>[]);
  for (var i = 0; i < tokens.length; i++) {
    slices[i % cfg.workers].add(tokens[i]);
  }
  final results = await Future.wait([
    for (var w = 0; w < cfg.workers; w++)
      Isolate.run(
        _job(
          w,
          slices[w],
          cfg.api.toString(),
          cfg.ws,
          cfg.duration.inMilliseconds,
          cfg.think.inMilliseconds,
          cfg.ramp.inMilliseconds,
          cfg.deltas,
        ),
      ),
  ]);
  sampler.cancel();
  final after = await _scrape(cfg.metrics);
  final elapsed = DateTime.now().difference(started);
  _report(cfg, results, before, after, samples, elapsed);
}

// ---- Accounts ---------------------------------------------------------------

/// Guest tokens from the cache file, topped up through `POST /auth/guest`.
/// That endpoint is throttled per IP (20/min); on 429 we wait.
Future<List<String>> _accounts(Config cfg, int n) async {
  final file = File(cfg.accounts);
  final tokens = <String>[
    if (file.existsSync())
      ...(jsonDecode(file.readAsStringSync()) as List).cast<String>(),
  ];
  final run = DateTime.now().millisecondsSinceEpoch;
  while (tokens.length < n) {
    final res = await http.post(
      cfg.api.resolve('/api/v1/auth/guest'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'deviceId': 'load-$run-${tokens.length}',
        'locale': 'en',
      }),
    );
    if (res.statusCode == 429) {
      final wait = int.tryParse(res.headers['retry-after'] ?? '') ?? 10;
      stdout.writeln(
        '  guest sign-up throttled; ${tokens.length}/$n, waiting ${wait}s',
      );
      file
        ..createSync(recursive: true)
        ..writeAsStringSync(jsonEncode(tokens));
      await Future<void>.delayed(Duration(seconds: wait));
      continue;
    }
    if (res.statusCode >= 300) {
      throw StateError('guest sign-up: ${res.statusCode} ${res.body}');
    }
    tokens.add((jsonDecode(res.body) as Map)['token'] as String);
  }
  file
    ..createSync(recursive: true)
    ..writeAsStringSync(jsonEncode(tokens));
  return tokens.sublist(0, n);
}

Future<Map<String, num>> _scrape(Uri url) async {
  try {
    final res = await http.get(url).timeout(const Duration(seconds: 3));
    final out = <String, num>{};
    for (final line in const LineSplitter().convert(res.body)) {
      if (line.isEmpty || line.startsWith('#')) continue;
      final at = line.lastIndexOf(' ');
      final v = num.tryParse(line.substring(at + 1));
      if (v != null) out[line.substring(0, at)] = v;
    }
    return out;
  } on Object {
    return const {};
  }
}

// ---- Worker isolate ----------------------------------------------------------

/// A closure over plain values only, so it can be sent to an isolate.
Future<Map<String, Object>> Function() _job(
  int index,
  List<String> tokens,
  String api,
  String ws,
  int durationMs,
  int thinkMs,
  int rampMs,
  bool deltas,
) => () => _worker(index, tokens, api, ws, durationMs, thinkMs, rampMs, deltas);

/// Plays with [tokens] until the duration is over and returns raw stats.
Future<Map<String, Object>> _worker(
  int index,
  List<String> tokens,
  String api,
  String ws,
  int durationMs,
  int thinkMs,
  int rampMs,
  bool deltas,
) async {
  final stats = Stats();
  final deadline = DateTime.now().millisecondsSinceEpoch + durationMs;
  final clients = <SimClient>[];
  for (var i = 0; i < tokens.length; i++) {
    final ticket = await _ticket(Uri.parse(api), tokens[i], stats);
    if (ticket == null) continue;
    final c = SimClient(
      'w$index-$i',
      ticket,
      ws,
      stats,
      deadline,
      Duration(milliseconds: thinkMs),
      Random(index * 100000 + i),
      deltas: deltas,
    );
    clients.add(c);
    // Spread connections over the ramp-up.
    final delay = rampMs ~/ max(1, tokens.length);
    unawaited(Future<void>.delayed(Duration(milliseconds: delay * i), c.start));
  }
  await Future.wait(clients.map((c) => c.finished.future));
  return stats.toJson();
}

Future<String?> _ticket(Uri api, String token, Stats stats) async {
  for (var attempt = 0; attempt < 5; attempt++) {
    try {
      final res = await http.post(
        api.resolve('/api/v1/game/ticket'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        return (jsonDecode(res.body) as Map)['ticket'] as String;
      }
      if (res.statusCode != 429 && res.statusCode < 500) {
        stats.error('ticket_${res.statusCode}');
        return null;
      }
    } on Object {
      // retry
    }
    await Future<void>.delayed(Duration(seconds: 1 + attempt));
  }
  stats.error('ticket_failed');
  return null;
}

class Stats {
  final moveMs = <int>[];
  final pingMs = <int>[];

  /// Size (characters of the JSON frame) of every `game.state` received.
  final stateBytes = <int>[];

  /// `game.state` frames that were deltas (ADR-048).
  int stateDeltas = 0;
  final matchMs = <int>[];
  final errors = <String, int>{};
  int connected = 0;
  int matchesFound = 0;
  int matchesCompleted = 0;
  int botMatches = 0;
  int stalled = 0;
  int framesIn = 0;
  int framesOut = 0;
  int bytesIn = 0;

  void error(String code) => errors[code] = (errors[code] ?? 0) + 1;

  Map<String, Object> toJson() => {
    'moveMs': moveMs,
    'pingMs': pingMs,
    'stateBytes': stateBytes,
    'stateDeltas': stateDeltas,
    'matchMs': matchMs,
    'errors': errors,
    'connected': connected,
    'matchesFound': matchesFound,
    'matchesCompleted': matchesCompleted,
    'botMatches': botMatches,
    'stalled': stalled,
    'framesIn': framesIn,
    'framesOut': framesOut,
    'bytesIn': bytesIn,
  };
}

/// One simulated player: queue → play → queue again until the deadline.
class SimClient {
  SimClient(
    this.name,
    this.ticket,
    this.ws,
    this.stats,
    this.deadline,
    this.think,
    this.random, {
    this.deltas = true,
  }) : bot = HeuristicBot(BotLevel.easy, random: random);

  final String name;
  final String ticket;
  final String ws;
  final Stats stats;
  final int deadline;
  final Duration think;
  final Random random;
  final bool deltas;
  final HeuristicBot bot;
  final _sync = GameStateSync();
  final finished = Completer<void>();
  late final IOWebSocketChannel _socket;
  int _id = 0;
  Side? _side;
  int _seq = -1;
  int _actedSeq = -1;
  int _matchStarted = 0;
  bool _closed = false;
  Timer? _act;
  Timer? _pinger;
  Timer? _watchdog;
  GameStatePayload? _state;

  /// The intent waiting for its state: (sent at, kind).
  (int, String)? _awaiting;
  final _pings = <String, int>{};

  static int get _now => DateTime.now().millisecondsSinceEpoch;
  bool get _running => _now < deadline;

  void start() {
    try {
      _socket = IOWebSocketChannel.connect(
        ws,
        connectTimeout: const Duration(seconds: 10),
      );
    } on Object {
      stats.error('connect');
      _finish();
      return;
    }
    _socket.stream.listen(
      _onFrame,
      onError: (_) {
        stats.error('socket');
        _finish();
      },
      onDone: _finish,
    );
    _send(
      MessageType.auth,
      AuthPayload(
        ticket,
        features: {if (deltas) ProtocolFeature.stateDelta},
      ).toJson(),
    );
    // Clients still waiting in the queue at the deadline stop.
    Timer(Duration(milliseconds: max(0, deadline - _now)), () {
      if (_side == null) _close();
    });
    _pinger = Timer.periodic(const Duration(seconds: 5), (_) {
      final id = '$name-p${_id++}';
      _pings[id] = _now;
      _send(MessageType.ping, const {}, id);
    });
  }

  void _send(
    String type, [
    Map<String, Object?> payload = const {},
    String? id,
  ]) {
    if (_closed) return;
    stats.framesOut++;
    _socket.sink.add(
      jsonEncode(
        Envelope(
          type: type,
          id: id ?? '$name-${_id++}',
          ts: 0,
          payload: payload,
        ).toJson(),
      ),
    );
  }

  void _queue() => _send(
    MessageType.queueJoin,
    const QueueJoinPayload(
      variant: Variant.shortNard,
      matchLength: 1,
      mode: QueueMode.casual,
    ).toJson(),
  );

  void _onFrame(Object? frame) {
    final now = _now;
    stats.framesIn++;
    stats.bytesIn += (frame as String).length;
    final msg = Envelope.fromJson(jsonDecode(frame));
    switch (msg.type) {
      case MessageType.pong:
        final sent = _pings.remove(msg.id);
        if (sent != null) stats.pingMs.add(now - sent);
      case MessageType.hello:
        stats.connected++;
        _queue();
      case MessageType.matchFound:
        final found = MatchFoundPayload.fromJson(msg.payload);
        _side = found.you;
        _seq = -1;
        _actedSeq = -1;
        _sync.reset();
        _matchStarted = now;
        stats.matchesFound++;
        if (found.white.bot || found.black.bot) stats.botMatches++;
        _send(MessageType.gameSeed, SeedPayload('$name-$now').toJson());
        _armWatchdog();
      case MessageType.gameState:
        stats.stateBytes.add(frame.length);
        final f = GameStateFrame.fromJson(msg.payload);
        if (f is GameStateDelta) stats.stateDeltas++;
        final s = _sync.accept(
          f,
          onGap: () {
            // Never expected on one socket: counted, then resynced.
            stats.error('state_gap');
            _send(MessageType.gameSync, {'matchId': f.matchId});
          },
        );
        if (s != null) _onState(s, now);
      case MessageType.error:
        stats.error('${msg.payload['code']}');
    }
  }

  void _armWatchdog() {
    _watchdog?.cancel();
    _watchdog = Timer(const Duration(seconds: 90), () {
      stats.stalled++;
      _side = null;
      if (_running) {
        _queue();
      } else {
        _close();
      }
    });
  }

  void _onState(GameStatePayload s, int now) {
    if (s.seq <= _seq) return;
    _seq = s.seq;
    _state = s;
    final game = s.state;
    final me = _side;
    if (me == null) return;
    _armWatchdog();
    final waiting = _awaiting;
    if (waiting != null) {
      final (sentAt, kind) = waiting;
      final applied = switch (kind) {
        'roll' => game.phase != GamePhase.awaitingRoll || game.turn != me,
        _ => game.phase != GamePhase.awaitingMove || game.turn != me,
      };
      if (applied || game.isOver) {
        stats.moveMs.add(now - sentAt);
        _awaiting = null;
      }
    }
    if (game.isOver) {
      // Match length 1: the first finished game ends the match.
      stats.matchesCompleted++;
      stats.matchMs.add(now - _matchStarted);
      _side = null;
      _watchdog?.cancel();
      _act?.cancel();
      if (_running) {
        Timer(Duration(milliseconds: 500 + random.nextInt(1000)), _queue);
      } else {
        _close();
      }
      return;
    }
    if (s.seq <= _actedSeq) return;
    final mine = switch (game.phase) {
      GamePhase.awaitingRoll => game.turn == me,
      GamePhase.awaitingMove =>
        game.turn == me && s.pending.isEmpty && !game.mustPass,
      GamePhase.cubeOffered => game.turn != me,
      _ => false,
    };
    if (!mine) return;
    _actedSeq = s.seq;
    _act?.cancel();
    final jitter = think.inMilliseconds ~/ 2;
    _act = Timer(
      Duration(
        milliseconds:
            think.inMilliseconds - jitter + random.nextInt(2 * jitter + 1),
      ),
      () => _play(s.seq),
    );
  }

  void _play(int seq) {
    final s = _state;
    final me = _side;
    if (s == null || me == null || s.seq != seq) return;
    final game = s.state;
    switch (game.phase) {
      case GamePhase.awaitingRoll:
        _awaiting = (_now, 'roll');
        _send(MessageType.gameRoll);
      case GamePhase.awaitingMove:
        final turn = bot.chooseTurn(game.rules, game.board, game.dice!);
        for (final m in turn.moves) {
          _send(
            MessageType.gameMove,
            MovePayload(m.from, m.to, die: m.die).toJson(),
          );
        }
        _awaiting = (_now, 'turn');
        _send(MessageType.gameConfirmTurn);
      case GamePhase.cubeOffered:
        _send(MessageType.cubeTake);
      default:
        break;
    }
  }

  void _close() {
    if (_closed) return;
    _closed = true;
    _pinger?.cancel();
    _act?.cancel();
    _watchdog?.cancel();
    unawaited(_socket.sink.close());
  }

  void _finish() {
    _closed = true;
    _pinger?.cancel();
    _act?.cancel();
    _watchdog?.cancel();
    if (!finished.isCompleted) finished.complete();
  }
}

// ---- Report ----------------------------------------------------------------

int _pct(List<int> sorted, double p) =>
    sorted.isEmpty
        ? 0
        : sorted[min(sorted.length - 1, (p * sorted.length).floor())];

void _report(
  Config cfg,
  List<Map<String, Object>> parts,
  Map<String, num> before,
  Map<String, num> after,
  List<Map<String, num>> samples,
  Duration elapsed,
) {
  List<int> all(String k) =>
      [for (final p in parts) ...(p[k]! as List).cast<int>()]..sort();
  int sum(String k) => parts.fold(0, (a, p) => a + (p[k]! as int));
  final errors = <String, int>{};
  for (final p in parts) {
    (p['errors']! as Map).forEach(
      (k, v) => errors[k as String] = (errors[k] ?? 0) + (v as int),
    );
  }
  final move = all('moveMs');
  final ping = all('pingMs');
  final match = all('matchMs');
  final stateBytes = all('stateBytes');
  num peak(String k) => samples.fold<num>(0, (a, s) => max(a, s[k] ?? 0));
  num delta(String prefix) {
    num total(Map<String, num> m) => m.entries
        .where((e) => e.key == prefix || e.key.startsWith('$prefix{'))
        .fold<num>(0, (a, e) => a + e.value);
    return total(after) - total(before);
  }

  final secs = elapsed.inMilliseconds / 1000;
  final summary = <String, Object>{
    'matches': cfg.matches,
    'clients': cfg.matches * 2,
    'durationS': cfg.duration.inSeconds,
    'elapsedS': secs,
    'thinkMs': cfg.think.inMilliseconds,
    'connected': sum('connected'),
    'matchesStarted': sum('matchesFound') ~/ 2,
    'matchesCompleted': sum('matchesCompleted') ~/ 2,
    'botMatches': sum('botMatches'),
    'stalledClients': sum('stalled'),
    'errors': errors,
    'moveRttMs': {
      'n': move.length,
      'p50': _pct(move, .5),
      'p95': _pct(move, .95),
      'p99': _pct(move, .99),
      'max': move.isEmpty ? 0 : move.last,
    },
    'pingRttMs': {
      'n': ping.length,
      'p50': _pct(ping, .5),
      'p95': _pct(ping, .95),
      'p99': _pct(ping, .99),
      'max': ping.isEmpty ? 0 : ping.last,
    },
    'matchDurationS': {
      'p50': _pct(match, .5) / 1000,
      'p95': _pct(match, .95) / 1000,
    },
    'gameStateBytes': {
      'n': stateBytes.length,
      'avg':
          stateBytes.isEmpty
              ? 0
              : (stateBytes.fold<int>(0, (a, b) => a + b) / stateBytes.length)
                  .round(),
      'p50': _pct(stateBytes, .5),
      'p95': _pct(stateBytes, .95),
      'max': stateBytes.isEmpty ? 0 : stateBytes.last,
      'deltas': sum('stateDeltas'),
    },
    'clientFramesInPerS': (sum('framesIn') / secs).round(),
    'clientFramesOutPerS': (sum('framesOut') / secs).round(),
    'clientMBIn': (sum('bytesIn') / 1e6).toStringAsFixed(1),
    'server': {
      'peakRssMB': (peak('process_resident_memory_bytes') / 1e6).round(),
      'maxRssMB':
          ((after['process_max_resident_memory_bytes'] ?? 0) / 1e6).round(),
      'rssAfterMB':
          ((after['process_resident_memory_bytes'] ?? 0) / 1e6).round(),
      'peakRooms': peak('nard_rooms_active'),
      'peakConnections': peak('nard_ws_connections'),
      'matchesStarted': delta('nard_matches_started_total'),
      'matchesFinished': delta('nard_matches_finished_total'),
      'resultsReported': delta('nard_results_reported_total'),
      'resultsFailed': delta('nard_results_failed_total'),
      'resultRetries': delta('nard_results_retries_total'),
      'messagesInPerS':
          (delta('nard_ws_messages_received_total') / secs).round(),
      'messagesOutPerS': (delta('nard_ws_messages_sent_total') / secs).round(),
      'internalErrors': delta('nard_internal_errors_total'),
      'handleP99Bucket': _histogramP(
        after,
        before,
        'nard_room_handle_seconds',
        .99,
      ),
    },
  };
  const encoder = JsonEncoder.withIndent('  ');
  stdout.writeln(encoder.convert(summary));
  final out = cfg.json;
  if (out != null) File(out).writeAsStringSync(encoder.convert(summary));
  // Non-zero exit for CI: nothing finished, clients stalled or server bugs.
  final failed =
      sum('matchesCompleted') == 0 ||
      sum('stalled') > 0 ||
      delta('nard_internal_errors_total') > 0;
  if (failed) {
    stderr.writeln('load test FAILED');
    exitCode = 1;
  }
}

/// Upper bound (seconds) of the bucket holding quantile [q] over all
/// intent types, from the delta between two scrapes.
String _histogramP(
  Map<String, num> after,
  Map<String, num> before,
  String name,
  double q,
) {
  final buckets = <String, num>{};
  for (final e in after.entries) {
    if (!e.key.startsWith('${name}_bucket{')) continue;
    final le = RegExp(r'le="([^"]+)"').firstMatch(e.key)!.group(1)!;
    buckets[le] = (buckets[le] ?? 0) + e.value - (before[e.key] ?? 0);
  }
  if (buckets.isEmpty) return 'n/a';
  final total = buckets['+Inf'] ?? 0;
  if (total == 0) return 'n/a';
  final les =
      buckets.keys.where((k) => k != '+Inf').toList()
        ..sort((a, b) => double.parse(a).compareTo(double.parse(b)));
  for (final le in les) {
    if (buckets[le]! >= q * total) return '≤${le}s';
  }
  return '>${les.last}s';
}
