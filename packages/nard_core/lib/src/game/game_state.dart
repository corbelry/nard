import '../board_state.dart';
import '../cube.dart';
import '../dice.dart';
import '../move.dart';
import '../rules/rule_set.dart';
import '../rules/turn_planner.dart';
import '../side.dart';
import 'game_action.dart';

enum GamePhase {
  /// Waiting for the opening roll that decides who starts.
  opening,

  /// The side to move may double (if allowed) or roll.
  awaitingRoll,

  /// Dice are rolled; the side to move must play a turn.
  awaitingMove,

  /// The side to move has doubled; the opponent must take or drop.
  cubeOffered,

  over,
}

enum GameEndReason { bearOff, doubleDropped, resignation, forfeit }

/// Per-game options, usually derived from `MatchState.gameConfig`.
class GameConfig {
  const GameConfig({
    this.cubeEnabled = true,
    this.jacoby = false,
    this.maxCubeValue = 64,
  });

  /// False for variants without a cube and during the Crawford game.
  final bool cubeEnabled;

  /// Money play only: gammons count single until the cube is turned.
  final bool jacoby;

  /// No double may be offered that would exceed this value.
  final int maxCubeValue;
}

class GameResult {
  const GameResult({
    required this.winner,
    required this.kind,
    required this.cubeValue,
    required this.points,
    required this.reason,
  });

  final Side winner;
  final WinKind kind;
  final int cubeValue;
  final int points;
  final GameEndReason reason;

  Map<String, Object?> toJson() => {
    'winner': winner.name,
    'kind': kind.name,
    'cubeValue': cubeValue,
    'points': points,
    'reason': reason.name,
  };

  @override
  String toString() =>
      'GameResult(${winner.name} wins ${kind.name} x$cubeValue = $points, '
      '${reason.name})';
}

/// Thrown when an action is not allowed in the current game state.
class IllegalActionException implements Exception {
  IllegalActionException(this.message);

  final String message;

  @override
  String toString() => 'IllegalActionException: $message';
}

/// Immutable game state machine. Every transition goes through [apply],
/// which validates the action completely, so the server can feed client
/// intents straight into it.
class GameState {
  GameState._({
    required this.rules,
    required this.config,
    required this.board,
    required this.cube,
    required this.phase,
    this.dice,
    this.resignOffer,
    this.result,
  });

  /// A new game waiting for its opening roll.
  factory GameState.newGame(
    RuleSet rules, {
    GameConfig config = const GameConfig(),
  }) => GameState._(
    rules: rules,
    config: GameConfig(
      cubeEnabled: config.cubeEnabled && rules.usesCube,
      jacoby: config.jacoby,
      maxCubeValue: config.maxCubeValue,
    ),
    board: rules.initialState(),
    cube: DoublingCube.initial,
    phase: GamePhase.opening,
  );

  final RuleSet rules;
  final GameConfig config;
  final BoardState board;
  final DoublingCube cube;
  final GamePhase phase;
  final DiceRoll? dice;

  /// A pending resignation offer: who offers and at what level.
  final (Side, WinKind)? resignOffer;
  final GameResult? result;

  Side get turn => board.turn;
  bool get isOver => phase == GamePhase.over;

  TurnPlanner? _planner;

  /// Planner for the current roll (only in [GamePhase.awaitingMove]).
  TurnPlanner get planner {
    if (phase != GamePhase.awaitingMove) {
      throw IllegalActionException('No roll to play');
    }
    return _planner ??= rules.planner(board, dice!);
  }

  List<Turn> get legalTurns => planner.legalTurns;

  /// True when the rolled dice cannot be played at all.
  bool get mustPass => planner.maxDiceUsed == 0;

  /// Whether [side] may offer a double right now.
  bool canDouble(Side side) =>
      phase == GamePhase.awaitingRoll &&
      side == turn &&
      resignOffer == null &&
      config.cubeEnabled &&
      cube.isAvailableTo(side) &&
      cube.value * 2 <= config.maxCubeValue;

