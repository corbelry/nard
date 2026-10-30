import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../cosmetics/catalog.dart';
import '../cosmetics/cosmetics_text.dart';
import '../l10n/gen/app_localizations.dart';
import '../store/inventory.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/commerce.dart';
import '../ui/controls.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import 'progress.dart';
import 'progress_models.dart';

/// 2.1 level line under the name: "Səv. 24" + XP bar.
class HomeLevelLine extends ConsumerWidget {
  const HomeLevelLine({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider).value;
    if (progress == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final c = context.nard;
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Text(
            l.homeLevel(progress.level),
            style: NardType.micro.copyWith(
              fontWeight: FontWeight.w400,
              color: c.textDim,
              fontFeatures: tabular,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: NardProgressBar(value: progress.levelFraction)),
        ],
      ),
    );
  }
}

/// 2.1 currency pills: coins → missions (earn-only), Yaqut → store.
class HomeCurrencyRow extends ConsumerWidget {
  const HomeCurrencyRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(inventoryProvider).value?.wallet;
    if (wallet == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          CurrencyPill(
            currency: Currency.coins,
            amount: wallet.coins,
            onTap: () => context.push('/home/missions'),
          ),
          const SizedBox(width: 8),
          CurrencyPill(
            currency: Currency.gems,
            amount: wallet.gems,
            onTap: () => context.go('/store'),
          ),
        ],
      ),
    );
  }
}

/// 2.1 daily mission card: missions done today and the next one to do.
class HomeMissionCard extends ConsumerWidget {
  const HomeMissionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider).value;
    if (progress == null) return const SizedBox.shrink();
    final daily = progress.of(MissionKind.daily);
    if (daily.isEmpty) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final done = daily.where((m) => m.completed).length;
    final next = daily.where((m) => !m.completed).firstOrNull;
    return Pressable(
      onTap: () => context.push('/home/missions'),
      semanticLabel: l.missionsTitle,
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
            Overline(l.homeDailyMission(done, daily.length)),
            const SizedBox(height: 8),
            Text(
              next == null ? l.homeMissionsDone : missionName(l, next),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: NardType.bodyS.copyWith(
                fontWeight: FontWeight.w500,
                height: 17 / 13,
                color: c.text,
              ),
            ),
            const SizedBox(height: 8),
            NardProgressBar(
              value: next == null ? 1 : next.fraction,
              fill: c.successText,
            ),
            if (next != null) ...[
              const SizedBox(height: 6),
              Text(
                l.missionProgressCompact(
                  min(next.progress, next.target),
                  next.target,
                ),
                style: NardType.micro.copyWith(
                  color: c.textDim,
                  fontFeatures: tabular,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Title item name under the player's name (8.1, Noto italic).
class TitleLine extends ConsumerWidget {
  const TitleLine({super.key, required this.name});

  final String? name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = name;
    if (text == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Text(
        text,
        style: NardType.title.copyWith(
          fontSize: 13,
          height: 16 / 13,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
          color: context.nard.accentHi,
        ),
      ),
    );
  }
}
