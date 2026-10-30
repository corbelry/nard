import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../social/social_gate.dart' show AsyncBody;
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/competition.dart';
import '../ui/layout.dart';
import 'tournament_models.dart';
import 'tournament_panel.dart';
import 'tournament_providers.dart';

/// 4.4 Swiss / round-robin standings: points, then Buchholz (integer,
/// ADR-038), my row highlighted and pinned. The API serves the live table
/// only, so the round squares show progress.
class StandingsScreen extends ConsumerStatefulWidget {
  const StandingsScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends ConsumerState<StandingsScreen> {
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _poll = pollEvery(
      const Duration(seconds: 15),
      () => ref.invalidate(tournamentDetailProvider(widget.id)),
    );
    ref.read(tournamentSocketProvider.notifier).connect();
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: AsyncBody<TournamentDetail>(
          value: ref.watch(tournamentDetailProvider(widget.id)),
          onRetry: () => ref.invalidate(tournamentDetailProvider(widget.id)),
          data: (d) => StandingsView(detail: d),
        ),
      ),
    );
  }
}

/// The table for [detail] (public for render tests).
class StandingsView extends ConsumerWidget {
  const StandingsView({super.key, required this.detail});

  final TournamentDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final t = detail.tournament;
    final locale = Localizations.localeOf(context).languageCode;
    final me = ref.watch(accountProvider).value?.id;
    final rows = detail.standings ?? const [];
    final swiss = t.type == TournamentType.swiss;
    final rounds = max(
      t.totalRounds ?? detail.rounds.length,
      detail.rounds.length,
    );
    // Prize places count as the qualifying zone (no Swiss playoff yet).
    final zone = t.prizes.fold<int>(0, (m, p) => max(m, p.to));
    final mono = NardType.mono.copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: c.text.withValues(alpha: .5),
    );
    StandingRow? mine;
    for (final r in rows) {
      if (r.user.id == me) mine = r;
    }
    Widget grid(List<Widget> cells, {double? height, Color? fill}) => Container(
      height: height,
      color: fill,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: height == null ? 8 : 0,
      ),
      child: Row(
        children: [
          SizedBox(width: 28, child: cells[0]),
          const SizedBox(width: 6),
          Expanded(child: cells[1]),
          const SizedBox(width: 6),
          SizedBox(width: 44, child: cells[2]),
          if (swiss) ...[
            const SizedBox(width: 6),
            SizedBox(width: 44, child: cells[3]),
          ],
          const SizedBox(width: 6),
          SizedBox(width: 36, child: cells[4]),
        ],
      ),
    );
    final body = NardType.bodyS.copyWith(
      color: c.text.withValues(alpha: .7),
      fontFeatures: tabular,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ScreenHeader(title: '', bare: true),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.standingsTitle(t.nameFor(locale)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: NardType.title.copyWith(fontSize: 22, color: c.text),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    l.standingsRound,
                    style: NardType.caption.copyWith(
                      fontWeight: FontWeight.w400,
                      color: c.text.withValues(alpha: .6),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var r = 1; r <= rounds; r++) ...[
                            if (r > 1) const SizedBox(width: 6),
                            _RoundSquare(
                              n: r,
                              current: r == t.currentRound,
                              future: r > t.currentRound,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: c.accent.withValues(alpha: .16)),
            ),
          ),
          child: grid([
            Text(l.standingsColRank, style: mono),
            Text(l.standingsColPlayer, style: mono),
            Text(l.standingsColWinLoss, style: mono),
            Text(l.standingsColBuchholz, style: mono),
            Text(l.standingsColPoints, style: mono, textAlign: TextAlign.end),
          ]),
        ),
        Expanded(
          child:
              rows.isEmpty
                  ? MessageState(
                    title: l.tournamentsNoneTitle,
                    body: l.standingsEmpty,
                  )
                  : ListView(
                    children: [
                      for (final r in rows)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color:
                                r.user.id == me
                                    ? c.accent.withValues(alpha: .14)
                                    : null,
                            border: Border(
                              bottom: BorderSide(
                                color: c.accent.withValues(alpha: .08),
                              ),
                            ),
                          ),
                          child: grid(height: 46, [
                            Text(
                              '${r.rank}',
                              style: body.copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    r.rank <= zone
                                        ? c.accentHi
                                        : c.text.withValues(alpha: .5),
                              ),
                            ),
                            Text(
                              r.user.id == me
                                  ? l.memberMe(r.user.name)
                                  : r.user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: body.copyWith(
                                color: c.text,
                                fontWeight:
                                    r.user.id == me
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                              ),
                            ),
                            Text(
                              l.standingsWinLoss(r.wins, r.losses),
                              style: body,
                            ),
                            Text('${r.buchholz}', style: body),
                            Text(
                              '${r.points}',
                              textAlign: TextAlign.end,
                              style: body.copyWith(
                                fontWeight: FontWeight.w600,
                                color: c.text,
                              ),
                            ),
                          ]),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        child: Text(
                          l.standingsFootnoteNoPlayoff,
                          style: NardType.micro.copyWith(
                            color: c.text.withValues(alpha: .5),
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
        if (detail.nextMatch != null ||
            t.status == TournamentStatus.finished ||
            t.myStatus == MyTournamentStatus.eliminated)
          TournamentPanel(detail: detail)
        else if (mine != null)
          PinnedMeRow(
            rank: l.lbRank(mine.rank),
            name: l.memberMe(mine.user.name),
            value: '${mine.points}',
          ),
      ],
    );
  }
}

class _RoundSquare extends StatelessWidget {
  const _RoundSquare({
    required this.n,
    required this.current,
    required this.future,
  });

  final int n;
  final bool current;
  final bool future;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: current ? NardPalette.ivory100 : c.text.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(NardRadius.s),
      ),
      child: Text(
        '$n',
        style: NardType.caption.copyWith(
          fontWeight: FontWeight.w600,
          color:
              current
                  ? NardPalette.walnut900
                  : future
                  ? c.text.withValues(alpha: .3)
                  : c.text,
        ),
      ),
    );
  }
}
