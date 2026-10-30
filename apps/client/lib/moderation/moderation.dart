import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../online/account.dart';
import '../online/api_client.dart';

/// Where banned players write to appeal (shown on the banned screen).
// TODO(owner): confirm the domain and mailbox exist before release
// (docs/QUESTIONS.md #41, docs/store/listing.md "What the owner provides").
const kSupportEmail = 'support@nardarena.app';

/// The current account ban, set by any `403 {code: banned}` answer
/// (ADR-042). While non-null the app shows the full-screen banned state.
class BanNotifier extends Notifier<AccountBan?> {
  @override
  AccountBan? build() {
    final api = ref.watch(apiClientProvider);
    final sub = api.bans.listen((ban) => state = ban);
    ref.onDispose(() => unawaited(sub.cancel()));
    return api.ban;
  }

  /// Signs out (the device keeps playing offline) and leaves the banned
  /// state.
  Future<void> signOut() async {
    await ref.read(accountProvider.notifier).signOut();
    _clear();
  }

  /// The ban ran out: load the account again.
  void resume() {
    _clear();
    ref.invalidate(accountProvider);
  }

  void _clear() {
    ref.read(apiClientProvider).clearBan();
    state = null;
  }
}

final banProvider = NotifierProvider<BanNotifier, AccountBan?>(BanNotifier.new);

/// "12 noyabr 2026, 14:30" in [locale].
String formatModerationTime(DateTime at, String locale) =>
    DateFormat.yMMMMd(locale).add_Hm().format(at);
