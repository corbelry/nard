import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'dice.dart';

/// Provably fair dice (docs/FAIRNESS.md, rules FD-xx).
///
/// Roll N of a game is derived from `HMAC-SHA256(key: serverSeed,
/// message: "clientSeedA|clientSeedB|N")`: bytes below 252 map to
/// `byte % 6 + 1` (252 = 6 × 42, so no modulo bias); bytes ≥ 252 are
/// skipped. If one MAC runs out of usable bytes, the message gets a
/// `|k` suffix (k = 1, 2, …) and the next MAC continues.
///
/// The server publishes [commitment] before the game and reveals the seed
/// afterwards, so anyone can recompute every roll.
class FairDice implements DiceSource {
  FairDice({
    required this.serverSeed,
    required this.clientSeedA,
    required this.clientSeedB,
    int nonce = 0,
  }) : _nonce = nonce;

  final String serverSeed;
  final String clientSeedA;
  final String clientSeedB;
  int _nonce;

  /// Index of the next roll.
  int get nonce => _nonce;

  /// A fresh 256-bit server seed as 64 lowercase hex characters.
  static String newServerSeed([Random? random]) {
    final r = random ?? Random.secure();
    return [
      for (var i = 0; i < 32; i++)
        r.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ].join();
  }

  /// SHA-256 of the seed's UTF-8 bytes, lowercase hex.
  static String commitment(String serverSeed) =>
      sha256.convert(utf8.encode(serverSeed)).toString();

  static bool verifyCommitment(String serverSeed, String commitment) =>
      FairDice.commitment(serverSeed) == commitment.toLowerCase();

  /// Roll number [n] for the given seeds.
  static DiceRoll rollAt(
    String serverSeed,
    String clientSeedA,
    String clientSeedB,
    int n,
  ) {
    final mac = Hmac(sha256, utf8.encode(serverSeed));
    final dice = <int>[];
    for (var k = 0; dice.length < 2; k++) {
      final message = '$clientSeedA|$clientSeedB|$n${k == 0 ? '' : '|$k'}';
      for (final byte in mac.convert(utf8.encode(message)).bytes) {
        if (byte >= 252) continue;
        dice.add(byte % 6 + 1);
        if (dice.length == 2) break;
      }
    }
    return DiceRoll(dice[0], dice[1]);
  }

  @override
  DiceRoll roll() => rollAt(serverSeed, clientSeedA, clientSeedB, _nonce++);

  /// Consumes a whole roll and returns its first die.
  @override
  int rollDie() => roll().die1;
}
