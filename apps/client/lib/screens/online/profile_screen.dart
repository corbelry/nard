import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nard_core/nard_core.dart';

import '../../app/setup_draft.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../online/account.dart';
import '../../online/api_client.dart';
import '../../online/match_history.dart';
import '../../online/online_text.dart';
import '../../online/rank.dart';
import '../../online/reachability.dart';
import '../../theme/nard_colors.dart';
import '../../theme/nard_tokens.dart';
import '../../ui/buttons.dart';
import '../../ui/controls.dart';
import '../../ui/extra_tokens.dart';
import '../../ui/identity.dart';
import '../../ui/layout.dart';
import 'account_sheets.dart';
import 'versus_screen.dart';

/// 8.1 Profile + statistics: the Profil tab root from Phase 3. Settings
/// stay reachable from the header (online.md §12.8).
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Variant? _variant;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final state = ref.watch(accountProvider);
    final account = state.value;
    final offline = ref.watch(offlineProvider);
    final variant = _variant ?? ref.watch(setupDraftProvider).variant;

    final settingsButton = NardIconButton(
      icon: LucideIcons.settings,
      semanticLabel: l.settingsTitle,
      size: 40,
      onPressed: () => context.push('/settings'),
    );

    Widget body;
    if (account != null) {
      body = _profile(context, l, account, variant, settingsButton);
    } else {
      Widget message;
      if (state.isLoading) {
        message = Center(
          child: CircularProgressIndicator(color: c.accent, strokeWidth: 2),
        );
      } else if (offline) {
        message = MessageState(
          title: l.onlineOfflineTitle,
          body: l.onlineOfflineBody,
          danger: true,
          action: l.retry,
          onAction: () => ref.invalidate(accountProvider),
        );
      } else if (state.hasError && state.error is ApiException) {
        message = MessageState(
          title: l.errorTitle,
          body: l.errorBody,
          danger: true,
          action: l.retry,
          onAction: () => ref.invalidate(accountProvider),
        );
      } else {
        message = MessageState(
          title: l.profileSignedOutTitle,
          body: l.profileSignedOutBody,
          action: l.authSignIn,
          onAction: () => context.push('/signin'),
        );
      }
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: RootTitle(l.tabProfile)),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: settingsButton,
              ),
            ],
          ),
          Expanded(child: message),
        ],
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(gradient: c.profileBg),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OfflineBanner(text: l.offlineBanner, visible: offline),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }

  Widget _profile(
    BuildContext context,
    AppLocalizations l,
    Account account,
    Variant variant,
    Widget settingsButton,
  ) {
    final c = context.nard;
    final info = ratingFor(account, variant);
    final rating = info?.rating;
    final history = ref.watch(matchHistoryProvider);
    final now = DateTime.now();

    Widget tile(String label, Widget value) => Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: c.tile,
        borderRadius: BorderRadius.circular(c.cardRadius),
        border: Border.all(color: c.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          value,
          const SizedBox(height: 2),
          Text(
            label,
            style: NardType.caption.copyWith(
              fontWeight: FontWeight.w400,
              color: c.text.withValues(alpha: .6),
            ),
          ),
        ],
      ),
    );
    final valueStyle = NardType.labelL.copyWith(
      fontSize: 22,
      height: 28 / 22,
      color: c.text,
      fontFeatures: tabular,
    );
    Text number(String text) => Text(text, style: valueStyle);
    final matches = info?.matches ?? 0;
    final wins = info?.wins ?? 0;

    final rows = <Widget>[];
    switch (history) {
      case AsyncData(:final value):
        final entries = value.where((e) => e.variant == variant).toList();
        if (entries.isEmpty) {
          rows.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: MessageState(
                title: l.historyEmptyTitle,
                body: l.historyEmptyBody,
              ),
            ),
          );
        } else {
          for (final e in entries) {
            rows.add(_HistoryRow(entry: e, now: now));
          }
        }
      case AsyncError():
        rows.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: MessageState(
              title: l.onlineOfflineTitle,
              body: l.onlineOfflineBody,
              danger: true,
              action: l.retry,
              onAction: () => ref.invalidate(matchHistoryProvider),
            ),
          ),
        );
      default:
        rows.add(
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(color: c.accent, strokeWidth: 2),
            ),
          ),
        );
    }

    return RefreshIndicator(
      color: c.accent,
      onRefresh: () async {
        ref.invalidate(matchHistoryProvider);
        await ref.read(accountProvider.notifier).refresh();
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Avatar(name: account.name, size: 72),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              account.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: NardType.title.copyWith(
                                fontSize: 22,
                                color: c.text,
                              ),
                            ),
                          ),
                          if (account.country != null) ...[
                            const SizedBox(width: 8),
                            FlagSwatch(country: account.country),
                          ],
                        ],
                      ),
                      if (rating != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          l.rankMeta(rating),
                          style: NardType.caption.copyWith(
                            fontWeight: FontWeight.w400,
                            color: c.textDim,
                            fontFeatures: tabular,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                NardIconButton(
                  icon: LucideIcons.pencil,
                  semanticLabel: l.profileEdit,
                  size: 40,
                  onPressed: () => showRenameSheet(context),
                ),
                const SizedBox(width: 8),
                settingsButton,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: NardSegmented<Variant>(
              compact: true,
              values: const [Variant.shortNard, Variant.longNard],
              labels: [l.variantShort, l.variantLong],
              selected: variant,
              onChanged: (v) => setState(() => _variant = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: tile(
                        l.statRating,
                        Row(
                          children: [
                            number(rating == null ? l.valueNone : '$rating'),
                            if (rating != null) ...[
                              const SizedBox(width: 8),
                              RankBadge(tier: tierNamed(info?.tier, rating)),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: tile(
                        l.statWinRate,
                        number(
                          matches == 0
                              ? l.valueNone
                              : l.statPercent((100 * wins / matches).round()),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: tile(l.statMatches, number('$matches'))),
                    const SizedBox(width: 8),
                    Expanded(child: tile(l.statWins, number('$wins'))),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Overline(l.profileHistory),
          ),
          ...rows,
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry, required this.now});

  final HistoryEntry entry;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final e = entry;
    final unrated = !e.ranked || e.opponentBot;
    final color = unrated ? c.accent : (e.won ? c.successText : c.dangerText);
    final delta = e.ratingDelta;
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: c.accent.withValues(alpha: .08)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.opponentBot ? botDisplayName(l) : e.opponentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NardType.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: c.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l.historyMeta(
                    l.variantAbbr(e.variant),
                    l.formatName(e.matchLength),
                    l.relativeDate(e.endedAt, now),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NardType.caption.copyWith(
                    fontWeight: FontWeight.w400,
                    color: c.text.withValues(alpha: .6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            l.historyScore(e.myScore, e.opponentScore),
            style: NardType.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: c.text,
              fontFeatures: tabular,
            ),
          ),
          SizedBox(
            width: 42,
            child: Text(
              delta == null || unrated ? l.valueNone : l.signedDelta(delta),
              textAlign: TextAlign.right,
              style: NardType.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: color,
                fontFeatures: tabular,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
