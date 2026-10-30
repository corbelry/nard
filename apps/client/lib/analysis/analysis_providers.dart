import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nard_core/nard_core.dart';

import '../cosmetics/cosmetics_providers.dart' show noRetry;
import '../online/account.dart';
import 'analysis_engine.dart';

/// Analyses one position; one isolate per position by default (tests run
/// it inline).
final analysisRunnerProvider =
    Provider<Future<MoveEval> Function(AnalysisTask)>(
      (_) => Analyzer.analyseInIsolate,
    );

/// Finished analyses per game record for this app session.
final analysisCacheProvider = Provider<Map<String, List<MoveEval>>>((_) => {});

/// Cache key of a game record.
String recordKey(GameRecord record) => jsonEncode(record.toJson());

/// An online match from `GET /me/matches/{id}`: names, my side and the
/// game records.
class MatchRecords {
  const MatchRecords({
    required this.variant,
    required this.white,
    required this.black,
    required this.you,
    required this.games,
  });

  final Variant variant;
  final String white;
  final String black;
  final Side you;
  final List<GameRecord> games;

  static MatchRecords fromJson(Map<String, Object?> j) {
    String name(Object? p) => p is Map ? '${p['name'] ?? ''}' : '';
    return MatchRecords(
      variant:
          j['variant'] == 'longNard' ? Variant.longNard : Variant.shortNard,
      white: name(j['white']),
      black: name(j['black']),
      you: j['you'] == 'black' ? Side.black : Side.white,
      games: [
        // Each game is the MatchResult entry `{record, serverSeed, …}`; a
        // bare record is accepted too.
        for (final g in (j['games'] as List?) ?? const [])
          if (g is Map<String, Object?>)
            GameRecord.fromJson(
              g['record'] is Map<String, Object?>
                  ? g['record']! as Map<String, Object?>
                  : g,
            ),
      ],
    );
  }
}

final matchRecordsProvider = FutureProvider.autoDispose
    .family<MatchRecords, String>(
      (ref, id) async =>
          MatchRecords.fromJson(await ref.read(apiClientProvider).match(id)),
      retry: noRetry,
    );
