import 'dart:math';

import 'package:nard_core/nard_core.dart';

import 'bot.dart';
import 'evaluator.dart';
import 'heuristic_bot.dart';

/// Move quality of one player over many recorded games (fair play, spec
/// §8.14): how often the played turn reaches the same position as the
/// reference bot's choice, and the average evaluation lost to it.
class PlayerQuality {
  PlayerQuality(this.userId);

  final String userId;
  final Set<String> _matches = {};
  int games = 0;

  /// Turns with more than one distinct resulting position.
  int decisions = 0;

  /// Decisions where the played position equals the reference choice.
  int agreed = 0;

  /// Sum over decisions of `score(reference) − score(played)`, ≥ 0.
  double totalLoss = 0;

  int get matches => _matches.length;
  double get agreement => decisions == 0 ? 0 : agreed / decisions;
  double get averageLoss => decisions == 0 ? 0 : totalLoss / decisions;

  Map<String, Object?> toJson() => {
    'userId': userId,
    'matches': matches,
    'games': games,
    'decisions': decisions,
    'agreement': double.parse(agreement.toStringAsFixed(4)),
    'avgLoss': double.parse(averageLoss.toStringAsFixed(5)),
  };
}

/// Replays match records (the `games` of a MatchResult, as stored by the
/// API) and compares every human turn with [reference], by default
/// [HeuristicBot] at [BotLevel.hard] (deterministic: no noise).
///
/// Input per match: `{matchId, white: {userId}, black: {userId}, games:
/// [{record: GameRecord JSON, …}]}`. Malformed games are skipped.
class MoveQualityAnalyzer {
  MoveQualityAnalyzer({
    Bot? reference,
    this.evaluator = const HeuristicEvaluator(),
  }) : reference = reference ?? HeuristicBot(BotLevel.hard, random: Random(0));

  final Bot reference;
  final HeuristicEvaluator evaluator;
  final Map<String, PlayerQuality> _players = {};

  /// Players seen so far, in first-seen order.
  Iterable<PlayerQuality> get players => _players.values;

  /// Games that could not be replayed.
  int skippedGames = 0;

  void addMatch(Map<String, Object?> match) {
    final matchId = match['matchId'];
    final ids = {
      Side.white: _userId(match['white']),
      Side.black: _userId(match['black']),
    };
    final games = match['games'];
    if (matchId is! String || games is! List) return;
    for (final game in games) {
      final record = game is Map<String, Object?> ? game['record'] : null;
      if (record is! Map<String, Object?>) {
        skippedGames++;
        continue;
      }
      try {
        _addGame(matchId, GameRecord.fromJson(record), ids);
      } on Object {
        // FormatException, IllegalActionException, bad casts: a record this
        // version cannot replay is left out rather than guessed at.
        skippedGames++;
      }
    }
  }

  void _addGame(String matchId, GameRecord record, Map<Side, String?> ids) {
    final rules = rulesFor(record.variant);
    var state = GameState.newGame(rules, config: record.config);
    final seen = <Side>{};
    for (final action in record.actions) {
      if (action is PlayTurn && state.phase == GamePhase.awaitingMove) {
        final userId = ids[action.by];
        if (userId != null) {
          seen.add(action.by);
          _score(_player(userId), rules, state, action);
        }
      }
      state = state.apply(action);
    }
    for (final side in seen) {
      final p = _player(ids[side]!);
      p.games++;
      p._matches.add(matchId);
    }
  }

  void _score(
    PlayerQuality player,
    RuleSet rules,
    GameState state,
    PlayTurn action,
  ) {
    final turns = state.legalTurns;
    final distinct = {for (final t in turns) t.result};
    if (distinct.length < 2) return;
    final me = state.board.turn;
    final played = state.planner.play(action.moves).result;
    final best = reference.chooseTurn(rules, state.board, state.dice!).result;
    player.decisions++;
    if (played == best) {
      player.agreed++;
      return;
    }
    final loss =
        evaluator.score(rules, best, me) - evaluator.score(rules, played, me);
    player.totalLoss += max(0, loss);
  }

  PlayerQuality _player(String id) =>
      _players.putIfAbsent(id, () => PlayerQuality(id));

  static String? _userId(Object? player) {
    if (player is! Map<String, Object?>) return null;
    final id = player['userId'];
    return id is String && id.isNotEmpty ? id : null;
  }
}
