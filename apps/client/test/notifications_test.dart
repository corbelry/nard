import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nard_client/app/providers.dart';
import 'package:nard_client/cosmetics/cosmetics_cache.dart';
import 'package:nard_client/cosmetics/cosmetics_providers.dart';
import 'package:nard_client/data/app_settings.dart';
import 'package:nard_client/l10n/gen/app_localizations.dart';
import 'package:nard_client/notifications/inbox_bell.dart';
import 'package:nard_client/notifications/inbox_screen.dart';
import 'package:nard_client/notifications/notification_models.dart';
import 'package:nard_client/notifications/notification_providers.dart';
import 'package:nard_client/notifications/notification_settings_screen.dart';
import 'package:nard_client/notifications/push_prompt_screen.dart';
import 'package:nard_client/notifications/push_registrar.dart';
import 'package:nard_client/online/account.dart';
import 'package:nard_client/social/social_models.dart';
import 'package:nard_client/social/social_socket.dart';
import 'package:nard_client/theme/nard_colors.dart';
import 'package:nard_client/theme/nard_theme.dart';
import 'package:nard_client/tournaments/tournament_models.dart' show UserLite;
import 'package:nard_core/nard_core.dart' show Variant;
import 'package:nard_protocol/nard_protocol.dart' show TimeControl;

import 'store_fakes.dart';

AppNotification _n(
  int id,
  NotificationType type,
  Duration ago, {
  Map<String, Object?> data = const {},
  String? from,
  bool read = false,
}) => AppNotification(
  id: id,
  type: type,
  data: data,
  from: from == null ? null : UserLite(id: '9$id', name: from),
  read: read,
  createdAt: DateTime.now().subtract(ago),
);

/// Inbox, settings and devices in memory.
class NotifyFakeApi extends FakeApi {
  NotifyFakeApi() {
    inbox = InboxPage(
      unread: 3,
      items: [
        _n(
          5,
          NotificationType.challenge,
          const Duration(minutes: 18),
          from: 'Nigar',
          data: {
            'code': 'NRD482',
            'variant': 'shortNard',
            'matchLength': 5,
            'timeControl': 'blitz',
            'expiresAt':
                DateTime.now()
                    .add(const Duration(minutes: 5))
                    .toUtc()
                    .toIso8601String(),
          },
        ),
        _n(
          4,
          NotificationType.tournamentReminder,
          const Duration(minutes: 2),
          data: {
            'tournamentId': '9',
            'tournament': {'az': 'Bakı Cümə Kuboku', 'en': 'Baku Friday Cup'},
            'minutes': 15,
          },
        ),
        _n(
          3,
          NotificationType.friendRequest,
          const Duration(days: 1),
          from: 'Rauf',
          data: {'requestId': 31},
        ),
        _n(
          2,
          NotificationType.seasonEnd,
          const Duration(days: 1, hours: 1),
          data: {'season': 1, 'tier': 'diamond', 'coins': 2000},
          read: true,
        ),
      ],
    );
  }

  final settingsCalls = <Map<String, Object?>>[];
  final devices = <String>[];
  var settings = NotificationSettings.fromJson(const {
    'push': true,
    'quietHours': {'enabled': true, 'start': '23:00', 'end': '08:00'},
    'categories': {'clan_war': true},
    'pushAvailable': false,
  });

  @override
  Future<int> markNotificationsRead({List<int>? ids, bool all = false}) async {
    calls.add(all ? 'readAll' : 'read:${ids?.join(',')}');
    return all ? 0 : inbox.unread - 1;
  }

  @override
  Future<int> deleteNotification(int id) async {
    calls.add('delete:$id');
    return inbox.unread - 1;
  }

  @override
  Future<void> acceptFriend(int requestId) async =>
      calls.add('accept:$requestId');

  @override
  Future<FriendsOverview> friends() async => const FriendsOverview();

  @override
  Future<NotificationSettings> notificationSettings() async => settings;

  @override
  Future<NotificationSettings> updateNotificationSettings(
    Map<String, Object?> fields,
  ) async {
    settingsCalls.add(fields);
    final cats = fields['categories'];
    final quiet = fields['quietHours'];
    settings = settings.copyWith(
      push: fields['push'] as bool?,
      categories:
          cats is Map<String, Object?>
              ? {
                ...settings.categories,
                for (final c in NotificationCategory.values)
                  if (cats.containsKey(c.api)) c: cats[c.api]! as bool,
              }
              : null,
      quietEnabled:
          quiet is Map<String, Object?> ? quiet['enabled'] as bool? : null,
      quietStart:
          quiet is Map<String, Object?> ? quiet['start'] as String? : null,
      quietEnd: quiet is Map<String, Object?> ? quiet['end'] as String? : null,
    );
    return settings;
  }

