import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nard_ai/nard_ai.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';

import '../app/providers.dart';
import '../data/app_settings.dart';
import '../data/database.dart';
import 'dice_time.dart';
import 'game_actions.dart';
import 'match_setup.dart';
import 'session.dart';

/// UI state of the running match.
class GameView {
  const GameView({
    required this.session,
    this.revision = 0,
    this.steps = const [],
    this.rolling = false,
    this.botThinking = false,
    this.noMoves = false,
    this.handoff = false,
    this.undoSnapshot,
    this.botTookDouble = false,
    this.online,
  });

  final Session session;

  /// Server-only details of an online match.
  final OnlineExtras? online;

  /// Increments with every change so the board knows what to animate.
  final int revision;

  /// Intermediate positions of the latest turn, animated in order.
  final List<BoardState> steps;
  final bool rolling;
  final bool botThinking;

  /// The side to move has no legal move: the card counts down to a pass.
  final bool noMoves;

  /// Pass & play: the board is hidden until the next player is ready.
  final bool handoff;

  /// Pass & play: the session before the last confirmed turn.
  final Session? undoSnapshot;

  /// The bot just took a double (shown as a brief note).
  final bool botTookDouble;

  GameView copyWith({
    Session? session,
    List<BoardState>? steps,
    bool? rolling,
    bool? botThinking,
    bool? noMoves,
    bool? handoff,
    Session? Function()? undoSnapshot,
    bool? botTookDouble,
    OnlineExtras? Function()? online,
  }) => GameView(
    session: session ?? this.session,
    revision: revision + 1,
    steps: steps ?? const [],
    rolling: rolling ?? this.rolling,
    botThinking: botThinking ?? this.botThinking,
    noMoves: noMoves ?? this.noMoves,
    handoff: handoff ?? this.handoff,
    undoSnapshot: undoSnapshot != null ? undoSnapshot() : this.undoSnapshot,
    botTookDouble: botTookDouble ?? this.botTookDouble,
    online: online != null ? online() : this.online,
  );
}

/// Clock, connection and fair-dice data of an online match.
class OnlineExtras {
  const OnlineExtras({
    required this.clock,
    required this.commitment,
    this.opponentConnected = true,
    this.reconnectDeadline,
    this.serverSeed,
    this.clientSeeds = const {},
    this.connected = true,
    this.receivedAt,
  });

  final ClockState clock;

  /// Local time the clock values were received (avoids server clock skew).
  final DateTime? receivedAt;
  final String commitment;
  final bool opponentConnected;

  /// When the absent opponent forfeits (ms since epoch).
  final int? reconnectDeadline;
  final String? serverSeed;
  final Map<Side, String> clientSeeds;

  /// Our own socket is up.
  final bool connected;
}

/// Drives an offline match: dice, the bot, forced passes, pass & play
/// hand-over and saving finished games. Every rule decision goes through
/// [Session] (and so through nard_core).
class GameController extends Notifier<GameView?> implements GameActions {
  final _random = Random.secure();
  Timer? _timer;
  String _matchId = '';
  int _gameIndex = 0;
  bool _saved = false;

  /// Delay before the no-moves pass (design: 2 s).
  static const passDelay = Duration(seconds: 2);

  @override
  GameView? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  AppSettings get _settings => ref.read(currentSettingsProvider);

  Duration get _diceTime => diceRollTime(_settings);

  void start(MatchSetup setup) {
    _timer?.cancel();
    _matchId =
        '${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(1 << 30)}';
    _gameIndex = 0;
    _saved = false;
    state = GameView(session: Session.start(setup));
    _drive();
  }

  void _set(GameView next) {
    state = next;
    _drive();
  }

  void _after(Duration d, void Function() action) {
    _timer?.cancel();
    _timer = Timer(d, action);
  }

  int _die() => _random.nextInt(6) + 1;

  /// Schedules whatever happens without the local player.
  void _drive() {
    final view = state;
    if (view == null) return;
    final s = view.session;
    if (s.isGameOver) {
      unawaited(_save(s));
      return;
    }
    if (view.handoff || view.rolling || view.botThinking) return;
    switch (s.phase) {
      case GamePhase.opening:
        _after(const Duration(milliseconds: 700), _openingRoll);
      case GamePhase.awaitingRoll:
        if (s.remoteToAct) {
          // Leave the opening dice on the board for a moment.
          final pause = s.openingDice != null ? 1200 : 300;
          _after(Duration(milliseconds: pause), _botRollOrDouble);
        } else if (_settings.autoRoll && !s.canDouble) {
          _after(const Duration(milliseconds: 400), roll);
        }
      case GamePhase.awaitingMove:
        if (s.mustPass) {
          if (!view.noMoves) state = view.copyWith(noMoves: true);
          _after(passDelay, pass);
        } else if (s.remoteToAct) {
          unawaited(_botMove());
        }
      case GamePhase.cubeOffered:
        if (s.remoteToAct) {
          _after(const Duration(milliseconds: 900), _botAnswerDouble);
        }
      case GamePhase.over:
        break;
    }
  }

