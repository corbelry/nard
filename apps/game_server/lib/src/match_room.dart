import 'dart:async';
import 'dart:math';

import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';

/// Delivers a message to the player on [side] (if connected).
typedef SendFn = void Function(Side side, Envelope message);

/// One authoritative match between two seats (spec §7). Transport-agnostic:
/// the hub feeds client intents into [handle] and connection changes into
/// [connected] / [disconnected]; every rule check goes through nard_core.
class MatchRoom {
  MatchRoom({
    required this.matchId,
    required this.variant,
    required this.matchLength,
    required this.mode,
    required this.white,
    required this.black,
    required this.send,
    required this.onEnd,
    this.clock = ClockConfig.standard,
    this.reconnectGrace = const Duration(seconds: 60),
    this.passDelay = const Duration(seconds: 2),
    this.nextGameDelay = const Duration(seconds: 4),
    this.tournamentId,
    this.timeControl,
    int Function()? now,
  }) : _now = now ?? (() => DateTime.now().millisecondsSinceEpoch),
       _match = MatchState.start(length: matchLength),
       _reserve = {Side.white: clock.reserveMs, Side.black: clock.reserveMs} {
    _resetGame();
  }

  final String matchId;
  final Variant variant;
  final int matchLength;
  final QueueMode mode;
  final PlayerInfo white;
  final PlayerInfo black;
  final ClockConfig clock;
  final SendFn send;

  /// Called once with the final result.
  final void Function(MatchResult result) onEnd;
  final Duration reconnectGrace;
  final Duration passDelay;
  final Duration nextGameDelay;

  /// Set for tournament matches; carried into the [MatchResult].
  final String? tournamentId;

  /// The control [clock] came from (ADR-044); carried into the
  /// [MatchResult].
  final TimeControl? timeControl;
  final int Function() _now;

  MatchState _match;
  late GameState _game;
  late GameRecord _record;
  final _pending = <Move>[];
  late String _serverSeed;
  final _clientSeeds = <Side, String>{};
  FairDice? _dice;
  int _seq = 0;
  int _gameIndex = 0;
  final _games = <Map<String, Object?>>[];
  int _startedAt = 0;

  final Map<Side, int> _reserve;
  Side? _running;
  int _turnStartedAt = 0;
  Timer? _clockTimer;
  Timer? _passTimer;
  Timer? _nextGameTimer;
  final _connected = {Side.white: false, Side.black: false};
  final _reconnectDeadline = <Side, int>{};
  final _reconnectTimers = <Side, Timer>{};
  bool _ended = false;

  bool get isOver => _ended;
  GameState get game => _game;
  MatchState get match => _match;
  List<Move> get pending => List.unmodifiable(_pending);
  bool isConnected(Side side) => _connected[side]!;

  PlayerInfo player(Side side) => side == Side.white ? white : black;

  /// Starts the first game; seats join with [connected].
  void start() {
    _startedAt = _now();
    _started = true;
    _broadcast();
  }

  bool _started = false;

  void _newGame() {
    _resetGame();
    _broadcast();
  }

  void _resetGame() {
    _game = GameState.newGame(rulesFor(variant), config: _match.gameConfig());
    _record = GameRecord(variant: variant, config: _match.gameConfig());
    _pending.clear();
    _serverSeed = FairDice.newServerSeed();
    _clientSeeds.clear();
    _dice = null;
  }

  // ---- Connections -----------------------------------------------------

  void connected(Side side) {
    if (_ended) return;
    _connected[side] = true;
    _reconnectTimers.remove(side)?.cancel();
    _reconnectDeadline.remove(side);
    _broadcast();
  }

  /// Starts the reconnect grace; the absent seat forfeits when it ends.
  void disconnected(Side side) {
    if (_ended) return;
    _connected[side] = false;
    _reconnectDeadline[side] = _now() + reconnectGrace.inMilliseconds;
    _reconnectTimers[side]?.cancel();
    _reconnectTimers[side] = Timer(reconnectGrace, () {
      if (!_connected[side]!) {
        _endMatch(side.opponent, MatchEndReason.abandoned);
      }
    });
    _broadcast();
  }

