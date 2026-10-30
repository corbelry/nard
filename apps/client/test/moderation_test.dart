import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nard_client/app/providers.dart';
import 'package:nard_client/data/app_settings.dart';
import 'package:nard_client/l10n/gen/app_localizations.dart';
import 'package:nard_client/moderation/banned_screen.dart';
import 'package:nard_client/moderation/moderation.dart';
import 'package:nard_client/notifications/inbox_screen.dart';
import 'package:nard_client/notifications/notification_models.dart';
import 'package:nard_client/notifications/notification_providers.dart';
import 'package:nard_client/notifications/notification_text.dart';
import 'package:nard_client/online/account.dart';
import 'package:nard_client/online/api_client.dart';
import 'package:nard_client/online/online_game_controller.dart';
import 'package:nard_client/screens/online/searching_screen.dart';
import 'package:nard_client/theme/nard_colors.dart';
import 'package:nard_client/theme/nard_theme.dart';
import 'package:nard_core/nard_core.dart' show Variant;
import 'package:nard_protocol/nard_protocol.dart';

import 'store_fakes.dart';

/// Keeps the token in memory instead of the platform keychain.
class _MemoryStore extends CredentialStore {
  _MemoryStore([this.saved]);

  String? saved;

  @override
  Future<String?> token() async => saved;

  @override
  Future<void> saveToken(String? token) async => saved = token;

  @override
  Future<String> deviceId() async => 'device-1';
}

/// Every call answers `403 {code: banned, until}` (ADR-042).
ApiClient _bannedApi(List<String> calls, {String? until}) => ApiClient(
  'http://test',
  client: MockClient((req) async {
    calls.add('${req.method} ${req.url.path}');
    return http.Response(
      jsonEncode({'code': 'banned', 'until': until}),
      403,
      headers: {'content-type': 'application/json'},
    );
  }),
);

const _ranked = QueueJoinPayload(
  variant: Variant.shortNard,
  matchLength: 5,
  mode: QueueMode.ranked,
);

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Widget _app(ProviderContainer container, GoRouter router) =>
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: NardTheme.build(NardColors.defaultTheme),
        locale: const Locale('az'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: router,
        // Same wiring as NardApp.
        builder:
            (context, child) => BannedGate(
              onSignedOut: () => router.go('/home'),
              child: child!,
            ),
      ),
    );

GoRouter _router() {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Center(child: Text('start'))),
      ),
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Center(child: Text('home'))),
      ),
    ],
  );
  addTearDown(router.dispose);
  return router;
}

class _FixedLobby extends LobbyNotifier {
  _FixedLobby(this.value);

  final Lobby value;

  @override
  Lobby build() => value;
}

