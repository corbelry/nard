import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../app/providers.dart';
import '../l10n/gen/app_localizations.dart';
import '../online/api_client.dart';
import '../online/reachability.dart';
import '../store/inventory.dart';
import '../store/purchase_flow.dart';
import '../store/store_models.dart';
import '../store/store_providers.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/buttons.dart';
import '../ui/commerce.dart';
import '../ui/controls.dart';
import '../ui/extra_tokens.dart';
import '../ui/fields.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import 'catalog.dart';
import 'cosmetics_providers.dart';
import 'cosmetics_text.dart';
import 'set_preview.dart';

/// 3.1 Locker (Dolab): live preview, loadouts, categories, item grid and
/// the opponent-cosmetics toggle. Pushed from the Store header and 8.1.
class LockerScreen extends ConsumerWidget {
  const LockerScreen({super.key, this.category});

  /// Category to open first (e.g. after "İndi tax").
  final String? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final offline = ref.watch(offlineProvider);
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OfflineBanner(text: l.offlineBanner, visible: offline),
          Expanded(
            child: AccountGate(
              builder: (_) => _Locker(initialCategory: category),
            ),
          ),
        ],
      ),
    );
  }
}

class _Locker extends ConsumerStatefulWidget {
  const _Locker({this.initialCategory});

  final String? initialCategory;

  @override
  ConsumerState<_Locker> createState() => _LockerState();
}

class _LockerState extends ConsumerState<_Locker> {
  String? _category;

  /// Loadout being edited (null = the active one) and its unsaved slots.
  int? _editingId;
  Map<String, String>? _edited;

  /// Category → item tried on (not owned, not saved).
  final _preview = <String, String>{};
  bool _busy = false;

  Inventory? get _inventory => ref.read(inventoryProvider).value;

  Loadout? _loadout(Inventory inv) =>
      inv.loadouts.where((x) => x.id == _editingId).firstOrNull ?? inv.active;

  Map<String, String> _slots(Inventory inv) =>
      _edited ?? _loadout(inv)?.slots ?? const {};

