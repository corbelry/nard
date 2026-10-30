import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../online/api_client.dart';
import '../online/reachability.dart';
import '../social/social_gate.dart';
import '../store/store_providers.dart' show showNote;
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import '../ui/social.dart';
import 'clan_home_screen.dart';
import 'clan_models.dart';
import 'clan_providers.dart';
import 'clan_text.dart';

/// Klan tab root: 5.4 clan home when in a clan, else 5.1 search.
class ClanTab extends ConsumerWidget {
  const ClanTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final offline = ref.watch(offlineProvider);
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OfflineBanner(text: l.offlineBanner, visible: offline),
          Expanded(
            child: SocialGate(
              builder: (context, account) {
                final clan = account.clan;
                if (clan != null) return ClanHome(clanId: clan.id);
                return const ClanSearch();
              },
            ),
          ),
        ],
      ),
    ).withBackground(c);
  }
}

extension on Widget {
  Widget withBackground(NardColors c) => DecoratedBox(
    decoration: BoxDecoration(gradient: c.bgGradient),
    child: this,
  );
}

/// 5.1 Clan search: name/tag search, language / open / min-rating
/// filters, my invites on top, join or apply from the row.
class ClanSearch extends ConsumerStatefulWidget {
  const ClanSearch({super.key});

  @override
  ConsumerState<ClanSearch> createState() => _ClanSearchState();
}

class _ClanSearchState extends ConsumerState<ClanSearch> {
  final _text = TextEditingController();
  Timer? _debounce;
  String _query = '';
  bool _languageOn = true;
  bool _openOnly = false;
  bool _ratingOn = false;

