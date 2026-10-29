// End-to-end check against the docker compose stack:
//   docker compose -f infra/docker-compose.yml up --build -d
//   (cd apps/game_server && dart run tool/e2e.dart)
// Two guests get tickets from the API, queue for a ranked game, play it
// on the game server with the heuristic bot, and the API records the
// match and the rating change. Also signs in by e-mail through Mailpit.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:nard_ai/nard_ai.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';
import 'package:web_socket_channel/io.dart';

final api = Uri.parse(Platform.environment['API'] ?? 'http://localhost:18000');
final ws = Platform.environment['WS'] ?? 'ws://localhost:18080/ws';
final mailpit = Uri.parse(
  Platform.environment['MAILPIT'] ?? 'http://localhost:18025',
);

Future<Map<String, Object?>> call(
  String method,
  String path, {
  String? token,
  Map<String, Object?>? body,
}) async {
  final req = http.Request(method, api.resolve(path))
    ..headers.addAll({
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
  if (body != null) req.body = jsonEncode(body);
  final res = await http.Response.fromStream(await req.send());
  if (res.statusCode >= 300) {
    throw StateError('$method $path → ${res.statusCode} ${res.body}');
  }
  return jsonDecode(res.body) as Map<String, Object?>;
}

class Player {
  Player(this.name, this.token);

  final String name;
  final String token;
  late final IOWebSocketChannel socket;
  final bot = HeuristicBot(BotLevel.easy);
  final done = Completer<GameStatePayload>();
  Side? side;
  int _id = 0;
  int _actedSeq = -1;

  void send(String type, [Map<String, Object?> payload = const {}]) =>
      socket.sink.add(
        jsonEncode(
          Envelope(
            type: type,
            id: '$name${_id++}',
            ts: 0,
            payload: payload,
          ).toJson(),
        ),
      );

  Future<void> connect(String ticket, QueueJoinPayload queue) async {
    socket = IOWebSocketChannel.connect(ws);
    socket.stream.listen((frame) {
      final msg = Envelope.fromJson(jsonDecode(frame as String));
      switch (msg.type) {
        case MessageType.hello:
          send(MessageType.queueJoin, queue.toJson());
        case MessageType.matchFound:
          side = MatchFoundPayload.fromJson(msg.payload).you;
          send(MessageType.gameSeed, SeedPayload('$name-seed').toJson());
        case MessageType.gameState:
          _onState(GameStatePayload.fromJson(msg.payload));
        case MessageType.error:
          stderr.writeln('$name error: ${msg.payload}');
      }
    });
    send(MessageType.auth, {'ticket': ticket});
  }

  void _onState(GameStatePayload s) {
    final game = s.state;
    if (game.isOver) {
      if (!done.isCompleted) done.complete(s);
      return;
    }
    final me = side;
    if (me == null || s.seq <= _actedSeq) return;
    switch (game.phase) {
      case GamePhase.awaitingRoll when game.turn == me:
        _actedSeq = s.seq;
        send(MessageType.gameRoll);
      case GamePhase.awaitingMove
          when game.turn == me && s.pending.isEmpty && !game.mustPass:
        _actedSeq = s.seq;
        final turn = bot.chooseTurn(game.rules, game.board, game.dice!);
        for (final m in turn.moves) {
          send(
            MessageType.gameMove,
            MovePayload(m.from, m.to, die: m.die).toJson(),
          );
        }
        send(MessageType.gameConfirmTurn);
      case GamePhase.cubeOffered when game.turn != me:
        _actedSeq = s.seq;
        send(MessageType.cubeTake);
      default:
        break;
    }
  }
}

Future<void> main() async {
  final run = DateTime.now().millisecondsSinceEpoch;
  stdout.writeln('1. guests and tickets');
  final players = <Player>[];
  for (final n in ['a', 'b']) {
    final guest = await call(
      'POST',
      '/api/v1/auth/guest',
      body: {'deviceId': 'e2e-$n-$run', 'locale': 'en'},
    );
    players.add(Player(n, guest['token']! as String));
  }
  const queue = QueueJoinPayload(
    variant: Variant.shortNard,
    matchLength: 1,
    mode: QueueMode.ranked,
  );
  for (final p in players) {
    final t = await call('POST', '/api/v1/game/ticket', token: p.token);
    await p.connect(t['ticket']! as String, queue);
  }
  stdout.writeln('2. ranked game on the game server');
  final finals = await Future.wait(
    players.map((p) => p.done.future.timeout(const Duration(minutes: 3))),
  );
  final last = finals.first;
  stdout.writeln(
    '   ${last.record.actions.length} actions, winner '
    '${last.state.result!.winner.name}, seed revealed: '
    '${last.serverSeed != null}',
  );
  if (!FairDice.verifyCommitment(last.serverSeed!, last.commitment)) {
    throw StateError('commitment mismatch');
  }
  stdout.writeln('3. API recorded the match and the ratings');
  Map<String, Object?>? match;
  for (var i = 0; i < 20 && match == null; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final list =
        (await call(
              'GET',
              '/api/v1/me/matches',
              token: players[0].token,
            ))['matches']!
            as List;
    if (list.isNotEmpty) match = list.first as Map<String, Object?>;
  }
  if (match == null) throw StateError('match not recorded');
  final me = await call('GET', '/api/v1/me', token: players[0].token);
  final rating = ((me['user']! as Map)['ratings'] as Map)['shortNard'];
  stdout.writeln(
    '   match ${match['id']} reason ${match['reason']}; rating $rating',
  );
  if (rating == null) throw StateError('rating missing');

  stdout.writeln('4. e-mail sign-in through Mailpit');
  final email = 'e2e-$run@example.com';
  await call('POST', '/api/v1/auth/email/start', body: {'email': email});
  String? code;
  for (var i = 0; i < 20 && code == null; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final res = await http.get(
      mailpit.resolve(
        '/api/v1/search?query=${Uri.encodeComponent('to:$email')}',
      ),
    );
    final messages = (jsonDecode(res.body) as Map)['messages'] as List;
    if (messages.isNotEmpty) {
      final subject = (messages.first as Map)['Subject'] as String;
      code = RegExp(r'\d{6}').firstMatch(subject)?.group(0);
    }
  }
  if (code == null) throw StateError('no code e-mail');
  final signedIn = await call(
    'POST',
    '/api/v1/auth/email/verify',
    body: {'email': email, 'code': code},
  );
  stdout.writeln('   signed in as ${(signedIn['user']! as Map)['email']}');
  for (final p in players) {
    await p.socket.sink.close();
  }
  stdout.writeln('OK');
}
