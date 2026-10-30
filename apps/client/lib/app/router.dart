import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nard_protocol/nard_protocol.dart'
    show TournamentReadyStatePayload, TournamentWalkoverPayload;

import '../analysis/analysis_screen.dart';
import '../clans/clan_leaderboard_screen.dart';
import '../clans/clan_members_screen.dart';
import '../clans/clan_models.dart' show Emblem;
import '../clans/clan_profile_screen.dart';
import '../clans/clan_search_screen.dart';
import '../clans/create_clan_screen.dart';
import '../clans/emblem_builder_screen.dart';
import '../cosmetics/locker_screen.dart';
import '../game/game_screen.dart';
import '../notifications/inbox_screen.dart';
import '../notifications/notification_settings_screen.dart';
import '../notifications/push_prompt_screen.dart';
import '../progression/achievements_screen.dart';
import '../progression/level_up_screen.dart';
import '../progression/missions_screen.dart';
import '../puzzles/puzzle_screen.dart';
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
import '../seasons/leaderboard_screen.dart';
import '../seasons/season_pass_screen.dart';
import '../seasons/season_summary_screen.dart';
import '../social/add_friend_screen.dart';
import '../social/friends_screen.dart';
import '../social/player_menu.dart';
import '../social/room_screen.dart';
import '../store/purchase_flow.dart';
import '../store/store_screen.dart';
import '../tournaments/bracket_screen.dart';
import '../tournaments/private_tournament_screen.dart';
import '../tournaments/sng_screen.dart';
import '../tournaments/standings_screen.dart';
import '../tournaments/tournament_detail_screen.dart';
import '../tournaments/tournament_list_screen.dart';
import '../tournaments/tournament_models.dart' show Tournament;
import '../tournaments/tournament_outcomes.dart';
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
          // Phase 6: Turnirlər tab (tournaments.md §1, TabBar.dc.html).
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tournaments',
                builder: (_, _) => const TournamentsTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/clan', builder: (_, _) => const ClanTab()),
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
      // Notifications (16.x, notifications.md §6).
      GoRoute(
        path: '/settings/notifications',
        builder: (_, _) => const NotificationSettingsScreen(),
      ),
      GoRoute(path: '/notifications', builder: (_, _) => const InboxScreen()),
      GoRoute(
        path: '/push-prompt',
        pageBuilder: (_, s) => _fade(s, const PushPromptScreen()),
      ),
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
      // Phase 5: friends, rooms, spectating, reports (social.md §8).
      GoRoute(path: '/friends', builder: (_, _) => const FriendsScreen()),
      GoRoute(path: '/friends/add', builder: (_, _) => const AddFriendScreen()),
      GoRoute(
        path: '/friends/blocked',
        builder: (_, _) => const BlockedScreen(),
      ),
      GoRoute(path: '/room', builder: (_, _) => const RoomScreen()),
      GoRoute(
        path: '/room/join',
        builder: (_, s) => JoinRoomScreen(code: s.uri.queryParameters['code']),
      ),
      GoRoute(
        path: '/spectate',
        pageBuilder: (_, s) => _fade(s, const GameScreen(spectator: true)),
      ),
      GoRoute(
        path: '/report',
        builder:
            (_, s) =>
                s.extra is ReportArgs
                    ? ReportScreen(args: s.extra! as ReportArgs)
                    : const _Missing(),
      ),
      GoRoute(
        path: '/report/sent',
        builder: (_, s) {
          final extra = s.extra;
          return extra is ({String name, bool blocked})
              ? ReportSentScreen(name: extra.name, blocked: extra.blocked)
              : const _Missing();
        },
      ),
      // Clans (5.x, 19.x); the Klan tab root is `/clan`.
      GoRoute(
        path: '/clans/create',
        builder: (_, _) => const CreateClanScreen(),
      ),
      GoRoute(
        path: '/clans/leaderboard',
        builder: (_, _) => const ClanLeaderboardScreen(),
      ),
      GoRoute(
        path: '/clans/emblem',
        builder:
            (_, s) => EmblemBuilderScreen(
              initial: s.extra is Emblem ? s.extra! as Emblem : const Emblem(),
            ),
      ),
      GoRoute(
        path: '/clans/:id',
        builder: (_, s) => ClanProfileScreen(clanId: s.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'members',
            builder:
                (_, s) => ClanMembersScreen(clanId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: 'requests',
            builder:
                (_, s) => ClanRequestsScreen(clanId: s.pathParameters['id']!),
          ),
        ],
      ),
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
        builder:
            (_, s) => ReplayScreen(
              id: int.parse(s.pathParameters['id']!),
              analysis: s.uri.queryParameters['analysis'] == '1',
            ),
      ),
      // Phase 6: tournaments, seasons, analysis, puzzles
      // (tournaments.md §14).
      GoRoute(
        path: '/tournaments/join',
        builder: (_, _) => const JoinTournamentScreen(),
      ),
      GoRoute(
        path: '/tournaments/private/new',
        builder: (_, _) => const CreatePrivateTournamentScreen(),
      ),
      GoRoute(
        path: '/tournaments/notfilled',
        builder:
            (_, s) =>
                s.extra is Tournament
                    ? NotFilledScreen(tournament: s.extra! as Tournament)
                    : const _Missing(),
      ),
      GoRoute(
        path: '/tournaments/:id',
        builder: (_, s) => TournamentDetailScreen(id: s.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'bracket',
            builder: (_, s) => BracketScreen(id: s.pathParameters['id']!),
          ),
          GoRoute(
            path: 'standings',
            builder: (_, s) => StandingsScreen(id: s.pathParameters['id']!),
          ),
          GoRoute(
            path: 'champion',
            builder: (_, s) => ChampionScreen(id: s.pathParameters['id']!),
          ),
          GoRoute(
            path: 'invite',
            builder:
                (_, s) => PrivateTournamentScreen(id: s.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/tournament/noshow',
        builder:
            (_, s) =>
                s.extra is TournamentReadyStatePayload
                    ? NoShowScreen(
                      state: s.extra! as TournamentReadyStatePayload,
                    )
                    : const _Missing(),
      ),
      GoRoute(
        path: '/tournament/walkover',
        builder:
            (_, s) =>
                s.extra is TournamentWalkoverPayload
                    ? WalkoverScreen(
                      walkover: s.extra! as TournamentWalkoverPayload,
                    )
                    : const _Missing(),
      ),
      GoRoute(
        path: '/sng',
        builder:
            (_, s) => SngScreen(
              size: int.tryParse(s.uri.queryParameters['size'] ?? ''),
            ),
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (_, _) => const LeaderboardScreen(),
      ),
      GoRoute(path: '/season', builder: (_, _) => const SeasonPassScreen()),
      GoRoute(
        path: '/season/summary',
        builder:
            (_, s) => SeasonSummaryScreen(
              number: int.tryParse(s.uri.queryParameters['n'] ?? ''),
            ),
      ),
      GoRoute(
        path: '/puzzles',
        builder:
            (_, s) =>
                PuzzleScreen(daily: s.uri.queryParameters['daily'] == '1'),
      ),
      GoRoute(
        path: '/analysis/match/:id',
        builder:
            (_, s) => MatchAnalysisScreen(matchId: s.pathParameters['id']!),
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
