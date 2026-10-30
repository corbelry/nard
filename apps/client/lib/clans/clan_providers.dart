import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cosmetics/cosmetics_providers.dart' show noRetry;
import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../online/api_client.dart';
import '../store/inventory.dart';
import '../store/store_models.dart';
import 'clan_models.dart';

/// `GET /clans/{id}` (5.2 profile, 5.4 header, 5.5 members).
final clanDetailProvider = FutureProvider.autoDispose
    .family<ClanDetail, String>(
      (ref, id) => ref.read(apiClientProvider).clan(id),
      retry: noRetry,
    );

/// My pending clan invites (5.1 "DƏVƏTLƏR").
final clanInvitesProvider = FutureProvider.autoDispose<List<ClanInvite>>(
  _invites,
  retry: noRetry,
);

Future<List<ClanInvite>> _invites(Ref ref) async {
  final signedIn = ref.watch(accountProvider.select((a) => a.value?.id));
  if (signedIn == null) return const [];
  return ref.read(apiClientProvider).clanInvites();
}

final clanLeaderboardProvider = FutureProvider.autoDispose<ClanLeaderboard>(
  (ref) => ref.read(apiClientProvider).clanLeaderboard(),
  retry: noRetry,
);

final clanWarProvider = FutureProvider.autoDispose.family<ClanWar?, String>(
  (ref, id) => ref.read(apiClientProvider).clanWar(id),
  retry: noRetry,
);

final clanRequestsProvider = FutureProvider.autoDispose
    .family<List<JoinRequest>, String>(
      (ref, id) => ref.read(apiClientProvider).clanRequests(id),
      retry: noRetry,
    );

/// 5.1 search filters.
class ClanQuery {
  const ClanQuery({
    this.text = '',
    this.language,
    this.openOnly = false,
    this.maxMinRating,
  });

  final String text;
  final String? language;
  final bool openOnly;
  final int? maxMinRating;

  @override
  bool operator ==(Object other) =>
      other is ClanQuery &&
      other.text == text &&
      other.language == language &&
      other.openOnly == openOnly &&
      other.maxMinRating == maxMinRating;

  @override
  int get hashCode => Object.hash(text, language, openOnly, maxMinRating);
}

final clanSearchProvider = FutureProvider.autoDispose
    .family<List<ClanSummary>, ClanQuery>(
      (ref, q) => ref
          .read(apiClientProvider)
          .clans(
            query: q.text,
            language: q.language,
            policy: q.openOnly ? JoinPolicy.open : null,
            maxMinRating: q.maxMinRating,
          ),
      retry: noRetry,
    );

/// Clan chat state (5.4): messages oldest first, polled while open.
class ClanChatState {
  const ClanChatState({
    this.messages = const [],
    this.loading = true,
    this.error,
    this.sending = false,
  });

  final List<ClanMessage> messages;
  final bool loading;
  final Object? error;
  final bool sending;

  ClanChatState copyWith({
    List<ClanMessage>? messages,
    bool? loading,
    Object? Function()? error,
    bool? sending,
  }) => ClanChatState(
    messages: messages ?? this.messages,
    loading: loading ?? this.loading,
    error: error != null ? error() : this.error,
    sending: sending ?? this.sending,
  );
}

/// Polls `GET /clans/{id}/messages?after=` every [pollEvery] while the
/// chat is on screen (autoDispose stops it).
class ClanChat extends Notifier<ClanChatState> {
  ClanChat(this.clanId);

  final String clanId;
  Timer? _timer;
  bool _polling = false;

  static const pollEvery = Duration(seconds: 5);

  /// Keep at most this many messages in memory.
  static const keep = 200;

  ApiClient get _api => ref.read(apiClientProvider);

  @override
  ClanChatState build() {
    _timer = Timer.periodic(pollEvery, (_) => unawaited(poll()));
    ref.onDispose(() => _timer?.cancel());
    unawaited(Future.microtask(poll));
    return const ClanChatState();
  }

  int? get _lastId => state.messages.isEmpty ? null : state.messages.last.id;

  Future<void> poll() async {
    if (_polling) return;
    _polling = true;
    try {
      final fresh = await _api.clanMessages(clanId, after: _lastId);
      if (!ref.mounted) return;
      _merge(fresh);
      state = state.copyWith(loading: false, error: () => null);
    } on Object catch (e) {
      if (ref.mounted) state = state.copyWith(loading: false, error: () => e);
    } finally {
      _polling = false;
    }
  }

  void _merge(List<ClanMessage> fresh) {
    if (fresh.isEmpty) return;
    final known = {for (final m in state.messages) m.id};
    final all = [
      ...state.messages,
      for (final m in fresh)
        if (!known.contains(m.id)) m,
    ]..sort((a, b) => a.id.compareTo(b.id));
    state = state.copyWith(
      messages: all.length > keep ? all.sublist(all.length - keep) : all,
    );
  }

  /// Returns true once posted; errors (429, 422) are rethrown.
  Future<bool> send(String text) async {
    state = state.copyWith(sending: true);
    try {
      final m = await _api.postClanMessage(clanId, text);
      if (ref.mounted) _merge([m]);
      return true;
    } finally {
      if (ref.mounted) state = state.copyWith(sending: false);
    }
  }

  Future<void> delete(int messageId) async {
    await _api.deleteClanMessage(clanId, messageId);
    if (!ref.mounted) return;
    state = state.copyWith(
      messages: [
        for (final m in state.messages)
          if (m.id != messageId) m,
      ],
    );
  }
}

final clanChatProvider = NotifierProvider.autoDispose
    .family<ClanChat, ClanChatState, String>(ClanChat.new);

/// After joining, leaving or creating: reload `/me` (its `clan`) and the
/// wallet.
Future<void> refreshMembership(WidgetRef ref, {Wallet? wallet}) async {
  if (wallet != null) ref.read(inventoryProvider.notifier).setWallet(wallet);
  try {
    await ref.read(accountProvider.notifier).refresh();
  } on Object {
    // The tab catches up on the next account load.
  }
}

/// Copy for clan API errors (docs/api/clans.md codes).
String clanErrorText(AppLocalizations l, Object error) {
  if (error is! ApiException) return l.errorTitle;
  if (error.offline) return l.authOffline;
  if (error.status == 429) return l.clanChatTooFast;
  return switch (error.code) {
    'invite_only' => l.clanInviteOnlyCta,
    'rating_too_low' => l.clanErrRatingLow,
    'clan_full' => l.clanFullCta,
    'already_in_clan' => l.clanErrInClan,
    'insufficient_funds' => l.purchaseNotEnoughCoins,
    'name_taken' => l.createErrNameTaken,
    'tag_taken' => l.createTagTaken,
    'transfer_first' => l.clanTransferFirst,
    'chest_full' => l.clanErrChestFull,
    'blocked' || 'self' => l.friendErrBlocked,
    _ => l.errorTitle,
  };
}
