import 'package:nard_core/nard_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('Long Nard', () {
    test('LN-01 initial position: all 15 checkers on the head (own 24)', () {
      final board = longRules.initialState();
      for (final side in Side.values) {
        expect(pointsOf(board, side), {24: 15});
        expect(board.pipCount(side), 360);
      }
      longRules.validate(board);
    });

    test('LN-02 geometry: the opponent head is own point 12; shift of 12', () {
      expect(longRules.opposite(24), 12);
      expect(longRules.opposite(12), 24);
      expect(longRules.opposite(1), 13);
      expect(longRules.opposite(13), 1);
      for (var p = 1; p <= 24; p++) {
        expect(longRules.opposite(longRules.opposite(p)), p);
        expect((longRules.opposite(p) - p).abs(), 12);
      }
      expect(longRules.toAbsolute(Side.black, 24), 12);
    });

    test('LN-03 no hitting: a single opposing checker closes the point', () {
      final board = BoardState.fromPoints(
        white: {20: 1, 24: 14},
        black: {5: 1, 24: 14}, // black 5 = white 17
        whiteTurnsTaken: 1,
        blackTurnsTaken: 1,
      );
      final next = longRules.planner(board, roll(3, 1)).nextMoves();
      expect(next, isNot(contains(const Move(20, 17, 3))));
      expect(next, contains(const Move(20, 19, 1)));
      for (final t in longRules.legalTurns(board, roll(3, 1))) {
        expect(t.moves.any((m) => m.hit), isFalse);
      }
    });

    test('LN-04 only one checker may leave the head per turn', () {
      final turns = longRules.legalTurns(longRules.initialState(), roll(5, 2));
      expect(moverResults(turns, Side.white), {'24:14 17:1'});
    });

    group('LN-05 first-turn 6-6, 4-4 and 3-3 may take two from the head', () {
      test('6-6: two checkers to 18 (the opponent head blocks 12)', () {
        final planner = longRules.planner(longRules.initialState(), roll(6, 6));
        expect(planner.maxDiceUsed, 2);
        expect(moverResults(planner.legalTurns, Side.white), {'24:13 18:2'});
      });

      test('4-4: two checkers to 16', () {
        final turns = longRules.legalTurns(
          longRules.initialState(),
          roll(4, 4),
        );
        expect(moverResults(turns, Side.white), {'24:13 16:2'});
      });

      test('3-3: two checkers, four moves', () {
        final turns = longRules.legalTurns(
          longRules.initialState(),
          roll(3, 3),
        );
        expect(moverResults(turns, Side.white), {
          '24:13 21:1 15:1',
          '24:13 18:2',
        });
      });

      test('LN-08 5-5 is not an exception: one checker plays all four', () {
        final turns = longRules.legalTurns(
          longRules.initialState(),
          roll(5, 5),
        );
        expect(moverResults(turns, Side.white), {'24:14 4:1'});
      });

      test('the exception applies to the second player first turn too', () {
        final afterWhite =
            longRules
                .legalTurns(longRules.initialState(), roll(5, 2))
                .single
                .result;
        expect(afterWhite.turn, Side.black);
        final turns = longRules.legalTurns(afterWhite, roll(6, 6));
        expect(moverResults(turns, Side.black), {'24:13 18:2'});
      });

      test('no exception after the first turn', () {
        final board = BoardState.fromPoints(
          white: {24: 14, 18: 1},
          black: {24: 15},
          whiteTurnsTaken: 1,
        );
        final planner = longRules.planner(board, roll(6, 6));
        expect(planner.maxDiceUsed, 1);
        expect(moverResults(planner.legalTurns, Side.white), {'24:13 18:2'});
      });
    });

    group('LN-06 six-point block rule', () {
      BoardState fiveInARow(Map<int, int> black) => BoardState.fromPoints(
        white: {11: 1, 9: 1, 8: 1, 7: 1, 6: 1, 5: 1, 24: 9},
        black: black,
        whiteTurnsTaken: 5,
        blackTurnsTaken: 5,
      );

      test('a six-block with no opposing checker ahead is illegal', () {
        final board = fiveInARow({24: 15});
        final planner = longRules.planner(board, roll(2, 1));
        expect(planner.nextMoves(), isNot(contains(const Move(11, 10, 1))));
        for (final t in planner.legalTurns) {
          expect(longRules.hasIllegalBlock(t.result, Side.white), isFalse);
        }
      });

      test('a six-block is legal once an opposing checker is ahead', () {
        // black 10 = white 22, past the block (black 22..17).
        final board = fiveInARow({24: 14, 10: 1});
        final next = longRules.planner(board, roll(2, 1)).nextMoves();
        expect(next, contains(const Move(11, 10, 1)));
      });

      test('the rule is checked after every single move', () {
        final board = fiveInARow({24: 15});
        final planner = longRules.planner(board, roll(1, 1));
        // 11/10 first is illegal, 5/4 then 11/10 is fine.
        expect(planner.nextMoves(), isNot(contains(const Move(11, 10, 1))));
        expect(
          planner.nextMoves([const Move(5, 4, 1)]),
          contains(const Move(11, 10, 1)),
        );
      });

      test('blocks wrap from own point 1 to own point 24', () {
        final board = BoardState.fromPoints(
          white: {3: 1, 2: 1, 1: 1, 24: 10, 23: 1, 22: 1},
          black: {24: 15},
        );
        expect(longRules.hasIllegalBlock(board, Side.white), isTrue);
      });

      test('own points 13 and 12 are not adjacent on the opponent path', () {
        final board = BoardState.fromPoints(
          white: {15: 1, 14: 1, 13: 1, 12: 1, 11: 1, 10: 1, 24: 9},
          black: {20: 15},
        );
        expect(longRules.hasIllegalBlock(board, Side.white), isFalse);
      });

      test('borne-off opposing checkers count as ahead', () {
        final board = BoardState.fromPoints(
          white: {10: 1, 9: 1, 8: 1, 7: 1, 6: 1, 5: 1, 24: 9},
          black: {24: 14},
        );
        expect(longRules.hasIllegalBlock(board, Side.white), isFalse);
      });
    });

    test('LN-07 both dice must be used; larger die if only one fits', () {
      // Only the checker on 8 can move (black holds white 18 and 19);
      // 8/2 and 8/3 each rule out the other die.
      final ok = BoardState.fromPoints(
        white: {8: 1, 24: 14},
        black: {6: 1, 7: 1, 2: 13}, // white 18 and 19
        whiteTurnsTaken: 3,
        blackTurnsTaken: 3,
      );
      longRules.validate(ok);
      expect(notations(longRules.legalTurns(ok, roll(5, 6))), {'8/2'});
    });

    test('LN-09 bearing off follows the same rules as Short Nard', () {
      final board = BoardState.fromPoints(
        white: {6: 1, 3: 1},
        black: {24: 15},
        whiteTurnsTaken: 30,
        blackTurnsTaken: 30,
      );
      expect(
        moverResults(longRules.legalTurns(board, roll(3, 1)), Side.white),
        {'5:1', '3:1 2:1'},
      );
    });

    group('LN-10..12 oyn, mars and koks', () {
      BoardState finished(Map<int, int> black) =>
          BoardState.fromPoints(white: const {}, black: black);

      test('LN-10 oyn (single) when the loser has borne off', () {
        expect(longRules.winKind(finished({5: 14})), WinKind.single);
      });

      test('LN-11 mars (double) when the loser has borne off nothing', () {
        expect(longRules.winKind(finished({10: 15})), WinKind.gammon);
      });

      test('LN-12 koks (triple) when a loser checker has not passed the '
          'winner home board', () {
        expect(longRules.winKind(finished({13: 1, 5: 14})), WinKind.backgammon);
        expect(longRules.winKind(finished({24: 1, 5: 14})), WinKind.backgammon);
        expect(
          const LongNardRules(koks: false).winKind(finished({24: 1, 5: 14})),
          WinKind.gammon,
        );
      });

      test('winKind requires a finished game', () {
        expect(
          () => longRules.winKind(longRules.initialState()),
          throwsStateError,
        );
      });
    });

    test('LN-14 Long Nard has no doubling cube', () {
      expect(longRules.usesCube, isFalse);
      expect(GameState.newGame(longRules).config.cubeEnabled, isFalse);
    });
  });
}
