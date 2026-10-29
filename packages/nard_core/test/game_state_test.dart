import 'dart:math';

import 'package:nard_core/nard_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// A Short Nard game where White has won the opening with 3-1 and played.
GameState _blackToRoll({GameConfig config = const GameConfig()}) {
  var g = GameState.newGame(shortRules, config: config);
  g = g.apply(OpeningRoll(3, 1));
  return g.apply(PlayTurn(Side.white, g.legalTurns.first.moves));
}

void main() {
  group('Opening roll', () {
    test('SN-02 ties are re-thrown; the higher die starts with both dice', () {
      final g = GameState.newGame(shortRules);
      expect(g.phase, GamePhase.opening);
      expect(g.apply(OpeningRoll(4, 4)).phase, GamePhase.opening);
      final started = g.apply(OpeningRoll(2, 5));
      expect(started.turn, Side.black);
      expect(started.phase, GamePhase.awaitingMove);
      expect(started.dice, DiceRoll(2, 5));
      expect(
        () => started.apply(OpeningRoll(1, 2)),
        throwsA(isA<IllegalActionException>()),
      );
    });

    test('LN-13 in Long Nard the opening winner then rolls both dice', () {
      final g = GameState.newGame(longRules).apply(OpeningRoll(6, 1));
      expect(g.turn, Side.white);
      expect(g.phase, GamePhase.awaitingRoll);
      expect(g.dice, isNull);
    });

    test('OpeningRoll validates dice', () {
      expect(() => OpeningRoll(0, 3), throwsArgumentError);
    });
  });

  group('Turn flow', () {
    test('rolling and playing alternates sides', () {
      final g = _blackToRoll();
      expect(g.turn, Side.black);
      expect(g.phase, GamePhase.awaitingRoll);
      expect(
        () => g.apply(RollDice(Side.white, DiceRoll(1, 2))),
        throwsA(isA<IllegalActionException>()),
      );
      expect(() => g.planner, throwsA(isA<IllegalActionException>()));
      final rolled = g.apply(RollDice(Side.black, DiceRoll(6, 5)));
      expect(rolled.phase, GamePhase.awaitingMove);
      expect(
        () => rolled.apply(RollDice(Side.black, DiceRoll(1, 2))),
        throwsA(isA<IllegalActionException>()),
      );
      expect(
        () => rolled.apply(PlayTurn(Side.white, rolled.legalTurns.first.moves)),
        throwsA(isA<IllegalActionException>()),
      );
      expect(
        () => rolled.apply(PlayTurn(Side.black, const [])),
        throwsA(isA<IllegalMoveException>()),
      );
      final played = rolled.apply(
        PlayTurn(Side.black, rolled.legalTurns.first.moves),
      );
      expect(played.turn, Side.white);
      expect(played.phase, GamePhase.awaitingRoll);
      expect(
        () => played.apply(PlayTurn(Side.white, const [])),
        throwsA(isA<IllegalActionException>()),
      );
    });

    test('SN-08 a dance is played as an empty turn', () {
      final board = BoardState.fromPoints(
        white: {BoardState.bar: 1, 13: 14},
        black: {1: 2, 2: 2, 3: 2, 4: 2, 5: 2, 6: 3, 13: 2},
      );
      final planner = shortRules.planner(board, roll(6, 5));
      expect(planner.maxDiceUsed, 0);
      expect(planner.play(const []).result.turn, Side.black);
    });

    test('a full game ends by bear-off with a result', () {
      final rng = Random(8);
      var g = GameState.newGame(shortRules).apply(OpeningRoll(6, 2));
      while (!g.isOver) {
        if (g.phase == GamePhase.awaitingRoll) {
          g = g.apply(
            RollDice(g.turn, DiceRoll(rng.nextInt(6) + 1, rng.nextInt(6) + 1)),
          );
        }
        if (g.mustPass) {
          g = g.apply(PlayTurn(g.turn, const []));
          continue;
        }
        final turns = g.legalTurns;
        g = g.apply(PlayTurn(g.turn, turns[rng.nextInt(turns.length)].moves));
      }
      final result = g.result!;
      expect(result.reason, GameEndReason.bearOff);
      expect(g.board.offCount(result.winner), 15);
      expect(result.points, result.kind.multiplier);
      expect(result.toString(), contains(result.winner.name));
      expect(
        () => g.apply(Forfeit(Side.white, WinKind.single)),
        throwsA(isA<IllegalActionException>()),
      );
    });
  });

  group('SN-17 doubling cube', () {
    test('double only before rolling, by the side to move', () {
      final g = _blackToRoll();
      expect(g.canDouble(Side.black), isTrue);
      expect(g.canDouble(Side.white), isFalse);
      expect(
        () => g.apply(const OfferDouble(Side.white)),
        throwsA(isA<IllegalActionException>()),
      );
      final rolled = g.apply(RollDice(Side.black, DiceRoll(1, 2)));
      expect(rolled.canDouble(Side.black), isFalse);
    });

    test('take doubles the cube and gives ownership to the taker', () {
      final offered = _blackToRoll().apply(const OfferDouble(Side.black));
      expect(offered.phase, GamePhase.cubeOffered);
      expect(
        () => offered.apply(const TakeDouble(Side.black)),
        throwsA(isA<IllegalActionException>()),
      );
      expect(
        () => offered.apply(RollDice(Side.black, DiceRoll(1, 2))),
        throwsA(isA<IllegalActionException>()),
      );
      final taken = offered.apply(const TakeDouble(Side.white));
      expect(taken.cube, const DoublingCube(value: 2, owner: Side.white));
      expect(taken.phase, GamePhase.awaitingRoll);
      expect(taken.turn, Side.black);
      // The doubler no longer has access to the cube.
      expect(taken.canDouble(Side.black), isFalse);
      // After Black plays, White (the owner) may redouble.
      final rolled = taken.apply(RollDice(Side.black, DiceRoll(6, 5)));
      final whiteTurn = rolled.apply(
        PlayTurn(Side.black, rolled.legalTurns.first.moves),
      );
      expect(whiteTurn.canDouble(Side.white), isTrue);
    });

    test('drop ends the game for the current cube value', () {
      final offered = _blackToRoll()
          .apply(const OfferDouble(Side.black))
          .apply(const TakeDouble(Side.white));
      final rolled = offered.apply(RollDice(Side.black, DiceRoll(6, 5)));
      final redouble = rolled
          .apply(PlayTurn(Side.black, rolled.legalTurns.first.moves))
          .apply(const OfferDouble(Side.white));
      expect(
        () => redouble.apply(const DropDouble(Side.white)),
        throwsA(isA<IllegalActionException>()),
      );
      final dropped = redouble.apply(const DropDouble(Side.black));
      expect(dropped.isOver, isTrue);
      expect(dropped.result!.winner, Side.white);
      expect(dropped.result!.points, 2);
      expect(dropped.result!.reason, GameEndReason.doubleDropped);
    });

    test('take/drop without an offer is illegal', () {
      final g = _blackToRoll();
      expect(
        () => g.apply(const TakeDouble(Side.white)),
        throwsA(isA<IllegalActionException>()),
      );
      expect(
        () => g.apply(const DropDouble(Side.white)),
        throwsA(isA<IllegalActionException>()),
      );
    });

    test('the cube cannot exceed maxCubeValue', () {
      final g = _blackToRoll(config: const GameConfig(maxCubeValue: 2))
          .apply(const OfferDouble(Side.black))
          .apply(const TakeDouble(Side.white));
      final rolled = g.apply(RollDice(Side.black, DiceRoll(6, 5)));
      final whiteTurn = rolled.apply(
        PlayTurn(Side.black, rolled.legalTurns.first.moves),
      );
      expect(whiteTurn.canDouble(Side.white), isFalse);
    });

    test('a disabled cube (Crawford) forbids doubling', () {
      final g = _blackToRoll(config: const GameConfig(cubeEnabled: false));
      expect(g.canDouble(Side.black), isFalse);
    });
  });

  group('SN-20 resignation', () {
    test('accepted resignation scores level x cube', () {
      final g = _blackToRoll().apply(
        const OfferResignation(Side.black, WinKind.gammon),
      );
      expect(g.resignOffer, (Side.black, WinKind.gammon));
      expect(
        () => g.apply(RollDice(Side.black, DiceRoll(1, 2))),
        throwsA(isA<IllegalActionException>()),
      );
      expect(
        () => g.apply(const AcceptResignation(Side.black)),
        throwsA(isA<IllegalActionException>()),
      );
      final over = g.apply(const AcceptResignation(Side.white));
      expect(over.result!.winner, Side.white);
      expect(over.result!.points, 2);
      expect(over.result!.reason, GameEndReason.resignation);
    });

    test('rejected resignation continues the game', () {
      final g = _blackToRoll()
          .apply(const OfferResignation(Side.black, WinKind.single))
          .apply(const RejectResignation(Side.white));
      expect(g.resignOffer, isNull);
      expect(g.phase, GamePhase.awaitingRoll);
      expect(
        () => g.apply(const RejectResignation(Side.white)),
        throwsA(isA<IllegalActionException>()),
      );
      expect(
        () => g.apply(const AcceptResignation(Side.white)),
        throwsA(isA<IllegalActionException>()),
      );
    });

    test('rejecting your own offer is illegal; resign before start too', () {
      final g = _blackToRoll().apply(
        const OfferResignation(Side.black, WinKind.single),
      );
      expect(
        () => g.apply(const RejectResignation(Side.black)),
        throwsA(isA<IllegalActionException>()),
      );
      expect(
        () => GameState.newGame(
          shortRules,
        ).apply(const OfferResignation(Side.white, WinKind.single)),
        throwsA(isA<IllegalActionException>()),
      );
    });

    test('SN-18 Jacoby: gammon counts single while the cube is centred', () {
      final over = _blackToRoll(config: const GameConfig(jacoby: true))
          .apply(const OfferResignation(Side.black, WinKind.backgammon))
          .apply(const AcceptResignation(Side.white));
      expect(over.result!.kind, WinKind.backgammon);
      expect(over.result!.points, 1);
    });
  });

  test('Forfeit ends the game at any phase', () {
    final g = GameState.newGame(
      shortRules,
    ).apply(Forfeit(Side.black, WinKind.gammon));
    expect(g.result!.winner, Side.white);
    expect(g.result!.points, 2);
    expect(g.result!.reason, GameEndReason.forfeit);
  });
}
