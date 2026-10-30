import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nard_core/nard_core.dart' show Variant;

import '../app/providers.dart';
import '../cosmetics/cosmetics_providers.dart' show noRetry;
import '../data/database.dart';
import '../online/account.dart';
import '../online/api_client.dart' show ApiException;
import '../store/inventory.dart';
import 'season_models.dart';

/// `GET /season` (7.1 pass, 2.1 season card); null while signed out.
class SeasonNotifier extends AsyncNotifier<SeasonView?> {
  @override
  Future<SeasonView?> build() async {
    final signedIn = ref.watch(accountProvider.select((a) => a.value?.id));
    if (signedIn == null) return null;
    return ref.read(apiClientProvider).season();
  }

  Future<void> claim(int level, PassTrack track) async {
    final (view, wallet) = await ref
        .read(apiClientProvider)
        .claimPassReward(level, track);
    _set(view);
    ref.read(inventoryProvider.notifier).setWallet(wallet);
  }

  Future<void> claimAll() async {
    final (view, wallet) =
        await ref.read(apiClientProvider).claimAllPassRewards();
    _set(view);
    ref.read(inventoryProvider.notifier).setWallet(wallet);
  }

  /// 950 Yaqut once per season; throws 422 `insufficient_funds`.
  Future<void> buyPremium(String idempotencyKey) async {
    final (view, wallet) = await ref
        .read(apiClientProvider)
        .buySeasonPremium(idempotencyKey);
    _set(view);
    ref.read(inventoryProvider.notifier).setWallet(wallet);
    // Item rewards land in the inventory.
    await ref.read(inventoryProvider.notifier).refresh();
  }

  void _set(SeasonView view) {
    if (ref.mounted) state = AsyncData(view);
  }
}

final seasonProvider = AsyncNotifierProvider<SeasonNotifier, SeasonView?>(
  SeasonNotifier.new,
  retry: noRetry,
);

/// 7.2: the latest finished season ([number] null) or a given one; null
/// when there is none yet (404).
final seasonSummaryProvider = FutureProvider.autoDispose
    .family<SeasonSummary?, int?>(_summary, retry: noRetry);

Future<SeasonSummary?> _summary(Ref ref, int? number) async {
  try {
    return await ref.read(apiClientProvider).seasonSummary(number);
  } on ApiException catch (e) {
    if (e.status == 404) return null;
    rethrow;
  }
}

final seasonsListProvider = FutureProvider.autoDispose<List<Season>>(
  (ref) => ref.read(apiClientProvider).seasons(),
  retry: noRetry,
);

/// 6.5 query.
class LbQuery {
  const LbQuery(this.variant, this.scope, {this.season});

  final Variant variant;
  final LeaderboardScope scope;

  /// Null = the running season.
  final int? season;

  @override
  bool operator ==(Object other) =>
      other is LbQuery &&
      other.variant == variant &&
      other.scope == scope &&
      other.season == season;

  @override
  int get hashCode => Object.hash(variant, scope, season);
}

final leaderboardProvider = FutureProvider.autoDispose
    .family<Leaderboard, LbQuery>(
      (ref, q) => ref
          .read(apiClientProvider)
          .leaderboard(q.variant, q.scope, season: q.season),
      retry: noRetry,
    );

const _seenKey = 'season.summarySeen';

/// The finished season whose 7.2 summary I have not opened yet (2.1
/// prompt); null otherwise, while signed out or on errors.
final seasonSummaryPromptProvider = FutureProvider.autoDispose<int?>(
  _prompt,
  retry: noRetry,
);

Future<int?> _prompt(Ref ref) async {
  final signedIn = ref.watch(accountProvider.select((a) => a.value?.id));
  if (signedIn == null) return null;
  try {
    final summary = await ref.read(apiClientProvider).seasonSummary();
    final seen = int.tryParse(
      (await ref.read(databaseProvider).readSettings())[_seenKey] ?? '',
    );
    final n = summary.season.number;
    return seen != null && seen >= n ? null : n;
  } on Object {
    return null;
  }
}

/// Marks the 7.2 summary of season [number] as seen.
Future<void> markSummarySeen(AppDatabase db, int number) =>
    db.writeSetting(_seenKey, '$number');
