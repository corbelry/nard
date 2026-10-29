import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nard_core/nard_core.dart';

import '../app/providers.dart';
import '../board/board_painter.dart';
import '../game/game_controller.dart';
import '../game/match_setup.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/background.dart';
import '../ui/buttons.dart';
import '../ui/controls.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import 'setup_screen.dart';

/// 18.1 Pass & play setup.
class HotseatSetupScreen extends ConsumerStatefulWidget {
  const HotseatSetupScreen({super.key});

  @override
  ConsumerState<HotseatSetupScreen> createState() => _HotseatSetupScreenState();
}

class _HotseatSetupScreenState extends ConsumerState<HotseatSetupScreen> {
  late MatchSetup _setup = MatchSetup(
    variant:
        ref.read(currentSettingsProvider).preferredVariant ?? Variant.shortNard,
    opponent: OpponentKind.passAndPlay,
  );

  Future<void> _editName(Side side) async {
    final l = AppLocalizations.of(context);
    final current = side == Side.white ? _setup.whiteName : _setup.blackName;
    final ctrl = TextEditingController(text: current);
    final name = await showNardSheet<String>(
      context,
      builder:
          (ctx) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(ctx).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SheetTitle(l.hotseatEditName),
                const SizedBox(height: 14),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  maxLength: 16,
                  textCapitalization: TextCapitalization.words,
                  style: NardType.body.copyWith(color: ctx.nard.text),
                  cursorColor: ctx.nard.accent,
                  decoration: InputDecoration(
                    hintText: l.hotseatNameHint,
                    counterText: '',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(NardRadius.m),
                      borderSide: BorderSide(color: ctx.nard.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(NardRadius.m),
                      borderSide: BorderSide(
                        color: ctx.nard.accent,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onSubmitted: (v) => Navigator.of(ctx).pop(v),
                ),
                const SizedBox(height: 14),
                NardButton(
                  label: l.continueAction,
                  size: NardButtonSize.m,
                  onPressed: () => Navigator.of(ctx).pop(ctrl.text),
                ),
              ],
            ),
          ),
    );
    ctrl.dispose();
    if (name == null) return;
    setState(() {
      _setup =
          side == Side.white
              ? _setup.copyWith(whiteName: name.trim())
              : _setup.copyWith(blackName: name.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    Widget player(Side side) {
      final custom = side == Side.white ? _setup.whiteName : _setup.blackName;
      final name =
          custom.isNotEmpty
              ? custom
              : (side == Side.white
                  ? l.hotseatDefaultWhite
                  : l.hotseatDefaultBlack);
      return Pressable(
        onTap: () => _editName(side),
        semanticLabel: '${l.hotseatEditName}: $name',
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: c.text.withValues(alpha: .04),
            borderRadius: BorderRadius.circular(NardRadius.l),
            border: Border.all(color: c.accent.withValues(alpha: .18)),
          ),
          child: Row(
            children: [
              CustomPaint(size: const Size(32, 32), painter: _Swatch(side)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      side == Side.white ? l.hotseatWhite : l.hotseatBlack,
                      style: NardType.caption.copyWith(
                        color: c.text.withValues(alpha: .55),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NardType.labelM.copyWith(
                        fontSize: 16,
                        color: c.text,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.pencil,
                size: 16,
                color: c.text.withValues(alpha: .5),
              ),
            ],
          ),
        ),
      );
    }

    Widget toggle(
      String label,
      String sub,
      bool value,
      ValueChanged<bool> set,
    ) => Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: c.accent.withValues(alpha: .08)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: NardType.body.copyWith(color: c.text)),
                const SizedBox(height: 1),
                Text(
                  sub,
                  style: NardType.caption.copyWith(
                    color: c.text.withValues(alpha: .55),
                  ),
                ),
              ],
            ),
          ),
          NardSwitch(
            value: value,
            compact: true,
            semanticLabel: label,
            onChanged: set,
          ),
        ],
      ),
    );

    return Scaffold(
      body: NardBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(title: l.hotseatTitle),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                  children: [
                    player(Side.white),
                    const SizedBox(height: 14),
                    player(Side.black),
                    const SizedBox(height: 20),
                    Overline(l.hotseatGameSection),
                    const SizedBox(height: 10),
                    NardSegmented<Variant>(
                      pill: true,
                      values: const [Variant.shortNard, Variant.longNard],
                      labels: [l.variantShort, l.variantLong],
                      selected: _setup.variant,
                      onChanged:
                          (v) => setState(
                            () => _setup = _setup.copyWith(variant: v),
                          ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        for (final n in SetupScreen.formats) ...[
                          if (n != SetupScreen.formats.first)
                            const SizedBox(width: 8),
                          Expanded(
                            child: OptionTile(
                              label:
                                  n == 1 ? l.formatOneGame : l.formatPoints(n),
                              selected: _setup.matchLength == n,
                              onTap:
                                  () => setState(
                                    () =>
                                        _setup = _setup.copyWith(
                                          matchLength: n,
                                        ),
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: c.text.withValues(alpha: .04),
                        borderRadius: BorderRadius.circular(NardRadius.l),
                        border: Border.all(
                          color: c.accent.withValues(alpha: .14),
                        ),
                      ),
                      child: Column(
                        children: [
                          toggle(
                            l.hotseatHideBetweenTurns,
                            l.hotseatHideBetweenTurnsSub,
                            _setup.hideBetweenTurns,
                            (v) => setState(
                              () =>
                                  _setup = _setup.copyWith(hideBetweenTurns: v),
                            ),
                          ),
                          toggle(
                            l.hotseatFlipBoard,
                            l.hotseatFlipBoardSub,
                            _setup.flipBoard,
                            (v) => setState(
                              () => _setup = _setup.copyWith(flipBoard: v),
                            ),
                          ),
                          toggle(
                            l.hotseatAllowUndo,
                            l.hotseatAllowUndoSub,
                            _setup.allowUndo,
                            (v) => setState(
                              () => _setup = _setup.copyWith(allowUndo: v),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: NardButton(
                  label: l.hotseatStart,
                  onPressed: () {
                    ref.read(gameControllerProvider.notifier).start(_setup);
                    context.go('/home');
                    context.push('/game');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Swatch extends CustomPainter {
  const _Swatch(this.side);

  final Side side;

  @override
  void paint(Canvas canvas, Size size) => BoardPainter.paintChecker(
    canvas,
    size.center(Offset.zero),
    size.width / 2,
    side,
  );

  @override
  bool shouldRepaint(_Swatch old) => old.side != side;
}
