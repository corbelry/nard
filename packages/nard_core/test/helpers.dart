import 'package:nard_core/nard_core.dart';

const shortRules = ShortNardRules();
const longRules = LongNardRules();

DiceRoll roll(int a, int b) => DiceRoll(a, b);

/// Occupied slots of [side] as `{slot: count}` (bar = 25, off excluded).
Map<int, int> pointsOf(BoardState board, Side side) => {
  for (var s = 1; s <= BoardState.bar; s++)
    if (board.count(side, s) > 0) s: board.count(side, s),
};

/// The set of mover positions reached by [turns] (as `pointsOf` maps
/// rendered to strings for easy comparison).
Set<String> moverResults(List<Turn> turns, Side mover) => {
  for (final t in turns) _render(pointsOf(t.result, mover)),
};

String _render(Map<int, int> points) {
  final keys = points.keys.toList()..sort((a, b) => b.compareTo(a));
  return keys.map((k) => '$k:${points[k]}').join(' ');
}

String render(Map<int, int> points) => _render(points);

Set<String> notations(List<Turn> turns) => {
  for (final t in turns) MoveNotation.format(t.moves),
};
