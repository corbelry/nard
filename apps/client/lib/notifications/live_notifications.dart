import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nard_protocol/nard_protocol.dart';

import '../online/game_socket.dart';
import '../online/online_game_controller.dart';
import '../seasons/season_providers.dart';
import '../social/social_socket.dart';
import '../tournaments/tournament_providers.dart';
import 'notification_models.dart';
import 'notification_providers.dart';

/// Live events on the shared game-server socket (ADR-049): `notification`
/// (an inbox row just written for me) and `tournament.updated`. The state
/// is the row to show as an in-app banner (null = none).
///
/// While the app is in the foreground and signed in, [TabShell] keeps the
/// socket open ([foreground]) so these arrive at once; in the background
/// it closes an idle socket ([background]). Without a socket everything
/// still works: the bell polls the inbox and tournament screens poll.
class LiveNotifications extends Notifier<AppNotification?> {
  GameSocket? _bound;
  StreamSubscription<Envelope>? _sub;

  @override
  AppNotification? build() {
    ref.onDispose(() => unawaited(_sub?.cancel()));
    return null;
  }

  GameSocket _socket() {
    final s = ref.read(onlineGameProvider.notifier).socket();
    if (!identical(s, _bound)) {
      unawaited(_sub?.cancel());
      _bound = s;
      _sub = s.messages.listen(onMessage);
    }
    return s;
  }

  /// Opens the socket if needed (app in the foreground, signed in).
  void foreground() {
    final s = _socket();
    if (s.current == SocketStatus.offline) unawaited(s.open());
  }

  /// Closes the socket when nothing needs it (no search, match or room).
  /// Being connected counts as present for tournament matches (ADR-038),
  /// so a backgrounded app must not look present.
  void background() {
    final s = _bound;
    if (s == null || s.current == SocketStatus.offline) return;
    final lobby = ref.read(lobbyProvider).phase;
    final room = ref.read(socialSocketProvider).phase;
    final idle =
        (lobby == LobbyPhase.idle || lobby == LobbyPhase.finished) &&
        room == RoomPhase.idle;
    if (idle) unawaited(s.close());
  }

  /// Signed out or switched accounts: the socket speaks for the previous
  /// account, so it is closed ([foreground] opens it with a new ticket).
  void accountChanged() {
    final s = _bound;
    if (s != null && s.current != SocketStatus.offline) unawaited(s.close());
    state = null;
  }

  /// Handles one server message (the socket listener; tests call it).
  void onMessage(Envelope msg) {
    switch (msg.type) {
      case MessageType.notification:
        final AppNotification n;
        try {
          n = AppNotification.fromJson(msg.payload);
        } on Object {
          return; // Malformed: the inbox poll still has it.
        }
        ref.read(inboxProvider.notifier).receive(n);
        _refreshFor(n);
        if (showsBanner(n.type)) state = n;
      case MessageType.tournamentUpdated:
        try {
          _refreshTournament(
            TournamentUpdatedPayload.fromJson(msg.payload).tournamentId,
          );
        } on ProtocolException {
          // Malformed: the screens still poll.
        }
      default:
        break;
    }
  }

  /// Rows that also pop up as a banner; a level-up is earned with the app
  /// open (its own screen), unknown types stay in the inbox.
  static bool showsBanner(NotificationType t) =>
      t != NotificationType.levelUp && t != NotificationType.unknown;

  void _refreshFor(AppNotification n) {
    final tournament = n.text('tournamentId');
    if (tournament.isNotEmpty) _refreshTournament(tournament);
    if (n.type == NotificationType.seasonEnd ||
        n.type == NotificationType.seasonStarted) {
      ref
        ..invalidate(seasonProvider)
        ..invalidate(seasonSummaryPromptProvider);
    }
  }

  void _refreshTournament(String id) {
    ref
      ..invalidate(tournamentDetailProvider(id))
      ..invalidate(tournamentListProvider)
      ..invalidate(homeTournamentProvider)
      ..invalidate(sngTablesProvider);
  }

  /// The banner was shown, tapped or swiped away.
  void dismiss() => state = null;
}

final liveNotificationsProvider =
    NotifierProvider<LiveNotifications, AppNotification?>(
      LiveNotifications.new,
    );
