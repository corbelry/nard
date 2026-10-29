import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nard_core/nard_core.dart';

import '../app/providers.dart';
import '../app/sounds.dart';
import '../board/board_game.dart';
import '../data/app_settings.dart';
import '../l10n/gen/app_localizations.dart';
import '../online/online_game_controller.dart';
import '../theme/board_theme.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/background.dart';
import '../ui/buttons.dart';
import '../ui/layout.dart';
import 'game_actions.dart';
import 'game_controller.dart';
import 'game_overlays.dart';
import 'game_parts.dart';
import 'game_presenter.dart';
import 'game_sheets.dart';
import 'session.dart';

/// The in-game screen (game.md §1 portrait, §1L landscape).
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, this.online = false});

  /// Drives the screen from the game server instead of the local match.
  final bool online;

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

  @override
  void dispose() {
    _resultTimer?.cancel();
    super.dispose();
  }

  ProviderListenable<GameView?> get _provider =>
      widget.online ? onlineGameProvider : gameControllerProvider;

  GameActions get _ctrl =>
      widget.online
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
              ref.read(_provider)?.session.movableFrom.contains(slot) ?? false,
    );
  }

  void _sync(GameView view, AppSettings settings, AppLocalizations l) {
    final board = _board;
    if (board == null || view.revision == _shownRevision) return;
    _shownRevision = view.revision;
    board.reduceMotion = settings.reduceMotion;
    board.show(GamePresenter(view, settings, l).scene(), steps: view.steps);
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
    if (p.mustAnswerDouble && !_offerOpen && !next.handoff) {
      unawaited(_answerDouble(p));
    }
    if (s.isMatchOver && !_matchResultReady && _resultTimer == null) {
      _resultTimer = Timer(const Duration(milliseconds: 1400), () {
        if (mounted) setState(() => _matchResultReady = true);
      });
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
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case MenuChoice.resume:
        break;
      case MenuChoice.settings:
        unawaited(context.push('/settings'));
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
    final l = AppLocalizations.of(context);
    if (view == null) {
      return const Scaffold(body: NardBackground(child: SizedBox.expand()));
    }
    final p = GamePresenter(view, settings, l);
    final s = view.session;

    Widget body;
    if (view.handoff) {
      body = _handoff(p, l);
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
          return landscape
              ? _landscape(p, l, game, box)
              : _portrait(p, l, game, box);
        },
      );
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_leave(p));
      },
      child: Scaffold(body: NardBackground(child: body)),
    );
  }

  // ---- Pieces ---------------------------------------------------------

  Widget _boardStack(
    GamePresenter p,
    AppLocalizations l,
    NardBoardGame game,
    double width,
  ) {
    final s = p.s;
    final rule = p.rejectionText();
    final h = width * _boardHeight / BoardGeometry.width;
    final dice = s.dice;
    return SizedBox(
      width: width,
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: GameWidget(game: game)),
          if (p.view.noMoves && dice != null)
            NoMovesCard(
              title: l.noMovesTitle,
              body: l.noMovesBody(dice.die1, dice.die2, p.noMovesReason),
              duration: GameController.passDelay,
            ),
          if (s.isGameOver && !s.isMatchOver) _gameOver(p, l),
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
    final parts = <String>[
      if (p.setup.isRemote(side)) l.playerBotLevel(p.levelName(p.setup.level)),
      if (settings.showPipCount) l.playerPip(s.board.pipCount(side)),
    ];
    final active =
        !s.isGameOver &&
        s.phase != GamePhase.opening &&
        (s.phase == GamePhase.cubeOffered ? s.turn.opponent : s.turn) == side;
    return PlayerCard(
      name: p.name(side),
      meta: parts.join(' · '),
      active: active,
      ivory: side == Side.white,
      side: column,
    );
  }

  Widget _banner(GamePresenter p) {
    final b = p.banner();
    return StatusBanner(title: b.title, sub: b.sub, tone: b.tone);
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
            // Keeps the title centred (fair-dice button is Phase 3).
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
          _topBar(p, l),
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
                _banner(p),
                const SizedBox(height: 10),
                _boardStack(p, l, game, boardWidth),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: _card(p, l, me),
          ),
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
                  else
                    const SizedBox(width: 66),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
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
    final b = p.banner();
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
                      Text(
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
          Expanded(child: Center(child: _boardStack(p, l, game, width))),
          const SizedBox(width: 14),
          SizedBox(
            width: 96,
            child: Column(
              children: [
                NardIconButton(
                  icon: LucideIcons.menu,
                  semanticLabel: l.actionMenu,
                  width: 96,
                  height: 44,
                  circle: true,
                  onPressed: () => _openMenu(p),
                ),
                const Spacer(),
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
      rematchLabel: l.matchRematch,
      onRematch: () {
        setState(() {
          _matchResultReady = false;
          _resultTimer = null;
        });
        _ctrl.rematch();
      },
      homeLabel: l.matchHome,
      onHome: () {
        _ctrl.leave();
        context.go('/home');
      },
      replayLabel: l.actionViewReplay,
      onReplay: () => context.push('/replays'),
    );
  }
}