  Future<void> _guard(Future<void> Function() action) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
    } on ApiException catch (e) {
      if (mounted) {
        showNote(
          context,
          e.offline
              ? l.onlineOfflineTitle
              : e.code == 'too_many_loadouts'
              ? l.lockerLoadoutLimit(Inventory.maxLoadouts)
              : l.errorTitle,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _equip(CatalogItem item) {
    final inv = _inventory;
    if (inv == null) return;
    setState(() {
      _preview.remove(item.category);
      _edited = {..._slots(inv), item.category: item.id};
    });
  }

  Future<void> _save() async {
    final inv = _inventory;
    final edited = _edited;
    if (inv == null || edited == null) return;
    final l = AppLocalizations.of(context);
    final loadout = _loadout(inv);
    await _guard(() async {
      await ref
          .read(inventoryProvider.notifier)
          .saveLoadout(
            loadout?.name ?? l.loadoutName(1),
            edited,
            id: loadout?.id,
          );
      if (mounted) {
        setState(() => _edited = null);
        showNote(context, l.lockerSaved);
      }
    });
  }

  Future<void> _switchTo(Loadout loadout) async {
    setState(() {
      _editingId = loadout.id;
      _edited = null;
      _preview.clear();
    });
    if (!loadout.active) {
      await _guard(
        () => ref.read(inventoryProvider.notifier).activate(loadout.id),
      );
    }
  }

  Future<void> _add(Inventory inv) async {
    final l = AppLocalizations.of(context);
    if (inv.loadouts.length >= Inventory.maxLoadouts) {
      showNote(context, l.lockerLoadoutLimit(Inventory.maxLoadouts));
      return;
    }
    final slots = _slots(inv);
    await _guard(() async {
      await ref
          .read(inventoryProvider.notifier)
          .saveLoadout(l.loadoutName(inv.loadouts.length + 1), slots);
      final fresh = _inventory;
      final created = fresh?.loadouts.lastOrNull;
      if (created != null && mounted) {
        await ref.read(inventoryProvider.notifier).activate(created.id);
        setState(() {
          _editingId = created.id;
          _edited = null;
        });
      }
    });
  }

  Future<void> _manage(Loadout loadout) async {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController(text: loadout.name);
    final result = await showNardSheet<(bool, String)>(
      context,
      builder:
          (ctx) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetTitle(l.lockerRenameTitle),
              const SizedBox(height: 14),
              NardTextField(controller: controller, maxLength: 24),
              const SizedBox(height: 16),
              NardButton(
                label: l.lockerRename,
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) Navigator.of(ctx).pop((false, name));
                },
              ),
              const SizedBox(height: 8),
              NardButton(
                label: l.lockerDelete,
                variant: NardButtonVariant.ghost,
                labelColor: ctx.nard.dangerText,
                onPressed: () => Navigator.of(ctx).pop((true, '')),
              ),
            ],
          ),
    );
    controller.dispose();
    if (result == null || !mounted) return;
    final notifier = ref.read(inventoryProvider.notifier);
    final (delete, name) = result;
    if (delete) {
      await _guard(() => notifier.deleteLoadout(loadout.id));
      if (mounted) {
        setState(() {
          _editingId = null;
          _edited = null;
        });
      }
    } else if (name != loadout.name) {
      await _guard(
        () => notifier.saveLoadout(name, loadout.slots, id: loadout.id),
      );
    }
  }

  Future<void> _tap(CatalogItem item, Inventory inv, bool owned) async {
    if (owned) {
      _equip(item);
      return;
    }
    setState(() => _preview[item.category] = item.id);
    final action = await showItemDetail(
      context,
      item,
      owned: false,
      canTry: true,
    );
    if (!mounted) return;
    switch (action) {
      case ItemSheetAction.buy:
        await startPurchase(context, ref, item);
      case ItemSheetAction.equip:
        _equip(item);
      case ItemSheetAction.tryOn:
        break;
      case null:
        setState(() => _preview.remove(item.category));
    }
  }

  Future<void> _details(CatalogItem item, bool owned) async {
    final action = await showItemDetail(context, item, owned: owned);
    if (action == ItemSheetAction.equip && mounted) _equip(item);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final inventoryState = ref.watch(inventoryProvider);
    final inv = inventoryState.value;
    final catalog = ref.watch(currentCatalogProvider);
    final settings = ref.watch(currentSettingsProvider);
    final locale = Localizations.localeOf(context).languageCode;

    if (inv == null) {
      if (inventoryState.hasError) {
        return OfflineMessage(onRetry: () => ref.invalidate(inventoryProvider));
      }
      return Center(
        child: CircularProgressIndicator(color: c.accent, strokeWidth: 2),
      );
    }

    // Titles are picked on 8.2, not in loadouts.
    final categories = [
      for (final cat in catalog.categories)
        if (cat != ItemCategory.title) cat,
    ];
    final category =
        categories.contains(_category)
            ? _category!
            : categories.contains(widget.initialCategory)
            ? widget.initialCategory!
            : (categories.firstOrNull ?? ItemCategory.board);
    final slots = _slots(inv);
    final previewLook = catalog.lookFor({...slots, ..._preview});
    final current = _loadout(inv);
    final items = catalog.inCategory(category);

    String? equippedId(String cat) => slots[cat] ?? catalog.defaultOf(cat)?.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.only(left: 4, right: 16),
            child: Row(
              children: [
                Pressable(
                  onTap: () => context.pop(),
                  semanticLabel:
                      MaterialLocalizations.of(context).backButtonTooltip,
                  child: Center(
                    child: Icon(
                      LucideIcons.chevronLeft,
                      size: 20,
                      color: c.text,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    l.lockerTitle,
                    style: NardType.displayL.copyWith(
                      fontSize: 24,
                      color: c.text,
                    ),
                  ),
                ),
                CurrencyPill(
                  currency: Currency.coins,
                  amount: inv.wallet.coins,
                  compact: true,
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 230,
          decoration: BoxDecoration(gradient: c.lockerGlow),
          alignment: Alignment.center,
          child: SetPreview(look: previewLook, tilted: true),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (inv.loadouts.isEmpty)
                        LoadoutChip(
                          label: l.loadoutName(1),
                          active: true,
                          onTap: () {},
                        ),
                      for (final loadout in inv.loadouts) ...[
                        LoadoutChip(
                          label: loadout.name,
                          active: loadout.id == current?.id,
                          onTap: () => _switchTo(loadout),
                          onLongPress: () => _manage(loadout),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (inv.loadouts.isNotEmpty &&
                          inv.loadouts.length < Inventory.maxLoadouts)
                        Pressable(
                          onTap: _busy ? null : () => _add(inv),
                          semanticLabel: l.lockerAddLoadout,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: c.line),
                            ),
                            child: Icon(
                              LucideIcons.plus,
                              size: 16,
                              color: c.accent,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (_edited != null || inv.loadouts.isEmpty)
                Pressable(
                  onTap: _busy || _edited == null ? null : _save,
                  semanticLabel: l.lockerSave,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Center(
                      child: Text(
                        l.lockerSave,
                        style: NardType.caption.copyWith(
                          color: _edited == null ? c.textFaint : c.accentHi,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 34,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder:
                (_, i) => CategoryChip(
                  label: categoryName(l, categories[i]),
                  selected: categories[i] == category,
                  onTap: () => setState(() => _category = categories[i]),
                ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child:
              items.isEmpty
                  ? MessageState(
                    title: l.lockerEmptyTitle,
                    body: l.lockerEmptyBody,
                  )
                  : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          mainAxisExtent: 120,
                        ),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final item = items[i];
                      final owned = inv.owns(item.id) || item.isDefault;
                      final equipped = equippedId(item.category) == item.id;
                      final previewing =
                          _preview[item.category] == item.id && !equipped;
                      final price = item.price.primary;
                      final Widget status;
                      Color? statusColor;
                      if (equipped) {
                        status = Text(l.itemEquipped);
                        statusColor = c.accentHi;
                      } else if (previewing) {
                        status = Text(l.itemPreviewing);
                        statusColor = c.accentHi;
                      } else if (owned) {
                        status = Text(l.itemOwned);
                      } else if (item.forSale && price != null) {
                        status = PriceTag(
                          currency: price.$1,
                          amount: price.$2,
                          fontSize: 11,
                          color: c.text.withValues(alpha: .6),
                        );
                      } else {
                        final obtain = switch (item.obtain) {
                          Obtain.season => l.itemSeason,
                          Obtain.tournament => l.itemTournamentReward,
                          Obtain.achievement => l.itemAchievementReward,
                          _ => l.comingSoon,
                        };
                        status = Text(obtain);
                      }
                      return RarityFrame(
                        item: item,
                        name: item.nameFor(locale),
                        status: status,
                        statusColor: statusColor,
                        equipped: equipped,
                        previewing: previewing,
                        locked: !owned,
                        onTap: () => _tap(item, inv, owned),
                        onLongPress: () => _details(item, owned),
                      );
                    },
                  ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 2, 12, 0),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: c.accent.withValues(alpha: .12)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l.lockerShowOpponentCosmetics,
                  style: NardType.bodyS.copyWith(color: c.text),
                ),
              ),
              NardSwitch(
                compact: true,
                semanticLabel: l.lockerShowOpponentCosmetics,
                value: settings.showOpponentCosmetics,
                onChanged:
                    (v) => ref
                        .read(settingsProvider.notifier)
                        .change((s) => s.copyWith(showOpponentCosmetics: v)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
