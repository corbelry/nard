import 'package:nard_core/nard_core.dart';

import 'match_setup.dart';

/// One offline match in progress: the rules state, the replay record of the
/// current game and the partial turn the local player is building.
///
/// Immutable; every action returns a new session. All rule checks go
/// through `nard_core` (`GameState.apply`, `TurnPlanner`).
class Session {
  const Session._({
    required this.setup,
    required this.match,
    required this.game,
    required this.record,
    required this.finished,
    this.pending = const [],
    this.selected,
    this.rejection,
    this.rejectedMove,
    this.openingDice,
    this.lastTurn = const [],
  });

  factory Session.start(MatchSetup setup) {
    final match = MatchState.start(length: setup.matchLength);
    return Session._(
      setup: setup,
      match: match,
      game: _newGame(setup, match),
      record: _newRecord(setup, match),
      finished: const [],
    );
  }

  /// Rebuilds the session from the server's authoritative state
  /// (`game.state`, ADR-031).
  factory Session.fromServer({
    required MatchSetup setup,
    required MatchState match,
    required GameRecord record,
    List<Move> pending = const [],
  }) {
    final turns = record.actions.whereType<PlayTurn>();
    return Session._(
      setup: setup,
      match: match,
      game: record.replay(),
      record: record,
      finished: const [],
      pending: List.unmodifiable(pending),
      lastTurn: turns.isEmpty ? const [] : turns.last.moves,
    );
  }

  static GameState _newGame(MatchSetup setup, MatchState match) =>
      GameState.newGame(
        rulesFor(setup.variant),
        config: match.gameConfig(cubeEnabled: setup.cube),
      );

  static GameRecord _newRecord(MatchSetup setup, MatchState match) =>
      GameRecord(
        variant: setup.variant,
        config: match.gameConfig(cubeEnabled: setup.cube),
      );

  final MatchSetup setup;

  /// Score before the current game's result is added.
  final MatchState match;
  final GameState game;

  /// Replay log of the current game.
  final GameRecord record;

  /// Records of the games already finished in this match.
  final List<GameRecord> finished;

  /// Moves of the turn being built (not yet confirmed).
  final List<Move> pending;

  /// The slot whose checker is selected (tap-tap moves).
  final int? selected;

  /// Why the last requested move was refused, for the rule banners.
  final MoveRejection? rejection;

  /// The refused `(from, to)` when [rejection] came from a move attempt.
  final (int, int)? rejectedMove;

  /// The last opening throw (White's die, Black's die), shown until the
  /// first move.
  final (int, int)? openingDice;

  /// The previous turn's moves, drawn as last-move markers.
  final List<Move> lastTurn;

  RuleSet get rules => game.rules;
  Side get turn => game.turn;
  GamePhase get phase => game.phase;
  DiceRoll? get dice => game.dice;
  bool get isGameOver => game.isOver;

  /// The match score including the current game once it is over. A score
  /// that is already decided counts it (older servers sent the final score
  /// with the last game).
  MatchState get score =>
      game.result == null || match.isOver
          ? match
          : match.withResult(game.result!);

  bool get isMatchOver => isGameOver && score.isOver;

  /// Whether the side to act is driven by the bot.
  bool get remoteToAct {
    if (isGameOver || phase == GamePhase.opening) return false;
    final actor = phase == GamePhase.cubeOffered ? turn.opponent : turn;
    return setup.isRemote(actor);
  }

  bool get _moving => phase == GamePhase.awaitingMove;

  /// The position shown on the board, including pending moves.
  BoardState get board =>
      _moving ? game.planner.positionAfter(pending) : game.board;

  /// Dice of the current roll not yet used by [pending], highest first.
  List<int> get remainingDice {
    if (!_moving) return const [];
    final left = List<int>.of(dice!.moves);
    for (final m in pending) {
      left.remove(m.die);
    }
    return left;
  }

  /// Legal next moves after [pending].
  List<Move> get nextMoves =>
      _moving ? game.planner.nextMoves(pending) : const [];

  /// Slots holding a checker that can move now.
  Set<int> get movableFrom => {for (final m in nextMoves) m.from};

  /// Destinations reachable from [from] with one die, plus multi-die
  /// destinations of the same checker.
  Set<int> targetsFrom(int from) => {
    for (final path in _paths(from, pending)) path.last.to,
  };

  bool get canConfirm => _moving && game.planner.isComplete(pending);
  bool get mustPass => _moving && game.mustPass;
  bool get canUndo => pending.isNotEmpty;
  bool get canDouble => game.canDouble(turn);

  Session _copy({
    MatchState? match,
    GameState? game,
    GameRecord? record,
    List<GameRecord>? finished,
    List<Move>? pending,
    int? Function()? selected,
    MoveRejection? Function()? rejection,
    (int, int)? Function()? rejectedMove,
    (int, int)? Function()? openingDice,
    List<Move>? lastTurn,
  }) => Session._(
    setup: setup,
    match: match ?? this.match,
    game: game ?? this.game,
    record: record ?? this.record,
    finished: finished ?? this.finished,
    pending: pending ?? this.pending,
    selected: selected != null ? selected() : this.selected,
    rejection: rejection != null ? rejection() : this.rejection,
    rejectedMove:
        rejectedMove != null
            ? rejectedMove()
            : (rejection != null ? null : this.rejectedMove),
    openingDice: openingDice != null ? openingDice() : this.openingDice,
    lastTurn: lastTurn ?? this.lastTurn,
  );