  // ---- Intents -----------------------------------------------------------

  /// Applies a client intent from [side]; replies with `error` if refused.
  void handle(Side side, Envelope msg) {
    if (_ended) return _error(side, msg, ErrorCode.notInMatch);
    try {
      switch (msg.type) {
        case MessageType.gameSeed:
          _seed(side, SeedPayload.fromJson(msg.payload).clientSeed, msg);
        case MessageType.gameRoll:
          _requireTurn(side, msg, GamePhase.awaitingRoll);
          _apply(RollDice(side, _dice!.roll()));
        case MessageType.gameMove:
          _move(side, MovePayload.fromJson(msg.payload), msg);
        case MessageType.gameUndo:
          _requireTurn(side, msg, GamePhase.awaitingMove);
          if (_pending.isNotEmpty) _pending.removeLast();
          _broadcast();
        case MessageType.gameConfirmTurn:
          _requireTurn(side, msg, GamePhase.awaitingMove);
          if (!_game.planner.isComplete(_pending)) {
            throw IllegalActionException('Turn is not complete');
          }
          _apply(PlayTurn(side, List.of(_pending)));
        case MessageType.cubeOffer:
          _apply(OfferDouble(side));
        case MessageType.cubeTake:
          _apply(TakeDouble(side));
        case MessageType.cubeDrop:
          _apply(DropDouble(side));
        case MessageType.chatEmote:
          _emote(side, EmotePayload.fromJson(msg.payload));
        case MessageType.gameResign:
          final kind = ResignPayload.fromJson(msg.payload).kind;
          _game = _game.apply(OfferResignation(side, kind));
          _record = _record.add(OfferResignation(side, kind));
          _apply(AcceptResignation(side.opponent));
        default:
          _error(side, msg, ErrorCode.notImplemented);
      }
    } on _Refused {
      // Already answered.
    } on ProtocolException catch (e) {
      _error(side, msg, ErrorCode.badRequest, e.message);
    } on IllegalActionException catch (e) {
      _error(side, msg, ErrorCode.illegalAction, e.message);
    } on IllegalMoveException catch (e) {
      _error(side, msg, ErrorCode.illegalMove, e.message);
    }
  }

  /// Minimum gap between two emotes of one player.
  static const emoteGap = Duration(seconds: 2);
  final _lastEmote = <Side, int>{};

  void _emote(Side side, EmotePayload emote) {
    final now = _now();
    final last = _lastEmote[side];
    if (last != null && now - last < emoteGap.inMilliseconds) return;
    _lastEmote[side] = now;
    final out = _envelope(
      MessageType.chatEmote,
      EmotePayload(emote.id, from: side).toJson(),
    );
    for (final s in Side.values) {
      send(s, out);
    }
    for (final spectator in _spectators.values) {
      spectator(out);
    }
  }

  // ---- Spectators (6.4) ----------------------------------------------------

  final _spectators = <Object, void Function(Envelope)>{};

  int get spectatorCount => _spectators.length;

  /// Adds a read-only viewer keyed by [key] and sends the current state.
  void addSpectator(Object key, void Function(Envelope) sink) {
    _spectators[key] = sink;
    sink(_envelope(MessageType.gameState, stateFor(Side.white).toJson()));
  }

  void removeSpectator(Object key) => _spectators.remove(key);

  void _requireTurn(Side side, Envelope msg, GamePhase phase) {
    if (_game.phase != phase) {
      _error(side, msg, ErrorCode.illegalAction, 'Expected ${phase.name}');
      throw const _Refused();
    }
    if (_game.turn != side) {
      _error(side, msg, ErrorCode.notYourTurn);
      throw const _Refused();
    }
  }

