import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';

import '../app/providers.dart';
import '../data/app_settings.dart';
import '../game/game_actions.dart';
import '../game/game_controller.dart';
import '../game/match_setup.dart';
import '../game/session.dart';
import '../theme/nard_tokens.dart';
import 'account.dart';
import 'game_socket.dart';
import 'online_config.dart';

enum LobbyPhase { idle, connecting, searching, found, playing, finished }

/// Matchmaking state shown by the searching (2.4) and VS (2.5) screens.
class Lobby {
  const Lobby({
    this.phase = LobbyPhase.idle,
    this.request,
    this.match,
    this.searchStartedAt,
    this.connected = false,
    this.error,
  });

  final LobbyPhase phase;
  final QueueJoinPayload? request;
  final MatchFoundPayload? match;
  final DateTime? searchStartedAt;
  final bool connected;

  /// An API/connection failure code (e.g. `offline`).
  final String? error;

  Lobby copyWith({
    LobbyPhase? phase,
    QueueJoinPayload? request,
    MatchFoundPayload? Function()? match,
    DateTime? Function()? searchStartedAt,
    bool? connected,
    String? Function()? error,
  }) => Lobby(
    phase: phase ?? this.phase,
    request: request ?? this.request,
    match: match != null ? match() : this.match,
    searchStartedAt:
        searchStartedAt != null ? searchStartedAt() : this.searchStartedAt,
    connected: connected ?? this.connected,
    error: error != null ? error() : this.error,
  );
}

/// Online play: queue, `match.found`, then the authoritative `game.state`
/// stream turned into the same [GameView] the offline game uses. Moves are
/// shown at once and sent as intents; the server's next state wins.
class OnlineGameController extends Notifier<GameView?> implements GameActions {
  GameSocket? _socket;
  StreamSubscription<Envelope>? _sub;
  StreamSubscription<SocketStatus>? _statusSub;
  Timer? _rollTimer;
  int _lastSeq = -1;
  MatchSetup? _setup;

  @override
  GameView? build() {
    ref.onDispose(_dispose);
    return null;
  }

  AppSettings get _settings => ref.read(currentSettingsProvider);

  void _dispose() {
    _rollTimer?.cancel();
    unawaited(_sub?.cancel());
    unawaited(_statusSub?.cancel());
    unawaited(_socket?.dispose());
  }

  Lobby get _lobby => ref.read(lobbyProvider);
  set _lobby(Lobby value) => ref.read(lobbyProvider.notifier).set(value);

  /// Connects (if needed) and joins the queue.
  Future<void> search(QueueJoinPayload request) async {
    state = null;
    _lastSeq = -1;
    _setup = null;
    _lobby = Lobby(
      phase: LobbyPhase.connecting,
      request: request,
      searchStartedAt: DateTime.now(),
    );
    final socket = _socket ??= _createSocket();
    if (socket.current == SocketStatus.online) {
      socket.send(MessageType.queueJoin, request.toJson());
      _lobby = _lobby.copyWith(phase: LobbyPhase.searching, connected: true);
    } else if (socket.current == SocketStatus.offline) {
      await socket.open();
    }
  }

  GameSocket _createSocket() {
    final api = ref.read(apiClientProvider);
    final socket = GameSocket(url: OnlineConfig.wsUrl, ticket: api.ticket);
    _sub = socket.messages.listen(_onMessage);
    _statusSub = socket.status.listen((s) {
      final online = s == SocketStatus.online;
      _lobby = _lobby.copyWith(connected: online);
      final v = state;
      final extras = v?.online;
      if (v != null && extras != null) {
        state = v.copyWith(
          online:
              () => OnlineExtras(
                clock: extras.clock,
                commitment: extras.commitment,
                opponentConnected: extras.opponentConnected,
                reconnectDeadline: extras.reconnectDeadline,
                serverSeed: extras.serverSeed,
                clientSeeds: extras.clientSeeds,
                connected: online,
              ),
        );
      }
    });
    return socket;
  }

