import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../cosmetics/catalog.dart';
import '../cosmetics/cosmetics_text.dart';
import '../cosmetics/set_preview.dart';
import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../online/api_client.dart';
import '../online/online_draft.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/buttons.dart';
import '../ui/commerce.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import 'inventory.dart';
import 'store_models.dart';
import 'store_providers.dart';

/// What buying [price] in [currency] does to [balance] (7.4).
class PurchaseQuote {
  const PurchaseQuote({
    required this.currency,
    required this.price,
    required this.balance,
  });

  final Currency currency;
  final int price;
  final int balance;

  int get after => balance - price;
  bool get affordable => after >= 0;
  int get shortfall => max(0, price - balance);

  static PurchaseQuote? of(CatalogItem item, Wallet wallet) {
    final p = item.price.primary;
    if (p == null) return null;
    return PurchaseQuote(currency: p.$1, price: p.$2, balance: wallet.of(p.$1));
  }
}

/// A finished purchase, shown on 7.5.
class PurchaseOutcome {
  const PurchaseOutcome({
    required this.currency,
    required this.amount,
    required this.receipt,
    this.item,
  });

  /// Null for a Yaqut pack (gems credited).
  final CatalogItem? item;
  final Currency currency;

  /// Price paid, or gems credited for a pack.
  final int amount;
  final String receipt;
}

/// "NA-7F3K-2291"-style reference from an idempotency key.
String receiptFor(String key) {
  final k = key.toUpperCase().padRight(8, '0');
  return 'NA-${k.substring(0, 4)}-${k.substring(4, 8)}';
}

String _purchaseError(AppLocalizations l, Object e) {
  if (e is ApiException) {
    if (e.offline) return l.onlineOfflineTitle;
    switch (e.code) {
      case 'already_owned':
        return l.purchaseAlreadyOwned;
      case 'not_for_sale':
        return l.purchaseNotForSale;
      case 'iap_disabled':
      case 'not_implemented':
        return l.storePackUnavailable;
    }
  }
  return l.purchaseFailed;
}

/// Buys a Yaqut pack. There is no store SDK yet (ADR-025 stub): debug
/// builds send a local `test-` receipt (compose `IAP_FAKE`), release
/// builds say it is not available yet. Returns the outcome on success.
Future<PurchaseOutcome?> buyGemPack(WidgetRef ref, GemProduct pack) async {
  if (!kDebugMode) {
    throw const ApiException(503, 'iap_disabled');
  }
  final key = newIdempotencyKey();
  await ref
      .read(apiClientProvider)
      .redeemIap(Platform.isIOS ? 'apple' : 'google', pack.id, 'test-$key');
  await ref.read(inventoryProvider.notifier).refresh();
  return PurchaseOutcome(
    currency: Currency.gems,
    amount: pack.gems,
    receipt: receiptFor(key),
  );
}

/// Store entry: sign in if needed, confirm (7.4), then 7.5 on success.
Future<void> startPurchase(
  BuildContext context,
  WidgetRef ref,
  CatalogItem item,
) async {
  if (!await ensureSignedIn(context, ref) || !context.mounted) return;
  final outcome = await showNardSheet<PurchaseOutcome>(
    context,
    builder: (_) => PurchaseConfirmSheet(item: item),
  );
  if (outcome != null && context.mounted) {
    await context.push('/purchased', extra: outcome);
  }
}

/// Pack tile tap on 7.3: buys and shows the pack success.
Future<void> startGemPack(
  BuildContext context,
  WidgetRef ref,
  GemProduct pack,
) async {
  final l = AppLocalizations.of(context);
  try {
    final outcome = await buyGemPack(ref, pack);
    if (outcome != null && context.mounted) {
      await context.push('/purchased', extra: outcome);
    }
  } on Object catch (e) {
    if (context.mounted) showNote(context, _purchaseError(l, e));
  }
}

/// 7.4 Confirm purchase sheet. Pops with a [PurchaseOutcome] once bought.
class PurchaseConfirmSheet extends ConsumerStatefulWidget {
  const PurchaseConfirmSheet({super.key, required this.item});

  final CatalogItem item;

  @override
  ConsumerState<PurchaseConfirmSheet> createState() =>
      _PurchaseConfirmSheetState();
}

class _PurchaseConfirmSheetState extends ConsumerState<PurchaseConfirmSheet> {
  bool _busy = false;
  String? _error;
  final _key = newIdempotencyKey();

