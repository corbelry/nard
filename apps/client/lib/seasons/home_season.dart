import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/gen/app_localizations.dart';
import '../progression/home_progress.dart';
import '../progression/progress.dart';
import '../progression/progress_models.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/controls.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import 'season_providers.dart';

/// 2.1 season card: "SEZON 4 · 18 GÜN", pass level and bar → 7.1.
class HomeSeasonCard extends ConsumerWidget {
  const HomeSeasonCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = ref.watch(seasonProvider).value;
    if (v == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final days = Duration(seconds: v.season.secondsLeft).inDays;
    return Pressable(
      onTap: () => context.push('/season'),
      semanticLabel: l.seasonPassTitle,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.tile,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.tileRing),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Overline(l.homeSeason(v.season.number, days)),
            const SizedBox(height: 8),
            Text(
              l.homeSeasonLevel(v.level, v.levels),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: NardType.bodyS.copyWith(
                fontWeight: FontWeight.w500,
                height: 17 / 13,
                color: c.text,
              ),
            ),
            const SizedBox(height: 8),
            NardProgressBar(value: v.levels == 0 ? 0 : v.level / v.levels),
          ],
        ),
      ),
    );
  }
}

/// 2.1 prompt after a season ended: opens 7.2 once.
class HomeSeasonPrompt extends ConsumerWidget {
  const HomeSeasonPrompt({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.watch(seasonSummaryPromptProvider).value;
    if (n == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final c = context.nard;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Pressable(
        onTap: () => context.push('/season/summary'),
        semanticLabel: l.homeSeasonSummaryCta,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: c.surfaceRaised,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.accent.withValues(alpha: .35)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Overline(l.homeSeasonEnded(n), color: c.accentHi),
                    const SizedBox(height: 4),
                    Text(
                      l.homeSeasonSummaryCta,
                      style: NardType.labelM.copyWith(color: c.text),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 18, color: c.accentHi),
            ],
          ),
        ),
      ),
    );
  }
}

/// 2.1 bottom grid: daily mission card and season card side by side (the
/// mission card spans the row when there is no season, and vice versa).
class HomeProgressRow extends ConsumerWidget {
  const HomeProgressRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final season = ref.watch(seasonProvider).value;
    final missions =
        ref.watch(progressProvider).value?.of(MissionKind.daily).isNotEmpty ??
        false;
    if (season == null) return const HomeMissionCard();
    if (!missions) return const HomeSeasonCard();
    return const IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: HomeMissionCard()),
          SizedBox(width: 8),
          Expanded(child: HomeSeasonCard()),
        ],
      ),
    );
  }
}
