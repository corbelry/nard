import 'dart:math';
import 'dart:ui';

import 'package:nard_core/nard_core.dart';

import '../theme/board_theme.dart';

/// Where things sit on the board in the 640 × H logical space, seen from
/// [viewer] (whose home is bottom right). Pure geometry; no rendering.
class BoardLayout {
  const BoardLayout({
    required this.rules,
    required this.viewer,
    required this.height,
  });

  final RuleSet rules;
  final Side viewer;

  /// [BoardGeometry.heightPortrait] or [BoardGeometry.heightLandscape].
  final double height;

  static const double w = BoardGeometry.width;
  static const double f = BoardGeometry.frame;
  static const double d = BoardGeometry.checker;

  /// x of the bear-off trays.
  static const double trayX =
      f +
      2 * BoardGeometry.quadrant +
      BoardGeometry.bar +
      BoardGeometry.trayGap;

  double get pointHeight =>
      ((height - 2 * f) * BoardGeometry.pointHeightRatio).roundToDouble();

  /// Checkers that fit on a point before stacks compress.
  int get maxFit => (pointHeight / d).floor();

  double get midY => height / 2;

  /// Viewer's point (1..24) where [side]'s own point [slot] is drawn.
  int viewerPoint(Side side, int slot) =>
      side == viewer ? slot : rules.opposite(slot);

  /// Inverse of [viewerPoint]: [side]'s own slot for viewer point [p].
  int ownSlot(Side side, int p) => side == viewer ? p : rules.opposite(p);

  /// Triangle of viewer point [p]: base-left corner x, whether the base is
  /// at the bottom.
  ({double x, bool bottom}) point(int p) => BoardGeometry.point(p);

  /// Polygon of the point triangle (column 40 wide inside the 42 column).
  Path triangle(int p) {
    final g = point(p);
    final x = g.x + 1;
    final path = Path();
    if (g.bottom) {
      final base = height - f;
      path
        ..moveTo(x, base)
        ..lineTo(x + 40, base)
        ..lineTo(x + 20, base - pointHeight);
    } else {
      path
        ..moveTo(x, f)
        ..lineTo(x + 40, f)
        ..lineTo(x + 20, f + pointHeight);
    }
    return path..close();
  }

  /// Center of the k-th checker (0 = at the base) of a stack of [count] on
  /// viewer point [p].
  Offset checkerCenter(int p, int k, int count) {
    final g = point(p);
    final spacing = count <= maxFit ? d : (pointHeight - d) / (count - 1);
    final x = g.x + 2 + d / 2;
    return g.bottom
        ? Offset(x, height - f - d / 2 - k * spacing)
        : Offset(x, f + d / 2 + k * spacing);
  }

  /// Center of the k-th checker on the bar for [side].
  Offset barCenter(Side side, int k) {
    const r = BoardGeometry.barChecker / 2;
    const x = 273 + r;
    return side == viewer
        ? Offset(x, midY + 22 + r + k * 30)
        : Offset(x, midY - 56 + r - k * 30);
  }

  /// Top-left of the k-th borne-off slab for [side].
  Offset slabOrigin(Side side, int k) =>
      side == viewer
          ? Offset(trayX + 3, height - 34 - k * 11)
          : Offset(trayX + 3, 24 + k * 11.0);

  /// Tray rectangle of [side] (viewer bottom, opponent top).
  Rect tray(Side side) {
    final h = (height - 2 * f) / 2 - 26;
    return side == viewer
        ? Rect.fromLTWH(trayX, midY + 26, BoardGeometry.tray, h)
        : Rect.fromLTWH(trayX, f, BoardGeometry.tray, h);
  }

  /// Center of [side]'s checker at own [slot] with stack index [k] of
  /// [count] (bar and off slots included).
  Offset slotCenter(Side side, int slot, int k, int count) {
    if (slot == BoardState.bar) return barCenter(side, k);
    if (slot == BoardState.off) {
      final o = slabOrigin(side, k);
      return Offset(o.dx + 20, o.dy + 5);
    }
    return checkerCenter(viewerPoint(side, slot), k, count);
  }

  /// The slot of [side] under the logical position [pos]: a point, the bar
  /// or (in the mover's tray) off. Null outside any target.
  int? slotAt(Side side, Offset pos) {
    if (pos.dx >= trayX - 4 && pos.dx <= trayX + BoardGeometry.tray + 8) {
      return tray(side).inflate(12).contains(pos) ? BoardState.off : null;
    }
    if (pos.dx >= 277 && pos.dx <= 303) return BoardState.bar;
    for (var c = 0; c < 12; c++) {
      final x = BoardGeometry.colX(c);
      if (pos.dx >= x && pos.dx < x + BoardGeometry.pointWidth) {
        final top = pos.dy < midY;
        final p = top ? 13 + c : 12 - c;
        return ownSlot(side, p);
      }
    }
    return null;
  }

  /// Center of die [j] of [count] in the right (viewer) or left half.
  Offset diceCenter(int j, int count, {required bool viewerSide}) {
    final cx = viewerSide ? 434.0 : 146.0;
    const step = 52.0;
    final start = cx - (count - 1) * step / 2;
    return Offset(start + j * step, midY);
  }

  /// Centered cube position (between the trays) or toward its owner.
  Offset cubeCenter(Side? owner) {
    const x = trayX + BoardGeometry.tray / 2;
    if (owner == null) return Offset(x, midY);
    final t = tray(owner);
    // Owned cube rests at the inner end of the owner's tray.
    return owner == viewer
        ? Offset(x, max(t.top + 22, midY + 48))
        : Offset(x, min(t.bottom - 22, midY - 48));
  }
}
