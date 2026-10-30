import '../board_state.dart';
import '../dice.dart';
import '../move.dart';
import 'move_rejection.dart';
import 'rule_set.dart';

typedef _NodeKey = (BoardState board, int remaining, int headMoves);

class _Child {
  _Child(this.move, this.node);

  final Move move;
  final _Node node;
}

class _Node {
  _Node(this.board, this.remaining, this.headMoves, this.total);

  final BoardState board;

  /// Unused dice, sorted descending.
  final List<int> remaining;
  final int headMoves;

  /// Number of dice granted by the roll.
  final int total;

  int get used => total - remaining.length;

  _NodeKey get key => (board, _encode(remaining), headMoves);

  static int _encode(List<int> dice) {
    var code = 0;
    for (final d in dice) {
      code = code * 7 + d;
    }
    return code;
  }
}

/// Builds and validates one turn for a fixed position and roll.
///
/// Rules enforced here for every variant:
/// * doubles grant four moves of the rolled number;
/// * a player must use as many dice as possible;
/// * if only one die of a non-double can be used, the larger one must be
///   used whenever it is playable.
///
/// A partial sequence is legal exactly when it can still be completed into a
/// sequence that satisfies these rules, which lets UIs validate move by move
/// (and undo) without enumerating every ordering.
class TurnPlanner {
  TurnPlanner(this.rules, this.start, this.roll)
    : _headLimit = rules.headLimit(start, roll) {
    _root = _Node(start, roll.moves, 0, roll.moves.length);
    maxDiceUsed = _maxDepth(_root);
    _largerDiePlayable =
        !roll.isDouble &&
        maxDiceUsed == 1 &&
        _children(_root).any((c) => c.move.die == roll.high);
  }

  final RuleSet rules;
  final BoardState start;
  final DiceRoll roll;
  final int _headLimit;

  late final _Node _root;

  /// How many dice a complete turn must use.
  late final int maxDiceUsed;
  late final bool _largerDiePlayable;

  final Map<_NodeKey, List<_Child>> _childrenMemo = {};
  final Map<_NodeKey, int> _depthMemo = {};

  List<_Child> _children(_Node node) {
    final key = node.key;
    final cached = _childrenMemo[key];
    if (cached != null) return cached;
    final children = <_Child>[];
    int? previousDie;
    for (var i = 0; i < node.remaining.length; i++) {
      final die = node.remaining[i];
      if (die == previousDie) continue;
      previousDie = die;
      final rest = List<int>.of(node.remaining)..removeAt(i);
      final headOpen = node.headMoves < _headLimit;
      for (final move in rules.singleMoves(
        node.board,
        die,
        headOpen: headOpen,
      )) {
        final next = rules.applyMove(node.board, move);
        if (!rules.isLegalAfterMove(next)) continue;
        final head = node.headMoves + (move.from == rules.headPoint ? 1 : 0);
        children.add(_Child(move, _Node(next, rest, head, node.total)));
      }
    }
    _childrenMemo[key] = children;
    return children;
  }

  int _maxDepth(_Node node) {
    final key = node.key;
    final cached = _depthMemo[key];
    if (cached != null) return cached;
    var best = 0;
    for (final child in _children(node)) {
      final d = 1 + _maxDepth(child.node);
      if (d > best) best = d;
      if (best == node.remaining.length) break;
    }
    _depthMemo[key] = best;
    return best;
  }

  List<_Child> _validChildren(_Node node) => [
    for (final c in _children(node))
      if (node.used + 1 + _maxDepth(c.node) == maxDiceUsed &&
          (!_largerDiePlayable || c.move.die == roll.high))
        c,
  ];

  _Node _walk(List<Move> played) {
    var node = _root;
    for (var i = 0; i < played.length; i++) {
      final move = played[i];
      final match = _validChildren(node).where((c) => c.move == move);
      if (match.isEmpty) {
        throw IllegalMoveException(
          'Move $move (step ${i + 1}) is not legal with roll $roll',
        );
      }
      node = match.first.node;
    }
    return node;
  }

  /// The legal moves that may follow [played] (which must itself be a legal
  /// partial turn).
  List<Move> nextMoves([List<Move> played = const []]) => [
    for (final c in _validChildren(_walk(played))) c.move,
  ];

