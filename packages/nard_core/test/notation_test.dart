import 'package:nard_core/nard_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('MoveNotation', () {
    test('formats bar, off, hits and repeated moves', () {
      expect(
        MoveNotation.format(const [
          Move(25, 22, 3, hit: true),
          Move(8, 5, 3),
          Move(8, 5, 3),
          Move(6, 0, 6),
        ]),
        'bar/22* 8/5(2) 6/off',
      );
      expect(MoveNotation.format(const []), '');
    });

    test('parses chains, repeats, bar/off aliases and separators', () {
      expect(MoveNotation.parse('13/7*/1'), [(13, 7), (7, 1)]);
      expect(MoveNotation.parse('8/5(2), 6/off'), [(8, 5), (8, 5), (6, 0)]);
      expect(MoveNotation.parse('bar/22 b/20 25/21 3/o 4/0'), [
        (25, 22),
        (25, 20),
        (25, 21),
        (3, 0),
        (4, 0),
      ]);
      expect(MoveNotation.parse('  '), isEmpty);
    });

    test('rejects malformed notation', () {
      for (final bad in [
        '13',
        '13/x',
        '7/13',
        '8/5(9)',
        '30/20',
        '8/5(0)',
        '(2)',
      ]) {
        expect(
          () => MoveNotation.parse(bad),
          throwsFormatException,
          reason: bad,
        );
      }
    });

    test('parseTurn accepts combined movements', () {
      final start = shortRules.initialState();
      final turn = MoveNotation.parseTurn(
        '24/13',
        shortRules,
        start,
        roll(6, 5),
      );
      expect(turn.result.count(Side.white, 13), 6);
      expect(turn.moves, hasLength(2));
      final doubles = MoveNotation.parseTurn(
        '13/4 24/21',
        shortRules,
        start,
        roll(3, 3),
      );
      expect(doubles.result.count(Side.white, 4), 1);
      expect(doubles.result.count(Side.white, 21), 1);
    });

    test('parseTurn resolves bear-off with a higher die', () {
      final board = BoardState.fromPoints(white: {4: 1, 3: 1}, black: {1: 15});
      final turn = MoveNotation.parseTurn(
        '4/off 3/off',
        shortRules,
        board,
        roll(6, 5),
      );
      expect(turn.result.offCount(Side.white), 15);
    });

    test('parseTurn rejects illegal plays', () {
      final start = shortRules.initialState();
      expect(
        () => MoveNotation.parseTurn('13/7', shortRules, start, roll(6, 5)),
        throwsFormatException,
      );
      expect(
        () => MoveNotation.parseTurn('12/6', shortRules, start, roll(6, 5)),
        throwsFormatException,
      );
      expect(
        () => MoveNotation.parseTurn('24/14', shortRules, start, roll(6, 5)),
        throwsFormatException,
      );
    });

    test('Long Nard notation uses own numbering', () {
      final turn = MoveNotation.parseTurn(
        '24/17',
        longRules,
        longRules.initialState(),
        roll(5, 2),
      );
      expect(pointsOf(turn.result, Side.white), {24: 14, 17: 1});
    });
  });

  group('PositionId', () {
    test('starting position is 4HPwATDgc/ABMA', () {
      expect(PositionId.encode(shortRules.initialState()), '4HPwATDgc/ABMA');
      final decoded = PositionId.decode('4HPwATDgc/ABMA');
      expect(decoded, shortRules.initialState());
    });

    test('the player on roll is encoded first', () {
      final board = BoardState.fromPoints(
        white: {BoardState.bar: 1, 6: 14},
        black: {24: 15},
      );
      final id = PositionId.encode(board);
      expect(id, isNot(PositionId.encode(board.withTurn(Side.black))));
      final asBlack = PositionId.decode(id, onRoll: Side.black);
      expect(asBlack.slots(Side.black), board.slots(Side.white));
      expect(asBlack.turn, Side.black);
    });

    test('rejects malformed IDs', () {
      expect(() => PositionId.decode('short'), throwsFormatException);
      expect(() => PositionId.decode('!!!!!!!!!!!!!!'), throwsFormatException);
      // All ones: more than 15 checkers.
      expect(() => PositionId.decode('//////////////'), throwsFormatException);
    });
  });

  group('MatchId', () {
    MatchIdData data({
      DoublingCube cube = DoublingCube.initial,
      DiceRoll? dice,
      int length = 0,
      int white = 0,
      int black = 0,
      bool crawford = false,
    }) => MatchIdData(
      cube: cube,
      onRoll: Side.black,
      turn: Side.black,
      crawford: crawford,
      gameState: MatchIdGameState.playing,
      doubled: false,
      resigned: 0,
      dice: dice,
      matchLength: length,
      whiteScore: white,
      blackScore: black,
    );

    test('new money game with player 1 on roll is cAkAAAAAAAAA', () {
      expect(MatchId.encode(data()), 'cAkAAAAAAAAA');
      expect(MatchId.decode('cAkAAAAAAAAA'), data());
    });

    test('round trips every field', () {
      final d = MatchIdData(
        cube: const DoublingCube(value: 8, owner: Side.white),
        onRoll: Side.white,
        turn: Side.black,
        crawford: true,
        gameState: MatchIdGameState.resigned,
        doubled: true,
        resigned: 2,
        dice: DiceRoll(2, 5),
        matchLength: 15,
        whiteScore: 14,
        blackScore: 9,
      );
      final id = MatchId.encode(d);
      expect(id, hasLength(12));
      final back = MatchId.decode(id);
      expect(back.dice, DiceRoll(5, 2), reason: 'dice are stored high first');
      expect(back.cube, d.cube);
      expect(back.crawford, isTrue);
      expect(back.gameState, MatchIdGameState.resigned);
      expect(back.doubled, isTrue);
      expect(back.resigned, 2);
      expect(back.matchLength, 15);
      expect(back.whiteScore, 14);
      expect(back.blackScore, 9);
      expect(back.onRoll, Side.white);
      expect(back.turn, Side.black);
      expect(back.hashCode, MatchId.decode(id).hashCode);
    });

    test('rejects invalid values', () {
      expect(
        () => MatchId.encode(data(cube: const DoublingCube(value: 3))),
        throwsArgumentError,
      );
      expect(() => MatchId.encode(data(length: 1 << 15)), throwsArgumentError);
      expect(() => MatchId.decode('abc'), throwsFormatException);
      expect(() => MatchId.decode('!!!!!!!!!!!!'), throwsFormatException);
      // Crawford flag in a money game is inconsistent.
      expect(
        () => MatchId.decode(MatchId.encode(data(crawford: true))),
        throwsFormatException,
      );
      // Score above the match length.
      expect(
        () => MatchId.decode(MatchId.encode(data(length: 3, white: 5))),
        throwsFormatException,
      );
    });
  });
}
