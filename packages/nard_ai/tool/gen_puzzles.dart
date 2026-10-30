// Generates the practice puzzles ("find the best move", spec §8.8) seeded
// by the API: heuristic self-play games, keeping positions where the 2-ply
// best turn beats the second best by a clear margin.
//
// Usage (from packages/nard_ai):
//   dart run tool/gen_puzzles.dart [out.json] [perVariant]
// Default output: ../../apps/api/database/seeders/data/puzzles.json
//
// Deterministic (fixed seeds), so re-running reproduces the same file.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:nard_ai/nard_ai.dart';
import 'package:nard_core/nard_core.dart';

/// Minimum equity gap (2·Δp) between the best and the second-best turn.
const double minMargin = 0.06;

/// Candidates (by 1-ply) re-scored with the 2-ply search.
const int searchWidth = 10;

const HeuristicEvaluator evaluator = HeuristicEvaluator();

void main(List<String> args) {
  final out =
      args.isNotEmpty
          ? args[0]
          : '../../apps/api/database/seeders/data/puzzles.json';
  final perVariant = args.length > 1 ? int.parse(args[1]) : 15;
  final puzzles = <Map<String, Object?>>[
    ..._generate(const ShortNardRules(), 'sn', perVariant, 1000),
    ..._generate(const LongNardRules(), 'ln', perVariant, 2000),
  ];
  File(out)
    ..createSync(recursive: true)
    ..writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(puzzles)}\n',
    );
  stdout.writeln('Wrote ${puzzles.length} puzzles to $out');
}

List<Map<String, Object?>> _generate(
  RuleSet rules,
  String prefix,
  int count,
  int seed,
) {
  final found = <Map<String, Object?>>[];
  final seen = <int>{};
  var game = 0;
  while (found.length < count && game < 500) {
    final random = Random(seed + game);
    final bot = HeuristicBot(BotLevel.medium, random: random);
    // Puzzles from the middle of the game: skip a few turns, then take the
    // first position that qualifies (one puzzle per game for variety).
    final skip = 2 + random.nextInt(30);
    var board = rules.initialState();
    for (var ply = 0; ply < 400 && !rules.isGameOver(board); ply++) {
      final roll = DiceRoll(random.nextInt(6) + 1, random.nextInt(6) + 1);
      if (ply >= skip && !seen.contains(board.zobrist ^ roll.hashCode)) {
        final puzzle = _puzzle(rules, board, roll);
        if (puzzle != null) {
          seen.add(board.zobrist ^ roll.hashCode);
          final n = (found.length + 1).toString().padLeft(3, '0');
          found.add({'id': '$prefix-$n', ...puzzle});
          break;
        }
      }
      board = bot.chooseTurn(rules, board, roll).result;
    }
    game++;
  }
  return found;
}

/// The puzzle for [board] and [roll], or null when it is not instructive.
Map<String, Object?>? _puzzle(RuleSet rules, BoardState board, DiceRoll roll) {
  final turns = rules.legalTurns(board, roll);
  if (turns.length < 3 || turns.length > 60) return null;
  final me = board.turn;
  final byOnePly = [
    for (final t in turns) (t, evaluator.score(rules, t.result, me)),
  ]..sort((a, b) => b.$2.compareTo(a.$2));
  final scored = [
    for (final (t, _) in byOnePly.take(searchWidth))
      (t, 2 * _twoPly(rules, t.result, me) - 1),
  ]..sort((a, b) => b.$2.compareTo(a.$2));
  final (best, bestEquity) = scored[0];
  final (second, secondEquity) = scored[1];
  final margin = bestEquity - secondEquity;
  if (margin < minMargin || margin > 0.6) return null;

  final solution = MoveNotation.format(best.moves);
  // Sanity: the notation must parse back to the same position.
  final parsed = MoveNotation.parseTurn(solution, rules, board, roll);
  if (parsed.result != best.result) return null;

  // Harder: many choices, a small margin, or the greedy 1-ply pick differs.
  final greedyMisses = byOnePly.first.$1.result != best.result;
  final rating = (1350 +
          12 * min(turns.length, 40) -
          800 * margin +
          (greedyMisses ? 150 : 0))
      .clamp(1100, 1950);
  final phase =
      board.allHome(me)
          ? 'bearoff'
          : board.turnsTaken(me) < 4
          ? 'opening'
          : 'middle';
  return {
    'variant': rules.variant.name,
    'side': me.name,
    'dice': [roll.die1, roll.die2],
    'board': _points(board),
    'solution': solution,
    'resultBoard': _points(best.result),
    'secondBest': {
      'moves': MoveNotation.format(second.moves),
      'loss': double.parse(margin.toStringAsFixed(3)),
    },
    'rating': (rating / 10).round() * 10,
    'phase': phase,
    'legalTurns': turns.length,
  };
}

/// Win probability for [me] after the opponent's best reply, averaged over
/// the opponent's 36 rolls (2-ply expectiminimax).
double _twoPly(RuleSet rules, BoardState board, Side me) {
  if (rules.isGameOver(board)) {
    return evaluator.winProbability(rules, board, me);
  }
  var total = 0.0;
  for (var a = 1; a <= 6; a++) {
    for (var b = a; b <= 6; b++) {
      var worst = double.infinity;
      for (final reply in rules.legalTurns(board, DiceRoll(a, b))) {
        worst = min(worst, evaluator.winProbability(rules, reply.result, me));
      }
      total += (a == b ? 1 : 2) * worst;
    }
  }
  return total / 36;
}

/// `{white: {point: count}, black: {point: count}}`, each side in its own
/// numbering (1..24, 25 = bar; borne-off checkers are omitted).
Map<String, Map<String, int>> _points(BoardState board) => {
  for (final side in Side.values)
    side.name: {
      for (var p = BoardState.bar; p >= 1; p--)
        if (board.count(side, p) > 0) '$p': board.count(side, p),
    },
};
