import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nard_core/nard_core.dart' show Variant;
import 'package:nard_protocol/nard_protocol.dart' show TimeControl;

import '../cosmetics/cosmetics_providers.dart' show noRetry;
import '../online/account.dart';
import '../online/api_client.dart';
import '../social/social_models.dart' show timeControlNamed;
import '../social/social_socket.dart';
import 'notification_models.dart';
import 'push_registrar.dart';

/// The inbox (16.2); null while signed out. [poll] adds rows newer than
/// the newest one held (Home polls every 60 s and on resume, ADR-041).
class InboxNotifier extends AsyncNotifier<InboxPage?> {
  ApiClient get _api => ref.read(apiClientProvider);

  @override
  Future<InboxPage?> build() async {
    final signedIn = ref.watch(accountProvider.select((a) => a.value?.id));
    if (signedIn == null) return null;
    return _api.notifications();
  }

  void _set(InboxPage page) {
    if (ref.mounted) state = AsyncData(page);
  }

  Future<void> refresh() async => _set(await _api.notifications());

  /// New rows only; a full load when nothing is held yet.
  Future<void> poll() async {
    final current = state.value;
    if (ref.read(accountProvider).value == null) return;
    if (current == null || current.items.isEmpty) return refresh();
    final fresh = await _api.notifications(after: current.items.first.id);
    final known = {for (final n in current.items) n.id};
    _set(
      InboxPage(
        items: [
          ...fresh.items.where((n) => !known.contains(n.id)),
          ...current.items,
        ],
        unread: fresh.unread,
      ),
    );
  }

  Future<void> markAllRead() async {
    final current = state.value;
    if (current == null) return;
    _set(
      InboxPage(
        items: [for (final n in current.items) n.copyWith(read: true)],
        unread: 0,
      ),
    );
    final unread = await _api.markNotificationsRead(all: true);
    _withUnread(unread);
  }

  Future<void> markRead(int id) async {
    final current = state.value;
    if (current == null) return;
    final target = current.items.where((n) => n.id == id && !n.read);
    if (target.isEmpty) return;
    _set(
      InboxPage(
        items: [
          for (final n in current.items)
            n.id == id ? n.copyWith(read: true) : n,
        ],
        unread: current.unread > 0 ? current.unread - 1 : 0,
      ),
    );
    _withUnread(await _api.markNotificationsRead(ids: [id]));
  }

  /// Removes a row (after its action was taken).
  Future<void> remove(int id) async {
    final current = state.value;
    if (current == null) return;
    final removed = current.items.where((n) => n.id == id);
    _set(
      InboxPage(
        items: [
          for (final n in current.items)
            if (n.id != id) n,
        ],
        unread:
            removed.any((n) => !n.read) && current.unread > 0
                ? current.unread - 1
                : current.unread,
      ),
    );
    try {
      _withUnread(await _api.deleteNotification(id));
    } on ApiException catch (e) {
      if (e.status != 404) rethrow;
    }
  }

  void _withUnread(int unread) {
    final current = state.value;
    if (current != null) _set(InboxPage(items: current.items, unread: unread));
  }
}

final inboxProvider = AsyncNotifierProvider<InboxNotifier, InboxPage?>(
  InboxNotifier.new,
  retry: noRetry,
);

/// The bell badge.
final unreadCountProvider = Provider<int>(
  (ref) => ref.watch(inboxProvider).value?.unread ?? 0,
);

/// 16.1 settings; null while signed out.
class NotificationSettingsNotifier
    extends AsyncNotifier<NotificationSettings?> {
  ApiClient get _api => ref.read(apiClientProvider);

  @override
  Future<NotificationSettings?> build() async {
    final signedIn = ref.watch(accountProvider.select((a) => a.value?.id));
    if (signedIn == null) return null;
    return _api.notificationSettings();
  }

  /// Applies [optimistic] at once and sends [fields] with the device's
  /// UTC offset (quiet hours are local); reverts on failure.
  Future<void> change(
    NotificationSettings optimistic,
    Map<String, Object?> fields,
  ) async {
    final before = state.value;
    state = AsyncData(optimistic);
    try {
      final saved = await _api.updateNotificationSettings({
        ...fields,
        'utcOffset': DateTime.now().timeZoneOffset.inMinutes,
      });
      if (ref.mounted) state = AsyncData(saved);
    } on Object {
      if (ref.mounted) state = AsyncData(before);
      rethrow;
    }
  }
}

final notificationSettingsProvider =
    AsyncNotifierProvider<NotificationSettingsNotifier, NotificationSettings?>(
      NotificationSettingsNotifier.new,
      retry: noRetry,
    );

/// Sends this device's push token to the API when the OS allows push (a
/// no-op with [NoopPushRegistrar]).
Future<void> syncPushDevice(
  ApiClient api,
  PushRegistrar registrar,
  String locale,
) async {
  if (await registrar.status() != PushStatus.granted) return;
  final token = await registrar.token();
  if (token == null || token.isEmpty) return;
  await api.registerDevice(
    registrar.platform,
    token,
    locale: locale,
    utcOffset: DateTime.now().timeZoneOffset.inMinutes,
  );
}

/// Where a notification leads (16.2 tap, push tap); null = nowhere.
/// `go` = a tab root (switch tabs) rather than a pushed screen.
({String path, bool go})? notificationLink(AppNotification n) {
  final tournament = n.text('tournamentId');
  return switch (n.type) {
    NotificationType.friendRequest ||
    NotificationType.friendAccepted => (path: '/friends', go: false),
    NotificationType.challenge => (
      path: '/room/join?code=${n.text('code')}',
      go: false,
    ),
    NotificationType.clanInvite || NotificationType.clanJoined => (
      path: '/clans/${n.text('clanId')}',
      go: false,
    ),
    NotificationType.clanWar => (path: '/clan', go: true),
    NotificationType.tournamentReminder ||
    NotificationType.tournamentStarted ||
    NotificationType.tournamentRound ||
    NotificationType.tournamentEliminated ||
    NotificationType.tournamentWon ||
    NotificationType.tournamentFinished =>
      tournament.isEmpty ? null : (path: '/tournaments/$tournament', go: false),
    NotificationType.seasonEnd => (
      path: '/season/summary?n=${n.number('season')}',
      go: false,
    ),
    NotificationType.levelUp => (path: '/profile', go: true),
    // The row itself is the whole message.
    NotificationType.moderationWarning || NotificationType.unknown => null,
  };
}

/// Whether a challenge can still be joined.
bool challengeOpen(AppNotification n, DateTime now) {
  final expires = n.time('expiresAt');
  return expires == null || expires.isAfter(now);
}

/// The challenged room's clock; rows from before ADR-044 were rapid.
TimeControl challengeControl(AppNotification n) =>
    timeControlNamed(n.data['timeControl']) ?? TimeControl.rapid;

/// Joins the challenger's room (as 6.1 "Qoşul" does) before opening it.
void joinChallenge(WidgetRef ref, AppNotification n) {
  ref
      .read(socialSocketProvider.notifier)
      .joinRoom(
        n.text('code'),
        variant:
            n.text('variant') == Variant.longNard.name
                ? Variant.longNard
                : Variant.shortNard,
        matchLength:
            n.number('matchLength') > 0 ? n.number('matchLength') : null,
        timeControl: challengeControl(n),
      );
}
