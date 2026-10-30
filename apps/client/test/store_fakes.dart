import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:nard_client/app/providers.dart';
import 'package:nard_client/cosmetics/catalog.dart';
import 'package:nard_client/cosmetics/cosmetics_cache.dart';
import 'package:nard_client/cosmetics/cosmetics_providers.dart';
import 'package:nard_client/data/app_settings.dart';
import 'package:nard_client/l10n/gen/app_localizations.dart';
import 'package:nard_client/notifications/notification_models.dart';
import 'package:nard_client/online/account.dart';
import 'package:nard_client/online/api_client.dart';
import 'package:nard_client/progression/progress_models.dart';
import 'package:nard_client/seasons/season_models.dart';
import 'package:nard_client/store/store_models.dart';
import 'package:nard_client/theme/nard_colors.dart';
import 'package:nard_client/theme/nard_theme.dart';
import 'package:nard_client/tournaments/tournament_models.dart';
import 'package:nard_core/nard_core.dart' show Variant;

// Mirrors apps/api/database/seeders/ItemCatalogSeeder.php.
const _ivory = {
  'stops': ['#FFFFFBF2', '#FFEFE4CF', '#FFD4C3A2', '#FFB3A07C'],
  'groove': '#2B6E5532',
};
const _onyx = {
  'stops': ['#FF5D564F', '#FF2B2724', '#FF151312', '#FF0A0909'],
  'groove': '#0EFFFFFF',
};
const _ivoryDie = {
  'face': ['#FFFFFAF0', '#FFE4D6B8'],
  'pip': ['#FF3A2A1E', '#FF0D0806'],
};

const _caspianLook = <String, Object?>{
  'frame': ['#FF0F3D48', '#FF082731'],
  'field': ['#FF1D6577', '#FF16546A'],
  'pointA': ['#FFECE3D1', '#FFCDBD9F'],
  'pointB': ['#FF0A2C36', '#FF061C23'],
  'tray': ['#FF05161B', '#FF05161B'],
  'numbers': '#8CECE3D1',
  'light': {
    'stops': ['#FFFFFFFF', '#FFF1F0F4', '#FFD8D6E0', '#FFB8B6C4'],
  },
  'dark': {
    'stops': ['#FF3A5566', '#FF142836', '#FF08141C'],
  },
  'dice': {
    'face': ['#FFFFF4EE', '#FFECD2C4'],
    'pip': ['#FF1D4A5A', '#FF061C23'],
  },
  'table': ['#FF123844', '#FF051318'],
};

const _xatamLook = <String, Object?>{
  'frame': ['#FF5C2B17', '#FF3E1C0E', '#FF4C2414'],
  'field': ['#FF9C683D', '#FF835330'],
  'inlay': ['#FFC9A24A', '#FFF3EBDD', '#FF9E1B32', '#FF1C120B'],
  'pointA': ['#FFA8213B', '#FF72111F'],
  'pointB': ['#FFF2E7CF', '#FFD5C29D'],
  'tray': ['#FF24120A', '#FF170A05'],
  'numbers': '#8CF3EBDD',
  'grain': true,
  'light': _ivory,
  'dark': _onyx,
  'dice': _ivoryDie,
};

const walnutJson = <String, Object?>{
  'id': 'board.walnut',
  'category': 'board',
  'rarity': 'common',
  'price': <String, Object?>{},
  'default': true,
  'data': {
    'theme': 'walnut',
    'name': {'az': 'Klassik Qoz', 'en': 'Classic Walnut'},
    'description': {'az': 'Standart.', 'en': 'The standard.'},
    'obtain': 'default',
    'look': {
      'frame': ['#FF6E4224', '#FF4B2B16', '#FF5D3720'],
      'field': ['#FFC49159', '#FFA87745'],
      'pointA': ['#FF2E1C10', '#FF1A0E07'],
      'pointB': ['#FFF2E7CF', '#FFD5C29D'],
      'tray': ['#FF2A170C', '#FF1C0F07'],
      'numbers': '#8CF3EBDD',
      'grain': true,
      'light': _ivory,
      'dark': _onyx,
      'dice': _ivoryDie,
      'table': ['#FF3B2819', '#FF1B120C'],
    },
  },
  'asset': null,
};

