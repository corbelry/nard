import 'dart:async';
import 'dart:convert';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nard_core/nard_core.dart';

import '../app/providers.dart';
import '../board/board_game.dart';
import '../board/board_scene.dart';
import '../data/database.dart';
import '../game/match_setup.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/board_theme.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/background.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import 'replay_list_screen.dart';

/// One step of a replay: the position after an action.
class ReplayFrame {
  const ReplayFrame({
    required this.state,
    required this.label,
    this.side,
    this.dice,
    this.moves = const [],
  });

  final GameState state;

  /// Move-list text (notation or event).
  final String label;
  final Side? side;
  final DiceRoll? dice;
  final List<Move> moves;
}

/// Replays [record] into frames: the start, then one per turn or event.
List<ReplayFrame> buildFrames(GameRecord record, AppLocalizations l) {
  var state = GameState.newGame(
    rulesFor(record.variant),
    config: record.config,
  );
  final frames = [ReplayFrame(state: state, label: '')];
  DiceRoll? lastRoll;
  for (final action in record.actions) {
    state = state.apply(action);
    switch (action) {
      case OpeningRoll(:final white, :final black):
        if (state.phase == GamePhase.awaitingMove) {
          lastRoll = DiceRoll(white, black);
        }
        frames.add(
          ReplayFrame(state: state, label: l.replayOpening(white, black)),
        );
      case RollDice(:final roll):
        lastRoll = roll;
      case PlayTurn(:final by, :final moves):
        frames.add(
          ReplayFrame(
            state: state,
            side: by,
            dice: lastRoll,
            moves: moves,
            label: moves.isEmpty ? l.replayNoMove : MoveNotation.format(moves),
          ),
        );
      case OfferDouble(:final by):
        frames.add(ReplayFrame(state: state, side: by, label: l.replayDouble));
      case TakeDouble(:final by):
        frames.add(ReplayFrame(state: state, side: by, label: l.replayTake));
      case DropDouble(:final by):
        frames.add(ReplayFrame(state: state, side: by, label: l.replayDrop));
      case OfferResignation(:final by):
        frames.add(ReplayFrame(state: state, side: by, label: l.replayResign));
      case AcceptResignation() || RejectResignation() || Forfeit():
        break;
    }
  }
  return frames;
}

final _gameRowProvider = FutureProvider.autoDispose.family<GameRecordRow?, int>(
  (ref, id) => ref.watch(databaseProvider).gameById(id),
);

