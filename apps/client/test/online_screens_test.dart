import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nard_client/app/providers.dart';
import 'package:nard_client/data/app_settings.dart';
import 'package:nard_client/game/game_controller.dart';
import 'package:nard_client/game/game_screen.dart';
import 'package:nard_client/game/match_setup.dart';
import 'package:nard_client/game/online_overlays.dart';
import 'package:nard_client/game/session.dart';
import 'package:nard_client/l10n/gen/app_localizations.dart';
import 'package:nard_client/online/account.dart';
import 'package:nard_client/online/api_client.dart';
import 'package:nard_client/online/match_history.dart';
import 'package:nard_client/online/online_game_controller.dart';
import 'package:nard_client/screens/online/account_screen.dart';
import 'package:nard_client/screens/online/fair_dice_screen.dart';
import 'package:nard_client/screens/online/online_setup_screen.dart';
import 'package:nard_client/screens/online/profile_screen.dart';
import 'package:nard_client/screens/online/searching_screen.dart';
import 'package:nard_client/screens/online/versus_screen.dart';
import 'package:nard_client/theme/nard_colors.dart';
import 'package:nard_client/theme/nard_theme.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';

const _account = Account(
  id: '1',
  name: 'Elvin',
  guest: false,
  email: 'elvin@mail.az',
  country: 'AZ',
  ratings: {
    'shortNard': RatingInfo(
      rating: 1866,
      peak: 1900,
      matches: 40,
      wins: 23,
      tier: 'platinum',
    ),
  },
);

class _SignedIn extends AccountNotifier {
  @override
  Future<Account?> build() async => _account;
}

class _FixedLobby extends LobbyNotifier {
  _FixedLobby(this.value);

  final Lobby value;

  @override
  Lobby build() => value;
}

class _FixedGame extends OnlineGameController {
  _FixedGame(this.value);

  final GameView? value;

  @override
  GameView? build() => value;
}

MatchFoundPayload _found({bool bot = false}) => MatchFoundPayload(
  matchId: 'm',
  variant: Variant.shortNard,
  matchLength: 5,
  mode: bot ? QueueMode.casual : QueueMode.ranked,
  you: Side.black,
  white: PlayerInfo(
    userId: '2',
    name: bot ? 'bot' : 'Nigar',
    rating: bot ? null : 1790,
    country: 'TR',
    bot: bot,
  ),
  black: const PlayerInfo(userId: '1', name: 'Elvin', rating: 1866),
  clock: ClockConfig.standard,
);

GameView _view({
  String? serverSeed,
  bool opponentConnected = true,
  bool connected = true,
}) {
  final found = _found();
  final setup = MatchSetup(
    variant: found.variant,
    opponent: OpponentKind.online,
    matchLength: found.matchLength,
    localSide: Side.black,
    online: OnlineMatch(
      matchId: 'm',
      mode: found.mode,
      white: found.white,
      black: found.black,
      clock: found.clock,
    ),
  );
  const seed = 'f00d';
  final dice = FairDice(serverSeed: seed, clientSeedA: 'a', clientSeedB: 'b');
  var record = GameRecord(variant: Variant.shortNard);
  while (true) {
    final r = dice.roll();
    record = record.add(OpeningRoll(r.die1, r.die2));
    if (r.die1 != r.die2) break;
  }
  return GameView(
    session: Session.fromServer(
      setup: setup,
      match: MatchState.start(length: 5),
      record: record,
    ),
    online: OnlineExtras(
      clock: const ClockState(
        whiteMs: 180000,
        blackMs: 180000,
        delayMs: 12000,
        sentAt: 0,
      ),
      commitment: FairDice.commitment(seed),
      serverSeed: serverSeed,
      clientSeeds: const {Side.white: 'a', Side.black: 'b'},
      opponentConnected: opponentConnected,
      reconnectDeadline: opponentConnected ? null : 42000,
      connected: connected,
      receivedAt: DateTime.now(),
    ),
  );
}

