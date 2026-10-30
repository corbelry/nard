import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../cosmetics/catalog.dart';
import '../cosmetics/cosmetics_providers.dart';
import '../cosmetics/cosmetics_text.dart';
import '../l10n/gen/app_localizations.dart';
import '../online/api_client.dart' show ApiException;
import '../online/online_text.dart';
import '../online/rank.dart';
import '../social/social_gate.dart' show AsyncBody;
import '../store/inventory.dart';
import '../store/purchase_flow.dart' show buyGemPack;
import '../store/store_models.dart';
import '../store/store_providers.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/buttons.dart';
import '../ui/commerce.dart';
import '../ui/controls.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import 'season_models.dart';
import 'season_providers.dart';

/// "SEZON 4 · 18 GÜN 6 SAAT" (hours and minutes under a day).
String seasonOverline(AppLocalizations l, Season s) {
  final left = Duration(seconds: s.secondsLeft);
  return left.inDays >= 1
      ? l.seasonOverline(s.number, left.inDays, left.inHours % 24)
      : l.seasonOverlineHours(s.number, left.inHours, left.inMinutes % 60);
}

/// "Çərçivə + 2 000 sikkə" for a season-end reward.
String endRewardText(
  AppLocalizations l,
  EndReward r,
  Catalog catalog,
  String locale,
) {
  final coins = priceText(l, Currency.coins, r.coins);
  final item = catalog.item(r.itemId);
  if (r.itemId == null) return coins;
  final name =
      item == null ? l.seasonRewardItem : categoryName(l, item.category);
  return l.seasonRewardWithItem(name, coins);
}

/// 7.1 Season pass: level, free / premium tracks, season-end reward and
/// premium (Yaqut) / claim-all.
class SeasonPassScreen extends ConsumerWidget {
  const SeasonPassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nard;
    final season = ref.watch(seasonProvider);
    return Scaffold(
      backgroundColor: c.bgDeep,
      body: AccountGate(
        builder:
            (_) => AsyncBody<SeasonView?>(
              value: season,
              onRetry: () => ref.invalidate(seasonProvider),
              data:
                  (view) =>
                      view == null
                          ? const SizedBox.shrink()
                          : SeasonPassView(view: view),
            ),
      ),
    );
  }
}

class SeasonPassView extends ConsumerStatefulWidget {
  const SeasonPassView({super.key, required this.view});

  final SeasonView view;

  @override
  ConsumerState<SeasonPassView> createState() => _SeasonPassViewState();
}

