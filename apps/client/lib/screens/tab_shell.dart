import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/gen/app_localizations.dart';
import '../moderation/moderation.dart';
import '../notifications/live_notifications.dart';
import '../online/account.dart';
import '../online/api_client.dart' show Account;
import '../online/online_game_controller.dart';
import '../progression/progress.dart';
import '../progression/streak_modal.dart';
import '../tournaments/tournament_providers.dart';
import '../ui/background.dart';
import '../ui/layout.dart';

/// Tab roots: Əsas, Turnirlər, Klan, Mağaza and Profil (tournaments.md
/// §13). Runs the daily check-in once per app open while signed in and
/// shows the 12.2 streak modal when coins were credited. Assigned
/// tournament matches open VS (2.5) and walkovers 21.3 from any screen.
/// While signed in and in the foreground it keeps the game-server socket
/// open for live notifications (ADR-049); in the background an idle
/// socket is closed.
class TabShell extends ConsumerStatefulWidget {
  const TabShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  ConsumerState<TabShell> createState() => _TabShellState();
}

class _TabShellState extends ConsumerState<TabShell> {
  AppLifecycleListener? _lifecycle;
  String? _accountId;

  @override
  void initState() {
    super.initState();
    ref.listenManual<AsyncValue<Account?>>(
      accountProvider,
      (_, next) => _onAccount(next.value),
      fireImmediately: true,
    );
    _lifecycle = AppLifecycleListener(
      onResume: _goLive,
      onPause: () => ref.read(liveNotificationsProvider.notifier).background(),
    );
    ref.listenManual<Lobby>(lobbyProvider, (prev, next) {
      final found = next.phase == LobbyPhase.found;
      final tournament = next.match?.tournamentId != null;
      if (found && tournament && prev?.phase != LobbyPhase.found && mounted) {
        unawaited(GoRouter.of(context).push('/online/vs'));
      }
    });
    ref.listenManual<TournamentLive>(tournamentSocketProvider, (_, next) {
      if (next.walkovers.isEmpty) return;
      // A screen showing the match (21.2) may take it in this frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final pending = ref.read(tournamentSocketProvider).walkovers;
        if (pending.isEmpty) return;
        final w = pending.first;
        ref.read(tournamentSocketProvider.notifier).consumeWalkover(w.matchId);
        final r = ref.read(tournamentSocketProvider).ready[w.matchId];
        if (w.winner != null && (r == null || r.you == w.winner)) {
          unawaited(
            GoRouter.of(context).push('/tournament/walkover', extra: w),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    super.dispose();
  }

  void _onAccount(Account? account) {
    final id = account?.id;
    // Another account (or none): the socket was authenticated as the
    // previous one.
    if (_accountId != null && id != _accountId) {
      ref.read(liveNotificationsProvider.notifier).accountChanged();
    }
    _accountId = id;
    _maybeCheckIn(account);
    _goLive();
  }

  /// Opens the shared socket for live notifications when signed in and
  /// not banned (a banned account gets no ticket).
  void _goLive() {
    if (ref.read(accountProvider).value == null) return;
    if (ref.read(banProvider) != null) return;
    ref.read(liveNotificationsProvider.notifier).foreground();
  }

  void _maybeCheckIn(Account? account) {
    if (account == null) return;
    if (!ref.read(checkInGateProvider.notifier).claim(account.id)) return;
    unawaited(_checkIn());
  }

  Future<void> _checkIn() async {
    final result = await ref.read(progressProvider.notifier).checkIn();
    if (result == null || !mounted) return;
    final rewards = ref.read(progressProvider).value?.streak.rewards ?? [];
    await showStreakModal(
      context,
      streakDay: result.streak,
      coins: result.coins,
      rewards: rewards,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final shell = widget.shell;
    return Scaffold(
      body: NardBackground(child: shell),
      bottomNavigationBar: NardTabBar(
        tabs: [
          NardTab(LucideIcons.home, l.tabHome),
          NardTab(LucideIcons.trophy, l.tabTournaments),
          NardTab(LucideIcons.shield, l.tabClan),
          NardTab(LucideIcons.shoppingBag, l.tabStore),
          NardTab(LucideIcons.user, l.tabProfile),
        ],
        index: shell.currentIndex,
        onTap:
            (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
      ),
    );
  }
}
