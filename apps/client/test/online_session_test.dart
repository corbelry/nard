import 'package:flutter_test/flutter_test.dart';
import 'package:nard_client/game/match_setup.dart';
import 'package:nard_client/game/session.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';

void main() {
  const setup = MatchSetup(
    variant: Variant.shortNard,
    opponent: OpponentKind.online,
    localSide: Side.black,
    online: OnlineMatch(
      matchId: 'm',
      mode: QueueMode.casual,
      white: PlayerInfo(userId: '1', name: 'Elvin'),
      black: PlayerInfo(userId: '2', name: 'Nigar'),
      clock: ClockConfig.standard,
    ),
  );

  test('a server state becomes a session; the remote side is the opponent', () {
    var record = GameRecord(variant: Variant.shortNard);
    record = record.add(OpeningRoll(5, 2)); // White starts with 5-2
    var s = Session.fromServer(
      setup: setup,
      match: MatchState.start(),
      record: record,
      pending: const [Move(13, 8, 5)],
    );
    expect(s.turn, Side.white);
    expect(s.remoteToAct, isTrue);
    expect(s.board.count(Side.white, 8), 4);
    expect(s.remainingDice, [2]);
    record = record.add(
      PlayTurn(Side.white, const [Move(13, 8, 5), Move(13, 11, 2)]),
    );
    s = Session.fromServer(
      setup: setup,
      match: MatchState.start(),
      record: record,
    );
    expect(s.remoteToAct, isFalse);
    expect(s.lastTurn, hasLength(2));
    expect(setup.isRemote(Side.white), isTrue);
    expect(setup.hasRemote, isTrue);
  });

  test('a score that already counts the finished game is not counted '
      'twice (older servers)', () {
    var record = GameRecord(variant: Variant.shortNard);
    record = record
        .add(OpeningRoll(5, 2))
        .add(const OfferResignation(Side.white, WinKind.single))
        .add(const AcceptResignation(Side.black));
    final before = MatchState.start(length: 1);
    final after = before.withResult(record.replay().result!);
    for (final match in [before, after]) {
      final s = Session.fromServer(setup: setup, match: match, record: record);
      expect(s.isMatchOver, isTrue);
      expect(s.score.blackScore, 1);
    }
  });

  test('pathTo splits multi-die moves; refusals come from the server', () {
    var record = GameRecord(variant: Variant.shortNard);
    record = record.add(OpeningRoll(5, 2));
    final s = Session.fromServer(
      setup: setup,
      match: MatchState.start(),
      record: record,
    );
    expect(
      s.pathTo(13, 6),
      [const Move(13, 8, 5), const Move(8, 6, 2)].length == 2
          ? hasLength(2)
          : isEmpty,
    );
    expect(s.pathTo(24, 19), isEmpty);
    final refused = s.withSelection(13).refused(MoveRejection.pointClosed);
    expect(refused.selected, isNull);
    expect(refused.rejection, MoveRejection.pointClosed);
  });
}