  Future<void> _run(Future<PurchaseOutcome?> Function() action) async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final outcome = await action();
      if (!mounted) return;
      if (outcome != null) Navigator.of(context).pop(outcome);
    } on Object catch (e) {
      if (mounted) setState(() => _error = _purchaseError(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<PurchaseOutcome?> _buy(PurchaseQuote quote) async {
    await ref
        .read(inventoryProvider.notifier)
        .purchase(widget.item, quote.currency, idempotencyKey: _key);
    return PurchaseOutcome(
      item: widget.item,
      currency: quote.currency,
      amount: quote.price,
      receipt: receiptFor(_key),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final item = widget.item;
    final locale = Localizations.localeOf(context).languageCode;
    final rarity = rarityColor(item.rarity);
    final wallet = ref.watch(inventoryProvider).value?.wallet ?? const Wallet();
    final quote = PurchaseQuote.of(item, wallet);
    final products = ref.watch(gemProductsProvider).value;

    final rows = <Widget>[];
    Widget? note;
    Widget primary;
    if (quote == null) {
      primary = NardButton(label: l.purchaseNotForSale, onPressed: null);
    } else {
      rows.addAll([
        KeyValueRow(
          label: l.purchasePrice,
          value: Text(priceText(l, quote.currency, quote.price)),
        ),
        KeyValueRow(
          label: l.purchaseBalanceAfter,
          value:
              quote.affordable
                  ? Text(priceText(l, quote.currency, quote.after))
                  : Text(
                    l.purchaseShortfall(formatAmount(quote.shortfall)),
                    style: TextStyle(color: c.dangerText),
                  ),
        ),
      ]);
      if (quote.affordable) {
        primary = NardButton(
          label: l.itemBuy,
          trailing: PriceTag(
            currency: quote.currency,
            amount: quote.price,
            color: c.primaryText,
            fontSize: 16,
          ),
          onPressed: _busy ? null : () => _run(() => _buy(quote)),
        );
      } else if (quote.currency == Currency.gems) {
        final pack = products?.packFor(quote.shortfall);
        note = Text(
          l.purchaseNotEnoughGems(formatAmount(pack?.gems ?? quote.shortfall)),
        );
        primary = NardButton(
          label: l.purchaseBuyPack(formatAmount(pack?.gems ?? 0)),
          onPressed:
              _busy || pack == null
                  ? null
                  : () => _run(() async {
                    await buyGemPack(ref, pack);
                    return _buy(quote);
                  }),
        );
      } else {
        note = Text(l.purchaseNotEnoughCoins);
        primary = NardButton(
          label: l.purchaseToMissions,
          onPressed: () {
            Navigator.of(context).pop();
            context.go('/home/missions');
          },
        );
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: rarity, width: 1.5),
                ),
                child: ItemThumb(item: item, radius: 10),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Overline(
                      rarityUpper(l, item.rarity),
                      color: rarity,
                      spacing: .66,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.nameFor(locale),
                      maxLines: 2,
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
                        color: c.text.withValues(alpha: .6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: c.accent.withValues(alpha: .14)),
              ),
            ),
            child: Column(children: rows),
          ),
          if (note != null) ...[
            const SizedBox(height: 16),
            DefaultTextStyle(
              style: NardType.bodyS.copyWith(
                color: c.text.withValues(alpha: .7),
              ),
              child: note,
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: NardType.bodyS.copyWith(color: c.dangerText)),
          ],
          const SizedBox(height: 16),
          if (_busy)
            SizedBox(
              height: NardButtonSize.l.height,
              child: Center(
                child: CircularProgressIndicator(
                  color: c.accent,
                  strokeWidth: 2,
                ),
              ),
            )
          else
            primary,
          const SizedBox(height: 4),
          NardButton(
            label: l.cancel,
            variant: NardButtonVariant.ghost,
            size: NardButtonSize.m,
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

/// What the item sheet (3.2) asks the caller to do.
enum ItemSheetAction { tryOn, buy, equip }

/// 3.2 Item detail. [canTry] shows "Sına" (Locker preview).
Future<ItemSheetAction?> showItemDetail(
  BuildContext context,
  CatalogItem item, {
  required bool owned,
  bool canTry = false,
}) => showTallSheet<ItemSheetAction>(
  context,
  rarity: rarityColor(item.rarity),
  builder: (_) => _ItemDetail(item: item, owned: owned, canTry: canTry),
);

class _ItemDetail extends StatelessWidget {
  const _ItemDetail({
    required this.item,
    required this.owned,
    required this.canTry,
  });

  final CatalogItem item;
  final bool owned;
  final bool canTry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final locale = Localizations.localeOf(context).languageCode;
    final rarity = rarityColor(item.rarity);
    final look = item.look;
    final price = item.price.primary;
    final description = item.descriptionFor(locale);

    final obtain = <(String, String)>[
      if (item.isDefault) (l.obtainDefault, l.obtainFree),
      if (item.forSale && price != null)
        (l.obtainStore, priceText(l, price.$1, price.$2)),
      if (item.obtain == Obtain.season) (l.obtainSeasonPremium, l.comingSoon),
      if (item.obtain == Obtain.tournament) (l.obtainTournament, l.comingSoon),
      if (item.obtain == Obtain.achievement)
        (
          l.obtainAchievement,
          titleAchievements[item.id] == null
              ? l.achGeneric
              : achievementName(l, titleAchievements[item.id]!),
        ),
    ];

    Widget? primary;
    if (owned) {
      if (item.category != ItemCategory.title) {
        primary = NardButton(
          label: l.itemEquip,
          onPressed: () => Navigator.of(context).pop(ItemSheetAction.equip),
        );
      }
    } else if (item.forSale && price != null) {
      primary = NardButton(
        label: l.itemBuy,
        trailing: PriceTag(
          currency: price.$1,
          amount: price.$2,
          color: c.primaryText,
          fontSize: 16,
        ),
        onPressed: () => Navigator.of(context).pop(ItemSheetAction.buy),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child:
                  look != null
                      ? DecoratedBox(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: rarity.withValues(alpha: .35),
                              blurRadius: 30,
                            ),
                          ],
                        ),
                        child: SetPreview(look: look, width: 354),
                      )
                      : SizedBox(
                        width: 160,
                        height: 120,
                        child: ItemThumb(item: item, radius: 16),
                      ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Overline(
                rarityUpper(l, item.rarity),
                color: rarity,
                spacing: .96,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  categoryName(l, item.category),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NardType.caption.copyWith(
                    fontWeight: FontWeight.w400,
                    color: c.text.withValues(alpha: .55),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.nameFor(locale),
            style: NardType.displayL.copyWith(color: c.text),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              description,
              style: NardType.body.copyWith(
                fontSize: 14,
                color: c.text.withValues(alpha: .7),
              ),
            ),
          ],
          if (obtain.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: c.accent.withValues(alpha: .14)),
                ),
              ),
              child: Overline(
                l.itemObtainTitle,
                color: c.text.withValues(alpha: .6),
              ),
            ),
            for (final (label, value) in obtain)
              KeyValueRow(
                label: label,
                padding: 10,
                value: Text(
                  value,
                  style: TextStyle(
                    color: c.textDim,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              if (canTry && look != null && !owned) ...[
                Expanded(
                  child: NardButton(
                    label: l.itemTry,
                    variant: NardButtonVariant.outline,
                    onPressed:
                        () => Navigator.of(context).pop(ItemSheetAction.tryOn),
                  ),
                ),
                if (primary != null) const SizedBox(width: 10),
              ],
              if (primary != null) Expanded(flex: 2, child: primary),
            ],
          ),
        ],
      ),
    );
  }
}

