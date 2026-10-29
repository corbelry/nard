import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nard_core/nard_core.dart';

import '../app/setup_draft.dart';
import '../game/game_controller.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/background.dart';
import '../ui/buttons.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import 'ai_level_screen.dart';

/// 2.1 Home, offline parts: hero card with the quick game and mode tiles.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final setup = ref.watch(setupDraftProvider);
    final variantUpper =
        setup.variant == Variant.shortNard
            ? l.variantShortUpper
            : l.variantLongUpper;
    final format =
        setup.matchLength <= 1
            ? l.oneGameUpper
            : l.matchToPointsUpper(setup.matchLength);
    final other =
        setup.variant == Variant.shortNard ? l.variantLong : l.variantShort;

    void play() {
      ref.read(setupDraftProvider.notifier).remember(setup);
      ref.read(gameControllerProvider.notifier).start(setup);
      context.push('/game');
    }

    void toggleVariant() {
      final draft = ref.read(setupDraftProvider.notifier);
      draft.edit(
        (s) => s.copyWith(
          variant:
              s.variant == Variant.shortNard
                  ? Variant.longNard
                  : Variant.shortNard,
        ),
      );
      draft.remember(ref.read(setupDraftProvider));
    }

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Nard',
                  style: NardType.displayL.copyWith(color: c.text),
                ),
                TextSpan(
                  text: 'Arena',
                  style: NardType.displayL.copyWith(
                    color: c.accent,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: c.surfaceRaised,
              borderRadius: BorderRadius.circular(NardRadius.xl),
              border: Border.all(color: c.accent.withValues(alpha: .35)),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    c.accent.withValues(alpha: .22),
                    c.accent.withValues(alpha: .04),
                  ],
                  stops: const [0, .6],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -30,
                    top: -30,
                    width: 160,
                    height: 160,
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback:
                          (r) => const RadialGradient(
                            colors: [Colors.white, Colors.transparent],
                            stops: [0, .7],
                          ).createShader(r),
                      child: CustomPaint(
                        painter: LatticePainter(
                          color: c.accent.withValues(alpha: .12),
                          spacing: 16,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Overline(l.homeHeroMeta(variantUpper, format)),
                        const SizedBox(height: 6),
                        Text(
                          l.homeHeroMode(aiLevelName(l, setup.level)),
                          style: NardType.labelM.copyWith(
                            color: c.text.withValues(alpha: .85),
                          ),
                        ),
                        const SizedBox(height: 16),
                        NardButton(
                          label: l.homePlay,
                          size: NardButtonSize.hero,
                          onPressed: play,
                        ),
                        const SizedBox(height: 4),
                        Pressable(
                          onTap: toggleVariant,
                          child: Row(
                            children: [
                              Text(
                                l.homeChangeMode,
                                style: NardType.caption.copyWith(
                                  color: c.textDim,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                l.homeOtherVariant(other),
                                style: NardType.caption.copyWith(
                                  color: c.accentHi,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: max(
              .6,
              (MediaQuery.sizeOf(context).width - 56) / 4 / 74,
            ),
            children: [
              _ModeTile(
                icon: LucideIcons.monitor,
                label: l.modeComputer,
                onTap: () => context.push('/setup'),
              ),
              _ModeTile(
                icon: LucideIcons.smartphone,
                label: l.modeSameDevice,
                onTap: () => context.push('/hotseat'),
              ),
              _ModeTile(
                icon: LucideIcons.graduationCap,
                label: l.modeLesson,
                onTap: () => context.push('/lesson'),
              ),
              _ModeTile(
                icon: LucideIcons.history,
                label: l.modeReplays,
                onTap: () => context.push('/replays'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: c.tile,
          borderRadius: BorderRadius.circular(c.cardRadius),
          border: Border.all(color: c.tileRing),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: c.accent),
            const SizedBox(height: 7),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: NardType.micro.copyWith(color: c.text),
            ),
          ],
        ),
      ),
    );
  }
}
