import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cosmetics/cosmetics_providers.dart' show noRetry;
import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../online/api_client.dart';
import 'social_models.dart';

/// Friends, requests, my friend code and incoming challenges (6.1); null
/// while signed out. Errors (offline) surface as AsyncError.
class FriendsNotifier extends AsyncNotifier<FriendsOverview?> {
  ApiClient get _api => ref.read(apiClientProvider);

  @override
  Future<FriendsOverview?> build() async {
    final signedIn = ref.watch(accountProvider.select((a) => a.value?.id));
    if (signedIn == null) return null;
    return _api.friends();
  }

  Future<void> refresh() async {
    final fresh = await _api.friends();
    if (ref.mounted) state = AsyncData(fresh);
  }

  Future<void> _thenRefresh(Future<void> action) async {
    await action;
    try {
      await refresh();
    } on ApiException {
      // The action went through; the list catches up on the next load.
    }
  }

  /// Sends a request by friend [code] or [userId] (6.2, 14.1).
  Future<FriendRequestStatus> add({String? code, String? userId}) async {
    final status = await _api.requestFriend(code: code, userId: userId);
    await _thenRefresh(Future.value());
    return status;
  }

  Future<void> accept(int requestId) =>
      _thenRefresh(_api.acceptFriend(requestId));

  Future<void> dismiss(int requestId) =>
      _thenRefresh(_api.dismissFriend(requestId));

  Future<void> unfriend(String userId) => _thenRefresh(_api.unfriend(userId));
}

final friendsProvider =
    AsyncNotifierProvider<FriendsNotifier, FriendsOverview?>(
      FriendsNotifier.new,
      retry: noRetry,
    );

/// Players I blocked (14.3, 15.1 › Bloklananlar).
class BlocksNotifier extends AsyncNotifier<List<PublicUser>?> {
  ApiClient get _api => ref.read(apiClientProvider);

  @override
  Future<List<PublicUser>?> build() async {
    final signedIn = ref.watch(accountProvider.select((a) => a.value?.id));
    if (signedIn == null) return null;
    return _api.blocks();
  }

  bool isBlocked(String userId) =>
      state.value?.any((u) => u.id == userId) ?? false;

  /// Blocking also ends a friendship, so the friend list reloads.
  Future<void> block(String userId) async {
    await _api.block(userId);
    await _reload();
  }

  Future<void> unblock(String userId) async {
    await _api.unblock(userId);
    await _reload();
  }

  Future<void> _reload() async {
    try {
      final fresh = await _api.blocks();
      if (ref.mounted) state = AsyncData(fresh);
      await ref.read(friendsProvider.notifier).refresh();
    } on ApiException {
      // Reloaded on the next visit.
    }
  }
}

final blocksProvider = AsyncNotifierProvider<BlocksNotifier, List<PublicUser>?>(
  BlocksNotifier.new,
  retry: noRetry,
);

/// Players whose emotes and phrases I hide (14.1 "Söhbəti səssizə al");
/// local to this app run.
class MutedPlayers extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  bool isMuted(String userId) => state.contains(userId);

  void toggle(String userId) =>
      state =
          state.contains(userId)
              ? ({...state}..remove(userId))
              : {...state, userId};
}

final mutedPlayersProvider = NotifierProvider<MutedPlayers, Set<String>>(
  MutedPlayers.new,
);

/// userId → matchId of friends in a running game (WS `presence`).
class PresenceNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => const {};

  void set(Map<String, String> matches) => state = Map.unmodifiable(matches);
}

final presenceProvider =
    NotifierProvider<PresenceNotifier, Map<String, String>>(
      PresenceNotifier.new,
    );

/// Copy for a failed friend request (social.md §2.2).
String friendErrorText(AppLocalizations l, Object error) {
  if (error is! ApiException) return l.errorTitle;
  if (error.offline) return l.authOffline;
  if (error.status == 404) return l.friendErrNotFound;
  if (error.status == 429) return l.authTooManyTries;
  return switch (error.code) {
    'blocked' || 'self' => l.friendErrBlocked,
    'already_friends' => l.friendErrAlready,
    'already_requested' => l.friendErrPending,
    'too_many_friends' => l.friendErrLimit(200),
    _ => l.errorTitle,
  };
}

/// Reloads the friend list without surfacing errors (pull to refresh).
Future<void> refreshFriends(WidgetRef ref) async {
  try {
    await ref.read(friendsProvider.notifier).refresh();
  } on Object {
    ref.invalidate(friendsProvider);
  }
}
