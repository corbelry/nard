import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../game/game_screen.dart';
import '../screens/ai_level_screen.dart';
import '../screens/home_screen.dart';
import '../screens/hotseat_setup_screen.dart';
import '../screens/language_screen.dart';
import '../screens/lesson_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/replay_list_screen.dart';
import '../screens/replay_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/setup_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/tab_shell.dart';

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
              GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const SettingsScreen(root: true),
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/setup', builder: (_, _) => const SetupScreen()),
      GoRoute(path: '/ai', builder: (_, _) => const AiLevelScreen()),
      GoRoute(path: '/hotseat', builder: (_, _) => const HotseatSetupScreen()),
      GoRoute(
        path: '/game',
        pageBuilder: (_, s) => _fade(s, const GameScreen()),
      ),
      GoRoute(path: '/replays', builder: (_, _) => const ReplayListScreen()),
      GoRoute(
        path: '/replay/:id',
        builder: (_, s) => ReplayScreen(id: int.parse(s.pathParameters['id']!)),
      ),
    ],
  );
});
