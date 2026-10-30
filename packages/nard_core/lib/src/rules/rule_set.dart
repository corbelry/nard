import '../board_state.dart';
import '../cube.dart';
import '../dice.dart';
import '../move.dart';
import '../side.dart';
import 'turn_planner.dart';

/// Supported rule variants.
enum Variant { shortNard, longNard }

/// How decisively a game was won. The multiplier is applied to the cube.
///
/// Short Nard: single / gammon / backgammon.
/// Long Nard: oyn / mars / koks.
enum WinKind {
  single(1),
  gammon(2),
  backgammon(3);

  const WinKind(this.multiplier);

  final int multiplier;
}

/// Thrown when a position, move or action breaks the rules.
class IllegalMoveException implements Exception {
  IllegalMoveException(this.message);

  final String message;

  @override
  String toString() => 'IllegalMoveException: $message';
}

/// A pluggable rule set. All functions are pure.
///
/// Subclasses describe the variant through a handful of hooks; the shared
/// move generator in [TurnPlanner] enforces the dice-usage rules common to
/// every variant (use as many dice as possible; if only one of two can be
/// played, play the larger when possible; doubles give four moves).
abstract class RuleSet {
  const RuleSet();

  Variant get variant;

  /// Whether the doubling cube is part of this variant.
  bool get usesCube;

  /// Whether the winner of the opening roll plays the two opening dice
  /// (true) or rolls again (false).
  bool get openingRollIsFirstMove;

  BoardState initialState({Side firstToMove = Side.white});

  /// Maps a point in one side's numbering to the other side's numbering.
  /// Must be an involution on 1..24.
  int opposite(int point);

  /// Converts [side]'s slot to White's numbering (bar/off stay as is).
  int toAbsolute(Side side, int slot) {
    if (side == Side.white ||
        slot == BoardState.off ||
        slot == BoardState.bar) {
      return slot;
    }
    return opposite(slot);
  }

  /// Whether the side to move may land on its own point [to] (1..24).
  bool canLand(BoardState board, int to);

  /// Whether landing on [to] sends an opponent blot to the bar.
  bool isHit(BoardState board, int to) => false;

  /// Upper bound on checkers that may leave the head this turn
  /// (unlimited unless a variant restricts it).
  int headLimit(BoardState board, DiceRoll roll) => 15;

  /// The head point, if the variant has one; moves from it are counted.
  int? get headPoint => null;

  /// Variant-specific legality of the position right after a single move.
  bool isLegalAfterMove(BoardState board) => true;

  /// All single moves for the side to move using [die], before checks that
  /// depend on the resulting position ([isLegalAfterMove]).
  List<Move> singleMoves(BoardState board, int die, {required bool headOpen}) {
    final me = board.turn;
    final moves = <Move>[];
    if (board.barCount(me) > 0) {
      final to = BoardState.bar - die;
      if (canLand(board, to)) {
        moves.add(Move(BoardState.bar, to, die, hit: isHit(board, to)));
      }
      return moves;
    }
    final highest = board.highestPoint(me);
    final bearingOff = highest <= 6;
    for (var from = highest; from >= 1; from--) {
      if (board.count(me, from) == 0) continue;
      if (!headOpen && from == headPoint) continue;
      final to = from - die;
      if (to >= 1) {
        if (canLand(board, to)) {
          moves.add(Move(from, to, die, hit: isHit(board, to)));
        }
      } else if (bearingOff && (to == 0 || from == highest)) {
        moves.add(Move(from, BoardState.off, die));
      }
    }
    return moves;
  }

  /// Applies a single move without validation (turn is not switched).
  BoardState applyMove(BoardState board, Move move) => board.relocate(
    move.from,
    move.to,
    hitAt: move.hit ? opposite(move.to) : null,
  );

  /// Creates a planner for building or validating a turn.
  TurnPlanner planner(BoardState board, DiceRoll roll) =>
      TurnPlanner(this, board, roll);

  /// Every legal full-turn move sequence, one per distinct resulting
  /// position. A position with no legal move yields a single empty turn.
  List<Turn> legalTurns(BoardState board, DiceRoll roll) =>
      planner(board, roll).legalTurns;

  /// Validates [moves] as a complete turn and returns the resulting position
  /// with the turn passed to the opponent.
  BoardState apply(BoardState board, DiceRoll roll, List<Move> moves) =>
      planner(board, roll).play(moves).result;

  /// Throws [IllegalMoveException] if the position cannot occur.
  void validate(BoardState board) {
    for (var p = 1; p <= 24; p++) {
      if (board.count(Side.white, p) > 0 &&
          board.count(Side.black, opposite(p)) > 0) {
        throw IllegalMoveException('Both sides occupy white point $p');
      }
    }
  }

  bool isGameOver(BoardState board) => winner(board) != null;

  Side? winner(BoardState board) {
    for (final side in Side.values) {
      if (board.offCount(side) == BoardState.checkersPerSide) return side;
    }
    return null;
  }

  /// How the finished game on [board] was won.
  WinKind winKind(BoardState board);

  /// Points won for the finished game on [board] with [cube].
  ///
  /// With [jacoby], gammons and backgammons count as singles while the cube
  /// has not been turned (money play only).
  int score(BoardState board, DoublingCube cube, {bool jacoby = false}) {
    final kind = winKind(board);
    if (jacoby && !cube.isTurned) return cube.value;
    return kind.multiplier * cube.value;
  }
}
