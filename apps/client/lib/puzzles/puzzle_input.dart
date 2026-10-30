import 'package:nard_core/nard_core.dart';

import 'puzzle_models.dart';

/// Move input on a puzzle position: tap-tap / drag moves staged locally
/// through the rules engine (`TurnPlanner`), undo, nothing sent until the
/// turn is complete and confirmed (13.1). Immutable like `Session`.
class PuzzleInput {
  PuzzleInput(this.puzzle, {this.pending = const [], this.selected})
    : planner = puzzle.rules.planner(puzzle.board, puzzle.dice);

  PuzzleInput._(
    this.puzzle,
    this.planner, {
    this.pending = const [],
    this.selected,
  });

  final Puzzle puzzle;
  final TurnPlanner planner;
  final List<Move> pending;
  final int? selected;

  Side get side => puzzle.side;

  /// The position shown, including the staged moves.
  BoardState get board => planner.positionAfter(pending);

  List<Move> get nextMoves => planner.nextMoves(pending);

  Set<int> get movableFrom => {for (final m in nextMoves) m.from};

  /// Dice of the roll not yet used by [pending], highest first.
  List<int> get remainingDice {
    final left = List<int>.of(puzzle.dice.moves);
    for (final m in pending) {
      left.remove(m.die);
    }
    return left;
  }

  bool get canConfirm => planner.isComplete(pending);
  bool get canUndo => pending.isNotEmpty;

  /// Destinations of the checker on [from] (one or several dice).
  Set<int> targetsFrom(int from) => {
    for (final path in _paths(from, pending)) path.last.to,
  };

  PuzzleInput _copy({List<Move>? pending, int? Function()? selected}) =>
      PuzzleInput._(
        puzzle,
        planner,
        pending: pending ?? this.pending,
        selected: selected != null ? selected() : this.selected,
      );

  PuzzleInput select(int? slot) => _copy(
    selected: () => slot != null && movableFrom.contains(slot) ? slot : null,
  );

  /// A tap on [slot]: select, move the selected checker, or deselect.
  PuzzleInput tap(int? slot) {
    final sel = selected;
    if (slot == null || sel == slot) return select(null);
    if (sel != null && targetsFrom(sel).contains(slot)) return move(sel, slot);
    return select(slot);
  }

  /// Moves [from] → [to] using the fewest dice; unchanged if illegal.
  PuzzleInput move(int from, int to) {
    final paths = _paths(from, pending).where((p) => p.last.to == to);
    if (paths.isEmpty) return select(null);
    final best = paths.reduce((a, b) {
      if (a.length != b.length) return a.length < b.length ? a : b;
      return a.first.die <= b.first.die ? a : b;
    });
    return _copy(pending: [...pending, ...best], selected: () => null);
  }

  PuzzleInput undo() =>
      pending.isEmpty
          ? this
          : _copy(
            pending: pending.sublist(0, pending.length - 1),
            selected: () => null,
          );

  PuzzleInput reset() => _copy(pending: const [], selected: () => null);

  /// The attempt body: the board after my moves, in the API format (the
  /// server judges by the resulting position, any move order).
  Map<String, Object?> attemptBoard() => PuzzleBoard.toJson(board);

  String get notation => MoveNotation.format(pending);

  List<List<Move>> _paths(int from, List<Move> played) {
    final result = <List<Move>>[];
    for (final m in planner.nextMoves(played)) {
      if (m.from != from) continue;
      result.add([m]);
      if (m.to == BoardState.off) continue;
      for (final rest in _paths(m.to, [...played, m])) {
        result.add([m, ...rest]);
      }
    }
    return result;
  }
}
