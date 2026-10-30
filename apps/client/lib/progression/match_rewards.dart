import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../cosmetics/catalog.dart';
import '../cosmetics/cosmetics_text.dart';
import '../l10n/gen/app_localizations.dart';
import '../online/api_client.dart';
import '../store/store_models.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/commerce.dart';
import '../ui/controls.dart';
import '../ui/layout.dart';
import 'progress_models.dart';

/// Progress + wallet at one moment (before / after an online match).
class RewardSnapshot {
  const RewardSnapshot({required this.progress, required this.wallet});

  final Progress progress;
  final Wallet wallet;

  /// Both from the API; null when offline or signed out.
  static Future<RewardSnapshot?> capture(ApiClient api) async {
    try {
      final results = await Future.wait([api.progress(), api.inventory()]);
      return RewardSnapshot(
        progress: results[0] as Progress,
        wallet: (results[1] as Inventory).wallet,
      );
    } on Object {
      return null;
    }
  }
}

/// What a finished online match earned (2.6), derived by comparing the
/// server's progress before and after (the API is authoritative; the
/// match payload carries no rewards).
class MatchRewards {
  const MatchRewards({
    required this.coins,
    required this.xp,
    required this.levelFrom,
    required this.after,
    this.missions = const [],
  });

  final int coins;
  final int xp;
  final int levelFrom;
  final Progress after;

  /// Missions whose progress changed in this match (max 2).
  final List<Mission> missions;

  int get levelTo => after.level;
  bool get leveledUp => levelTo > levelFrom;
  bool get isEmpty => coins <= 0 && xp <= 0 && missions.isEmpty;

  static MatchRewards compare(RewardSnapshot before, RewardSnapshot after) {
    final b = before.progress;
    final a = after.progress;
    // XP within a level resets on level-up; one level step is exact,
    // further steps add their thresholds (approximated by xpForNext).
    var xp = a.xp - b.xp;
    if (a.level > b.level) {
      xp = (b.xpForNext - b.xp) + a.xp;
      for (var lvl = b.level + 1; lvl < a.level; lvl++) {
        xp += b.xpForNext;
      }
    }
    final old = {for (final m in b.missions) m.id: m.progress};
    final changed = [
      for (final m in a.missions)
        if (m.progress != (old[m.id] ?? 0)) m,
    ];
    return MatchRewards(
      coins: max(0, after.wallet.coins - before.wallet.coins),
      xp: max(0, xp),
      levelFrom: b.level,
      after: a,
      missions: changed.take(2).toList(),
    );
  }
}

/// 2.6 rewards row and mission progress of an online match.
class MatchRewardsView extends StatelessWidget {
  const MatchRewardsView({super.key, required this.rewards});

  final MatchRewards rewards;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: RewardTile(
                glyph: const CurrencyIcon(Currency.coins, size: 26),
                value: rewards.coins,
                label: l.matchCoins,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RewardTile(
                glyph: const XpBadge(),
                value: rewards.xp,
                label: l.matchXp,
              ),
            ),
          ],
        ),
        for (final m in rewards.missions) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        missionName(l, m),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NardType.bodyS.copyWith(color: c.text),
                      ),
                    ),
                    Text(
                      l.missionProgressCompact(
                        min(m.progress, m.target),
                        m.target,
                      ),
                      style: NardType.bodyS.copyWith(
                        color: m.completed ? c.successText : c.textDim,
                        fontWeight:
                            m.completed ? FontWeight.w600 : FontWeight.w400,
                        fontFeatures: tabular,
                      ),
                    ),
                    if (m.completed) ...[
                      const SizedBox(width: 4),
                      Icon(LucideIcons.check, size: 14, color: c.successText),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                NardProgressBar(
                  value: m.fraction,
                  fill: m.completed ? c.successText : c.accent,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