  void _seed(Side side, String seed, Envelope msg) {
    if (_game.phase != GamePhase.opening || _clientSeeds.containsKey(side)) {
      return _error(side, msg, ErrorCode.illegalAction, 'Seed already set');
    }
    _clientSeeds[side] = seed;
    if (_clientSeeds.length < 2) return _broadcast();
    final dice =
        _dice = FairDice(
          serverSeed: _serverSeed,
          clientSeedA: _clientSeeds[Side.white]!,
          clientSeedB: _clientSeeds[Side.black]!,
        );
    // FD-04: one roll per opening throw; ties are thrown again.
    while (_game.phase == GamePhase.opening) {
      final r = dice.roll();
      final action = OpeningRoll(r.die1, r.die2);
      _game = _game.apply(action);
      _record = _record.add(action);
    }
    _afterChange();
  }

  void _move(Side side, MovePayload m, Envelope msg) {
    _requireTurn(side, msg, GamePhase.awaitingMove);
    final planner = _game.planner;
    final options =
        planner
            .nextMoves(_pending)
            .where(
              (x) =>
                  x.from == m.from &&
                  x.to == m.to &&
                  (m.die == null || x.die == m.die),
            )
            .toList();
    if (options.isEmpty) {
      send(
        side,
        _envelope(
          MessageType.error,
          ErrorPayload(
            code: ErrorCode.illegalMove,
            rejection: planner.explain(m.from, m.to, _pending),
          ).toJson(),
          id: msg.id,
        ),
      );
      return;
    }
    options.sort((a, b) => a.die.compareTo(b.die));
    _pending.add(options.first);
    _broadcast();
  }

  void _apply(GameAction action) {
    _game = _game.apply(action);
    _record = _record.add(action);
    if (action is PlayTurn) _pending.clear();
    _afterChange();
  }

  // ---- Flow --------------------------------------------------------------

  void _afterChange() {
    _passTimer?.cancel();
    if (_game.isOver) {
      _setRunner(null);
      _finishGame();
      return;
    }
    final runner = switch (_game.phase) {
      GamePhase.opening => null,
      GamePhase.cubeOffered => _game.turn.opponent,
      _ => _game.turn,
    };
    _setRunner(runner);
    if (_game.phase == GamePhase.awaitingMove && _game.mustPass) {
      final side = _game.turn;
      _passTimer = Timer(passDelay, () {
        if (_game.phase == GamePhase.awaitingMove && _game.mustPass) {
          _apply(PlayTurn(side, const []));
        }
      });
    }
    _broadcast();
  }

  void _finishGame() {
    final result = _game.result!;
    _games.add({
      'record': _record.toJson(),
      'serverSeed': _serverSeed,
      'commitment': FairDice.commitment(_serverSeed),
      'clientSeeds': {
        for (final e in _clientSeeds.entries) e.key.name: e.value,
      },
      'winner': result.winner.name,
      'kind': result.kind.name,
      'points': result.points,
    });
    _broadcast();
    final next = _match.withResult(result);
    if (next.isOver) {
      _match = next;
      _endMatch(
        next.winner!,
        result.reason == GameEndReason.resignation
            ? MatchEndReason.resigned
            : MatchEndReason.completed,
      );
      return;
    }
    _nextGameTimer = Timer(nextGameDelay, () {
      _match = next;
      _gameIndex++;
      _newGame();
    });
  }

  void _endMatch(Side winner, MatchEndReason reason) {
    if (_ended) return;
    _ended = true;
    for (final t in [
      _clockTimer,
      _passTimer,
      _nextGameTimer,
      ..._reconnectTimers.values,
    ]) {
      t?.cancel();
    }
    _running = null;
    var whiteScore = _match.whiteScore;
    var blackScore = _match.blackScore;
    if (reason == MatchEndReason.timeout ||
        reason == MatchEndReason.abandoned) {
      // The match is forfeited: the winner is credited the full length.
      if (winner == Side.white) {
        whiteScore = max(whiteScore, matchLength);
      } else {
        blackScore = max(blackScore, matchLength);
      }
      if (!_game.isOver) {
        _record = _record.add(Forfeit(winner.opponent, WinKind.single));
        _game = _game.apply(Forfeit(winner.opponent, WinKind.single));
        _games.add({
          'record': _record.toJson(),
          'serverSeed': _serverSeed,
          'commitment': FairDice.commitment(_serverSeed),
          'clientSeeds': {
            for (final e in _clientSeeds.entries) e.key.name: e.value,
          },
        });
      }
      if (reason == MatchEndReason.timeout) {
        for (final side in Side.values) {
          send(
            side,
            _envelope(MessageType.gameTimeout, {'loser': winner.opponent.name}),
          );
        }
      }
    }
    _broadcast();
    onEnd(
      MatchResult(
        matchId: matchId,
        variant: variant,
        matchLength: matchLength,
        mode: mode,
        white: white,
        black: black,
        winner: winner,
        whiteScore: whiteScore,
        blackScore: blackScore,
        reason: reason,
        games: List.unmodifiable(_games),
        startedAt: _startedAt,
        endedAt: _now(),
        tournamentId: tournamentId,
        timeControl: timeControl,
      ),
    );
  }

