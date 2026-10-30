import 'board_look.dart';

/// The two currencies: earn-only coins (ADR-022) and paid Yaqut, code
/// name `gems` (ADR-023).
enum Currency { coins, gems }

/// Item categories of the API (`config/economy.php`), in Locker order.
abstract final class ItemCategory {
  static const board = 'board';
  static const checkers = 'checkers';
  static const dice = 'dice';
  static const diceCup = 'dice_cup';
  static const cube = 'cube';
  static const table = 'table';
  static const sounds = 'sound_pack';
  static const emotes = 'emote_pack';
  static const avatarFrame = 'avatar_frame';
  static const title = 'title';
  static const winEffect = 'win_effect';

  static const order = [
    board,
    checkers,
    dice,
    diceCup,
    cube,
    table,
    sounds,
    emotes,
    avatarFrame,
    title,
    winEffect,
  ];
}

/// Where an item comes from when it is not bought (`data.obtain`).
enum Obtain { defaultItem, store, season, tournament, achievement }

/// A price in coins and/or Yaqut.
class Price {
  const Price({this.coins, this.gems});

  final int? coins;
  final int? gems;

  bool get isEmpty => coins == null && gems == null;

  /// The currency an item is bought with: coins when offered (earned,
  /// never bought), otherwise Yaqut.
  (Currency, int)? get primary =>
      coins != null
          ? (Currency.coins, coins!)
          : gems != null
          ? (Currency.gems, gems!)
          : null;

  int? of(Currency currency) => currency == Currency.coins ? coins : gems;

  static Price fromJson(Object? json) {
    if (json is! Map) return const Price();
    return Price(
      coins: (json['coins'] as num?)?.toInt(),
      gems: (json['gems'] as num?)?.toInt(),
    );
  }
}

/// One cosmetic from `GET /catalog`. Names and descriptions are per-locale
/// catalog data, not ARB (store.md §2.3).
class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.category,
    required this.rarity,
    this.price = const Price(),
    this.isDefault = false,
    this.theme,
    this.name = const {},
    this.description = const {},
    this.obtain = Obtain.store,
    this.look,
    this.json = const {},
  });

  final String id;
  final String category;

  /// `common` | `rare` | `epic` | `legendary` | `seasonal` | `tournament`.
  final String rarity;
  final Price price;
  final bool isDefault;
  final String? theme;
  final Map<String, String> name;
  final Map<String, String> description;
  final Obtain obtain;

  /// Board sets only (ADR-034).
  final BoardLook? look;

  /// The raw API object (kept for the offline cache).
  final Map<String, Object?> json;

  bool get forSale => !isDefault && !price.isEmpty;

  String nameFor(String locale) => _localized(name, locale) ?? id;

  String descriptionFor(String locale) => _localized(description, locale) ?? '';

  static String? _localized(Map<String, String> map, String locale) =>
      map[locale] ?? map['en'] ?? map['az'] ?? map.values.firstOrNull;

  static Map<String, String> _strings(Object? value) => {
    if (value is Map)
      for (final e in value.entries)
        if (e.key is String && e.value is String)
          e.key as String: e.value as String,
  };

  static CatalogItem? tryParse(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final id = json['id'];
    final category = json['category'];
    if (id is! String || category is! String) return null;
    final data = json['data'];
    final d = data is Map ? data : const <String, Object?>{};
    final theme = d['theme'] is String ? d['theme'] as String : null;
    final obtainName = d['obtain'];
    final isDefault = json['default'] == true;
    return CatalogItem(
      id: id,
      category: category,
      rarity: json['rarity'] is String ? json['rarity']! as String : 'common',
      price: Price.fromJson(json['price']),
      isDefault: isDefault,
      theme: theme,
      name: _strings(d['name']),
      description: _strings(d['description']),
      obtain: switch (obtainName) {
        'default' => Obtain.defaultItem,
        'season' => Obtain.season,
        'tournament' => Obtain.tournament,
        'achievement' => Obtain.achievement,
        'store' => Obtain.store,
        _ => isDefault ? Obtain.defaultItem : Obtain.store,
      },
      look:
          category == ItemCategory.board
              ? BoardLook.fromJson(d['look'], id: theme ?? id)
              : null,
      json: json,
    );
  }
}

/// The item catalog; [builtin] (Classic Walnut only) until the API answers.
class Catalog {
  Catalog(this.items) : _byId = {for (final i in items) i.id: i};

  final List<CatalogItem> items;
  final Map<String, CatalogItem> _byId;

  CatalogItem? item(String? id) => id == null ? null : _byId[id];

  List<CatalogItem> inCategory(String category) =>
      items.where((i) => i.category == category).toList();

  /// Categories with at least one item, in Locker order.
  List<String> get categories {
    final present = {for (final i in items) i.category};
    return [
      for (final c in ItemCategory.order)
        if (present.contains(c)) c,
      for (final c in present)
        if (!ItemCategory.order.contains(c)) c,
    ];
  }

  /// The default item of [category] (owned by everyone).
  CatalogItem? defaultOf(String category) =>
      items.where((i) => i.category == category && i.isDefault).firstOrNull;

  /// The board look for loadout [slots] (default walnut).
  BoardLook lookFor(Map<String, String> slots) =>
      item(slots[ItemCategory.board])?.look ?? BoardLook.walnut;

  static Catalog fromJson(Object? json) {
    final list = json is Map ? json['items'] : json;
    final items = <CatalogItem>[
      if (list is List)
        for (final raw in list)
          if (CatalogItem.tryParse(raw) case final item?) item,
    ];
    return Catalog(items);
  }

  List<Map<String, Object?>> toJson() => [for (final i in items) i.json];

  static final builtin = Catalog([
    const CatalogItem(
      id: 'board.walnut',
      category: ItemCategory.board,
      rarity: 'common',
      isDefault: true,
      theme: 'walnut',
      name: {'az': 'Klassik Qoz', 'en': 'Classic Walnut'},
      obtain: Obtain.defaultItem,
      look: BoardLook.walnut,
    ),
  ]);
}
