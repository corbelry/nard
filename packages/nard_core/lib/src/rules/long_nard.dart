import '../board_state.dart';
import '../dice.dart';
import '../side.dart';
import 'rule_set.dart';

/// Long Nard (Uzun nərd).
///
/// Geometry: both sides move in the same rotational direction from heads on
/// opposite sides of the board, so a side's point p is the opponent's point
/// p ± 12. Each side starts with all 15 checkers on its head (own point 24).
/// See docs/RULES_LONG.md for the rule catalogue (LN-xx).
class LongNardRules extends RuleSet {
  const LongNardRules({this.koks = true});

  /// Whether a koks (triple win) is scored; otherwise the best result is mars.
  final bool koks;

  static const int head = 24;

  /// Doubles that may move two checkers off the head on a side's first turn.
  static const Set<int> firstTurnHeadDoubles = {6, 4, 3};

  @override
  Variant get variant => Variant.longNard;

  @override
  bool get usesCube => false;

  @override
  bool get openingRollIsFirstMove => false;

  @override
  BoardState initialState({Side firstToMove = Side.white}) =>
      BoardState.fromPoints(
        white: const {head: 15},
        black: const {head: 15},
        turn: firstToMove,
      );

  @override
  int opposite(int point) => (point + 11) % 24 + 1;

  @override
  int? get headPoint => head;

  // LN-03: no hitting; a point holding any opposing checker is closed.
  @override
  bool canLand(BoardState board, int to) =>
      board.count(board.turn.opponent, opposite(to)) == 0;

  // LN-04/05: one checker from the head per turn, except 6-6, 4-4 and 3-3 on
  // a side's first turn, which allow two.
  @override
  int headLimit(BoardState board, DiceRoll roll) =>
      board.turnsTaken(board.turn) == 0 &&
              roll.isDouble &&
              firstTurnHeadDoubles.contains(roll.die1)
          ? 2
          : 1;

  // LN-06: a side may not hold six consecutive points (along the opponent's
  // path) unless at least one opposing checker is already past the block.
  @override
  bool isLegalAfterMove(BoardState board) =>
      !hasIllegalBlock(board, board.turn);

  /// Whether [side] holds six consecutive points with no opposing checker
  /// ahead of them.
  bool hasIllegalBlock(BoardState board, Side side) {
    final opp = side.opponent;
    // Lowest opposing checker in the opponent's numbering; borne-off
    // checkers count as fully past every block.
    var lowestOpp = 0;
    if (board.offCount(opp) == 0) {
      lowestOpp = 25;
      for (var p = 1; p <= 24; p++) {
        if (board.count(opp, p) > 0) {
          lowestOpp = p;
          break;
        }
      }
    }
    var run = 0;
    // Walk the opponent's path from its point 1 upwards; a run ending at
    // opponent point a+5 starts at a.
    for (var oppPoint = 1; oppPoint <= 24; oppPoint++) {
      if (board.count(side, opposite(oppPoint)) > 0) {
        run++;
        if (run >= 6 && lowestOpp >= oppPoint - 5) return true;
      } else {
        run = 0;
      }
    }
    return false;
  }

  // LN-10/11: mars when the loser has borne off nothing; koks when, in
  // addition, a loser checker has not yet passed the winner's home board
  // (loser's own points 13..24).
  @override
  WinKind winKind(BoardState board) {
    final winner = this.winner(board);
    if (winner == null) throw StateError('Game is not over');
    final loser = winner.opponent;
    if (board.offCount(loser) > 0) return WinKind.single;
    if (koks) {
      for (var p = 13; p <= 24; p++) {
        if (board.count(loser, p) > 0) return WinKind.backgammon;
      }
    }
    return WinKind.gammon;
  }
}
