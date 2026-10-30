import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nard_client/cosmetics/catalog.dart';
import 'package:nard_client/cosmetics/cosmetics_providers.dart';
import 'package:nard_client/cosmetics/locker_screen.dart';
import 'package:nard_client/online/account.dart';
import 'package:nard_client/online/api_client.dart';
import 'package:nard_client/progression/achievements_screen.dart';
import 'package:nard_client/progression/level_up_screen.dart';
import 'package:nard_client/progression/match_rewards.dart';
import 'package:nard_client/progression/missions_screen.dart';
import 'package:nard_client/progression/progress.dart';
import 'package:nard_client/progression/progress_models.dart';
import 'package:nard_client/progression/streak_modal.dart';
import 'package:nard_client/screens/home_screen.dart';
import 'package:nard_client/store/inventory.dart';
import 'package:nard_client/store/purchase_flow.dart';
import 'package:nard_client/store/store_models.dart';
import 'package:nard_client/store/store_screen.dart';
import 'package:nard_client/ui/layout.dart';

import 'store_fakes.dart';

/// A container whose providers stay active (Riverpod 3 pauses providers
/// nobody listens to).
Future<ProviderContainer> _container(FakeApi api) async {
  final container = ProviderContainer(overrides: storeOverrides(api));
  addTearDown(container.dispose);
  container
    ..listen(inventoryProvider, (_, _) {})
    ..listen(progressProvider, (_, _) {})
    ..listen(catalogProvider, (_, _) {})
    ..listen(localLookProvider, (_, _) {})
    ..listen(localTableProvider, (_, _) {});
  await container.read(accountProvider.future);
  return container;
}