class _SeasonPassViewState extends ConsumerState<SeasonPassView> {
  static const _col = 68.0;
  static const _gap = 8.0;
  late final _scroll = ScrollController(
    initialScrollOffset: max(0, (widget.view.level - 1) * (_col + _gap)),
  );
  bool _busy = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action, String done) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) showNote(context, done);
    } on Object catch (e) {
      if (mounted) {
        showNote(
          context,
          e is ApiException && e.offline
              ? l.onlineOfflineTitle
              : l.tourActionFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _tapReward(PassReward? r, int level, PassTrack track) {
    final l = AppLocalizations.of(context);
    final v = widget.view;
    if (r == null || r.claimed) return;
    if (r.claimable) {
      _run(
        () => ref.read(seasonProvider.notifier).claim(level, track),
        l.seasonClaimedToast,
      );
    } else if (track == PassTrack.premium && !v.premium) {
      showNote(context, l.seasonNeedsPremium);
    } else {
      showNote(context, l.seasonNeedsLevel(level));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final v = widget.view;
    final locale = Localizations.localeOf(context).languageCode;
    final catalog = ref.watch(currentCatalogProvider);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final target = v.targetTier ?? v.currentTier;
    final end = v.endRewardFor(target);
    final targetTier = tierNamed(target, 1500);
    final claimable = v.claimableCount;
    return DecoratedBox(
      decoration: BoxDecoration(gradient: c.seasonPassBg(c.seasonDefaultColor)),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ScreenHeader(title: '', bare: true),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Overline(
                    seasonOverline(l, v.season),
                    color: c.seasonDefaultInk,
                    spacing: .96,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    v.season.nameFor(locale),
                    style: NardType.displayL.copyWith(
                      fontSize: 30,
                      color: c.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c.accent,
                          borderRadius: BorderRadius.circular(NardRadius.m),
                        ),
                        child: Text(
                          '${v.level}',
                          style: NardType.clock.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: c.onAccent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    v.level >= v.levels
                                        ? l.seasonLevelMax
                                        : l.seasonLevelNext(v.level + 1),
                                    style: NardType.caption.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: c.text,
                                    ),
                                  ),
                                ),
                                Text(
                                  l.xpProgress(
                                    formatAmount(v.levelXp),
                                    formatAmount(v.xpPerLevel),
                                  ),
                                  style: NardType.caption.copyWith(
                                    fontWeight: FontWeight.w400,
                                    color: c.text.withValues(alpha: .7),
                                    fontFeatures: tabular,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            NardProgressBar(
                              value:
                                  v.xpPerLevel == 0
                                      ? 0
                                      : v.levelXp / v.xpPerLevel,
                              height: 6,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _track(context, l, c, v, catalog, locale),
                  if (end != null)
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: c.text.withValues(alpha: .04),
                        borderRadius: BorderRadius.circular(NardRadius.l),
                        border: Border.all(
                          color: c.accent.withValues(alpha: .16),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipPath(
                            clipper: HexClipper(),
                            child: Container(
                              width: 38,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: c.tierFill(targetTier),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.seasonEndReward(l.tierName(targetTier)),
                                  style: NardType.bodyS.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: c.text,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  v.targetTier == null || v.targetPoints == null
                                      ? l.seasonEndRewardReached(
                                        endRewardText(l, end, catalog, locale),
                                      )
                                      : l.seasonEndRewardMeta(
                                        endRewardText(l, end, catalog, locale),
                                        v.targetPoints!,
                                      ),
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
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, max(24, bottom + 8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (claimable > 0) ...[
                    NardButton(
                      label: l.seasonClaimAll(claimable),
                      variant:
                          v.premium
                              ? NardButtonVariant.primary
                              : NardButtonVariant.outline,
                      size: v.premium ? NardButtonSize.l : NardButtonSize.m,
                      onPressed:
                          _busy
                              ? null
                              : () => _run(
                                ref.read(seasonProvider.notifier).claimAll,
                                l.seasonClaimedToast,
                              ),
                    ),
                    if (!v.premium) const SizedBox(height: 10),
                  ],
                  if (!v.premium)
                    NardButton(
                      label: l.seasonPremiumUnlock,
                      height: 58,
                      trailing: PriceTag(
                        currency: Currency.gems,
                        amount: v.premiumGems,
                        color: c.primaryText,
                        fontSize: 17,
                      ),
                      onPressed:
                          _busy
                              ? null
                              : () => showNardSheet<bool>(
                                context,
                                builder:
                                    (_) =>
                                        PremiumPassSheet(price: v.premiumGems),
                              ),
                    )
                  else if (claimable == 0)
                    Text(
                      l.seasonPremiumOwned,
                      textAlign: TextAlign.center,
                      style: NardType.bodyS.copyWith(color: c.accentHi),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _track(
    BuildContext context,
    AppLocalizations l,
    NardColors c,
    SeasonView v,
    Catalog catalog,
    String locale,
  ) {
    Widget label(String text, Color color) => SizedBox(
      width: 62,
      child: Text(
        text,
        style: NardType.micro.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
    Widget levels(Widget Function(int level) cell) => Row(
      children: [
        for (var level = 1; level <= v.levels; level++) ...[
          if (level > 1) const SizedBox(width: _gap),
          SizedBox(width: _col, child: cell(level)),
        ],
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              SizedBox(
                height: _col * 4 / 3,
                child: Center(
                  child: label(l.seasonTrackFree, c.text.withValues(alpha: .6)),
                ),
              ),
              const SizedBox(height: _gap),
              SizedBox(
                height: _col * 4 / 3,
                child: Center(child: label(l.seasonTrackPremium, c.accentHi)),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    child: levels(
                      (level) => Center(
                        child: Text(
                          '$level',
                          style: NardType.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                level == v.level
                                    ? c.accentHi
                                    : c.text.withValues(alpha: .6),
                            fontFeatures: tabular,
                          ),
                        ),
                      ),
                    ),
                  ),
                  levels(
                    (level) => _tile(
                      context,
                      l,
                      c,
                      v,
                      v.reward(level, PassTrack.free),
                      level,
                      PassTrack.free,
                      catalog,
                      locale,
                    ),
                  ),
                  const SizedBox(height: _gap),
                  levels(
                    (level) => _tile(
                      context,
                      l,
                      c,
                      v,
                      v.reward(level, PassTrack.premium),
                      level,
                      PassTrack.premium,
                      catalog,
                      locale,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    AppLocalizations l,
    NardColors c,
    SeasonView v,
    PassReward? r,
    int level,
    PassTrack track,
    Catalog catalog,
    String locale,
  ) {
    final premium = track == PassTrack.premium;
    final item = r?.kind == RewardKind.item ? catalog.item(r?.itemId) : null;
    final seasonal = item?.rarity == 'seasonal';
    final Color ring;
    double width = 1;
    if (r?.claimable ?? false) {
      ring = c.successText;
      width = 1.5;
    } else if (r != null && !r.claimed && level == v.level + 1) {
      ring = c.accent;
      width = 1.5;
    } else if (seasonal) {
      ring = NardPalette.raritySeasonal;
      width = 1.5;
    } else {
      ring = premium ? c.accent.withValues(alpha: .3) : c.lineSoft;
    }
    final String text;
    Widget art;
    switch (r?.kind) {
      case RewardKind.coins:
        text = formatAmount(r!.amount ?? 0);
        art = const CurrencyIcon(Currency.coins, size: 24);
      case RewardKind.gems:
        text = formatAmount(r!.amount ?? 0);
        art = const CurrencyIcon(Currency.gems, size: 24);
      case RewardKind.item:
        text =
            item == null
                ? l.seasonRewardItem
                : '${categoryName(l, item.category)} · ${rarityName(l, item.rarity)}';
        art =
            item == null
                ? Icon(LucideIcons.gift, size: 20, color: c.accentHi)
                : ItemThumb(item: item, radius: 8);
      case null:
        text = '';
        art = const SizedBox.shrink();
    }
    final tile = AspectRatio(
      aspectRatio: 3 / 4,
      child: Opacity(
        opacity: (r?.claimed ?? false) ? .6 : 1,
        child: Container(
          decoration: BoxDecoration(
            color: premium ? null : c.text.withValues(alpha: .05),
            gradient: premium ? c.premiumTileFill : null,
            borderRadius: BorderRadius.circular(NardRadius.m),
            border: Border.all(color: ring, width: width),
          ),
          child: Stack(
            children: [
              if (r != null)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: Center(child: art),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: NardType.micro.copyWith(
                            fontSize: 10,
                            height: 12 / 10,
                            color: c.text,
                          ),
                        ),
                      ),
                      if (r.claimed)
                        Icon(LucideIcons.check, size: 12, color: c.successText),
                    ],
                  ),
                ),
              if (premium && !v.premium && r != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Icon(LucideIcons.lock, size: 12, color: c.accentHi),
                ),
            ],
          ),
        ),
      ),
    );
    return Pressable(
      onTap: _busy ? null : () => _tapReward(r, level, track),
      semanticLabel: text.isEmpty ? '$level' : text,
      child: tile,
    );
  }
}

/// 7.4-style confirm for the premium track: price, Yaqut after or the
/// covering pack, buy. Pops `true` on success.
class PremiumPassSheet extends ConsumerStatefulWidget {
  const PremiumPassSheet({super.key, required this.price});

  final int price;

  @override
  ConsumerState<PremiumPassSheet> createState() => _PremiumPassSheetState();
}

class _PremiumPassSheetState extends ConsumerState<PremiumPassSheet> {
  final _key = newIdempotencyKey();
  bool _busy = false;
  String? _error;

  Future<void> _run(Future<void> Function() action) async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (!mounted) return;
      showNote(context, l.seasonPremiumBought);
      Navigator.of(context).pop(true);
    } on Object catch (e) {
      if (mounted) {
        setState(
          () =>
              _error =
                  e is ApiException
                      ? (e.offline
                          ? l.onlineOfflineTitle
                          : e.code == 'iap_disabled'
                          ? l.storePackUnavailable
                          : l.purchaseFailed)
                      : l.purchaseFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final wallet = ref.watch(inventoryProvider).value?.wallet ?? const Wallet();
    final after = wallet.gems - widget.price;
    final products = ref.watch(gemProductsProvider).value;
    final pack = after < 0 ? products?.packFor(-after) : null;
    final buy = ref.read(seasonProvider.notifier).buyPremium;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetTitle(l.seasonPremiumSheetTitle),
        const SizedBox(height: 8),
        Text(
          l.seasonPremiumBody,
          style: NardType.bodyS.copyWith(color: c.text.withValues(alpha: .75)),
        ),
        const SizedBox(height: 12),
        KeyValueRow(
          label: l.purchasePrice,
          value: Text(priceText(l, Currency.gems, widget.price)),
        ),
        KeyValueRow(
          label: l.purchaseBalanceAfter,
          value:
              after >= 0
                  ? Text(priceText(l, Currency.gems, after))
                  : Text(
                    l.purchaseShortfall(formatAmount(-after)),
                    style: TextStyle(color: c.dangerText),
                  ),
        ),
        if (after < 0) ...[
          const SizedBox(height: 12),
          Text(
            l.purchaseNotEnoughGems(formatAmount(pack?.gems ?? -after)),
            style: NardType.bodyS.copyWith(color: c.text.withValues(alpha: .7)),
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
              child: CircularProgressIndicator(color: c.accent, strokeWidth: 2),
            ),
          )
        else if (after >= 0)
          NardButton(
            label: l.seasonPremiumUnlock,
            trailing: PriceTag(
              currency: Currency.gems,
              amount: widget.price,
              color: c.primaryText,
              fontSize: 16,
            ),
            onPressed: () => _run(() => buy(_key)),
          )
        else
          NardButton(
            label: l.purchaseBuyPack(formatAmount(pack?.gems ?? 0)),
            onPressed:
                pack == null
                    ? null
                    : () => _run(() async {
                      await buyGemPack(ref, pack);
                      await buy(_key);
                    }),
          ),
        const SizedBox(height: 4),
        NardButton(
          label: l.cancel,
          variant: NardButtonVariant.ghost,
          size: NardButtonSize.m,
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}
