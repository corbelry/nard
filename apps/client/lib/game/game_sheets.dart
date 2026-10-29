import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nard_core/nard_core.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/buttons.dart';
import '../ui/controls.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';

enum MenuChoice { resume, settings, rules, sound, resign, leave }

/// Game menu sheet (2.9).
Future<MenuChoice?> showGameMenu(
  BuildContext context, {
  required Variant variant,
  required bool soundOn,
}) {
  final l = AppLocalizations.of(context);
  return showNardSheet<MenuChoice>(
    context,
    builder: (ctx) {
      final c = ctx.nard;
      Widget row(
        MenuChoice choice,
        IconData icon,
        String label, {
        String? trailing,
        Color? color,
      }) => Pressable(
        onTap: () => Navigator.of(ctx).pop(choice),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: c.accent.withValues(alpha: .12)),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color ?? c.text),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: NardType.body.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: color ?? c.text,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing,
                  style: NardType.bodyS.copyWith(
                    color: c.text.withValues(alpha: .5),
                  ),
                ),
            ],
          ),
        ),
      );
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            row(MenuChoice.resume, LucideIcons.play, l.menuResume),
            row(MenuChoice.settings, LucideIcons.settings, l.menuSettings),
            row(
              MenuChoice.rules,
              LucideIcons.fileText,
              l.menuRules,
              trailing:
                  variant == Variant.shortNard ? l.variantShort : l.variantLong,
            ),
            row(
              MenuChoice.sound,
              soundOn ? LucideIcons.volume1 : LucideIcons.volumeX,
              l.menuSound,
              trailing: soundOn ? l.valueOn : l.valueOff,
            ),
            row(
              MenuChoice.resign,
              LucideIcons.flag,
              l.menuResign,
              color: c.dangerText,
            ),
            row(MenuChoice.leave, LucideIcons.logOut, l.menuLeave),
          ],
        ),
      );
    },
  );
}

/// Resign sheet (2.8); returns the chosen level.
Future<WinKind?> showResignSheet(
  BuildContext context, {
  required int cube,
  required Variant variant,
}) {
  final l = AppLocalizations.of(context);
  return showNardSheet<WinKind>(
    context,
    builder: (ctx) => _ResignBody(cube: cube, variant: variant, l: l),
  );
}

class _ResignBody extends StatefulWidget {
  const _ResignBody({
    required this.cube,
    required this.variant,
    required this.l,
  });

  final int cube;
  final Variant variant;
  final AppLocalizations l;

  @override
  State<_ResignBody> createState() => _ResignBodyState();
}

class _ResignBodyState extends State<_ResignBody> {
  WinKind _kind = WinKind.single;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final l = widget.l;
    final options = [
      (WinKind.single, l.resignSingle, l.resignSingleDesc),
      (WinKind.gammon, l.resignMars, l.resignMarsDesc),
      (
        WinKind.backgammon,
        l.resignKoks,
        widget.variant == Variant.longNard
            ? l.resignKoksDescLong
            : l.resignKoksDesc,
      ),
    ];
    final points = _kind.multiplier * widget.cube;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetTitle(l.resignTitle),
          const SizedBox(height: 8),
          Text(
            l.resignBody(widget.cube),
            style: NardType.bodyS.copyWith(color: c.textDim),
          ),
          const SizedBox(height: 14),
          for (final (kind, title, desc) in options) ...[
            Pressable(
              onTap: () => setState(() => _kind = kind),
              child: AnimatedContainer(
                duration: NardMotion.fast,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kind == _kind ? c.accent.withValues(alpha: .1) : null,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        kind == _kind
                            ? c.accent
                            : c.accent.withValues(alpha: .18),
                    width: kind == _kind ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    RadioDot(selected: kind == _kind),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: NardType.labelM.copyWith(color: c.text),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            desc,
                            style: NardType.caption.copyWith(
                              color: c.text.withValues(alpha: .6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      l.resignPoints(kind.multiplier * widget.cube),
                      style: NardType.labelM.copyWith(
                        color: c.dangerText,
                        fontFeatures: tabular,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                flex: 10,
                child: NardButton(
                  label: l.cancel,
                  variant: NardButtonVariant.outline,
                  size: NardButtonSize.m,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 14,
                child: NardButton(
                  label: l.resignConfirm(points),
                  variant: NardButtonVariant.danger,
                  size: NardButtonSize.m,
                  onPressed: () => Navigator.of(context).pop(_kind),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Cube offer sheet (6.2): true = take, false = drop.
Future<bool?> showCubeOfferSheet(
  BuildContext context, {
  required String offerer,
  required int value,
}) {
  final l = AppLocalizations.of(context);
  return showNardSheet<bool>(
    context,
    dismissible: false,
    handle: false,
    builder: (ctx) {
      final c = ctx.nard;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFBF5E8), Color(0xFFDDCDAA)],
                  ),
                  border: Border.all(color: c.accent, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0x66E8C468), blurRadius: 26),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '${value * 2}',
                  style: NardType.displayL.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: NardPalette.walnut900,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.cubeOfferTitle(offerer),
                      style: NardType.title.copyWith(color: c.text),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      l.cubeOfferBody(value, value * 2),
                      style: NardType.bodyS.copyWith(color: c.textDim),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _AnswerButton(
                  label: l.cubeDecline,
                  sub: l.cubeDeclineSub(value),
                  onTap: () => Navigator.of(ctx).pop(false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NardButton(
                  label: l.cubeAccept,
                  sub: l.cubeAcceptSub(value * 2),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  labelStyle: NardType.labelL.copyWith(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.label,
    required this.sub,
    required this.onTap,
  });

  final String label;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(c.buttonRadius),
          border: Border.all(
            color: c.dangerText.withValues(alpha: .6),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: NardType.labelM.copyWith(
                fontSize: 16,
                color: c.dangerText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: NardType.micro.copyWith(
                color: c.dangerText.withValues(alpha: .85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Short rules summary for the current variant.
Future<void> showRulesSheet(BuildContext context, Variant variant) {
  final l = AppLocalizations.of(context);
  return showNardSheet<void>(
    context,
    builder: (ctx) {
      final c = ctx.nard;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: min(520, MediaQuery.sizeOf(ctx).height * .7),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SheetTitle(
                variant == Variant.shortNard ? l.variantShort : l.variantLong,
              ),
              const SizedBox(height: 12),
              Text(
                variant == Variant.shortNard
                    ? l.rulesShortBody
                    : l.rulesLongBody,
                style: NardType.body.copyWith(
                  color: c.text.withValues(alpha: .85),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Confirms leaving an unfinished match.
Future<bool?> showLeaveSheet(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showNardSheet<bool>(
    context,
    builder:
        (ctx) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetTitle(l.leaveTitle),
            const SizedBox(height: 8),
            Text(
              l.leaveBody,
              style: NardType.bodyS.copyWith(color: ctx.nard.textDim),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: NardButton(
                    label: l.cancel,
                    variant: NardButtonVariant.outline,
                    size: NardButtonSize.m,
                    onPressed: () => Navigator.of(ctx).pop(false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: NardButton(
                    label: l.leaveConfirm,
                    variant: NardButtonVariant.danger,
                    size: NardButtonSize.m,
                    onPressed: () => Navigator.of(ctx).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
  );
}