  void _send(String type, [Map<String, Object?> payload = const {}]) =>
      _socket?.send(type, payload);

  void cancelSearch() {
    _send(MessageType.queueLeave);
    _lobby = const Lobby();
  }

  void _onMessage(Envelope msg) {
    switch (msg.type) {
      case MessageType.hello:
        final request = _lobby.request;
        final playing =
            _lobby.phase == LobbyPhase.playing ||
            _lobby.phase == LobbyPhase.found;
        if (request != null && !playing) {
          _send(MessageType.queueJoin, request.toJson());
          _lobby = _lobby.copyWith(phase: LobbyPhase.searching);
        }
      case MessageType.matchFound:
        final found = MatchFoundPayload.fromJson(msg.payload);
        _setup = MatchSetup(
          variant: found.variant,
          opponent: OpponentKind.online,
          matchLength: found.matchLength,
          localSide: found.you,
          online: OnlineMatch(
            matchId: found.matchId,
            mode: found.mode,
            white: found.white,
            black: found.black,
            clock: found.clock,
          ),
        );
        _lastSeq = -1;
        _lobby = _lobby.copyWith(phase: LobbyPhase.found, match: () => found);
        _send(MessageType.gameSeed, SeedPayload(_seed()).toJson());
      case MessageType.gameState:
        _onState(GameStatePayload.fromJson(msg.payload));
      case MessageType.error:
        final err = ErrorPayload.fromJson(msg.payload);
        final v = state;
        if (err.code == ErrorCode.illegalMove && v != null) {
          state = v.copyWith(session: v.session.refused(err.rejection));
        }
      default:
        break;
    }
  }

  String _seed() {
    final now = DateTime.now().microsecondsSinceEpoch;
    return '${ref.read(accountProvider).value?.id ?? 'p'}-$now';
  }

  void _onState(GameStatePayload p) {
    final setup = _setup;
    if (setup == null || p.matchId != setup.online?.matchId) return;
    if (p.seq <= _lastSeq) return;
    _lastSeq = p.seq;
    final previous = state;
    final session = Session.fromServer(
      setup: setup,
      match: p.match,
      record: p.record,
      pending: p.pending,
    );
    final newRoll =
        session.dice != null &&
        previous?.session.dice != session.dice &&
        p.record.actions.isNotEmpty &&
        p.record.actions.last is RollDice;
    final diceTime =
        _settings.reduceMotion
            ? Duration.zero
            : (_settings.animationSpeed == AnimationSpeed.fast
                ? NardMotion.diceFast
                : NardMotion.dice);
    // Animate the opponent's checkers through each move of their turn.
    final steps = <BoardState>[];
    final last = p.record.actions.isEmpty ? null : p.record.actions.last;
    if (last is PlayTurn &&
        last.by != setup.localSide &&
        previous != null &&
        previous.session.phase == GamePhase.awaitingMove) {
      var b = previous.session.game.board;
      for (final m in last.moves) {
        b = session.rules.applyMove(b, m);
        steps.add(b);
      }
      if (steps.isNotEmpty) steps.removeLast();
    }
    final keepSelection =
        previous != null &&
        previous.session.pending.length == session.pending.length &&
        session.movableFrom.contains(previous.session.selected);
    state = GameView(
      session:
          keepSelection
              ? session.withSelection(previous.session.selected)
              : session,
      revision: (previous?.revision ?? 0) + 1,
      steps: steps,
      rolling: newRoll && diceTime > Duration.zero,
      noMoves:
          session.phase == GamePhase.awaitingMove &&
          session.mustPass &&
          !session.isGameOver,
      online: OnlineExtras(
        clock: p.clock,
        commitment: p.commitment,
        opponentConnected: p.opponentConnected,
        reconnectDeadline: p.reconnectDeadline,
        serverSeed: p.serverSeed,
        clientSeeds: p.clientSeeds,
        connected: _socket?.current == SocketStatus.online,
        receivedAt: DateTime.now(),
      ),
    );
    if (newRoll && diceTime > Duration.zero) {
      _rollTimer?.cancel();
      _rollTimer = Timer(diceTime, () {
        final v = state;
        if (v != null) state = v.copyWith(rolling: false);
      });
    }
    final over = session.isMatchOver;
    _lobby = _lobby.copyWith(
      phase: over ? LobbyPhase.finished : LobbyPhase.playing,
    );
    if (over) {
      // Ratings changed: refresh the profile.
      unawaited(
        ref.read(accountProvider.notifier).refresh().catchError((_) {}),
      );
    }
  }

