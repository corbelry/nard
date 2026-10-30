import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nard_core/nard_core.dart' show Side;
import 'package:nard_protocol/nard_protocol.dart';

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
import '../ui/competition.dart';
import '../ui/extra_tokens.dart';
import '../ui/identity.dart';
import '../ui/layout.dart';
import 'tournament_models.dart';
import 'tournament_providers.dart';
import 'tournament_text.dart';

/// 4.5 Champion ceremony (my place 1): trophy slot, prizes, share (text
/// copied; no share plugin) and continue.
class ChampionScreen extends ConsumerWidget {
  const ChampionScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nard;
    final detail = ref.watch(tournamentDetailProvider(id));
    if (!detail.hasValue) {
      return Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(gradient: c.championBg),
          child: AsyncBody<TournamentDetail>(
            value: detail,
            onRetry: () => ref.invalidate(tournamentDetailProvider(id)),
            data: (_) => const SizedBox.shrink(),
          ),
        ),
      );
    }
    return ChampionView(detail: detail.requireValue);
  }
}

class ChampionView extends ConsumerWidget {
  const ChampionView({super.key, required this.detail});

  final TournamentDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final t = detail.tournament;
    final locale = Localizations.localeOf(context).languageCode;
    final account = ref.watch(accountProvider).value;
    final me = account?.id;
    final myName = account?.name ?? '';
    final name = t.nameFor(locale);
    final catalog = ref.watch(currentCatalogProvider);
    // The final: last round's match with me.
    String? finalLine;
    if (detail.rounds.isNotEmpty) {
      for (final m in detail.rounds.last.matches) {
        if (!m.involves(me)) continue;
        final score = m.score;
        final white = m.white?.id == me;
        final opp = white ? m.black : m.white;
        if (score != null && opp != null) {
          finalLine = l.championFinal(
            white
                ? l.gameScore(score.$1, score.$2)
                : l.gameScore(score.$2, score.$1),
            opp.name,
          );
        }
      }
    }
    final place = t.myPlace ?? 1;
    final prize =
        t.prizes.where((p) => p.from <= place && place <= p.to).firstOrNull;
    final animate = !MediaQuery.of(context).disableAnimations;
    return CelebrationLayout(
      background: c.championBg,
      gap: 22,
      padding: 24,
      content: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: animate ? .6 : 1, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          builder: (_, v, child) => Transform.scale(scale: v, child: child),
          child: Container(
            width: 200,
            height: 240,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(NardRadius.l),
              border: Border.all(color: c.accentHi.withValues(alpha: .4)),
            ),
            child: CustomPaint(
              painter: StripesPainter(color: c.text.withValues(alpha: .07)),
              child: Center(
                child: Icon(LucideIcons.trophy, size: 72, color: c.accentHi),
              ),
            ),
          ),
        ),
        const OrnamentDivider(),
        Text(
          l.championTitle,
          style: NardType.displayXl.copyWith(color: c.accentHi),
        ),
        Column(
          children: [
            Text(
              l.championLine(myName, name),
              textAlign: TextAlign.center,
              style: NardType.body.copyWith(
                height: 22 / 15,
                color: c.text.withValues(alpha: .8),
              ),
            ),
            if (finalLine != null)
              Text(
                finalLine,
                textAlign: TextAlign.center,
                style: NardType.body.copyWith(
                  height: 22 / 15,
                  color: c.text.withValues(alpha: .8),
                ),
              ),
          ],
        ),
        if (prize != null)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (prize.coins > 0)
                RewardPill(
                  label: l.rewardCoins(formatAmount(prize.coins)),
                  fill: c.accent.withValues(alpha: .18),
                  color: c.text,
                  coin: true,
                ),
              for (final id in prize.items)
                if (catalog.item(id) case final item?)
                  RewardPill(
                    label:
                        item.category == 'title'
                            ? l.tourTitlePrize(item.nameFor(locale))
                            : item.nameFor(locale),
                    fill: NardPalette.rarityLegendary.withValues(alpha: .18),
                    color: c.titlePrizeText,
                  ),
            ],
          ),
      ],
      footer: [
        Row(
          children: [
            Expanded(
              child: NardButton(
                label: l.championShare,
                variant: NardButtonVariant.outline,
                height: 54,
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: l.championShareText(myName, name)),
                  );
                  if (context.mounted) {
                    showNote(context, l.championShareCopied);
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: NardButton(
                label: l.continueAction,
                height: 54,
                onPressed:
                    () =>
                        context.canPop()
                            ? context.pop()
                            : context.go('/tournaments'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 21.2 Opponent no-show: my avatar, the empty seat and the countdown to
/// the walkover (3 min by default, QUESTIONS #35). A walkover replaces it with 21.3.
class NoShowScreen extends ConsumerStatefulWidget {
  const NoShowScreen({super.key, required this.state});

  final TournamentReadyStatePayload state;

  @override
  ConsumerState<NoShowScreen> createState() => _NoShowScreenState();
}

class _NoShowScreenState extends ConsumerState<NoShowScreen> {
  Timer? _tick;
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _onLive(TournamentLive? _, TournamentLive live) {
    if (_gone) return;
    final s = widget.state;
    final current = live.ready[s.matchId];
    for (final w in live.walkovers) {
      if (w.matchId != s.matchId) continue;
      _gone = true;
      ref.read(tournamentSocketProvider.notifier).consumeWalkover(w.matchId);
      if (w.winner == s.you) {
        context.pushReplacement('/tournament/walkover', extra: w);
      } else {
        context.pushReplacement('/tournaments/${s.tournamentId}/bracket');
      }
      return;
    }
    // The opponent arrived: the match starts (VS opens from the tab shell).
    if (current != null && (current.ready[current.you.opponent] ?? false)) {
      _gone = true;
      if (context.canPop()) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<TournamentLive>(tournamentSocketProvider, _onLive);
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final s =
        ref.watch(tournamentSocketProvider).ready[widget.state.matchId] ??
        widget.state;
    final me = s.you == Side.white ? s.white : s.black;
    final opp = s.you == Side.white ? s.black : s.white;
    final left = max(0, s.deadline - DateTime.now().millisecondsSinceEpoch);
    final total = s.noShowSeconds * 1000;
    final seconds = (left / 1000).ceil();
    final label =
        '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
    return CelebrationLayout(
      background: c.bgGradient,
      padding: 28,
      gap: 16,
      content: [
        Overline(
          l.noShowOverline(s.round, tableOf(s.matchId) ?? 1),
          color: c.accent,
          spacing: .96,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Avatar(name: me.name, size: 72),
            const SizedBox(width: 18),
            Text(
              l.vsLabel,
              style: NardType.title.copyWith(
                fontSize: 22,
                fontStyle: FontStyle.italic,
                color: c.accentHi,
              ),
            ),
            const SizedBox(width: 18),
            Container(
              width: 72,
              height: 72,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: c.text.withValues(alpha: .25),
                  width: 2,
                ),
              ),
              child: CustomPaint(
                painter: StripesPainter(
                  color: c.text.withValues(alpha: .07),
                  width: 4,
                  gap: 8,
                ),
                child: Center(
                  child: Text(
                    opp.name.isEmpty ? '?' : opp.name.characters.first,
                    style: NardType.title.copyWith(
                      fontSize: 28,
                      color: c.text.withValues(alpha: .4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Text(
          l.noShowTitle,
          textAlign: TextAlign.center,
          style: NardType.displayL.copyWith(
            fontSize: 26,
            height: 32 / 26,
            color: c.text,
          ),
        ),
        Text(
          l.noShowBody(opp.name),
          textAlign: TextAlign.center,
          style: NardType.body.copyWith(
            fontSize: 14,
            height: 21 / 14,
            color: c.text.withValues(alpha: .7),
          ),
        ),
        const SizedBox(height: 8),
        CountdownRing(fraction: left / total, label: label),
      ],
      footer: [
        NardButton(
          label: l.tourBracket,
          variant: NardButtonVariant.outline,
          onPressed:
              () => context.pushReplacement(
                '/tournaments/${s.tournamentId}/bracket',
              ),
        ),
      ],
    );
  }
}

/// 21.3 Walkover win: next round (once the other matches end), unrated.
class WalkoverScreen extends ConsumerWidget {
  const WalkoverScreen({super.key, required this.walkover});

  final TournamentWalkoverPayload walkover;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final ready = ref.watch(tournamentSocketProvider).ready[walkover.matchId];
    final opp =
        ready == null
            ? ''
            : (ready.you == Side.white ? ready.black : ready.white).name;
    final round =
        ready?.round ??
        int.tryParse(walkover.matchId.split('-').elementAtOrNull(1) ?? '') ??
        1;
    return CelebrationLayout(
      background: c.walkoverBg,
      content: [
        const SuccessDisc(),
        Text(
          l.walkoverTitle,
          textAlign: TextAlign.center,
          style: NardType.displayL.copyWith(fontSize: 26, color: c.text),
        ),
        Text(
          l.walkoverBody(opp),
          textAlign: TextAlign.center,
          style: NardType.body.copyWith(
            fontSize: 14,
            height: 21 / 14,
            color: c.text.withValues(alpha: .7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.text.withValues(alpha: .04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.accent.withValues(alpha: .18)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l.walkoverNextRound(round + 1),
                  style: NardType.body.copyWith(
                    fontSize: 14,
                    color: c.text.withValues(alpha: .65),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  l.walkoverNextRoundWhen,
                  textAlign: TextAlign.end,
                  style: NardType.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      footer: [
        NardButton(
          label: l.tourOpenBracket,
          onPressed:
              () => context.pushReplacement(
                '/tournaments/${walkover.tournamentId}/bracket',
              ),
        ),
      ],
    );
  }
}

/// 21.4 Tournament not filled: refunded entry, offer a smaller sit-and-go
/// table.
class NotFilledScreen extends ConsumerStatefulWidget {
  const NotFilledScreen({super.key, required this.tournament});

  final Tournament tournament;

  @override
  ConsumerState<NotFilledScreen> createState() => _NotFilledScreenState();
}

class _NotFilledScreenState extends ConsumerState<NotFilledScreen> {
  bool _busy = false;
  final _key = newIdempotencyKey();

  /// The largest sit-and-go size the joined players would have filled.
  int? get _smaller {
    final t = widget.tournament;
    if (t.kind != TournamentKind.sitAndGo) return null;
    for (final size in const [16, 8]) {
      if (size < t.size && t.entrants >= size) return size;
    }
    return null;
  }

  Future<void> _join(int size) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final (_, wallet) = await ref.read(apiClientProvider).joinSng(size, _key);
      ref.read(inventoryProvider.notifier).setWallet(wallet);
      ref.invalidate(sngTablesProvider);
      if (mounted) context.pushReplacement('/sng?size=$size');
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
    final t = widget.tournament;
    final smaller = _smaller;
    return CelebrationLayout(
      background: c.bgGradient,
      content: [
        const DiamondWell(),
        Text(
          l.notFilledTitle,
          textAlign: TextAlign.center,
          style: NardType.displayL.copyWith(fontSize: 24, color: c.text),
        ),
        Text(
          t.kind == TournamentKind.sitAndGo
              ? l.notFilledBody(10, t.size, t.entrants)
              : l.notFilledBodyScheduled,
          textAlign: TextAlign.center,
          style: NardType.body.copyWith(
            fontSize: 14,
            height: 21 / 14,
            color: c.text.withValues(alpha: .7),
          ),
        ),
        if (t.paid)
          RewardPill(
            label: l.refunded(formatAmount(t.entryCoins)),
            fill: c.success.withValues(alpha: .16),
            border: c.successText.withValues(alpha: .4),
            color: c.successText,
            coin: true,
          ),
      ],
      footer: [
        if (smaller != null)
          NardButton(
            label: l.notFilledJoinSmaller(smaller),
            onPressed: _busy ? null : () => _join(smaller),
          ),
        NardButton(
          label: l.backToTournaments,
          variant: NardButtonVariant.ghost,
          size: NardButtonSize.m,
          labelColor: c.text.withValues(alpha: .7),
          onPressed: () => context.go('/tournaments'),
        ),
      ],
    );
  }
}
