import 'dart:convert';
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

/// Every `game.state` one receiver got, decoded from the wire.
class Receiver {
  final frames = <Map<String, Object?>>[];
  final sync = GameStateSync();
  final rebuilt = <GameStatePayload>[];
  int gaps = 0;

  void take(Envelope e) {
    if (e.type != MessageType.gameState) return;
    final json = jsonDecode(jsonEncode(e.payload)) as Map<String, Object?>;
    frames.add(json);
    final s = sync.accept(GameStateFrame.fromJson(json), onGap: () => gaps++);
    if (s != null) rebuilt.add(s);
  }

  int get fulls => frames.where((f) => f.containsKey('record')).length;
  int get deltas => frames.where((f) => f.containsKey('delta')).length;
  int get bytes => frames.fold(0, (a, f) => a + jsonEncode(f).length);
}

MatchRoom room(
  FakeAsync async,
  Map<Side, Receiver> players, {
  required bool Function(Side) deltas,
  int length = 1,
  void Function(MatchResult)? onEnd,
  Map<Side, BotDriver>? bots,
}) {
  final seeds = Random(2026);
  return MatchRoom(
    matchId: 'm1',
    variant: Variant.shortNard,
    matchLength: length,
    mode: QueueMode.casual,
    white: alice,
    black: bob,
    clock: const ClockConfig(reserveMs: 600000, delayMs: 600000),
    now: () => async.elapsed.inMilliseconds,
    deltas: deltas,
    // Seeded dice: the match plays out the same on every run.
    newServerSeed: () => FairDice.newServerSeed(seeds),
    send: (side, msg) {
      players[side]!.take(msg);
      bots?[side]?.receive(msg);
    },
    onEnd: onEnd ?? (_) {},
  );
}

/// The state without the fields that differ between the two seats' views.
Map<String, Object?> shared(GameStatePayload s) =>
    s.toJson()
      ..remove('opponentConnected')
      ..remove('reconnectDeadline');

