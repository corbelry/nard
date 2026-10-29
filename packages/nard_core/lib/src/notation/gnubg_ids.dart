import 'dart:convert';
import 'dart:typed_data';

import '../board_state.dart';
import '../cube.dart';
import '../dice.dart';
import '../side.dart';

/// GNU Backgammon Position ID (Short Nard only).
///
/// The player on roll is encoded first: for each of its points 1..24 and
/// then the bar, one `1` bit per checker followed by a `0`; then the same for
/// the opponent. The 80 bits are packed little-endian into 10 bytes and
/// Base64-encoded without padding (14 characters).
class PositionId {
  PositionId._();

  static String encode(BoardState board) {
    final key = Uint8List(10);
    var bit = 0;
    for (final side in [board.turn, board.turn.opponent]) {
      for (var slot = 1; slot <= BoardState.bar; slot++) {
        for (var c = board.count(side, slot); c > 0; c--) {
          key[bit >> 3] |= 1 << (bit & 7);
          bit++;
        }
        bit++;
      }
    }
    return base64.encode(key).substring(0, 14);
  }

  /// Decodes [id] into a position with [onRoll] to move.
  static BoardState decode(String id, {Side onRoll = Side.white}) {
    if (id.length != 14) {
      throw FormatException('Position ID must be 14 chars', id);
    }
    final Uint8List key;
    try {
      key = base64.decode('$id==');
    } on FormatException {
      throw FormatException('Invalid Position ID', id);
    }
    final slots = [List<int>.filled(26, 0), List<int>.filled(26, 0)];
    var bit = 0;
    for (var s = 0; s < 2; s++) {
      for (var slot = 1; slot <= BoardState.bar; slot++) {
        while (bit < 80 && (key[bit >> 3] >> (bit & 7)) & 1 == 1) {
          slots[s][slot]++;
          bit++;
        }
        bit++;
      }
    }
    for (final s in slots) {
      final onBoard = s.fold<int>(0, (a, b) => a + b);
      if (onBoard > BoardState.checkersPerSide) {
        throw FormatException('Too many checkers in Position ID', id);
      }
      s[BoardState.off] = BoardState.checkersPerSide - onBoard;
    }
    final mover = slots[0];
    final other = slots[1];
    return BoardState.fromSlots(
      white: onRoll == Side.white ? mover : other,
      black: onRoll == Side.white ? other : mover,
      turn: onRoll,
    );
  }
}

/// gnubg game state field of the Match ID.
enum MatchIdGameState { none, playing, over, resigned, dropped }

/// Decoded GNU Backgammon Match ID. Player 0 is [Side.white].
class MatchIdData {
  const MatchIdData({
    required this.cube,
    required this.onRoll,
    required this.turn,
    required this.crawford,
    required this.gameState,
    required this.doubled,
    required this.resigned,
    required this.dice,
    required this.matchLength,
    required this.whiteScore,
    required this.blackScore,
  });

  final DoublingCube cube;

  /// The side holding the dice (fMove).
  final Side onRoll;

  /// The side that must make the next decision (fTurn), e.g. the taker.
  final Side turn;
  final bool crawford;
  final MatchIdGameState gameState;
  final bool doubled;

  /// 0 none, 1 single, 2 gammon, 3 backgammon.
  final int resigned;

  /// Null if the dice have not been rolled.
  final DiceRoll? dice;
  final int matchLength;
  final int whiteScore;
  final int blackScore;

  @override
  bool operator ==(Object other) =>
      other is MatchIdData &&
      other.cube == cube &&
      other.onRoll == onRoll &&
      other.turn == turn &&
      other.crawford == crawford &&
      other.gameState == gameState &&
      other.doubled == doubled &&
      other.resigned == resigned &&
      other.dice == dice &&
      other.matchLength == matchLength &&
      other.whiteScore == whiteScore &&
      other.blackScore == blackScore;

  @override
  int get hashCode => Object.hash(
    cube,
    onRoll,
    turn,
    crawford,
    gameState,
    doubled,
    resigned,
    dice,
    matchLength,
    whiteScore,
    blackScore,
  );
}

/// GNU Backgammon Match ID: 66 bits packed little-endian into 9 bytes,
/// Base64 encoded (12 characters). gnubg's optional extended bit 66
/// (Jacoby) is always written as 0 and ignored when reading.
class MatchId {
  MatchId._();

  static void _set(Uint8List key, int pos, int bits, int value) {
    for (var i = 0; i < bits; i++) {
      if ((value >> i) & 1 == 1) key[(pos + i) >> 3] |= 1 << ((pos + i) & 7);
    }
  }

  static int _get(Uint8List key, int pos, int bits) {
    var value = 0;
    for (var i = 0; i < bits; i++) {
      value |= ((key[(pos + i) >> 3] >> ((pos + i) & 7)) & 1) << i;
    }
    return value;
  }

  static String encode(MatchIdData d) {
    final log = d.cube.value.bitLength - 1;
    if (d.cube.value != 1 << log || log > 15) {
      throw ArgumentError('Cube value ${d.cube.value} cannot be encoded');
    }
    if (d.matchLength > 0x7FFF ||
        d.whiteScore > 0x7FFF ||
        d.blackScore > 0x7FFF) {
      throw ArgumentError('Score out of range');
    }
    final key = Uint8List(9);
    _set(key, 0, 4, log);
    _set(key, 4, 2, d.cube.owner?.index ?? 3);
    _set(key, 6, 1, d.onRoll.index);
    _set(key, 7, 1, d.crawford ? 1 : 0);
    _set(key, 8, 3, d.gameState.index);
    _set(key, 11, 1, d.turn.index);
    _set(key, 12, 1, d.doubled ? 1 : 0);
    _set(key, 13, 2, d.resigned);
    _set(key, 15, 3, d.dice?.high ?? 0);
    _set(key, 18, 3, d.dice?.low ?? 0);
    _set(key, 21, 15, d.matchLength);
    _set(key, 36, 15, d.whiteScore);
    _set(key, 51, 15, d.blackScore);
    return base64.encode(key);
  }

  static MatchIdData decode(String id) {
    if (id.length != 12) throw FormatException('Match ID must be 12 chars', id);
    final Uint8List key;
    try {
      key = base64.decode(id);
    } on FormatException {
      throw FormatException('Invalid Match ID', id);
    }
    final owner = _get(key, 4, 2);
    final state = _get(key, 8, 3);
    final d1 = _get(key, 15, 3);
    final d2 = _get(key, 18, 3);
    final length = _get(key, 21, 15);
    final white = _get(key, 36, 15);
    final black = _get(key, 51, 15);
    final crawford = _get(key, 7, 1) == 1;
    if (owner == 2 ||
        state >= MatchIdGameState.values.length ||
        d1 > 6 ||
        d2 > 6 ||
        (d1 == 0) != (d2 == 0) ||
        (length > 0 && (white > length || black > length)) ||
        (length == 0 && crawford)) {
      throw FormatException('Inconsistent Match ID', id);
    }
    return MatchIdData(
      cube: DoublingCube(
        value: 1 << _get(key, 0, 4),
        owner: owner == 3 ? null : Side.values[owner],
      ),
      onRoll: Side.values[_get(key, 6, 1)],
      turn: Side.values[_get(key, 11, 1)],
      crawford: crawford,
      gameState: MatchIdGameState.values[state],
      doubled: _get(key, 12, 1) == 1,
      resigned: _get(key, 13, 2),
      dice: d1 == 0 ? null : DiceRoll(d1, d2),
      matchLength: length,
      whiteScore: white,
      blackScore: black,
    );
  }
}
