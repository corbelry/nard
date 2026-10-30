import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:nard_ai/nard_ai.dart';
import 'package:nard_core/nard_core.dart';
import 'package:test/test.dart';

/// Records one full game between [white] and [black] with seeded dice, the
/// way the game server stores it (GameRecord JSON).
Map<String, Object?> recordGame(
  RuleSet rules,
  Variant variant,
  Bot white,
  Bot black,
  Random dice,
) {
  var record = GameRecord(variant: variant);
  var state = GameState.newGame(rules);
  int die() => dice.nextInt(6) + 1;
  for (var i = 0; i < 4000 && !state.isOver; i++) {
    final GameAction action;
    switch (state.phase) {
      case GamePhase.opening:
        final w = die();
        var b = die();
        while (b == w) {
          b = die();
        }
        action = OpeningRoll(w, b);
      case GamePhase.awaitingRoll:
        action = RollDice(state.turn, DiceRoll(die(), die()));
      case GamePhase.awaitingMove:
        final bot = state.turn == Side.white ? white : black;
        action = PlayTurn(
          state.turn,
          bot.chooseTurn(rules, state.board, state.dice!).moves,
        );
      case GamePhase.cubeOffered || GamePhase.over:
        fail('unexpected phase ${state.phase}');
    }
    state = state.apply(action);
    record = record.add(action);
  }
  expect(state.isOver, isTrue);
  return {'record': record.toJson(), 'serverSeed': 'x'};
}

Map<String, Object?> match(
  String id,
  String? white,
  String? black,
  List<Map<String, Object?>> games,
) => {
  'matchId': id,
  'white': {if (white != null) 'userId': white},
  'black': {if (black != null) 'userId': black},
  'games': games,
};

void main() {
  const rules = ShortNardRules();
  final hard = HeuristicBot(BotLevel.hard, random: Random(1));

  test('engine-like play agrees with the reference; random play does not', () {
    final game = recordGame(
      rules,
      Variant.shortNard,
      hard,
      RandomBot(Random(7)),
      Random(3),
    );
    final analyzer =
        MoveQualityAnalyzer()..addMatch(match('m1', '1', '2', [game]));
    final byId = {for (final p in analyzer.players) p.userId: p};
    final engine = byId['1']!;
    final random = byId['2']!;
    expect(engine.decisions, greaterThan(10));
    expect(engine.agreement, 1.0);
    expect(engine.averageLoss, 0.0);
    expect(random.decisions, greaterThan(10));
    expect(random.agreement, lessThan(0.6));
    expect(random.averageLoss, greaterThan(0));
    expect((engine.matches, engine.games), (1, 1));
    expect(engine.toJson(), {
      'userId': '1',
      'matches': 1,
      'games': 1,
      'decisions': engine.decisions,
      'agreement': 1.0,
      'avgLoss': 0.0,
    });
  });

  test(
    'players are aggregated over matches; bots and bad games are skipped',
    () {
      final dice = Random(11);
      final g1 = recordGame(rules, Variant.shortNard, hard, hard, dice);
      final g2 = recordGame(rules, Variant.shortNard, hard, hard, dice);
      final analyzer =
          MoveQualityAnalyzer()
            ..addMatch(
              match('a', '1', '2', [
                g1,
                {'record': 'broken'},
              ]),
            )
            ..addMatch(
              match('b', '2', null, [
                g2,
                {
                  'record': {'version': 99},
                },
              ]),
            )
            ..addMatch({'matchId': 7});
      final byId = {for (final p in analyzer.players) p.userId: p};
      expect(byId.keys, unorderedEquals(['1', '2']));
      expect((byId['2']!.matches, byId['2']!.games), (2, 2));
      expect((byId['1']!.matches, byId['1']!.games), (1, 1));
      expect(byId['2']!.agreement, 1.0);
      expect(analyzer.skippedGames, 2);
    },
  );

  test(
    'the CLI reads match lines on stdin and writes player lines',
    () async {
      final game = recordGame(
        rules,
        Variant.shortNard,
        RandomBot(Random(5)),
        hard,
        Random(9),
      );
      final process = await Process.start(Platform.resolvedExecutable, [
        'run',
        'tool/move_quality.dart',
      ]);
      process.stdin
        ..writeln(jsonEncode(match('m9', '41', '42', [game])))
        ..writeln('not json')
        ..writeln();
      await process.stdin.close();
      final out = await process.stdout.transform(utf8.decoder).join();
      final err = await process.stderr.transform(utf8.decoder).join();
      expect(await process.exitCode, 0, reason: err);
      final lines = const LineSplitter().convert(out.trim());
      final rows = [
        for (final l in lines) jsonDecode(l) as Map<String, Object?>,
      ];
      final byId = {for (final r in rows) r['userId']: r};
      expect(byId.keys, unorderedEquals(['41', '42']));
      expect(byId['42']!['agreement'], 1.0);
      expect(byId['41']!['agreement'] as double, lessThan(1.0));
      expect(err, contains('1 bad line'));
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
