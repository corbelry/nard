import '../board_state.dart';
import '../dice.dart';
import '../move.dart';
import '../rules/rule_set.dart';

/// Standard move notation, e.g. `24/18 13/11`, `bar/22*`, `6/off`,
/// `8/5(2)`, `13/7*/1`. Points are in the mover's numbering.
class MoveNotation {
  MoveNotation._();

  static String _point(int slot) =>
      slot == BoardState.bar
          ? 'bar'
          : slot == BoardState.off
          ? 'off'
          : '$slot';

  /// Formats a turn; identical consecutive moves are grouped as `a/b(n)`.
  static String format(List<Move> moves) {
    if (moves.isEmpty) return '';
    final parts = <String>[];
    var i = 0;
    while (i < moves.length) {
      final m = moves[i];
      var n = 1;
      while (i + n < moves.length && moves[i + n] == m) {
        n++;
      }
      parts.add(
        '${_point(m.from)}/${_point(m.to)}${m.hit ? '*' : ''}'
        '${n > 1 ? '($n)' : ''}',
      );
      i += n;
    }
    return parts.join(' ');
  }

  static int _parsePoint(String token, String source) {
    final t = token.toLowerCase();
    if (t == 'bar' || t == 'b') return BoardState.bar;
    if (t == 'off' || t == 'o') return BoardState.off;
    final v = int.tryParse(t);
    if (v == null || v < 0 || v > 25) {
      throw FormatException('Bad point "$token"', source);
    }
    return v;
  }

  /// Parses notation into `(from, to)` checker movements; chains such as
  /// `13/7/1` are split and `(n)` repeats a movement.
  static List<(int, int)> parse(String notation) {
    final result = <(int, int)>[];
    final tokens = notation.trim().split(RegExp(r'[\s,]+'));
    final tokenPattern = RegExp(r'^([^()]+?)(?:\((\d)\))?$');
    for (final token in tokens) {
      if (token.isEmpty) continue;
      final match = tokenPattern.firstMatch(token);
      if (match == null) throw FormatException('Bad move "$token"', notation);
      final repeat = int.parse(match.group(2) ?? '1');
      final points = [
        for (final p in match.group(1)!.split('/'))
          _parsePoint(p.replaceAll('*', ''), notation),
      ];
      if (points.length < 2 || repeat < 1 || repeat > 4) {
        throw FormatException('Bad move "$token"', notation);
      }
      for (var r = 0; r < repeat; r++) {
        for (var i = 0; i + 1 < points.length; i++) {
          if (points[i + 1] >= points[i]) {
            throw FormatException(
              'Moves must go towards home: "$token"',
              notation,
            );
          }
          result.add((points[i], points[i + 1]));
        }
      }
    }
    return result;
  }

  /// Parses [notation] into the legal turn it describes on [board] with
  /// [roll]. A movement may span several dice (`13/7` with 4-2); the turn is
  /// matched by its resulting position.
  static Turn parseTurn(
    String notation,
    RuleSet rules,
    BoardState board,
    DiceRoll roll,
  ) {
    final planner = rules.planner(board, roll);
    final path = parse(notation);
    final direct = planner.resolve(path);
    if (direct != null) return direct;
    // Fall back to matching the resulting position of combined movements.
    var target = board;
    for (final (from, to) in path) {
      if (target.count(board.turn, from) == 0) {
        throw FormatException('No checker on $from', notation);
      }
      final hit = to != BoardState.off && rules.isHit(target, to);
      target = target.relocate(
        from,
        to,
        hitAt: hit ? rules.opposite(to) : null,
      );
    }
    final expected = target.nextTurn();
    for (final turn in planner.legalTurns) {
      if (turn.result == expected) return turn;
    }
    throw FormatException('Not a legal play for $roll', notation);
  }
}
