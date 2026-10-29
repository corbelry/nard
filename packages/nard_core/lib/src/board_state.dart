import 'dart:typed_data';

import 'side.dart';
import 'zobrist.dart';

/// Immutable board position.
///
/// Each side's checkers are stored in that side's **own perspective**:
/// slot 0 is borne off, slots 1..24 are points (the side moves from 24
/// towards 1 and bears off from its home board 1..6), slot 25 is the bar.
/// How one side's point maps onto the other side's numbering is variant
/// geometry and lives in the rule set.
class BoardState {
  BoardState._(this._counts, this.turn, this._turnsTaken)
    : zobrist = Zobrist.hash(_counts, blackToMove: turn == Side.black);

  /// Builds a position from two 26-slot lists (index 0 = off, 25 = bar).
  ///
  /// Throws [ArgumentError] unless each side has exactly 15 non-negative
  /// checkers. Cross-side overlap is checked by `RuleSet.validate`.
  factory BoardState.fromSlots({
    required List<int> white,
    required List<int> black,
    Side turn = Side.white,
    int whiteTurnsTaken = 0,
    int blackTurnsTaken = 0,
  }) {
    final counts = Uint8List(slotsPerSide * 2);
    for (final (sideIndex, slots) in [(0, white), (1, black)]) {
      if (slots.length != slotsPerSide) {
        throw ArgumentError(
          'Expected $slotsPerSide slots, got ${slots.length}',
        );
      }
      var total = 0;
      for (var i = 0; i < slotsPerSide; i++) {
        final c = slots[i];
        if (c < 0) throw ArgumentError('Negative checker count at slot $i');
        total += c;
        counts[sideIndex * slotsPerSide + i] = c;
      }
      if (total != checkersPerSide) {
        throw ArgumentError(
          '${Side.values[sideIndex].name} has $total checkers, '
          'expected $checkersPerSide',
        );
      }
    }
    if (whiteTurnsTaken < 0 || blackTurnsTaken < 0) {
      throw ArgumentError('turnsTaken must be non-negative');
    }
    return BoardState._(counts, turn, (whiteTurnsTaken, blackTurnsTaken));
  }

  /// Builds a position from `{point: count}` maps (keys 1..24, or [bar]).
  /// Checkers not placed are considered borne off.
  factory BoardState.fromPoints({
    required Map<int, int> white,
    required Map<int, int> black,
    Side turn = Side.white,
    int whiteTurnsTaken = 0,
    int blackTurnsTaken = 0,
  }) {
    List<int> toSlots(Map<int, int> points) {
      final slots = List<int>.filled(slotsPerSide, 0);
      var placed = 0;
      points.forEach((point, count) {
        if (point < 1 || point > bar) {
          throw ArgumentError('Point $point out of range 1..25');
        }
        slots[point] += count;
        placed += count;
      });
      slots[off] = checkersPerSide - placed;
      return slots;
    }

    return BoardState.fromSlots(
      white: toSlots(white),
      black: toSlots(black),
      turn: turn,
      whiteTurnsTaken: whiteTurnsTaken,
      blackTurnsTaken: blackTurnsTaken,
    );
  }

  static const int checkersPerSide = 15;
  static const int slotsPerSide = 26;
  static const int off = 0;
  static const int bar = 25;

  final Uint8List _counts;
  final (int, int) _turnsTaken;

  /// The side to move.
  final Side turn;

  /// 53-bit Zobrist key (identical on VM and web).
  final int zobrist;

  int count(Side side, int slot) => _counts[side.index * slotsPerSide + slot];

  int offCount(Side side) => count(side, off);
  int barCount(Side side) => count(side, bar);

  /// Number of turns [side] has completed in this game.
  int turnsTaken(Side side) =>
      side == Side.white ? _turnsTaken.$1 : _turnsTaken.$2;

  /// A copy of [side]'s 26 slots.
  List<int> slots(Side side) => List<int>.unmodifiable(
    _counts.sublist(side.index * slotsPerSide, (side.index + 1) * slotsPerSide),
  );

  /// Pips [side] still needs to bear off every checker.
  int pipCount(Side side) {
    var pips = 0;
    for (var slot = 1; slot <= bar; slot++) {
      pips += slot * count(side, slot);
    }
    return pips;
  }

  /// Highest occupied point of [side] (25 if on the bar, 0 if all off).
  int highestPoint(Side side) {
    for (var slot = bar; slot >= 1; slot--) {
      if (count(side, slot) > 0) return slot;
    }
    return off;
  }

  /// True when every checker of [side] is in its home board or borne off.
  bool allHome(Side side) => highestPoint(side) <= 6;

  BoardState withTurn(Side side) =>
      side == turn ? this : BoardState._(_counts, side, _turnsTaken);

  /// Ends the current turn: hands the move to the opponent and increments the
  /// mover's completed-turn counter.
  BoardState nextTurn() => BoardState._(
    _counts,
    turn.opponent,
    turn == Side.white
        ? (_turnsTaken.$1 + 1, _turnsTaken.$2)
        : (_turnsTaken.$1, _turnsTaken.$2 + 1),
  );

  /// Moves one checker of the side to move from [from] to [to] (0 = off).
  /// When [hitAt] is given, the opponent checker on that slot (opponent's
  /// numbering) is sent to the opponent's bar. No legality checks.
  BoardState relocate(int from, int to, {int? hitAt}) {
    final counts = Uint8List.fromList(_counts);
    final me = turn.index * slotsPerSide;
    counts[me + from]--;
    counts[me + to]++;
    if (hitAt != null) {
      final opp = turn.opponent.index * slotsPerSide;
      counts[opp + hitAt]--;
      counts[opp + bar]++;
    }
    return BoardState._(counts, turn, _turnsTaken);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BoardState ||
        other.zobrist != zobrist ||
        other.turn != turn ||
        other._turnsTaken != _turnsTaken) {
      return false;
    }
    for (var i = 0; i < _counts.length; i++) {
      if (_counts[i] != other._counts[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => zobrist;

  @override
  String toString() {
    String side(Side s) {
      final parts = <String>[];
      for (var slot = bar; slot >= 1; slot--) {
        final c = count(s, slot);
        if (c > 0) parts.add('${slot == bar ? 'bar' : slot}:$c');
      }
      final o = offCount(s);
      if (o > 0) parts.add('off:$o');
      return parts.join(' ');
    }

    return 'BoardState(turn: ${turn.name}, white: [${side(Side.white)}], '
        'black: [${side(Side.black)}])';
  }
}