void main() {
  test('bot-vs-bot match: deltas rebuild exactly the full frames', () {
    fakeAsync((async) {
      final white = Receiver(); // announces stateDelta
      final black = Receiver(); // an old client
      final fullWatcher = Receiver();
      final deltaWatcher = Receiver();
      final bots = <Side, BotDriver>{};
      MatchResult? result;
      final r = room(
        async,
        {Side.white: white, Side.black: black},
        deltas: (side) => side == Side.white,
        length: 7,
        bots: bots,
        onEnd: (x) => result = x,
      );
      for (final side in Side.values) {
        bots[side] = BotDriver(
          room: r,
          side: side,
          level: BotLevel.easy,
          random: Random(11 + side.index),
          thinking: const Duration(milliseconds: 200),
        );
      }
      r
        ..connected(Side.white)
        ..connected(Side.black)
        ..start()
        ..addSpectator('full', fullWatcher.take)
        ..addSpectator('delta', deltaWatcher.take, deltas: true);
      async.elapse(const Duration(hours: 2));
      final games = result!.games;
      expect(games.length, greaterThan(1), reason: 'several games');

      // The old client only ever gets full frames.
      expect(black.deltas, 0);
      expect(fullWatcher.deltas, 0);
      // Delta receivers: one full frame per game (plus the first), the
      // rest are deltas; nothing was lost.
      for (final x in [white, deltaWatcher]) {
        expect(x.gaps, 0);
        expect(x.fulls, lessThanOrEqualTo(games.length + 2));
        expect(x.deltas, greaterThan(x.fulls * 10));
        expect(x.rebuilt, hasLength(x.frames.length));
      }
      // Same seat view, same frame: identical states.
      expect(deltaWatcher.frames, hasLength(fullWatcher.frames.length));
      for (var i = 0; i < fullWatcher.frames.length; i++) {
        expect(
          deltaWatcher.rebuilt[i].toJson(),
          GameStatePayload.fromJson(fullWatcher.frames[i]).toJson(),
        );
      }
      // The two seats agree on everything but the opponent's connection.
      expect(white.rebuilt, hasLength(black.frames.length));
      for (var i = 0; i < black.frames.length; i++) {
        expect(
          shared(white.rebuilt[i]),
          shared(GameStatePayload.fromJson(black.frames[i])),
        );
      }
      // The rebuilt final record verifies its dice (FD-05) like the report.
      final last = white.rebuilt.last;
      expect(last.serverSeed, isNotNull);
      expect(last.record.toJson(), games.last['record']);
      expect(last.commitment, games.last['commitment']);
      expect(
        FairDice.verifyCommitment(last.serverSeed!, last.commitment),
        isTrue,
      );
      // And the point of it all: far fewer bytes.
      expect(white.bytes * 3, lessThan(black.bytes));
    });
  });

  test('a reconnect, a sync request and a new spectator get full frames', () {
    fakeAsync((async) {
      final white = Receiver();
      final black = Receiver();
      final players = {Side.white: white, Side.black: black};
      final r = room(async, players, deltas: (_) => true);
      r
        ..connected(Side.white)
        ..connected(Side.black)
        ..start();
      void play(Side side, Envelope e) => r.handle(side, e);
      play(
        Side.white,
        Envelope(
          type: MessageType.gameSeed,
          id: 'a',
          ts: 0,
          payload: const SeedPayload('a').toJson(),
        ),
      );
      play(
        Side.black,
        Envelope(
          type: MessageType.gameSeed,
          id: 'b',
          ts: 0,
          payload: const SeedPayload('b').toJson(),
        ),
      );
      final mover = r.game.turn;
      final turn = r.game.legalTurns.first;
      for (final m in turn.moves) {
        play(
          mover,
          Envelope(
            type: MessageType.gameMove,
            id: 'm',
            ts: 0,
            payload: MovePayload(m.from, m.to, die: m.die).toJson(),
          ),
        );
      }
      play(
        mover,
        const Envelope(type: MessageType.gameConfirmTurn, id: 'c', ts: 0),
      );
      expect(white.frames.last.containsKey('delta'), isTrue);
      expect(white.gaps, 0);

      // Reconnect: the new socket starts from a full frame.
      r.disconnected(Side.white);
      white.sync.reset();
      r.connected(Side.white);
      expect(white.frames.last.containsKey('record'), isTrue);
      expect(white.gaps, 0);
      expect(white.sync.current!.record.actions, isNotEmpty);

      // A lost frame: the client sees the gap and asks; the resend is full
      // and the next delta builds on it.
      white.frames.clear();
      final lost = Receiver()..sync.accept(white.sync.current!);
      r.handle(
        r.game.turn,
        const Envelope(type: MessageType.gameRoll, id: 'r', ts: 0),
      );
      // `lost` missed the roll; it gets the next broadcast only.
      r.handle(
        r.game.turn,
        const Envelope(type: MessageType.gameUndo, id: 'u', ts: 0),
      );
      lost.take(
        Envelope(
          type: MessageType.gameState,
          id: 'x',
          ts: 0,
          payload: white.frames.last,
        ),
      );
      expect(lost.gaps, 1);
      expect(lost.sync.resyncing, isTrue);
      r.resend(Side.white);
      expect(white.frames.last.containsKey('record'), isTrue);
      lost.take(
        Envelope(
          type: MessageType.gameState,
          id: 'y',
          ts: 0,
          payload: white.frames.last,
        ),
      );
      expect(lost.sync.resyncing, isFalse);
      expect(
        lost.sync.current!.record.toJson(),
        white.sync.current!.record.toJson(),
      );

      // A spectator joining mid-game gets a full frame, then deltas; a
      // resend for it is full again.
      final watcher = Receiver();
      r.addSpectator('w', watcher.take, deltas: true);
      expect(watcher.frames.single.containsKey('record'), isTrue);
      r.disconnected(Side.black);
      expect(watcher.frames.last.containsKey('delta'), isTrue);
      r.resendSpectator('w');
      expect(watcher.frames.last.containsKey('record'), isTrue);
      expect(watcher.gaps, 0);
      r.removeSpectator('w');
      r.connected(Side.black);
      expect(watcher.frames, hasLength(3));
      r.dispose();
    });
  });
}
