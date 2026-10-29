import 'dart:math';

import 'package:nard_core/nard_core.dart';

import 'bot.dart';
import 'evaluator.dart';

/// Search depth and imperfection of one [BotLevel].
class BotProfile {
  const BotProfile({
    required this.plies,
    required this.noise,
    required this.blunderRate,
    required this.cubeNoise,
  });

  /// 1 = greedy on the evaluator; 2 = expectiminimax over the opponent's
  /// 21 rolls for the best candidates.
  final int plies;

  /// Standard deviation of the noise added to each candidate's score.
  final double noise;

  /// Chance of playing a uniformly random legal turn.
  final double blunderRate;

  /// Noise added to win probabilities in cube decisions.
  final double cubeNoise;

  static BotProfile of(BotLevel level) => switch (level) {
    BotLevel.beginner => const BotProfile(
      plies: 1,
      noise: 0.6,
      blunderRate: 0.25,
      cubeNoise: 0.15,
    ),
    BotLevel.easy => const BotProfile(
      plies: 1,
      noise: 0.25,
      blunderRate: 0.08,
      cubeNoise: 0.08,
    ),
    BotLevel.medium => const BotProfile(
      plies: 1,
      noise: 0.04,
      blunderRate: 0,
      cubeNoise: 0.03,
    ),
    // Expert and master are locked in the UI until the neural AI (Phase 6)
    // and play like hard for now (ADR-019).
    BotLevel.hard || BotLevel.expert || BotLevel.master => const BotProfile(
      plies: 2,
      noise: 0,
      blunderRate: 0,
      cubeNoise: 0,
    ),
  };
}

/// Heuristic bot: [HeuristicEvaluator] with 1- or 2-ply search, weakened by
/// noise and blunders according to its [BotLevel].
class HeuristicBot implements Bot {
  HeuristicBot(
    this.level, {
    Random? random,
    this.evaluator = const HeuristicEvaluator(),
  }) : profile = BotProfile.of(level),
       _random = random ?? Random();

  final BotLevel level;
  final BotProfile profile;
  final HeuristicEvaluator evaluator;
  final Random _random;

  /// Candidates re-scored by the 2-ply search.
  static const int searchWidth = 4;

  /// Win probability needed to offer a double.
  static const double doubleThreshold = 0.68;

  /// Win probability needed to take a double.
  static const double takeThreshold = 0.25;

  @override
  Turn chooseTurn(RuleSet rules, BoardState board, DiceRoll roll) {
    final turns = rules.legalTurns(board, roll);
    if (turns.length == 1) return turns.single;
    if (_random.nextDouble() < profile.blunderRate) {
      return turns[_random.nextInt(turns.length)];
    }
    final me = board.turn;
    final scored = [
      for (final t in turns)
        (t, evaluator.score(rules, t.result, me) + _noise(profile.noise)),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    if (profile.plies < 2) return scored.first.$1;
    var best = scored.first.$1;
    var bestValue = double.negativeInfinity;
    for (final (turn, _) in scored.take(searchWidth)) {
      final value = _expectimax(rules, turn.result, me);
      if (value > bestValue) {
        bestValue = value;
        best = turn;
      }
    }
    return best;
  }

  /// Average over the opponent's rolls of the score after its best reply.
  double _expectimax(RuleSet rules, BoardState board, Side me) {
    if (rules.isGameOver(board)) return evaluator.score(rules, board, me);
    var total = 0.0;
    for (var a = 1; a <= 6; a++) {
      for (var b = a; b <= 6; b++) {
        var worst = double.infinity;
        for (final reply in rules.legalTurns(board, DiceRoll(a, b))) {
          worst = min(worst, evaluator.score(rules, reply.result, me));
        }
        total += (a == b ? 1 : 2) * worst;
      }
    }
    return total / 36;
  }

  /// Whether [me], on roll in [board], should offer a double.
  bool shouldDouble(RuleSet rules, BoardState board, Side me) =>
      _cubeProbability(rules, board.withTurn(me), me) >= doubleThreshold;

  /// Whether [me] should take a double offered by the opponent, who is on
  /// roll in [board].
  bool shouldTake(RuleSet rules, BoardState board, Side me) =>
      _cubeProbability(rules, board.withTurn(me.opponent), me) >= takeThreshold;

  double _cubeProbability(RuleSet rules, BoardState board, Side me) =>
      evaluator.winProbability(rules, board, me) + _noise(profile.cubeNoise);

  /// Gaussian noise (Box-Muller); no randomness is consumed when [sd] is 0.
  double _noise(double sd) {
    if (sd == 0) return 0;
    final u1 = 1 - _random.nextDouble();
    final u2 = _random.nextDouble();
    return sd * sqrt(-2 * log(u1)) * cos(2 * pi * u2);
  }
}
