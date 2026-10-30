import 'board_state.dart';

/// One checker movement by one die, in the mover's own perspective.
///
/// [from] is 1..24 or 25 (bar); [to] is 1..24 or 0 (borne off).
class Move {
  const Move(this.from, this.to, this.die, {this.hit = false});

  final int from;
  final int to;

  /// The die value consumed. For bear-off it may exceed `from - to`.
  final int die;

  /// Whether an opponent blot was sent to the bar (Short Nard only).
  final bool hit;

  bool get isBarEntry => from == BoardState.bar;
  bool get isBearOff => to == BoardState.off;

  @override
  bool operator ==(Object other) =>
      other is Move &&
      other.from == from &&
      other.to == to &&
      other.die == die &&
      other.hit == hit;

  @override
  int get hashCode => Object.hash(from, to, die, hit);

  @override
  String toString() {
    final f = isBarEntry ? 'bar' : '$from';
    final t = isBearOff ? 'off' : '$to';
    return '$f/$t${hit ? '*' : ''}';
  }
}

/// A complete turn: the ordered moves and the resulting position (with the
/// turn already handed to the opponent).
class Turn {
  Turn(List<Move> moves, this.result) : moves = List.unmodifiable(moves);

  final List<Move> moves;
  final BoardState result;

  bool get isPass => moves.isEmpty;

  @override
  bool operator ==(Object other) {
    if (other is! Turn || other.moves.length != moves.length) return false;
    for (var i = 0; i < moves.length; i++) {
      if (other.moves[i] != moves[i]) return false;
    }
    return other.result == result;
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(moves), result);

  @override
  String toString() => isPass ? '(no move)' : moves.join(' ');
}