  @override
  Future<void> registerDevice(
    String platform,
    String token, {
    String? locale,
    int? utcOffset,
  }) async => devices.add('$platform:$token:$locale');
}

class FakeRegistrar implements PushRegistrar {
  FakeRegistrar(this._status);

  PushStatus _status;
  var asked = 0;
  final _opened = StreamController<PushOpen>.broadcast();

  void open(PushOpen push) => _opened.add(push);

  @override
  Future<PushStatus> status() async => _status;

  @override
  Future<PushStatus> requestPermission() async {
    asked++;
    return _status = PushStatus.granted;
  }

  @override
  Future<String?> token() async =>
      _status == PushStatus.granted ? 'fcm-token-1' : null;

  @override
  Stream<String> get tokenRefresh => const Stream.empty();

  @override
  Stream<PushOpen> get opened => _opened.stream;

  @override
  String get platform => 'android';
}

class _Socket extends SocialSocket {
  final sent = <String>[];

  @override
  RoomState build() => const RoomState();

  @override
  void joinRoom(
    String code, {
    Variant? variant,
    int? matchLength,
    TimeControl? timeControl,
  }) =>
      sent.add('join:$code:${variant?.name}:$matchLength:${timeControl?.name}');
}

class _Settings extends SettingsNotifier {
  _Settings(this.initial);

  final AppSettings initial;

  @override
  Future<AppSettings> build() async => initial;

  @override
  Future<void> save(AppSettings next) async => state = AsyncData(next);
}

Future<(ProviderContainer, _Socket)> _pump(
  WidgetTester tester,
  Widget screen,
  NotifyFakeApi api, {
  PushRegistrar registrar = const NoopPushRegistrar(),
  AppSettings settings = const AppSettings(),
}) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final socket = _Socket();
  final router = GoRouter(
    routes: [GoRoute(path: '/', builder: (_, _) => Scaffold(body: screen))],
    errorBuilder: (_, s) => Scaffold(body: Text('route:${s.uri}')),
  );
  addTearDown(router.dispose);
  final container = ProviderContainer(
    overrides: [
      accountProvider.overrideWith(SignedIn.new),
      apiClientProvider.overrideWithValue(api),
      cosmeticsCacheProvider.overrideWithValue(MemoryCosmeticsCache()),
      settingsProvider.overrideWith(() => _Settings(settings)),
      socialSocketProvider.overrideWith(() => socket),
      pushRegistrarProvider.overrideWithValue(registrar),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: NardTheme.build(NardColors.defaultTheme),
        locale: const Locale('az'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: router,
      ),
    ),
  );
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
  return (container, socket);
}

