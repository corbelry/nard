import 'dart:convert';
import 'dart:io';

import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';
import 'package:test/test.dart';

Map<String, Object?> roundTrip(Map<String, Object?> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, Object?>;

void main() {
  const white = PlayerInfo(
    userId: 'u1',
    name: 'Elvin',
    rating: 1500,
    country: 'AZ',
  );
  const black = PlayerInfo(userId: 'bot-1', name: 'Bot', bot: true);

  test('payloads round-trip through JSON', () {
    const join = QueueJoinPayload(
      variant: Variant.longNard,
      matchLength: 5,
      mode: QueueMode.ranked,
    );
    expect(
      QueueJoinPayload.fromJson(roundTrip(join.toJson())).toJson(),
      join.toJson(),
    );

    const found = MatchFoundPayload(
      matchId: 'm1',
      variant: Variant.shortNard,
      matchLength: 3,
      mode: QueueMode.casual,
      you: Side.black,
      white: white,
      black: black,
      clock: ClockConfig.standard,
    );
    expect(
      MatchFoundPayload.fromJson(roundTrip(found.toJson())).toJson(),
      found.toJson(),
    );

    expect(const AuthPayload('t').toJson(), {'ticket': 't'});
    expect(const SeedPayload('s').toJson(), {'clientSeed': 's'});
    expect(AuthPayload.fromJson({'ticket': 'abc'}).ticket, 'abc');
    expect(SeedPayload.fromJson({'clientSeed': 'xyz'}).clientSeed, 'xyz');
    expect(MovePayload.fromJson(const MovePayload(25, 20).toJson()).to, 20);
    expect(
      MovePayload.fromJson(const MovePayload(3, 0, die: 6).toJson()).die,
      6,
    );
    expect(
      () => MovePayload.fromJson({'from': 3, 'to': 0, 'die': 7}),
      throwsA(isA<ProtocolException>()),
    );
    expect(
      ResignPayload.fromJson(const ResignPayload(WinKind.gammon).toJson()).kind,
      WinKind.gammon,
    );
    const err = ErrorPayload(
      code: ErrorCode.illegalMove,
      rejection: MoveRejection.headRule,
    );
    final back = ErrorPayload.fromJson(roundTrip(err.toJson()));
    expect(back.rejection, MoveRejection.headRule);
    expect(ErrorPayload.fromJson({'code': 'x'}).rejection, isNull);
  });

  test('game.state carries a replayable record', () {
    var record = GameRecord(variant: Variant.shortNard);
    record = record.add(OpeningRoll(5, 2));
    final state = GameStatePayload(
      seq: 3,
      matchId: 'm1',
      gameIndex: 0,
      record: record,
      match: MatchState.start(length: 3),
      pending: const [Move(13, 8, 5)],
      clock: const ClockState(
        whiteMs: 1000,
        blackMs: 2000,
        delayMs: 500,
        running: Side.white,
        sentAt: 42,
      ),
      commitment: FairDice.commitment('seed'),
      clientSeeds: const {Side.white: 'a'},
      reconnectDeadline: 99,
    );
    final back = GameStatePayload.fromJson(roundTrip(state.toJson()));
    expect(back.toJson(), state.toJson());
    expect(back.state.phase, GamePhase.awaitingMove);
    expect(back.state.planner.isValidPrefix(back.pending), isTrue);
    expect(back.clock.running, Side.white);
  });

  test('match results round-trip (API contract)', () {
    const result = MatchResult(
      matchId: 'm1',
      variant: Variant.shortNard,
      matchLength: 3,
      mode: QueueMode.ranked,
      white: white,
      black: black,
      winner: Side.white,
      whiteScore: 3,
      blackScore: 1,
      reason: MatchEndReason.completed,
      games: [
        {'record': {}, 'serverSeed': 's'},
      ],
      startedAt: 1,
      endedAt: 2,
    );
    expect(
      MatchResult.fromJson(roundTrip(result.toJson())).toJson(),
      result.toJson(),
    );
  });

  group('validation', () {
    test('rejects wrong types, ranges and unknown enum values', () {
      expect(
        () => QueueJoinPayload.fromJson({
          'variant': 'shortNard',
          'matchLength': 2,
          'mode': 'casual',
        }),
        throwsA(isA<ProtocolException>()),
      );
      expect(
        () => QueueJoinPayload.fromJson({
          'variant': 'chess',
          'matchLength': 3,
          'mode': 'casual',
        }),
        throwsA(isA<ProtocolException>()),
      );
      expect(
        () => MovePayload.fromJson({'from': 0, 'to': 3}),
        throwsA(isA<ProtocolException>()),
      );
      expect(
        () => MovePayload.fromJson({'from': '3', 'to': 1}),
        throwsA(isA<ProtocolException>()),
      );
      expect(
        () => AuthPayload.fromJson({'ticket': 'x' * 3000}),
        throwsA(isA<ProtocolException>()),
      );
      expect(() => ResignPayload.fromJson({}), throwsA(isA<FormatException>()));
      expect(
        () => GameStatePayload.fromJson({
          'record': {'version': 9},
        }),
        throwsA(isA<ProtocolException>()),
      );
      expect(const ProtocolException('x').toString(), contains('x'));
      expect(const ProtocolException('x').offset, isNull);
      expect(const ProtocolException('x').source, isNull);
    });
  });

  test('the exported schema matches MatchResult and the committed file', () {
    final required = (Schemas.matchResult['required']! as List).toSet();
    const result = MatchResult(
      matchId: 'm',
      variant: Variant.longNard,
      matchLength: 1,
      mode: QueueMode.casual,
      white: white,
      black: black,
      winner: Side.black,
      whiteScore: 0,
      blackScore: 2,
      reason: MatchEndReason.resigned,
      games: [],
      startedAt: 0,
      endedAt: 0,
    );
    expect(result.toJson().keys.toSet(), required);
    final file = File('schema/match_result.schema.json').readAsStringSync();
    expect(jsonDecode(file), Schemas.matchResult);
  });

  group('time controls (QUESTIONS #20, ADR-044)', () {
    test('each control has its clock', () {
      expect(TimeControl.values.map((t) => t.name), [
        'blitz',
        'rapid',
        'classic',
      ]);
      expect(
        (TimeControl.blitz.clock.reserveMs, TimeControl.blitz.clock.delayMs),
        (60000, 8000),
      );
      expect(TimeControl.rapid.clock.reserveMs, 180000);
      expect(TimeControl.rapid.clock.delayMs, 12000);
      expect(TimeControl.rapid.clock, same(ClockConfig.standard));
      expect(
        (
          TimeControl.classic.clock.reserveMs,
          TimeControl.classic.clock.delayMs,
        ),
        (300000, 15000),
      );
    });

    test('queue.join carries the control and defaults to rapid', () {
      const join = QueueJoinPayload(
        variant: Variant.shortNard,
        matchLength: 3,
        mode: QueueMode.casual,
        timeControl: TimeControl.blitz,
      );
      expect(join.toJson()['timeControl'], 'blitz');
      final back = QueueJoinPayload.fromJson(roundTrip(join.toJson()));
      expect(back.timeControl, TimeControl.blitz);
      expect(back.toJson(), join.toJson());
      // Older clients send no timeControl.
      final old = QueueJoinPayload.fromJson({
        'variant': 'shortNard',
        'matchLength': 3,
        'mode': 'ranked',
      });
      expect(old.timeControl, TimeControl.rapid);
      expect(join.copyWith(mode: QueueMode.ranked).toJson(), {
        ...join.toJson(),
        'mode': 'ranked',
      });
      expect(
        join.copyWith(timeControl: TimeControl.classic).timeControl,
        TimeControl.classic,
      );
    });

    test('unknown or mistyped controls are refused', () {
      for (final bad in ['daily', 'bullet', 3]) {
        expect(
          () => QueueJoinPayload.fromJson({
            'variant': 'shortNard',
            'matchLength': 3,
            'mode': 'casual',
            'timeControl': bad,
          }),
          throwsA(isA<ProtocolException>()),
          reason: '$bad',
        );
        expect(
          () => RoomCreatePayload.fromJson({
            'variant': 'shortNard',
            'matchLength': 3,
            'timeControl': bad,
          }),
          throwsA(isA<ProtocolException>()),
          reason: '$bad',
        );
      }
    });

    test('room.create carries the control and defaults to rapid', () {
      const room = RoomCreatePayload(
        variant: Variant.longNard,
        matchLength: 5,
        timeControl: TimeControl.classic,
      );
      final back = RoomCreatePayload.fromJson(roundTrip(room.toJson()));
      expect(back.timeControl, TimeControl.classic);
      expect(back.toJson(), room.toJson());
      expect(
        RoomCreatePayload.fromJson({
          'variant': 'longNard',
          'matchLength': 5,
        }).timeControl,
        TimeControl.rapid,
      );
    });

    test('match results record the control (optional in the schema)', () {
      const result = MatchResult(
        matchId: 'm1',
        variant: Variant.shortNard,
        matchLength: 1,
        mode: QueueMode.ranked,
        white: white,
        black: black,
        winner: Side.white,
        whiteScore: 1,
        blackScore: 0,
        reason: MatchEndReason.completed,
        games: [],
        startedAt: 1,
        endedAt: 2,
        timeControl: TimeControl.blitz,
      );
      final back = MatchResult.fromJson(roundTrip(result.toJson()));
      expect(back.timeControl, TimeControl.blitz);
      expect(back.toJson(), result.toJson());
      final properties =
          Schemas.matchResult['properties']! as Map<String, Object?>;
      expect(properties['timeControl'], {
        'enum': ['blitz', 'rapid', 'classic'],
      });
      expect(
        Schemas.matchResult['required']! as List,
        isNot(contains('timeControl')),
      );
      expect(
        () =>
            MatchResult.fromJson({...result.toJson(), 'timeControl': 'daily'}),
        throwsA(isA<ProtocolException>()),
      );
    });
  });

  test('game.seed is a known message type', () {
    expect(MessageType.all, contains(MessageType.gameSeed));
  });
}