class _InboxApi extends FakeApi {
  @override
  Future<InboxPage> notifications({int? after}) async => InboxPage(
    unread: 1,
    items: [
      AppNotification(
        id: 1,
        type: NotificationType.moderationWarning,
        data: const {'reason': 'Söhbətdə təhqir'},
        createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
    ],
  );
}

void main() {
  group('banned interceptor', () {
    test('a 403 banned answer records the ban and emits it', () async {
      final calls = <String>[];
      final api = _bannedApi(calls, until: '2030-01-02T12:00:00+00:00')
        ..token = 'tok';
      final seen = <AccountBan>[];
      final sub = api.bans.listen(seen.add);
      await expectLater(
        api.me(),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', 'banned')
              .having(
                (e) => e.until?.toUtc(),
                'until',
                DateTime.utc(2030, 1, 2, 12),
              ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(api.ban?.until?.toUtc(), DateTime.utc(2030, 1, 2, 12));
      expect(seen.single.permanent, isFalse);
      api.clearBan();
      expect(api.ban, isNull);
      await sub.cancel();
    });

    test('late answers for dropped credentials are ignored', () async {
      final api = ApiClient(
        'http://test',
        client: MockClient((req) async {
          await Future<void>.delayed(const Duration(milliseconds: 5));
          return http.Response(jsonEncode({'code': 'banned'}), 403);
        }),
      )..token = 'old';
      final pending = api.me();
      api.token = null; // signed out meanwhile
      await expectLater(pending, throwsA(isA<ApiException>()));
      expect(api.ban, isNull);
    });

    testWidgets('banned at start: full screen with the end date, sign out', (
      tester,
    ) async {
      _phone(tester);
      final calls = <String>[];
      final store = _MemoryStore('tok');
      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(
            _bannedApi(calls, until: '2030-01-02T12:00:00+00:00'),
          ),
          credentialStoreProvider.overrideWithValue(store),
        ],
      );
      addTearDown(container.dispose);
      final router = _router();
      await tester.pumpWidget(_app(container, router));
      // The account loads `/me`, which is refused.
      container.listen(accountProvider, (_, _) {});
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      expect(calls, contains('GET /api/v1/me'));
      expect(find.text('Hesab dayandırılıb'), findsOneWidget);
      expect(find.textContaining('2030'), findsOneWidget);
      expect(find.textContaining(kSupportEmail), findsOneWidget);

      await tester.tap(find.text('Hesabdan çıx'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(store.saved, isNull);
      expect(container.read(banProvider), isNull);
      expect(find.text('Hesab dayandırılıb'), findsNothing);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('a refused guest sign-in shows the permanent ban', (
      tester,
    ) async {
      _phone(tester);
      final calls = <String>[];
      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(_bannedApi(calls)),
          credentialStoreProvider.overrideWithValue(_MemoryStore()),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(_app(container, _router()));
      expect(find.text('start'), findsOneWidget);
      await container.read(accountProvider.future);
      await expectLater(
        container.read(accountProvider.notifier).signInAsGuest('az'),
        throwsA(isA<ApiException>()),
      );
      await tester.pump();
      expect(calls, contains('POST /api/v1/auth/guest'));
      expect(find.text('Hesab dayandırılıb'), findsOneWidget);
      expect(find.textContaining('müddətsiz'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an expired ban offers to continue', (tester) async {
      _phone(tester);
      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(ApiClient('http://test')),
          credentialStoreProvider.overrideWithValue(_MemoryStore()),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: NardTheme.build(NardColors.defaultTheme),
            locale: const Locale('az'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: BannedScreen(
              ban: AccountBan(
                until: DateTime.now().subtract(const Duration(minutes: 1)),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Məhdudiyyət bitdi'), findsOneWidget);
      expect(find.text('Davam et'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('queue cooldown', () {
    test('queue_cooldown error and a known cooldown stop the search', () async {
      final container = ProviderContainer(
        overrides: [
          currentSettingsProvider.overrideWithValue(const AppSettings()),
        ],
      );
      addTearDown(container.dispose);
      final until = DateTime.now().add(const Duration(hours: 2));
      container
          .read(lobbyProvider.notifier)
          .set(
            Lobby(
              phase: LobbyPhase.searching,
              request: _ranked,
              searchStartedAt: DateTime.now(),
            ),
          );
      final game = container.read(onlineGameProvider.notifier);
      game.receive(
        Envelope(
          type: MessageType.error,
          id: 'q1',
          ts: 0,
          payload:
              ErrorPayload(
                code: ErrorCode.queueCooldown,
                message: '${until.millisecondsSinceEpoch ~/ 1000}',
              ).toJson(),
        ),
      );
      var lobby = container.read(lobbyProvider);
      expect(lobby.phase, LobbyPhase.idle);
      expect(lobby.request, _ranked);
      expect(
        lobby.cooldownUntil?.millisecondsSinceEpoch,
        until.millisecondsSinceEpoch ~/ 1000 * 1000,
      );
      // Searching again shows the cooldown without opening the queue.
      container.read(lobbyProvider.notifier).set(const Lobby());
      await game.search(_ranked);
      lobby = container.read(lobbyProvider);
      expect(lobby.coolingDown(DateTime.now()), isTrue);
      expect(lobby.searchStartedAt, isNull);
    });

    test('the ticket carries queueCooldownUntil', () async {
      final api = ApiClient(
        'http://test',
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'ticket': 't',
              'queueCooldownUntil': '2030-01-02T12:00:00+00:00',
            }),
            200,
          ),
        ),
      );
      final t = await api.gameTicket();
      expect(t.ticket, 't');
      expect(t.queueCooldownUntil?.toUtc(), DateTime.utc(2030, 1, 2, 12));
    });

    Future<void> showSearching(WidgetTester tester, Lobby lobby) async {
      _phone(tester);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountProvider.overrideWith(SignedIn.new),
            apiClientProvider.overrideWithValue(ApiClient('http://test')),
            currentSettingsProvider.overrideWithValue(const AppSettings()),
            lobbyProvider.overrideWith(() => _FixedLobby(lobby)),
          ],
          child: MaterialApp(
            theme: NardTheme.build(NardColors.defaultTheme),
            locale: const Locale('az'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const SearchingScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    Future<void> close(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    }

    testWidgets('2.4 shows the time left instead of searching', (tester) async {
      await showSearching(
        tester,
        Lobby(
          request: _ranked,
          cooldownUntil: DateTime.now().add(
            const Duration(hours: 2, minutes: 5, seconds: 30),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Axtarış müvəqqəti bağlıdır'), findsOneWidget);
      expect(find.textContaining('02:05:'), findsOneWidget);
      expect(find.textContaining('Şəxsi otaqlar və turnirlər'), findsOneWidget);
      expect(find.text('Rəqib axtarılır…'), findsNothing);
      expect(find.text('Yenidən axtar'), findsNothing);
      await close(tester);
    });

    testWidgets('2.4 offers to search again once the cooldown ran out', (
      tester,
    ) async {
      await showSearching(
        tester,
        Lobby(
          request: _ranked,
          cooldownUntil: DateTime.now().subtract(const Duration(seconds: 1)),
        ),
      );
      expect(find.text('Növbə yenidən açıqdır.'), findsOneWidget);
      expect(find.text('Yenidən axtar'), findsOneWidget);
      await close(tester);
    });
  });

  group('moderation_warning', () {
    test('parses and renders title and reason', () {
      final n = AppNotification.fromJson({
        'id': 3,
        'type': 'moderation_warning',
        'data': {'reason': 'Spam'},
        'read': false,
        'createdAt': '2026-11-06T10:00:00+00:00',
      });
      expect(n.type, NotificationType.moderationWarning);
      expect(n.tab, InboxTab.all);
      expect(notificationLink(n), isNull);
      final en = lookupAppLocalizations(const Locale('en'));
      final line = notificationLine(en, 'en', n);
      expect(line.who, 'Warning from the moderators:');
      expect(line.text, 'please follow the fair-play rules. Reason: Spam');
      final plain = notificationLine(
        en,
        'en',
        AppNotification(
          id: 4,
          type: NotificationType.moderationWarning,
          createdAt: DateTime(2026),
        ),
      );
      expect(plain.text, 'please follow the fair-play rules');
    });

    testWidgets('16.2 row at 390×844', (tester) async {
      _phone(tester);
      final container = ProviderContainer(
        overrides: [
          accountProvider.overrideWith(SignedIn.new),
          apiClientProvider.overrideWithValue(_InboxApi()),
        ],
      );
      addTearDown(container.dispose);
      final router = GoRouter(
        routes: [GoRoute(path: '/', builder: (_, _) => const InboxScreen())],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(_app(container, router));
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      expect(tester.takeException(), isNull);
      expect(
        find.textContaining('Moderatorlardan xəbərdarlıq:', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('Səbəb: Söhbətdə təhqir', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('Yeni bildiriş'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
