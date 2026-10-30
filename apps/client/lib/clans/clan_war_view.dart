import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cosmetics/cosmetics_text.dart' show formatCountdown;
import '../game/online_overlays.dart' show PeriodicBuilder;
import '../l10n/gen/app_localizations.dart';
import '../social/social_gate.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import '../ui/social.dart';
import 'clan_models.dart';
import 'clan_providers.dart';
import 'emblem_catalog.dart';

/// 5.6 Clan war: status, scoreboard, split bar and the counted matches
/// (the API scores online wins between the two clans; there are no
/// pre-assigned pairings, ADR-036).
class ClanWarView extends ConsumerWidget {
  const ClanWarView({super.key, required this.clanId});

  final String clanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return RefreshIndicator(
      color: context.nard.accent,
      onRefresh: () async => ref.invalidate(clanWarProvider(clanId)),
      child: AsyncBody<ClanWar?>(
        value: ref.watch(clanWarProvider(clanId)),
        onRetry: () => ref.invalidate(clanWarProvider(clanId)),
        data:
            (war) =>
                war == null
                    ? ListView(
                      children: [
                        const SizedBox(height: 32),
                        MessageState(
                          title: l.warNoneTitle,
                          body: l.warNoneBody,
                        ),
                      ],
                    )
                    : _War(war: war),
      ),
    );
  }
}

class _War extends StatelessWidget {
  const _War({required this.war});

  final ClanWar war;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final mineColor = EmblemCatalog.colorOf(war.clan.emblem.color).$1;
    final opp = war.opponent;
    final theirsColor =
        opp == null
            ? c.text.withValues(alpha: .2)
            : EmblemCatalog.colorOf(opp.emblem.color).$1;
    final total = (war.maxMatches * war.pointsPerWin).clamp(1, 1 << 20);
    final status =
        war.live
            ? PeriodicBuilder(
              period: const Duration(seconds: 1),
              builder: (_) {
                final end = war.endsAt;
                final left =
                    end == null
                        ? Duration.zero
                        : end.difference(DateTime.now());
                return LivePill(
                  label: l.warLive(formatCountdown(left)),
                  compact: true,
                );
              },
            )
            : Text(
              switch (war.result) {
                'won' => l.warWon,
                'lost' => l.warLost,
                _ => l.warDraw,
              },
              style: NardType.micro.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: .88,
                color: war.result == 'lost' ? c.dangerText : c.accentHi,
              ),
            );
    Widget side(ClanSummary? clan) => Expanded(
      child: Column(
        children: [
          if (clan != null)
            ClanEmblem(
              emblem: clan.emblem,
              width: 64,
              initials:
                  clan.emblem.symbol == 'initials'
                      ? clanInitials(clan.name)
                      : null,
            )
          else
            const SizedBox(height: 64),
          const SizedBox(height: 8),
          Text(
            clan?.name ?? l.warNoOpponent,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: NardType.bodyS.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: c.text,
            ),
          ),
        ],
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(gradient: c.clanWarBg(mineColor, theirsColor)),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 10),
          Center(child: status),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                side(war.clan),
                const SizedBox(width: 8),
                Column(
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '${war.mine}'),
                          TextSpan(
                            text: ' : ',
                            style: TextStyle(
                              color: c.text.withValues(alpha: .4),
                            ),
                          ),
                          TextSpan(text: '${war.theirs}'),
                        ],
                      ),
                      style: NardType.displayXl.copyWith(
                        fontSize: 44,
                        height: 48 / 44,
                        color: c.text,
                        fontFeatures: tabular,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.warCounted(war.matchesCounted, war.maxMatches),
                      style: NardType.micro.copyWith(
                        color: c.text.withValues(alpha: .6),
                        fontFeatures: tabular,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                side(opp),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 6,
                child: Row(
                  children: [
                    Expanded(
                      flex: war.mine.clamp(0, total),
                      child: ColoredBox(color: mineColor),
                    ),
                    Expanded(
                      flex: (total - war.mine - war.theirs).clamp(0, total),
                      child: ColoredBox(color: c.text.withValues(alpha: .12)),
                    ),
                    Expanded(
                      flex: war.theirs.clamp(0, total),
                      child: ColoredBox(color: theirsColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
            child: Overline(l.warMatches, color: c.text.withValues(alpha: .6)),
          ),
          if (war.matches.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l.warMatchesEmpty,
                style: NardType.bodyS.copyWith(color: c.textDim),
              ),
            ),
          for (final m in war.matches) _MatchRow(match: m),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              l.warHowTo(war.pointsPerWin),
              textAlign: TextAlign.center,
              style: NardType.caption.copyWith(
                fontWeight: FontWeight.w400,
                color: c.text.withValues(alpha: .55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchRow extends StatelessWidget {
  const _MatchRow({required this.match});

  final WarMatch match;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final mine = match.won ? match.winner : match.loser;
    final theirs = match.won ? match.loser : match.winner;
    final (a, b) =
        match.won
            ? (match.score[0], match.score[1])
            : (match.score[1], match.score[0]);
    TextStyle name(bool winner) => NardType.bodyS.copyWith(
      fontWeight: winner ? FontWeight.w600 : FontWeight.w400,
      color: c.text,
    );
    return Container(
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: c.accent.withValues(alpha: .1)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              mine?.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: name(match.won),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.accent.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              l.warFinished(a, b),
              maxLines: 1,
              style: NardType.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: c.accentHi,
                fontFeatures: tabular,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              theirs?.name ?? '',
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: name(!match.won),
            ),
          ),
        ],
      ),
    );
  }
}
