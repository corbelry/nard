import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:game_server/src/bot_driver.dart';
import 'package:game_server/src/match_room.dart';
import 'package:nard_ai/nard_ai.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';
import 'package:test/test.dart';

const alice = PlayerInfo(userId: 'u1', name: 'Alice');
const bob = PlayerInfo(userId: 'u2', name: 'Bob');

class Harness {
  Harness(
    this.async, {
    Variant variant = Variant.shortNard,
    int length = 1,
    ClockConfig clock = const ClockConfig(reserveMs: 60000, delayMs: 5000),
  }) {
    room = MatchRoom(
      matchId: 'm1',
      variant: variant,
      matchLength: length,
      mode: QueueMode.casual,
      white: alice,
      black: bob,
      clock: clock,
      now: () => async.elapsed.inMilliseconds,
      send: (side, msg) {
        inbox[side]!.add(msg);
        bots[side]?.receive(msg);
      },
      onEnd: (r) => result = r,
    );
  }

  final FakeAsync async;
  late final MatchRoom room;
  final inbox = {Side.white: <Envelope>[], Side.black: <Envelope>[]};
  final bots = <Side, BotDriver>{};
  MatchResult? result;
  int _id = 0;

  void send(
    Side side,
    String type, [
    Map<String, Object?> payload = const {},
  ]) => room.handle(
    side,
    Envelope(type: type, id: 'c${_id++}', ts: 0, payload: payload),
  );

  Envelope last(Side side) => inbox[side]!.last;

  GameStatePayload state(Side side) => GameStatePayload.fromJson(
    inbox[side]!.lastWhere((e) => e.type == MessageType.gameState).payload,
  );

  void seeds() {
    send(Side.white, MessageType.gameSeed, const SeedPayload('a').toJson());
    send(Side.black, MessageType.gameSeed, const SeedPayload('b').toJson());
  }
}

/// Checks every roll of a finished game against its revealed seeds (FD-05).
void verifyDice(Map<String, Object?> game) {
  final record = GameRecord.fromJson(game['record']! as Map<String, Object?>);
  final seed = game['serverSeed']! as String;
  expect(
    FairDice.verifyCommitment(seed, game['commitment']! as String),
    isTrue,
  );
  final seeds = game['clientSeeds']! as Map<String, Object?>;
  final a = seeds['white']! as String;
  final b = seeds['black']! as String;
  var n = 0;
  for (final action in record.actions) {
    switch (action) {
      case OpeningRoll(:final white, :final black):
        final r = FairDice.rollAt(seed, a, b, n++);
        expect((r.die1, r.die2), (white, black));
      case RollDice(:final roll):
        expect(FairDice.rollAt(seed, a, b, n++), roll);
      default:
        break;
    }
  }
}