  void _openingRoll() {
    final view = state;
    if (view == null || view.session.phase != GamePhase.opening) return;
    final white = _die();
    final black = _die();
    final next = view.session.openingRoll(white, black);
    final started = next.phase != GamePhase.opening;
    final hotseat = !next.setup.vsComputer;
    state = view.copyWith(
      session: next,
      rolling: _diceTime > Duration.zero,
      handoff: false,
    );
    _after(_diceTime, () {
      final v = state;
      if (v == null) return;
      // The first pass & play player gets the hand-over screen.
      _set(
        v.copyWith(
          rolling: false,
          handoff: started && hotseat && v.session.setup.hideBetweenTurns,
        ),
      );
    });
  }

  // ---- Local player actions ----------------------------------------

  @override
  void roll() {
    final view = state;
    if (view == null ||
        view.rolling ||
        view.session.phase != GamePhase.awaitingRoll) {
      return;
    }
    final next = view.session.roll(DiceRoll(_die(), _die()));
    state = view.copyWith(session: next, rolling: _diceTime > Duration.zero);
    _after(_diceTime, () {
      final v = state;
      if (v != null) _set(v.copyWith(rolling: false));
    });
  }

  @override
  void tapSlot(int? slot) {
    final view = state;
    if (view == null || !_humanMoving(view)) return;
    final s = view.session;
    if (slot == null) {
      state = view.copyWith(session: s.clearSelection());
      return;
    }
    final selected = s.selected;
    if (selected == slot) {
      state = view.copyWith(session: s.clearSelection());
    } else if (selected != null &&
        (s.targetsFrom(selected).contains(slot) ||
            !s.movableFrom.contains(slot))) {
      // A target, or an illegal destination the rules should explain.
      _applyMove(view, s.move(selected, slot));
    } else {
      final targets = s.movableFrom.contains(slot) ? s.targetsFrom(slot) : null;
      if (targets != null && targets.length == 1) {
        // Only one place to go: move straight away.
        _applyMove(view, s.move(slot, targets.single));
      } else {
        state = view.copyWith(session: s.select(slot));
      }
    }
  }

  @override
  void drop(int from, int? to) {
    final view = state;
    if (view == null || !_humanMoving(view) || to == null) return;
    _applyMove(view, view.session.move(from, to));
  }

  void _applyMove(GameView view, Session next) {
    state = view.copyWith(session: next);
    if (next.canConfirm && !_settings.confirmMoves) confirm();
  }

  @override
  void undo() {
    final view = state;
    if (view == null || !_humanMoving(view)) return;
    state = view.copyWith(session: view.session.undo());
  }

  @override
  void confirm() {
    final view = state;
    if (view == null || !view.session.canConfirm || view.noMoves) return;
    final before = view.session;
    final next = before.confirm();
    final hotseat = !before.setup.vsComputer;
    _set(
      view.copyWith(
        session: next,
        handoff: hotseat && before.setup.hideBetweenTurns && !next.isGameOver,
        undoSnapshot: () => hotseat ? before : null,
      ),
    );
  }

  /// Plays the forced empty turn now (also called by the countdown).
  @override
  void pass() {
    final view = state;
    if (view == null || !view.session.mustPass) return;
    final next = view.session.playTurn(const []);
    _set(
      view.copyWith(
        session: next,
        noMoves: false,
        handoff:
            !next.setup.vsComputer &&
            next.setup.hideBetweenTurns &&
            !next.isGameOver,
        undoSnapshot: () => null,
      ),
    );
  }

  @override
  void offerDouble() {
    final view = state;
    if (view == null || !view.session.canDouble || view.session.remoteToAct) {
      return;
    }
    _set(view.copyWith(session: view.session.offerDouble()));
  }

  @override
  void takeDouble() => _answer(take: true);
  @override
  void dropDouble() => _answer(take: false);

  void _answer({required bool take}) {
    final view = state;
    if (view == null || view.session.phase != GamePhase.cubeOffered) return;
    final s = view.session;
    _set(view.copyWith(session: take ? s.takeDouble() : s.dropDouble()));
  }

