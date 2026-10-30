import 'package:nard_core/nard_core.dart';
import 'package:test/test.dart';

// Vectors from an independent Python implementation (hmac + hashlib).
const seed = '3f9a1c0e5b7d2468ace013579bdf2468ace013579bdf2468ace013579bdf2468';

void main() {
  group('Provably fair dice (docs/FAIRNESS.md)', () {
    test('FD-01 commitment is sha256 of the server seed', () {
      expect(
        FairDice.commitment(seed),
        'c0b05b94df8f5e1004e130827fe662ba07b9feced32c6e48b73ed3497c086486',
      );
      expect(
        FairDice.verifyCommitment(seed, FairDice.commitment(seed)),
        isTrue,
      );
      expect(
        FairDice.verifyCommitment('other', FairDice.commitment(seed)),
        isFalse,
      );
    });

    test('FD-02 roll N = HMAC-SHA256(serverSeed, "A|B|N") mapped to dice', () {
      final expected = [
        (2, 1),
        (2, 6),
        (5, 5),
        (6, 4),
        (4, 3),
        (3, 1),
        (6, 3),
        (2, 2),
      ];
      for (var n = 0; n < expected.length; n++) {
        final r = FairDice.rollAt(seed, 'alice-seed', 'bob-seed', n);
        expect((r.die1, r.die2), expected[n], reason: 'roll $n');
      }
      final other = [(1, 5), (3, 5), (1, 6), (3, 4)];
      for (var n = 0; n < other.length; n++) {
        final r = FairDice.rollAt('x', '', '', n);
        expect((r.die1, r.die2), other[n]);
      }
    });

    test('FD-03 bytes >= 252 are skipped, so every face is equally likely', () {
      final counts = List.filled(7, 0);
      for (var n = 0; n < 6000; n++) {
        final r = FairDice.rollAt(seed, 'a', 'b', n);
        counts[r.die1]++;
        counts[r.die2]++;
      }
      for (var face = 1; face <= 6; face++) {
        expect(
          counts[face],
          inInclusiveRange(1800, 2200),
          reason: 'face $face',
        );
      }
    });

    test('FD-04 the source rolls in order; the opening uses one roll', () {
      final dice = FairDice(
        serverSeed: seed,
        clientSeedA: 'alice-seed',
        clientSeedB: 'bob-seed',
      );
      expect(dice.rollDie(), 2); // roll 0, first die
      final r = dice.roll(); // roll 1
      expect((r.die1, r.die2), (2, 6));
      expect(dice.nonce, 2);
      final resumed = FairDice(
        serverSeed: seed,
        clientSeedA: 'alice-seed',
        clientSeedB: 'bob-seed',
        nonce: 2,
      );
      expect(resumed.roll().die1, 5);
    });

    test('FD-05 server seeds are 64 hex chars and differ', () {
      final a = FairDice.newServerSeed();
      final b = FairDice.newServerSeed();
      expect(a, matches(RegExp(r'^[0-9a-f]{64}$')));
      expect(a, isNot(b));
    });
  });
}
