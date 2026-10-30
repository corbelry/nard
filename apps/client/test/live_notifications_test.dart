import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nard_client/l10n/gen/app_localizations.dart';
import 'package:nard_client/notifications/live_banner.dart';
import 'package:nard_client/notifications/live_notifications.dart';
import 'package:nard_client/notifications/notification_models.dart';
import 'package:nard_client/notifications/notification_providers.dart';
import 'package:nard_client/notifications/notification_text.dart';
import 'package:nard_client/theme/nard_colors.dart';
import 'package:nard_client/theme/nard_theme.dart';
import 'package:nard_client/tournaments/tournament_models.dart';
import 'package:nard_client/tournaments/tournament_providers.dart';
import 'package:nard_protocol/nard_protocol.dart';

import 'phase6_fakes.dart';

/// Counts tournament detail fetches.
class _Api extends TournamentFakeApi {
  var detailFetches = 0;
  final read = <String>[];

  @override
  Future<TournamentDetail> tournament(String id) {
    detailFetches++;
    return super.tournament(id);
  }

  @override
  Future<int> markNotificationsRead({List<int>? ids, bool all = false}) async {
    read.add('${ids?.join(',')}');
    return 0;
  }
}

const _cup = {'az': 'Bakı Payız Kuboku', 'en': 'Baku Autumn Cup'};

Map<String, Object?> _row(
  int id,
  String type, [
  Map<String, Object?> data = const {},
]) => {
  'id': id,
  'type': type,
  'category': null,
  'data': data,
  'from': null,
  'read': false,
  'createdAt': DateTime.now().toUtc().toIso8601String(),
};

Envelope _msg(String type, Map<String, Object?> payload) =>
    Envelope(type: type, id: 's1', ts: 0, payload: payload);

Envelope _notification(
  int id,
  String type, [
  Map<String, Object?> data = const {},
]) => _msg(MessageType.notification, _row(id, type, data));

