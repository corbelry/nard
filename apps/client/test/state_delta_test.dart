import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nard_client/app/providers.dart';
import 'package:nard_client/data/app_settings.dart';
import 'package:nard_client/game/game_controller.dart';
import 'package:nard_client/online/account.dart';
import 'package:nard_client/online/game_socket.dart';
import 'package:nard_client/online/online_game_controller.dart';
import 'package:nard_client/social/spectate.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';

import 'store_fakes.dart';

/// Records what the controllers send; [incoming] plays the server.
class _RecordingSocket extends GameSocket {
  _RecordingSocket() : super(url: 'ws://test', ticket: () async => '');

  final sent = <(String, Map<String, Object?>)>[];
  final incoming = StreamController<Envelope>.broadcast();

  @override
  SocketStatus get current => SocketStatus.online;

  @override
  Stream<Envelope> get messages => incoming.stream;

  @override
  String send(String type, [Map<String, Object?> payload = const {}]) {
    sent.add((type, payload));
    return 'c${sent.length}';
  }

  List<Map<String, Object?>> of(String type) => [
    for (final (t, p) in sent)
      if (t == type) p,
  ];
}

class _SocketController extends OnlineGameController {
  _SocketController(this.s);

  final GameSocket s;

  @override
  GameSocket socket() => s;

  @override
  GameSocket? get activeSocket => s;
}

const _white = PlayerInfo(userId: '1', name: 'Elvin');
const _black = PlayerInfo(userId: '2', name: 'Nigar');

