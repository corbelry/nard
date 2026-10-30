import 'dart:async';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nard_core/nard_core.dart';

import '../game/match_setup.dart';
import '../online/account.dart';
import '../store/inventory.dart';
import 'board_look.dart';
import 'catalog.dart';
import 'cosmetics_cache.dart';

/// Never retry automatically: API failures surface as offline states and
/// the user retries (Riverpod 3 retries exceptions by default).
Duration? noRetry(int _, Object _) => null;

final cosmeticsCacheProvider = Provider<CosmeticsCache>(
  (_) => CosmeticsCache(),
);

/// The item catalog: the cached copy (or the built-in walnut) at once,
/// refreshed from the API while signed in (the endpoint needs a token).
class CatalogNotifier extends AsyncNotifier<Catalog> {
  @override
  Future<Catalog> build() async {
    final signedIn = ref.watch(accountProvider.select((a) => a.value?.id));
    final cached = await ref.read(cosmeticsCacheProvider).catalog();
    if (signedIn != null) unawaited(Future.microtask(refresh));
    return cached ?? Catalog.builtin;
  }

  Future<void> refresh() async {
    try {
      final fresh = await ref.read(apiClientProvider).catalog();
      if (!ref.mounted || fresh.items.isEmpty) return;
      state = AsyncData(fresh);
      await ref.read(cosmeticsCacheProvider).saveCatalog(fresh);
    } on Object {
      // Offline: keep the cached catalog.
    }
  }
}

final catalogProvider = AsyncNotifierProvider<CatalogNotifier, Catalog>(
  CatalogNotifier.new,
  retry: noRetry,
);

/// The catalog with the built-in fallback while loading.
final currentCatalogProvider = Provider<Catalog>(
  (ref) => ref.watch(catalogProvider).value ?? Catalog.builtin,
);

/// Equipped slots saved on the last successful inventory load.
final cachedSlotsProvider = FutureProvider<Map<String, String>>(
  (ref) => ref.read(cosmeticsCacheProvider).slots(),
  retry: noRetry,
);

/// The local player's equipped items: the active loadout, or the cached
/// one while signed out / offline.
final equippedSlotsProvider = Provider<Map<String, String>>((ref) {
  final inventory = ref.watch(inventoryProvider).value;
  if (inventory != null) return inventory.equipped;
  return ref.watch(cachedSlotsProvider).value ?? const {};
});

/// The local player's board set (built-in walnut by default).
final localLookProvider = Provider<BoardLook>(
  (ref) => ref
      .watch(currentCatalogProvider)
      .lookFor(ref.watch(equippedSlotsProvider)),
);

/// The table background of the equipped set; null keeps the theme
/// background (nothing equipped yet).
final localTableProvider = Provider<List<Color>?>((ref) {
  final slots = ref.watch(equippedSlotsProvider);
  if (!slots.containsKey(ItemCategory.board)) return null;
  return ref.watch(localLookProvider).table;
});

/// The opponent's set for an online match, when the "show opponent
/// cosmetics" setting is on and their board is in the catalog.
Map<Side, BoardLook> opponentLooks(
  Catalog catalog,
  MatchSetup setup, {
  required bool show,
}) {
  final online = setup.online;
  if (!show || online == null) return const {};
  final side = setup.localSide.opponent;
  final seat = online.player(side);
  if (seat.bot) return const {};
  final look = catalog.item(seat.cosmetics[ItemCategory.board])?.look;
  return look == null ? const {} : {side: look};
}
