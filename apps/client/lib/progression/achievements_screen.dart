import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cosmetics/catalog.dart';
import '../cosmetics/cosmetics_providers.dart';
import '../cosmetics/cosmetics_text.dart';
import '../l10n/gen/app_localizations.dart';
import '../online/api_client.dart';
import '../online/rank.dart';
import '../store/inventory.dart';
import '../store/store_providers.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/commerce.dart';
import '../ui/controls.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import 'progress.dart';

/// 8.2 Achievements + titles, pushed from the Profil tab.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final progress = ref.watch(progressProvider).value;
    final done =
        progress?.achievements.where(achievementIds.contains).length ?? 0;
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader(
            title: l.achievementsTitle,
            bare: true,
            trailing:
                progress == null
                    ? null
                    : Text(
                      l.achievementsCount(done, achievementIds.length),
                      style: NardType.bodyS.copyWith(
                        color: c.text.withValues(alpha: .6),
                        fontFeatures: tabular,
                      ),
                    ),
          ),
          Expanded(child: AccountGate(builder: (_) => const _Achievements())),
        ],
      ),
    );
  }
}

/// Hex fill per achievement (the design's colours carry no meaning yet).
Gradient _fill(NardColors c, String id) => switch (id) {
  'first_win' => c.tierFill(Tier.bronze),
  'wins_10' => c.tierFill(Tier.silver),
  'wins_100' => c.tierFill(Tier.gold),
  'games_1000' => c.tierFill(Tier.platinum),
  'mars_10' => c.tierFill(Tier.master),
  'ranked_wins_25' => c.tierFill(Tier.diamond),
  _ => c.garnetHexFill,
};

class _Achievements extends ConsumerWidget {
  const _Achievements();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final state = ref.watch(progressProvider);
    final progress = state.value;
    if (progress == null) {
      if (state.hasError) {
        return OfflineMessage(onRetry: () => ref.invalidate(progressProvider));
      }
      return Center(
        child: CircularProgressIndicator(color: c.accent, strokeWidth: 2),
      );
    }
    final unlocked = progress.achievements.toSet();
    final ids = [
      ...achievementIds,
      for (final id in progress.achievements)
        if (!achievementIds.contains(id)) id,
    ];
    final catalog = ref.watch(currentCatalogProvider);
    final owned = ref.watch(inventoryProvider).value?.owned ?? const {};
    final titles = catalog.inCategory(ItemCategory.title);
    final locale = Localizations.localeOf(context).languageCode;

    Future<void> pick(String? id) async {
      if (id == progress.title) return;
      try {
        await ref.read(progressProvider.notifier).setTitle(id);
      } on ApiException catch (e) {
        if (context.mounted) {
          showNote(context, e.offline ? l.onlineOfflineTitle : l.errorTitle);
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: .86,
            children: [
              for (final id in ids)
                _AchievementTile(
                  name: achievementName(l, id),
                  fill: _fill(c, id),
                  unlocked: unlocked.contains(id),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: Overline(l.titlesOverline),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TitleChip(
                label: l.titlesNone,
                selected: progress.title == null,
                onTap: () => pick(null),
              ),
              for (final t in titles)
                _TitleChip(
                  label: t.nameFor(locale),
                  selected: progress.title == t.id,
                  locked: !owned.contains(t.id),
                  onTap:
                      owned.contains(t.id)
                          ? () => pick(t.id)
                          : () => showNote(context, l.titlesLocked),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.name,
    required this.fill,
    required this.unlocked,
  });

  final String name;
  final Gradient fill;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Opacity(
      opacity: unlocked ? 1 : .45,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: c.text.withValues(alpha: .04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.lineSoft),
        ),
        child: Column(
          children: [
            ClipPath(
              clipper: const HexClipper(),
              child: Container(
                width: 48,
                height: 54,
                decoration: BoxDecoration(
                  gradient: unlocked ? fill : null,
                  color: unlocked ? null : c.text.withValues(alpha: .2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: NardType.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 15 / 12,
                  color: c.text,
                ),
              ),
            ),
            NardProgressBar(
              value: unlocked ? 1 : 0,
              height: 3,
              track: c.text.withValues(alpha: .1),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleChip extends StatelessWidget {
  const _TitleChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.locked = false,
  });

  final String label;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      minSize: 0,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? c.accent.withValues(alpha: .18) : null,
          borderRadius: BorderRadius.circular(NardRadius.pill),
          border: Border.all(
            color: selected ? c.accent : c.line,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: NardType.title.copyWith(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                color:
                    selected
                        ? c.accentHi
                        : locked
                        ? c.text.withValues(alpha: .4)
                        : c.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
