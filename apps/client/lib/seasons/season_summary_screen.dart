import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/providers.dart';
import '../cosmetics/cosmetics_providers.dart';
import '../l10n/gen/app_localizations.dart';
import '../online/online_text.dart';
import '../online/rank.dart';
import '../social/social_gate.dart' show AsyncBody;
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/buttons.dart';
import '../ui/competition.dart';
import '../ui/extra_tokens.dart';
import '../ui/identity.dart';
import '../ui/layout.dart';
import 'season_models.dart';
import 'season_pass_screen.dart' show endRewardText;
import 'season_providers.dart';

/// 7.2 Season summary of the latest finished season (or [number]): tier,
/// stats and the season-end reward (granted at the roll, ADR-039; the
/// button only acknowledges).
class SeasonSummaryScreen extends ConsumerWidget {
  const SeasonSummaryScreen({super.key, this.number});

  final int? number;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final summary = ref.watch(seasonSummaryProvider(number));
    if (summary.value == null) {
      return Scaffold(
        backgroundColor: c.bgDeep,
        body: SafeArea(
          child: Column(
            children: [
              const ScreenHeader(title: '', bare: true),
              Expanded(
                child: AsyncBody<SeasonSummary?>(
                  value: summary,
                  onRetry: () => ref.invalidate(seasonSummaryProvider(number)),
                  data:
                      (_) => MessageState(
                        title: l.seasonNoSummaryTitle,
                        body: l.seasonNoSummaryBody,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SeasonSummaryView(summary: summary.requireValue!);
  }
}

class SeasonSummaryView extends ConsumerWidget {
  const SeasonSummaryView({super.key, required this.summary});

  final SeasonSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final locale = Localizations.localeOf(context).languageCode;
    final main = summary.main;
    final tier = tierNamed(main?.tier, main?.rating ?? 1500);
    final sub = subLevel(main?.rating ?? 1500);
    final (_, dark) = c.tierStops(tier);
    final catalog = ref.watch(currentCatalogProvider);
    final rewardTier = summary.rewardTier;
    final reward =
        rewardTier == null
            ? null
            : endRewardText(
              l,
              EndReward(
                tier: rewardTier,
                minRating: 0,
                coins: summary.rewardCoins,
                itemId: summary.rewardItem,
              ),
              catalog,
              locale,
            );
    final newRating = main?.rating;
    final stats = <(String, String)>[
      if (main != null) ...[
        ('${main.matches}', l.seasonStatGames),
        (l.statPercent(main.winRate), l.seasonStatWinRate),
        if (main.rank != null) (l.lbRank(main.rank!), l.seasonStatRank),
        if (main.countryRank != null)
          (l.lbRank(main.countryRank!), l.seasonStatCountryRank),
        ('${main.rating}', l.seasonStatRating),
        (l.signedDelta(main.ratingDelta), l.seasonStatRatingGain),
      ],
    ];

    void done() {
      markSummarySeen(ref.read(databaseProvider), summary.season.number);
      ref.invalidate(seasonSummaryPromptProvider);
      context.canPop() ? context.pop() : context.go('/home');
    }

    return CelebrationLayout(
      background: c.seasonSummaryBg(dark),
      gap: 18,
      padding: 16,
      content: [
        Overline(
          l.seasonEnded(summary.season.number),
          color: c.text.withValues(alpha: .64),
          spacing: .96,
        ),
        RankBadge(tier: tier, sub: sub, size: 110),
        Text(
          l.rankName(tier, sub),
          style: NardType.displayL.copyWith(fontSize: 30, color: c.text),
        ),
        LayoutBuilder(
          builder: (context, box) {
            final w = (box.maxWidth - 8) / 2;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (value, label) in stats)
                  Container(
                    width: w,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: c.text.withValues(alpha: .05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: c.accent.withValues(alpha: .16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: NardType.clock.copyWith(
                            fontSize: 22,
                            height: 1.1,
                            color: c.text,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          label,
                          style: NardType.caption.copyWith(
                            fontWeight: FontWeight.w400,
                            color: c.text.withValues(alpha: .6),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
        if (reward != null)
          RewardPill(
            label: l.seasonRewardLine(reward),
            fill: c.accent.withValues(alpha: .18),
            color: c.text,
            coin: true,
          ),
        if (newRating != null)
          Text(
            l.seasonSoftReset(summary.ratings[main!.variant.name] ?? newRating),
            textAlign: TextAlign.center,
            style: NardType.bodyS.copyWith(color: c.text.withValues(alpha: .7)),
          ),
      ],
      footer: [NardButton(label: l.seasonClaimRewards, onPressed: done)],
    );
  }
}
