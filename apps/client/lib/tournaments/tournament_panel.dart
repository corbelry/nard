import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nard_protocol/nard_protocol.dart'
    show TournamentReadyStatePayload;

import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/competition.dart';
import '../ui/social.dart';
import 'bracket_layout.dart';
import 'tournament_models.dart';
import 'tournament_providers.dart';
import 'tournament_text.dart';

/// Whether [r] shows me present and my opponent absent before the
/// no-show deadline (21.2).
bool opponentMissing(TournamentReadyStatePayload r) {
  final mine = r.ready[r.you] ?? false;
  final theirs = r.ready[r.you.opponent] ?? false;
  return mine && !theirs && r.deadline > DateTime.now().millisecondsSinceEpoch;
}

/// Bottom panel of 4.3 / 4.4: my next match with "Hazıram", eliminated or
/// final place. Opens 21.2 when the round opens without my opponent.
class TournamentPanel extends ConsumerStatefulWidget {
  const TournamentPanel({super.key, required this.detail});

  final TournamentDetail detail;

  @override
  ConsumerState<TournamentPanel> createState() => _TournamentPanelState();
}

class _TournamentPanelState extends ConsumerState<TournamentPanel> {
  final _shown = <String>{};

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final d = widget.detail;
    final t = d.tournament;
    final locale = Localizations.localeOf(context).languageCode;
    final live = ref.watch(tournamentSocketProvider);
    ref.listen<TournamentLive>(tournamentSocketProvider, (_, s) {
      final n = widget.detail.nextMatch;
      final r = n == null ? null : s.ready[n.matchId];
      if (r != null && opponentMissing(r) && _shown.add(r.matchId)) {
        unawaited(context.push('/tournament/noshow', extra: r));
      }
    });
    final bottom = MediaQuery.paddingOf(context).bottom;
    Widget shell(Widget child) => Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, max(20, bottom + 2)),
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        border: Border(top: BorderSide(color: c.accent.withValues(alpha: .2))),
      ),
      child: child,
    );
    final label = NardType.labelM.copyWith(color: c.text);
    if (t.status == TournamentStatus.finished) {
      final place = t.myPlace;
      if (place == null) return const SizedBox.shrink();
      return shell(
        Row(
          children: [
            Expanded(
              child: Text(
                l.tourFinishedPanel(ordinal(locale, place)),
                style: label,
              ),
            ),
            if (place == 1)
              SmallActionButton(
                label: l.championTitle,
                height: 44,
                onTap: () => context.push('/tournaments/${t.id}/champion'),
              ),
          ],
        ),
      );
    }
    if (t.myStatus == MyTournamentStatus.eliminated) {
      return shell(Text(l.tourEliminated(stageForCurrent(l, t)), style: label));
    }
    final next = d.nextMatch;
    if (next == null || !t.stillIn) return const SizedBox.shrink();
    final me = ref.watch(accountProvider).value?.name ?? '';
    final opponent = next.opponent?.name ?? l.tourOpponentTbd;
    final open = next.status == PairingStatus.ready;
    final sent = live.sent.contains(next.matchId);
    final stage =
        t.type == TournamentType.knockout
            ? stageLabel(
              l,
              knockoutStage(BracketLayout.of(d).rounds, next.round),
            )
            : l.tourNow(next.round);
    return shell(
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TournamentStatusLabel(
                  text: l.tourNextMatch(stage),
                  color: c.accentHi,
                ),
                const SizedBox(height: 3),
                Text(
                  l.replayPlayers(me, opponent),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: label,
                ),
                const SizedBox(height: 3),
                Text(
                  sent
                      ? l.tourWaitingOpponent
                      : open
                      ? l.tourNextMetaOpen(t.matchLength)
                      : l.tourNextMetaPending(t.matchLength),
                  style: NardType.caption.copyWith(
                    fontWeight: FontWeight.w400,
                    color: c.text.withValues(alpha: .6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SmallActionButton(
            label: sent ? l.tourReadyDone : l.tourReady,
            height: 44,
            style: sent ? SmallButtonStyle.outline : SmallButtonStyle.solid,
            onTap:
                sent
                    ? null
                    : () => ref
                        .read(tournamentSocketProvider.notifier)
                        .ready(next.matchId),
          ),
        ],
      ),
    );
  }
}
