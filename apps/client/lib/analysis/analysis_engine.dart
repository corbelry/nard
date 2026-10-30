import 'dart:isolate';
import 'dart:math';

import 'package:nard_ai/nard_ai.dart';
import 'package:nard_core/nard_core.dart';

/// How a played turn compares with the best one (tournaments.md §11,
/// thresholds §19.23: ✓ < 0.04, ? 0.04–0.10, ?? ≥ 0.10).
enum EvalClass { good, mistake, blunder }

/// The analysis of one turn. Values are **evaluations** from the heuristic
/// bot (QUESTIONS #38), on the equity scale −1 … +1 for the mover: 2·p − 1
/// where p is the 2-ply win estimate after the opponent's best reply.
class MoveEval {
  const MoveEval({
    required this.side,
    required this.roll,
    required this.played,
    required this.best,
    required this.playedEquity,
    required this.bestEquity,
    required this.candidates,
  });

  final Side side;
  final DiceRoll roll;
  final List<Move> played;
  final List<Move> best;

  /// Mover's evaluation after the played / the best turn.
  final double playedEquity;
  final double bestEquity;

  /// Legal turns considered (1 = forced).
  final int candidates;

  double get loss => max(0, bestEquity - playedEquity);

  bool get isBest => loss < 1e-9;

  EvalClass get cls => classify(loss);

  /// Evaluation for White after the best play (the 10.1 bar).
  double get whiteEquity => side == Side.white ? bestEquity : -bestEquity;

  static const mistakeAt = 0.04;
  static const blunderAt = 0.10;

  static EvalClass classify(double loss) =>
      loss >= blunderAt
          ? EvalClass.blunder
          : loss >= mistakeAt
          ? EvalClass.mistake
          : EvalClass.good;
}

/// One position to analyse: the board before the move (mover on turn),
/// the dice and the moves played.
class AnalysisTask {
  const AnalysisTask({
    required this.variant,
    required this.board,
    required this.roll,
    required this.played,
  });

  final Variant variant;
  final BoardState board;
  final DiceRoll roll;
  final List<Move> played;
}

/// The heuristic bot's 2-ply search (the strongest level until the neural
/// evaluator, ADR-019 / QUESTIONS #38–39), shared with
/// `nard_ai/tool/gen_puzzles.dart` so analysis and puzzles agree.
abstract final class Analyzer {
  static const HeuristicEvaluator _evaluator = HeuristicEvaluator();

  /// Candidates (best by 1-ply) re-scored with the 2-ply search, plus the
  /// played turn.
  static const int searchWidth = 6;

  /// The turns of [record] in order (forced passes included).
  static List<AnalysisTask> tasks(GameRecord record) {
    final rules = rulesFor(record.variant);
    var state = GameState.newGame(rules, config: record.config);
    final out = <AnalysisTask>[];
    for (final action in record.actions) {
      final roll = state.dice;
      if (action is PlayTurn && roll != null) {
        out.add(
          AnalysisTask(
            variant: record.variant,
            board: state.board,
            roll: roll,
            played: action.moves,
          ),
        );
      }
      state = state.apply(action);
    }
    return out;
  }

  /// Analyses one position (synchronous; run it in an isolate).
  static MoveEval analyse(AnalysisTask task) {
    final rules = rulesFor(task.variant);
    final board = task.board;
    final me = board.turn;
    final turns = rules.legalTurns(board, task.roll);
    final playedResult = rules.apply(board, task.roll, task.played);
    if (turns.length <= 1) {
      final e = _equity(rules, playedResult, me);
      return MoveEval(
        side: me,
        roll: task.roll,
        played: task.played,
        best: task.played,
        playedEquity: e,
        bestEquity: e,
        candidates: turns.length,
      );
    }
    final byOnePly = [
      for (final t in turns) (t, _evaluator.score(rules, t.result, me)),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    final scored = <BoardState, (Turn, double)>{};
    for (final (t, _) in byOnePly.take(searchWidth)) {
      scored[t.result] = (t, _equity(rules, t.result, me));
    }
    final playedEquity =
        scored[playedResult]?.$2 ?? _equity(rules, playedResult, me);
    var best = (Turn(task.played, playedResult), playedEquity);
    for (final candidate in scored.values) {
      if (candidate.$2 > best.$2 + 1e-12) best = candidate;
    }
    return MoveEval(
      side: me,
      roll: task.roll,
      played: task.played,
      best: best.$1.moves,
      playedEquity: playedEquity,
      bestEquity: best.$2,
      candidates: turns.length,
    );
  }

  /// Every turn of [record] (tests, offline tools).
  static List<MoveEval> analyseRecord(GameRecord record) => [
    for (final t in tasks(record)) analyse(t),
  ];

  /// [task] in a fresh isolate (one per position, so the UI fills in).
  static Future<MoveEval> analyseInIsolate(AnalysisTask task) =>
      Isolate.run(() => analyse(task));

  /// 2·p − 1 for [me] after the opponent's best reply, averaged over the
  /// opponent's 36 rolls.
  static double _equity(RuleSet rules, BoardState board, Side me) {
    if (rules.isGameOver(board)) {
      return 2 * _evaluator.winProbability(rules, board, me) - 1;
    }
    var total = 0.0;
    for (var a = 1; a <= 6; a++) {
      for (var b = a; b <= 6; b++) {
        var worst = double.infinity;
        for (final reply in rules.legalTurns(board, DiceRoll(a, b))) {
          worst = min(
            worst,
            _evaluator.winProbability(rules, reply.result, me),
          );
        }
        total += (a == b ? 1 : 2) * worst;
      }
    }
    return 2 * total / 36 - 1;
  }
}