  // ---- Clock (spec §7.3) ---------------------------------------------------

  /// Hands the clock to [runner]; the same runner keeps its turn clock.
  void _setRunner(Side? runner) {
    if (runner == _running) return;
    _charge();
    _clockTimer?.cancel();
    _running = runner;
    _turnStartedAt = _now();
    if (runner == null) return;
    _clockTimer = Timer(
      Duration(milliseconds: clock.delayMs + _reserve[runner]!),
      () => _endMatch(runner.opponent, MatchEndReason.timeout),
    );
  }

  /// Deducts the time beyond the delay from the running side's reserve.
  void _charge() {
    final r = _running;
    if (r == null) return;
    final over = _now() - _turnStartedAt - clock.delayMs;
    if (over > 0) _reserve[r] = max(0, _reserve[r]! - over);
  }

  ClockState _clockState() {
    final now = _now();
    final r = _running;
    final elapsed = r == null ? 0 : now - _turnStartedAt;
    int left(Side s) {
      final base = _reserve[s]!;
      if (s != r) return base;
      return max(0, base - max(0, elapsed - clock.delayMs));
    }

    return ClockState(
      whiteMs: left(Side.white),
      blackMs: left(Side.black),
      delayMs: r == null ? clock.delayMs : max(0, clock.delayMs - elapsed),
      running: r,
      sentAt: now,
    );
  }

  // ---- Messages ------------------------------------------------------------

  GameStatePayload stateFor(Side side) => GameStatePayload(
    seq: _seq,
    matchId: matchId,
    gameIndex: _gameIndex,
    record: _record,
    match: _match,
    pending: List.of(_pending),
    clock: _clockState(),
    commitment: FairDice.commitment(_serverSeed),
    serverSeed: _game.isOver ? _serverSeed : null,
    clientSeeds: Map.of(_clientSeeds),
    opponentConnected: _connected[side.opponent]!,
    reconnectDeadline: _reconnectDeadline[side.opponent],
  );

  void _broadcast() {
    if (!_started) return;
    _seq++;
    for (final side in Side.values) {
      send(side, _envelope(MessageType.gameState, stateFor(side).toJson()));
    }
    if (_spectators.isNotEmpty) {
      final view = _envelope(
        MessageType.gameState,
        stateFor(Side.white).toJson(),
      );
      for (final spectator in _spectators.values) {
        spectator(view);
      }
    }
  }

  /// Sends the current state to [side] only (after a reconnect).
  void resend(Side side) =>
      send(side, _envelope(MessageType.gameState, stateFor(side).toJson()));

  int _ids = 0;

  Envelope _envelope(String type, Map<String, Object?> payload, {String? id}) =>
      Envelope(
        type: type,
        id: id ?? 's${_ids++}',
        ts: _now(),
        payload: payload,
      );

  void _error(Side side, Envelope msg, String code, [String message = '']) =>
      send(
        side,
        _envelope(
          MessageType.error,
          ErrorPayload(code: code, message: message).toJson(),
          id: msg.id,
        ),
      );

  /// Stops all timers (server shutdown).
  void dispose() {
    for (final t in [
      _clockTimer,
      _passTimer,
      _nextGameTimer,
      ..._reconnectTimers.values,
    ]) {
      t?.cancel();
    }
  }
}

class _Refused implements Exception {
  const _Refused();
}