/// A Short Nard game a few turns long: the record after every step.
List<GameRecord> _records(int turns) {
  var record = GameRecord(variant: Variant.shortNard).add(OpeningRoll(5, 2));
  final out = [GameRecord(variant: Variant.shortNard), record];
  var state = record.replay();
  const dice = [(3, 1), (6, 4), (2, 2), (5, 3), (4, 1), (6, 6)];
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

GameStatePayload _full(GameRecord record, int seq) => GameStatePayload(
  seq: seq,
  matchId: 'm1',
  gameIndex: 0,
  record: record,
  match: MatchState.start(length: 1),
  pending: const [],
  clock: ClockState(
    whiteMs: 180000 - seq,
    blackMs: 180000,
    delayMs: 12000,
    running: Side.white,
    sentAt: seq,
  ),
  commitment: FairDice.commitment('server'),
  clientSeeds: const {Side.white: 'a', Side.black: 'b'},
);

Envelope _frame(GameStateFrame f) => Envelope(
  type: MessageType.gameState,
  id: 's${f.seq}',
  ts: 0,
  payload: f.toJson(),
);

const _found = Envelope(
  type: MessageType.matchFound,
  id: 'f',
  ts: 0,
  payload: {
    'matchId': 'm1',
    'variant': 'shortNard',
    'matchLength': 1,
    'mode': 'casual',
    'you': 'white',
    'white': {'userId': '1', 'name': 'Elvin', 'bot': false},
    'black': {'userId': '2', 'name': 'Nigar', 'bot': false},
    'clock': {'reserveMs': 180000, 'delayMs': 12000},
  },
);

(ProviderContainer, _RecordingSocket) _container() {
  final socket = _RecordingSocket();
  final container = ProviderContainer(
    overrides: [
      currentSettingsProvider.overrideWithValue(
        const AppSettings(reduceMotion: true),
      ),
      accountProvider.overrideWith(SignedIn.new),
      apiClientProvider.overrideWithValue(FakeApi()),
      onlineGameProvider.overrideWith(() => _SocketController(socket)),
    ],
  );
  addTearDown(container.dispose);
  addTearDown(socket.incoming.close);
  return (container, socket);
}

List<Map<String, Object?>> _acts(GameRecord r) => [
  for (final a in r.actions) a.toJson(),
];

/// What a game screen shows from a view.
Map<String, Object?> _shown(GameView v) => {
  'record': v.session.record.toJson(),
  'phase': v.session.phase.name,
  'board': '${v.session.game.board}',
  'commitment': v.online!.commitment,
  'seeds': {for (final e in v.online!.clientSeeds.entries) e.key.name: e.value},
  'clock': v.online!.clock.toJson(),
  'steps': v.steps.length,
};

void main() {
  test('auth announces game.state deltas (ADR-048)', () {
    final auth = GameSocket.authFor('t').toJson();
    expect(auth['ticket'], 't');
    expect(auth['features'], [ProtocolFeature.stateDelta]);
  });

  test('the controller shows the same game from deltas as from full '
      'states', () {
    final records = _records(8);
    final (fullC, _) = _container();
    final (deltaC, deltaSocket) = _container();
    final full = fullC.read(onlineGameProvider.notifier)..receive(_found);
    final delta = deltaC.read(onlineGameProvider.notifier)..receive(_found);
    for (var i = 0; i < records.length; i++) {
      final state = _full(records[i], i + 1);
      full.receive(_frame(state));
      delta.receive(
        _frame(
          i == 0
              ? state
              : state.deltaSince(
                records[i - 1].actions.length,
                withMatch: false,
                withSeeds: false,
              ),
        ),
      );
      expect(
        _shown(deltaC.read(onlineGameProvider)!),
        _shown(fullC.read(onlineGameProvider)!),
        reason: 'step $i',
      );
    }
    expect(deltaSocket.of(MessageType.gameSync), isEmpty);
    expect(
      _acts(deltaC.read(onlineGameProvider)!.session.record),
      _acts(records.last),
    );
  });

  test('a gap asks for a full state once and waits for it', () {
    final records = _records(4);
    final (container, socket) = _container();
    final game = container.read(onlineGameProvider.notifier)..receive(_found);
    game.receive(_frame(_full(records[1], 1)));
    final shown = container.read(onlineGameProvider)!.revision;
    // Frame 2 never arrived: frame 3 builds on it.
    game.receive(
      _frame(_full(records[3], 3).deltaSince(records[2].actions.length)),
    );
    expect(socket.of(MessageType.gameSync), [
      {'matchId': 'm1'},
    ]);
    expect(container.read(onlineGameProvider)!.revision, shown);
    game.receive(
      _frame(_full(records[4], 4).deltaSince(records[3].actions.length)),
    );
    expect(socket.of(MessageType.gameSync), hasLength(1));
    expect(container.read(onlineGameProvider)!.revision, shown);
    // The resent full state, then deltas again.
    game.receive(_frame(_full(records[4], 4)));
    game.receive(
      _frame(_full(records[5], 5).deltaSince(records[4].actions.length)),
    );
    expect(
      _acts(container.read(onlineGameProvider)!.session.record),
      _acts(records[5]),
    );
    expect(socket.of(MessageType.gameSync), hasLength(1));
  });

  test('spectators rebuild deltas and resync on a gap', () async {
    final records = _records(4);
    final (container, socket) = _container();
    container
        .read(spectatorProvider.notifier)
        .watch('m1', whiteName: _white.name, blackName: _black.name);
    expect(socket.of(MessageType.spectateJoin), [
      {'matchId': 'm1'},
    ]);
    Future<void> server(GameStateFrame f) async {
      socket.incoming.add(_frame(f));
      await Future<void>.delayed(Duration.zero);
    }

    await server(_full(records[1], 1));
    await server(_full(records[2], 2).deltaSince(records[1].actions.length));
    expect(
      _acts(container.read(spectatorProvider).view!.session.record),
      _acts(records[2]),
    );
    // Lost frame 3.
    await server(_full(records[4], 4).deltaSince(records[3].actions.length));
    expect(socket.of(MessageType.gameSync), [
      {'matchId': 'm1'},
    ]);
    expect(
      _acts(container.read(spectatorProvider).view!.session.record),
      _acts(records[2]),
    );
    await server(_full(records[4], 4));
    expect(
      _acts(container.read(spectatorProvider).view!.session.record),
      _acts(records[4]),
    );
  });
}
