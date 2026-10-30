import '../board_state.dart';
import '../side.dart';
import 'rule_set.dart';

/// Short Nard: classic international backgammon.
///
/// Geometry: a side's point p is the opponent's point 25 - p. Both sides start
/// with 2 checkers on 24, 5 on 13, 3 on 8 and 5 on 6 (own numbering).
/// See docs/RULES_SHORT.md for the rule catalogue (SN-xx).
class ShortNardRules extends RuleSet {
  const ShortNardRules();

  static const Map<int, int> startingPoints = {24: 2, 13: 5, 8: 3, 6: 5};

  @override
  Variant get variant => Variant.shortNard;

  @override
  bool get usesCube => true;

  @override
  bool get openingRollIsFirstMove => true;

  @override
  BoardState initialState({Side firstToMove = Side.white}) =>
      BoardState.fromPoints(
        white: startingPoints,
        black: startingPoints,
        turn: firstToMove,
      );

  @override
  int opposite(int point) => 25 - point;

  // SN-05: a point held by two or more opposing checkers is closed.
  @override
  bool canLand(BoardState board, int to) =>
      board.count(board.turn.opponent, opposite(to)) <= 1;

  // SN-06: landing on a single opposing checker hits it.
  @override
  bool isHit(BoardState board, int to) =>
      board.count(board.turn.opponent, opposite(to)) == 1;

  // SN-13/14: gammon when the loser has borne off nothing; backgammon when,
  // in addition, a loser checker is on the bar or in the winner's home board.
  @override
  WinKind winKind(BoardState board) {
    final winner = this.winner(board);
    if (winner == null) throw StateError('Game is not over');
    final loser = winner.opponent;
    if (board.offCount(loser) > 0) return WinKind.single;
    for (var p = 19; p <= BoardState.bar; p++) {
      if (board.count(loser, p) > 0) return WinKind.backgammon;
    }
    return WinKind.gammon;
  }
}
