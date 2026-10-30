import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../online/api_client.dart' show Account;
import '../progression/progress.dart';
import '../progression/streak_modal.dart';
import '../ui/background.dart';
import '../ui/layout.dart';

/// Tab roots: Əsas, Klan, Mağaza and Profil (Turnirlər stays hidden until
/// Phase 6, social.md §8). Runs the daily check-in once per app open while signed in and
/// shows the 12.2 streak modal when coins were credited.
class TabShell extends ConsumerStatefulWidget {
  const TabShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  ConsumerState<TabShell> createState() => _TabShellState();
}

class _TabShellState extends ConsumerState<TabShell> {
  @override
  void initState() {
    super.initState();
    ref.listenManual<AsyncValue<Account?>>(
      accountProvider,
      (_, next) => _maybeCheckIn(next.value),
      fireImmediately: true,
    );
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