  Session _apply(GameAction action, {List<Move>? lastTurn}) => _copy(
    game: game.apply(action),
    record: record.add(action),
    pending: const [],
    selected: () => null,
    rejection: () => null,
    lastTurn: lastTurn,
  );

  /// Each side throws one die; a tie is recorded and thrown again.
  Session openingRoll(int white, int black) => _apply(
    OpeningRoll(white, black),
  )._copy(openingDice: () => (white, black));

  Session roll(DiceRoll roll) =>
      _apply(RollDice(turn, roll))._copy(openingDice: () => null);

  /// Selects the checker on [from], or records why it cannot move.
  Session select(int from) {
    if (movableFrom.contains(from)) {
      return _copy(selected: () => from, rejection: () => null);
    }
    return _copy(selected: () => null, rejection: () => explainSource(from));
  }

  /// Records a refusal reported by the server.
  Session refused(MoveRejection? reason) =>
      _copy(selected: () => null, rejection: () => reason);

  /// The same session with [selected] (selection is client-side online).
  Session withSelection(int? slot) =>
      _copy(selected: () => slot, rejection: () => null);

  Session clearSelection() =>
      _copy(selected: () => null, rejection: () => null);

  /// Why no checker can leave [from] now.
  MoveRejection explainSource(int from) {
    final planner = game.planner;
    MoveRejection? fallback;
    for (final die in remainingDice.toSet()) {
      final to = from - die < 1 ? BoardState.off : from - die;
      final reason = planner.explain(from, to, pending);
      if (reason == null) continue;
      // A die-specific reason beats "wrong distance".
      if (reason != MoveRejection.noMatchingDie) return reason;
      fallback ??= reason;
    }
    return fallback ?? MoveRejection.turnComplete;
  }

  /// Moves a checker from [from] to [to], using several dice when no
  /// single die reaches. Refused moves set [rejection] and change nothing
  /// else.
  Session move(int from, int to) {
    if (!_moving) return this;
    final paths = _paths(from, pending).where((p) => p.last.to == to);
    if (paths.isEmpty) {
      return _copy(
        selected: () => null,
        rejection: () => game.planner.explain(from, to, pending),
        rejectedMove: () => (from, to),
      );
    }
    // Fewest dice first; among those, the smallest die (exact bear-off).
    final best = paths.reduce((a, b) {
      if (a.length != b.length) return a.length < b.length ? a : b;
      return a.first.die <= b.first.die ? a : b;
    });
    return _copy(
      pending: [...pending, ...best],
      selected: () => null,
      rejection: () => null,
    );
  }

  /// The single-die steps of moving [from] → [to] (empty if impossible).
  List<Move> pathTo(int from, int to) {
    final paths = _paths(from, pending).where((p) => p.last.to == to);
    if (paths.isEmpty) return const [];
    return paths.reduce((a, b) {
      if (a.length != b.length) return a.length < b.length ? a : b;
      return a.first.die <= b.first.die ? a : b;
    });
  }

  /// Every legal sequence moving the same checker on from [from].
  List<List<Move>> _paths(int from, List<Move> played) {
    if (!_moving) return const [];
    final result = <List<Move>>[];
    for (final m in game.planner.nextMoves(played)) {
      if (m.from != from) continue;
      result.add([m]);
      if (m.to == BoardState.off) continue;
      for (final rest in _paths(m.to, [...played, m])) {
        result.add([m, ...rest]);
      }
    }
    return result;
  }

  Session undo() =>
      pending.isEmpty
          ? this
          : _copy(
            pending: pending.sublist(0, pending.length - 1),
            selected: () => null,
            rejection: () => null,
          );

  /// Confirms the pending turn (or the forced pass).
  Session confirm() {
    if (!canConfirm) return this;
    final moves = List<Move>.of(pending);
    return _apply(PlayTurn(turn, moves), lastTurn: moves);
  }

  /// Plays a turn chosen by the bot.
  Session playTurn(List<Move> moves) =>
      _apply(PlayTurn(turn, moves), lastTurn: moves);

  Session offerDouble() => _apply(OfferDouble(turn));
  Session takeDouble() => _apply(TakeDouble(turn.opponent));
  Session dropDouble() => _apply(DropDouble(turn.opponent));

  /// [side] resigns at [kind]; the local opponent accepts at once.
  Session resign(Side side, WinKind kind) => _apply(
    OfferResignation(side, kind),
  )._apply(AcceptResignation(side.opponent));

  /// Starts the next game of the match after a finished game.
  Session nextGame() {
    if (!isGameOver || isMatchOver) {
      throw StateError('No next game: the game is not over or the match is');
    }
    final next = score;
    return Session._(
      setup: setup,
      match: next,
      game: _newGame(setup, next),
      record: _newRecord(setup, next),
      finished: [...finished, record],
    );
  }
}