Future<void> _show(
  WidgetTester tester,
  Widget screen, {
  Lobby lobby = const Lobby(),
  GameView? game,
}) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        accountProvider.overrideWith(_SignedIn.new),
        apiClientProvider.overrideWithValue(ApiClient('http://test')),
        currentSettingsProvider.overrideWithValue(const AppSettings()),
        lobbyProvider.overrideWith(() => _FixedLobby(lobby)),
        onlineGameProvider.overrideWith(() => _FixedGame(game)),
        matchHistoryProvider.overrideWith(
          (ref) async => [
            HistoryEntry(
              id: '1',
              variant: Variant.shortNard,
              matchLength: 5,
              ranked: true,
              opponentName: 'Nigar',
              opponentBot: false,
              won: true,
              myScore: 5,
              opponentScore: 2,
              endedAt: DateTime.now(),
              ratingBefore: 1842,
              ratingAfter: 1866,
            ),
          ],
        ),
      ],
      child: MaterialApp(
        theme: NardTheme.build(NardColors.defaultTheme),
        locale: const Locale('az'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: screen,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('8.1 profile shows rank, stats and history', (tester) async {
    await _show(tester, const Scaffold(body: ProfileScreen()));
    expect(find.text('Elvin'), findsOneWidget);
    expect(find.text('Platin I · 1866'), findsOneWidget);
    expect(find.text('58%'), findsOneWidget);
    expect(find.text('5–2'), findsOneWidget);
    expect(find.text('+24'), findsOneWidget);
    await _close(tester);
  });

  testWidgets('15.1 account rows', (tester) async {
    await _show(tester, const AccountScreen());
    expect(find.text('elvin@mail.az'), findsOneWidget);
    expect(find.text('Hesabı sil'), findsOneWidget);
    await _close(tester);
  });

  testWidgets('2.2 online setup and 2.4 searching render', (tester) async {
    await _show(tester, const OnlineSetupScreen());
    expect(find.text('Rəqib axtar'), findsOneWidget);
    await _close(tester);
    await _show(
      tester,
      const SearchingScreen(),
      lobby: Lobby(
        phase: LobbyPhase.searching,
        request: const QueueJoinPayload(
          variant: Variant.shortNard,
          matchLength: 5,
          mode: QueueMode.ranked,
        ),
        searchStartedAt: DateTime.now(),
      ),
    );
    expect(find.text('Rəqib axtarılır…'), findsOneWidget);
    expect(find.text('1816–1916'), findsOneWidget);
    await _close(tester);
  });

  testWidgets('2.5 VS and 20.1 VS bot render', (tester) async {
    await _show(
      tester,
      const VersusScreen(),
      lobby: Lobby(phase: LobbyPhase.found, match: _found()),
    );
    expect(find.text('Nigar'), findsOneWidget);
    expect(find.textContaining('REYTİNQLİ'), findsOneWidget);
    await _close(tester);
    await _show(
      tester,
      const VersusScreen(),
      lobby: Lobby(phase: LobbyPhase.found, match: _found(bot: true)),
    );
    expect(find.text('Kompüter · Orta'), findsOneWidget);
    expect(find.text('BOT'), findsOneWidget);
    await _close(tester);
  });

  testWidgets('10.3 fair dice: pending before the reveal, match after', (
    tester,
  ) async {
    await _show(tester, const FairDiceScreen(), game: _view());
    expect(find.text('Oyundan sonra açılacaq'), findsOneWidget);
    await _close(tester);
    await _show(
      tester,
      const FairDiceScreen(),
      game: _view(serverSeed: 'f00d'),
    );
    expect(find.textContaining('Uyğundur'), findsOneWidget);
    await _close(tester);
  });

  testWidgets('game screen: opponent reconnecting and own connection lost', (
    tester,
  ) async {
    await _show(
      tester,
      const GameScreen(online: true),
      game: _view(opponentConnected: false),
    );
    expect(find.text('Nigar yenidən qoşulur…'), findsOneWidget);
    expect(find.textContaining('0:42 qaldı'), findsOneWidget);
    expect(find.text('Oflayn'), findsOneWidget);
    expect(find.text('Rəqibin bağlantısı kəsildi'), findsOneWidget);
    await _close(tester);
    await _show(
      tester,
      const GameScreen(online: true),
      game: _view(connected: false),
    );
    expect(find.text('Bağlantı bərpa olunur…'), findsOneWidget);
    expect(find.text('Bağlantı kəsildi'), findsOneWidget);
    await _close(tester);
  });

  testWidgets('2.6 rating card counts up to the new rating', (tester) async {
    await _show(
      tester,
      const Scaffold(
        body: Center(child: RatingCard(before: 1842, after: 1866)),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('+24'), findsOneWidget);
    expect(find.text('1866'), findsOneWidget);
    expect(find.text('1842 idi'), findsOneWidget);
    expect(find.text('Almaz III üçün 34 xal qaldı'), findsOneWidget);
    await _close(tester);
  });
}
