import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nard_core/nard_core.dart' show Variant;

import '../cosmetics/catalog.dart' show Currency;
import '../cosmetics/cosmetics_text.dart' show formatAmount;
import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../online/api_client.dart' show ApiException;
import '../online/reachability.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/commerce.dart';
import '../ui/competition.dart';
import '../ui/controls.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import '../ui/social.dart';
import 'private_tournament_screen.dart' show showPrivateChooser;
import 'tournament_models.dart';
import 'tournament_providers.dart';
import 'tournament_text.dart';

/// Where a tournament card leads: registration → 4.2 (private → 22.2,
/// sit-and-go → 21.1); running / finished → 4.3 (knockout) or 4.4.
String tournamentRoute(Tournament t) {
  if (t.registering) {
    if (t.kind == TournamentKind.private) return '/tournaments/${t.id}/invite';
    if (t.kind == TournamentKind.sitAndGo && t.joined) {
      return '/sng?size=${t.size}';
    }
    return '/tournaments/${t.id}';
  }
  if (t.status == TournamentStatus.cancelled) return '/tournaments/${t.id}';
  return t.type == TournamentType.knockout
      ? '/tournaments/${t.id}/bracket'
      : '/tournaments/${t.id}/standings';
}

/// 4.1 Turnirlər tab root: live / upcoming / mine / finished with filters
/// and the 11.x states.
class TournamentsTab extends ConsumerStatefulWidget {
  const TournamentsTab({super.key});

  @override
  ConsumerState<TournamentsTab> createState() => _TournamentsTabState();
}

class _TournamentsTabState extends ConsumerState<TournamentsTab> {
  TournamentTab _tab = TournamentTab.live;
  Variant? _variant;
  bool _free = false;

  TourQuery get _query => TourQuery(_tab, variant: _variant, free: _free);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final offline = ref.watch(offlineProvider);
    final account = ref.watch(accountProvider);
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          OfflineBanner(text: l.offlineBanner, visible: offline),
          Row(
            children: [
              Expanded(child: RootTitle(l.tournamentsTitle)),
              _HeaderIcon(
                icon: LucideIcons.barChart2,
                label: l.leaderboardTitle,
                onTap: () => context.push('/leaderboard'),
              ),
              _HeaderIcon(
                icon: LucideIcons.plus,
                label: l.privateTourTitle,
                onTap:
                    account.value == null
                        ? () => context.push('/signin')
                        : () => showPrivateChooser(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          UnderlineTabs(
            labels: [
              l.tourTabLive,
              l.tourTabUpcoming,
              l.tourTabMine,
              l.tourTabFinished,
            ],
            index: _tab.index,
            onChanged: (i) => setState(() => _tab = TournamentTab.values[i]),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                NardFilterChip(
                  label: l.tourFilterAll,
                  selected: _variant == null && !_free,
                  onTap:
                      () => setState(() {
                        _variant = null;
                        _free = false;
                      }),
                ),
                const SizedBox(width: 6),
                NardFilterChip(
                  label: l.variantShortAbbr,
                  selected: _variant == Variant.shortNard,
                  onTap:
                      () => setState(
                        () =>
                            _variant =
                                _variant == Variant.shortNard
                                    ? null
                                    : Variant.shortNard,
                      ),
                ),
                const SizedBox(width: 6),
                NardFilterChip(
                  label: l.variantLongAbbr,
                  selected: _variant == Variant.longNard,
                  onTap:
                      () => setState(
                        () =>
                            _variant =
                                _variant == Variant.longNard
                                    ? null
                                    : Variant.longNard,
                      ),
                ),
                const SizedBox(width: 6),
                NardFilterChip(
                  label: l.tourFilterFree,
                  selected: _free,
                  onTap: () => setState(() => _free = !_free),
                ),
              ],
            ),
          ),
          Expanded(child: _body(context, l, c, offline, account)),
        ],
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l,
    NardColors c,
    bool offline,
    AsyncValue<Object?> account,
  ) {
    if (offline) {
      return MessageState(
        title: l.tournamentsOfflineTitle,
        body: l.tournamentsOfflineBody,
        danger: true,
        action: l.playVsComputer,
        onAction: () => context.push('/setup'),
      );
    }
    if (account.isLoading && !account.hasValue) return _skeleton();
    if (account.value == null) {
      return MessageState(
        title: l.accountNeededTitle,
        body: l.socialAccountBody,
        action: l.authSignIn,
        onAction: () => context.push('/signin'),
      );
    }
    final list = ref.watch(tournamentListProvider(_query));
    if (list.hasError && !list.hasValue) {
      final e = list.error;
      if (e is ApiException && e.offline) {
        return MessageState(
          title: l.tournamentsOfflineTitle,
          body: l.tournamentsOfflineBody,
          danger: true,
          action: l.retry,
          onAction: () => ref.invalidate(tournamentListProvider(_query)),
        );
      }
      return MessageState(
        title: l.listErrorTitle,
        body: l.listErrorBody,
        danger: true,
        action: l.retry,
        onAction: () => ref.invalidate(tournamentListProvider(_query)),
      );
    }
    if (!list.hasValue) return _skeleton();
    final items = list.requireValue;
    final showSng =
        (_tab == TournamentTab.live || _tab == TournamentTab.upcoming) &&
        _variant != Variant.longNard &&
        !_free;
    if (items.isEmpty && !showSng) {
      return _tab == TournamentTab.mine
          ? MessageState(
            title: l.tournamentsEmptyTitle,
            body: l.tournamentsEmptyBody,
            action: l.tournamentsEmptyCta,
            onAction: () => setState(() => _tab = TournamentTab.upcoming),
          )
          : MessageState(
            title: l.tournamentsNoneTitle,
            body: l.tournamentsNoneBody,
          );
    }
    return RefreshIndicator(
      color: c.accent,
      onRefresh: () => ref.refresh(tournamentListProvider(_query).future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          if (showSng) ...[const _SngCard(), const SizedBox(height: 10)],
          for (final t in items) ...[
            TournamentCard(
              tournament: t,
              onTap: () => context.push(tournamentRoute(t)),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _skeleton() => ListView(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
    physics: const NeverScrollableScrollPhysics(),
    children: [
      for (var i = 0; i < 4; i++) ...[
        const SkeletonCard(),
        const SizedBox(height: 10),
      ],
    ],
  );
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
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
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icon, size: 20, color: c.accentHi),
      ),
    );
  }
}

/// 4.1 TournamentCard.
class TournamentCard extends StatelessWidget {
  const TournamentCard({super.key, required this.tournament, this.onTap});

