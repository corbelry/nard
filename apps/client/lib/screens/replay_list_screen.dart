import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nard_core/nard_core.dart';

import '../app/providers.dart';
import '../data/database.dart';
import '../game/match_setup.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/background.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import 'ai_level_screen.dart';

final recentGamesProvider = FutureProvider.autoDispose<List<GameRecordRow>>(
  (ref) => ref.watch(databaseProvider).recentGames(),
);

/// Names of both sides for a saved game.
(String, String) playerNames(AppLocalizations l, MatchSetup setup) {
  if (setup.vsComputer) {
    return (l.you, '${l.computerName} · ${aiLevelName(l, setup.level)}');
  }
  return (
    setup.whiteName.isEmpty ? l.hotseatDefaultWhite : setup.whiteName,
    setup.blackName.isEmpty ? l.hotseatDefaultBlack : setup.blackName,
  );
}

/// Finished local games ("Oyunlarım"), newest first.
class ReplayListScreen extends ConsumerWidget {
  const ReplayListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final games = ref.watch(recentGamesProvider);
    return Scaffold(
      body: NardBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(title: l.replayListTitle),
              Expanded(
                child: games.when(
                  loading: () => const _Skeleton(),
                  error:
                      (_, _) => MessageState(
                        title: l.errorTitle,
                        body: l.errorBody,
                        danger: true,
                        action: l.retry,
                        onAction: () => ref.invalidate(recentGamesProvider),
                      ),
                  data:
                      (rows) =>
                          rows.isEmpty
                              ? MessageState(
                                title: l.replayEmptyTitle,
                                body: l.replayEmptyBody,
                                action: l.playVsComputer,
                                onAction: () => context.push('/setup'),
                              )
                              : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  24,
                                ),
                                itemCount: rows.length,
                                separatorBuilder:
                                    (_, _) => const SizedBox(height: 8),
                                itemBuilder: (_, i) {
                                  final row = rows[i];
                                  final setup = MatchSetup.fromJson(
                                    jsonDecode(row.setupJson)
                                        as Map<String, Object?>,
                                  );
                                  final (white, black) = playerNames(l, setup);
                                  final variant =
                                      setup.variant == Variant.shortNard
                                          ? l.variantShort
                                          : l.variantLong;
                                  final winner =
                                      row.winner == Side.white.name
                                          ? white
                                          : black;
                                  final date = MaterialLocalizations.of(
                                    context,
                                  ).formatShortDate(row.playedAt);
                                  return Pressable(
                                    onTap:
                                        () => context.push('/replay/${row.id}'),
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: c.text.withValues(alpha: .04),
                                        borderRadius: BorderRadius.circular(
                                          NardRadius.l,
                                        ),
                                        border: Border.all(
                                          color: c.accent.withValues(
                                            alpha: .14,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '$variant · $date',
                                                  style: NardType.caption
                                                      .copyWith(
                                                        color: c.textDim,
                                                      ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  l.replayPlayers(white, black),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: NardType.labelM
                                                      .copyWith(color: c.text),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  l.replayWon(
                                                    winner,
                                                    row.points,
                                                  ),
                                                  style: NardType.caption
                                                      .copyWith(
                                                        color: c.textDim,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '${row.whiteScore} – ${row.blackScore}',
                                            style: NardType.score.copyWith(
                                              color: c.text,
                                              fontFeatures: tabular,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            LucideIcons.chevronRight,
                                            size: 16,
                                            color: c.textDim,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Loading skeleton (11.4).
class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    Widget bar(double f, double h, double a) => FractionallySizedBox(
      widthFactor: f,
      alignment: Alignment.centerLeft,
      child: Container(
        height: h,
        decoration: BoxDecoration(
          color: c.text.withValues(alpha: a),
          borderRadius: BorderRadius.circular(h / 2),
        ),
      ),
    );
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        for (var i = 0; i < 4; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            height: 118,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.text.withValues(alpha: .04),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bar(.4, 10, .08),
                const SizedBox(height: 12),
                bar(.7, 16, .11),
                const SizedBox(height: 12),
                bar(.55, 10, .08),
                const SizedBox(height: 12),
                bar(1, 4, .06),
              ],
            ),
          ),
      ],
    );
  }
}
