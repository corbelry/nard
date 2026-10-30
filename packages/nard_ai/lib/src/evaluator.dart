import 'dart:math';

import 'package:nard_core/nard_core.dart';

/// Hand-tuned position evaluator for both variants.
///
/// [score] is a logit: positive favours `me`, and
/// `score(board, me) == -score(board, me.opponent)` for every position.
/// [winProbability] maps it through the logistic function.
class HeuristicEvaluator {
  const HeuristicEvaluator();

  /// Score of a finished game; large enough to dominate any live position.
  static const double decided = 12;

  /// Pips the side to roll is worth in a race.
  static const double onRollPips = 4;

  double winProbability(RuleSet rules, BoardState board, Side me) {
    final winner = rules.winner(board);
    if (winner != null) return winner == me ? 1 : 0;
    return 1 / (1 + exp(-score(rules, board, me)));
  }

  double score(RuleSet rules, BoardState board, Side me) {
    final winner = rules.winner(board);
    if (winner != null) return winner == me ? decided : -decided;
    final opp = me.opponent;
    final myPips = board.pipCount(me);
    final oppPips = board.pipCount(opp);
    final pipScale = 0.07 * (myPips + oppPips) / 2 + 1;
    final onRoll = board.turn == me ? onRollPips : -onRollPips;
    final race = (oppPips - myPips + onRoll) / pipScale;
    if (!_contact(rules, board)) return race;
    final positional = switch (rules.variant) {
      Variant.shortNard =>
        _short(rules, board, me, pipScale) -
            _short(rules, board, opp, pipScale),
      Variant.longNard => _long(rules, board, me) - _long(rules, board, opp),
    };
    return race + positional;
  }

  /// Whether some checker still has to pass an opposing checker.
  static bool _contact(RuleSet rules, BoardState board) {
    for (final side in Side.values) {
      if (board.barCount(side) > 0) return true;
    }
    for (final side in Side.values) {
      final highest = board.highestPoint(side);
      for (var p = 1; p < highest; p++) {
        if (board.count(side.opponent, rules.opposite(p)) > 0) return true;
      }
    }
    return false;
  }

  static const _primeValue = [0.0, 0.0, 0.05, 0.15, 0.3, 0.5, 0.8];

  double _short(RuleSet rules, BoardState board, Side side, double pipScale) {
    final opp = side.opponent;
    var value = 0.0;
    final oppOnBar = board.barCount(opp) > 0;
    var run = 0;
    var bestRun = 0;
    var anchors = 0;
    for (var p = 1; p <= 24; p++) {
      final n = board.count(side, p);
      if (n >= 2) {
        run++;
        bestRun = max(bestRun, run);
        if (p <= 6) value += oppOnBar ? 0.22 : 0.1;
        if (p >= 19) anchors++;
      } else {
        run = 0;
      }
      if (n > 3) value -= 0.02 * (n - 3);
    }
    value += _primeValue[min(bestRun, 6)];
    if (anchors > 0) value += 0.15 + 0.05 * (anchors - 1);
    value -= 0.15 * board.barCount(side);
    value -= _blotRisk(rules, board, side) / pipScale;
    return value;
  }

  /// Expected pips [side] loses to hits on its blots next opposing roll
  /// (blocking points are ignored).
  static double _blotRisk(RuleSet rules, BoardState board, Side side) {
    final opp = side.opponent;
    // Opposing checkers in [side]'s numbering; the bar enters from 0.
    final shooters = <int>[
      if (board.barCount(opp) > 0) 0,
      for (var p = 1; p <= 24; p++)
        if (board.count(opp, rules.opposite(p)) > 0) p,
    ];
    final blots = [
      for (var p = 1; p <= 24; p++)
        if (board.count(side, p) == 1) p,
    ];
    if (blots.isEmpty || shooters.isEmpty) return 0;
    var total = 0.0;
    for (var a = 1; a <= 6; a++) {
      for (var b = 1; b <= 6; b++) {
        final reach = a == b ? {a, 2 * a, 3 * a, 4 * a} : {a, b, a + b};
        var worst = 0;
        for (final blot in blots) {
          for (final s in shooters) {
            if (s < blot && reach.contains(blot - s)) {
              worst = max(worst, 25 - blot);
              break;
            }
          }
        }
        total += worst;
      }
    }
    return total / 36;
  }

  static const _blockValue = [0.0, 0.0, 0.05, 0.15, 0.35, 0.6, 0.9];

  double _long(RuleSet rules, BoardState board, Side side) {
    final opp = side.opponent;
    // The opponent's rearmost checker, in its own numbering.
    final oppHighest = board.highestPoint(opp);
    var value = 0.0;
    var run = 0;
    var bestRun = 0;
    var points = 0;
    // Walk the opponent's path from its point 1 upwards.
    for (var oppPoint = 1; oppPoint <= 24; oppPoint++) {
      final mine = rules.opposite(oppPoint);
      final n = board.count(side, mine);
      if (n > 0) {
        points++;
        if (oppPoint < oppHighest) {
          value += 0.06;
          run++;
          bestRun = max(bestRun, run);
        }
        if (n > 3 && mine != rules.headPoint) value -= 0.02 * (n - 3);
      } else {
        run = 0;
      }
    }
    value += _blockValue[min(bestRun, 6)];
    value += 0.03 * min(points, 8);
    return value;
  }
}
