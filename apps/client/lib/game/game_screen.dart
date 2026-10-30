import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';

import '../app/providers.dart';
import '../app/sounds.dart';
import '../board/board_game.dart';
import '../cosmetics/board_look.dart';
import '../cosmetics/cosmetics_providers.dart';
import '../data/app_settings.dart';
import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../online/online_game_controller.dart';
import '../online/online_text.dart';
import '../progression/level_up_screen.dart';
import '../progression/match_rewards.dart';
import '../progression/progress.dart';
import '../social/emotes.dart';
import '../social/player_menu.dart';
import '../social/social_providers.dart';
import '../social/social_socket.dart';
import '../social/spectate.dart';
import '../store/inventory.dart';
import '../theme/board_theme.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/background.dart';
import '../ui/buttons.dart';
import '../ui/extra_tokens.dart';
import '../ui/identity.dart';
import '../ui/layout.dart';
import '../ui/social.dart';
import 'game_actions.dart';
import 'game_clock.dart';
import 'game_controller.dart';
import 'game_overlays.dart';
import 'game_parts.dart';
import 'game_presenter.dart';
import 'game_sheets.dart';
import 'online_overlays.dart';
import 'session.dart';

/// The in-game screen (game.md §1 portrait, §1L landscape).
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, this.online = false, this.spectator = false});

  /// Drives the screen from the game server instead of the local match.
  final bool online;

  /// 6.4: watches someone else's game read-only (emotes only).
  final bool spectator;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  NardBoardGame? _board;
  double _boardHeight = 0;
  int _shownRevision = -1;
  bool _offerOpen = false;
  bool _matchResultReady = false;
  Timer? _resultTimer;
  Timer? _ratingTimer;
  Timer? _levelUpTimer;

  /// Greys the emote controls for the client cooldown (2.7 proposal).
  Timer? _emoteTimer;
  bool _emoteCooling = false;
  BoardLook? _shownLook;
  Map<Side, BoardLook> _shownSides = const {};

  /// Online: progress + wallet at the start of the match, compared with
  /// the server's values after it for the 2.6 rewards and 12.3.
  Future<RewardSnapshot?>? _rewardsBefore;
  MatchRewards? _rewards;

  @override
  void initState() {
    super.initState();
    if (widget.online) _captureRewards();
    // Emotes of this game arrive on the shared socket (2.7).
    if (widget.online) ref.read(socialSocketProvider.notifier).attach();
  }

  void _captureRewards() {
    _rewards = null;
    _rewardsBefore = RewardSnapshot.capture(ref.read(apiClientProvider));
  }

  @override
  void dispose() {
    _resultTimer?.cancel();
    _ratingTimer?.cancel();
    _levelUpTimer?.cancel();
    _emoteTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadRewards() async {
    final before = await _rewardsBefore;
    if (before == null || !mounted) return;
    final after = await RewardSnapshot.capture(ref.read(apiClientProvider));
    if (after == null || !mounted) return;
    final rewards = MatchRewards.compare(before, after);
    setState(() => _rewards = rewards);
    ref.read(inventoryProvider.notifier).setWallet(after.wallet);
    unawaited(ref.read(progressProvider.notifier).refresh());
    if (rewards.leveledUp) {
      // After the counters finish (store.md §6.5).
      _levelUpTimer = Timer(
        NardMotion.counter + const Duration(milliseconds: 300),
        () {
          if (!mounted) return;
          unawaited(
            context.push(
              '/levelup',
              extra: LevelUpArgs(
                from: rewards.levelFrom,
                to: rewards.levelTo,
                xp: rewards.after.xp,
                xpForNext: rewards.after.xpForNext,
              ),
            ),
          );
        },
      );
    }
  }

  ProviderListenable<GameView?> get _provider =>
      widget.spectator
          ? spectatorViewProvider
          : widget.online
          ? onlineGameProvider
          : gameControllerProvider;

  GameActions get _ctrl =>
      widget.spectator
          ? ref.read(spectatorProvider.notifier)
          : widget.online
          ? ref.read(onlineGameProvider.notifier)
          : ref.read(gameControllerProvider.notifier);

  NardBoardGame _boardFor(double height) {
    final existing = _board;
    if (existing != null && _boardHeight == height) return existing;
    _boardHeight = height;
    _shownRevision = -1;
    return _board = NardBoardGame(
      boardHeight: height,
      onTapSlot: (slot) => _ctrl.tapSlot(slot),
      onDrop: (from, to) => _ctrl.drop(from, to),
      canDrag:
          (slot) =>
              !widget.spectator &&
              (ref.read(_provider)?.session.movableFrom.contains(slot) ??
                  false),
    );
  }

  void _sync(GameView view, AppSettings settings, AppLocalizations l) {
    final board = _board;
    if (board == null) return;
    final look = ref.read(localLookProvider);
    final sides = opponentLooks(
      ref.read(currentCatalogProvider),
      view.session.setup,
      show: settings.showOpponentCosmetics,
    );
    final sameRevision = view.revision == _shownRevision;
    if (sameRevision && look == _shownLook && mapEquals(sides, _shownSides)) {
      return;
    }
    _shownRevision = view.revision;
    _shownLook = look;
    _shownSides = sides;
    board.reduceMotion = settings.reduceMotion;
    board.show(
      GamePresenter(view, settings, l).scene().withLook(look, sideLooks: sides),
      // A set change alone redraws without replaying the last moves.
      steps: sameRevision ? const [] : view.steps,
    );
  }

  void _onChange(GameView? prev, GameView? next) {
    if (next == null) return;
    final settings = ref.read(currentSettingsProvider);
    final s = next.session;
    if (settings.haptics && prev != null) {
      if (s.pending.length != prev.session.pending.length ||
          s.lastTurn != prev.session.lastTurn) {
        unawaited(HapticFeedback.selectionClick());
      }
      if (s.rejection != null && prev.session.rejection == null) {
        unawaited(HapticFeedback.mediumImpact());
      }
      if (next.rolling && !prev.rolling) {
        unawaited(HapticFeedback.lightImpact());
      }
    }
    if (prev != null) _sounds(prev.session, s, next);
    final p = GamePresenter(next, settings, AppLocalizations.of(context));
    if (p.mustAnswerDouble &&
        !_offerOpen &&
        !next.handoff &&
        !widget.spectator) {
      unawaited(_answerDouble(p));
    }
    if (s.isMatchOver && !_matchResultReady && _resultTimer == null) {
      _resultTimer = Timer(const Duration(milliseconds: 1400), () {
        if (mounted) setState(() => _matchResultReady = true);
      });
      if (widget.online && _ratingTimer == null) {
        // The API records the result a moment after the server ends the
        // match; refresh again for the 2.6 rating card.
        _ratingTimer = Timer(const Duration(seconds: 3), () {
          if (!mounted) return;
          unawaited(
            ref.read(accountProvider.notifier).refresh().catchError((_) {}),
          );
          unawaited(_loadRewards());
        });
      }
    }
  }

  void _sounds(Session before, Session after, GameView view) {
    final sfx = ref.read(soundProvider);
    if (view.rolling && after.dice != before.dice) sfx.play(Sfx.dice);
    if (after.phase == GamePhase.cubeOffered &&
        before.phase != GamePhase.cubeOffered) {
      sfx.play(Sfx.double);
    }
    // New checker movement: pending moves added, or a turn confirmed by
    // the bot (the human's confirm has already sounded per move).
    List<Move> moved = const [];
    if (after.pending.length > before.pending.length) {
      moved = after.pending.sublist(before.pending.length);
    } else if (!identical(after.lastTurn, before.lastTurn) &&
        before.pending.isEmpty) {
      moved = after.lastTurn;
    }
    if (moved.isEmpty) return;
    if (moved.any((m) => m.hit)) {
      sfx.play(Sfx.hit);
    } else if (moved.any((m) => m.isBearOff)) {
      sfx.play(Sfx.bearOff);
    } else {
      sfx.play(Sfx.checker);
    }
  }

  Future<void> _answerDouble(GamePresenter p) async {
    _offerOpen = true;
    final offerer = p.name(p.s.turn);
    final take = await showCubeOfferSheet(
      context,
      offerer: offerer,
      value: p.s.game.cube.value,
    );
    _offerOpen = false;
    if (take == null) return;
    take ? _ctrl.takeDouble() : _ctrl.dropDouble();
  }

  Future<void> _openMenu(GamePresenter p) async {
    final settings = ref.read(currentSettingsProvider);
    final choice = await showGameMenu(
      context,
      variant: p.setup.variant,
      soundOn: settings.sound,
      fairDice: widget.online,
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case MenuChoice.resume:
        break;
      case MenuChoice.settings:
        unawaited(context.push('/settings'));
      case MenuChoice.fairDice:
        unawaited(context.push('/online/fair'));
      case MenuChoice.rules:
        unawaited(showRulesSheet(context, p.setup.variant));
      case MenuChoice.sound:
        unawaited(
          ref
              .read(settingsProvider.notifier)
              .change((s) => s.copyWith(sound: !s.sound)),
        );
      case MenuChoice.resign:
        final kind = await showResignSheet(
          context,
          cube: p.s.game.cube.value,
          variant: p.setup.variant,
        );
        if (kind != null) _ctrl.resign(kind);
      case MenuChoice.leave:
        await _leave(p);
    }
  }

  Future<void> _leave(GamePresenter p) async {
    if (widget.spectator) {
      _ctrl.leave();
      context.canPop() ? context.pop() : context.go('/home');
      return;
    }
    if (!p.s.isMatchOver && p.s.record.actions.isNotEmpty) {
      final ok = await showLeaveSheet(context);
      if (ok != true || !mounted) return;
    }
    _ctrl.leave();
    if (mounted) context.go('/home');
  }

  void _primary(PrimaryAction action) {
    switch (action) {
      case PrimaryAction.none:
        break;
      case PrimaryAction.roll:
        _ctrl.roll();
      case PrimaryAction.confirm:
        _ctrl.confirm();
      case PrimaryAction.pass:
        _ctrl.pass();
      case PrimaryAction.nextGame:
        _ctrl.nextGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<GameView?>(_provider, (prev, next) => _onChange(prev, next));
    final view = ref.watch(_provider);
    final settings = ref.watch(currentSettingsProvider);
    // Rebuild (and re-sync the board) when the equipped set loads.
    ref.watch(localLookProvider);
    ref.watch(currentCatalogProvider);
    final table = ref.watch(localTableProvider);
    final l = AppLocalizations.of(context);
    if (view == null) {
      if (widget.spectator) return _spectatorPending(l);
      return const Scaffold(body: NardBackground(child: SizedBox.expand()));
    }
    ref.watch(emoteFeedProvider);
    ref.watch(mutedPlayersProvider);
    final p = GamePresenter(view, settings, l);
    final s = view.session;

    Widget body;
    if (view.handoff) {
      body = _handoff(p, l);
    } else if (s.isMatchOver && _matchResultReady && widget.spectator) {
      body = _spectatorOver(p, l);
    } else if (s.isMatchOver && _matchResultReady) {
      body = _matchResult(p, l);
    } else {
      body = LayoutBuilder(
        builder: (context, box) {
          final landscape = box.maxWidth > box.maxHeight;
          final height =
              landscape
                  ? BoardGeometry.heightLandscape
                  : BoardGeometry.heightPortrait;
          final game = _boardFor(height);
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _sync(view, settings, l),
          );
          final screen =
              landscape
                  ? _landscape(p, l, game, box)
                  : _portrait(p, l, game, box);
          final online = view.online;
          if (online == null || widget.spectator) return screen;
          return Stack(
            children: [
              screen,
              Positioned.fill(
                child: PeriodicBuilder(
                  builder:
                      (_) => LowTimeVignette(
                        active:
                            online.connected &&
                            isLowTime(online, p.viewer, DateTime.now()),
                      ),
                ),
              ),
            ],
          );
        },
      );
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_leave(p));
      },
      child: Scaffold(
        body:
            table == null || (s.isMatchOver && _matchResultReady)
                ? NardBackground(child: body)
                : DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -.2),
                      radius: .9,
                      colors: table,
                      stops: evenStops(table.length),
                    ),
                  ),
                  child: body,
                ),
      ),
    );
  }

  // ---- Pieces ---------------------------------------------------------

  /// Our own socket is down: every control is off (online.md §3.4).
  bool _lost(GamePresenter p) => p.view.online?.connected == false;

  Widget _lockable(GamePresenter p, Widget child) {
    final lost = _lost(p);
    return IgnorePointer(
      ignoring: lost,
      child: AnimatedOpacity(
        duration: NardMotion.fast,
        opacity: lost ? .5 : 1,
        child: child,
      ),
    );
  }

  bool _opponentBot(GamePresenter p) =>
      p.setup.online?.player(p.viewer.opponent).bot ?? false;

  Widget? _reconnectCard(GamePresenter p, AppLocalizations l, bool short) {
    final online = p.view.online;
    if (online == null) return null;
    if (!online.connected) return ReconnectCard(title: l.selfReconnectTitle);
    if (online.opponentConnected || _opponentBot(p)) return null;
    final name = p.name(p.viewer.opponent);
    return PeriodicBuilder(
      period: const Duration(milliseconds: 500),
      builder: (_) {
        // Rounded up like the clocks.
        final left = formatClock(
          (reconnectLeft(online, DateTime.now()) ?? Duration.zero)
              .inMilliseconds,
        );
        return ReconnectCard(
          title: l.reconnectTitle(name),
          sub: short ? l.bannerTimeLeft(left) : l.reconnectBody(left),
        );
      },
    );
  }

  ({String title, String? sub, BannerTone tone}) _bannerData(
    GamePresenter p,
    AppLocalizations l,
  ) {
    final online = p.view.online;
    if (online == null || widget.spectator) return p.banner();
    return onlineBanner(
          online,
          p.viewer,
          l,
          DateTime.now(),
          opponentBot: _opponentBot(p),
        ) ??
        p.banner();
  }

  Widget _boardStack(
    GamePresenter p,
    AppLocalizations l,
    NardBoardGame game,
    double width, {
    bool landscape = false,
  }) {
    final s = p.s;
    final rule = p.rejectionText();
    final h = width * _boardHeight / BoardGeometry.width;
    final dice = s.dice;
    final reconnect = _reconnectCard(p, l, landscape);
    return SizedBox(
      width: width,
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              ignoring: _lost(p),
              child: GameWidget(game: game),
            ),
          ),
          if (reconnect != null) reconnect,
          if (p.view.noMoves && dice != null)
            NoMovesCard(
              title: l.noMovesTitle,
              body: l.noMovesBody(dice.die1, dice.die2, p.noMovesReason),
              duration: GameController.passDelay,
            ),
          if (s.isGameOver && !s.isMatchOver && !widget.spectator)
            _gameOver(p, l),
          if (rule != null)
            Positioned(
              left: 24,
              right: 24,
              bottom: -14,
              child: RuleToast(title: rule.title, body: rule.body),
            ),
        ],
      ),
    );
  }

  Widget _gameOver(GamePresenter p, AppLocalizations l) {
    final r = p.s.game.result!;
    final me = p.setup.hasRemote ? p.setup.localSide : r.winner;
    final won = r.winner == me;
    final title =
        p.setup.hasRemote
            ? (won ? l.gameWonTitle : l.gameLostTitle)
            : l.gameWinnerTitle(p.name(r.winner));
    final target = p.setup.matchLength;
    final left = target - p.score(me);
    return GameOverCard(
      title: title,
      won: won,
      result: p.resultLine(),
      meName: p.name(me),
      oppName: p.name(me.opponent),
      meScore: p.score(me),
      oppScore: p.score(me.opponent),
      progress: target > 1 ? l.gameMatchProgress(target, left) : null,
      nextLabel: l.actionNextGame,
      onNext: _ctrl.nextGame,
    );
  }

  Widget _card(
    GamePresenter p,
    AppLocalizations l,
    Side side, {
    bool column = false,
  }) {
    final s = p.s;
    final settings = ref.read(currentSettingsProvider);
    final online = p.view.online;
    final seat = p.setup.online?.player(side);
    final bot = seat?.bot ?? false;
    final parts = <String>[
      if (p.setup.vsComputer && p.setup.isRemote(side))
        l.playerBotLevel(p.levelName(p.setup.level)),
      if (bot) l.botNoRating,
      if (settings.showPipCount) l.playerPip(s.board.pipCount(side)),
    ];
    final active =
        !s.isGameOver &&
        s.phase != GamePhase.opening &&
        (s.phase == GamePhase.cubeOffered ? s.turn.opponent : s.turn) == side;
    if (seat?.rating != null && !bot) parts.insert(0, '${seat!.rating}');
    final away =
        online != null &&
        !online.opponentConnected &&
        side != p.setup.localSide &&
        !bot;
    final human = online != null && seat != null && !bot && !widget.spectator;
    final mine = side == p.setup.localSide;
    final card = PlayerCard(
      name: p.name(side),
      meta: parts.join(' · '),
      action:
          human && mine && !column && !_opponentBot(p)
              ? EmoteButton(
                onSend: _sendEmote,
                enabled: !_lost(p) && !_emoteCooling,
              )
              : null,
      active: active,
      ivory: side == Side.white,
      side: column,
      bot: bot,
      badge: bot && !column ? BotBadge(label: l.botBadge) : null,
      offlineLabel: away ? l.playerOffline : null,
      trailing:
          online == null || p.setup.online == null
              ? null
              : bot
              ? ClockPlaceholder(label: l.valueNone, compact: column)
              : GameClock(
                clock: online.clock,
                side: side,
                receivedAt: online.receivedAt ?? DateTime.now(),
                delayTotalMs: p.setup.online!.clock.delayMs,
                haptics:
                    settings.haptics &&
                    side == p.setup.localSide &&
                    !widget.spectator,
                compact: column,
              ),
    );
    return _withEmote(
      p,
      side,
      card,
      opponentTap: human && !mine,
      column: column,
    );
  }

  /// Sends an emote/phrase id (2.7); the socket enforces the cooldown.
  void _sendEmote(String id) {
    final sent = ref.read(socialSocketProvider.notifier).sendEmote(id);
    if (!sent) return;
    if (ref.read(currentSettingsProvider).haptics) {
      unawaited(HapticFeedback.lightImpact());
    }
    setState(() => _emoteCooling = true);
    _emoteTimer?.cancel();
    _emoteTimer = Timer(SocialSocket.emoteCooldown, () {
      if (mounted) setState(() => _emoteCooling = false);
    });
  }

  /// The received emote bubble next to [side]'s card, and the 14.1 menu
  /// on the opponent's card.
  Widget _withEmote(
    GamePresenter p,
    Side side,
    Widget card, {
    required bool opponentTap,
    required bool column,
  }) {
    final seat = p.setup.online?.player(side);
    Widget result = card;
    if (opponentTap && seat != null) {
      result = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap:
            () => showPlayerMenu(
              context,
              PlayerRef(id: seat.userId, name: seat.name, rating: seat.rating),
              matchId: p.setup.online?.matchId,
              rankedGame: p.setup.online?.mode == QueueMode.ranked,
            ),
        child: result,
      );
    }
    final emote = ref.read(emoteFeedProvider)[side];
    final muted =
        seat != null && ref.read(mutedPlayersProvider).contains(seat.userId);
    if (emote == null || muted || p.view.online == null) return result;
    final top = side != p.viewer;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        result,
        Positioned(
          left: column ? 8 : 64,
          top: top ? null : -44,
          bottom: top ? -44 : null,
          child: EmoteBubble(key: ValueKey(emote.seq), id: emote.id),
        ),
      ],
    );
  }

  Widget _banner(GamePresenter p, AppLocalizations l) {
    if (p.view.online == null) {
      final b = p.banner();
      return StatusBanner(title: b.title, sub: b.sub, tone: b.tone);
    }
    return PeriodicBuilder(
      builder: (_) {
        final b = _bannerData(p, l);
        return StatusBanner(title: b.title, sub: b.sub, tone: b.tone);
      },
    );
  }

  Widget _topBar(GamePresenter p, AppLocalizations l) {
    final c = context.nard;
    final me = p.viewer;
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            NardIconButton(
              icon: LucideIcons.menu,
              semanticLabel: l.actionMenu,
              size: 42,
              circle: true,
              onPressed: () => _openMenu(p),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    p.modeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NardType.micro.copyWith(
                      color: c.textDim,
                      letterSpacing: .66,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l.gameScore(p.score(me), p.score(me.opponent)),
                    style: NardType.score.copyWith(
                      color: c.text,
                      letterSpacing: .44,
                      fontFeatures: tabular,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.online)
              NardIconButton(
                icon: LucideIcons.shieldCheck,
                semanticLabel: l.menuFairDice,
                size: 42,
                circle: true,
                color: c.accent,
                onPressed: () => context.push('/online/fair'),
              )
            else
              // Keeps the title centred.
              const SizedBox(width: 42),
          ],
        ),
      ),
    );
  }

  Widget _undoButton(
    GamePresenter p,
    AppLocalizations l, {
    double? width,
    double? height,
  }) => NardIconButton(
    icon: LucideIcons.undo2,
    caption: l.actionUndo,
    semanticLabel: l.actionUndo,
    width: width ?? 66,
    height: height ?? 62,
    circle: true,
    onPressed: p.canUndo ? _ctrl.undo : null,
  );

  Widget _doubleButton(
    GamePresenter p,
    AppLocalizations l, {
    double? width,
    double? height,
  }) {
    final c = context.nard;
    return NardIconButton(
      icon: LucideIcons.square,
      iconWidget: CubeGlyph(color: c.text),
      caption: l.actionDouble,
      semanticLabel: l.actionDouble,
      width: width ?? 66,
      height: height ?? 62,
      circle: true,
      onPressed: p.canDouble ? _ctrl.offerDouble : null,
    );
  }

  Widget _primaryButton(
    GamePresenter p, {
    double height = 62,
    bool column = false,
  }) {
    final pr = p.primary();
    return GamePrimaryButton(
      label: pr.label,
      sub: pr.sub,
      style: pr.style,
      height: height,
      column: column,
      onPressed:
          pr.action == PrimaryAction.none ? null : () => _primary(pr.action),
    );
  }

  Widget _portrait(
    GamePresenter p,
    AppLocalizations l,
    NardBoardGame game,
    BoxConstraints box,
  ) {
    final me = p.viewer;
    final boardWidth = box.maxWidth - 2 * NardSpace.boardGutter;
    return SafeArea(
      child: Column(
        children: [
          if (widget.spectator) _spectatorBar(p, l) else _topBar(p, l),
          if (p.crawford)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: CrawfordChip(label: l.crawfordChip),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
            child: _card(p, l, me.opponent),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _banner(p, l),
                const SizedBox(height: 10),
                _boardStack(p, l, game, boardWidth),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: _card(p, l, me),
          ),
          if (widget.spectator)
            _spectatorPanel(p, l)
          else ...[
            _lockable(
              p,
              SizedBox(
                height: 62,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _undoButton(p, l),
                      const SizedBox(width: 10),
                      Expanded(child: _primaryButton(p)),
                      const SizedBox(width: 10),
                      if (p.showDouble)
                        _doubleButton(p, l)
                      else if (_canChat(p))
                        // Long Nard "Söhbət" control (game.md §1).
                        EmoteButton(
                          onSend: _sendEmote,
                          caption: l.gameChat,
                          enabled: !_emoteCooling,
                        )
                      else
                        const SizedBox(width: 66),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _landscape(
    GamePresenter p,
    AppLocalizations l,
    NardBoardGame game,
    BoxConstraints box,
  ) {
    final c = context.nard;
    final me = p.viewer;
    final pad = MediaQuery.paddingOf(context);
    final boardWidth =
        (box.maxWidth - pad.left - pad.right - 158 - 96 - 18 - 28)
            .clamp(200.0, 480.0)
            .toDouble();
    final maxH = box.maxHeight - pad.top - pad.bottom - 28;
    final width =
        boardWidth * BoardGeometry.heightLandscape / BoardGeometry.width > maxH
            ? maxH * BoardGeometry.width / BoardGeometry.heightLandscape
            : boardWidth;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        pad.left + 14,
        pad.top + 14,
        pad.right + 18,
        pad.bottom + 14,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 158,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _card(p, l, me.opponent, column: true),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.modeLabel.toUpperCase(),
                        maxLines: 2,
                        style: NardType.micro.copyWith(
                          fontSize: 10,
                          color: c.textDim,
                          letterSpacing: .6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l.gameScore(p.score(me), p.score(me.opponent)),
                        style: NardType.score.copyWith(
                          fontSize: 24,
                          color: c.text,
                          fontFeatures: tabular,
                        ),
                      ),
                      const SizedBox(height: 6),
                      PeriodicBuilder(
                        builder: (_) {
                          final b = _bannerData(p, l);
                          return Text(
                            b.title,
                            maxLines: 2,
                            style: NardType.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: switch (b.tone) {
                                BannerTone.brass => c.accent,
                                BannerTone.dim => c.text,
                                BannerTone.danger => c.dangerText,
                                BannerTone.ok => c.successText,
                              },
                            ),
                          );
                        },
                      ),
                      if (p.crawford) ...[
                        const SizedBox(height: 6),
                        CrawfordChip(label: l.crawfordChip),
                      ],
                    ],
                  ),
                ),
                _card(p, l, me, column: true),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Center(
              child: _boardStack(p, l, game, width, landscape: true),
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 96,
            child: Column(
              children: [
                NardIconButton(
                  icon:
                      widget.spectator ? LucideIcons.logOut : LucideIcons.menu,
                  semanticLabel:
                      widget.spectator ? l.spectatorLeave : l.actionMenu,
                  width: 96,
                  height: 44,
                  circle: true,
                  onPressed:
                      widget.spectator ? () => _leave(p) : () => _openMenu(p),
                ),
                const Spacer(),
                if (widget.spectator)
                  LivePill(label: l.spectatorLive, compact: true)
                else
                  _lockable(
                    p,
                    Column(
                      children: [
                        _undoButton(p, l, width: 96, height: 60),
                        if (p.showDouble) ...[
                          const SizedBox(height: 10),
                          _doubleButton(p, l, width: 96, height: 60),
                        ],
                        const SizedBox(height: 10),
                        _primaryButton(p, height: 88, column: true),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Emotes need a human online opponent (hidden vs the bot, 2.7).
  bool _canChat(GamePresenter p) =>
      widget.online && p.setup.online != null && !_opponentBot(p);

  /// 6.4 top bar: the live pill and the score.
  Widget _spectatorBar(GamePresenter p, AppLocalizations l) {
    final c = context.nard;
    return SizedBox(
      height: 52,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LivePill(label: l.spectatorLive),
          const SizedBox(width: 12),
          Text(
            l.gameScore(p.score(Side.white), p.score(Side.black)),
            style: NardType.score.copyWith(
              color: c.text,
              fontFeatures: tabular,
            ),
          ),
        ],
      ),
    );
  }

  /// 6.4 bottom panel: spectators only see emotes (no chat, ADR-036).
  Widget _spectatorPanel(GamePresenter p, AppLocalizations l) {
    final c = context.nard;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.paddingOf(context).bottom > 0 ? 12 : 20,
      ),
      decoration: BoxDecoration(
        color: c.bg,
        border: Border(top: BorderSide(color: c.lineSoft)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l.spectatorNoChat,
              style: NardType.bodyS.copyWith(
                color: c.text.withValues(alpha: .55),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SmallActionButton(
            label: l.spectatorLeave,
            style: SmallButtonStyle.outline,
            height: 44,
            onTap: () => _leave(p),
          ),
        ],
      ),
    );
  }

  /// 6.4 before the first state, or when the game cannot be watched.
  Widget _spectatorPending(AppLocalizations l) {
    final c = context.nard;
    final unavailable = ref.watch(
      spectatorProvider.select((s) => s.unavailable),
    );
    void leave() {
      _ctrl.leave();
      context.canPop() ? context.pop() : context.go('/home');
    }

    return Scaffold(
      body: NardBackground(
        child: SafeArea(
          child: Column(
            children: [
              ScreenHeader(title: '', bare: true, onBack: leave),
              Expanded(
                child:
                    unavailable
                        ? MessageState(
                          title: l.spectatorUnavailable,
                          body: '',
                          danger: true,
                          action: l.spectatorLeave,
                          onAction: leave,
                        )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: c.accent,
                              strokeWidth: 2,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l.spectatorWaiting,
                              style: NardType.body.copyWith(color: c.textDim),
                            ),
                          ],
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 6.4 end of the watched match (not designed: winner + score + leave).
  Widget _spectatorOver(GamePresenter p, AppLocalizations l) {
    final winner = p.s.score.winner!;
    return SafeArea(
      child: MessageState(
        title: l.spectatorGameOver(
          p.name(winner),
          l.gameScore(p.score(winner), p.score(winner.opponent)),
        ),
        body: '',
        action: l.spectatorLeave,
        onAction: () => _leave(p),
      ),
    );
  }

  Widget _handoff(GamePresenter p, AppLocalizations l) {
    final s = p.s;
    final next = s.turn;
    final prev = next.opponent;
    final sideName = next == Side.white ? l.hotseatWhite : l.hotseatBlack;
    String body;
    if (s.lastTurn.isEmpty && s.record.actions.whereType<PlayTurn>().isEmpty) {
      body = l.handoffFirst(sideName);
    } else if (s.lastTurn.isEmpty) {
      body = l.handoffBodyNoMove(sideName, p.name(prev));
    } else {
      body = l.handoffBody(
        sideName,
        p.name(prev),
        MoveNotation.format(s.lastTurn),
      );
    }
    final undo = p.setup.allowUndo && p.view.undoSnapshot != null;
    return HandoffView(
      side: next,
      overline: l.handoffOverline,
      title: l.handoffTitle(p.name(next)),
      body: body,
      readyLabel: l.handoffReady(p.name(next)),
      onReady: _ctrl.ready,
      undoLabel: undo ? l.handoffUndo(p.name(prev)) : null,
      onUndo: undo ? _ctrl.undoLastTurn : null,
    );
  }

  Widget _matchResult(GamePresenter p, AppLocalizations l) {
    final s = p.s;
    final winner = s.score.winner!;
    final me = p.setup.hasRemote ? p.setup.localSide : winner;
    final won = winner == me;
    final title =
        p.setup.hasRemote
            ? (won ? l.matchWonTitle : l.matchLostTitle)
            : l.matchWinnerTitle(p.name(winner));
    final meta =
        p.setup.matchLength > 1
            ? l.matchMeta(p.name(me), p.name(me.opponent), p.setup.matchLength)
            : l.matchMetaSingle(p.name(me), p.name(me.opponent));
    return MatchResultView(
      title: title,
      won: won,
      meScore: p.score(me),
      oppScore: p.score(me.opponent),
      meta: meta,
      extra: _resultExtras(p, me),
      rematchLabel: l.matchRematch,
      onRematch: () {
        setState(() {
          _matchResultReady = false;
          _resultTimer = null;
          _ratingTimer = null;
          _levelUpTimer?.cancel();
          if (widget.online) _captureRewards();
        });
        // A private-room match (no queue request) rematches in a new room.
        if (widget.online && ref.read(lobbyProvider).request == null) {
          _ctrl.leave();
          ref
              .read(socialSocketProvider.notifier)
              .createRoom(p.setup.variant, p.setup.matchLength);
          context.go('/room');
          return;
        }
        _ctrl.rematch();
        // Online rematch = queue again with the same settings.
        if (widget.online) context.go('/online/search');
      },
      homeLabel: l.matchHome,
      onHome: () {
        _ctrl.leave();
        context.go('/home');
      },
      replayLabel: l.actionViewReplay,
      // Online matches are not saved locally (history lives in 8.1).
      onReplay: widget.online ? null : () => context.push('/replays'),
    );
  }

  /// 2.6 parts under the score: rating card (ranked) and the rewards row
  /// with mission progress (online matches only, store.md §6.5).
  Widget? _resultExtras(GamePresenter p, Side me) {
    final rating = _ratingCard(p, me);
    final rewards = _rewards;
    final showRewards = widget.online && rewards != null && !rewards.isEmpty;
    if (rating == null && !showRewards) return null;
    return Column(
      children: [
        if (rating != null) rating,
        if (rating != null && showRewards) const SizedBox(height: 18),
        if (showRewards) MatchRewardsView(rewards: rewards),
      ],
    );
  }

  /// 2.6 rating card: ranked online matches once the API has the new
  /// rating; hidden until then (and for casual / bot matches).
  Widget? _ratingCard(GamePresenter p, Side me) {
    final online = p.setup.online;
    if (online == null || online.mode != QueueMode.ranked) return null;
    final before = online.player(me).rating;
    if (before == null) return null;
    return Consumer(
      builder: (context, ref, _) {
        final account = ref.watch(accountProvider).value;
        final after = ratingFor(account, p.setup.variant)?.rating;
        if (after == null || after == before) return const SizedBox.shrink();
        return RatingCard(before: before, after: after);
      },
    );
  }
}
