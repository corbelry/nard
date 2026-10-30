import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nard_core/nard_core.dart';

import 'account.dart';

/// One row of `GET /me/matches`, seen from the signed-in player.
class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.variant,
    required this.matchLength,
    required this.ranked,
    required this.opponentName,
    required this.opponentBot,
    required this.won,
    required this.myScore,
    required this.opponentScore,
    required this.endedAt,
    this.ratingBefore,
    this.ratingAfter,
  });

  final String id;
  final Variant variant;
  final int matchLength;
  final bool ranked;
  final String opponentName;
  final bool opponentBot;
  final bool won;
  final int myScore;
  final int opponentScore;
  final DateTime endedAt;
  final int? ratingBefore;
  final int? ratingAfter;

  /// Rating change; null for casual / bot matches.
  int? get ratingDelta =>
      ratingBefore == null || ratingAfter == null
          ? null
          : ratingAfter! - ratingBefore!;

  static HistoryEntry fromJson(Map<String, Object?> j) {
    final you = j['you'] as String? ?? 'white';
    final white = j['white']! as Map<String, Object?>;
    final black = j['black']! as Map<String, Object?>;
    final me = you == 'white' ? white : black;
    final opp = you == 'white' ? black : white;
    final whiteScore = j['whiteScore']! as int;
    final blackScore = j['blackScore']! as int;
    return HistoryEntry(
      id: '${j['id']}',
      variant: Variant.values.byName(j['variant']! as String),
      matchLength: j['matchLength']! as int,
      ranked: j['mode'] == 'ranked',
      opponentName: opp['name'] as String? ?? '',
      opponentBot: opp['bot'] == true,
      won: j['winner'] == you,
      myScore: you == 'white' ? whiteScore : blackScore,
      opponentScore: you == 'white' ? blackScore : whiteScore,
      endedAt: DateTime.parse(j['endedAt']! as String).toLocal(),
      ratingBefore: me['ratingBefore'] as int?,
      ratingAfter: me['ratingAfter'] as int?,
    );
  }
}

/// The player's recent online matches (8.1); reloaded on sign-in changes.
final matchHistoryProvider = FutureProvider.autoDispose<List<HistoryEntry>>((
  ref,
) async {
  final account = ref.watch(accountProvider).value;
  if (account == null) return const [];
  final rows = await ref.read(apiClientProvider).matches(limit: 50);
  return [for (final r in rows) HistoryEntry.fromJson(r)];
});
