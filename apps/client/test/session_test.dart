import 'package:flutter_test/flutter_test.dart';
import 'package:nard_ai/nard_ai.dart';
import 'package:nard_client/game/match_setup.dart';
import 'package:nard_client/game/session.dart';
import 'package:nard_core/nard_core.dart';

const shortSetup = MatchSetup(
  variant: Variant.shortNard,
  opponent: OpponentKind.passAndPlay,
);

void main() {
  group('Session', () {
    test('opening roll: ties are thrown again, higher die starts', () {
      var s = Session.start(shortSetup);
      expect(s.phase, GamePhase.opening);
      s = s.openingRoll(3, 3);
      expect(s.phase, GamePhase.opening);
      expect(s.openingDice, (3, 3));
      s = s.openingRoll(2, 5);
      expect(s.turn, Side.black);
      // Short Nard plays the opening dice.
      expect(s.phase, GamePhase.awaitingMove);
      expect(s.remainingDice, [5, 2]);
      expect(s.record.actions, hasLength(2));
    });

    test('Long Nard: the opening winner rolls again', () {
      final s = Session.start(
        const MatchSetup(
          variant: Variant.longNard,
          opponent: OpponentKind.passAndPlay,
        ),
      ).openingRoll(6, 1);
      expect(s.phase, GamePhase.awaitingRoll);
      expect(s.turn, Side.white);
    });

    test('select, move, undo and confirm a turn', () {
      var s = Session.start(shortSetup).openingRoll(5, 2);
      expect(s.movableFrom, containsAll([24, 13, 8, 6]));
      s = s.select(13);
      expect(s.selected, 13);
      expect(s.targetsFrom(13), containsAll([8, 11, 6]));
      s = s.move(13, 8);
      expect(s.board.count(Side.white, 8), 4);
      expect(s.remainingDice, [2]);
      expect(s.canConfirm, isFalse);
      s = s.undo();
      expect(s.pending, isEmpty);
      s = s.move(13, 6); // both dice on one checker
      expect(s.pending, hasLength(2));
      expect(s.canConfirm, isTrue);
      s = s.confirm();
      expect(s.turn, Side.black);
      expect(s.phase, GamePhase.awaitingRoll);
      expect(s.lastTurn, hasLength(2));
    });

    test('refused moves explain themselves (SN-05)', () {
      var s = Session.start(shortSetup).openingRoll(5, 2);
      s = s.move(24, 19);
      expect(s.rejection, MoveRejection.pointClosed);
      expect(s.pending, isEmpty);
      s = s.select(23);
      expect(s.rejection, MoveRejection.noChecker);
    });

    test('LN-04 selecting the head twice explains the head rule', () {
      var s = Session.start(
        const MatchSetup(
          variant: Variant.longNard,
          opponent: OpponentKind.passAndPlay,
        ),
      ).openingRoll(6, 1);
      s = s.roll(DiceRoll(5, 2)).move(24, 19);
      s = s.select(24);
      expect(s.rejection, MoveRejection.headRule);
    });

    test('a bot turn is applied for the side to move', () {
      var s = Session.start(shortSetup).openingRoll(5, 2).move(13, 6);
      s = s.confirm();
      s = s.roll(DiceRoll(6, 6));
      final turn = HeuristicBot(
        BotLevel.medium,
      ).chooseTurn(s.rules, s.game.board, s.dice!);
      s = s.playTurn(turn.moves);
      expect(s.turn, Side.white);
    });

    test('doubles, takes and drops (SN-17)', () {
      var s =
          Session.start(
            const MatchSetup(
              variant: Variant.shortNard,
              opponent: OpponentKind.passAndPlay,
              matchLength: 5,
            ),
          ).openingRoll(5, 2).move(13, 6).confirm();
      expect(s.canDouble, isTrue);
      s = s.offerDouble().takeDouble();
      expect(s.game.cube.value, 2);
      expect(s.game.cube.owner, Side.white);
      s = s.roll(DiceRoll(3, 1)).move(8, 5).move(6, 5).confirm();
      s = s.offerDouble().dropDouble();
      expect(s.isGameOver, isTrue);
      expect(s.score.score(Side.white), 2);
      expect(s.isMatchOver, isFalse);
      s = s.nextGame();
      expect(s.finished, hasLength(1));
      expect(s.phase, GamePhase.opening);
      expect(s.match.score(Side.white), 2);
    });

    test('resigning ends the match of one game', () {
      var s = Session.start(shortSetup).openingRoll(5, 2);
      s = s.resign(Side.white, WinKind.gammon);
      expect(s.isGameOver, isTrue);
      expect(s.game.result!.winner, Side.black);
      expect(s.isMatchOver, isTrue);
      expect(() => s.nextGame(), throwsStateError);
      expect(s.record.replay().result!.points, 2);
    });

    test('botToAct follows the bot side and the cube owner', () {
      var s = Session.start(
        const MatchSetup(
          variant: Variant.shortNard,
          opponent: OpponentKind.computer,
          matchLength: 3,
        ),
      );
      expect(s.botToAct, isFalse);
      s = s.openingRoll(2, 5);
      expect(s.botToAct, isTrue);
      s = s.playTurn(const [Move(13, 8, 5), Move(13, 11, 2)]);
      expect(s.botToAct, isFalse);
      s = s.offerDouble();
      expect(s.botToAct, isTrue);
    });
  });

  test('MatchSetup round-trips through JSON', () {
    const setup = MatchSetup(
      variant: Variant.longNard,
      opponent: OpponentKind.computer,
      level: BotLevel.hard,
      matchLength: 5,
      whiteName: 'A',
      blackName: 'B',
    );
    final back = MatchSetup.fromJson(setup.toJson());
    expect(back.toJson(), setup.toJson());
  });
}
