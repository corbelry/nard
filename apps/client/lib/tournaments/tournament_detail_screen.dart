import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../cosmetics/catalog.dart' show Currency;
import '../cosmetics/cosmetics_providers.dart';
import '../cosmetics/cosmetics_text.dart';
import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../social/social_gate.dart' show AsyncBody;
import '../store/inventory.dart';
import '../store/store_providers.dart' show showNote;
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/buttons.dart';
import '../ui/commerce.dart';
import '../ui/competition.dart';
import '../ui/controls.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import 'tournament_models.dart';
import 'tournament_providers.dart';
import 'tournament_text.dart';

/// 4.2 Tournament detail: hero, countdown, prize pool, entrants, prizes,
/// rules and the registration CTA in all its states.
class TournamentDetailScreen extends ConsumerWidget {
  const TournamentDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nard;
    return Scaffold(
      backgroundColor: c.bg,
      body: AsyncBody<TournamentDetail>(
        value: ref.watch(tournamentDetailProvider(id)),
        onRetry: () => ref.invalidate(tournamentDetailProvider(id)),
        data: (d) => _DetailView(detail: d),
      ),
    );
  }
}

class _DetailView extends ConsumerStatefulWidget {
  const _DetailView({required this.detail});

  final TournamentDetail detail;

  @override
  ConsumerState<_DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends ConsumerState<_DetailView> {
  Timer? _tick;
  bool _busy = false;
  String _key = newIdempotencyKey();

  Tournament get _t => widget.detail.tournament;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _t.startsAt != null) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _refresh() {
    ref
      ..invalidate(tournamentDetailProvider(_t.id))
      ..invalidate(tournamentListProvider)
      ..invalidate(homeTournamentProvider);
  }