  /// Why moving a checker from [from] to [to] after the legal partial turn
  /// [played] is not allowed, or null when it is legal.
  ///
  /// [to] is [BoardState.off] for bearing off; [from] is [BoardState.bar]
  /// for entering. Throws [IllegalMoveException] if [played] is not legal.
  MoveRejection? explain(int from, int to, [List<Move> played = const []]) {
    final node = _walk(played);
    bool matches(Move m) => m.from == from && m.to == to;
    if (_validChildren(node).any((c) => matches(c.move))) return null;
    if (node.remaining.isEmpty) return MoveRejection.turnComplete;
    final board = node.board;
    final me = board.turn;
    if (board.barCount(me) > 0 && from != BoardState.bar) {
      return MoveRejection.mustEnterFromBar;
    }
    if (board.count(me, from) == 0) return MoveRejection.noChecker;
    final bearOff = to == BoardState.off;
    final dice = {
      for (final d in node.remaining)
        if (bearOff ? from - d <= 0 : from - d == to) d,
    };
    if (dice.isEmpty) return MoveRejection.noMatchingDie;
    if (bearOff && board.highestPoint(me) > 6) {
      return MoveRejection.bearOffNotAllowed;
    }
    if (from == rules.headPoint && node.headMoves >= _headLimit) {
      return MoveRejection.headRule;
    }
    MoveRejection? reason;
    for (final die in dice) {
      if (_children(node).any((c) => matches(c.move) && c.move.die == die)) {
        // Playable on its own, but not part of any complete legal turn.
        return _largerDiePlayable && die != roll.high
            ? MoveRejection.mustUseLargerDie
            : MoveRejection.mustUseBothDice;
      }
      if (bearOff) {
        reason ??= MoveRejection.bearOffHigherDie;
      } else if (!rules.canLand(board, to)) {
        reason ??= MoveRejection.pointClosed;
      } else {
        // Generated by the rule set but rejected by isLegalAfterMove.
        reason ??= MoveRejection.sixBlock;
      }
    }
    return reason;
  }

  /// Whether [played] is a legal partial turn.
  bool isValidPrefix(List<Move> played) {
    try {
      _walk(played);
      return true;
    } on IllegalMoveException {
      return false;
    }
  }

  /// Whether [played] is a legal, complete turn.
  bool isComplete(List<Move> played) =>
      played.length == maxDiceUsed && isValidPrefix(played);

  /// Position after the legal partial turn [played] (turn not switched).
  BoardState positionAfter(List<Move> played) => _walk(played).board;

  /// Validates a complete turn and returns it with the resulting position.
  Turn play(List<Move> moves) {
    final node = _walk(moves);
    if (node.used != maxDiceUsed) {
      throw IllegalMoveException(
        'Turn uses ${node.used} dice but $maxDiceUsed must be used '
        'with roll $roll',
      );
    }
    return Turn(moves, node.board.nextTurn());
  }

  /// Resolves `(from, to)` pairs into a legal complete turn, choosing dice
  /// as needed (bear-off may use a higher die). Returns null if impossible.
  Turn? resolve(List<(int, int)> path) {
    List<Move>? search(_Node node, int index) {
      if (index == path.length) {
        return node.used == maxDiceUsed ? <Move>[] : null;
      }
      final (from, to) = path[index];
      final candidates =
          _validChildren(
              node,
            ).where((c) => c.move.from == from && c.move.to == to).toList()
            ..sort((a, b) => a.move.die.compareTo(b.move.die));
      for (final c in candidates) {
        final rest = search(c.node, index + 1);
        if (rest != null) return [c.move, ...rest];
      }
      return null;
    }

    final moves = search(_root, 0);
    return moves == null ? null : play(moves);
  }

  /// One legal turn per distinct resulting position, in generation order.
  late final List<Turn> legalTurns = _generate();

  List<Turn> _generate() {
    final finals = <BoardState, List<Move>>{};
    final visited = <_NodeKey>{};
    void dfs(_Node node, List<Move> path) {
      if (!visited.add(node.key)) return;
      if (node.used == maxDiceUsed) {
        finals.putIfAbsent(node.board, () => List.of(path));
        return;
      }
      for (final c in _validChildren(node)) {
        path.add(c.move);
        dfs(c.node, path);
        path.removeLast();
      }
    }

    dfs(_root, []);
    return [for (final e in finals.entries) Turn(e.value, e.key.nextTurn())];
  }
}
