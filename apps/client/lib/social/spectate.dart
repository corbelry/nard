import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';

import '../game/game_actions.dart';
import '../game/game_controller.dart';
import '../game/match_setup.dart';
import '../game/session.dart';
import 'social_socket.dart';

/// What the spectator screen (6.4) shows.
class SpectatorState {
  const SpectatorState({
    this.matchId,
    this.view,
    this.unavailable = false,
    this.whiteName = '',
    this.blackName = '',
  });

  final String? matchId;
  final GameView? view;

  /// The game ended or cannot be watched.
  final bool unavailable;
  final String whiteName;
  final String blackName;
}

/// Read-only game view fed by the server's `game.state` for spectators
/// (always White's view). Every [GameActions] intent is ignored.
class SpectatorController extends Notifier<SpectatorState>
    implements GameActions {
  int _lastSeq = -1;

  @override
  SpectatorState build() => const SpectatorState();

  /// Starts watching [matchId]; the names label the two seats (the
  /// protocol does not tell spectators who plays which side).
  void watch(
    String matchId, {
    required String whiteName,
    required String blackName,
  }) {
    _lastSeq = -1;
    state = SpectatorState(
      matchId: matchId,
      whiteName: whiteName,
      blackName: blackName,
    );
    ref.read(socialSocketProvider.notifier).spectate(matchId);
  }

  void unavailable() =>
      state = SpectatorState(
        matchId: state.matchId,
        view: state.view,
        unavailable: true,
        whiteName: state.whiteName,
        blackName: state.blackName,
      );

  void onState(GameStatePayload p) {
    if (p.matchId != state.matchId || p.seq <= _lastSeq) return;
    _lastSeq = p.seq;
    final setup = MatchSetup(
      variant: p.record.variant,
      opponent: OpponentKind.passAndPlay,
      matchLength: p.match.length,
      flipBoard: false,
      hideBetweenTurns: false,
      cube: p.record.config.cubeEnabled,
      online: OnlineMatch(
        matchId: p.matchId,
        mode: QueueMode.casual,
        white: PlayerInfo(userId: 'white', name: state.whiteName),
        black: PlayerInfo(userId: 'black', name: state.blackName),
        clock: ClockConfig.standard,
      ),
    );
    final previous = state.view;
    final session = Session.fromServer(
      setup: setup,
      match: p.match,
      record: p.record,
      pending: p.pending,
    );
    // Animate the checkers of the turn just played.
    final steps = <BoardState>[];
    final last = p.record.actions.isEmpty ? null : p.record.actions.last;
    if (last is PlayTurn &&
        previous != null &&
        previous.session.phase == GamePhase.awaitingMove &&
        previous.session.pending.isEmpty) {
      var b = previous.session.game.board;
      for (final m in last.moves) {
        b = session.rules.applyMove(b, m);
        steps.add(b);
      }
      if (steps.isNotEmpty) steps.removeLast();
    }
    state = SpectatorState(
      matchId: state.matchId,
      whiteName: state.whiteName,
      blackName: state.blackName,
      view: GameView(
        session: session,
        revision: (previous?.revision ?? 0) + 1,
        steps: steps,
        online: OnlineExtras(
          clock: p.clock,
          commitment: p.commitment,
          opponentConnected: true,
          reconnectDeadline: null,
          serverSeed: p.serverSeed,
          clientSeeds: p.clientSeeds,
          connected: true,
          receivedAt: DateTime.now(),
        ),
      ),
    );
  }

  // ---- GameActions: spectators cannot act ----------------------------

  @override
  void tapSlot(int? slot) {}

  @override
  void drop(int from, int? to) {}

  @override
  void roll() {}

  @override
  void undo() {}

  @override
  void confirm() {}

  @override
  void pass() {}

  @override
  void offerDouble() {}

  @override
  void takeDouble() {}

  @override
  void dropDouble() {}

  @override
  void resign(WinKind kind) {}

  @override
  void nextGame() {}

  @override
  void ready() {}

  @override
  void undoLastTurn() {}

  @override
  void rematch() {}

  @override
  void leave() {
    ref.read(socialSocketProvider.notifier).stopSpectating();
    state = const SpectatorState();
  }
}

final spectatorProvider = NotifierProvider<SpectatorController, SpectatorState>(
  SpectatorController.new,
);

/// The spectated game view (null until the first state arrives).
final spectatorViewProvider = Provider<GameView?>(
  (ref) => ref.watch(spectatorProvider.select((s) => s.view)),
);
