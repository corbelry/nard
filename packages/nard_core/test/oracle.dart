import 'package:nard_core/nard_core.dart';

/// A deliberately naive, independent reference move generator used to
/// cross-check [TurnPlanner]. It shares no code with the engine: it works on
/// raw lists, enumerates every ordering of the dice and every prefix, then
/// applies the textbook filters (maximum dice used; larger die when only
/// one of two can be played).
class Oracle {
  Oracle(this.variant);

  final Variant variant;

  bool get _long => variant == Variant.longNard;

  int _opp(int p) => _long ? (p > 12 ? p - 12 : p + 12) : 25 - p;

  /// Resulting positions (as keys) of all legal turns.
  Set<String> legalResults(BoardState board, DiceRoll roll) {
    final me = board.slots(board.turn).toList();
    final opp = board.slots(board.turn.opponent).toList();
    final headLimit =
        _long &&
                board.turnsTaken(board.turn) == 0 &&
                roll.isDouble &&
                const {3, 4, 6}.contains(roll.die1)
            ? 2
            : 1;
    final orders =
        roll.isDouble
            ? [List.filled(4, roll.die1)]
            : [
              [roll.die1, roll.die2],
              [roll.die2, roll.die1],
            ];

    final plays = <(List<int> used, String key)>[];
    void dfs(
      List<int> me,
      List<int> opp,
      List<int> dice,
      List<int> used,
      int head,
    ) {
      plays.add((List.of(used), _key(me, opp)));
      if (dice.isEmpty) return;
      final die = dice.first;
      for (final (from, to) in _singles(me, opp, die, head < headLimit)) {
        final m = List.of(me);
        final o = List.of(opp);
        m[from]--;
        m[to < 0 ? 0 : to]++;
        if (!_long && to > 0 && o[_opp(to)] == 1) {
          o[_opp(to)]--;
          o[25]++;
        }
        if (_long && _illegalBlock(m, o)) continue;
        dfs(m, o, dice.sublist(1), [...used, die], head + (from == 24 ? 1 : 0));
      }
    }

    for (final order in orders) {
      dfs(me, opp, order, [], 0);
    }
    final maxUsed = plays
        .map((p) => p.$1.length)
        .reduce((a, b) => a > b ? a : b);
    var best = plays.where((p) => p.$1.length == maxUsed).toList();
    if (!roll.isDouble && maxUsed == 1) {
      final larger = best.where((p) => p.$1.single == roll.high).toList();
      if (larger.isNotEmpty) best = larger;
    }
    return {for (final p in best) p.$2};
  }

  List<(int, int)> _singles(
    List<int> me,
    List<int> opp,
    int die,
    bool headOpen,
  ) {
    final out = <(int, int)>[];
    bool open(int to) => _long ? opp[_opp(to)] == 0 : opp[_opp(to)] < 2;
    if (me[25] > 0) {
      if (open(25 - die)) out.add((25, 25 - die));
      return out;
    }
    var outside = 0;
    for (var p = 7; p <= 25; p++) {
      outside += me[p];
    }
    for (var from = 1; from <= 24; from++) {
      if (me[from] == 0) continue;
      if (_long && from == 24 && !headOpen) continue;
      final to = from - die;
      if (to >= 1) {
        if (open(to)) out.add((from, to));
      } else if (outside == 0) {
        var higher = 0;
        for (var p = from + 1; p <= 6; p++) {
          higher += me[p];
        }
        if (to == 0 || higher == 0) out.add((from, 0));
      }
    }
    return out;
  }

  bool _illegalBlock(List<int> me, List<int> opp) {
    var lowestOpp = 0;
    if (opp[0] == 0) {
      lowestOpp = 99;
      for (var p = 24; p >= 1; p--) {
        if (opp[p] > 0) lowestOpp = p;
      }
    }
    for (var a = 1; a + 5 <= 24; a++) {
      var all = true;
      for (var q = a; q < a + 6; q++) {
        if (me[_opp(q)] == 0) all = false;
      }
      if (all && lowestOpp >= a) return true;
    }
    return false;
  }

  static String _key(List<int> me, List<int> opp) =>
      '${me.join(',')}|${opp.join(',')}';

  /// Key of a planner result (mover = side that just moved).
  static String keyOf(Turn turn) {
    final mover = turn.result.turn.opponent;
    return _key(turn.result.slots(mover), turn.result.slots(mover.opponent));
  }
}
