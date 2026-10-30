import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/gen/app_localizations.dart';
import '../online/api_client.dart' show ApiException;
import '../screens/replay_screen.dart';
import '../theme/nard_colors.dart';
import '../ui/background.dart';
import '../ui/layout.dart';
import '../ui/social.dart';
import 'analysis_providers.dart';

/// 10.1 analysis of an online match (`GET /me/matches/{id}` records),
/// one game at a time.
class MatchAnalysisScreen extends ConsumerStatefulWidget {
  const MatchAnalysisScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<MatchAnalysisScreen> createState() =>
      _MatchAnalysisScreenState();
}

class _MatchAnalysisScreenState extends ConsumerState<MatchAnalysisScreen> {
  int _game = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final value = ref.watch(matchRecordsProvider(widget.matchId));
    Widget message(String title, String body, {bool retry = false}) => Column(
      children: [
        ScreenHeader(title: l.actionAnalysis),
        Expanded(
          child: MessageState(
            title: title,
            body: body,
            danger: retry,
            action: retry ? l.retry : null,
            onAction:
                retry
                    ? () => ref.invalidate(matchRecordsProvider(widget.matchId))
                    : null,
          ),
        ),
      ],
    );
    final Widget body;
    if (value.hasError) {
      final e = value.error;
      body =
          e is ApiException && e.status == 404
              ? message(l.replayLoadError, l.analysisNotReady, retry: true)
              : e is ApiException && e.offline
              ? message(l.onlineOfflineTitle, l.onlineOfflineBody, retry: true)
              : message(l.replayLoadError, l.errorBody, retry: true);
    } else if (!value.hasValue) {
      body = Center(
        child: CircularProgressIndicator(color: c.accent, strokeWidth: 2),
      );
    } else {
      final m = value.requireValue;
      if (m.games.isEmpty) {
        body = message(l.actionAnalysis, l.analysisNoGames);
      } else {
        final index = _game.clamp(0, m.games.length - 1);
        final record = m.games[index];
        body = ReplayView(
          key: ValueKey(index),
          viewer: m.you,
          white: m.white,
          black: m.black,
          record: record,
          frames: buildFrames(record, l),
          gameNumber: index + 1,
          analysis: true,
          header:
              m.games.length < 2
                  ? null
                  : SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                      children: [
                        for (var i = 0; i < m.games.length; i++) ...[
                          if (i > 0) const SizedBox(width: 6),
                          NardFilterChip(
                            label: l.analysisGameChip(i + 1),
                            selected: i == index,
                            onTap: () => setState(() => _game = i),
                          ),
                        ],
                      ],
                    ),
                  ),
        );
      }
    }
    return Scaffold(body: NardBackground(child: SafeArea(child: body)));
  }
}
