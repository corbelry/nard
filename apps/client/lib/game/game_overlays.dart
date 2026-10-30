import 'package:flutter/material.dart';
import 'package:nard_core/nard_core.dart';

import '../board/board_painter.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/background.dart';
import '../ui/buttons.dart';
import '../ui/layout.dart';

/// Pass & play hand-over screen (18.2): hides the board until the next
/// player is ready.
class HandoffView extends StatelessWidget {
  const HandoffView({
    super.key,
    required this.side,
    required this.overline,
    required this.title,
    required this.body,
    required this.readyLabel,
    required this.onReady,
    this.undoLabel,
    this.onUndo,
  });

  final Side side;
  final String overline;
  final String title;
  final String body;
  final String readyLabel;
  final VoidCallback onReady;
  final String? undoLabel;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -.1),
          radius: 1.1,
          colors: [Color(0xFF4A321F), Color(0xFF2B1D14), Color(0xFF120C08)],
          stops: [0, .55, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: LatticePainter(color: c.accent.withValues(alpha: .07)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0x80D4AE58),
                              width: 4,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x80000000),
                                offset: Offset(0, 20),
                                blurRadius: 40,
                              ),
                            ],
                          ),
                          child: CustomPaint(
                            size: const Size(120, 120),
                            painter: _CheckerPainter(side),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Overline(overline, color: c.accent, spacing: .96),
                        const SizedBox(height: 16),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: NardType.displayL.copyWith(
                            fontSize: 32,
                            height: 38 / 32,
                            color: c.text,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          body,
                          textAlign: TextAlign.center,
                          style: NardType.body.copyWith(
                            height: 22 / 15,
                            color: c.text.withValues(alpha: .7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, bottom > 0 ? 6 : 24),
                  child: Column(
                    children: [
                      NardButton(label: readyLabel, onPressed: onReady),
                      if (undoLabel != null) ...[
                        const SizedBox(height: 10),
                        NardButton(
                          label: undoLabel!,
                          onPressed: onUndo,
                          variant: NardButtonVariant.ghost,
                          size: NardButtonSize.m,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckerPainter extends CustomPainter {
  const _CheckerPainter(this.side);

  final Side side;

  @override
  void paint(Canvas canvas, Size size) => BoardPainter.paintChecker(
    canvas,
    size.center(Offset.zero),
    size.width / 2,
    side,
  );

  @override
  bool shouldRepaint(_CheckerPainter old) => old.side != side;
}

/// Match result (2.6). Offline: no rating, rewards or missions.
class MatchResultView extends StatelessWidget {
  const MatchResultView({
    super.key,
    required this.title,
    required this.won,
    required this.meScore,
    required this.oppScore,
    required this.meta,
    required this.rematchLabel,
    required this.onRematch,
    required this.homeLabel,
    required this.onHome,
    required this.replayLabel,
    required this.onReplay,
    this.extra,
  });

  /// Shown under the score (2.6 rating card of ranked matches).
  final Widget? extra;

  final String title;
  final bool won;
  final int meScore;
  final int oppScore;
  final String meta;
  final String rematchLabel;
  final VoidCallback onRematch;
  final String homeLabel;
  final VoidCallback onHome;
  final String replayLabel;
  final VoidCallback? onReplay;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -.56),
          radius: 1.0,
          // Brass glow blended into walnut (opaque, so nothing shows
          // through); dimmer after a loss.
          colors: [
            won ? const Color(0xFF6A5028) : const Color(0xFF45321F),
            NardPalette.walnut900,
            NardPalette.walnut950,
          ],
          stops: const [0, .6, 1],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, bottom > 0 ? 6 : 24),
          child: Column(
            children: [
              const Spacer(),
              const OrnamentDivider(),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: NardType.displayL.copyWith(
                  fontSize: 34,
                  height: 40 / 34,
                  letterSpacing: 1.36,
                  color: won ? c.accentHi : c.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$meScore – $oppScore',
                style: NardType.displayXl.copyWith(
                  fontSize: 44,
                  height: 48 / 44,
                  color: c.text,
                  fontFeatures: tabular,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                meta,
                textAlign: TextAlign.center,
                style: NardType.bodyS.copyWith(color: c.textDim),
              ),
              if (extra != null) ...[const SizedBox(height: 20), extra!],
              const Spacer(flex: 2),
              Row(
                children: [
                  Expanded(
                    child: NardButton(
                      label: replayLabel,
                      onPressed: onReplay,
                      variant: NardButtonVariant.secondary,
                      size: NardButtonSize.m,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: NardButton(
                      label: homeLabel,
                      onPressed: onHome,
                      variant: NardButtonVariant.outline,
                      size: NardButtonSize.m,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              NardButton(label: rematchLabel, onPressed: onRematch),
            ],
          ),
        ),
      ),
    );
  }
}