/// Pushed routes need a frame to start and one to finish.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  group('models and links', () {
    test('inbox JSON parses (contract shapes)', () {
      final page = InboxPage.fromJson({
        'unread': 2,
        'notifications': [
          {
            'id': 7,
            'type': 'tournament_round',
            'category': 'tournament_round',
            'data': {
              'tournamentId': '9',
              'round': 2,
              'opponent': 'Kerem',
              'tournament': {'az': 'Kubok'},
            },
            'from': null,
            'read': false,
            'createdAt': '2026-11-05T12:00:00+00:00',
          },
          {
            'id': 6,
            'type': 'something_new',
            'data': <String, Object?>{},
            'from': {'id': '4', 'name': 'Rauf'},
            'read': true,
            'createdAt': '2026-11-05T11:00:00+00:00',
          },
        ],
      });
      expect(page.unread, 2);
      expect(page.items.first.type, NotificationType.tournamentRound);
      expect(page.items.first.number('round'), 2);
      expect(page.items.first.tab, InboxTab.tournament);
      expect(page.items.last.type, NotificationType.unknown);
      expect(page.items.last.from?.name, 'Rauf');
      expect(notificationLink(page.items.first)?.path, '/tournaments/9');
      expect(notificationLink(page.items.last), isNull);

      final s = NotificationSettings.fromJson({
        'push': false,
        'quietHours': {'enabled': false, 'start': '22:00', 'end': '07:00'},
        'categories': {'clan_war': false},
        'pushAvailable': true,
      });
      expect(s.push, isFalse);
      expect(s.isOn(NotificationCategory.clanWar), isFalse);
      expect(s.isOn(NotificationCategory.gameInvites), isTrue);
      expect(s.quietStart, '22:00');
    });

    test('deep links per type', () {
      AppNotification n(NotificationType t, Map<String, Object?> d) =>
          _n(1, t, Duration.zero, data: d);
      expect(
        notificationLink(n(NotificationType.friendRequest, {}))?.path,
        '/friends',
      );
      expect(
        notificationLink(
          n(NotificationType.challenge, {'code': 'ABC234'}),
        )?.path,
        '/room/join?code=ABC234',
      );
      expect(
        notificationLink(n(NotificationType.clanInvite, {'clanId': '7'}))?.path,
        '/clans/7',
      );
      final war = notificationLink(n(NotificationType.clanWar, {}));
      expect((war?.path, war?.go), ('/clan', true));
      expect(
        notificationLink(n(NotificationType.seasonEnd, {'season': 3}))?.path,
        '/season/summary?n=3',
      );
      expect(notificationLink(n(NotificationType.levelUp, {}))?.go, isTrue);
    });
  });

  group('16.2 inbox', () {
    testWidgets('groups, filters, read-all, actions and taps', (tester) async {
      final api = NotifyFakeApi();
      final (_, socket) = await _pump(tester, const InboxScreen(), api);
      expect(tester.takeException(), isNull);
      expect(find.text('Bildirişlər'), findsOneWidget);
      expect(find.text('BU GÜN'), findsOneWidget);
      expect(find.text('DÜNƏN'), findsOneWidget);
      expect(find.textContaining('15 dəqiqəyə başlayır'), findsOneWidget);
      expect(
        find.textContaining(
          'səni oyuna çağırır · Qısa nərd, 5 xal, Blits 1+8s',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Dərəcən: Almaz'), findsOneWidget);
      expect(find.text('18 dəq'), findsOneWidget);

      // Turnir chip: only the tournament row.
      // Ahem test glyphs are wide: the chip row scrolls.
      await tester.ensureVisible(find.text('Turnir'));
      await tester.tap(find.text('Turnir'));
      await tester.pump();
      expect(find.textContaining('dostluq sorğusu'), findsNothing);
      expect(find.textContaining('15 dəqiqəyə'), findsOneWidget);
      await tester.ensureVisible(find.text('Hamısı'));
      await tester.tap(find.text('Hamısı'));
      await tester.pump();

      // Accept Rauf's request: accepted via the friends API, row removed.
      final accept = find.text('Qəbul et');
      expect(accept, findsNWidgets(2));
      await tester.tap(accept.last);
      await tester.pump(const Duration(milliseconds: 300));
      expect(api.calls, containsAll(['accept:31', 'delete:3']));
      expect(find.textContaining('dostluq sorğusu'), findsNothing);

      await tester.tap(find.text('Hamısını oxu'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(api.calls, contains('readAll'));
      expect(find.text('Hamısını oxu'), findsNothing);

      // Accepting the invite joins the room.
      await tester.tap(find.text('Qəbul et'));
      await _settle(tester);
      expect(socket.sent, ['join:NRD482:shortNard:5:blitz']);
      expect(find.text('route:/room/join?code=NRD482'), findsOneWidget);
      await closeScreen(tester);
    });

    testWidgets('a row opens its screen and is marked read', (tester) async {
      final api = NotifyFakeApi();
      await _pump(tester, const InboxScreen(), api);
      await tester.tap(find.textContaining('15 dəqiqəyə başlayır'));
      await _settle(tester);
      expect(api.calls, contains('read:4'));
      expect(find.text('route:/tournaments/9'), findsOneWidget);
      await closeScreen(tester);
    });

    testWidgets('empty state', (tester) async {
      final api =
          NotifyFakeApi()..inbox = const InboxPage(items: [], unread: 0);
      await _pump(tester, const InboxScreen(), api);
      expect(tester.takeException(), isNull);
      expect(find.text('Bildiriş yoxdur'), findsOneWidget);
      await closeScreen(tester);
    });
  });

  group('bell (Home header)', () {
    testWidgets('badge, 60 s polling, push taps, device sync', (tester) async {
      final api = NotifyFakeApi();
      final registrar = FakeRegistrar(PushStatus.granted);
      await _pump(
        tester,
        const Align(alignment: Alignment.topRight, child: InboxBell()),
        api,
        registrar: registrar,
        settings: const AppSettings(pushPromptShown: true),
      );
      expect(find.text('3'), findsOneWidget);
      expect(api.devices, ['android:fcm-token-1:az']);

      api.inbox = InboxPage(
        unread: 4,
        items: [
          _n(6, NotificationType.levelUp, Duration.zero, data: {'level': 5}),
          ...api.inbox.items,
        ],
      );
      await tester.pump(const Duration(seconds: 61));
      expect(find.text('4'), findsOneWidget);

      registrar.open(
        const PushOpen(
          id: 4,
          type: 'tournament_reminder',
          data: '{"tournamentId":"9"}',
        ),
      );
      await _settle(tester);
      expect(find.text('route:/tournaments/9'), findsOneWidget);
      await closeScreen(tester);
    });

    testWidgets('16.3 opens once when the OS has not been asked', (
      tester,
    ) async {
      final api = NotifyFakeApi();
      final registrar = FakeRegistrar(PushStatus.notDetermined);
      await _pump(
        tester,
        const Align(alignment: Alignment.topRight, child: InboxBell()),
        api,
        registrar: registrar,
      );
      await _settle(tester);
      expect(find.text('route:/push-prompt'), findsOneWidget);
      await closeScreen(tester);
    });

    testWidgets('no prompt without a push plugin', (tester) async {
      final api = NotifyFakeApi();
      await _pump(
        tester,
        const Align(alignment: Alignment.topRight, child: InboxBell()),
        api,
      );
      expect(find.text('route:/push-prompt'), findsNothing);
      expect(api.devices, isEmpty);
      await closeScreen(tester);
    });
  });

  group('16.3 push pre-prompt', () {
    testWidgets('allow asks the OS once and registers the token', (
      tester,
    ) async {
      final api = NotifyFakeApi();
      final registrar = FakeRegistrar(PushStatus.notDetermined);
      final (container, _) = await _pump(
        tester,
        const PushPromptScreen(),
        api,
        registrar: registrar,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Növbəni qaçırma'), findsOneWidget);
      expect(find.text('NardArena'), findsNWidgets(2));
      expect(find.text('İndi yox'), findsOneWidget);
      await tester.tap(find.text('Bildirişləri aç'));
      await _settle(tester);
      expect(registrar.asked, 1);
      expect(api.devices, ['android:fcm-token-1:az']);
      expect(container.read(currentSettingsProvider).pushPromptShown, isTrue);
      await closeScreen(tester);
    });

    testWidgets('not now only remembers the answer', (tester) async {
      final api = NotifyFakeApi();
      final registrar = FakeRegistrar(PushStatus.notDetermined);
      final (container, _) = await _pump(
        tester,
        const PushPromptScreen(),
        api,
        registrar: registrar,
      );
      await tester.tap(find.text('İndi yox'));
      await _settle(tester);
      expect(registrar.asked, 0);
      expect(container.read(currentSettingsProvider).pushPromptShown, isTrue);
      await closeScreen(tester);
    });
  });

  group('16.1 settings', () {
    testWidgets('categories, master switch and quiet hours', (tester) async {
      final api = NotifyFakeApi();
      await _pump(tester, const NotificationSettingsScreen(), api);
      expect(tester.takeException(), isNull);
      for (final t in [
        'Push bildirişləri',
        'Sakit saatlar',
        '23:00 – 08:00',
        'Oyun dəvətləri',
        'Turnir başlayır',
        '15 dəqiqə əvvəl',
        'Raund hazırdır',
        'Dostluq sorğuları',
        'Klan dəvətləri',
        'Klan müharibəsi',
        'Sezon nəticələri',
      ]) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
      expect(
        find.text('Bu versiyada push hələ işləmir; hamısı qutuda görünür'),
        findsOneWidget,
      );

      await tester.tap(find.bySemanticsLabel('Klan müharibəsi'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(api.settingsCalls.last['categories'], {'clan_war': false});
      expect(api.settingsCalls.last.containsKey('utcOffset'), isTrue);

      await tester.tap(find.text('Sakit saatlar'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Bir saat əvvəl').first);
      await tester.pump();
      expect(find.text('22:00'), findsOneWidget);
      await tester.tap(find.text('Yadda saxla'));
      await tester.pumpAndSettle();
      expect(api.settingsCalls.last['quietHours'], {
        'enabled': true,
        'start': '22:00',
        'end': '08:00',
      });
      expect(find.text('22:00 – 08:00'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Push bildirişləri'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(api.settingsCalls.last['push'], isFalse);
      await closeScreen(tester);
    });
  });
}
