import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nard_client/app/providers.dart';
import 'package:nard_client/data/app_settings.dart';
import 'package:nard_client/game/game_controller.dart';
import 'package:nard_client/l10n/gen/app_localizations.dart';
import 'package:nard_client/online/account.dart';
import 'package:nard_client/online/api_client.dart';
import 'package:nard_client/online/online_draft.dart';
import 'package:nard_client/online/online_game_controller.dart';
import 'package:nard_client/screens/online/online_setup_screen.dart';
import 'package:nard_client/screens/online/searching_screen.dart';
import 'package:nard_client/theme/nard_colors.dart';
import 'package:nard_client/theme/nard_theme.dart';
import 'package:nard_core/nard_core.dart' show Variant;
import 'package:nard_protocol/nard_protocol.dart';

import 'store_fakes.dart';

/// Records `queue.join` requests instead of opening a socket.
class _RecordingGame extends OnlineGameController {
  final requests = <QueueJoinPayload>[];

  @override
  GameView? build() => null;

  @override
  Future<void> search(QueueJoinPayload request) async => requests.add(request);
}

class _FixedLobby extends LobbyNotifier {
  _FixedLobby(this.value);

  final Lobby value;

  @override
  Lobby build() => value;
}

void main() {
  Future<void> pump(
    WidgetTester tester,
    String location,
    List<Override> overrides,
  ) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(path: '/setup', builder: (_, _) => const OnlineSetupScreen()),
        GoRoute(path: '/online/search', builder: (_, _) => const Placeholder()),
        GoRoute(path: '/search', builder: (_, _) => const SearchingScreen()),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountProvider.overrideWith(SignedIn.new),
          apiClientProvider.overrideWithValue(ApiClient('http://test')),
          currentSettingsProvider.overrideWithValue(const AppSettings()),
          ...overrides,
        ],
        child: MaterialApp.router(
          theme: NardTheme.build(NardColors.defaultTheme),
          locale: const Locale('az'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('2.2 time tiles: Blits/Sürətli/Klassik selectable, Gündəlik '
      'soon; the choice reaches queue.join (ADR-044)', (tester) async {
    final game = _RecordingGame();
    await pump(tester, '/setup', [onlineGameProvider.overrideWith(() => game)]);
    for (final text in [
      'Blits',
      '1 dəq + 8s',
      'Sürətli',
      '3 dəq + 12s',
      'Klassik',
      '5 dəq + 15s',
      'Gündəlik',
      'Tezliklə',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    final container = ProviderScope.containerOf(
      tester.element(find.byType(OnlineSetupScreen)),
    );
    expect(container.read(onlineDraftProvider).timeControl, TimeControl.rapid);

    // Gündəlik is not selectable yet.
    await tester.tap(find.text('Gündəlik'));
    await tester.pump();
    expect(container.read(onlineDraftProvider).timeControl, TimeControl.rapid);

    await tester.tap(find.text('Blits'));
    await tester.pump();
    expect(container.read(onlineDraftProvider).timeControl, TimeControl.blitz);
    // Other edits keep the chosen control.
    await tester.tap(find.text('3 xal'));
    await tester.pump();
    expect(container.read(onlineDraftProvider).timeControl, TimeControl.blitz);

    await tester.tap(find.text('Rəqib axtar'));
    await tester.pumpAndSettle();
    final sent = game.requests.single;
    expect(sent.timeControl, TimeControl.blitz);
    expect(sent.matchLength, 3);
    expect(sent.toJson()['timeControl'], 'blitz');

    // The draft stays in memory for the next visit.
    expect(container.read(onlineDraftProvider).timeControl, TimeControl.blitz);
    await close(tester);
  });

  testWidgets('2.4 searching shows the chosen control', (tester) async {
    await pump(tester, '/search', [
      lobbyProvider.overrideWith(
        () => _FixedLobby(
          Lobby(
            phase: LobbyPhase.searching,
            request: const QueueJoinPayload(
              variant: Variant.shortNard,
              matchLength: 1,
              mode: QueueMode.casual,
              timeControl: TimeControl.classic,
            ),
            searchStartedAt: DateTime.now(),
          ),
        ),
      ),
    ]);
    expect(find.text('5+15s'), findsOneWidget);
    expect(find.text('3+12s'), findsNothing);
    await close(tester);
  });
}