/// 7.5 Purchase success (full screen, no tab bar).
class PurchaseSuccessScreen extends ConsumerStatefulWidget {
  const PurchaseSuccessScreen({super.key, required this.outcome});

  final PurchaseOutcome outcome;

  @override
  ConsumerState<PurchaseSuccessScreen> createState() =>
      _PurchaseSuccessScreenState();
}

class _PurchaseSuccessScreenState extends ConsumerState<PurchaseSuccessScreen> {
  bool _busy = false;

  Future<void> _equip(CatalogItem item) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref
          .read(inventoryProvider.notifier)
          .equip(item, defaultName: l.loadoutName(1));
      if (mounted) context.go('/store/locker?category=${item.category}');
    } on Object catch (e) {
      if (mounted) showNote(context, _purchaseError(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final o = widget.outcome;
    final item = o.item;
    final locale = Localizations.localeOf(context).languageCode;
    final rarity =
        item == null ? NardPalette.garnet400 : rarityColor(item.rarity);
    final reduce = MediaQuery.disableAnimationsOf(context);
    final look = item?.look;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: c.successBg(rarity)),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: reduce ? 1 : .6, end: 1),
                        duration: NardMotion.sheetIn,
                        curve: NardMotion.standard,
                        builder:
                            (_, s, child) =>
                                Transform.scale(scale: s, child: child),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: c.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.check,
                            size: 34,
                            color: NardPalette.ivory100,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        item == null
                            ? l.storePackAdded(formatAmount(o.amount))
                            : l.purchaseOwnedTitle(item.nameFor(locale)),
                        textAlign: TextAlign.center,
                        style: NardType.displayL.copyWith(color: c.text),
                      ),
                      const SizedBox(height: 18),
                      if (look != null)
                        SetPreview(look: look, width: 320)
                      else if (item != null)
                        SizedBox(
                          width: 160,
                          height: 120,
                          child: ItemThumb(item: item, radius: 16),
                        )
                      else
                        const CurrencyIcon(Currency.gems, size: 48),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: c.tile,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: DefaultTextStyle(
                          style: NardType.caption.copyWith(
                            fontWeight: FontWeight.w400,
                            color: c.text.withValues(alpha: .7),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(l.purchaseReceipt)),
                                  Text(o.receipt, style: NardType.mono),
                                ],
                              ),
                              // A pack's price lives in the platform store.
                              if (item != null) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(child: Text(l.purchasePaid)),
                                    Text(priceText(l, o.currency, o.amount)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Row(
                  children: [
                    Expanded(
                      flex: 10,
                      child: NardButton(
                        label: l.purchaseClose,
                        variant: NardButtonVariant.outline,
                        onPressed: () => context.pop(),
                      ),
                    ),
                    if (item != null &&
                        item.category != ItemCategory.title) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 14,
                        child: NardButton(
                          label: l.purchaseEquipNow,
                          onPressed: _busy ? null : () => _equip(item),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
