import 'dart:math';

import 'package:nard_ai/nard_ai.dart';
import 'package:nard_core/nard_core.dart';
import 'package:test/test.dart';

void main() {
  for (final rules in [const ShortNardRules(), const LongNardRules()]) {
    test('RandomBot plays a full ${rules.variant.name} game legally', () {
      final rng = Random(1);
      final bot = RandomBot(Random(2));
      var board = rules.initialState();
      while (!rules.isGameOver(board)) {
        final roll = DiceRoll(rng.nextInt(6) + 1, rng.nextInt(6) + 1);
        final turn = bot.chooseTurn(rules, board, roll);
        expect(rules.legalTurns(board, roll), contains(turn));
        board = turn.result;
      }
      expect(rules.winner(board), isNotNull);
    });
  }
}