Map<String, Object?> _board(
  String theme,
  String rarity,
  String az,
  Map<String, Object?> look, {
  Map<String, Object?> price = const {},
  String obtain = 'store',
}) => {
  'id': 'board.$theme',
  'category': 'board',
  'rarity': rarity,
  'price': price,
  'default': false,
  'data': {
    'theme': theme,
    'name': {'az': az, 'en': az},
    'description': {'az': '$az təsviri.'},
    'obtain': obtain,
    'look': look,
  },
  'asset': null,
};

final catalogJson = <String, Object?>{
  'items': [
    walnutJson,
    _board(
      'minimal_pro',
      'common',
      'Minimal Pro',
      {
        'frame': ['#FF1F2125', '#FF1F2125'],
        'field': ['#FF2A2D32', '#FF2A2D32'],
        'pointA': ['#FFE9E6DF', '#FFE9E6DF'],
        'pointB': ['#FF5C6068', '#FF5C6068'],
        'tray': ['#FF17181B', '#FF17181B'],
        'numbers': '#B3ECE7DE',
        'light': {
          'stops': ['#FFF5F3EE', '#FFF5F3EE'],
          'flat': true,
        },
        'dark': {
          'stops': ['#FF111214', '#FF111214'],
          'rim': '#FF4A4D53',
          'flat': true,
        },
        'dice': {
          'face': ['#FFF5F3EE', '#FFF5F3EE'],
          'pip': ['#FF111214', '#FF111214'],
          'flat': true,
        },
        'table': ['#FF16181D', '#FF16181D'],
      },
      price: {'coins': 1500},
    ),
    _board(
      'carpet_heritage',
      'rare',
      'Xalça İrsi',
      {
        'frame': ['#FF4A2418', '#FF2E140C'],
        'field': ['#FF8A2228', '#FF6C171D'],
        'pointA': ['#FF26346E', '#FF18214A'],
        'pointB': ['#FFF1E4C8', '#FFD6C39D'],
        'tray': ['#FF1F0D08', '#FF140804'],
        'numbers': '#8CF3EBDD',
        'grain': true,
        'light': {..._ivory, 'rim': '#FFB88F3A'},
        'dark': {
          'stops': ['#FF4A5A9A', '#FF26346E', '#FF141C40'],
          'groove': '#0FFFFFFF',
          'rim': '#FFC9A24A',
        },
        'dice': {
          'face': ['#FFFFFAF0', '#FFE4D6B8'],
          'pip': ['#FFC2323C', '#FF6C171D'],
        },
        'table': ['#FF3A1416', '#FF140708'],
      },
      price: {'coins': 1200},
    ),
    _board(
      'baku_night',
      'epic',
      'Bakı Gecəsi',
      {
        'frame': ['#FF1D212C', '#FF11131A'],
        'field': ['#FF232838', '#FF171A26'],
        'glow': '#2EE8783C',
        'pointA': ['#FFD9B560', '#FF8A6A22'],
        'pointB': ['#FF39406A', '#FF20253F'],
        'tray': ['#FF0B0D12', '#FF0B0D12'],
        'numbers': '#8CE8C468',
        'light': {
          'stops': ['#FFFFF3C8', '#FFE8C86E', '#FFB08A35', '#FF8A6A22'],
          'groove': '#33785010',
        },
        'dark': {..._onyx, 'rim': '#99E8C468'},
        'dice': {
          'face': ['#FF2C2C33', '#FF101014'],
          'pip': ['#FFFFF0B8', '#FFC9A24A'],
        },
        'table': ['#FF3A2418', '#FF0D0F16'],
      },
      price: {'gems': 600},
    ),
    _board('caspian', 'seasonal', 'Xəzər', _caspianLook, obtain: 'season'),
    _board('xatam', 'epic', 'Şuşa Xatəmi', _xatamLook, obtain: 'tournament'),
    _board(
      'marble_royale',
      'legendary',
      'Kral Mərməri',
      {
        'frame': ['#FF2A2A2E', '#FF0F0F12'],
        'field': ['#FFF4F1EC', '#FFDCD7CF'],
        'inlay': ['#FFE9CF82', '#FFA8822F'],
        'pointA': ['#FF2A2A2E', '#FF0F0F12'],
        'pointB': ['#FFE9CF82', '#FFB38A35'],
        'tray': ['#FF141416', '#FF08080A'],
        'numbers': '#B3E8C468',
        'light': {
          'stops': ['#FFFFFFFF', '#FFF4F1EC', '#FFDCD7CF', '#FFBDB6AC'],
          'rim': '#FFC9A24A',
        },
        'dark': {
          'stops': ['#FF3A3A40', '#FF1C1C20', '#FF0F0F12', '#FF050507'],
          'rim': '#FFC9A24A',
        },
        'dice': {
          'face': ['#F2EBF5FF', '#BFAAC8E6', '#E6DCEBFA'],
          'pip': ['#FF3A5A8A', '#FF0E1D36'],
        },
        'table': ['#FF2E2A24', '#FF0C0B0A'],
      },
      price: {'gems': 1800},
    ),
    {
      'id': 'checkers.classic',
      'category': 'checkers',
      'rarity': 'common',
      'price': <String, Object?>{},
      'default': true,
      'data': {
        'name': {'az': 'Klassik', 'en': 'Classic'},
      },
      'asset': null,
    },
    {
      'id': 'title.regular',
      'category': 'title',
      'rarity': 'common',
      'price': <String, Object?>{},
      'default': false,
      'data': {
        'name': {'az': 'Daimi', 'en': 'Regular'},
        'obtain': 'achievement',
      },
      'asset': null,
    },
  ],
};

