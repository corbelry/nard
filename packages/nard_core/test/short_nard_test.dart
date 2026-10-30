import 'package:nard_core/nard_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('Short Nard', () {
    test('SN-01 initial position: 2 on 24, 5 on 13, 3 on 8, 5 on 6', () {
      final board = shortRules.initialState();
      for (final side in Side.values) {
        expect(pointsOf(board, side), {24: 2, 13: 5, 8: 3, 6: 5});
        expect(board.pipCount(side), 167);
      }
      shortRules.validate(board);
    });

    test('SN-01 geometry: own point p is the opponent point 25-p', () {
      for (var p = 1; p <= 24; p++) {
        expect(shortRules.opposite(p), 25 - p);
        expect(shortRules.opposite(shortRules.opposite(p)), p);
      }
      expect(shortRules.toAbsolute(Side.black, 24), 1);
      expect(shortRules.toAbsolute(Side.white, 24), 24);
      expect(shortRules.toAbsolute(Side.black, BoardState.bar), BoardState.bar);
    });

    test('SN-03 checkers move towards their own point 1 by the die value', () {
      final turns = shortRules.legalTurns(
        shortRules.initialState(),
        roll(3, 1),
      );
      expect(notations(turns), contains('8/5 6/5'));
      for (final t in turns) {
        for (final m in t.moves) {
          expect(m.from - m.to, m.die);
        }
      }
    });

    test('SN-04 doubles grant four moves', () {
      final turns = shortRules.legalTurns(
        shortRules.initialState(),
        roll(6, 6),
      );
      expect(turns, isNotEmpty);
      for (final t in turns) {
        expect(t.moves, hasLength(4));
        expect(t.moves.every((m) => m.die == 6), isTrue);
      }
      expect(notations(turns), contains('24/18(2) 13/7(2)'));
    });

    test('SN-05 a point with two or more opposing checkers is closed', () {
      final board = BoardState.fromPoints(
        white: {13: 1, 1: 14},
        black: {18: 2, 1: 13}, // black 18 = white 7
      );
      final moves = shortRules.planner(board, roll(6, 2)).nextMoves();
      expect(moves.where((m) => m.from == 13 && m.to == 7), isEmpty);
      // 13/11/5 is still available.
      expect(notations(shortRules.legalTurns(board, roll(6, 2))), {
        '13/11 11/5',
      });
    });

    test('SN-06 landing on a blot hits it and sends it to the bar', () {
      final board = BoardState.fromPoints(
        white: {13: 1, 1: 14},
        black: {16: 1, 1: 14}, // black 16 = white 9
      );
      final turns = shortRules.legalTurns(board, roll(4, 4));
      final hitting = turns.where((t) => t.moves.first.hit).toList();
      expect(hitting, isNotEmpty);
      final first = hitting.first;
      expect(first.moves.first, const Move(13, 9, 4, hit: true));
      expect(first.result.barCount(Side.black), 1);
      expect(first.result.count(Side.black, 16), 0);
      shortRules.validate(first.result);
    });

    test('SN-07 a checker on the bar must enter before any other move', () {
      final board = BoardState.fromPoints(
        white: {BoardState.bar: 1, 13: 14},
        black: {1: 15},
      );
      final turns = shortRules.legalTurns(board, roll(6, 5));
      for (final t in turns) {
        expect(t.moves.first.isBarEntry, isTrue);
      }
      // Enters on 25 - die.
      expect(
        shortRules.planner(board, roll(6, 5)).nextMoves().map((m) => m.to),
        unorderedEquals([19, 20]),
      );
    });

    test(
      'SN-08 a closed entry point forfeits the die; a closed board the turn',
      () {
        // Black holds white 19..24 (black 1..6) with two checkers each.
        final closed = BoardState.fromPoints(
          white: {BoardState.bar: 1, 13: 14},
          black: {1: 2, 2: 2, 3: 2, 4: 2, 5: 2, 6: 3, 13: 2},
        );
        final turns = shortRules.legalTurns(closed, roll(6, 5));
        expect(turns, hasLength(1));
        expect(turns.single.isPass, isTrue);
        expect(turns.single.result.turn, Side.black);

        // Two on the bar, only the 5 enters: the 6 is lost even though other
        // checkers could move it.
        final twoOnBar = BoardState.fromPoints(
          white: {BoardState.bar: 2, 13: 13},
          black: {6: 2, 1: 13}, // black 6 = white 19
        );
        expect(notations(shortRules.legalTurns(twoOnBar, roll(6, 5))), {
          'bar/20',
        });
      },
    );

    test('SN-09 both dice must be used when possible', () {
      // 10/4 is blocked, so the only full play is 10/9/3 (1 first).
      final board = BoardState.fromPoints(
        white: {10: 1, 1: 14},
        black: {21: 2, 1: 13}, // black 21 = white 4
      );
      final planner = shortRules.planner(board, roll(6, 1));
      expect(planner.maxDiceUsed, 2);
      expect(notations(planner.legalTurns), {'10/9 9/3'});
      expect(planner.nextMoves(), [const Move(10, 9, 1)]);
      expect(
        () => shortRules.apply(board, roll(6, 1), [const Move(10, 9, 1)]),
        throwsA(isA<IllegalMoveException>()),
      );
    });

    group('SN-10 if only one die can be used, the larger must be used', () {
      // White 24s are blocked for both 6 and 5; the checker on 8 can play
      // either die but not both.
      Map<int, int> black({bool blockTwo = false}) =>
          blockTwo ? {7: 2, 6: 2, 23: 2, 2: 9} : {7: 2, 6: 2, 2: 11};

      test('larger die playable', () {
        final board = BoardState.fromPoints(
          white: {8: 1, 24: 14},
          black: black(),
        );
        final planner = shortRules.planner(board, roll(5, 6));
        expect(planner.maxDiceUsed, 1);
        expect(notations(planner.legalTurns), {'8/2'});
        expect(
          () => planner.play([const Move(8, 3, 5)]),
          throwsA(isA<IllegalMoveException>()),
        );
      });

      test('only the smaller die playable', () {
        final board = BoardState.fromPoints(
          white: {8: 1, 24: 14},
          black: black(blockTwo: true),
        );
        expect(notations(shortRules.legalTurns(board, roll(6, 5))), {'8/3'});
      });
    });

    test('SN-11 doubles: play as many moves as possible', () {
      final board = BoardState.fromPoints(
        white: {13: 1, 24: 14},
        black: {7: 2, 2: 13}, // black 7 = white 18 blocks the 24s
      );
      final planner = shortRules.planner(board, roll(6, 6));
      expect(planner.maxDiceUsed, 2);
      expect(notations(planner.legalTurns), {'13/7 7/1'});
    });

    test('SN-12 bearing off only once all checkers are in the home board', () {
      final board = BoardState.fromPoints(white: {7: 1, 3: 14}, black: {1: 15});
      final planner = shortRules.planner(board, roll(4, 3));
      expect(planner.nextMoves().any((m) => m.isBearOff), isFalse);
      final turns = planner.legalTurns;
      expect(moverResults(turns, Side.white), {'3:14'});
      expect(turns.single.result.offCount(Side.white), 1);
    });

    group('SN-13 bearing off', () {
      test('a higher die bears off from the highest point', () {
        final board = BoardState.fromPoints(
          white: {4: 1, 3: 1},
          black: {1: 15},
        );
        final turns = shortRules.legalTurns(board, roll(6, 5));
        expect(turns, hasLength(1));
        expect(turns.single.result.offCount(Side.white), 15);
      });

      test('a higher die must move a checker from a higher point if any', () {
        final board = BoardState.fromPoints(
          white: {6: 1, 2: 1},
          black: {1: 15},
        );
        final next = shortRules.planner(board, roll(4, 1)).nextMoves();
        expect(next, isNot(contains(const Move(2, 0, 4))));
        expect(next, contains(const Move(6, 2, 4)));
      });

      test('exact die bears off', () {
        final board = BoardState.fromPoints(
          white: {6: 1, 1: 1},
          black: {1: 15},
        );
        final turns = shortRules.legalTurns(board, roll(6, 1));
        expect(turns.any((t) => t.result.offCount(Side.white) == 15), isTrue);
      });

      test(
        'bear-off is optional when a move inside the home board is legal',
        () {
          final board = BoardState.fromPoints(
            white: {6: 1, 3: 1},
            black: {1: 15},
          );
          final results = moverResults(
            shortRules.legalTurns(board, roll(3, 1)),
            Side.white,
          );
          // 3/off 6/5 bears off; 6/3/2 (or 6/5/2) keeps both checkers.
          expect(results, {'5:1', '3:1 2:1'});
        },
      );
    });

    test('SN-14 a hit checker must re-enter before bearing off resumes', () {
      final board = BoardState.fromPoints(
        white: {BoardState.bar: 1, 1: 14},
        black: {1: 15},
      );
      final planner = shortRules.planner(board, roll(6, 1));
      for (final t in planner.legalTurns) {
        expect(t.moves.first.isBarEntry, isTrue);
        expect(t.moves.any((m) => m.isBearOff), isFalse);
      }
    });

    group('SN-15/SN-16 gammon and backgammon', () {
      BoardState finished(Map<int, int> black) =>
          BoardState.fromPoints(white: const {}, black: black);

      test('single when the loser has borne off a checker', () {
        expect(shortRules.winKind(finished({20: 14})), WinKind.single);
      });

      test('gammon when the loser has borne off nothing', () {
        expect(shortRules.winKind(finished({18: 15})), WinKind.gammon);
      });

      test('backgammon with a loser checker in the winner home board', () {
        expect(
          shortRules.winKind(finished({19: 1, 5: 14})),
          WinKind.backgammon,
        );
      });

      test('backgammon with a loser checker on the bar', () {
        expect(
          shortRules.winKind(finished({BoardState.bar: 1, 5: 14})),
          WinKind.backgammon,
        );
      });

      test(
        'score multiplies by the cube; Jacoby counts single while centred',
        () {
          final board = finished({18: 15});
          expect(shortRules.score(board, const DoublingCube(value: 4)), 8);
          expect(
            shortRules.score(board, DoublingCube.initial, jacoby: true),
            1,
          );
          expect(
            shortRules.score(
              board,
              const DoublingCube(value: 2, owner: Side.black),
              jacoby: true,
            ),
            4,
          );
        },
      );

      test('winKind requires a finished game', () {
        expect(
          () => shortRules.winKind(shortRules.initialState()),
          throwsStateError,
        );
      });
    });

    test('validate rejects both sides on the same point', () {
      final bad = BoardState.fromPoints(white: {5: 15}, black: {20: 15});
      expect(
        () => shortRules.validate(bad),
        throwsA(isA<IllegalMoveException>()),
      );
    });
  });
}
