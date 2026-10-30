import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cosmetics/catalog.dart';
import '../cosmetics/cosmetics_providers.dart';
import '../online/account.dart';
import 'store_models.dart';

/// A random purchase idempotency key (API: 8–64 chars).
String newIdempotencyKey() {
  final r = Random.secure();
  return List.generate(24, (_) => r.nextInt(16).toRadixString(16)).join();
}

/// Wallet, owned items and loadouts of the signed-in player; null while
/// signed out. Errors (offline) surface as AsyncError.
class InventoryNotifier extends AsyncNotifier<Inventory?> {
  @override
  Future<Inventory?> build() async {
    final signedIn = ref.watch(accountProvider.select((a) => a.value?.id));
    if (signedIn == null) return null;
    final inventory = await ref.read(apiClientProvider).inventory();
    unawaited(ref.read(cosmeticsCacheProvider).saveSlots(inventory.equipped));
    return inventory;
  }

  Inventory? get _current => state.value;

  void _set(Inventory next) {
    state = AsyncData(next);
    unawaited(ref.read(cosmeticsCacheProvider).saveSlots(next.equipped));
  }

  /// Reloads from the API (keeps the old value on failure).
  Future<void> refresh() async {
    try {
      final fresh = await ref.read(apiClientProvider).inventory();
      if (ref.mounted) _set(fresh);
    } on Object {
      // Offline: keep what we have.
    }
  }

  void setWallet(Wallet wallet) {
    final current = _current;
    if (current != null) state = AsyncData(current.copyWith(wallet: wallet));
  }

  /// Buys [item] with [currency]. Throws [ApiException] (422 codes).
  Future<PurchaseResult> purchase(
    CatalogItem item,
    Currency currency, {
    String? idempotencyKey,
  }) async {
    final result = await ref
        .read(apiClientProvider)
        .purchase(item.id, currency, idempotencyKey ?? newIdempotencyKey());
    final current = _current ?? const Inventory();
    _set(current.copyWith(wallet: result.wallet, owned: result.owned));
    return result;
  }

  /// Saves [slots] into loadout [id] (or a new loadout named [name]).
  Future<void> saveLoadout(
    String name,
    Map<String, String> slots, {
    int? id,
  }) async {
    await ref.read(apiClientProvider).saveLoadout(name, slots, id: id);
    await refresh();
  }

  Future<void> activate(int id) async {
    await ref.read(apiClientProvider).activateLoadout(id);
    final current = _current;
    if (current != null) {
      _set(
        current.copyWith(
          loadouts: [
            for (final l in current.loadouts) l.copyWith(active: l.id == id),
          ],
        ),
      );
    }
  }

  Future<void> deleteLoadout(int id) async {
    await ref.read(apiClientProvider).deleteLoadout(id);
    await refresh();
  }

  /// Equips [item] into the active loadout and saves it; creates the first
  /// loadout ([defaultName]) when there is none.
  Future<void> equip(CatalogItem item, {required String defaultName}) async {
    final active = _current?.active;
    final slots = {...?active?.slots, item.category: item.id};
    await saveLoadout(active?.name ?? defaultName, slots, id: active?.id);
  }
}

final inventoryProvider = AsyncNotifierProvider<InventoryNotifier, Inventory?>(
  InventoryNotifier.new,
  retry: noRetry,
);