final testCatalog = Catalog.fromJson(catalogJson);

const testAccount = Account(id: '1', name: 'Elvin', guest: false);

class SignedIn extends AccountNotifier {
  @override
  Future<Account?> build() async => testAccount;
}

class MemorySettings extends SettingsNotifier {
  @override
  Future<AppSettings> build() async => const AppSettings();

  @override
  Future<void> save(AppSettings next) async => state = AsyncData(next);
}

Mission mission(
  String id,
  String event,
  int target,
  int progress, {
  bool claimed = false,
  MissionKind kind = MissionKind.daily,
  int coins = 40,
}) => Mission(
  id: id,
  kind: kind,
  event: event,
  target: target,
  progress: progress,
  coins: coins,
  xp: 20,
  completed: progress >= target,
  claimed: claimed,
);

/// An in-memory API: wallet, owned items, loadouts, progress.
class FakeApi extends ApiClient {
  FakeApi({this.wallet = const Wallet(coins: 12450, gems: 320)})
    : super('http://test');

  Wallet wallet;
  final owned = <String>{
    'board.walnut',
    'checkers.classic',
    'board.baku_night',
    'board.minimal_pro',
  };
  final loadouts = <Loadout>[
    const Loadout(
      id: 1,
      name: 'Dəst 1',
      slots: {'board': 'board.walnut'},
      active: true,
    ),
  ];
  final calls = <String>[];
  var missions = <Mission>[
    mission('daily_doubles_3', 'doubles', 3, 3),
    mission('daily_ranked_win_3', 'ranked_win', 3, 2, coins: 60),
    mission('daily_long_play_1', 'long_play', 1, 1, claimed: true),
    mission(
      'weekly_play_15',
      'play',
      15,
      4,
      kind: MissionKind.weekly,
      coins: 300,
    ),
  ];

  Progress _progress() => Progress(
    level: 24,
    xp: 960,
    xpForNext: 1500,
    streak: const Streak(
      current: 5,
      best: 9,
      rewards: [20, 30, 40, 50, 60, 80, 150],
    ),
    missions: missions,
    achievements: const ['first_win', 'wins_10'],
    title: 'title.regular',
    dailyBonus: 100,
    resetsDaily: DateTime.now().add(const Duration(hours: 6)),
    resetsWeekly: DateTime.now().add(const Duration(days: 3)),
  );

  @override
  Future<Catalog> catalog() async => testCatalog;

  /// The inbox the Home bell polls (empty unless a test fills it).
  InboxPage inbox = const InboxPage(items: [], unread: 0);

  @override
  Future<InboxPage> notifications({int? after}) async => InboxPage(
    items: [
      for (final n in inbox.items)
        if (after == null || n.id > after) n,
    ],
    unread: inbox.unread,
  );

  @override
  Future<Inventory> inventory() async =>
      Inventory(wallet: wallet, owned: {...owned}, loadouts: [...loadouts]);

