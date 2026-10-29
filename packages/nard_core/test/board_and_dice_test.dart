import 'dart:math';

import 'package:nard_core/nard_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('BoardState', () {
    test('rejects wrong checker totals, negative counts and bad lengths', () {
      final ok = List<int>.filled(26, 0)..[24] = 15;
      expect(
        () => BoardState.fromSlots(white: ok, black: List.filled(26, 0)),
        throwsArgumentError,
      );
      expect(
        () => BoardState.fromSlots(white: ok, black: List.filled(25, 0)),
        throwsArgumentError,
      );
      final negative =
          List<int>.of(ok)
            ..[1] = -1
            ..[2] = 1;
      expect(
        () => BoardState.fromSlots(white: ok, black: negative),
        throwsArgumentError,
      );
      expect(
        () => BoardState.fromSlots(white: ok, black: ok, whiteTurnsTaken: -1),
        throwsArgumentError,
      );
      expect(
        () => BoardState.fromPoints(white: {26: 15}, black: {24: 15}),
        throwsArgumentError,
      );
    });

    test('equality and hash cover counts, side to move and turn counters', () {
      final a = shortRules.initialState();
      final b = shortRules.initialState();
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a.withTurn(Side.black), isNot(a));
      expect(a.withTurn(Side.black).zobrist, isNot(a.zobrist));
      expect(a.withTurn(Side.white), same(a));
      expect(a.nextTurn().nextTurn(), isNot(a)); // counters differ
      final moved = a.relocate(13, 10);
      expect(moved, isNot(a));
      expect(moved.zobrist, isNot(a.zobrist));
    });

    test('Zobrist key fits in 53 bits (web-safe)', () {
      final rng = Random(5);
      var board = shortRules.initialState();
      for (var i = 0; i < 200 && !shortRules.isGameOver(board); i++) {
        expect(board.zobrist, inInclusiveRange(0, (1 << 53) - 1));
        final turns = shortRules.legalTurns(
          board,
          DiceRoll(rng.nextInt(6) + 1, rng.nextInt(6) + 1),
        );
        board = turns[rng.nextInt(turns.length)].result;
      }
    });

    test('nextTurn passes the move and counts completed turns', () {
      final b = longRules.initialState().nextTurn();
      expect(b.turn, Side.black);
      expect(b.turnsTaken(Side.white), 1);
      expect(b.turnsTaken(Side.black), 0);
      final c = b.nextTurn();
      expect(c.turn, Side.white);
      expect(c.turnsTaken(Side.black), 1);
    });

    test('relocate hits onto the opponent bar', () {
      final b = BoardState.fromPoints(white: {13: 15}, black: {16: 1, 1: 14});
      final hit = b.relocate(13, 9, hitAt: 16);
      expect(hit.count(Side.white, 9), 1);
      expect(hit.barCount(Side.black), 1);
      expect(hit.count(Side.black, 16), 0);
    });

    test('derived helpers', () {
      final b = BoardState.fromPoints(
        white: {BoardState.bar: 1, 3: 2},
        black: {5: 3},
      );
      expect(b.offCount(Side.white), 12);
      expect(b.barCount(Side.white), 1);
      expect(b.pipCount(Side.white), 25 + 6);
      expect(b.highestPoint(Side.white), BoardState.bar);
      expect(b.allHome(Side.white), isFalse);
      expect(b.allHome(Side.black), isTrue);
      expect(
        BoardState.fromPoints(
          white: {},
          black: {1: 15},
        ).highestPoint(Side.white),
        0,
      );
      expect(b.toString(), contains('bar:1'));
      expect(b.toString(), contains('off:12'));
    });
  });

  group('Dice', () {
    test('DiceRoll validates and exposes moves', () {
      expect(() => DiceRoll(0, 3), throwsArgumentError);
      expect(() => DiceRoll(3, 7), throwsArgumentError);
      expect(DiceRoll(2, 5).moves, [5, 2]);
      expect(DiceRoll(4, 4).moves, [4, 4, 4, 4]);
      expect(DiceRoll(2, 5).isDouble, isFalse);
      expect(DiceRoll(2, 5).high, 5);
      expect(DiceRoll(2, 5).low, 2);
      expect(DiceRoll(2, 5), DiceRoll(2, 5));
      expect(DiceRoll(2, 5), isNot(DiceRoll(5, 2)));
      expect(DiceRoll(2, 5).hashCode, DiceRoll(2, 5).hashCode);
      expect(DiceRoll(2, 5).toString(), '2-5');
    });

    test('RandomDiceSource covers all faces uniformly', () {
      final source = RandomDiceSource(Random(1));
      final counts = List.filled(7, 0);
      for (var i = 0; i < 60000; i++) {
        counts[source.rollDie()]++;
      }
      expect(counts[0], 0);
      for (var f = 1; f <= 6; f++) {
        expect(counts[f], inInclusiveRange(9500, 10500));
      }
      expect(RandomDiceSource().roll(), isA<DiceRoll>());
    });

    test('ScriptedDiceSource replays and then fails', () {
      final source = ScriptedDiceSource(rolls: [DiceRoll(3, 1)], dice: [6]);
      expect(source.roll(), DiceRoll(3, 1));
      expect(source.rollDie(), 6);
      expect(source.roll, throwsStateError);
      expect(source.rollDie, throwsStateError);
    });
  });

  group('DoublingCube', () {
    test('ownership and doubling', () {
      const cube = DoublingCube.initial;
      expect(cube.isCentered, isTrue);
      expect(cube.isTurned, isFalse);
      expect(cube.isAvailableTo(Side.white), isTrue);
      final taken = cube.doubledTo(Side.black);
      expect(taken, const DoublingCube(value: 2, owner: Side.black));
      expect(taken.isAvailableTo(Side.white), isFalse);
      expect(taken.isAvailableTo(Side.black), isTrue);
      expect(DoublingCube.fromJson(taken.toJson()), taken);
      expect(DoublingCube.fromJson(cube.toJson()), cube);
      expect(
        taken.hashCode,
        const DoublingCube(value: 2, owner: Side.black).hashCode,
      );
      expect(taken.toString(), 'Cube(2, black)');
    });
  });

  test('Move and Turn value semantics', () {
    expect(const Move(25, 22, 3, hit: true).toString(), 'bar/22*');
    expect(const Move(3, 0, 5).toString(), '3/off');
    expect(const Move(3, 0, 5).isBearOff, isTrue);
    expect(const Move(25, 22, 3).isBarEntry, isTrue);
    expect(const Move(8, 5, 3).hashCode, const Move(8, 5, 3).hashCode);
    final turns = shortRules.legalTurns(shortRules.initialState(), roll(3, 1));
    final again = shortRules.legalTurns(shortRules.initialState(), roll(3, 1));
    expect(turns.first, again.first);
    expect(turns.first.hashCode, again.first.hashCode);
    expect(turns.first, isNot(turns.last));
    expect(turns.first.toString(), isNotEmpty);
  });
}
