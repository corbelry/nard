import 'dart:math';

/// An immutable roll of two dice.
class DiceRoll {
  /// Creates a roll; throws [ArgumentError] if a die is outside 1..6.
  DiceRoll(this.die1, this.die2) {
    if (!isValidDie(die1) || !isValidDie(die2)) {
      throw ArgumentError('Dice must be in 1..6, got $die1-$die2');
    }
  }

  final int die1;
  final int die2;

  static bool isValidDie(int value) => value >= 1 && value <= 6;

  bool get isDouble => die1 == die2;
  int get high => max(die1, die2);
  int get low => min(die1, die2);

  /// The individual moves this roll grants: four for doubles, two otherwise,
  /// sorted descending.
  List<int> get moves =>
      isDouble ? List<int>.filled(4, die1) : <int>[high, low];

  @override
  bool operator ==(Object other) =>
      other is DiceRoll && other.die1 == die1 && other.die2 == die2;

  @override
  int get hashCode => die1 * 7 + die2;

  @override
  String toString() => '$die1-$die2';
}

/// Source of dice. Offline play uses [RandomDiceSource]; online play uses the
/// server's provably-fair source (see docs/FAIRNESS.md, Phase 3).
abstract interface class DiceSource {
  DiceRoll roll();

  /// A single die, used for the opening roll.
  int rollDie();
}

/// Uniform dice from a [Random] (cryptographically secure by default).
class RandomDiceSource implements DiceSource {
  RandomDiceSource([Random? random]) : _random = random ?? Random.secure();

  final Random _random;

  @override
  int rollDie() => _random.nextInt(6) + 1;

  @override
  DiceRoll roll() => DiceRoll(rollDie(), rollDie());
}

/// Replays a fixed list of rolls; for tests and replays.
class ScriptedDiceSource implements DiceSource {
  ScriptedDiceSource({
    List<DiceRoll> rolls = const [],
    List<int> dice = const [],
  }) : _rolls = List.of(rolls),
       _dice = List.of(dice);

  final List<DiceRoll> _rolls;
  final List<int> _dice;

  @override
  DiceRoll roll() {
    if (_rolls.isEmpty) throw StateError('No scripted rolls left');
    return _rolls.removeAt(0);
  }

  @override
  int rollDie() {
    if (_dice.isEmpty) throw StateError('No scripted dice left');
    return _dice.removeAt(0);
  }
}
