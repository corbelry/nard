import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart' show TextPainter, TextSpan, TextStyle;
import 'package:nard_core/nard_core.dart';

import '../cosmetics/board_look.dart';
import '../theme/board_theme.dart';
import '../theme/nard_tokens.dart';
import 'board_layout.dart';
import 'board_scene.dart';

/// Canvas drawing of the board, checkers, dice and cube in the 640 × H
/// logical space, in the scene's [BoardLook] (store.md §1.1; Classic
/// Walnut by default). Shared by the Flame board and static previews.
abstract final class BoardPainter {
  static const _hinge = [
    Color(0xFF8A6A2A),
    Color(0xFFE2C472),
    Color(0xFFA07C30),
  ];
  static const illegal = Color(0xFFE0566C);

  static List<double> _frameStops(int n) =>
      n == 3 ? const [0, .55, 1] : evenStops(n);

  static List<double> _checkerStops(int n) =>
      n == 4 ? const [0, .42, .78, 1] : evenStops(n);

  /// Frame, fields, bar, hinges, points, highlights, numbers and trays.
  static void paintBoard(
    Canvas canvas,
    BoardLayout l,
    BoardScene s, {
    bool slabs = true,
  }) {
    final h = l.height;
    final look = s.look;
    final full = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, BoardLayout.w, h),
      const Radius.circular(12),
    );
    canvas.drawShadow(
      Path()..addRRect(full),
      const Color(0xFF000000),
      14,
      false,
    );
    canvas.drawRRect(
      full,
      Paint()
        ..shader = Gradient.linear(
          Offset.zero,
          Offset(BoardLayout.w * .3, h),
          look.frame,
          _frameStops(look.frame.length),
        ),
    );
    if (look.grain) {
      _grain(canvas, full.outerRect, const Color(0x14000000), 7);
    }
    canvas.drawRRect(
      full.deflate(.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0x73000000),
    );

    final fieldH = h - 2 * BoardLayout.f;
    for (final x in [BoardGeometry.colX(0), BoardGeometry.colX(6)]) {
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, BoardLayout.f, BoardGeometry.quadrant, fieldH),
        const Radius.circular(2),
      );
      final inlay = look.inlay;
      if (inlay != null) _inlay(canvas, r.outerRect.inflate(6), inlay);
      canvas.drawRRect(
        r,
        Paint()
          ..shader = Gradient.linear(
            r.outerRect.topCenter,
            r.outerRect.bottomCenter,
            look.field,
            evenStops(look.field.length),
          ),
      );
      if (look.grain) {
        _grain(canvas, r.outerRect, const Color(0x12000000), 5);
      }
      final glow = look.glow;
      if (glow != null) {
        canvas.save();
        canvas.clipRRect(r);
        canvas.drawRect(
          r.outerRect,
          Paint()
            ..shader = Gradient.radial(
              r.outerRect.bottomCenter,
              r.outerRect.width * .9,
              [glow, glow.withValues(alpha: 0)],
            ),
        );
        canvas.restore();
      }
    }

    // Bar: frame wood darkened at the edges.
    final bar = Rect.fromLTWH(277, BoardLayout.f, 26, fieldH);
    canvas.drawRect(
      bar,
      Paint()
        ..shader = Gradient.linear(
          bar.centerLeft,
          bar.centerRight,
          const [
            Color(0x66000000),
            Color(0x0F000000),
            Color(0x0F000000),
            Color(0x66000000),
          ],
          const [0, .3, .7, 1],
        ),
    );
    for (final y in [.2 * h, .8 * h - 26]) {
      final hinge = RRect.fromRectAndRadius(
        Rect.fromLTWH(286, y, 8, 26),
        const Radius.circular(2),
      );
      canvas.drawRRect(
        hinge,
        Paint()
          ..shader = Gradient.linear(
            hinge.outerRect.centerLeft,
            hinge.outerRect.centerRight,
            _hinge,
            const [0, .45, 1],
          ),
      );
    }

    final targetsV = <int>{};
    for (final t in s.targets) {
      if (t >= 1 && t <= 24 && s.mover != null) {
        targetsV.add(l.viewerPoint(s.mover!, t));
      }
    }
    final illegalV =
        s.illegalTarget != null &&
                s.illegalTarget! >= 1 &&
                s.illegalTarget! <= 24 &&
                s.mover != null
            ? l.viewerPoint(s.mover!, s.illegalTarget!)
            : null;

    for (var p = 1; p <= 24; p++) {
      final path = l.triangle(p);
      final b = path.getBounds();
      final g = l.point(p);
      final base = g.bottom ? b.bottomCenter : b.topCenter;
      final tip = g.bottom ? b.topCenter : b.bottomCenter;
      canvas.drawPath(
        path,
        Paint()
          ..shader = Gradient.linear(
            base,
            tip,
            p.isOdd ? look.pointA : look.pointB,
            evenStops((p.isOdd ? look.pointA : look.pointB).length),
          ),
      );
      if (targetsV.contains(p) || p == illegalV) {
        final c = p == illegalV ? illegal : BoardOverlay.legalFill;
        canvas.drawPath(
          path,
          Paint()
            ..shader = Gradient.linear(base, tip, [
              c.withValues(alpha: p == illegalV ? .9 : .85),
              c.withValues(alpha: p == illegalV ? .15 : .12),
            ]),
        );
      }
      final numberColor =
          p == illegalV
              ? illegal
              : targetsV.contains(p)
              ? BoardOverlay.selectRing
              : look.numbers;
      _text(
        canvas,
        '$p',
        Offset(g.x + BoardGeometry.pointWidth / 2, g.bottom ? h - 16 : 4),
        TextStyle(
          fontFamily: NardFonts.ui,
          fontSize: 9,
          height: 12 / 9,
          fontWeight: FontWeight.w600,
          color: numberColor,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      );
    }

    // Inner shadow along the field edges.
    for (final x in [BoardGeometry.colX(0), BoardGeometry.colX(6)]) {
      final r = Rect.fromLTWH(x, BoardLayout.f, BoardGeometry.quadrant, fieldH);
      canvas.drawRect(
        Rect.fromLTWH(r.left, r.top, r.width, 10),
        Paint()
          ..shader = Gradient.linear(
            r.topCenter,
            r.topCenter + const Offset(0, 10),
            const [Color(0x8C000000), Color(0x00000000)],
          ),
      );
      canvas.drawRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0x59000000),
      );
    }

    for (final side in Side.values) {
      final t = l.tray(side);
      final rr = RRect.fromRectAndRadius(t, const Radius.circular(4));
      canvas.drawRRect(
        rr,
        Paint()
          ..shader = Gradient.linear(
            t.topCenter,
            t.bottomCenter,
            look.tray,
            evenStops(look.tray.length),
          ),
      );
      canvas.drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0x80000000),
      );
      if (side == s.mover && s.targets.contains(BoardState.off)) {
        canvas.drawRRect(
          rr.inflate(1),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = BoardOverlay.selectRing,
        );
        canvas.drawRRect(rr, Paint()..color = BoardOverlay.legalGhostFill);
      }
      if (slabs) {
        for (var k = 0; k < s.board.offCount(side); k++) {
          paintSlab(canvas, l.slabOrigin(side, k), side);
        }
      }
    }

    // Last move "from" ghosts.
    final lastMover = s.lastMover;
    if (lastMover != null) {
      for (final m in s.lastMoves) {
        if (m.from < 1 || m.from > 24) continue;
        final n = s.board.count(lastMover, m.from);
        final c = l.slotCenter(lastMover, m.from, n, n + 1);
        _dashedCircle(
          canvas,
          c,
          BoardLayout.d / 2 - 1,
          BoardOverlay.lastMoveGhost,
        );
      }
    }

    // Legal ghosts at the next free slot of each target.
    final mover = s.mover;
    if (mover != null) {
      for (final t in s.targets) {
        if (t < 1 || t > 24) continue;
        final n = s.board.count(mover, t);
        final c = l.slotCenter(mover, t, n, n + 1);
        canvas.drawCircle(
          c,
          BoardLayout.d / 2 - 1,
          Paint()..color = BoardOverlay.legalGhostFill,
        );
        _dashedCircle(
          canvas,
          c,
          BoardLayout.d / 2 - 1,
          BoardOverlay.legalGhostBorder,
        );
      }
      final it = s.illegalTarget;
      if (it != null && it >= 1 && it <= 24) {
        final n = s.board.count(mover, it);
        final c = l.slotCenter(mover, it, n, n + 1);
        canvas.drawCircle(
          c,
          BoardLayout.d / 2 - 1,
          Paint()..color = illegal.withValues(alpha: .22),
        );
        _dashedCircle(canvas, c, BoardLayout.d / 2 - 1, illegal);
      }
    }
  }

  /// A checker of [side] at [c] in [material] (default: walnut ivory for
  /// White, onyx for Black).
  static void paintChecker(
    Canvas canvas,
    Offset c,
    double radius,
    Side side, {
    bool colorBlind = false,
    CheckerMaterial? material,
  }) {
    final ivory = side == Side.white;
    final m =
        material ?? (ivory ? BoardLook.walnut.light : BoardLook.walnut.dark);
    if (m.flat) {
      canvas.drawCircle(
        c + const Offset(0, 1),
        radius,
        Paint()
          ..color = const Color(0x66000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
      canvas.drawCircle(c, radius, Paint()..color = m.stops.first);
    } else {
      canvas.drawCircle(
        c + const Offset(0, 2.5),
        radius,
        Paint()
          ..color = Color(ivory ? 0x55000000 : 0x73000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawCircle(
        c,
        radius,
        Paint()
          ..shader = Gradient.radial(
            c + Offset(-radius * .24, -radius * .4),
            radius * 1.6,
            m.stops,
            _checkerStops(m.stops.length),
          ),
      );
      final grooveColor = m.groove;
      if (grooveColor != null) {
        final groove =
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1
              ..color = grooveColor;
        for (var r = radius - 6; r > 4; r -= 6) {
          canvas.drawCircle(c, r, groove);
        }
      }
      canvas.drawCircle(
        c,
        radius - .5,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = ivory ? const Color(0x59503719) : const Color(0x99000000),
      );
    }
    final rim = m.rim;
    if (rim != null) {
      final w = m.flat ? 2.0 : 2.5;
      canvas.drawCircle(
        c,
        radius - w / 2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w
          ..color = rim,
      );
    }
    if (colorBlind) {
      if (ivory) {
        canvas.drawCircle(
          c,
          radius * .28,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = radius * .16
            ..color = NardPalette.walnut900,
        );
      } else {
        canvas.drawCircle(
          c,
          radius * .18,
          Paint()..color = NardPalette.brass300,
        );
      }
    }
  }

  /// Borne-off slab (40 × 10) with top-left [o].
  static void paintSlab(Canvas canvas, Offset o, Side side) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        o.dx,
        o.dy,
        BoardGeometry.offSlab.width,
        BoardGeometry.offSlab.height,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      r,
      Paint()
        ..shader = Gradient.linear(
          r.outerRect.topCenter,
          r.outerRect.bottomCenter,
          side == Side.white
              ? const [Color(0xFFFBF4E4), Color(0xFFD9C9A8)]
              : const [Color(0xFF4A4440), Color(0xFF151312)],
        ),
    );
  }

  static const _pipLayout = {
    1: [4],
    2: [2, 6],
    3: [2, 4, 6],
    4: [0, 2, 6, 8],
    5: [0, 2, 4, 6, 8],
    6: [0, 2, 3, 5, 6, 8],
  };

  /// Die of [value] in [dice] centered at [c] (44 × 44 at scale 1).
  static void paintDie(
    Canvas canvas,
    Offset c,
    int value, {
    double size = BoardGeometry.die,
    double angle = 0,
    bool used = false,
    bool largePips = false,
    DiceLook? dice,
  }) {
    final d = dice ?? BoardLook.walnut.dice;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);
    final half = size / 2;
    final rect = Rect.fromLTWH(-half, -half, size, size);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size * 9 / 44));
    final alpha = used ? .4 : 1.0;
    canvas.drawRRect(
      rr.shift(const Offset(0, 4)),
      Paint()
        ..color = Color.fromRGBO(0, 0, 0, .45 * alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    List<Color> faded(List<Color> colors) => [
      for (final c in colors) c.withValues(alpha: c.a * alpha),
    ];
    canvas.drawRRect(
      rr,
      d.flat
          ? (Paint()..color = faded(d.face).first)
          : (Paint()
            ..shader = Gradient.linear(
              rect.topLeft,
              rect.bottomRight,
              faded(d.face),
              evenStops(d.face.length),
            )),
    );
    final scale = size / 44;
    final pip = (largePips ? 9.5 : 7.5) * scale;
    for (final idx in _pipLayout[value]!) {
      final row = idx ~/ 3;
      final col = idx % 3;
      final p = Offset(
        -half + (8 + col * 10.5 + 3.75) * scale,
        -half + (8 + row * 10.5 + 3.75) * scale,
      );
      canvas.drawCircle(
        p,
        pip / 2,
        d.flat
            ? (Paint()..color = faded(d.pip).first)
            : (Paint()
              ..shader = Gradient.radial(
                p,
                pip / 2,
                faded(d.pip),
                evenStops(d.pip.length),
              )),
      );
    }
    canvas.restore();
  }

  /// Doubling cube showing [label] centered at [c].
  static void paintCube(
    Canvas canvas,
    Offset c,
    String label, {
    double size = BoardGeometry.cube,
    bool offer = false,
  }) {
    final rect = Rect.fromCenter(center: c, width: size, height: size);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(offer ? 10 : 6));
    if (offer) {
      canvas.drawRRect(
        rr.inflate(8),
        Paint()
          ..color = const Color(0x73F0CD6E)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
      );
    }
    canvas.drawRRect(
      rr.shift(const Offset(0, 3)),
      Paint()
        ..color = const Color(0x8C000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..shader = Gradient.linear(rect.topLeft, rect.bottomRight, [
          const Color(0xFFFBF5E8),
          Color(offer ? 0xFFDDCDAA : 0xFFD6C5A0),
        ]),
    );
    if (offer) {
      canvas.drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = BoardOverlay.selectRing,
      );
    }
    _text(
      canvas,
      label,
      c,
      TextStyle(
        fontFamily: offer ? NardFonts.display : NardFonts.ui,
        fontSize: offer ? 28 : 13,
        fontWeight: FontWeight.w700,
        color: NardPalette.walnut900,
        height: 1,
      ),
      centerY: true,
    );
  }

  static void _text(
    Canvas canvas,
    String text,
    Offset anchor,
    TextStyle style, {
    bool centerY = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(
        anchor.dx - tp.width / 2,
        centerY ? anchor.dy - tp.height / 2 : anchor.dy,
      ),
    );
  }

  /// Stack count label on the top checker (only when compressed).
  static void paintCount(Canvas canvas, Offset c, int count, Side side) {
    _text(
      canvas,
      '$count',
      c,
      TextStyle(
        fontFamily: NardFonts.ui,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1,
        color:
            side == Side.white
                ? const Color(0xFF4A3620)
                : const Color(0xFFEFE4CF),
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      centerY: true,
    );
  }

  static void _dashedCircle(Canvas canvas, Offset c, double r, Color color) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = color;
    const dashes = 16;
    for (var i = 0; i < dashes; i++) {
      final a = i * 2 * pi / dashes;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        a,
        pi / dashes,
        false,
        paint,
      );
    }
  }

  /// Inlay band behind a field: a gradient for 2–3 colours, diagonal
  /// xatam stripes (3-2-3-2 of 10 pt) for 4+.
  static void _inlay(Canvas canvas, Rect r, List<Color> colors) {
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(4));
    if (colors.length < 4) {
      canvas.drawRRect(
        rr,
        Paint()
          ..shader = Gradient.linear(
            r.topCenter,
            r.bottomCenter,
            colors,
            evenStops(colors.length),
          ),
      );
      return;
    }
    const widths = [3.0, 2.0, 3.0, 2.0];
    final total = widths.reduce((a, b) => a + b);
    final stripeColors = <Color>[];
    final stops = <double>[];
    var at = 0.0;
    for (var i = 0; i < 4; i++) {
      stripeColors.addAll([colors[i], colors[i]]);
      stops.addAll([at / total, (at + widths[i]) / total]);
      at += widths[i];
    }
    canvas.drawRRect(
      rr,
      Paint()
        ..shader = Gradient.linear(
          r.topLeft,
          r.topLeft + Offset(total / sqrt2, total / sqrt2),
          stripeColors,
          stops,
          TileMode.repeated,
        ),
    );
  }

  /// Faint vertical grain lines over wood.
  static void _grain(Canvas canvas, Rect r, Color color, double step) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1;
    var i = 0;
    for (var x = r.left + 2; x < r.right; x += step) {
      final wobble = sin(i++ * 1.7) * 1.5;
      canvas.drawLine(
        Offset(x + wobble, r.top),
        Offset(x - wobble, r.bottom),
        paint,
      );
    }
  }
}
