import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../cosmetics/catalog.dart';
import '../cosmetics/cosmetics_text.dart';
import '../cosmetics/set_preview.dart';
import '../game/online_overlays.dart' show PeriodicBuilder;
import '../l10n/gen/app_localizations.dart';
import '../online/reachability.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/buttons.dart';
import '../ui/commerce.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import 'inventory.dart';
import 'purchase_flow.dart';
import 'store_models.dart';
import 'store_providers.dart';

/// 7.3 Store: the Mağaza tab root (featured offer, daily picks, Yaqut
/// packs). The Locker (3.1) opens from the header.
class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final offline = ref.watch(offlineProvider);
    final wallet = ref.watch(inventoryProvider).value?.wallet;
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OfflineBanner(text: l.offlineBanner, visible: offline),
          Row(
            children: [
              Expanded(child: RootTitle(l.tabStore)),
              if (wallet != null) ...[
                CurrencyPill(
                  currency: Currency.coins,
                  amount: wallet.coins,
                  compact: true,
                  onTap: () => context.go('/home/missions'),
                ),
                const SizedBox(width: 6),
                CurrencyPill(
                  currency: Currency.gems,
                  amount: wallet.gems,
                  compact: true,
                ),
                const SizedBox(width: 6),
              ],
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: NardIconButton(
                  icon: LucideIcons.shirt,
                  semanticLabel: l.lockerTitle,
                  size: 36,
                  onPressed: () => context.push('/store/locker'),
                ),
              ),
            ],
          ),
          Expanded(child: AccountGate(builder: (_) => const _StoreBody())),
        ],
      ),
    );
  }
}

class _StoreBody extends ConsumerWidget {
  const _StoreBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final offers = ref.watch(storeOffersProvider);
    final products = ref.watch(gemProductsProvider).value;
    final inventory = ref.watch(inventoryProvider).value;

    Future<void> refresh() async {
      ref.invalidate(storeOffersProvider);
      ref.invalidate(gemProductsProvider);
      await ref.read(inventoryProvider.notifier).refresh();
    }

    Future<void> open(CatalogItem item) async {
      final owned = inventory?.owns(item.id) ?? false;
      final action = await showItemDetail(context, item, owned: owned);
      if (!context.mounted) return;
      switch (action) {
        case ItemSheetAction.buy:
          await startPurchase(context, ref, item);
          ref.invalidate(storeOffersProvider);
        case ItemSheetAction.equip:
          await ref
              .read(inventoryProvider.notifier)
              .equip(item, defaultName: l.loadoutName(1));
        case ItemSheetAction.tryOn:
        case null:
          break;
      }
    }

    final value = offers.value;
    if (value == null) {
      if (offers.hasError) {
        return OfflineMessage(onRetry: refresh);
      }
      return Center(
        child: CircularProgressIndicator(color: c.accent, strokeWidth: 2),
      );
    }

    final featured = value.featured;
    return RefreshIndicator(
      color: c.accent,
      onRefresh: refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          if (featured != null) ...[
            _FeaturedCard(offer: featured, onTap: () => open(featured.item)),
            const SizedBox(height: 14),
          ],
          if (value.daily.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(child: Overline(l.storeDailyTitle)),
                if (value.refreshAt != null)
                  PeriodicBuilder(
                    period: const Duration(seconds: 1),
                    builder:
                        (_) => Text(
                          l.storeRefreshesIn(
                            formatCountdown(
                              value.refreshAt!.difference(DateTime.now()),
                            ),
                          ),
                          style: NardType.caption.copyWith(
                            fontWeight: FontWeight.w400,
                            color: c.text.withValues(alpha: .55),
                            fontFeatures: tabular,
                          ),
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _Grid(
              children: [
                for (final item in value.daily)
                  _DailyTile(item: item, onTap: () => open(item)),
              ],
            ),
            const SizedBox(height: 14),
          ],
          if (products != null && products.products.isNotEmpty) ...[
            Overline(l.storeGemsTitle),
            const SizedBox(height: 10),
            _Grid(
              children: [
                for (final p in products.products)
                  _GemPackTile(
                    pack: p,
                    onTap: () => startGemPack(context, ref, p),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A 3-column grid with 8 pt gaps that sizes rows to their content.
class _Grid extends StatelessWidget {
  const _Grid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 3) {
      if (i > 0) rows.add(const SizedBox(height: 8));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = i; j < i + 3; j++) ...[
                if (j > i) const SizedBox(width: 8),
                Expanded(
                  child: j < children.length ? children[j] : const SizedBox(),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.offer, required this.onTap});

  final FeaturedOffer offer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final item = offer.item;
    final locale = Localizations.localeOf(context).languageCode;
    final rarity = rarityColor(item.rarity);
    final price = item.price.primary;
    final ends = offer.endsAt;
    final days =
        ends == null
            ? null
            : (ends.difference(DateTime.now()).inHours / 24).ceil().clamp(
              1,
              99,
            );
    final look = item.look;
    return Pressable(
      onTap: onTap,
      semanticLabel: item.nameFor(locale),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: c.featuredFill(rarity),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: rarity.withValues(alpha: .5)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 14, 0, 6),
              child:
                  look != null
                      ? SetPreview(look: look, width: 300)
                      : SizedBox(
                        width: 160,
                        height: 120,
                        child: ItemThumb(item: item, radius: 16),
                      ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (days != null)
                          Overline(
                            l.storeFeaturedOverline(days),
                            color: rarity,
                            spacing: .88,
                          ),
                        const SizedBox(height: 3),
                        Text(
                          item.nameFor(locale),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NardType.title.copyWith(
                            fontSize: 20,
                            color: c.text,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          categoryName(l, item.category),
                          style: NardType.caption.copyWith(
                            fontWeight: FontWeight.w400,
                            color: c.textDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (price != null) ...[
                    const SizedBox(width: 10),
                    Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: c.accent,
                        borderRadius: BorderRadius.circular(NardRadius.m),
                      ),
                      alignment: Alignment.center,
                      child: PriceTag(
                        currency: price.$1,
                        amount: price.$2,
                        oldAmount: offer.oldPrice?.of(price.$1),
                        color: c.onAccent,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyTile extends StatelessWidget {
  const _DailyTile({required this.item, required this.onTap});

  final CatalogItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final price = item.price.primary;
    return RarityFrame(
      item: item,
      name: item.nameFor(locale),
      padding: 8,
      thumbHeight: 62,
      onTap: onTap,
      status:
          price == null
              ? const SizedBox()
              : PriceTag(currency: price.$1, amount: price.$2),
    );
  }
}

class _GemPackTile extends StatelessWidget {
  const _GemPackTile({required this.pack, required this.onTap});

  final GemProduct pack;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    return Pressable(
      onTap: onTap,
      semanticLabel: l.purchaseBuyPack(formatAmount(pack.gems)),
      minSize: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: c.text.withValues(alpha: .04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.tileRing),
        ),
        child: Column(
          children: [
            const CurrencyIcon(Currency.gems, size: 22),
            const SizedBox(height: 6),
            Text(
              formatAmount(pack.gems),
              style: NardType.labelM.copyWith(
                color: c.text,
                fontFeatures: tabular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
