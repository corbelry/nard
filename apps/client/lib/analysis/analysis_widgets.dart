import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nard_core/nard_core.dart';

import '../board/board_layout.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/board_theme.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import 'analysis_engine.dart';

/// "+0.24" / "−0.142" (U+2212 minus, sign always shown).
String signed(double v, {int digits = 2}) {
  final text = v.abs().toStringAsFixed(digits);
  return v < 0 ? '−$text' : '+$text';
}

/// 10.1 evaluation bar: White share = (1 + E) / 2, clamped.
class EvalBar extends StatelessWidget {
  const EvalBar({super.key, required this.white});

  /// Evaluation for White in −1 … +1.
  final double white;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final share = ((1 + white.clamp(-1, 1)) / 2).toDouble();
    return Container(
      height: 10,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.evalBlack,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: c.accent.withValues(alpha: .2)),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedFractionallySizedBox(
          duration: NardMotion.fast,
          widthFactor: share,
          heightFactor: 1,
          child: DecoratedBox(decoration: BoxDecoration(gradient: c.evalWhite)),
        ),
      ),
    );
  }
}

/// ✓ / ? / ?? mark of a move-list row (54 wide, right-aligned).
class EvalMark extends StatelessWidget {
  const EvalMark({super.key, required this.cls});

  final EvalClass cls;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final style = NardType.bodyS.copyWith(fontWeight: FontWeight.w700);
    return switch (cls) {
      EvalClass.good => Semantics(
        label: l.analysisMarkGood,
        child: Icon(LucideIcons.check, size: 14, color: c.successText),
      ),
      EvalClass.mistake => Semantics(
        label: l.analysisMarkMistake,
        excludeSemantics: true,
        child: Text('?', style: style.copyWith(color: c.accentHi)),
      ),
      EvalClass.blunder => Semantics(
        label: l.analysisMarkBlunder,
        excludeSemantics: true,
        child: Text('??', style: style.copyWith(color: c.dangerText)),
      ),
    };
  }
}

/// Paints best-move (solid, arrow heads) and played-move (dashed) arrows
/// over the board (sized like the Flame board widget).
class MoveArrowsPainter extends CustomPainter {
  MoveArrowsPainter({
    required this.rules,
    required this.viewer,
    required this.side,
    required this.boardHeight,
    required this.best,
    required this.played,
    required this.bestColor,
    required this.playedColor,
  });

  final RuleSet rules;
  final Side viewer;

  /// The mover (moves are in its numbering).
  final Side side;
  final double boardHeight;
  final List<Move> best;
  final List<Move> played;
  final Color bestColor;
  final Color playedColor;

  @override
  void paint(Canvas canvas, Size size) {
    final layout = BoardLayout(
      rules: rules,
      viewer: viewer,
      height: boardHeight,
    );
    final scale = size.width / BoardGeometry.width;
    canvas.save();
    canvas.scale(scale);
    Offset at(int slot) {
      if (slot == BoardState.off) return layout.tray(side).center;
      return layout.slotCenter(side, slot, 0, 1);
    }

    final dashed =
        Paint()
          ..color = playedColor.withValues(alpha: .85)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
    for (final m in played) {
      _dashed(canvas, at(m.from), at(m.to), dashed);
    }
    final solid =
        Paint()
          ..color = bestColor.withValues(alpha: .9)
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
    for (final m in best) {
      final a = at(m.from);
      final b = at(m.to);
      canvas.drawLine(a, b, solid);
      final angle = atan2(b.dy - a.dy, b.dx - a.dx);
      for (final s in const [-1, 1]) {
        final head = angle + pi + s * 35 * pi / 180;
        canvas.drawLine(b, b + Offset(cos(head), sin(head)) * 12, solid);
      }
    }
    canvas.restore();
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Paint paint) {
    final length = (b - a).distance;
    if (length == 0) return;
    final dir = (b - a) / length;
    for (var d = 0.0; d < length; d += 12) {
      canvas.drawLine(a + dir * d, a + dir * min(d + 6, length), paint);
    }
  }

  @override
  bool shouldRepaint(MoveArrowsPainter old) =>
      old.best != best || old.played != played || old.viewer != viewer;
}

/// 10.1 legend: "Ən yaxşı: …" and "Sənin: … · −0.142", or one line when
/// the played move was the best.
class ArrowsLegend extends StatelessWidget {
  const ArrowsLegend({super.key, required this.eval});

  final MoveEval eval;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final style = NardType.caption.copyWith(fontWeight: FontWeight.w400);
    Widget swatch(Color color, {bool dashed = false}) => SizedBox(
      width: 16,
      height: 3,
      child:
          dashed
              ? Row(
                children: [
                  Expanded(child: ColoredBox(color: color)),
                  const SizedBox(width: 3),
                  Expanded(child: ColoredBox(color: color)),
                ],
              )
              : DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
    );
    if (eval.isBest) {
      return Row(
        children: [
          Icon(LucideIcons.check, size: 14, color: c.successText),
          const SizedBox(width: 6),
          Text(
            l.analysisBestPlayed,
            style: style.copyWith(color: c.successText),
          ),
        ],
      );
    }
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            swatch(c.successText),
            const SizedBox(width: 6),
            Text(
              l.analysisBest(MoveNotation.format(eval.best)),
              style: style.copyWith(color: c.text),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            swatch(c.dangerText, dashed: true),
            const SizedBox(width: 6),
            Text(
              l.analysisYours(
                eval.played.isEmpty
                    ? l.replayNoMove
                    : MoveNotation.format(eval.played),
                signed(-eval.loss, digits: 3),
              ),
              style: style.copyWith(color: c.dangerText, fontFeatures: tabular),
            ),
          ],
        ),
      ],
    );
  }
}

/// Mistake / blunder dots along the replay scrubber.
class ScrubberMarks extends StatelessWidget {
  const ScrubberMarks({
    super.key,
    required this.marks,
    required this.count,
    required this.onTap,
  });

  /// Frame index → class (mistakes and blunders only).
  final Map<int, EvalClass> marks;

  /// Number of frames (positions along the track).
  final int count;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return LayoutBuilder(
      builder: (context, box) {
        // The slider track is inset by the thumb radius (10).
        const inset = 10.0;
        final width = box.maxWidth - 2 * inset;
        return SizedBox(
          height: 12,
          child: Stack(
            children: [
              for (final e in marks.entries)
                Positioned(
                  left:
                      inset +
                      (count <= 1 ? 0 : width * e.key / (count - 1)) -
                      4,
                  top: 2,
                  child: GestureDetector(
                    onTap: () => onTap(e.key),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            e.value == EvalClass.blunder
                                ? c.dangerText
                                : c.accentHi,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