void main() {
  test('two bots play a full match; every roll verifies (FD-05)', () {
    fakeAsync((async) {
      final h = Harness(async, length: 3);
      for (final side in Side.values) {
        h.bots[side] = BotDriver(
          room: h.room,
          side: side,
          level: BotLevel.easy,
          random: Random(side.index),
          thinking: const Duration(milliseconds: 200),
        );
      }
      h.room
        ..connected(Side.white)
        ..connected(Side.black)
        ..start();
      async.elapse(const Duration(hours: 2));
      final r = h.result!;
      expect(r.reason, isIn([MatchEndReason.completed]));
      expect(max(r.whiteScore, r.blackScore), greaterThanOrEqualTo(3));
      expect(r.games, isNotEmpty);
      r.games.forEach(verifyDice);
      // Each game reports how it was won (missions count mars wins).
      expect(r.games.first['winner'], isIn(['white', 'black']));
      expect(r.games.first['kind'], isIn(['single', 'gammon', 'backgammon']));
      // The final state reveals the server seed.
      expect(h.state(Side.white).serverSeed, isNotNull);
      expect(MatchResult.fromJson(r.toJson()).toJson(), r.toJson());
    });
  });

  test('Long Nard bots finish too', () {
    fakeAsync((async) {
      final h = Harness(async, variant: Variant.longNard);
      for (final side in Side.values) {
        h.bots[side] = BotDriver(
          room: h.room,
          side: side,
          random: Random(7 + side.index),
          thinking: const Duration(milliseconds: 100),
        );
      }
      h.room.start();
      h.room
        ..connected(Side.white)
        ..connected(Side.black);
      async.elapse(const Duration(hours: 2));
      expect(h.result, isNotNull);
      h.result!.games.forEach(verifyDice);
    });
  });

  test('intents are validated: turn, phase and rule explanations', () {
    fakeAsync((async) {
      final h = Harness(async, variant: Variant.longNard);
      h.room
        ..connected(Side.white)
        ..connected(Side.black)
        ..start();
      h.send(Side.white, MessageType.gameRoll);
      expect(h.last(Side.white).payload['code'], ErrorCode.illegalAction);
      h.seeds();
      h.send(Side.white, MessageType.gameSeed, const SeedPayload('x').toJson());
      expect(h.last(Side.white).payload['code'], ErrorCode.illegalAction);
      final s = h.state(Side.white).state;
      expect(s.phase, GamePhase.awaitingRoll); // LN-13: winner rolls again
      final mover = s.turn;
      h.send(mover.opponent, MessageType.gameRoll);
      expect(h.last(mover.opponent).payload['code'], ErrorCode.notYourTurn);
      h.send(mover, MessageType.gameRoll);
      final rolled = h.state(mover).state;
      expect(rolled.phase, GamePhase.awaitingMove);
      // A move the dice do not allow is explained (ADR-026).
      h.send(
        mover,
        MessageType.gameMove,
        const MovePayload(24, 23, die: 1).toJson(),
      );
      final dice = rolled.dice!;
      if (dice.die1 != 1 && dice.die2 != 1) {
        expect(h.last(mover).payload['code'], ErrorCode.illegalMove);
        expect(h.last(mover).payload['rejection'], 'noMatchingDie');
      }
      h.send(mover, MessageType.gameConfirmTurn);
      expect(h.last(mover).payload['code'], ErrorCode.illegalAction);
      // Play the turn the planner offers, with an undo in between.
      final turn = rolled.legalTurns.first;
      final first = turn.moves.first;
      h.send(
        mover,
        MessageType.gameMove,
        MovePayload(first.from, first.to, die: first.die).toJson(),
      );
      expect(h.state(mover).pending, hasLength(1));
      h.send(mover, MessageType.gameUndo);
      expect(h.state(mover).pending, isEmpty);
      for (final m in turn.moves) {
        h.send(
          mover,
          MessageType.gameMove,
          MovePayload(m.from, m.to, die: m.die).toJson(),
        );
      }
      h.send(mover, MessageType.gameConfirmTurn);
      expect(h.state(mover).state.turn, mover.opponent);
      // Unknown or malformed intents.
      h.send(mover, MessageType.queueJoin);
      expect(h.last(mover).payload['code'], ErrorCode.notImplemented);
      h.send(mover, MessageType.chatEmote, const {'id': 'free text'});
      expect(h.last(mover).payload['code'], ErrorCode.badRequest);
      h.send(mover.opponent, MessageType.gameMove, const {'from': 'x'});
      expect(
        h.last(mover.opponent).payload['code'],
        isIn([ErrorCode.illegalAction, ErrorCode.badRequest]),
      );
      h.room.dispose();
    });
  });

  test('resigning ends the match at the chosen level', () {
    fakeAsync((async) {
      final h = Harness(async);
      h.room
        ..connected(Side.white)
        ..connected(Side.black)
        ..start();
      h.seeds();
      h.send(
        Side.white,
        MessageType.gameResign,
        const ResignPayload(WinKind.gammon).toJson(),
      );
      final r = h.result!;
      expect(r.winner, Side.black);
      expect(r.reason, MatchEndReason.resigned);
      expect(r.blackScore, 2);
      // Every state keeps `match` as the score before the game: the last
      // one adds the finished game to it once (clients crashed on a score
      // that already counted it).
      final last = h.state(Side.white);
      expect(last.state.isOver, isTrue);
      expect(last.match.isOver, isFalse);
      final score = last.match.withResult(last.state.result!);
      expect((score.isOver, score.blackScore), (true, 2));
      h.send(Side.white, MessageType.gameRoll);
      expect(h.last(Side.white).payload['code'], ErrorCode.notInMatch);
    });
  });

  test(
    'the clock: delay first, then the reserve; timeout loses (spec §7.3)',
    () {
      fakeAsync((async) {
        final h = Harness(
          async,
          clock: const ClockConfig(reserveMs: 10000, delayMs: 2000),
        );
        h.room
          ..connected(Side.white)
          ..connected(Side.black)
          ..start();
        h.seeds();
        final mover = h.state(Side.white).state.turn;
        async.elapse(const Duration(seconds: 5));
        h.room.resend(mover);
        final clock = h.state(mover).clock;
        expect(clock.running, mover);
        expect(clock.delayMs, 0);
        expect(mover == Side.white ? clock.whiteMs : clock.blackMs, 7000);
        async.elapse(const Duration(seconds: 8));
        expect(h.result!.reason, MatchEndReason.timeout);
        expect(h.result!.winner, mover.opponent);
        expect(
          h.inbox[mover]!.any((e) => e.type == MessageType.gameTimeout),
          isTrue,
        );
        h.result!.games.forEach(verifyDice);
      });
    },
  );

  test('reconnect within the grace keeps the match; otherwise it is lost', () {
    fakeAsync((async) {
      final h = Harness(
        async,
        clock: const ClockConfig(reserveMs: 600000, delayMs: 600000),
      );
      h.room
        ..connected(Side.white)
        ..connected(Side.black)
        ..start();
      h.room.disconnected(Side.black);
      expect(h.state(Side.white).opponentConnected, isFalse);
      expect(h.state(Side.white).reconnectDeadline, 60000);
      async.elapse(const Duration(seconds: 30));
      h.room.connected(Side.black);
      expect(h.state(Side.white).opponentConnected, isTrue);
      async.elapse(const Duration(seconds: 60));
      expect(h.result, isNull);
      h.room.disconnected(Side.white);
      async.elapse(const Duration(seconds: 61));
      expect(h.result!.reason, MatchEndReason.abandoned);
      expect(h.result!.winner, Side.black);
      expect(h.result!.blackScore, 1);
    });
  });
}