  @override
  Future<PurchaseResult> purchase(
    String itemId,
    Currency currency,
    String idempotencyKey,
  ) async {
    calls.add('purchase:$itemId:${currency.name}');
    final item = testCatalog.item(itemId)!;
    final price = item.price.of(currency);
    if (price == null) throw const ApiException(422, 'not_for_sale');
    if (owned.contains(itemId)) throw const ApiException(422, 'already_owned');
    if (wallet.of(currency) < price) {
      throw const ApiException(422, 'insufficient_funds');
    }
    wallet =
        currency == Currency.coins
            ? Wallet(coins: wallet.coins - price, gems: wallet.gems)
            : Wallet(coins: wallet.coins, gems: wallet.gems - price);
    owned.add(itemId);
    return PurchaseResult(wallet: wallet, owned: {...owned});
  }

  @override
  Future<Loadout> saveLoadout(
    String name,
    Map<String, String> slots, {
    int? id,
  }) async {
    calls.add('saveLoadout:$id:$name');
    final loadout = Loadout(
      id: id ?? loadouts.length + 1,
      name: name,
      slots: slots,
      active: id == null ? loadouts.isEmpty : true,
    );
    final i = loadouts.indexWhere((l) => l.id == loadout.id);
    if (i >= 0) {
      loadouts[i] = loadout.copyWith(active: loadouts[i].active);
    } else {
      loadouts.add(loadout);
    }
    return loadout;
  }

  @override
  Future<void> activateLoadout(int id) async {
    for (var i = 0; i < loadouts.length; i++) {
      loadouts[i] = loadouts[i].copyWith(active: loadouts[i].id == id);
    }
  }

  @override
  Future<StoreOffers> offers() async => StoreOffers(
    featured: FeaturedOffer(
      item: testCatalog.item('board.marble_royale')!,
      oldPrice: const Price(gems: 2400),
      endsAt: DateTime.now().add(const Duration(hours: 40)),
    ),
    daily: [
      testCatalog.item('board.carpet_heritage')!,
      testCatalog.item('board.minimal_pro')!,
    ],
    refreshAt: DateTime.now().add(const Duration(hours: 6)),
  );

  @override
  Future<GemProducts> products() async => const GemProducts(
    enabled: true,
    products: [
      GemProduct(id: 'yaqut_500', gems: 500),
      GemProduct(id: 'yaqut_1200', gems: 1200),
      GemProduct(id: 'yaqut_2600', gems: 2600),
    ],
  );

  @override
  Future<Progress> progress() async => _progress();

  @override
  Future<CheckIn> checkIn() async =>
      CheckIn(coins: 0, streak: 5, wallet: wallet);

  @override
  Future<ClaimResult> claimMission(String id) async {
    calls.add('claim:$id');
    final m = missions.firstWhere((m) => m.id == id);
    if (!m.completed || m.claimed) {
      throw const ApiException(422, 'not_claimable');
    }
    missions = [
      for (final x in missions)
        x.id == id
            ? mission(
              x.id,
              x.event,
              x.target,
              x.progress,
              claimed: true,
              kind: x.kind,
              coins: x.coins,
            )
            : x,
    ];
    wallet = Wallet(coins: wallet.coins + m.coins, gems: wallet.gems);
    return ClaimResult(progress: _progress(), wallet: wallet);
  }

  @override
  Future<void> setTitle(String? itemId) async => calls.add('title:$itemId');

  // Phase 6 defaults: no season, no tournaments (Home stays hermetic).
  @override
  Future<SeasonView> season() async =>
      throw const ApiException(404, 'not_found');

  @override
  Future<SeasonSummary> seasonSummary([int? number]) async =>
      throw const ApiException(404, 'not_found');

  @override
  Future<List<Tournament>> tournaments(
    TournamentTab tab, {
    Variant? variant,
    bool free = false,
  }) async => const [];
}

List<Override> storeOverrides(FakeApi api) => [
  accountProvider.overrideWith(SignedIn.new),
  apiClientProvider.overrideWithValue(api),
  cosmeticsCacheProvider.overrideWithValue(MemoryCosmeticsCache()),
  settingsProvider.overrideWith(MemorySettings.new),
];

/// Pumps [screen] at 390 × 844 (az) with the fake API.
Future<void> showScreen(WidgetTester tester, Widget screen, FakeApi api) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: storeOverrides(api),
      child: MaterialApp(
        theme: NardTheme.build(NardColors.defaultTheme),
        locale: const Locale('az'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(body: screen),
      ),
    ),
  );
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

Future<void> closeScreen(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 2));
}
