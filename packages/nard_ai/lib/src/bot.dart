import 'dart:math';

import 'package:nard_core/nard_core.dart';

/// Skill levels exposed to players (see spec §6).
enum BotLevel { beginner, easy, medium, hard, expert, master }

/// A bot picks one of the legal turns for a position and roll.
abstract interface class Bot {
  Turn chooseTurn(RuleSet rules, BoardState board, DiceRoll roll);
}

/// Picks a uniformly random legal turn. Used for tests, load generation and
/// as the floor of the strength ladder.
class RandomBot implements Bot {
  RandomBot([Random? random]) : _random = random ?? Random();

  final Random _random;

  @override
  Turn chooseTurn(RuleSet rules, BoardState board, DiceRoll roll) {
    final turns = rules.legalTurns(board, roll);
    return turns[_random.nextInt(turns.length)];
  }
}
