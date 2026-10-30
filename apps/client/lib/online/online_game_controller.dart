import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;
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
    this.cooldownUntil,
  });

  final LobbyPhase phase;
  final QueueJoinPayload? request;
  final MatchFoundPayload? match;
  final DateTime? searchStartedAt;
  final bool connected;

  /// An API/connection failure code (e.g. `offline`).
  final String? error;

  /// The public queue is closed until then (abandonment penalty, ADR-042):
  /// set instead of searching; private rooms and tournaments still work.
  final DateTime? cooldownUntil;

  /// Whether [cooldownUntil] is still ahead of [now].
  bool coolingDown(DateTime now) =>
      cooldownUntil != null && cooldownUntil!.isAfter(now);

  Lobby copyWith({
    LobbyPhase? phase,
    QueueJoinPayload? request,
    MatchFoundPayload? Function()? match,
    DateTime? Function()? searchStartedAt,
    bool? connected,
    String? Function()? error,
    DateTime? Function()? cooldownUntil,
  }) => Lobby(
    phase: phase ?? this.phase,
    request: request ?? this.request,
    match: match != null ? match() : this.match,
    searchStartedAt:
        searchStartedAt != null ? searchStartedAt() : this.searchStartedAt,
    connected: connected ?? this.connected,
    error: error != null ? error() : this.error,
    cooldownUntil: cooldownUntil != null ? cooldownUntil() : this.cooldownUntil,
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

  /// Full states rebuilt from `game.state` frames and deltas (ADR-048).
  final _sync = GameStateSync();
  MatchSetup? _setup;

  /// Index of the last game we sent a client seed for (FD-02: one per game).
  int _seededGame = -1;

  /// The matchmaking cooldown from the latest ticket or `queue_cooldown`
  /// error (ADR-042).
  DateTime? _queueCooldownUntil;

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

  /// Connects (if needed) and joins the queue. While a matchmaking
  /// cooldown is known the lobby shows it instead of searching.
  Future<void> search(QueueJoinPayload request) async {
    state = null;
    _sync.reset();
    _setup = null;
    final cooldown = _queueCooldownUntil;
    if (cooldown != null && cooldown.isAfter(DateTime.now())) {
      _lobby = Lobby(
        request: request,
        connected: _lobby.connected,
        cooldownUntil: cooldown,
      );
      return;
    }
    _lobby = Lobby(
      phase: LobbyPhase.connecting,
      request: request,
      searchStartedAt: DateTime.now(),
    );
    final socket = this.socket();
    if (socket.current == SocketStatus.online) {
      socket.send(MessageType.queueJoin, request.toJson());
      _lobby = _lobby.copyWith(phase: LobbyPhase.searching, connected: true);
    } else if (socket.current == SocketStatus.offline) {
      await socket.open();
    }
  }

  /// The one game-server connection (the server keeps a single socket per
  /// user, so rooms, spectating, presence and emotes share it). Created on
  /// first use; [open] it when [GameSocket.current] is offline.
  GameSocket socket() => _socket ??= _createSocket();

  /// Clears the previous match before a private room (6.3) pairs us: the
  /// following `match.found` starts a fresh game without a queue request.
  void resetForRoom() {
    state = null;
    _sync.reset();
    _setup = null;
    _lobby = const Lobby();
  }

  GameSocket _createSocket() {
    final api = ref.read(apiClientProvider);
    final socket = GameSocket(
      url: OnlineConfig.wsUrl,
      ticket: () async {
        final t = await api.gameTicket();
        _queueCooldownUntil = t.queueCooldownUntil;
        return t.ticket;
      },
    );
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

  /// The socket intents go to once it exists (tests substitute one).
  @visibleForTesting
  GameSocket? get activeSocket => _socket;

  void _send(String type, [Map<String, Object?> payload = const {}]) =>
      activeSocket?.send(type, payload);

  void cancelSearch() {
    _send(MessageType.queueLeave);
    _lobby = const Lobby();
  }

  /// Feeds a server message as if it came over the socket (tests).
  @visibleForTesting
  void receive(Envelope msg) => _onMessage(msg);

  void _onMessage(Envelope msg) {
    switch (msg.type) {
      case MessageType.hello:
        final request = _lobby.request;
        final playing =
            _lobby.phase == LobbyPhase.playing ||
            _lobby.phase == LobbyPhase.found;
        // A lobby showing a cooldown never re-joins by itself.
        if (request != null && !playing && _lobby.cooldownUntil == null) {
          final cooldown = _queueCooldownUntil;
          if (cooldown != null && cooldown.isAfter(DateTime.now())) {
            _coolDown(cooldown);
            return;
          }
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
        _sync.reset();
        _seededGame = 0;
        _lobby = _lobby.copyWith(phase: LobbyPhase.found, match: () => found);
        _send(MessageType.gameSeed, SeedPayload(_seed()).toJson());
      case MessageType.gameState:
        final frame = GameStateFrame.fromJson(msg.payload);
        if (_setup == null || frame.matchId != _setup?.online?.matchId) {
          return;
        }
        // A delta that does not fit (lost frame): ask for the full state
        // rather than guess (ADR-048).
        final full = _sync.accept(
          frame,
          onGap: () => _send(MessageType.gameSync, {'matchId': frame.matchId}),
        );
        if (full != null) _onState(full);
      case MessageType.error:
        final err = ErrorPayload.fromJson(msg.payload);
        if (err.code == ErrorCode.queueCooldown) {
          // The message carries the end as epoch seconds.
          final seconds = int.tryParse(err.message.trim());
          _coolDown(
            seconds != null
                ? DateTime.fromMillisecondsSinceEpoch(seconds * 1000)
                : _queueCooldownUntil ??
                    DateTime.now().add(const Duration(minutes: 1)),
          );
          return;
        }
        final v = state;
        if (err.code == ErrorCode.illegalMove && v != null) {
          state = v.copyWith(session: v.session.refused(err.rejection));
        }
      default:
        break;
    }
  }

  /// Leaves the search for the cooldown view (only while searching).
  void _coolDown(DateTime until) {
    _queueCooldownUntil = until;
    final phase = _lobby.phase;
    if (phase != LobbyPhase.connecting && phase != LobbyPhase.searching) {
      return;
    }
    _lobby = Lobby(
      request: _lobby.request,
      connected: _lobby.connected,
      cooldownUntil: until,
    );
  }

  String _seed() {
    final now = DateTime.now().microsecondsSinceEpoch;
    return '${ref.read(accountProvider).value?.id ?? 'p'}-$now';
  }

  /// A new full state of the current match (stale ones are already
  /// dropped by [_sync]).
  void _onState(GameStatePayload p) {
    final setup = _setup!;
    // Every game of a match needs fresh client seeds before its opening
    // roll; the first one went out with `match.found`.
    if (p.record.actions.isEmpty &&
        !p.clientSeeds.containsKey(setup.localSide) &&
        _seededGame != p.gameIndex) {
      _seededGame = p.gameIndex;
      _send(MessageType.gameSeed, SeedPayload(_seed()).toJson());
    }
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