  /// The local player (pass & play: the side to move) resigns.
  @override
  void resign(WinKind kind) {
    final view = state;
    if (view == null || view.session.isGameOver) return;
    final s = view.session;
    final side = s.setup.hasRemote ? s.setup.localSide : s.turn;
    _timer?.cancel();
    _set(
      view.copyWith(
        session: s.resign(side, kind),
        rolling: false,
        botThinking: false,
        noMoves: false,
        handoff: false,
      ),
    );
  }

  @override
  void nextGame() {
    final view = state;
    if (view == null || !view.session.isGameOver || view.session.isMatchOver) {
      return;
    }
    _gameIndex++;
    _saved = false;
    _set(GameView(session: view.session.nextGame(), revision: view.revision));
  }

  /// Pass & play: the next player is ready.
  @override
  void ready() {
    final view = state;
    if (view == null || !view.handoff) return;
    _set(view.copyWith(handoff: false));
  }

  /// Pass & play: the previous player takes the last turn back.
  @override
  void undoLastTurn() {
    final view = state;
    final snapshot = view?.undoSnapshot;
    if (view == null || snapshot == null || !view.session.setup.allowUndo) {
      return;
    }
    _timer?.cancel();
    state = view.copyWith(
      session: snapshot,
      handoff: false,
      undoSnapshot: () => null,
      noMoves: false,
    );
  }

  bool _humanMoving(GameView view) =>
      !view.rolling &&
      !view.handoff &&
      !view.noMoves &&
      view.session.phase == GamePhase.awaitingMove &&
      !view.session.remoteToAct;

  // ---- Bot -----------------------------------------------------------

  HeuristicBot get _bot => HeuristicBot(state!.session.setup.level);

  void _botRollOrDouble() {
    final view = state;
    if (view == null || !view.session.remoteToAct) return;
    final s = view.session;
    if (s.phase != GamePhase.awaitingRoll) return;
    if (s.canDouble && _bot.shouldDouble(s.rules, s.game.board, s.turn)) {
      _set(view.copyWith(session: s.offerDouble()));
      return;
    }
    roll();
  }

  void _botAnswerDouble() {
    final view = state;
    if (view == null || !view.session.remoteToAct) return;
    final s = view.session;
    final take = _bot.shouldTake(s.rules, s.game.board, s.turn.opponent);
    _set(
      view.copyWith(
        session: take ? s.takeDouble() : s.dropDouble(),
        botTookDouble: take,
      ),
    );
  }

  Future<void> _botMove() async {
    final view = state;
    if (view == null) return;
    final s = view.session;
    final level = s.setup.level;
    final rules = s.rules;
    final board = s.game.board;
    final dice = s.dice!;
    state = view.copyWith(botThinking: true);
    final started = DateTime.now();
    final turn = await Isolate.run(
      () => HeuristicBot(level).chooseTurn(rules, board, dice),
    );
    final minThink = Duration(milliseconds: 250 + _random.nextInt(300));
    final elapsed = DateTime.now().difference(started);
    if (elapsed < minThink) await Future<void>.delayed(minThink - elapsed);
    final current = state;
    // The match may have been left or resigned meanwhile.
    if (current == null || !identical(current.session, s)) return;
    final steps = <BoardState>[];
    var b = board;
    for (final m in turn.moves) {
      b = rules.applyMove(b, m);
      steps.add(b);
    }
    if (steps.isNotEmpty) steps.removeLast();
    _set(
      current.copyWith(
        session: s.playTurn(turn.moves),
        steps: steps,
        botThinking: false,
        botTookDouble: false,
      ),
    );
  }

  // ---- Storage -------------------------------------------------------

  Future<void> _save(Session s) async {
    if (_saved) return;
    _saved = true;
    final result = s.game.result!;
    final score = s.score;
    try {
      await ref
          .read(databaseProvider)
          .addGame(
            GameRecordsCompanion.insert(
              matchId: _matchId,
              gameIndex: _gameIndex,
              setupJson: jsonEncode(s.setup.toJson()),
              recordJson: jsonEncode(s.record.toJson()),
              variant: s.setup.variant.name,
              opponent: s.setup.opponent.name,
              level: Value(s.setup.vsComputer ? s.setup.level.name : null),
              winner: result.winner.name,
              winKind: result.kind.name,
              points: result.points,
              whiteScore: score.whiteScore,
              blackScore: score.blackScore,
              matchOver: s.isMatchOver,
              playedAt: DateTime.now(),
            ),
          );
    } on Object {
      // Saving is best effort: a full disk must not break the game.
      _saved = false;
    }
  }

  @override
  void rematch() {
    final setup = state?.session.setup;
    if (setup != null) start(setup);
  }

  /// Leaves the match without saving.
  @override
  void leave() {
    _timer?.cancel();
    state = null;
  }
}

final gameControllerProvider = NotifierProvider<GameController, GameView?>(
  GameController.new,
);
