import 'dart:convert';
import 'dart:io';

import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';
import 'package:test/test.dart';

const white = PlayerInfo(userId: '1', name: 'Elvin', country: 'AZ');
const black = PlayerInfo(userId: '2', name: 'Nigar');

const assignment = TournamentMatchPayload(
  matchId: 't7-1-0',
  tournamentId: '7',
  round: 1,
  variant: Variant.shortNard,
  matchLength: 5,
  white: white,
  black: black,
);

void main() {
  test('tournament match assignments round-trip and are validated', () {
    final back = TournamentMatchPayload.fromJson(
      jsonDecode(jsonEncode(assignment.toJson())) as Map<String, Object?>,
    );
    expect(back.matchId, 't7-1-0');
    expect(back.tournamentId, '7');
    expect(back.round, 1);
    expect(back.noShowSeconds, 180);
    expect(back.white.country, 'AZ');
    expect(back.black.name, 'Nigar');
    Map<String, Object?> bad(String key, Object? value) => {
      ...jsonDecode(jsonEncode(assignment.toJson())) as Map<String, Object?>,
      key: value,
    };
    for (final (key, value) in [
      ('matchLength', 4),
      ('round', 0),
      ('noShowSeconds', 0),
      ('variant', 'chess'),
      ('black', white.toJson()),
      ('black', const PlayerInfo(userId: 'b', name: 'B', bot: true).toJson()),
    ]) {
      expect(
        () => TournamentMatchPayload.fromJson(bad(key, value)),
        throwsA(isA<ProtocolException>()),
        reason: key,
      );
    }
  });

  test('ready, ready state, walkover and no-show round-trip', () {
    expect(
      TournamentReadyPayload.fromJson(
        const TournamentReadyPayload('m1').toJson(),
      ).matchId,
      'm1',
    );
    final state = TournamentReadyStatePayload.fromJson(
      const TournamentReadyStatePayload(
        matchId: 'm1',
        tournamentId: '7',
        round: 2,
        you: Side.black,
        white: white,
        black: black,
        ready: {Side.white: true},
        deadline: 60000,
        noShowSeconds: 180,
      ).toJson(),
    );
    expect(state.noShowSeconds, 180);
    expect(state.you, Side.black);
    expect(state.ready, {Side.white: true, Side.black: false});
    expect(state.deadline, 60000);
    // Older servers did not send it: the default no-show wait (#35).
    final legacy = state.toJson()..remove('noShowSeconds');
    expect(TournamentReadyStatePayload.fromJson(legacy).noShowSeconds, 180);
    final walkover = TournamentWalkoverPayload.fromJson(
      const TournamentWalkoverPayload(
        matchId: 'm1',
        tournamentId: '7',
        winner: Side.white,
      ).toJson(),
    );
    expect(walkover.winner, Side.white);
    expect(
      TournamentWalkoverPayload.fromJson(const {
        'matchId': 'm1',
        'tournamentId': '7',
      }).winner,
      isNull,
    );
    final noShow = TournamentNoShow.fromJson(
      const TournamentNoShow(
        matchId: 'm1',
        tournamentId: '7',
        endedAt: 5,
      ).toJson(),
    );
    expect(
      (noShow.matchId, noShow.tournamentId, noShow.endedAt),
      ('m1', '7', 5),
    );
    for (final t in [
      MessageType.tournamentReady,
      MessageType.tournamentReadyState,
      MessageType.tournamentWalkover,
    ]) {
      expect(MessageType.all, contains(t));
    }
  });

  test('tournament mode: never queued, carried by match.found and results', () {
    expect(
      () => QueueJoinPayload.fromJson({
        'variant': 'shortNard',
        'matchLength': 5,
        'mode': 'tournament',
      }),
      throwsA(isA<ProtocolException>()),
    );
    final found = MatchFoundPayload.fromJson(
      const MatchFoundPayload(
        matchId: 'm1',
        variant: Variant.shortNard,
        matchLength: 5,
        mode: QueueMode.tournament,
        you: Side.white,
        white: white,
        black: black,
        clock: ClockConfig.standard,
        tournamentId: '7',
        round: 3,
      ).toJson(),
    );
    expect(
      (found.mode, found.tournamentId, found.round),
      (QueueMode.tournament, '7', 3),
    );
    const result = MatchResult(
      matchId: 'm1',
      variant: Variant.shortNard,
      matchLength: 5,
      mode: QueueMode.tournament,
      white: white,
      black: black,
      winner: Side.black,
      whiteScore: 0,
      blackScore: 5,
      reason: MatchEndReason.walkover,
      games: [],
      startedAt: 1,
      endedAt: 1,
      tournamentId: '7',
    );
    final back = MatchResult.fromJson(result.toJson());
    expect((back.reason, back.tournamentId), (MatchEndReason.walkover, '7'));
    final schema = Schemas.matchResult['properties']! as Map<String, Object?>;
    expect(result.toJson().keys.toSet(), schema.keys.toSet());
  });

  test('exported schemas match the models and the committed files', () {
    expect(
      assignment.toJson().keys.toSet(),
      (Schemas.tournamentMatch['required']! as List).toSet(),
    );
    expect(
      const TournamentNoShow(
        matchId: 'm',
        tournamentId: 't',
        endedAt: 0,
      ).toJson().keys.toSet(),
      (Schemas.tournamentNoShow['required']! as List).toSet(),
    );
    for (final e in Schemas.all.entries) {
      expect(
        jsonDecode(File('schema/${e.key}').readAsStringSync()),
        e.value,
        reason: e.key,
      );
    }
  });
}
