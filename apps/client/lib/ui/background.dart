import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/nard_colors.dart';
import 'extra_tokens.dart';

/// Screen background: the theme gradient plus, in sebeke, the şəbəkə
/// lattice band fading out of the top 300 pt. Never flat black.
class NardBackground extends StatelessWidget {
  const NardBackground({super.key, required this.child, this.band = true});

  final Widget child;
  final bool band;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return DecoratedBox(
      decoration: BoxDecoration(gradient: c.bgGradient),
      child: Stack(
        children: [
          if (band && c.latticeBand)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 300,
              child: IgnorePointer(
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback:
                      (rect) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Colors.transparent],
                      ).createShader(rect),
                  child: CustomPaint(
                    painter: LatticePainter(
                      color: c.accent.withValues(alpha: .11),
                      horizontal: c.accent.withValues(alpha: .06),
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

/// ±60° hairlines every [spacing] pt, optionally with horizontal lines.
class LatticePainter extends CustomPainter {
  const LatticePainter({
    required this.color,
    this.horizontal,
    this.spacing = 18,
    this.horizontalSpacing = 15.6,
  });

  final Color color;
  final Color? horizontal;
  final double spacing;
  final double horizontalSpacing;

  @override
  void paint(Canvas canvas, Size size) {
    // The diagonals start outside the box; without the clip Impeller draws
    // the overhang past a ShaderMask's fade (hero card on Android).
    canvas.clipRect(Offset.zero & size);
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1;
    // A line at 60° advances by h / tan(60°) horizontally over height h;
    // perpendicular spacing s means a horizontal step of s / sin(60°).
    final run = size.height / tan(pi / 3);
    final step = spacing / sin(pi / 3);
    for (var x = -run; x < size.width + run; x += step) {
      canvas.drawLine(Offset(x, size.height), Offset(x + run, 0), paint);
      canvas.drawLine(Offset(x, 0), Offset(x + run, size.height), paint);
    }
    final h = horizontal;
    if (h != null) {
      final hp =
          Paint()
            ..color = h
            ..strokeWidth = 1;
      for (var y = 0.0; y < size.height; y += horizontalSpacing) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), hp);
      }
    }
  }

  @override
  bool shouldRepaint(LatticePainter old) =>
      old.color != color || old.horizontal != horizontal;
}
