import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nard_ai/nard_ai.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';

import '../../game/game_controller.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../online/account.dart';
import '../../online/online_game_controller.dart';
import '../../online/online_text.dart';
import '../../theme/nard_colors.dart';
import '../../theme/nard_tokens.dart';
import '../../ui/extra_tokens.dart';
import '../../ui/identity.dart';
import '../../ui/layout.dart';
import '../ai_level_screen.dart';

/// Name shown for the server's bot seat (ADR-024: always labelled).
String botDisplayName(AppLocalizations l) =>
    l.playerBotLevel(aiLevelName(l, BotLevel.medium));

/// 2.5 Opponent found (20.1 against the bot). Opens the game after 3 s,
/// once the first `game.state` has arrived.
class VersusScreen extends ConsumerStatefulWidget {
  const VersusScreen({super.key});

  static const countdown = 3;

  @override
  ConsumerState<VersusScreen> createState() => _VersusScreenState();
}

class _VersusScreenState extends ConsumerState<VersusScreen> {
  Timer? _timer;
  int _left = VersusScreen.countdown;
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _left = max(0, _left - 1));
      _maybeStart();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _maybeStart() {
    if (_gone || _left > 0) return;
    final lobby = ref.read(lobbyProvider);
    if (lobby.phase == LobbyPhase.idle) {
      _gone = true;
      context.go('/home');
      return;
    }
    if (ref.read(onlineGameProvider) == null) return;
    _gone = true;
    _timer?.cancel();
    context.go('/game?online=1');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<GameView?>(onlineGameProvider, (_, _) => _maybeStart());
    ref.listen<Lobby>(lobbyProvider, (_, _) => _maybeStart());
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final match = ref.watch(lobbyProvider).match;
    final account = ref.watch(accountProvider).value;
    if (match == null) {
      return Scaffold(
        body: DecoratedBox(decoration: BoxDecoration(gradient: c.searchBg)),
      );
    }
    final me = match.you == Side.white ? match.white : match.black;
    final opp = match.you == Side.white ? match.black : match.white;
    final bot = opp.bot;
    final mine = ratingFor(account, match.variant);
    final myRating = me.rating ?? mine?.rating;
    String? myMeta;
    if (myRating != null) {
      final rank = l.rankOf(myRating);
      myMeta =
          !bot && mine != null && mine.matches > 0
              ? l.vsMeta(
                rank,
                myRating,
                (100 * mine.wins / mine.matches).round(),
              )
              : l.vsMetaNoStats(rank, myRating);
    }
    final oppRating = opp.rating;
    final oppMeta =
        bot
            ? l.botNoRating
            : oppRating == null
            ? null
            : l.vsMetaNoStats(l.rankOf(oppRating), oppRating);
    final animate = !MediaQuery.of(context).disableAnimations;
    final bottom = MediaQuery.paddingOf(context).bottom;

    Widget seat({
      required PlayerInfo info,
      required String name,
      required String? meta,
      required AvatarTone tone,
      required bool top,
    }) {
      final avatar =
          tone == AvatarTone.bot
              ? SizedBox(
                width: 110,
                height: 116,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Avatar(name: name, size: 110, tone: tone),
                    Positioned(
                      bottom: 0,
                      child: BotBadge(label: l.botBadge, large: true),
                    ),
                  ],
                ),
              )
              : Avatar(name: name, size: 110, tone: tone);
      final nameRow = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: NardType.title.copyWith(fontSize: 24, color: c.text),
            ),
          ),
          if (tone != AvatarTone.bot && info.country != null) ...[
            const SizedBox(width: 8),
            FlagSwatch(country: info.country, width: 20, height: 13),
          ],
        ],
      );
      final metaText =
          meta == null
              ? null
              : Text(
                meta,
                textAlign: TextAlign.center,
                style: NardType.bodyS.copyWith(
                  color: c.text.withValues(alpha: .7),
                  fontFeatures: tabular,
                ),
              );
      final children = [
        avatar,
        const SizedBox(height: 10),
        nameRow,
        if (metaText != null) ...[const SizedBox(height: 10), metaText],
      ];
      final column = Column(
        mainAxisSize: MainAxisSize.min,
        children: top ? children : children.reversed.toList(),
      );
      if (!animate) return column;
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 1, end: 0),
        duration: NardMotion.sheetIn,
        curve: NardMotion.standard,
        builder:
            (context, t, child) => Opacity(
              opacity: 1 - t,
              child: Transform.translate(
                offset: Offset(0, (top ? -40 : 40) * t),
                child: child,
              ),
            ),
        child: column,
      );
    }

    final overline = [
      match.variant == Variant.shortNard
          ? l.variantShortUpper
          : l.variantLongUpper,
      match.matchLength <= 1
          ? l.oneGameUpper
          : l.pointsUpper(match.matchLength),
      l.timeControlShort(
        match.clock.reserveMs ~/ 60000,
        match.clock.delayMs ~/ 1000,
      ),
      match.mode == QueueMode.ranked ? l.rankedUpper : l.unrankedUpper,
    ].join(' · ');

    final footer =
        bot
            ? Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: c.surfaceSunken,
                borderRadius: BorderRadius.circular(c.cardRadius),
                border: Border.all(color: c.text.withValues(alpha: .18)),
              ),
              child: Text(
                l.botFallbackNotice,
                textAlign: TextAlign.center,
                style: NardType.bodyS.copyWith(
                  height: 19 / 13,
                  color: c.text.withValues(alpha: .8),
                ),
              ),
            )
            : Column(
              children: [
                Overline(overline, spacing: .72),
                const SizedBox(height: 6),
                Text(
                  l.vsStartsIn(max(1, _left)),
                  style: NardType.labelM.copyWith(
                    color: c.accentHi,
                    fontFeatures: tabular,
                  ),
                ),
              ],
            );

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(gradient: c.vsBg(bot: bot)),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 30, 24, max(44, bottom + 6)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  seat(
                    info: opp,
                    name: bot ? botDisplayName(l) : opp.name,
                    meta: oppMeta,
                    tone: bot ? AvatarTone.bot : AvatarTone.opponent,
                    top: true,
                  ),
                  _VsDivider(label: l.vsLabel, animate: animate),
                  seat(
                    info: me,
                    name: me.name,
                    meta: myMeta,
                    tone: AvatarTone.me,
                    top: false,
                  ),
                  footer,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Hairlines with the brass "vs" diamond between them.
class _VsDivider extends StatelessWidget {
  const _VsDivider({required this.label, required this.animate});

  final String label;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    Widget hair(bool left) => Expanded(
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                left
                    ? [c.accent.withValues(alpha: 0), c.accent]
                    : [c.accent, c.accent.withValues(alpha: 0)],
          ),
        ),
      ),
    );
    Widget diamond = SizedBox(
      width: 108,
      height: 108,
      child: Center(
        child: Transform.rotate(
          angle: pi / 4,
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: NardPalette.walnut900,
              border: Border.all(color: c.accent, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: -pi / 4,
              child: Text(
                label,
                style: NardType.displayL.copyWith(
                  fontSize: 30,
                  height: 1,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: c.accentHi,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (animate) {
      diamond = TweenAnimationBuilder<double>(
        tween: Tween(begin: .6, end: 1),
        duration: NardMotion.sheetIn,
        curve: NardMotion.standard,
        builder: (context, s, child) => Transform.scale(scale: s, child: child),
        child: diamond,
      );
    }
    return Row(children: [hair(true), diamond, hair(false)]);
  }
}
