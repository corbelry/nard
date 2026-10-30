import 'dart:convert';

import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';
import 'package:test/test.dart';

Map<String, Object?> roundTrip(Map<String, Object?> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, Object?>;

/// A short game played to a few turns, one record per step.
List<GameRecord> playedRecords(int turns) {
  var record = GameRecord(variant: Variant.shortNard);
  record = record.add(OpeningRoll(5, 2));
  final out = [record];
  var state = record.replay();
  final dice = [(3, 1), (6, 4), (2, 2), (5, 3), (4, 1), (6, 6), (3, 2)];
  for (var i = 0; i < turns && !state.isOver; i++) {
    if (state.phase == GamePhase.awaitingRoll) {
      final (a, b) = dice[i % dice.length];
      final roll = RollDice(state.turn, DiceRoll(a, b));
      record = record.add(roll);
      state = state.apply(roll);
      out.add(record);
    }
    final turns = state.planner.legalTurns;
    final play = PlayTurn(
      state.turn,
      turns.isEmpty ? const <Move>[] : turns.first.moves,
    );
    record = record.add(play);
    state = state.apply(play);
    out.add(record);
  }
  return out;
}

GameStatePayload full(
  GameRecord record, {
  int seq = 1,
  String matchId = 'm1',
  int gameIndex = 0,
  List<Move> pending = const [],
  String? serverSeed,
  Map<Side, String> clientSeeds = const {Side.white: 'w', Side.black: 'b'},
}) => GameStatePayload(
  seq: seq,
  matchId: matchId,
  gameIndex: gameIndex,
  record: record,
  match: MatchState.start(length: 3),
  pending: pending,
  clock: ClockState(
    whiteMs: 1000 + seq,
    blackMs: 2000,
    delayMs: 500,
    running: Side.white,
    sentAt: 42 + seq,
  ),
  commitment: FairDice.commitment('seed'),
  serverSeed: serverSeed,
  clientSeeds: clientSeeds,
  opponentConnected: seq.isEven,
  reconnectDeadline: seq.isEven ? null : 99,
);

void main() {
  group('auth features (ADR-048)', () {
    test('auth announces stateDelta; old clients announce nothing', () {
      const auth = AuthPayload('t', features: {ProtocolFeature.stateDelta});
      final back = AuthPayload.fromJson(roundTrip(auth.toJson()));
      expect(back.features, {ProtocolFeature.stateDelta});
      expect(back.ticket, 't');
      final old = AuthPayload.fromJson({'ticket': 't'});
      expect(old.features, isEmpty);
      expect(const AuthPayload('t').toJson(), {'ticket': 't'});
    });

    test('unknown features are kept, malformed lists refused', () {
      expect(
        AuthPayload.fromJson({
          'ticket': 't',
          'features': ['stateDelta', 'later'],
        }).features,
        {'stateDelta', 'later'},
      );
      for (final bad in [
        'stateDelta',
        [1],
        List.filled(40, 'x'),
        ['x' * 100],
      ]) {
        expect(
          () => AuthPayload.fromJson({'ticket': 't', 'features': bad}),
          throwsA(isA<ProtocolException>()),
          reason: '$bad',
        );
      }
    });
  });

  group('game.state deltas (ADR-048)', () {
    final records = playedRecords(6);

    test('a delta round-trips and parses as a delta frame', () {
      final last = full(records.last, seq: 7, pending: const [Move(13, 8, 5)]);
      final delta = last.deltaSince(records[2].actions.length);
      final json = roundTrip(delta.toJson());
      expect(json.containsKey('record'), isFalse);
      expect(json.containsKey('commitment'), isFalse);
      expect(json['delta'], isA<Map<String, Object?>>());
      final frame = GameStateFrame.fromJson(json);
      expect(frame, isA<GameStateDelta>());
      expect(frame.toJson(), delta.toJson());
      expect(frame.seq, 7);
      expect(frame.matchId, 'm1');
      expect(frame.gameIndex, 0);
      expect(
        GameStateFrame.fromJson(roundTrip(last.toJson())),
        isA<GameStatePayload>(),
      );
    });

    test('applying a delta rebuilds exactly the full state', () {
      for (var base = 0; base < records.length; base++) {
        for (var to = base; to < records.length; to++) {
          final before = full(records[base], seq: base + 1);
          final after = full(
            records[to],
            seq: to + 2,
            serverSeed: to == records.length - 1 ? 'revealed' : null,
          );
          final delta = GameStateFrame.fromJson(
            roundTrip(after.deltaSince(records[base].actions.length).toJson()),
          );
          final rebuilt = (delta as GameStateDelta).applyTo(before);
          expect(rebuilt.toJson(), after.toJson(), reason: '$base → $to');
        }
      }
    });

    test('a delta that does not fit the base is a gap', () {
      final base = full(records[2]);
      final next = full(records[4], seq: 3);
      final fits = next.deltaSince(records[2].actions.length);
      expect(fits.applyTo(base).record.actions, records[4].actions);
      expect(
        () => next.deltaSince(records[1].actions.length).applyTo(base),
        throwsA(isA<StateGapException>()),
      );
      expect(
        () => fits.applyTo(full(records[2], matchId: 'other')),
        throwsA(isA<StateGapException>()),
      );
      expect(
        () => fits.applyTo(full(records[2], gameIndex: 1)),
        throwsA(isA<StateGapException>()),
      );
      expect(const StateGapException('x').toString(), contains('x'));
    });

    test('malformed deltas are refused', () {
      final json = roundTrip(full(records[3]).deltaSince(1).toJson());
      for (final bad in <Object?>[
        {'from': -1, 'actions': <Object?>[]},
        {'from': 0},
        {
          'from': 0,
          'actions': [1],
        },
        {
          'from': 0,
          'actions': [
            {'type': 'nope'},
          ],
        },
        'x',
      ]) {
        expect(
          () => GameStateFrame.fromJson({...json, 'delta': bad}),
          throwsA(isA<ProtocolException>()),
          reason: '$bad',
        );
      }
    });

    test('match and seeds can be left out when the receiver has them', () {
      final before = full(records[3], seq: 1);
      final after = full(records[5], seq: 2);
      final delta = after.deltaSince(
        records[3].actions.length,
        withMatch: false,
        withSeeds: false,
      );
      final json = roundTrip(delta.toJson());
      expect(json.containsKey('match'), isFalse);
      expect(json.containsKey('clientSeeds'), isFalse);
      final back = GameStateFrame.fromJson(json) as GameStateDelta;
      expect(back.match, isNull);
      expect(back.clientSeeds, isNull);
      expect(back.applyTo(before).toJson(), after.toJson());
      // Present means replaced, even by an empty map.
      final seeded = full(records[5], seq: 3, clientSeeds: const {});
      expect(
        seeded
            .deltaSince(records[3].actions.length)
            .applyTo(before)
            .clientSeeds,
        isEmpty,
      );
    });

    test('a delta is far smaller than the full frame late in a game', () {
      final long = playedRecords(40).last;
      final last = full(long);
      final fullBytes = jsonEncode(last.toJson()).length;
      final deltaBytes =
          jsonEncode(last.deltaSince(long.actions.length - 1).toJson()).length;
      expect(deltaBytes * 4, lessThan(fullBytes));
    });
  });

  group('GameStateSync (ADR-048)', () {
    final records = playedRecords(5);

    test('follows full frames and deltas; drops stale frames', () {
      final sync = GameStateSync();
      var gaps = 0;
      void gap() => gaps++;
      final first = full(records[1], seq: 1);
      expect(sync.accept(first, onGap: gap), same(first));
      for (var i = 2; i < records.length; i++) {
        final want = full(records[i], seq: i);
        final got = sync.accept(
          GameStateFrame.fromJson(
            roundTrip(want.deltaSince(records[i - 1].actions.length).toJson()),
          ),
          onGap: gap,
        );
        expect(got!.toJson(), want.toJson());
      }
      expect(sync.current!.seq, records.length - 1);
      // Same or older seq: ignored.
      expect(sync.accept(full(records[1], seq: 2), onGap: gap), isNull);
      expect(gaps, 0);
      expect(sync.resyncing, isFalse);
    });

    test('a gap asks once for a resync and waits for a full frame', () {
      final sync = GameStateSync();
      var gaps = 0;
      void gap() => gaps++;
      sync.accept(full(records[1], seq: 1), onGap: gap);
      // Frame 2 was lost: frame 3 builds on it.
      final third = full(
        records[3],
        seq: 3,
      ).deltaSince(records[2].actions.length);
      expect(sync.accept(third, onGap: gap), isNull);
      expect(gaps, 1);
      expect(sync.resyncing, isTrue);
      final fourth = full(
        records[4],
        seq: 4,
      ).deltaSince(records[3].actions.length);
      expect(sync.accept(fourth, onGap: gap), isNull, reason: 'still waiting');
      expect(gaps, 1);
      final snapshot = full(records[4], seq: 4);
      expect(sync.accept(snapshot, onGap: gap), same(snapshot));
      expect(sync.resyncing, isFalse);
      final fifth = full(records[5], seq: 5);
      expect(
        sync
            .accept(fifth.deltaSince(records[4].actions.length), onGap: gap)!
            .toJson(),
        fifth.toJson(),
      );
    });

    test('a delta before any full frame, or of another match, is a gap', () {
      final sync = GameStateSync();
      var gaps = 0;
      final delta = full(records[2], seq: 2).deltaSince(1);
      expect(sync.accept(delta, onGap: () => gaps++), isNull);
      expect(gaps, 1);
      sync.reset();
      expect(sync.resyncing, isFalse);
      expect(sync.current, isNull);
      sync.accept(full(records[1], matchId: 'old', seq: 9));
      expect(sync.accept(delta, onGap: () => gaps++), isNull);
      expect(gaps, 2);
      // A full frame of a new match replaces the old one whatever its seq.
      final fresh = full(records[0], matchId: 'new');
      expect(sync.accept(fresh), same(fresh));
    });
  });
}
