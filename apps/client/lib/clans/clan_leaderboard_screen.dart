import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../cosmetics/cosmetics_text.dart' show formatAmount;
import '../l10n/gen/app_localizations.dart';
import '../online/rank.dart';
import '../social/social_gate.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import '../ui/social.dart';
import 'clan_models.dart';
import 'clan_providers.dart';

/// 5.7 Clan ranking by clan XP (no seasons in the API yet): podium for
/// the top three, rows from 4, my clan highlighted and pinned when off
/// the list.
class ClanLeaderboardScreen extends ConsumerWidget {
  const ClanLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: c.clanLeaderboardBg),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ScreenHeader(title: '', bare: true),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Text(
                  l.clanLeaderboardTitle,
                  style: NardType.title.copyWith(fontSize: 22, color: c.text),
                ),
              ),
              Expanded(
                child: AsyncBody<ClanLeaderboard>(
                  value: ref.watch(clanLeaderboardProvider),
                  onRetry: () => ref.invalidate(clanLeaderboardProvider),
                  data: (board) => _body(context, l, board),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l, ClanLeaderboard b) {
    final c = context.nard;
    final mine = b.myClan?.id;
    final top = b.entries.take(3).toList();
    final rest = b.entries.skip(3).toList();
    final listed = b.entries.any((e) => e.clan.id == mine);
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              if (top.isNotEmpty) _Podium(entries: top),
              for (final e in rest) _Row(entry: e, mine: e.clan.id == mine),
            ],
          ),
        ),
        if (mine != null && !listed && b.myRank != null)
          Container(
            color: c.accent.withValues(alpha: .14),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l.clanMyRank(b.myRank!),
                    style: NardType.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.text,
                    ),
                  ),
                ),
                Text(
                  formatAmount(b.myPoints ?? 0),
                  style: NardType.bodyS.copyWith(
                    color: c.text,
                    fontFeatures: tabular,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.entries});

  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    // Order 2 · 1 · 3.
    final order = [
      if (entries.length > 1) entries[1],
      entries[0],
      if (entries.length > 2) entries[2],
    ];
    Widget column(LeaderboardEntry e) {
      final (height, tier) = switch (e.rank) {
        1 => (96.0, Tier.gold),
        2 => (70.0, Tier.silver),
        _ => (52.0, Tier.bronze),
      };
      final (light, dark) = c.tierStops(tier);
      return SizedBox(
        width: 106,
        child: GestureDetector(
          onTap: () => context.push('/clans/${e.clan.id}'),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ClanEmblem(
                emblem: e.clan.emblem,
                width: 48,
                initials: clanInitials(e.clan.name),
              ),
              const SizedBox(height: 8),
              Text(
                e.clan.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: NardType.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 15 / 12,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [light, dark],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${e.rank}',
                      style: NardType.title.copyWith(
                        fontSize: 22,
                        color: c.onAccent,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatAmount(e.points),
                      style: NardType.micro.copyWith(
                        fontWeight: FontWeight.w600,
                        color: c.onAccent,
                        fontFeatures: tabular,
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

    return SizedBox(
      height: 234,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < order.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Flexible(child: column(order[i])),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.entry, required this.mine});

  final LeaderboardEntry entry;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: mine ? c.accent.withValues(alpha: .14) : null,
        border: Border(
          bottom: BorderSide(color: c.accent.withValues(alpha: .08)),
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.push('/clans/${entry.clan.id}'),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: Text(
                '${entry.rank}',
                style: NardType.bodyS.copyWith(
                  fontWeight: FontWeight.w600,
                  color: c.text.withValues(alpha: .6),
                  fontFeatures: tabular,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ClanEmblem(
              emblem: entry.clan.emblem,
              width: 30,
              flat: true,
              symbol: false,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.clan.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: NardType.body.copyWith(
                  fontSize: 14,
                  fontWeight: mine ? FontWeight.w600 : FontWeight.w500,
                  color: c.text,
                ),
              ),
            ),
            Text(
              formatAmount(entry.points),
              style: NardType.bodyS.copyWith(
                color: c.text,
                fontFeatures: tabular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
