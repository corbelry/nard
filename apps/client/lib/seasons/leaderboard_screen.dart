import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nard_core/nard_core.dart' show Variant;

import '../cosmetics/cosmetics_text.dart' show formatAmount;
import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../social/social_gate.dart' show AsyncBody;
import '../store/store_providers.dart' show AccountGate;
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/commerce.dart';
import '../ui/competition.dart';
import '../ui/extra_tokens.dart';
import '../ui/identity.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import '../ui/social.dart';
import 'season_models.dart';
import 'season_providers.dart';

/// 6.5 Leaderboard: season picker, scope tabs, variant switch, podium,
/// rows and my pinned row.
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  LeaderboardScope _scope = LeaderboardScope.global;
  Variant _variant = Variant.shortNard;
  int? _season;

  LbQuery get _query => LbQuery(_variant, _scope, season: _season);

  Future<void> _pickSeason() async {
    final l = AppLocalizations.of(context);
    final seasons = await ref
        .read(seasonsListProvider.future)
        .catchError((Object _) => <Season>[]);
    if (!mounted || seasons.isEmpty) return;
    final picked = await showNardSheet<Season>(
      context,
      builder:
          (ctx) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetTitle(l.lbSeasonPicker),
              const SizedBox(height: 8),
              for (final s in seasons)
                SheetActionRow(
                  label: l.seasonN(s.number),
                  icon:
                      (s.active ? _season == null : _season == s.number)
                          ? LucideIcons.check
                          : null,
                  onTap: () => Navigator.of(ctx).pop(s),
                ),
            ],
          ),
    );
    if (picked != null) {
      setState(() => _season = picked.active ? null : picked.number);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final current = ref.watch(seasonProvider).value?.season.number;
    return Scaffold(
      backgroundColor: c.bgDeep,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: c.leaderboardBg),
        child: SafeArea(
          bottom: false,
          child: AccountGate(
            builder:
                (_) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const ScreenHeader(title: '', bare: true),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l.leaderboardTitle,
                              style: NardType.title.copyWith(
                                fontSize: 24,
                                color: c.text,
                              ),
                            ),
                          ),
                          Pressable(
                            onTap: _pickSeason,
                            semanticLabel: l.lbSeasonPicker,
                            child: Container(
                              height: 32,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: c.accent.withValues(alpha: .24),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l.seasonN(_season ?? current ?? 1),
                                    style: NardType.bodyS.copyWith(
                                      color: c.text,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    LucideIcons.chevronDown,
                                    size: 12,
                                    color: c.text,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    UnderlineTabs(
                      height: 38,
                      labels: [
                        l.lbScopeGlobal,
                        l.lbScopeCountry,
                        l.lbScopeFriends,
                        l.lbScopeClan,
                      ],
                      index: _scope.index,
                      onChanged:
                          (i) => setState(
                            () => _scope = LeaderboardScope.values[i],
                          ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: PillSegmented<Variant>(
                          values: const [Variant.shortNard, Variant.longNard],
                          labels: [l.variantShortAbbr, l.variantLongAbbr],
                          selected: _variant,
                          onChanged: (v) => setState(() => _variant = v),
                        ),
                      ),
                    ),
                    Expanded(
                      child: AsyncBody<Leaderboard>(
                        value: ref.watch(leaderboardProvider(_query)),
                        onRetry:
                            () => ref.invalidate(leaderboardProvider(_query)),
                        data: (b) => LeaderboardBody(board: b, scope: _scope),
                      ),
                    ),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}

/// Podium, rows from 4 and my pinned row (public for render tests).
class LeaderboardBody extends ConsumerWidget {
  const LeaderboardBody({super.key, required this.board, required this.scope});

  final Leaderboard board;
  final LeaderboardScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final me = ref.watch(accountProvider).value;
    final top = board.entries.take(3).toList();
    final rest = board.entries.skip(3).toList();
    final myName = board.me?.name ?? me?.name ?? '';
    final pinned = PinnedMeRow(
      rank: board.myRank == null ? '—' : l.lbRank(board.myRank!),
      leading: FlagSwatch(country: board.me?.country ?? me?.country),
      name: l.memberMe(myName),
      value: board.myRating == null ? '—' : '${board.myRating}',
    );
    if (board.entries.isEmpty) {
      return Column(
        children: [
          Expanded(
            child: MessageState(
              title: l.lbEmptyTitle,
              body: switch (scope) {
                LeaderboardScope.friends => l.lbEmptyFriends,
                LeaderboardScope.clan => l.lbEmptyClan,
                LeaderboardScope.country => l.lbEmptyCountry,
                LeaderboardScope.global => l.lbUnranked(board.minMatches),
              },
            ),
          ),
          pinned,
        ],
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              PlayerPodium(
                entries: [
                  for (final e in top)
                    PodiumEntry(
                      place: e.rank,
                      name: e.user.name,
                      value: formatAmount(e.rating),
                      me: e.user.id == me?.id,
                    ),
                ],
              ),
              for (final e in rest)
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color:
                        e.user.id == me?.id
                            ? c.accent.withValues(alpha: .14)
                            : null,
                    border: Border(
                      bottom: BorderSide(
                        color: c.accent.withValues(alpha: .08),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${e.rank}',
                          style: NardType.bodyS.copyWith(
                            color: c.text.withValues(alpha: .6),
                            fontFeatures: tabular,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FlagSwatch(country: e.user.country),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          e.user.id == me?.id
                              ? l.memberMe(e.user.name)
                              : e.user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NardType.body.copyWith(
                            fontSize: 14,
                            color: c.text,
                          ),
                        ),
                      ),
                      Text(
                        '${e.rating}',
                        style: NardType.body.copyWith(
                          fontSize: 14,
                          color: c.text,
                          fontFeatures: tabular,
                        ),
                      ),
                    ],
                  ),
                ),
              if (board.myRank == null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Text(
                    l.lbUnranked(board.minMatches),
                    textAlign: TextAlign.center,
                    style: NardType.caption.copyWith(
                      fontWeight: FontWeight.w400,
                      color: c.text.withValues(alpha: .6),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        pinned,
      ],
    );
  }
}
