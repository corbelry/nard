import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nard_core/nard_core.dart';

import '../app/providers.dart';
import '../board/board_game.dart';
import '../board/board_scene.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/board_theme.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/background.dart';
import '../ui/buttons.dart';
import '../ui/pressable.dart';

/// One scripted lesson step: a position, dice and the moves to make.
class _Step {
  const _Step(this.board, this.dice, this.moves);

  final BoardState board;
  final List<int> dice;

  /// Moves to play in any order; empty = tap any own checker.
  final List<Move> moves;
}

const _short = ShortNardRules();

BoardState _pos(Map<int, int> white, [Map<int, int>? black]) =>
    BoardState.fromPoints(
      white: white,
      black: black ?? ShortNardRules.startingPoints,
      whiteTurnsTaken: 1,
      blackTurnsTaken: 1,
    );

final _steps = [
  _Step(_short.initialState(), const [], const []),
  _Step(_short.initialState(), const [6, 1], const [Move(13, 7, 6)]),
  _Step(
    _short.initialState(),
    const [3, 1],
    const [Move(8, 5, 3), Move(6, 5, 1)],
  ),
  _Step(_short.initialState(), const [5], const [Move(13, 8, 5)]),
  _Step(
    _short.initialState(),
    const [2],
    const [Move(6, 4, 2, hit: true)],
  ).withBlack({21: 1, 24: 1, 13: 5, 8: 3, 6: 5}),
  _Step(
    _pos({BoardState.bar: 1, 24: 1, 13: 5, 8: 3, 6: 5}),
    const [3],
    const [Move(BoardState.bar, 22, 3)],
  ),
  _Step(
    _pos({6: 3, 5: 3, 4: 3, 3: 2, 2: 2, 1: 2}, {24: 15}),
    const [6],
    const [Move(6, BoardState.off, 6)],
  ),
];

extension on _Step {
  _Step withBlack(Map<int, int> black) =>
      _Step(_pos(ShortNardRules.startingPoints, black), dice, moves);
}

/// 9.5 Interactive lesson: seven scripted steps on a live board.
class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key});

  static int get stepCount => _steps.length;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  late final NardBoardGame _game = NardBoardGame(
    boardHeight: BoardGeometry.heightPortrait,
    onTapSlot: _tap,
    onDrop: (from, to) => to == null ? null : _move(from, to),
    canDrag: (slot) => _remaining.any((m) => m.from == slot),
  );

  int _index = 0;
  late BoardState _board;
  late List<Move> _remaining;
  int? _selected;
  bool _done = false;
  Timer? _next;

  @override
  void initState() {
    super.initState();
    _load(0);
  }

  @override
  void dispose() {
    _next?.cancel();
    super.dispose();
  }

  void _load(int i) {
    _index = i;
    _board = _steps[i].board;
    _remaining = List.of(_steps[i].moves);
    _selected = null;
    _show();
  }

  void _show() {
    final step = _steps[_index];
    final used = step.moves.length - _remaining.length;
    final targets = {
      for (final m in _remaining)
        if (m.from == _selected) m.to,
    };
    _game.show(
      BoardScene(
        rules: _short,
        viewer: Side.white,
        board: _board,
        dice: step.dice,
        diceUsed: [for (var j = 0; j < step.dice.length; j++) j < used],
        mover: Side.white,
        selected: _selected,
        targets: targets,
        mustEnter: _board.barCount(Side.white) > 0,
        colorBlind: ref.read(currentSettingsProvider).colorBlind,
      ),
    );
    if (mounted) setState(() {});
  }

  void _tap(int? slot) {
    if (slot == null || _next != null) return;
    if (_steps[_index].moves.isEmpty) {
      if (_board.count(Side.white, slot) > 0) _advance();
      return;
    }
    final selected = _selected;
    if (selected != null &&
        _remaining.any((m) => m.from == selected && m.to == slot)) {
      _move(selected, slot);
      return;
    }
    _selected = _remaining.any((m) => m.from == slot) ? slot : null;
    _show();
  }

  void _move(int from, int to) {
    final i = _remaining.indexWhere((m) => m.from == from && m.to == to);
    if (i < 0) {
      _show();
      return;
    }
    final move = _remaining.removeAt(i);
    _board = _short.applyMove(_board.withTurn(Side.white), move);
    _selected = null;
    _show();
    if (_remaining.isEmpty) _advance();
  }

  void _advance() {
    _next = Timer(const Duration(milliseconds: 700), () {
      _next = null;
      if (_index + 1 < _steps.length) {
        _load(_index + 1);
      } else {
        setState(() => _done = true);
      }
    });
  }

  ({String title, String body}) _text(AppLocalizations l) => switch (_index) {
    0 => (title: l.lessonStep1Title, body: l.lessonStep1Body),
    1 => (title: l.lessonStep2Title, body: l.lessonStep2Body),
    2 => (title: l.lessonStep3Title, body: l.lessonStep3Body),
    3 => (title: l.lessonStep4Title, body: l.lessonStep4Body),
    4 => (title: l.lessonStep5Title, body: l.lessonStep5Body),
    5 => (title: l.lessonStep6Title, body: l.lessonStep6Body),
    _ => (title: l.lessonStep7Title, body: l.lessonStep7Body),
  };

  void _exit() => context.canPop() ? context.pop() : context.go('/home');

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final text =
        _done ? (title: l.lessonDoneTitle, body: l.lessonDoneBody) : _text(l);
    final total = _steps.length;
    return Scaffold(
      body: NardBackground(
        band: false,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
                child: Row(
                  children: [
                    Pressable(
                      onTap: _exit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Center(
                          widthFactor: 1,
                          child: Text(
                            l.lessonSkip,
                            style: NardType.body.copyWith(
                              color: c.text.withValues(alpha: .7),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          for (var i = 0; i < total; i++) ...[
                            if (i > 0) const SizedBox(width: 4),
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color:
                                      i <= _index || _done
                                          ? c.accent
                                          : c.text.withValues(alpha: .15),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l.lessonProgress(_done ? total : _index + 1, total),
                      style: NardType.bodyS.copyWith(
                        color: c.text.withValues(alpha: .6),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LayoutBuilder(
                      builder: (_, box) {
                        final w = box.maxWidth - 2 * NardSpace.boardGutter;
                        return SizedBox(
                          width: w,
                          height:
                              w *
                              BoardGeometry.heightPortrait /
                              BoardGeometry.width,
                          child: GameWidget(game: _game),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    _CoachBubble(title: text.title, body: text.body),
                  ],
                ),
              ),
              if (_done)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: NardButton(label: l.lessonFinish, onPressed: _exit),
                )
              else
                const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoachBubble extends StatelessWidget {
  const _CoachBubble({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.accent.withValues(alpha: .35)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, 10),
            blurRadius: 30,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.accent, width: 1.5),
              color: c.text.withValues(alpha: .08),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: NardType.title.copyWith(fontSize: 17, color: c.text),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: NardType.body.copyWith(
                    fontSize: 14,
                    height: 20 / 14,
                    color: c.text.withValues(alpha: .75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
