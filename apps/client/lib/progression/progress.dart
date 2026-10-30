import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cosmetics/cosmetics_providers.dart';
import '../online/account.dart';
import '../store/inventory.dart';
import 'progress_models.dart';

/// Level, missions, streak, achievements and title of the signed-in
/// player; null while signed out.
class ProgressNotifier extends AsyncNotifier<Progress?> {
  @override
  Future<Progress?> build() async {
    final signedIn = ref.watch(accountProvider.select((a) => a.value?.id));
    if (signedIn == null) return null;
    return ref.read(apiClientProvider).progress();
  }

  /// Reloads from the API; returns the new value (null on failure).
  Future<Progress?> refresh() async {
    try {
      final fresh = await ref.read(apiClientProvider).progress();
      if (ref.mounted) state = AsyncData(fresh);
      return fresh;
    } on Object {
      return null;
    }
  }

  /// Claims a completed mission (12.1). Throws [ApiException]
  /// (`not_claimable`).
  Future<void> claim(String missionId) async {
    final result = await ref.read(apiClientProvider).claimMission(missionId);
    state = AsyncData(result.progress);
    ref.read(inventoryProvider.notifier).setWallet(result.wallet);
  }

  /// Daily check-in (12.2): credits the streak coins once per day
  /// (idempotent on the server). Returns the result when coins were
  /// credited now, else null (already checked in, or offline).
  Future<CheckIn?> checkIn() async {
    try {
      final result = await ref.read(apiClientProvider).checkIn();
      final wallet = result.wallet;
      if (wallet != null) {
        ref.read(inventoryProvider.notifier).setWallet(wallet);
      }
      if (result.coins <= 0) return null;
      await refresh();
      return result;
    } on Object {
      return null;
    }
  }

  /// Shows [itemId] (a `title.*` item) under the name; null clears it.
  Future<void> setTitle(String? itemId) async {
    await ref.read(apiClientProvider).setTitle(itemId);
    final current = state.value;
    if (current != null) {
      state = AsyncData(
        current.copyWith(title: itemId, clearTitle: itemId == null),
      );
    }
  }
}

final progressProvider = AsyncNotifierProvider<ProgressNotifier, Progress?>(
  ProgressNotifier.new,
  retry: noRetry,
);

/// Whether this app session already checked in (12.2 shows once per open).
class CheckInGate extends Notifier<String?> {
  @override
  String? build() => null;

  /// True the first time for [accountId] in this session.
  bool claim(String accountId) {
    if (state == accountId) return false;
    state = accountId;
    return true;
  }
}

final checkInGateProvider = NotifierProvider<CheckInGate, String?>(
  CheckInGate.new,
);
