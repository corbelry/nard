import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../cosmetics/locker_screen.dart';
import '../game/game_screen.dart';
import '../progression/achievements_screen.dart';
import '../progression/level_up_screen.dart';
import '../progression/missions_screen.dart';
import '../screens/ai_level_screen.dart';
import '../screens/home_screen.dart';
import '../screens/hotseat_setup_screen.dart';
import '../screens/language_screen.dart';
import '../screens/lesson_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/online/account_screen.dart';
import '../screens/online/code_screen.dart';
import '../screens/online/email_screen.dart';
import '../screens/online/fair_dice_screen.dart';
import '../screens/online/online_setup_screen.dart';
import '../screens/online/profile_screen.dart';
import '../screens/online/searching_screen.dart';
import '../screens/online/sign_in_screen.dart';
import '../screens/online/versus_screen.dart';
import '../screens/replay_list_screen.dart';
import '../screens/replay_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/setup_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/tab_shell.dart';
import '../store/purchase_flow.dart';
import '../store/store_screen.dart';
import '../ui/background.dart';

Page<void> _fade(GoRouterState state, Widget child) => CustomTransitionPage(
  key: state.pageKey,
  child: child,
  transitionsBuilder:
      (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
);

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (_, s) => _fade(s, const SplashScreen()),
      ),
      GoRoute(
        path: '/language',
        pageBuilder:
            (_, s) => _fade(
              s,
              LanguageScreen(
                fromSettings: s.uri.queryParameters['settings'] == '1',
              ),
            ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (_, s) => _fade(s, const OnboardingScreen()),
      ),
      GoRoute(path: '/lesson', builder: (_, _) => const LessonScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => TabShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, _) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'missions',
                    builder:
                        (_, _) => const NardBackground(child: MissionsScreen()),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/store',
                builder: (_, _) => const StoreScreen(),
                routes: [
                  GoRoute(
                    path: 'locker',
                    builder:
                        (_, s) => NardBackground(
                          child: LockerScreen(
                            category: s.uri.queryParameters['category'],
                          ),
                        ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'achievements',
                    builder:
                        (_, _) =>
                            const NardBackground(child: AchievementsScreen()),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/setup', builder: (_, _) => const SetupScreen()),
      GoRoute(
        path: '/online/setup',
        builder: (_, _) => const OnlineSetupScreen(),
      ),
      // Auth flow (17.x): each screen pops `true` once signed in.
      GoRoute(path: '/signin', builder: (_, _) => const SignInScreen()),
      GoRoute(path: '/signin/email', builder: (_, _) => const EmailScreen()),
      GoRoute(
        path: '/signin/code',
        builder:
            (_, s) => CodeScreen(email: s.uri.queryParameters['email'] ?? ''),
      ),
      GoRoute(
        path: '/online/search',
        pageBuilder: (_, s) => _fade(s, const SearchingScreen()),
      ),
      GoRoute(
        path: '/online/vs',
        pageBuilder: (_, s) => _fade(s, const VersusScreen()),
      ),
      GoRoute(path: '/online/fair', builder: (_, _) => const FairDiceScreen()),
      GoRoute(path: '/account', builder: (_, _) => const AccountScreen()),
      GoRoute(path: '/ai', builder: (_, _) => const AiLevelScreen()),
      GoRoute(path: '/hotseat', builder: (_, _) => const HotseatSetupScreen()),
      GoRoute(
        path: '/game',
        pageBuilder:
            (_, s) => _fade(
              s,
              GameScreen(online: s.uri.queryParameters['online'] == '1'),
            ),
      ),
      GoRoute(path: '/replays', builder: (_, _) => const ReplayListScreen()),
      // 7.5 and 12.3 cover the tab bar.
      GoRoute(
        path: '/purchased',
        builder:
            (_, s) =>
                s.extra is PurchaseOutcome
                    ? PurchaseSuccessScreen(
                      outcome: s.extra! as PurchaseOutcome,
                    )
                    : const _Missing(),
      ),
      GoRoute(
        path: '/levelup',
        builder:
            (_, s) =>
                s.extra is LevelUpArgs
                    ? LevelUpScreen(args: s.extra! as LevelUpArgs)
                    : const _Missing(),
      ),
      GoRoute(
        path: '/replay/:id',
        builder: (_, s) => ReplayScreen(id: int.parse(s.pathParameters['id']!)),
      ),
    ],
  );
});

/// A route opened without its arguments (e.g. restored): back to Home.
class _Missing extends StatelessWidget {
  const _Missing();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go('/home');
    });
    return const Scaffold(body: NardBackground(child: SizedBox.expand()));
  }
}
