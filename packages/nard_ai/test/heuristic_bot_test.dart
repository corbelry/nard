import 'dart:math';

import 'package:nard_ai/nard_ai.dart';
import 'package:nard_core/nard_core.dart';
import 'package:test/test.dart';

const short = ShortNardRules();
const long = LongNardRules();

/// Plays one game between [white] and [black]; returns the winner.
Side playGame(RuleSet rules, Bot white, Bot black, Random dice) {
  var board = rules.initialState(
    firstToMove: dice.nextBool() ? Side.white : Side.black,
  );
  var turns = 0;
  while (!rules.isGameOver(board)) {
    final roll = DiceRoll(dice.nextInt(6) + 1, dice.nextInt(6) + 1);
    final bot = board.turn == Side.white ? white : black;
    final turn = bot.chooseTurn(rules, board, roll);
    expect(rules.legalTurns(board, roll), contains(turn));
    board = turn.result;
    if (++turns > 2000) fail('Game did not terminate');
  }
  return rules.winner(board)!;
}

int wins(RuleSet rules, Bot a, Bot b, int games, int seed) {
  final dice = Random(seed);
  var won = 0;
  for (var g = 0; g < games; g++) {
    // Alternate colours so neither bot profits from the seat.
    final aIsWhite = g.isEven;
    final winner = playGame(rules, aIsWhite ? a : b, aIsWhite ? b : a, dice);
    if ((winner == Side.white) == aIsWhite) won++;
  }
  return won;
}

void main() {
  group('HeuristicEvaluator', () {
    const eval = HeuristicEvaluator();

    for (final rules in [short, long]) {
      test('${rules.variant.name}: score is antisymmetric', () {
        final rng = Random(3);
        var board = rules.initialState();
        for (var i = 0; i < 60 && !rules.isGameOver(board); i++) {
          final roll = DiceRoll(rng.nextInt(6) + 1, rng.nextInt(6) + 1);
          final turns = rules.legalTurns(board, roll);
          board = turns[rng.nextInt(turns.length)].result;
          expect(
            eval.score(rules, board, Side.white),
            closeTo(-eval.score(rules, board, Side.black), 1e-9),
          );
          final p = eval.winProbability(rules, board, Side.white);
          expect(p, inInclusiveRange(0, 1));
        }
      });
    }

    test('a race lead raises the win probability', () {
      final ahead = BoardState.fromPoints(
        white: {3: 5, 2: 5, 1: 5},
        black: {6: 5, 5: 5, 4: 5},
        turn: Side.black,
      );
      expect(eval.winProbability(short, ahead, Side.white), greaterThan(0.8));
      expect(eval.winProbability(short, ahead, Side.black), lessThan(0.2));
    });

    test('a finished game is certain', () {
      final won = BoardState.fromPoints(white: {}, black: {6: 15});
      expect(eval.winProbability(short, won, Side.white), 1);
      expect(eval.winProbability(short, won, Side.black), 0);
    });
  });

  group('HeuristicBot', () {
    test('every level plays legal turns', () {
      for (final level in BotLevel.values) {
        for (final rules in [short, long]) {
          final bot = HeuristicBot(level, random: Random(level.index));
          playGame(rules, bot, RandomBot(Random(9)), Random(level.index));
        }
      }
    });

    test('bears off rather than shuffling inside in a race', () {
      final board = BoardState.fromPoints(white: {6: 1, 2: 2}, black: {6: 15});
      // A checker left on 2 is safe here: there is no contact.
      final turn = HeuristicBot(
        BotLevel.medium,
      ).chooseTurn(short, board, DiceRoll(6, 2));
      expect(turn.result.offCount(Side.white), 14);
    });

    test('makes the bar point with an opening 6-1', () {
      // White 6-1 opening: making the 7 point (13/7 8/7) is the book play.
      final turn = HeuristicBot(
        BotLevel.medium,
      ).chooseTurn(short, short.initialState(), DiceRoll(6, 1));
      expect(MoveNotation.format(turn.moves), anyOf('13/7 8/7', '8/7 13/7'));
    });

    test('is deterministic for a seeded random source', () {
      final board = short.initialState();
      final a = HeuristicBot(BotLevel.beginner, random: Random(5));
      final b = HeuristicBot(BotLevel.beginner, random: Random(5));
      for (var i = 0; i < 10; i++) {
        expect(
          a.chooseTurn(short, board, DiceRoll(4, 2)),
          b.chooseTurn(short, board, DiceRoll(4, 2)),
        );
      }
    });

    for (final rules in [short, long]) {
      test('${rules.variant.name}: medium beats random clearly', () {
        final won = wins(
          rules,
          HeuristicBot(BotLevel.medium, random: Random(1)),
          RandomBot(Random(2)),
          60,
          11,
        );
        expect(won, greaterThanOrEqualTo(48), reason: '$won / 60');
      });

      test('${rules.variant.name}: medium beats beginner', () {
        final won = wins(
          rules,
          HeuristicBot(BotLevel.medium, random: Random(1)),
          HeuristicBot(BotLevel.beginner, random: Random(2)),
          60,
          12,
        );
        expect(won, greaterThan(33), reason: '$won / 60');
      });
    }

    test(
      'hard (2-ply) beats easy in Short Nard',
      () {
        final won = wins(
          short,
          HeuristicBot(BotLevel.hard, random: Random(1)),
          HeuristicBot(BotLevel.easy, random: Random(2)),
          30,
          13,
        );
        expect(won, greaterThan(16), reason: '$won / 30');
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });

  test('avoids leaving a blot while an opposing checker is behind', () {
    // Black's back checkers sit on white 1: 6/off 2/off would leave a
    // blot on 2, while 6/4 4/off keeps a safe point.
    final board = BoardState.fromPoints(white: {6: 1, 2: 2}, black: {24: 15});
    final turn = HeuristicBot(
      BotLevel.medium,
    ).chooseTurn(short, board, DiceRoll(6, 2));
    expect(turn.result.count(Side.white, 2), 2);
  });

  group('Cube decisions', () {
    final bot = HeuristicBot(BotLevel.medium);

    test('doubles a strong position and takes a close one', () {
      final strong = BoardState.fromPoints(
        white: {3: 5, 2: 5, 1: 5},
        black: {8: 5, 7: 5, 6: 5},
      );
      expect(bot.shouldDouble(short, strong, Side.white), isTrue);
      final close = short.initialState();
      expect(bot.shouldDouble(short, close, Side.white), isFalse);
      expect(bot.shouldTake(short, close, Side.black), isTrue);
    });

    test('drops a hopeless position', () {
      final lost = BoardState.fromPoints(white: {1: 3}, black: {24: 15});
      expect(bot.shouldTake(short, lost, Side.black), isFalse);
    });
  });
}
