import 'package:nard_core/nard_core.dart';

import '../tournaments/tournament_models.dart' show variantFromApi;

/// Puzzle shapes of `docs/api/seasons.md` (13.x).

int _int(Object? v, [int fallback = 0]) => v is num ? v.toInt() : fallback;

/// The API board: `{white: {point: count}, black: {point: count}}`, each
/// side in its own numbering (1..24, 25 = bar), borne-off checkers
/// omitted — i.e. nard_core `BoardState.fromPoints`.
abstract final class PuzzleBoard {
  static Map<String, Map<String, int>> toJson(BoardState board) => {
    for (final side in Side.values)
      side.name: {
        for (var p = BoardState.bar; p >= 1; p--)
          if (board.count(side, p) > 0) '$p': board.count(side, p),
      },
  };

  /// [turn] is the side to move. Both sides count as having moved before
  /// (generated puzzles skip the opening turns), so Long Nard's head rule
  /// is the regular one.
  static BoardState fromJson(Object? json, Side turn) {
    Map<int, int> side(Object? v) => {
      if (v is Map)
        for (final e in v.entries)
          if (int.tryParse('${e.key}') != null && e.value is num)
            int.parse('${e.key}'): (e.value as num).toInt(),
    };
    final j = json is Map ? json : const <String, Object?>{};
    return BoardState.fromPoints(
      white: side(j['white']),
      black: side(j['black']),
      turn: turn,
      whiteTurnsTaken: 1,
      blackTurnsTaken: 1,
    );
  }
}

enum PuzzlePhase { opening, middle, bearoff }

enum PuzzleDifficulty { easy, medium, hard }

class Puzzle {
  const Puzzle({
    required this.id,
    required this.variant,
    required this.side,
    required this.dice,
    required this.board,
    this.phase = PuzzlePhase.middle,
    this.difficulty = PuzzleDifficulty.medium,
    this.rating = 1500,
    this.attemptsUsed = 0,
    this.finished = false,
    this.correct = false,
  });

  final String id;
  final Variant variant;
  final Side side;
  final DiceRoll dice;
  final BoardState board;
  final PuzzlePhase phase;
  final PuzzleDifficulty difficulty;
  final int rating;
  final int attemptsUsed;
  final bool finished;
  final bool correct;

  RuleSet get rules => rulesFor(variant);

  static Puzzle fromJson(Map<String, Object?> j) {
    final side = j['side'] == 'black' ? Side.black : Side.white;
    final dice = (j['dice'] as List?) ?? const [1, 2];
    return Puzzle(
      id: '${j['id']}',
      variant: variantFromApi(j['variant']),
      side: side,
      dice: DiceRoll(_int(dice[0], 1), _int(dice[1], 2)),
      board: PuzzleBoard.fromJson(j['board'], side),
      phase: switch (j['phase']) {
        'opening' => PuzzlePhase.opening,
        'bearoff' => PuzzlePhase.bearoff,
        _ => PuzzlePhase.middle,
      },
      difficulty: switch (j['difficulty']) {
        'easy' => PuzzleDifficulty.easy,
        'hard' => PuzzleDifficulty.hard,
        _ => PuzzleDifficulty.medium,
      },
      rating: _int(j['rating'], 1500),
      attemptsUsed: _int(j['attemptsUsed']),
      finished: j['finished'] == true,
      correct: j['correct'] == true,
    );
  }
}

/// `GET /puzzles/next` / `daily`.
class PuzzleBatch {
  const PuzzleBatch({
    this.puzzle,
    this.rating = 1500,
    this.solved = 0,
    this.total = 0,
  });

  final Puzzle? puzzle;

  /// My puzzle rating.
  final int rating;
  final int solved;
  final int total;

  static PuzzleBatch fromJson(Map<String, Object?> j) {
    final p = j['puzzle'];
    return PuzzleBatch(
      puzzle: p is Map<String, Object?> ? Puzzle.fromJson(p) : null,
      rating: _int(j['rating'], 1500),
      solved: _int(j['solved']),
      total: _int(j['total']),
    );
  }
}

class PuzzleSolution {
  const PuzzleSolution({
    required this.moves,
    this.secondBestMoves,
    this.secondBestLoss,
  });

  /// Notation, e.g. "13/7 13/10".
  final String moves;
  final String? secondBestMoves;
  final double? secondBestLoss;
}

class AttemptResult {
  const AttemptResult({
    required this.attempt,
    required this.correct,
    required this.finished,
    required this.attemptsLeft,
    required this.ratingDelta,
    required this.rating,
    this.solution,
  });

  final int attempt;
  final bool correct;
  final bool finished;
  final int attemptsLeft;
  final int ratingDelta;
  final int rating;

  /// Only once the puzzle is finished.
  final PuzzleSolution? solution;

  static AttemptResult fromJson(Map<String, Object?> j) {
    final s = j['solution'];
    PuzzleSolution? solution;
    if (s is Map) {
      final second = s['secondBest'];
      solution = PuzzleSolution(
        moves: '${s['moves'] ?? ''}',
        secondBestMoves: second is Map ? second['moves'] as String? : null,
        secondBestLoss:
            second is Map && second['loss'] is num
                ? (second['loss'] as num).toDouble()
                : null,
      );
    }
    return AttemptResult(
      attempt: _int(j['attempt'], 1),
      correct: j['correct'] == true,
      finished: j['finished'] == true,
      attemptsLeft: _int(j['attemptsLeft']),
      ratingDelta: _int(j['ratingDelta']),
      rating: _int(j['rating'], 1500),
      solution: solution,
    );
  }
}
