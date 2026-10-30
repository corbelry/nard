import 'package:nard_core/nard_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('Move explanations (illegal-move banners)', () {
    test('a legal move has no rejection', () {
      final planner = shortRules.planner(shortRules.initialState(), roll(5, 2));
      expect(planner.explain(13, 8), isNull);
      expect(planner.explain(13, 11), isNull);
    });

    test('no own checker on the source point', () {
      final planner = shortRules.planner(shortRules.initialState(), roll(5, 2));
      expect(planner.explain(23, 18), MoveRejection.noChecker);
    });

    test('SN-03 the distance must match an unused die', () {
      final planner = shortRules.planner(shortRules.initialState(), roll(5, 2));
      expect(planner.explain(13, 9), MoveRejection.noMatchingDie);
      expect(planner.explain(13, 15), MoveRejection.noMatchingDie);
      expect(
        planner.explain(13, 11, [const Move(8, 6, 2)]),
        MoveRejection.noMatchingDie,
      );
    });

    test('every die used: the turn is complete', () {
      final planner = shortRules.planner(shortRules.initialState(), roll(5, 2));
      final played = [const Move(13, 8, 5), const Move(13, 11, 2)];
      expect(planner.explain(8, 6, played), MoveRejection.turnComplete);
    });

    test('SN-05 a point held by two opposing checkers is closed', () {
      final planner = shortRules.planner(shortRules.initialState(), roll(5, 2));
      expect(planner.explain(24, 19), MoveRejection.pointClosed);
    });

    test('LN-03 a point holding one opposing checker is closed', () {
      final board = BoardState.fromPoints(
        white: {20: 1, 24: 14},
        black: {5: 1, 24: 14}, // black 5 = white 17
        whiteTurnsTaken: 1,
        blackTurnsTaken: 1,
      );
      final planner = longRules.planner(board, roll(3, 1));
      expect(planner.explain(20, 17), MoveRejection.pointClosed);
      expect(planner.explain(20, 19), isNull);
    });

    test('SN-07 checkers on the bar must enter first', () {
      final board = BoardState.fromPoints(
        white: {BoardState.bar: 1, 13: 14},
        black: ShortNardRules.startingPoints,
        whiteTurnsTaken: 1,
        blackTurnsTaken: 1,
      );
      final planner = shortRules.planner(board, roll(5, 2));
      expect(planner.explain(13, 8), MoveRejection.mustEnterFromBar);
      expect(planner.explain(BoardState.bar, 20), isNull);
    });

    test('LN-04 a second checker may not leave the head', () {
      final planner = longRules.planner(longRules.initialState(), roll(5, 2));
      expect(planner.explain(24, 22), isNull);
      expect(
        planner.explain(24, 22, [const Move(24, 19, 5)]),
        MoveRejection.headRule,
      );
    });

    test('LN-06 a move may not complete a six-block', () {
      // White 14..18 plus 13 would block black points 1..6 while every
      // black checker is still on its head.
      final board = BoardState.fromPoints(
        white: {24: 9, 18: 1, 17: 1, 16: 2, 15: 1, 14: 1},
        black: {24: 15},
        whiteTurnsTaken: 5,
        blackTurnsTaken: 5,
      );
      longRules.validate(board);
      final planner = longRules.planner(board, roll(3, 1));
      expect(planner.explain(16, 13), MoveRejection.sixBlock);
    });

    test('SN-09 a move that leaves a die unplayable is rejected', () {
      // Black holds white 6 and 5: 13/9 leaves the 3 unplayable, while
      // 13/10 then 8/4 uses both dice.
      final board = BoardState.fromPoints(
        white: {13: 1, 8: 1},
        black: {19: 2, 20: 2},
        whiteTurnsTaken: 1,
        blackTurnsTaken: 1,
      );
      final planner = shortRules.planner(board, roll(4, 3));
      expect(planner.explain(13, 9), MoveRejection.mustUseBothDice);
      expect(planner.explain(13, 10), isNull);
    });

    test('SN-10 when only one die can be played it must be the larger', () {
      // Black holds white 6: either die alone is playable from 13, both
      // together are not.
      final board = BoardState.fromPoints(
        white: {13: 1},
        black: {19: 2},
        whiteTurnsTaken: 1,
        blackTurnsTaken: 1,
      );
      final planner = shortRules.planner(board, roll(4, 3));
      expect(planner.maxDiceUsed, 1);
      expect(planner.explain(13, 10), MoveRejection.mustUseLargerDie);
      expect(planner.explain(13, 9), isNull);
    });

    test('SN-12 bearing off needs every checker in the home board', () {
      final board = BoardState.fromPoints(
        white: {13: 1, 1: 14},
        black: {24: 15},
        whiteTurnsTaken: 1,
        blackTurnsTaken: 1,
      );
      final planner = shortRules.planner(board, roll(1, 2));
      expect(
        planner.explain(1, BoardState.off),
        MoveRejection.bearOffNotAllowed,
      );
    });

    test('SN-13 a higher die bears off only from the highest point', () {
      final board = BoardState.fromPoints(
        white: {6: 1, 4: 14},
        black: {24: 15},
        whiteTurnsTaken: 1,
        blackTurnsTaken: 1,
      );
      final planner = shortRules.planner(board, roll(6, 5));
      expect(planner.explain(6, BoardState.off), isNull);
      expect(
        planner.explain(4, BoardState.off),
        MoveRejection.bearOffHigherDie,
      );
    });

    test('LN-09 bearing off follows the same rules in Long Nard', () {
      final board = BoardState.fromPoints(
        white: {13: 1, 1: 14},
        black: {24: 15},
        whiteTurnsTaken: 1,
        blackTurnsTaken: 1,
      );
      final planner = longRules.planner(board, roll(1, 2));
      expect(
        planner.explain(1, BoardState.off),
        MoveRejection.bearOffNotAllowed,
      );
    });

    test('an illegal played prefix throws', () {
      final planner = shortRules.planner(shortRules.initialState(), roll(5, 2));
      expect(
        () => planner.explain(13, 8, [const Move(13, 9, 4)]),
        throwsA(isA<IllegalMoveException>()),
      );
    });
  });
}