  Future<void> _register() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final (_, wallet) = await ref
          .read(apiClientProvider)
          .registerTournament(_t.id, idempotencyKey: _key);
      ref.read(inventoryProvider.notifier).setWallet(wallet);
      _refresh();
      if (mounted) showNote(context, l.tourRegisteredToast);
    } on Object catch (e) {
      if (mounted) showNote(context, tournamentError(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _unregister() async {
    final l = AppLocalizations.of(context);
    final ok = await confirmSheet(
      context,
      title: l.tourUnregisterTitle,
      body: _t.paid ? l.tourUnregisterBody : l.tourUnregisterBodyFree,
      action: l.tourUnregister,
      cancel: l.cancel,
      danger: true,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      final (_, wallet) = await ref
          .read(apiClientProvider)
          .unregisterTournament(_t.id);
      ref.read(inventoryProvider.notifier).setWallet(wallet);
      // A refunded key cannot pay again (idempotency_key_reused).
      _key = newIdempotencyKey();
      _refresh();
      if (mounted) showNote(context, l.tourUnregisteredToast);
    } on Object catch (e) {
      if (mounted) showNote(context, tournamentError(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final t = _t;
    final locale = Localizations.localeOf(context).languageCode;
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final statusWord = switch (t.status) {
      TournamentStatus.registering => l.tourStatusUpcoming,
      TournamentStatus.running => l.tourLive,
      TournamentStatus.finished => l.tourStatusFinished,
      TournamentStatus.cancelled => l.tourStatusCancelled,
    };
    final dim = NardType.caption.copyWith(
      fontWeight: FontWeight.w400,
      color: c.text.withValues(alpha: .6),
    );
    final catalog = ref.watch(currentCatalogProvider);
    final itemPrizes = [
      for (final p in t.prizes)
        for (final id in p.items) (p, catalog.item(id)),
    ];
    final startsIn = t.startsAt?.difference(DateTime.now());

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: 203 + top,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const PosterFallback(),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [c.bg.withValues(alpha: 0), c.bg],
                          stops: const [.7, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 4,
                      top: top,
                      child: Pressable(
                        onTap: () => Navigator.of(context).maybePop(),
                        semanticLabel:
                            MaterialLocalizations.of(context).backButtonTooltip,
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(
                            LucideIcons.chevronLeft,
                            size: 20,
                            color: NardPalette.ivory100,
                            shadows: c.elevation2,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TournamentStatusLabel(
                            text: l.tourHeroMeta(
                              statusWord,
                              typeUpper(l, t),
                              t.size,
                            ),
                            color:
                                t.live
                                    ? c.dangerText
                                    : t.registering
                                    ? c.accentHi
                                    : c.text.withValues(alpha: .6),
                            dot: t.live,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t.nameFor(locale),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: NardType.displayL.copyWith(color: c.text),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (t.live) ...[
                                Text(
                                  l.tourLiveRound(
                                    max(1, t.currentRound),
                                    stageForCurrent(l, t),
                                  ),
                                  style: NardType.title.copyWith(
                                    fontSize: 22,
                                    color: c.text,
                                  ),
                                ),
                              ] else if (t.registering && startsIn != null) ...[
                                Text(l.tourStartsIn, style: dim),
                                const SizedBox(height: 2),
                                Text(
                                  formatCountdown(startsIn),
                                  style: NardType.clock.copyWith(
                                    fontSize: 30,
                                    color: c.text,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(l.tourPrizeFund, style: dim),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const CurrencyIcon(Currency.coins, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  formatAmount(t.prizeFund),
                                  style: NardType.score.copyWith(
                                    color: c.accentHi,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l.tourParticipants,
                            style: NardType.bodyS.copyWith(color: c.text),
                          ),
                        ),
                        Text(
                          l.tourParticipantsValue(t.entrants, t.size),
                          style: NardType.bodyS.copyWith(
                            color: c.text,
                            fontFeatures: tabular,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    NardProgressBar(
                      value: t.size == 0 ? 0 : t.entrants / t.size,
                      height: 6,
                      track: c.text.withValues(alpha: .1),
                    ),
                    if (prizeTiles(t, locale).isNotEmpty) ...[
                      const SizedBox(height: 16),
                      PrizeTiles(tiles: prizeTiles(t, locale)),
                    ],
                    for (final (prize, item) in itemPrizes)
                      if (item != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: ItemThumb(item: item, radius: 8),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item.category == 'title'
                                      ? l.tourTitlePrize(item.nameFor(locale))
                                      : item.nameFor(locale),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: NardType.bodyS.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: rarityColor(item.rarity),
                                  ),
                                ),
                              ),
                              Text(
                                prize.from == prize.to
                                    ? ordinal(locale, prize.from)
                                    : '${prize.from}–${prize.to}',
                                style: dim,
                              ),
                            ],
                          ),
                        ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: c.accent.withValues(alpha: .14),
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          KeyValueRow(
                            label: l.roomSettingVariant,
                            value: Text(variantName(l, t.variant)),
                            padding: 10,
                          ),
                          KeyValueRow(
                            label: l.roomSettingFormat,
                            value: Text(
                              l.tourFormatValue(typeName(l, t), t.matchLength),
                            ),
                            padding: 10,
                          ),
                          KeyValueRow(
                            label: l.roomSettingTime,
                            value: Text(
                              l.timeValue(
                                t.clockReserveMs ~/ 60000,
                                t.clockDelayMs ~/ 1000,
                              ),
                            ),
                            padding: 10,
                          ),
                          KeyValueRow(
                            label: l.tourRuleEntry,
                            value: Text(_entryText(l, t)),
                            padding: 10,
                          ),
                          KeyValueRow(
                            label: l.tourRuleRating,
                            value: Text(l.tourRuleUnrated),
                            padding: 10,
                          ),
                          KeyValueRow(
                            label: l.tourRuleFairDice,
                            value: Text(l.tourFairDiceValue),
                            padding: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, max(24, bottom + 8)),
          child: _cta(context, l, c),
        ),
      ],
    );
  }

  String _entryText(AppLocalizations l, Tournament t) {
    if (t.entryKind == EntryKind.invite) return l.tourEntryInvite;
    final price =
        t.paid ? priceText(l, Currency.coins, t.entryCoins) : l.privateTourFree;
    final min = t.minRating;
    return min == null ? price : l.tourEntryValue(price, min);
  }

  Widget _cta(BuildContext context, AppLocalizations l, NardColors c) {
    final t = _t;
    if (_busy) {
      return SizedBox(
        height: 58,
        child: Center(
          child: CircularProgressIndicator(color: c.accent, strokeWidth: 2),
        ),
      );
    }
    final account = ref.watch(accountProvider).value;
    if (account == null) {
      return NardButton(
        label: l.authSignIn,
        height: 58,
        onPressed: () => context.push('/signin'),
      );
    }
    void bracket() => context.push(
      t.type == TournamentType.knockout
          ? '/tournaments/${t.id}/bracket'
          : '/tournaments/${t.id}/standings',
    );
    switch (t.status) {
      case TournamentStatus.running:
        return t.stillIn
            ? NardButton(
              label: l.tourOpenBracket,
              height: 58,
              onPressed: bracket,
            )
            : NardButton(
              label: l.tourWatch,
              variant: NardButtonVariant.outline,
              height: 58,
              onPressed: bracket,
            );
      case TournamentStatus.finished:
        return NardButton(
          label: l.tourOpenBracket,
          variant: NardButtonVariant.outline,
          height: 58,
          onPressed: bracket,
        );
      case TournamentStatus.cancelled:
        return const SizedBox.shrink();
      case TournamentStatus.registering:
        break;
    }
    if (t.myStatus == MyTournamentStatus.registered) {
      return NardButton(
        label: l.tourUnregister,
        variant: NardButtonVariant.outline,
        height: 58,
        onPressed: _unregister,
      );
    }
    if (t.entryKind == EntryKind.invite) {
      return NardButton(
        label: l.tourInviteOnly,
        height: 58,
        onPressed: () => context.push('/tournaments/join'),
      );
    }
    if (t.full) {
      return NardButton(label: l.tourFull, height: 58, onPressed: null);
    }
    final rating = account.ratings[t.variant.name]?.rating;
    final min = t.minRating;
    if (min != null && rating != null && rating < min) {
      return NardButton(
        label: l.tourMinRating(min),
        height: 58,
        onPressed: null,
      );
    }
    if (!t.paid) {
      return NardButton(
        label: l.tourRegisterFree,
        height: 58,
        onPressed: _register,
      );
    }
    final wallet = ref.watch(inventoryProvider).value?.wallet;
    final poor = wallet != null && wallet.coins < t.entryCoins;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NardButton(
          label: l.tourRegister,
          height: 58,
          trailing: PriceTag(
            currency: Currency.coins,
            amount: t.entryCoins,
            color: poor ? null : c.primaryText,
            fontSize: 17,
          ),
          onPressed: poor ? null : _register,
        ),
        if (poor) ...[
          const SizedBox(height: 10),
          Text(
            l.purchaseNotEnoughCoins,
            textAlign: TextAlign.center,
            style: NardType.bodyS.copyWith(color: c.text.withValues(alpha: .7)),
          ),
        ],
      ],
    );
  }
}
