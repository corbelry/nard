import 'dart:convert';

import 'package:game_server/src/http_result_sink.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';
import 'package:test/test.dart';

const result = MatchResult(
  matchId: 'm1',
  variant: Variant.shortNard,
  matchLength: 1,
  mode: QueueMode.casual,
  white: PlayerInfo(userId: '1', name: 'A'),
  black: PlayerInfo(userId: 'bot', name: 'Bot', bot: true),
  winner: Side.white,
  whiteScore: 1,
  blackScore: 0,
  reason: MatchEndReason.completed,
  games: [],
  startedAt: 0,
  endedAt: 1,
);

void main() {
  test('posts a signed result and retries server errors', () async {
    final seen = <http.Request>[];
    var calls = 0;
    final sink = HttpResultSink(
      apiUrl: Uri.parse('http://api:8000'),
      secret: 's' * 32,
      backoff: Duration.zero,
      log: (_) {},
      client: MockClient((req) async {
        seen.add(req);
        return http.Response('', ++calls < 3 ? 503 : 201);
      }),
    );
    await sink.report(result);
    expect(calls, 3);
    final req = seen.last;
    expect(req.url.path, '/api/v1/internal/match-results');
    expect(
      req.headers['X-Nard-Signature'],
      HttpResultSink.signature(req.body, 's' * 32),
    );
    expect((jsonDecode(req.body) as Map<String, Object?>)['matchId'], 'm1');
  });

  test('client errors are not retried; network errors are', () async {
    var calls = 0;
    final logs = <String>[];
    await HttpResultSink(
      apiUrl: Uri.parse('http://api:8000'),
      secret: 's' * 32,
      backoff: Duration.zero,
      log: logs.add,
      client: MockClient((_) async {
        calls++;
        return http.Response('{"code":"bad"}', 422);
      }),
    ).report(result);
    expect(calls, 1);
    calls = 0;
    await HttpResultSink(
      apiUrl: Uri.parse('http://api:8000'),
      secret: 's' * 32,
      attempts: 2,
      backoff: Duration.zero,
      log: logs.add,
      client: MockClient((_) async {
        calls++;
        throw http.ClientException('down');
      }),
    ).report(result);
    expect(calls, 2);
    expect(logs.last, contains('lost'));
  });
}
