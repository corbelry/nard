import 'dart:convert';
import 'dart:math';

import 'package:nard_core/nard_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

GameResult _win(Side winner, int points) => GameResult(
  winner: winner,
  kind: WinKind.single,
  cubeValue: points,
  points: points,
  reason: GameEndReason.bearOff,
);

/// Plays a random Short or Long Nard game and returns its record.
GameRecord _randomRecord(Variant variant, int seed) {
  final rng = Random(seed);
  var record = GameRecord(variant: variant);
  var g = GameState.newGame(rulesFor(variant));
  void act(GameAction a) {
    g = g.apply(a);
    record = record.add(a);
  }

  act(OpeningRoll(3, 3));
  act(OpeningRoll(5, 2));
  var doubled = false;
  while (!g.isOver) {
    if (g.phase == GamePhase.awaitingRoll) {
      if (!doubled && g.canDouble(g.turn)) {
        doubled = true;
        act(OfferDouble(g.turn));
        act(TakeDouble(g.turn.opponent));
      }
      act(RollDice(g.turn, DiceRoll(rng.nextInt(6) + 1, rng.nextInt(6) + 1)));
    }
    final turns = g.legalTurns;
    act(PlayTurn(g.turn, turns[rng.nextInt(turns.length)].moves));
  }
  return record;
}

void main() {
  group('MatchState', () {
    test('money session accumulates and never ends', () {
      var m = MatchState.start(jacoby: true);
      expect(m.isMoney, isTrue);
      expect(m.jacoby, isTrue);
      for (var i = 0; i < 10; i++) {
        m = m.withResult(_win(Side.white, 4));
      }
      expect(m.whiteScore, 40);
      expect(m.isOver, isFalse);
      expect(m.winner, isNull);
      expect(m.isCrawfordGame, isFalse);
      expect(m.gameConfig().jacoby, isTrue);
      expect(m.gameConfig().cubeEnabled, isTrue);
    });

    test('jacoby is ignored in match play', () {
      expect(MatchState.start(length: 5, jacoby: true).jacoby, isFalse);
      expect(() => MatchState.start(length: -1), throwsArgumentError);
    });

    test('MT-03 Crawford: the game after first reaching match point has no '
        'cube; afterwards the cube is back', () {
      var m = MatchState.start(length: 5);
      m = m.withResult(_win(Side.white, 2)); // 2-0
      expect(m.isCrawfordGame, isFalse);
      m = m.withResult(_win(Side.white, 2)); // 4-0 -> Crawford
      expect(m.isCrawfordGame, isTrue);
      expect(m.away(Side.white), 1);
      expect(m.gameConfig().cubeEnabled, isFalse);
      m = m.withResult(_win(Side.black, 1)); // 4-1, Crawford game done
      expect(m.isCrawfordGame, isFalse);
      expect(m.isPostCrawford, isTrue);
      expect(m.gameConfig().cubeEnabled, isTrue);
      m = m.withResult(_win(Side.black, 3)); // 4-4 post-Crawford: no new one
      expect(m.isCrawfordGame, isFalse);
      expect(m.gameConfig().cubeEnabled, isTrue);
      m = m.withResult(_win(Side.black, 1));
      expect(m.isOver, isTrue);
      expect(m.winner, Side.black);
      expect(m.gamesPlayed, 5);
      expect(() => m.withResult(_win(Side.white, 1)), throwsStateError);
    });

    test(
      'MT-02 a win beyond the match length ends the match without Crawford',
      () {
        var m = MatchState.start(length: 3);
        m = m.withResult(_win(Side.white, 4));
        expect(m.isOver, isTrue);
        expect(m.winner, Side.white);
        expect(m.isCrawfordGame, isFalse);
      },
    );

    test('JSON round trip', () {
      final m = MatchState.start(length: 7).withResult(_win(Side.black, 6));
      final back = MatchState.fromJson(
        jsonDecode(jsonEncode(m.toJson())) as Map<String, Object?>,
      );
      expect(back.toJson(), m.toJson());
      expect(back.isCrawfordGame, isTrue);
      expect(m.toString(), contains('Crawford'));
      expect(MatchState.start().toString(), contains('money'));
    });
  });

  group('GameRecord', () {
    for (final variant in Variant.values) {
      test('${variant.name}: JSON round trip replays to the same result', () {
        final record = _randomRecord(variant, variant.index + 10);
        final original = record.replay();
        expect(original.isOver, isTrue);
        final json = jsonEncode(record.toJson());
        final restored = GameRecord.fromJson(
          jsonDecode(json) as Map<String, Object?>,
        );
        expect(restored.actions.length, record.actions.length);
        final replayed = restored.replay();
        expect(replayed.board, original.board);
        expect(replayed.result!.toJson(), original.result!.toJson());
        expect(replayed.cube, original.cube);
      });
    }

    test('a tampered record fails validation on replay', () {
      final record = _randomRecord(Variant.shortNard, 1);
      final json = record.toJson();
      final actions = (json['actions']! as List).cast<Map<String, Object?>>();
      final idx = actions.indexWhere(
        (a) => a['type'] == 'turn' && (a['moves']! as List).isNotEmpty,
      );
      final moves =
          (actions[idx]['moves']! as List).cast<Map<String, Object?>>();
      moves.first['to'] = (moves.first['to']! as int) - 1;
      expect(
        () => GameRecord.fromJson(json).replay(),
        throwsA(isA<IllegalMoveException>()),
      );
    });

    test('rejects unknown versions and action types', () {
      expect(() => GameRecord.fromJson({'version': 2}), throwsFormatException);
      expect(
        () => GameAction.fromJson({'type': 'teleport'}),
        throwsFormatException,
      );
    });

    test('every action type serialises', () {
      final actions = <GameAction>[
        OpeningRoll(1, 2),
        RollDice(Side.white, DiceRoll(3, 4)),
        PlayTurn(Side.black, const [Move(13, 9, 4, hit: true), Move(9, 6, 3)]),
        const OfferDouble(Side.white),
        const TakeDouble(Side.black),
        const DropDouble(Side.black),
        const OfferResignation(Side.white, WinKind.gammon),
        const AcceptResignation(Side.black),
        const RejectResignation(Side.black),
        const Forfeit(Side.white, WinKind.backgammon),
      ];
      for (final a in actions) {
        final back = GameAction.fromJson(
          jsonDecode(jsonEncode(a.toJson())) as Map<String, Object?>,
        );
        expect(back.toJson(), a.toJson());
        expect(back.type, a.type);
      }
    });

    test('rulesFor maps variants', () {
      expect(rulesFor(Variant.shortNard), isA<ShortNardRules>());
      expect(rulesFor(Variant.longNard), isA<LongNardRules>());
      expect(longRules.variant, Variant.longNard);
    });
  });
}
