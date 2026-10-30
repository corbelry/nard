import 'dart:async';
import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nard_core/nard_core.dart';

import '../analysis/analysis_engine.dart';
import '../analysis/analysis_providers.dart';
import '../analysis/analysis_widgets.dart';
import '../app/providers.dart';
import '../board/board_game.dart';
import '../board/board_scene.dart';
import '../cosmetics/cosmetics_providers.dart';
import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../online/api_client.dart' show ApiException;
import '../online/online_text.dart';
import '../online/reachability.dart';
import '../store/store_providers.dart' show showNote;
import '../theme/board_theme.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../tournaments/tournament_text.dart' show variantName;
import '../ui/buttons.dart';
import '../ui/competition.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import 'puzzle_input.dart';
import 'puzzle_models.dart';

String phaseName(AppLocalizations l, PuzzlePhase phase) => switch (phase) {
  PuzzlePhase.opening => l.puzzlePhaseOpening,
  PuzzlePhase.middle => l.puzzlePhaseMiddle,
  PuzzlePhase.bearoff => l.puzzlePhaseBearOff,
};

String difficultyName(AppLocalizations l, PuzzleDifficulty d) => switch (d) {
  PuzzleDifficulty.easy => l.puzzleLevelEasy,
  PuzzleDifficulty.medium => l.puzzleLevelMedium,
  PuzzleDifficulty.hard => l.puzzleLevelHard,
};

/// 13.1–13.3 Practice puzzles: find the best move on an interactive board,
/// two attempts judged by the server on the resulting position, reveal,
/// rating change. [daily] starts with today's puzzle.
class PuzzleScreen extends ConsumerStatefulWidget {
  const PuzzleScreen({super.key, this.daily = false});

  final bool daily;