/// 10.1 Replay viewer (analysis is Phase 6).
class ReplayScreen extends ConsumerWidget {
  const ReplayScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final row = ref.watch(_gameRowProvider(id));
    return Scaffold(
      body: NardBackground(
        child: SafeArea(
          child: row.when(
            loading: () => const SizedBox.expand(),
            error: (_, _) => _error(context, l),
            data: (r) {
              if (r == null) return _error(context, l);
              try {
                final setup = MatchSetup.fromJson(
                  jsonDecode(r.setupJson) as Map<String, Object?>,
                );
                final record = GameRecord.fromJson(
                  jsonDecode(r.recordJson) as Map<String, Object?>,
                );
                return _ReplayView(
                  setup: setup,
                  frames: buildFrames(record, l),
                  gameNumber: r.gameIndex + 1,
                );
              } on Object {
                return _error(context, l);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _error(BuildContext context, AppLocalizations l) => Column(
    children: [
      ScreenHeader(title: l.replayListTitle),
      Expanded(
        child: MessageState(
          title: l.replayLoadError,
          body: l.errorBody,
          danger: true,
        ),
      ),
    ],
  );
}

class _ReplayView extends ConsumerStatefulWidget {
  const _ReplayView({
    required this.setup,
    required this.frames,
    required this.gameNumber,
  });

  final MatchSetup setup;
  final List<ReplayFrame> frames;
  final int gameNumber;

  @override
  ConsumerState<_ReplayView> createState() => _ReplayViewState();
}

class _ReplayViewState extends ConsumerState<_ReplayView> {
  late final NardBoardGame _game = NardBoardGame(
    boardHeight: BoardGeometry.heightPortrait,
  );
  final _scroll = ScrollController();
  int _index = 0;
  Timer? _play;

  @override
  void initState() {
    super.initState();
    _show();
  }

  @override
  void dispose() {
    _play?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _go(int i) {
    setState(() => _index = i.clamp(0, widget.frames.length - 1));
    _show();
    if (_scroll.hasClients) {
      unawaited(
        _scroll.animateTo(
          (_index * 40.0 - 80).clamp(0, _scroll.position.maxScrollExtent),
          duration: NardMotion.fast,
          curve: NardMotion.standard,
        ),
      );
    }
  }

  void _show() {
    final f = widget.frames[_index];
    final s = f.state;
    final dice = f.dice;
    _game.show(
      BoardScene(
        rules: s.rules,
        viewer: widget.setup.localSide,
        board: s.board,
        dice:
            dice == null
                ? const []
                : dice.isDouble
                ? [dice.die1, dice.die1, dice.die1, dice.die1]
                : [dice.die1, dice.die2],
        diceOwner: f.side,
        cubeVisible: s.config.cubeEnabled,
        cubeValue: s.cube.value,
        cubeOwner: s.cube.owner,
        lastMoves: f.moves,
        lastMover: f.side,
        colorBlind: ref.read(currentSettingsProvider).colorBlind,
      ),
    );
  }

  void _togglePlay() {
    if (_play != null) {
      _play!.cancel();
      setState(() => _play = null);
      return;
    }
    if (_index >= widget.frames.length - 1) _go(0);
    setState(() {
      _play = Timer.periodic(const Duration(milliseconds: 1000), (t) {
        if (_index >= widget.frames.length - 1) {
          t.cancel();
          setState(() => _play = null);
          return;
        }
        _go(_index + 1);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final (white, black) = playerNames(l, widget.setup);
    final last = widget.frames.length - 1;
    Widget circle(
      IconData icon,
      String label,
      VoidCallback? onTap, {
      bool big = false,
    }) {
      final size = big ? 52.0 : 40.0;
      return Pressable(
        onTap: onTap,
        semanticLabel: label,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: big ? c.accent : null,
            border: big ? null : Border.all(color: c.line),
          ),
          child: Icon(
            icon,
            size: 18,
            color:
                big
                    ? c.clockActiveText
                    : (onTap == null ? c.text.withValues(alpha: .4) : c.text),
          ),
        ),
      );
    }

    return Column(
      children: [
        ScreenHeader(
          title: l.replayTitle(widget.gameNumber),
          trailing: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: Text(
              l.replayPlayers(white, black),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: NardType.caption.copyWith(
                color: c.text.withValues(alpha: .6),
              ),
            ),
          ),
        ),
        LayoutBuilder(
          builder: (_, box) {
            final w = box.maxWidth - 2 * NardSpace.boardGutter;
            return SizedBox(
              width: w,
              height: w * BoardGeometry.heightPortrait / BoardGeometry.width,
              child: GameWidget(game: _game),
            );
          },
        ),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            itemCount: widget.frames.length - 1,
            itemBuilder: (_, k) {
              final i = k + 1;
              final f = widget.frames[i];
              final current = i == _index;
              final dice = f.dice;
              return Pressable(
                onTap: () => _go(i),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: current ? c.accent.withValues(alpha: .12) : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          '$i',
                          style: NardType.bodyS.copyWith(
                            color: c.text.withValues(alpha: .5),
                            fontFeatures: tabular,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 44,
                        child: Text(
                          dice == null ? '' : '${dice.die1}-${dice.die2}',
                          style: NardType.bodyS.copyWith(
                            color: c.text.withValues(alpha: .7),
                            fontFeatures: tabular,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (f.side != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  f.side == Side.white
                                      ? const Color(0xFFEFE4CF)
                                      : const Color(0xFF2B2724),
                              border: Border.all(color: c.line),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          f.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NardType.mono.copyWith(color: c.text),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: c.accent.withValues(alpha: .14)),
            ),
          ),
          child: Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  activeTrackColor: c.accent,
                  inactiveTrackColor: c.text.withValues(alpha: .12),
                  thumbColor: NardPalette.ivory100,
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                ),
                child: Slider(
                  value: _index.toDouble(),
                  max: last.toDouble().clamp(1, double.infinity),
                  divisions: last < 1 ? 1 : last,
                  onChanged: (v) => _go(v.round()),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  circle(
                    LucideIcons.skipBack,
                    l.replayStart,
                    _index > 0 ? () => _go(0) : null,
                  ),
                  const SizedBox(width: 18),
                  circle(
                    LucideIcons.chevronLeft,
                    l.replayBack,
                    _index > 0 ? () => _go(_index - 1) : null,
                  ),
                  const SizedBox(width: 18),
                  circle(
                    _play == null ? LucideIcons.play : LucideIcons.pause,
                    _play == null ? l.replayPlay : l.replayPause,
                    _togglePlay,
                    big: true,
                  ),
                  const SizedBox(width: 18),
                  circle(
                    LucideIcons.chevronRight,
                    l.replayForward,
                    _index < last ? () => _go(_index + 1) : null,
                  ),
                  const SizedBox(width: 18),
                  circle(
                    LucideIcons.skipForward,
                    l.replayEnd,
                    _index < last ? () => _go(last) : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
