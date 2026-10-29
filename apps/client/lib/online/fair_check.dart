import 'package:nard_core/nard_core.dart';

/// One recorded roll next to its recomputation (FD-02…FD-05).
class RollCheck {
  const RollCheck({
    required this.n,
    required this.recorded,
    required this.opening,
    this.by,
    this.computed,
  });

  /// Roll number in the game (opening rolls included, from 0).
  final int n;

  /// The dice as played: opening rolls are White's die, Black's die.
  final DiceRoll recorded;
  final bool opening;

  /// Who rolled (null for opening rolls).
  final Side? by;

  /// Null while the server seed is still hidden.
  final DiceRoll? computed;

  bool get verifiable => computed != null;

  bool get matches =>
      computed != null &&
      computed!.die1 == recorded.die1 &&
      computed!.die2 == recorded.die2;
}

/// Fair-dice data of one game and every roll checked against it.
class FairCheck {
  const FairCheck({
    required this.commitment,
    required this.rolls,
    this.serverSeed,
    this.seedWhite,
    this.seedBlack,
  });

  final String commitment;
  final String? serverSeed;
  final String? seedWhite;
  final String? seedBlack;
  final List<RollCheck> rolls;

  /// The seed is revealed (after the game, FD-05).
  bool get revealed => serverSeed != null;

  /// sha256(serverSeed) equals the pre-game commitment; null while hidden.
  bool? get commitmentOk =>
      serverSeed == null
          ? null
          : FairDice.verifyCommitment(serverSeed!, commitment);

  /// Everything checks out: commitment and every roll.
  bool get allMatch => commitmentOk == true && rolls.every((r) => r.matches);
}

/// Recomputes every roll of [record]: one roll per [OpeningRoll] (ties
/// included, FD-04) and one per [RollDice], numbered in order. White's
/// client seed is A, Black's is B (FD-02).
FairCheck checkRolls({
  required GameRecord record,
  required String commitment,
  String? serverSeed,
  Map<Side, String> clientSeeds = const {},
}) {
  final a = clientSeeds[Side.white];
  final b = clientSeeds[Side.black];
  final canCompute = serverSeed != null && a != null && b != null;
  final rolls = <RollCheck>[];
  var n = 0;
  for (final action in record.actions) {
    final (DiceRoll? recorded, Side? by, bool opening) = switch (action) {
      OpeningRoll(:final white, :final black) => (
        DiceRoll(white, black),
        null,
        true,
      ),
      RollDice(:final roll, :final by) => (roll, by, false),
      _ => (null, null, false),
    };
    if (recorded == null) continue;
    rolls.add(
      RollCheck(
        n: n,
        recorded: recorded,
        opening: opening,
        by: by,
        computed: canCompute ? FairDice.rollAt(serverSeed, a, b, n) : null,
      ),
    );
    n++;
  }
  return FairCheck(
    commitment: commitment,
    serverSeed: serverSeed,
    seedWhite: a,
    seedBlack: b,
    rolls: rolls,
  );
}