  @override
  ConsumerState<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends ConsumerState<PuzzleScreen> {
  late final NardBoardGame _game = NardBoardGame(
    boardHeight: BoardGeometry.heightPortrait,
    onTapSlot: _tap,
    onDrop: _drop,
    canDrag:
        (slot) =>
            _result == null && (_input?.movableFrom.contains(slot) ?? false),
  );

  late bool _daily = widget.daily;
  PuzzleBatch? _batch;
  Object? _error;
  bool _loading = true;
  PuzzleInput? _input;
  int _attempt = 1;
  int? _rating;
  AttemptResult? _result;
  List<Move> _mine = const [];
  MoveEval? _mineEval;
  bool _arrows = false;
  bool _busy = false;

  Puzzle? get _puzzle => _batch?.puzzle;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
      _arrows = false;
      _mine = const [];
      _mineEval = null;
    });
    final api = ref.read(apiClientProvider);
    try {
      var batch = _daily ? await api.dailyPuzzle() : await api.nextPuzzle();
      if (_daily && (batch.puzzle?.finished ?? false)) {
        if (mounted) {
          showNote(context, AppLocalizations.of(context).puzzleDailyDone);
        }
        _daily = false;
        batch = await api.nextPuzzle();
      }
      if (!mounted) return;
      final p = batch.puzzle;
      setState(() {
        _batch = batch;
        _rating = batch.rating;
        _input = p == null ? null : PuzzleInput(p);
        _attempt = p == null ? 1 : min(2, p.attemptsUsed + 1);
        _loading = false;
      });
      _sync();
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  void _sync() {
    final input = _input;
    final p = _puzzle;
    if (input == null || p == null) return;
    final faces =
        p.dice.isDouble
            ? [p.dice.die1, p.dice.die1, p.dice.die1, p.dice.die1]
            : [p.dice.die1, p.dice.die2];
    final left = List<int>.of(input.remainingDice);
    final used = <bool>[];
    for (final f in faces.reversed) {
      used.insert(0, !left.remove(f));
    }
    final selected = input.selected;
    final settings = ref.read(currentSettingsProvider);
    final correct = _result?.correct ?? false;
    _game.show(
      BoardScene(
        rules: p.rules,
        viewer: p.side,
        board: input.board,
        dice: faces,
        diceUsed: used,
        diceOwner: p.side,
        mover: _result == null ? p.side : null,
        selected: selected,
        targets: selected == null ? const {} : input.targetsFrom(selected),
        lastMoves: correct ? _mine : const [],
        lastMover: correct ? p.side : null,
        mustEnter: input.board.barCount(p.side) > 0,
        colorBlind: settings.colorBlind,
        largePips: settings.largePips,
        look: ref.read(localLookProvider),
      ),
    );
  }

  void _tap(int? slot) {
    final input = _input;
    if (input == null || _result != null || _busy) return;
    setState(() => _input = input.tap(slot));
    _sync();
  }

  void _drop(int from, int? to) {
    final input = _input;
    if (input == null || _result != null || _busy || to == null) return;
    setState(() => _input = input.move(from, to));
    _sync();
  }

  void _undo() {
    final input = _input;
    if (input == null || !input.canUndo) return;
    setState(() => _input = input.undo());
    _sync();
  }

  Future<void> _hint() async {
    final input = _input;
    final p = _puzzle;
    if (input == null || p == null || _busy) return;
    setState(() => _busy = true);
    try {
      final turns = p.rules.legalTurns(p.board, p.dice);
      final eval = await ref.read(analysisRunnerProvider)(
        AnalysisTask(
          variant: p.variant,
          board: p.board,
          roll: p.dice,
          played: turns.first.moves,
        ),
      );
      if (!mounted || eval.best.isEmpty) return;
      final reset = input.reset();
      setState(() => _input = reset.select(eval.best.first.from));
      _sync();
    } on Object {
      // No hint.
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirm() async {
    final input = _input;
    final p = _puzzle;
    if (input == null || p == null || !input.canConfirm) return;
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final result = await ref
          .read(apiClientProvider)
          .attemptPuzzle(
            p.id,
            _attempt,
            input.attemptBoard(),
            moves: input.notation,
          );
      if (!mounted) return;
      final mine = input.pending;
      setState(() {
        _result = result;
        _rating = result.rating;
        _mine = mine;
        if (!result.correct) _input = input.reset();
      });
      _sync();
      if (!result.correct) unawaited(_evaluateMine(p, mine));
    } on Object catch (e) {
      if (mounted) {
        showNote(
          context,
          e is ApiException && e.offline ? l.puzzleOffline : l.tourActionFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// My move's loss for the compare box (heuristic, same bot as the
  /// puzzle generator).
  Future<void> _evaluateMine(Puzzle p, List<Move> mine) async {
    try {
      final e = await ref.read(analysisRunnerProvider)(
        AnalysisTask(
          variant: p.variant,
          board: p.board,
          roll: p.dice,
          played: mine,
        ),
      );
      if (mounted) setState(() => _mineEval = e);
    } on Object {
      // Leave the value empty.
    }
  }

  Future<void> _reveal() async {
    final p = _puzzle;
    if (p == null) return;
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final result = await ref.read(apiClientProvider).revealPuzzle(p.id);
      if (!mounted) return;
      setState(() {
        _result = result;
        _rating = result.rating;
        _arrows = true;
      });
      _sync();
    } on Object catch (e) {
      if (mounted) {
        showNote(
          context,
          e is ApiException && e.offline ? l.puzzleOffline : l.tourActionFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _retry() {
    final input = _input;
    setState(() {
      _result = null;
      _attempt = min(2, _attempt + 1);
      _mineEval = null;
      if (input != null) _input = input.reset();
    });
    _sync();
  }

  void _next() {
    _daily = false;
    unawaited(_load());
  }

  List<Move> _solutionMoves(Puzzle p) {
    final s = _result?.solution?.moves;
    if (s == null || s.isEmpty) return const [];
    try {
      return MoveNotation.parseTurn(s, p.rules, p.board, p.dice).moves;
    } on Object {
      return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final offline = ref.watch(offlineProvider);
    final p = _puzzle;
    final batch = _batch;
    Widget body;
    if (_loading) {
      body = Center(
        child: CircularProgressIndicator(color: c.accent, strokeWidth: 2),
      );
    } else if (_error != null || offline) {
      body = MessageState(
        title: l.onlineOfflineTitle,
        body: l.puzzleOffline,
        danger: true,
        action: l.retry,
        onAction: () => unawaited(_load()),
      );
    } else if (p == null || batch == null) {
      body = MessageState(
        title: l.puzzleSetDoneTitle,
        body: l.puzzleSetDoneBody,
        action: l.back,
        onAction: () => context.canPop() ? context.pop() : context.go('/home'),
      );
    } else {
      body = _puzzleBody(context, l, c, p, batch);
    }
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(
              title:
                  batch == null
                      ? ''
                      : _daily
                      ? l.puzzleDailyTitle
                      : l.puzzleTitle(
                        min(batch.solved + 1, max(1, batch.total)),
                        max(1, batch.total),
                      ),
              bare: true,
              trailing:
                  _rating == null
                      ? null
                      : Text(
                        l.puzzleRating(_rating!),
                        style: NardType.bodyS.copyWith(
                          color: c.text.withValues(alpha: .65),
                          fontFeatures: tabular,
                        ),
                      ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }

  Widget _puzzleBody(
    BuildContext context,
    AppLocalizations l,
    NardColors c,
    Puzzle p,
    PuzzleBatch batch,
  ) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final result = _result;
    final solution = _arrows ? _solutionMoves(p) : const <Move>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              TagChip(variantName(l, p.variant)),
              TagChip(phaseName(l, p.phase)),
              TagChip(difficultyName(l, p.difficulty)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.puzzlePrompt,
                style: NardType.title.copyWith(
                  fontSize: 22,
                  height: 28 / 22,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l.puzzleContext(
                  p.side == Side.white ? l.puzzleSideWhite : l.puzzleSideBlack,
                  p.dice.die1,
                  p.dice.die2,
                ),
                style: NardType.body.copyWith(
                  fontSize: 14,
                  color: c.text.withValues(alpha: .7),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              final ratio = BoardGeometry.heightPortrait / BoardGeometry.width;
              final w = min(
                box.maxWidth - 2 * NardSpace.boardGutter,
                box.maxHeight / ratio,
              );
              return Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: w,
                  height: w * ratio,
                  child: Stack(
                    children: [
                      Positioned.fill(child: GameWidget(game: _game)),
                      if (solution.isNotEmpty)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: MoveArrowsPainter(
                                rules: p.rules,
                                viewer: p.side,
                                side: p.side,
                                boardHeight: BoardGeometry.heightPortrait,
                                best: solution,
                                played:
                                    result?.correct ?? false ? const [] : _mine,
                                bestColor: c.successText,
                                playedColor: c.dangerText,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (result == null)
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, max(24, bottom + 8)),
            child: Row(
              children: [
                Pressable(
                  onTap: _busy ? null : _hint,
                  semanticLabel: l.puzzleHint,
                  child: Container(
                    width: 104,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(NardRadius.l),
                      border: Border.all(color: c.accent.withValues(alpha: .3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.rotate(
                          angle: pi / 4,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              border: Border.all(color: c.accent, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l.puzzleHint,
                          style: NardType.labelM.copyWith(color: c.text),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                NardIconButton(
                  icon: LucideIcons.undo2,
                  semanticLabel: l.actionUndo,
                  size: 56,
                  onPressed: (_input?.canUndo ?? false) ? _undo : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NardButton(
                    label: l.puzzleConfirm,
                    onPressed:
                        _busy || !(_input?.canConfirm ?? false)
                            ? null
                            : _confirm,
                  ),
                ),
              ],
            ),
          )
        else
          _panel(context, l, c, p, result),
      ],
    );
  }

  Widget _panel(
    BuildContext context,
    AppLocalizations l,
    NardColors c,
    Puzzle p,
    AttemptResult r,
  ) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final ok = r.correct;
    final tone = ok ? c.successText : c.dangerText;
    final finished = r.finished;
    final mine = _mine.isEmpty ? '' : MoveNotation.format(_mine);
    final second = r.solution?.secondBestMoves;
    final secondLoss = r.solution?.secondBestLoss;
    final best = r.solution?.moves;
    final myLoss = _mineEval?.loss;
    final rows = <(Color, String, String, String)>[
      if (mine.isNotEmpty)
        (
          tone,
          l.puzzleYours,
          mine,
          ok ? '0.000' : (myLoss == null ? '' : signed(-myLoss, digits: 3)),
        ),
      if (ok && second != null)
        (
          c.text.withValues(alpha: .6),
          l.puzzleSecondBest,
          second,
          secondLoss == null ? '' : signed(-secondLoss, digits: 3),
        ),
      if (!ok)
        (
          c.successText,
          l.puzzleBest,
          best ?? l.puzzleHidden,
          best == null ? '' : '0.000',
        ),
    ];
    final String title;
    final String sub;
    if (ok) {
      title = l.puzzleCorrect;
      sub = r.attempt <= 1 ? l.puzzleCorrectFirstTry : l.puzzleCorrectSecondTry;
    } else if (finished) {
      title = l.puzzleAnswer(best ?? '');
      sub = l.puzzleOutOfTries;
    } else {
      title = l.puzzleWrong;
      sub = l.puzzleAttemptsLeft(r.attemptsLeft);
    }
    return Container(
      padding: EdgeInsets.fromLTRB(16, 20, 16, max(24, bottom + 8)),
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(NardRadius.xl),
        ),
        border: Border(top: BorderSide(color: tone.withValues(alpha: .6))),
        boxShadow: c.panelShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ok ? c.success : c.danger,
                ),
                child: Icon(
                  ok ? LucideIcons.check : LucideIcons.x,
                  size: 20,
                  color: NardPalette.ivory100,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NardType.title.copyWith(fontSize: 20, color: tone),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: NardType.bodyS.copyWith(
                        color: c.text.withValues(alpha: .65),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                l.signedDelta(r.ratingDelta),
                style: NardType.labelM.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tone,
                  fontFeatures: tabular,
                ),
              ),
            ],
          ),
          if (rows.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: c.surfaceSunken,
                borderRadius: BorderRadius.circular(NardRadius.m),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < rows.length; i++) ...[
                    if (i > 0) const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 3,
                          decoration: BoxDecoration(
                            color: rows[i].$1,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${rows[i].$2} · ${rows[i].$3}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: NardType.bodyS.copyWith(
                              color: c.text.withValues(alpha: .75),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 58,
                          child: Text(
                            rows[i].$4,
                            textAlign: TextAlign.right,
                            style: NardType.bodyS.copyWith(
                              fontWeight: FontWeight.w700,
                              color: rows[i].$1,
                              fontFeatures: tabular,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: NardButton(
                  label:
                      ok || finished
                          ? l.puzzleSeeAnalysis
                          : l.puzzleShowSolution,
                  variant: NardButtonVariant.outline,
                  height: 52,
                  onPressed:
                      _busy
                          ? null
                          : ok || finished
                          ? () {
                            setState(() {
                              _arrows = !_arrows;
                              final input = _input;
                              if (_arrows && input != null) {
                                _input = input.reset();
                              }
                            });
                            _sync();
                          }
                          : _reveal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NardButton(
                  label: ok || finished ? l.puzzleNext : l.retry,
                  height: 52,
                  onPressed: _busy ? null : (ok || finished ? _next : _retry),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
