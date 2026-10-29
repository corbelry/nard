import 'dart:math';

import 'package:nard_core/nard_core.dart';
import 'package:test/test.dart';

import 'oracle.dart';

/// Plays [games] random games, calling [onPosition] before every turn.
void randomGames(
  RuleSet rules,
  int games,
  int seed,
  void Function(BoardState board, DiceRoll roll, TurnPlanner planner)
  onPosition,
) {
  final rng = Random(seed);
  for (var g = 0; g < games; g++) {
    var board = rules.initialState(firstToMove: Side.values[rng.nextInt(2)]);
    var turns = 0;
    while (!rules.isGameOver(board)) {
      final dice = DiceRoll(rng.nextInt(6) + 1, rng.nextInt(6) + 1);
      final planner = rules.planner(board, dice);
      onPosition(board, dice, planner);
      final legal = planner.legalTurns;
      board = legal[rng.nextInt(legal.length)].result;
      if (++turns > 5000) fail('Game did not terminate');
    }
  }
}

void checkInvariants(RuleSet rules, BoardState board) {
  rules.validate(board);
  for (final side in Side.values) {
    var total = 0;
    for (var s = 0; s < BoardState.slotsPerSide; s++) {
      expect(board.count(side, s), greaterThanOrEqualTo(0));
      total += board.count(side, s);
    }
    expect(total, BoardState.checkersPerSide);
    if (rules is LongNardRules) {
      expect(board.barCount(side), 0, reason: 'Long Nard has no bar');
      expect(rules.hasIllegalBlock(board, side), isFalse);
    }
  }
}

void main() {
  for (final rules in [const ShortNardRules(), const LongNardRules()]) {
    group('${rules.variant.name} properties', () {
      test('random games never produce an illegal state', () {
        randomGames(rules, 300, 42, (board, dice, planner) {
          checkInvariants(rules, board);
          final turns = planner.legalTurns;
          expect(turns, isNotEmpty);
          final results = <BoardState>{};
          for (final t in turns) {
            checkInvariants(rules, t.result);
            expect(t.moves.length, planner.maxDiceUsed);
            expect(results.add(t.result), isTrue, reason: 'duplicate result');
            expect(t.result.turn, board.turn.opponent);
            expect(
              t.result.turnsTaken(board.turn),
              board.turnsTaken(board.turn) + 1,
            );
          }
        });
      });

      test('move generation matches the independent oracle', () {
        final oracle = Oracle(rules.variant);
        var positions = 0;
        randomGames(rules, 40, 7, (board, dice, planner) {
          positions++;
          final expected = oracle.legalResults(board, dice);
          final actual = {for (final t in planner.legalTurns) Oracle.keyOf(t)};
          expect(actual, expected, reason: '$board roll $dice');
        });
        expect(positions, greaterThan(1000));
      });

      test('every legal turn validates move by move and resolves from '
          'notation', () {
        randomGames(rules, 30, 99, (board, dice, planner) {
          for (final t in planner.legalTurns) {
            for (var i = 0; i < t.moves.length; i++) {
              expect(
                planner.nextMoves(t.moves.sublist(0, i)),
                contains(t.moves[i]),
              );
            }
            expect(planner.isComplete(t.moves), isTrue);
            final path = [for (final m in t.moves) (m.from, m.to)];
            expect(planner.resolve(path)!.result, t.result);
            final text = MoveNotation.format(t.moves);
            expect(
              MoveNotation.parseTurn(text, rules, board, dice).result,
              t.result,
              reason: text,
            );
          }
        });
      });
    });
  }

  test('Position ID round-trips every position of random Short Nard games', () {
    const rules = ShortNardRules();
    randomGames(rules, 50, 3, (board, dice, planner) {
      final id = PositionId.encode(board);
      expect(id, hasLength(14));
      final decoded = PositionId.decode(id, onRoll: board.turn);
      for (final side in Side.values) {
        expect(decoded.slots(side), board.slots(side));
      }
    });
  });

  test('move generation is fast (typical position < 1 ms)', () {
    const rules = ShortNardRules();
    final positions = <(BoardState, DiceRoll)>[];
    randomGames(rules, 20, 11, (b, d, _) => positions.add((b, d)));
    // Warm up the VM.
    for (final (b, d) in positions.take(200)) {
      rules.legalTurns(b, d);
    }
    final sw = Stopwatch()..start();
    for (final (b, d) in positions) {
      rules.legalTurns(b, d);
    }
    final perPosition = sw.elapsedMicroseconds / positions.length;
    printOnFailure('average ${perPosition.toStringAsFixed(1)} us per position');
    expect(perPosition, lessThan(1000));
  });
}