  bool get _myMove {
    final v = state;
    return v != null &&
        !v.rolling &&
        v.session.phase == GamePhase.awaitingMove &&
        !v.session.remoteToAct &&
        !v.noMoves;
  }

  // ---- GameActions ---------------------------------------------------------

  @override
  void tapSlot(int? slot) {
    final v = state;
    if (v == null || !_myMove) return;
    final s = v.session;
    if (slot == null) {
      state = v.copyWith(session: s.clearSelection());
      return;
    }
    final selected = s.selected;
    if (selected == slot) {
      state = v.copyWith(session: s.clearSelection());
    } else if (selected != null &&
        (s.targetsFrom(selected).contains(slot) ||
            !s.movableFrom.contains(slot))) {
      _move(v, selected, slot);
    } else {
      state = v.copyWith(session: s.select(slot));
    }
  }

  @override
  void drop(int from, int? to) {
    final v = state;
    if (v == null || !_myMove || to == null) return;
    _move(v, from, to);
  }

  void _move(GameView v, int from, int to) {
    final s = v.session;
    final path = s.pathTo(from, to);
    // Refusals are explained locally with the same engine.
    final next = s.move(from, to);
    state = v.copyWith(session: next);
    for (final m in path) {
      _send(
        MessageType.gameMove,
        MovePayload(m.from, m.to, die: m.die).toJson(),
      );
    }
    if (path.isNotEmpty && next.canConfirm && !_settings.confirmMoves) {
      confirm();
    }
  }

  @override
  void roll() {
    final v = state;
    if (v == null ||
        v.session.phase != GamePhase.awaitingRoll ||
        v.session.remoteToAct) {
      return;
    }
    _send(MessageType.gameRoll);
  }

  @override
  void undo() {
    final v = state;
    if (v == null || !_myMove || !v.session.canUndo) return;
    state = v.copyWith(session: v.session.undo());
    _send(MessageType.gameUndo);
  }

  @override
  void confirm() {
    final v = state;
    if (v == null || !v.session.canConfirm) return;
    _send(MessageType.gameConfirmTurn);
  }

  /// The server passes forced turns itself after its delay.
  @override
  void pass() {}

  @override
  void offerDouble() => _send(MessageType.cubeOffer);

  @override
  void takeDouble() => _send(MessageType.cubeTake);

  @override
  void dropDouble() => _send(MessageType.cubeDrop);

  @override
  void resign(WinKind kind) =>
      _send(MessageType.gameResign, ResignPayload(kind).toJson());

  /// The server starts the next game of the match by itself.
  @override
  void nextGame() {}

  @override
  void ready() {}

  @override
  void undoLastTurn() {}

  @override
  void rematch() {
    final request = _lobby.request;
    if (request != null) unawaited(search(request));
  }

  @override
  void leave() {
    final v = state;
    if (v != null && !v.session.isMatchOver) {
      // Leaving a running match resigns it (single game).
      resign(WinKind.single);
    }
    state = null;
    _setup = null;
    _lobby = const Lobby();
  }
}

class LobbyNotifier extends Notifier<Lobby> {
  @override
  Lobby build() => const Lobby();

  void set(Lobby value) => state = value;
}

final lobbyProvider = NotifierProvider<LobbyNotifier, Lobby>(LobbyNotifier.new);

final onlineGameProvider = NotifierProvider<OnlineGameController, GameView?>(
  OnlineGameController.new,
);
