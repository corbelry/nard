import '../cosmetics/catalog.dart';

int _int(Object? v) => (v as num?)?.toInt() ?? 0;

DateTime? _date(Object? v) => v is String ? DateTime.tryParse(v) : null;

/// Coins and Yaqut balances.
class Wallet {
  const Wallet({this.coins = 0, this.gems = 0});

  final int coins;
  final int gems;

  int of(Currency currency) => currency == Currency.coins ? coins : gems;

  static Wallet fromJson(Object? json) =>
      json is Map
          ? Wallet(coins: _int(json['coins']), gems: _int(json['gems']))
          : const Wallet();
}

/// A named set of equipped items, category → item id.
class Loadout {
  const Loadout({
    required this.id,
    required this.name,
    this.slots = const {},
    this.active = false,
  });

  final int id;
  final String name;
  final Map<String, String> slots;
  final bool active;

  Loadout copyWith({String? name, Map<String, String>? slots, bool? active}) =>
      Loadout(
        id: id,
        name: name ?? this.name,
        slots: slots ?? this.slots,
        active: active ?? this.active,
      );

  static Loadout fromJson(Map<String, Object?> j) {
    final slots = j['slots'];
    return Loadout(
      id: _int(j['id']),
      name: j['name'] as String? ?? '',
      slots: {
        if (slots is Map)
          for (final e in slots.entries)
            if (e.key is String && e.value is String)
              e.key as String: e.value as String,
      },
      active: j['active'] == true,
    );
  }
}

/// `GET /me/inventory`.
class Inventory {
  const Inventory({
    this.wallet = const Wallet(),
    this.owned = const {},
    this.loadouts = const [],
  });

  final Wallet wallet;
  final Set<String> owned;
  final List<Loadout> loadouts;

  /// Server limit (`economy.max_loadouts`).
  static const maxLoadouts = 5;

  Loadout? get active =>
      loadouts.where((l) => l.active).firstOrNull ?? loadouts.firstOrNull;

  Map<String, String> get equipped => active?.slots ?? const {};

  bool owns(String itemId) => owned.contains(itemId);

  Inventory copyWith({
    Wallet? wallet,
    Set<String>? owned,
    List<Loadout>? loadouts,
  }) => Inventory(
    wallet: wallet ?? this.wallet,
    owned: owned ?? this.owned,
    loadouts: loadouts ?? this.loadouts,
  );

  static Inventory fromJson(Map<String, Object?> j) => Inventory(
    wallet: Wallet.fromJson(j['wallet']),
    owned: {
      for (final id in (j['owned'] as List?) ?? const [])
        if (id is String) id,
    },
    loadouts: [
      for (final l in (j['loadouts'] as List?) ?? const [])
        if (l is Map<String, Object?>) Loadout.fromJson(l),
    ],
  );
}

/// `POST /store/purchase` answer.
class PurchaseResult {
  const PurchaseResult({required this.wallet, required this.owned});

  final Wallet wallet;
  final Set<String> owned;

  static PurchaseResult fromJson(Map<String, Object?> j) => PurchaseResult(
    wallet: Wallet.fromJson(j['wallet']),
    owned: {
      for (final id in (j['owned'] as List?) ?? const [])
        if (id is String) id,
    },
  );
}

/// 7.3 featured offer.
class FeaturedOffer {
  const FeaturedOffer({required this.item, this.oldPrice, this.endsAt});

  final CatalogItem item;
  final Price? oldPrice;
  final DateTime? endsAt;
}

/// `GET /store/offers`.
class StoreOffers {
  const StoreOffers({this.featured, this.daily = const [], this.refreshAt});

  final FeaturedOffer? featured;
  final List<CatalogItem> daily;
  final DateTime? refreshAt;

  static StoreOffers fromJson(Map<String, Object?> j) {
    final f = j['featured'];
    final featuredItem = f is Map ? CatalogItem.tryParse(f['item']) : null;
    return StoreOffers(
      featured:
          featuredItem == null
              ? null
              : FeaturedOffer(
                item: featuredItem,
                oldPrice:
                    (f as Map)['oldPrice'] == null
                        ? null
                        : Price.fromJson(f['oldPrice']),
                endsAt: _date(f['endsAt']),
              ),
      daily: [
        for (final raw in (j['daily'] as List?) ?? const [])
          if (CatalogItem.tryParse(raw) case final item?) item,
      ],
      refreshAt: _date(j['refreshAt']),
    );
  }
}

/// A Yaqut pack (store product id → gems).
class GemProduct {
  const GemProduct({required this.id, required this.gems});

  final String id;
  final int gems;
}

/// `GET /store/products`.
class GemProducts {
  const GemProducts({this.enabled = false, this.products = const []});

  final bool enabled;
  final List<GemProduct> products;

  /// The smallest pack covering [shortfall] (7.4), else the largest.
  GemProduct? packFor(int shortfall) {
    if (products.isEmpty) return null;
    final sorted = [...products]..sort((a, b) => a.gems.compareTo(b.gems));
    return sorted.where((p) => p.gems >= shortfall).firstOrNull ?? sorted.last;
  }

  static GemProducts fromJson(Map<String, Object?> j) => GemProducts(
    enabled: j['enabled'] == true,
    products: [
      for (final p in (j['products'] as List?) ?? const [])
        if (p is Map && p['id'] is String)
          GemProduct(id: p['id'] as String, gems: _int(p['gems'])),
    ],
  );
}
