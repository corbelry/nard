import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../cosmetics/cosmetics_text.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/background.dart';
import '../ui/buttons.dart';
import '../ui/commerce.dart';
import '../ui/controls.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';

/// Arguments of 12.3.
class LevelUpArgs {
  const LevelUpArgs({
    required this.from,
    required this.to,
    required this.xp,
    required this.xpForNext,
  });

  final int from;
  final int to;
  final int xp;
  final int xpForNext;
}

/// 12.3 Level up (full screen), shown after 2.6 when the level rose. The
/// API grants coins on level-up but does not report them separately, so
/// the reward tiles of the mock are omitted.
class LevelUpScreen extends StatelessWidget {
  const LevelUpScreen({super.key, required this.args});

  final LevelUpArgs args;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final fraction =
        args.xpForNext <= 0
            ? 0.0
            : (args.xp / args.xpForNext).clamp(0.0, 1.0).toDouble();
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: c.levelUpBg),
        child: Stack(
          children: [
            Positioned.fill(
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback:
                    (r) => const RadialGradient(
                      center: Alignment(0, -.28),
                      radius: .8,
                      colors: [Colors.white, Colors.transparent],
                      stops: [0, .55],
                    ).createShader(r),
                child: CustomPaint(
                  painter: LatticePainter(color: c.levelUpLattice, spacing: 18),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: reduce ? 1 : .8, end: 1),
                              duration: NardMotion.sheetIn,
                              curve: Curves.easeOutBack,
                              builder:
                                  (_, s, child) =>
                                      Transform.scale(scale: s, child: child),
                              child: LevelBadge(level: args.to),
                            ),
                            const SizedBox(height: 22),
                            Overline(
                              l.levelUpOverline(args.from, args.to),
                              color: c.accent,
                              spacing: .96,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l.levelUpTitle,
                              textAlign: TextAlign.center,
                              style: NardType.displayL.copyWith(
                                fontSize: 32,
                                height: 38 / 32,
                                color: c.text,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: 220,
                              child: Column(
                                children: [
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(
                                      begin: reduce ? fraction : 0,
                                      end: fraction,
                                    ),
                                    duration: NardMotion.counter,
                                    curve: NardMotion.outExpo,
                                    builder:
                                        (_, v, _) => NardProgressBar(
                                          value: v,
                                          height: 6,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    l.xpProgress(
                                      formatAmount(args.xp),
                                      formatAmount(args.xpForNext),
                                    ),
                                    style: NardType.caption.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: c.text.withValues(alpha: .6),
                                      fontFeatures: tabular,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                    child: NardButton(
                      label: l.continueAction,
                      onPressed: () => context.pop(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