/// Opens the 7.4 sheet for [item] and returns the popped outcome holder.
Future<List<PurchaseOutcome?>> _openConfirm(
  WidgetTester tester,
  FakeApi api,
  String itemId,
) async {
  final popped = <PurchaseOutcome?>[];
  await showScreen(
    tester,
    Builder(
      builder:
          (context) => Center(
            child: TextButton(
              onPressed: () async {
                popped.add(
                  await showNardSheet<PurchaseOutcome>(
                    context,
                    builder:
                        (_) => PurchaseConfirmSheet(
                          item: testCatalog.item(itemId)!,
                        ),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
    ),
    api,
  );
  await tester.tap(find.text('open'));
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
  return popped;
}

void main() {
  group('purchase', () {
    test('quote: balance after and shortfall (7.4)', () {
      final marble = testCatalog.item('board.marble_royale')!;
      final poor = PurchaseQuote.of(marble, const Wallet(gems: 320))!;
      expect(poor.currency, Currency.gems);
      expect(poor.affordable, isFalse);
      expect(poor.shortfall, 1480);
      const products = GemProducts(
        products: [
          GemProduct(id: 'yaqut_500', gems: 500),
          GemProduct(id: 'yaqut_2600', gems: 2600),
          GemProduct(id: 'yaqut_1200', gems: 1200),
        ],
      );
      // Smallest pack covering the shortfall (1 480 → 2 600).
      expect(products.packFor(poor.shortfall)!.id, 'yaqut_2600');
      expect(products.packFor(100)!.id, 'yaqut_500');
      final carpet = testCatalog.item('board.carpet_heritage')!;
      final rich = PurchaseQuote.of(carpet, const Wallet(coins: 12450))!;
      expect(rich.currency, Currency.coins);
      expect(rich.after, 11250);
      expect(
        PurchaseQuote.of(testCatalog.item('board.caspian')!, rich_),
        isNull,
      );
    });

    test('success updates wallet and ownership', () async {
      final api = FakeApi();
      final container = await _container(api);
      final inventory = container.read(inventoryProvider.notifier);
      await container.read(inventoryProvider.future);
      final carpet = testCatalog.item('board.carpet_heritage')!;
      await inventory.purchase(carpet, Currency.coins);
      final after = container.read(inventoryProvider).value!;
      expect(after.wallet.coins, 12450 - 1200);
      expect(after.owns('board.carpet_heritage'), isTrue);
      expect(api.calls, ['purchase:board.carpet_heritage:coins']);
    });

    test('insufficient funds leaves the inventory unchanged', () async {
      final api = FakeApi();
      final container = await _container(api);
      await container.read(inventoryProvider.future);
      final marble = testCatalog.item('board.marble_royale')!;
      await expectLater(
        container
            .read(inventoryProvider.notifier)
            .purchase(marble, Currency.gems),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            'insufficient_funds',
          ),
        ),
      );
      final after = container.read(inventoryProvider).value!;
      expect(after.wallet.gems, 320);
      expect(after.owns('board.marble_royale'), isFalse);
    });

    testWidgets('7.4 insufficient balance offers the covering pack', (
      tester,
    ) async {
      final api = FakeApi();
      await _openConfirm(tester, api, 'board.marble_royale');
      expect(find.text('ƏFSANƏVİ'), findsOneWidget);
      expect(find.text('Kral Mərməri'), findsOneWidget);
      expect(find.text('1 800 yaqut'), findsOneWidget);
      expect(find.text('−1 480 çatmır'), findsOneWidget);
      expect(find.textContaining('2 600 yaqut paketini'), findsOneWidget);
      expect(find.text('2 600 yaqut al'), findsOneWidget);
      expect(api.calls, isEmpty);
      await closeScreen(tester);
    });

    testWidgets('7.4 enough balance buys and pops the outcome', (tester) async {
      final api = FakeApi();
      final popped = await _openConfirm(tester, api, 'board.carpet_heritage');
      expect(find.text('11 250 sikkə'), findsOneWidget);
      await tester.tap(find.text('Al'));
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(api.calls, ['purchase:board.carpet_heritage:coins']);
      expect(popped, hasLength(1));
      expect(popped.single!.item!.id, 'board.carpet_heritage');
      expect(popped.single!.amount, 1200);
      expect(popped.single!.receipt, startsWith('NA-'));
      await closeScreen(tester);
    });
  });

  group('progression', () {
    test('claiming a mission updates progress and the wallet', () async {
      final api = FakeApi();
      final container = await _container(api);
      await container.read(inventoryProvider.future);
      await container.read(progressProvider.future);
      await container.read(progressProvider.notifier).claim('daily_doubles_3');
      final progress = container.read(progressProvider).value!;
      expect(
        progress.missions.firstWhere((m) => m.id == 'daily_doubles_3').state,
        MissionState.claimed,
      );
      expect(container.read(inventoryProvider).value!.wallet.coins, 12490);
      await expectLater(
        container.read(progressProvider.notifier).claim('daily_ranked_win_3'),
        throwsA(isA<ApiException>()),
      );
    });

    test('match rewards compare progress before and after', () {
      const before = RewardSnapshot(
        progress: Progress(
          level: 23,
          xp: 1400,
          xpForNext: 1450,
          missions: [
            Mission(
              id: 'a',
              kind: MissionKind.daily,
              event: 'mars',
              target: 3,
              progress: 2,
            ),
          ],
        ),
        wallet: Wallet(coins: 1000),
      );
      final after = RewardSnapshot(
        progress: Progress(
          level: 24,
          xp: 70,
          xpForNext: 1500,
          missions: [mission('a', 'mars', 3, 3)],
        ),
        wallet: const Wallet(coins: 1450),
      );
      final r = MatchRewards.compare(before, after);
      expect(r.coins, 450);
      expect(r.xp, 120);
      expect(r.leveledUp, isTrue);
      expect(r.missions.single.id, 'a');
    });

    testWidgets('12.1 claim turns the row into "Alındı"', (tester) async {
      final api = FakeApi();
      await showScreen(tester, const MissionsScreen(), api);
      expect(find.text('Tapşırıqlar'), findsOneWidget);
      expect(find.text('Giriş seriyası · 5 gün'), findsOneWidget);
      expect(find.text('Sabah: +80'), findsOneWidget);
      expect(find.text('3 dubl at'), findsOneWidget);
      expect(find.text('Alındı'), findsOneWidget);
      await tester.tap(find.text('Al'));
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      expect(api.calls, ['claim:daily_doubles_3']);
      expect(find.text('Alındı'), findsNWidgets(2));
      await tester.tap(find.text('Həftəlik'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('15 oyun oyna'), findsOneWidget);
      await closeScreen(tester);
    });
  });

  group('render 390×844', () {
    testWidgets('3.1 Locker', (tester) async {
      final api = FakeApi();
      await showScreen(tester, const LockerScreen(), api);
      expect(find.text('Dolab'), findsOneWidget);
      expect(find.text('Taxta'), findsOneWidget);
      expect(find.text('Dəst 1'), findsOneWidget);
      expect(find.text('Taxılıb'), findsOneWidget);
      expect(find.text('Sahibsən'), findsNWidgets(2));
      expect(find.text('Sezon bileti'), findsOneWidget);
      expect(find.text('Turnir mükafatı'), findsOneWidget);
      expect(find.text('Rəqibin kosmetikasını göstər'), findsOneWidget);
      // Equipping an owned set marks it and offers "Saxla".
      await tester.tap(find.text('Minimal Pro'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Saxla'), findsOneWidget);
      await tester.tap(find.text('Saxla'));
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      expect(api.calls, contains('saveLoadout:1:Dəst 1'));
      expect(api.loadouts.single.slots['board'], 'board.minimal_pro');
      await closeScreen(tester);
    });

    testWidgets('7.3 Store', (tester) async {
      final api = FakeApi();
      await showScreen(tester, const StoreScreen(), api);
      expect(find.text('Mağaza'), findsOneWidget);
      expect(find.text('TÖVSİYƏ · 2 GÜN'), findsOneWidget);
      expect(find.text('Kral Mərməri'), findsOneWidget);
      expect(find.text('GÜNLÜK SEÇİM'), findsOneWidget);
      expect(find.textContaining('Yenilənir'), findsOneWidget);
      expect(find.text('Xalça İrsi'), findsOneWidget);
      expect(find.text('YAQUT'), findsOneWidget);
      expect(find.text('2 600'), findsOneWidget);
      expect(find.text('12 450'), findsOneWidget);
      await closeScreen(tester);
    });

    testWidgets('12.1 Missions and 8.2 Achievements', (tester) async {
      final api = FakeApi();
      await showScreen(tester, const MissionsScreen(), api);
      expect(find.textContaining('Günlük bonus'), findsOneWidget);
      expect(find.textContaining('Yenilənməyə'), findsOneWidget);
      await closeScreen(tester);
      await showScreen(tester, const AchievementsScreen(), api);
      expect(find.text('Nailiyyətlər'), findsOneWidget);
      expect(find.text('2 / 7'), findsOneWidget);
      expect(find.text('İlk qələbə'), findsOneWidget);
      expect(find.text('TİTUL'), findsOneWidget);
      expect(find.text('Daimi'), findsOneWidget);
      await closeScreen(tester);
    });

    testWidgets('2.1 Home level line, pills and daily mission card', (
      tester,
    ) async {
      final api = FakeApi();
      await showScreen(tester, const HomeScreen(), api);
      expect(find.text('Səv. 24'), findsOneWidget);
      expect(find.text('12 450'), findsOneWidget);
      expect(find.text('320'), findsOneWidget);
      expect(find.text('GÜNLÜK MİSSİYA · 2/3'), findsOneWidget);
      expect(find.text('Reytinq oyunu qazan'), findsNothing);
      expect(find.text('3 reytinq oyunu qazan'), findsOneWidget);
      await closeScreen(tester);
    });

    testWidgets('12.2 streak modal and 12.3 level up', (tester) async {
      final api = FakeApi();
      await showScreen(
        tester,
        StreakCardModal(
          streakDay: 5,
          coins: 60,
          rewards: const [20, 30, 40, 50, 60, 80, 150],
          onClaim: () {},
        ),
        api,
      );
      expect(find.text('GİRİŞ SERİYASI'), findsOneWidget);
      // Title + the day-5 tile.
      expect(find.text('5-ci gün'), findsNWidgets(2));
      expect(find.text('3-cü gün'), findsOneWidget);
      expect(find.text('+150'), findsOneWidget);
      expect(find.text('+60 sikkəni al'), findsOneWidget);
      await closeScreen(tester);
      await showScreen(
        tester,
        const LevelUpScreen(
          args: LevelUpArgs(from: 23, to: 24, xp: 120, xpForNext: 1500),
        ),
        api,
      );
      expect(find.text('24'), findsOneWidget);
      expect(find.text('SƏVİYYƏ 23 → 24'), findsOneWidget);
      expect(find.text('Səviyyə yüksəldi'), findsOneWidget);
      expect(find.text('120 / 1 500 XP'), findsOneWidget);
      await closeScreen(tester);
    });

    test('the equipped set follows the active loadout', () async {
      final api = FakeApi();
      api.loadouts[0] = api.loadouts[0].copyWith(
        slots: {'board': 'board.baku_night'},
      );
      final container = await _container(api);
      await container.read(catalogProvider.future);
      await container.read(inventoryProvider.future);
      // The catalog refreshes from the API right after its cached build.
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(container.read(localLookProvider).id, 'baku_night');
      expect(container.read(localTableProvider), isNotNull);
    });
  });
}

const rich_ = Wallet(coins: 99999, gems: 99999);