  final Tournament tournament;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final t = tournament;
    final locale = Localizations.localeOf(context).languageCode;
    final (status, color, dot) = statusLabel(l, c, t);
    final meta = NardType.caption.copyWith(
      fontWeight: FontWeight.w400,
      color: c.text.withValues(alpha: .7),
      fontFeatures: tabular,
    );
    return Pressable(
      onTap: onTap,
      semanticLabel: t.nameFor(locale),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.surfaceRaised,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.accent.withValues(alpha: .2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TournamentStatusLabel(
                    text: status,
                    color: color,
                    dot: dot,
                  ),
                ),
                Text(
                  timeSlot(l, t, DateTime.now(), locale),
                  style: NardType.caption.copyWith(
                    fontWeight: FontWeight.w400,
                    color: c.text.withValues(alpha: .64),
                    fontFeatures: tabular,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              t.nameFor(locale),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: NardType.title.copyWith(fontSize: 18, color: c.text),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Flexible(
                  child: Text(
                    tournamentMeta(l, t),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: meta,
                  ),
                ),
                const SizedBox(width: 14),
                const CurrencyIcon(Currency.coins, size: 12),
                const SizedBox(width: 4),
                Text(formatAmount(t.prizeFund), style: meta),
                const SizedBox(width: 14),
                Text(l.tourEntrants(t.entrants, t.size), style: meta),
                if (t.myStatus == MyTournamentStatus.registered) ...[
                  const Spacer(),
                  Text(
                    l.tourRegistered,
                    style: meta.copyWith(
                      color: c.successText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            NardProgressBar(
              value: t.size == 0 ? 0 : t.entrants / t.size,
              track: c.text.withValues(alpha: .1),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pinned sit-and-go entry (tournaments.md §1 proposal).
class _SngCard extends StatelessWidget {
  const _SngCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    return Pressable(
      onTap: () => context.push('/sng'),
      semanticLabel: l.tourTypeSngUpper,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.surfaceRaised,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.accent.withValues(alpha: .35)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TournamentStatusLabel(
                    text: l.tourTypeSngUpper,
                    color: c.accentHi,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.sngCardMeta,
                    style: NardType.title.copyWith(fontSize: 17, color: c.text),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '8 · 16 · 32',
                    style: NardType.caption.copyWith(
                      fontWeight: FontWeight.w400,
                      color: c.text.withValues(alpha: .7),
                      fontFeatures: tabular,
                    ),
                  ),
                ],
              ),
            ),
            SmallActionButton(
              label: l.sngJoin,
              height: 40,
              onTap: () => context.push('/sng'),
            ),
          ],
        ),
      ),
    );
  }
}
