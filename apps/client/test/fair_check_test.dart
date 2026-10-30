import 'package:flutter_test/flutter_test.dart';
import 'package:nard_client/online/fair_check.dart';
import 'package:nard_core/nard_core.dart';

void main() {
  const a = 'white-seed';
  final serverSeed = FairDice.newServerSeed();
  final commitment = FairDice.commitment(serverSeed);

  /// A Black seed whose roll 0 is a tie, so the opening is thrown twice.
  String tieSeed() {
    for (var i = 0; ; i++) {
      final r = FairDice.rollAt(serverSeed, a, 'b$i', 0);
      if (r.die1 == r.die2 &&
          FairDice.rollAt(serverSeed, a, 'b$i', 1).die1 !=
              FairDice.rollAt(serverSeed, a, 'b$i', 1).die2) {
        return 'b$i';
      }
    }
  }

  /// The record the server would write: opening rolls until no tie
  /// (FD-04), then a roll per turn; moves in between don't consume rolls.
  GameRecord record(String b, {int turns = 3}) {
    var rec = GameRecord(variant: Variant.shortNard);
    final dice = FairDice(
      serverSeed: serverSeed,
      clientSeedA: a,
      clientSeedB: b,
    );
    while (true) {
      final r = dice.roll();
      rec = rec.add(OpeningRoll(r.die1, r.die2));
      if (r.die1 != r.die2) break;
    }
    var side = Side.black;
    for (var i = 0; i < turns; i++) {
      rec = rec.add(PlayTurn(side.opponent, const []));
      rec = rec.add(RollDice(side, dice.roll()));
      side = side.opponent;
    }
    return rec;
  }

  test('FD-04 / FD-05: every roll incl. the opening tie is recomputed', () {
    final b = tieSeed();
    final check = checkRolls(
      record: record(b),
      commitment: commitment,
      serverSeed: serverSeed,
      clientSeeds: {Side.white: a, Side.black: b},
    );
    expect(check.revealed, isTrue);
    expect(check.commitmentOk, isTrue);
    // Tie + deciding opening roll + 3 turns.
    expect(check.rolls, hasLength(5));
    expect([for (final r in check.rolls) r.n], [0, 1, 2, 3, 4]);
    expect(check.rolls[0].opening, isTrue);
    expect(check.rolls[0].recorded.die1, check.rolls[0].recorded.die2);
    expect(check.rolls[1].opening, isTrue);
    expect(check.rolls[2].by, Side.black);
    expect(check.rolls.every((r) => r.matches), isTrue);
    expect(check.allMatch, isTrue);
  });

  test('FD-02: seeds A = White, B = Black; swapped seeds do not match', () {
    final b = tieSeed();
    final check = checkRolls(
      record: record(b),
      commitment: commitment,
      serverSeed: serverSeed,
      clientSeeds: {Side.white: b, Side.black: a},
    );
    expect(check.allMatch, isFalse);
  });

  test('a tampered roll is reported as a mismatch', () {
    final b = tieSeed();
    final honest = record(b);
    final last = honest.actions.last as RollDice;
    final fake = DiceRoll(
      last.roll.die1 == 6 ? 1 : last.roll.die1 + 1,
      last.roll.die2,
    );
    final tampered = GameRecord(
      variant: Variant.shortNard,
      actions: [
        ...honest.actions.take(honest.actions.length - 1),
        RollDice(last.by, fake),
      ],
    );
    final check = checkRolls(
      record: tampered,
      commitment: commitment,
      serverSeed: serverSeed,
      clientSeeds: {Side.white: a, Side.black: b},
    );
    expect(check.rolls.last.matches, isFalse);
    expect(check.rolls.first.matches, isTrue);
    expect(check.allMatch, isFalse);
  });

  test('FD-01: a seed that does not hash to the commitment fails', () {
    final b = tieSeed();
    final check = checkRolls(
      record: record(b),
      commitment: FairDice.commitment('other'),
      serverSeed: serverSeed,
      clientSeeds: {Side.white: a, Side.black: b},
    );
    expect(check.commitmentOk, isFalse);
    expect(check.allMatch, isFalse);
  });

  test('before the reveal only the commitment is known', () {
    final b = tieSeed();
    final check = checkRolls(
      record: record(b),
      commitment: commitment,
      clientSeeds: {Side.white: a, Side.black: b},
    );
    expect(check.revealed, isFalse);
    expect(check.commitmentOk, isNull);
    expect(check.rolls.every((r) => !r.verifiable), isTrue);
    expect(check.allMatch, isFalse);
  });
}