  /// clanId → requested (pending) after tapping "Müraciət".
  final _applied = <String>{};
  final _busy = <String>{};

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _changed(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _query = v.trim().length >= 2 ? v.trim() : '');
    });
  }

  int? _myRating(Account a) {
    final values = a.ratings.values.map((r) => r.rating);
    return values.isEmpty ? null : values.reduce((x, y) => x > y ? x : y);
  }

  Future<void> _join(ClanSummary clan) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy.add(clan.id));
    try {
      final joined = await ref.read(apiClientProvider).joinClan(clan.id);
      if (!mounted) return;
      if (joined) {
        await refreshMembership(ref);
      } else {
        setState(() => _applied.add(clan.id));
      }
    } on Object catch (e) {
      if (mounted) showNote(context, clanErrorText(l, e));
    } finally {
      if (mounted) setState(() => _busy.remove(clan.id));
    }
  }

  Future<void> _invite(ClanInvite invite, {required bool accept}) async {
    final l = AppLocalizations.of(context);
    final api = ref.read(apiClientProvider);
    try {
      if (accept) {
        await api.acceptClanInvite(invite.id);
        await refreshMembership(ref);
      } else {
        await api.declineClanInvite(invite.id);
      }
      ref.invalidate(clanInvitesProvider);
    } on Object catch (e) {
      if (mounted) showNote(context, clanErrorText(l, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final account = ref.watch(accountProvider).value;
    final lang = Localizations.localeOf(context).languageCode;
    final rating = account == null ? null : _myRating(account);
    final query = ClanQuery(
      text: _query,
      language: _languageOn ? lang : null,
      openOnly: _openOnly,
      maxMinRating: _ratingOn ? rating : null,
    );
    final invites = ref.watch(clanInvitesProvider).value ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 4, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l.clansTitle,
                  style: NardType.displayL.copyWith(
                    fontSize: 26,
                    color: c.text,
                  ),
                ),
              ),
              Pressable(
                onTap: () => context.push('/clans/create'),
                semanticLabel: l.createClanTitle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.plus, size: 14, color: c.accentHi),
                      const SizedBox(width: 4),
                      Text(
                        l.clanCreateShort,
                        style: NardType.labelM.copyWith(
                          fontSize: 14,
                          color: c.accentHi,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: NardSearchField(
            controller: _text,
            hint: l.clanSearchHint,
            height: 46,
            onChanged: _changed,
          ),
        ),
        SizedBox(
          height: 30 + 24,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              NardFilterChip(
                label: l.clanFilterLanguage(lang.toUpperCase()),
                selected: _languageOn,
                onTap: () => setState(() => _languageOn = !_languageOn),
              ),
              const SizedBox(width: 6),
              NardFilterChip(
                label: l.clanFilterOpen,
                selected: _openOnly,
                onTap: () => setState(() => _openOnly = !_openOnly),
              ),
              if (rating != null) ...[
                const SizedBox(width: 6),
                NardFilterChip(
                  label: l.clanFilterMinRating(rating),
                  selected: _ratingOn,
                  onTap: () => setState(() => _ratingOn = !_ratingOn),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: c.accent,
            onRefresh: () async {
              ref.invalidate(clanInvitesProvider);
              ref.invalidate(clanSearchProvider(query));
            },
            child: AsyncBody<List<ClanSummary>>(
              value: ref.watch(clanSearchProvider(query)),
              onRetry: () => ref.invalidate(clanSearchProvider(query)),
              data: (clans) {
                final rows = <Widget>[
                  if (invites.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: Overline(
                        l.clanInvitesTitle,
                        color: c.text.withValues(alpha: .55),
                      ),
                    ),
                  for (final i in invites)
                    _ClanRow(
                      clan: i.clan,
                      sub:
                          i.invitedBy == null
                              ? l.clanMeta(i.clan)
                              : l.clanInviteFrom(i.invitedBy!.name),
                      action: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SmallActionButton(
                            label: l.friendAccept,
                            height: 34,
                            onTap: () => _invite(i, accept: true),
                          ),
                          Pressable(
                            onTap: () => _invite(i, accept: false),
                            semanticLabel: l.friendDismiss,
                            child: Icon(
                              LucideIcons.x,
                              size: 18,
                              color: c.text.withValues(alpha: .6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  for (final clan in clans)
                    _ClanRow(
                      clan: clan,
                      sub: l.clanMeta(clan),
                      onTap: () => context.push('/clans/${clan.id}'),
                      action: _action(l, clan, rating),
                    ),
                ];
                if (clans.isEmpty && invites.isEmpty) {
                  return ListView(
                    children: [
                      const SizedBox(height: 40),
                      MessageState(
                        title: l.clanEmpty,
                        body: l.clanEmptyBody,
                        action: l.createClanTitle,
                        onAction: () => context.push('/clans/create'),
                      ),
                    ],
                  );
                }
                return ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: rows,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _action(AppLocalizations l, ClanSummary clan, int? rating) {
    final busy = _busy.contains(clan.id);
    if (clan.full) {
      return SmallActionButton(
        label: l.clanFull,
        height: 34,
        style: SmallButtonStyle.disabled,
        onTap: null,
      );
    }
    if (_applied.contains(clan.id)) {
      return SmallActionButton(
        label: l.clanPending,
        height: 34,
        style: SmallButtonStyle.outline,
        onTap: null,
      );
    }
    return switch (clan.joinPolicy) {
      JoinPolicy.open => SmallActionButton(
        label: l.clanJoin,
        height: 34,
        busy: busy,
        onTap: () => _join(clan),
      ),
      JoinPolicy.request => SmallActionButton(
        label: l.clanApply,
        height: 34,
        busy: busy,
        style: SmallButtonStyle.strong,
        onTap: () => _join(clan),
      ),
      JoinPolicy.invite => SmallActionButton(
        label: l.clanInviteOnlyShort,
        height: 34,
        style: SmallButtonStyle.disabled,
        onTap: null,
      ),
    };
  }
}

class _ClanRow extends StatelessWidget {
  const _ClanRow({
    required this.clan,
    required this.sub,
    required this.action,
    this.onTap,
  });

  final ClanSummary clan;
  final String sub;
  final Widget action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    return HairlineRow(
      onTap: onTap,
      semanticLabel: clan.name,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ClanEmblem(
            emblem: clan.emblem,
            width: 46,
            initials: clanInitials(clan.name),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        clan.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NardType.labelM.copyWith(color: c.text),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l.clanTag(clan.tag),
                      style: NardType.mono.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: c.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NardType.caption.copyWith(
                    fontWeight: FontWeight.w400,
                    color: c.text.withValues(alpha: .6),
                    fontFeatures: tabular,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          action,
        ],
      ),
    );
  }
}

/// Opens a clan (5.2) — shared by leaderboard rows.
void openClan(BuildContext context, String id) =>
    unawaited(context.push('/clans/$id'));