ProviderContainer _container(_Api api) {
  final c = ProviderContainer(overrides: phase6Overrides(api));
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('live notifications (ADR-049)', () {
    test('a pushed row lands on top of the inbox and bumps the bell', () async {
      final api =
          _Api()
            ..inbox = InboxPage(
              unread: 1,
              items: [AppNotification.fromJson(_row(3, 'friend_accepted'))],
            );
      final c = _container(api);
      c.listen(inboxProvider, (_, _) {});
      await c.read(inboxProvider.future);
      final live = c.read(liveNotificationsProvider.notifier);

      live.onMessage(
        _notification(7, 'tournament_round', {
          'tournamentId': '9',
          'tournament': _cup,
          'round': 2,
          'opponent': 'Nigar',
        }),
      );
      final inbox = c.read(inboxProvider).value!;
      expect(inbox.items.map((n) => n.id), [7, 3]);
      expect(c.read(unreadCountProvider), 2);
      expect(c.read(liveNotificationsProvider)?.id, 7);

      // The same row again (poll raced the push): nothing changes.
      live.onMessage(_notification(7, 'tournament_round'));
      expect(c.read(inboxProvider).value!.items, hasLength(2));
      expect(c.read(unreadCountProvider), 2);

      // Malformed rows and unknown messages are ignored.
      live
        ..onMessage(_msg(MessageType.notification, {'id': 'x'}))
        ..onMessage(_msg(MessageType.tournamentUpdated, const {}))
        ..onMessage(_msg(MessageType.pong, const {}));
      expect(c.read(inboxProvider).value!.items, hasLength(2));

      // A level-up has its own screen: inbox only, no banner.
      live
        ..dismiss()
        ..onMessage(_notification(8, 'level_up', {'level': 5, 'coins': 100}));
      expect(c.read(unreadCountProvider), 3);
      expect(c.read(liveNotificationsProvider), isNull);
    });

    test(
      'tournament.updated and tournament rows refetch open screens',
      () async {
        final api = _Api();
        final c = _container(api);
        c.listen(tournamentDetailProvider('9'), (_, _) {});
        await c.read(tournamentDetailProvider('9').future);
        expect(api.detailFetches, 1);
        final live = c.read(liveNotificationsProvider.notifier);

        live.onMessage(
          _msg(
            MessageType.tournamentUpdated,
            const TournamentUpdatedPayload('9').toJson(),
          ),
        );
        await c.read(tournamentDetailProvider('9').future);
        expect(api.detailFetches, 2);

        // Another tournament: this one is not refetched.
        live.onMessage(
          _msg(
            MessageType.tournamentUpdated,
            const TournamentUpdatedPayload('11').toJson(),
          ),
        );
        await c.read(tournamentDetailProvider('9').future);
        expect(api.detailFetches, 2);

        live.onMessage(
          _notification(9, 'tournament_cancelled', {
            'tournamentId': '9',
            'tournament': _cup,
            'refund': 100,
          }),
        );
        await c.read(tournamentDetailProvider('9').future);
        expect(api.detailFetches, 3);
      },
    );

    testWidgets('the new rows read well (az)', (tester) async {
      late AppLocalizations l;
      await tester.pumpWidget(
        Localizations(
          locale: const Locale('az'),
          delegates: AppLocalizations.localizationsDelegates,
          child: Builder(
            builder: (context) {
              l = AppLocalizations.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      String line(String type, Map<String, Object?> data) {
        final r = notificationLine(
          l,
          'az',
          AppNotification.fromJson(_row(1, type, data)),
        );
        return '${r.who} ${r.text}';
      }

      expect(
        line('tournament_cancelled', {'tournament': _cup, 'refund': 100}),
        'Bakı Payız Kuboku ləğv edildi · 100 sikkə geri qaytarıldı',
      );
      expect(
        line('tournament_cancelled', {'tournament': _cup, 'refund': 0}),
        'Bakı Payız Kuboku ləğv edildi',
      );
      expect(
        line('tournament_eliminated', {
          'tournament': _cup,
          'round': 2,
          'place': 3,
        }),
        'Bakı Payız Kuboku · Raund 2: mübarizə bitdi. Yerin: 3',
      );
      // Rows from before the place was sent.
      expect(
        line('tournament_eliminated', {'tournament': _cup, 'round': 2}),
        'Bakı Payız Kuboku · Raund 2: mübarizə bitdi',
      );
      expect(
        line('season_end', {
          'season': 1,
          'tier': 'diamond',
          'coins': 2000,
          'rank': 14,
        }),
        'Sezon 1 bitdi · Dərəcən: Almaz, yerin: #14. Mükafat: 2000 sikkə',
      );
      expect(
        line('season_started', {'season': 2}),
        'Sezon 2 başladı. Yeni sezon keçidi və mükafatlar səni gözləyir',
      );
      final cancelled = AppNotification.fromJson(
        _row(1, 'tournament_cancelled', {'tournamentId': '9'}),
      );
      expect(cancelled.tab, InboxTab.tournament);
      expect(notificationLink(cancelled)?.path, '/tournaments/9');
      expect(
        notificationLink(
          AppNotification.fromJson(_row(1, 'season_started', {'season': 2})),
        )?.path,
        '/season',
      );
    });

    Future<(ProviderContainer, GoRouter)> pumpHost(
      WidgetTester tester,
      _Api api, {
      String start = '/',
    }) async {
      tester.view.physicalSize = const Size(390, 844) * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final router = GoRouter(
        initialLocation: start,
        routes: [
          GoRoute(
            path: '/',
            builder:
                (_, _) => const Scaffold(body: Center(child: Text('home'))),
          ),
          GoRoute(
            path: '/game',
            builder:
                (_, _) => const Scaffold(body: Center(child: Text('game'))),
          ),
        ],
        errorBuilder: (_, s) => Scaffold(body: Text('route:${s.uri}')),
      );
      addTearDown(router.dispose);
      final c = _container(api);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp.router(
            theme: NardTheme.build(NardColors.defaultTheme),
            locale: const Locale('az'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            routerConfig: router,
            builder:
                (context, child) =>
                    LiveBannerHost(router: router, child: child!),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return (c, router);
    }

    testWidgets('a banner shows over any screen and opens its link', (
      tester,
    ) async {
      final api = _Api();
      final (c, _) = await pumpHost(tester, api);
      c.listen(inboxProvider, (_, _) {});
      // Riverpod's scheduler runs on the test clock.
      await tester.pumpAndSettle();
      expect(c.read(inboxProvider).hasValue, isTrue);
      c
          .read(liveNotificationsProvider.notifier)
          .onMessage(
            _notification(7, 'tournament_round', {
              'tournamentId': '9',
              'tournament': _cup,
              'round': 2,
              'opponent': 'Nigar',
            }),
          );
      await tester.pumpAndSettle();
      expect(find.byType(LiveBanner), findsOneWidget);
      expect(
        find.textContaining(
          'Raund 2 hazırdır. Rəqib: Nigar',
          findRichText: true,
        ),
        findsOneWidget,
      );
      await tester.tap(find.byType(LiveBanner));
      await tester.pumpAndSettle();
      expect(find.text('route:/tournaments/9'), findsOneWidget);
      expect(find.byType(LiveBanner), findsNothing);
      expect(api.read, ['7']);
      expect(c.read(liveNotificationsProvider), isNull);
    });

    testWidgets(
      'a banner hides itself, can be closed, and stays out of games',
      (tester) async {
        final (c, router) = await pumpHost(tester, _Api());
        c.listen(inboxProvider, (_, _) {});
        // Riverpod's scheduler runs on the test clock.
        await tester.pumpAndSettle();
        expect(c.read(inboxProvider).hasValue, isTrue);
        final live = c.read(liveNotificationsProvider.notifier);
        live.onMessage(_notification(1, 'season_started', {'season': 2}));
        await tester.pumpAndSettle();
        expect(find.byType(LiveBanner), findsOneWidget);
        await tester.pump(const Duration(seconds: 6));
        await tester.pumpAndSettle();
        expect(find.byType(LiveBanner), findsNothing);

        live.onMessage(_notification(2, 'season_started', {'season': 2}));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('Bağla'));
        await tester.pumpAndSettle();
        expect(find.byType(LiveBanner), findsNothing);
        expect(find.text('home'), findsOneWidget);

        router.go('/game');
        await tester.pumpAndSettle();
        live.onMessage(_notification(3, 'season_started', {'season': 2}));
        await tester.pumpAndSettle();
        expect(find.byType(LiveBanner), findsNothing);
        // Still in the inbox.
        expect(c.read(inboxProvider).value!.items.first.id, 3);
      },
    );
  });
}