  GameState _copy({
    BoardState? board,
    DoublingCube? cube,
    GamePhase? phase,
    DiceRoll? Function()? dice,
    (Side, WinKind)? Function()? resignOffer,
    GameResult? result,
  }) => GameState._(
    rules: rules,
    config: config,
    board: board ?? this.board,
    cube: cube ?? this.cube,
    phase: phase ?? this.phase,
    dice: dice != null ? dice() : this.dice,
    resignOffer: resignOffer != null ? resignOffer() : this.resignOffer,
    result: result ?? this.result,
  );

  GameState _finish(Side winner, WinKind kind, GameEndReason reason) {
    final singleOnly = config.jacoby && !cube.isTurned;
    final effective = singleOnly ? WinKind.single : kind;
    return _copy(
      phase: GamePhase.over,
      dice: () => null,
      resignOffer: () => null,
      result: GameResult(
        winner: winner,
        kind: kind,
        cubeValue: cube.value,
        points: effective.multiplier * cube.value,
        reason: reason,
      ),
    );
  }

  void _require(bool condition, String message) {
    if (!condition) throw IllegalActionException(message);
  }

  /// Applies [action] and returns the new state, or throws
  /// [IllegalActionException] / [IllegalMoveException].
  GameState apply(GameAction action) {
    _require(!isOver, 'Game is over');
    if (action is SideAction) {
      _require(
        resignOffer == null ||
            action is AcceptResignation ||
            action is RejectResignation,
        'A resignation offer is pending',
      );
    }
    switch (action) {
      case OpeningRoll(:final white, :final black):
        _require(phase == GamePhase.opening, 'Opening roll already done');
        if (white == black) return this;
        final first = white > black ? Side.white : Side.black;
        final started = board.withTurn(first);
        if (rules.openingRollIsFirstMove) {
          return _copy(
            board: started,
            phase: GamePhase.awaitingMove,
            dice: () => DiceRoll(white, black),
          );
        }
        return _copy(board: started, phase: GamePhase.awaitingRoll);

      case RollDice(:final by, :final roll):
        _require(phase == GamePhase.awaitingRoll, 'Cannot roll now');
        _require(by == turn, 'Not ${by.name}\'s turn');
        return _copy(phase: GamePhase.awaitingMove, dice: () => roll);

      case PlayTurn(:final by, :final moves):
        _require(phase == GamePhase.awaitingMove, 'No dice to play');
        _require(by == turn, 'Not ${by.name}\'s turn');
        final next = planner.play(moves).result;
        final winner = rules.winner(next);
        if (winner != null) {
          return _copy(
            board: next,
          )._finish(winner, rules.winKind(next), GameEndReason.bearOff);
        }
        return _copy(
          board: next,
          phase: GamePhase.awaitingRoll,
          dice: () => null,
        );

      case OfferDouble(:final by):
        _require(canDouble(by), '${by.name} cannot double now');
        return _copy(phase: GamePhase.cubeOffered);

      case TakeDouble(:final by):
        _require(phase == GamePhase.cubeOffered, 'No double to take');
        _require(by == turn.opponent, 'Only the opponent can take');
        return _copy(cube: cube.doubledTo(by), phase: GamePhase.awaitingRoll);

      case DropDouble(:final by):
        _require(phase == GamePhase.cubeOffered, 'No double to drop');
        _require(by == turn.opponent, 'Only the opponent can drop');
        return _finish(turn, WinKind.single, GameEndReason.doubleDropped);

      case OfferResignation(:final by, :final kind):
        _require(phase != GamePhase.opening, 'Game has not started');
        return _copy(resignOffer: () => (by, kind));

      case AcceptResignation(:final by):
        final offer = resignOffer;
        _require(offer != null, 'No resignation offered');
        _require(by == offer!.$1.opponent, 'Only the opponent can accept');
        return _finish(by, offer.$2, GameEndReason.resignation);

      case RejectResignation(:final by):
        final offer = resignOffer;
        _require(offer != null, 'No resignation offered');
        _require(by == offer!.$1.opponent, 'Only the opponent can reject');
        return _copy(resignOffer: () => null);

      case Forfeit(:final loser, :final kind):
        return _finish(loser.opponent, kind, GameEndReason.forfeit);
    }
  }
}
