import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/buttons.dart';
import '../ui/controls.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import 'game_presenter.dart';

/// Player card (game.md §3). Offline: name, pip count and bot level; the
/// clock is a Phase 3 feature and is hidden.
class PlayerCard extends StatelessWidget {
  const PlayerCard({
    super.key,
    required this.name,
    required this.meta,
    required this.active,
    required this.ivory,
    this.side = false,
    this.trailing,
  });

  /// The clock (online games).
  final Widget? trailing;

  final String name;
  final String meta;
  final bool active;

  /// Checker colour of this player (avatar tint).
  final bool ivory;

  /// Landscape column layout (158 wide).
  final bool side;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final avatarSize = side ? 38.0 : 46.0;
    final initials = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    final avatar = Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(
          startAngle: 210 * pi / 180,
          endAngle: 210 * pi / 180 + 2 * pi,
          colors: [
            Color(0xFF8A6A22),
            Color(0xFFE8C468),
            Color(0xFFA07C30),
            Color(0xFFE8C468),
            Color(0xFF8A6A22),
          ],
        ),
        boxShadow:
            active
                ? [
                  BoxShadow(
                    color: c.accent.withValues(alpha: .2),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: c.accent.withValues(alpha: .4),
                    blurRadius: 16,
                  ),
                ]
                : null,
      ),
      padding: EdgeInsets.all(side ? 2.5 : 3),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                ivory
                    ? const [Color(0xFF5B4A33), Color(0xFF2A2116)]
                    : const [Color(0xFF2F4A52), Color(0xFF162428)],
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: NardType.title.copyWith(
            fontSize: side ? 15 : 18,
            color: c.text,
            height: 1,
          ),
        ),
      ),
    );
    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: (side ? NardType.bodyS : NardType.labelM).copyWith(
            color: c.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: side ? 3 : 5),
        Text(
          meta,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: (side ? NardType.micro : NardType.caption).copyWith(
            color: c.textDim,
            fontFeatures: tabular,
          ),
        ),
      ],
    );
    return AnimatedContainer(
      duration: NardMotion.fast,
      padding:
          side
              ? const EdgeInsets.all(12)
              : const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: active ? c.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(c.cardRadius),
        border: Border.all(color: active ? c.line : Colors.transparent),
      ),
      child:
          side
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      avatar,
                      const SizedBox(width: 10),
                      Expanded(child: texts),
                    ],
                  ),
                  if (trailing != null) ...[
                    const SizedBox(height: 10),
                    Align(alignment: Alignment.centerRight, child: trailing),
                  ],
                ],
              )
              : Row(
                children: [
                  avatar,
                  const SizedBox(width: 12),
                  Expanded(child: texts),
                  if (trailing != null) ...[
                    const SizedBox(width: 12),
                    trailing!,
                  ],
                ],
              ),
    );
  }
}

/// The drawn "2" cube glyph of the double button.
class CubeGlyph extends StatelessWidget {
  const CubeGlyph({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      border: Border.all(color: color, width: 2),
      borderRadius: BorderRadius.circular(4),
    ),
    alignment: Alignment.center,
    child: Text(
      '2',
      style: NardType.micro.copyWith(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1,
      ),
    ),
  );
}

/// The big primary of the control bar with its four looks.
class GamePrimaryButton extends StatelessWidget {
  const GamePrimaryButton({
    super.key,
    required this.label,
    required this.sub,
    required this.style,
    required this.onPressed,
    this.height = 62,
    this.column = false,
  });

  final String label;
  final String? sub;
  final PrimaryStyle style;
  final VoidCallback? onPressed;
  final double height;

  /// Landscape: label above sub.
  final bool column;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    if (style == PrimaryStyle.on) {
      return NardButton(
        label: label,
        sub: column ? null : sub,
        onPressed: onPressed,
        height: height,
      );
    }
    final wait = style == PrimaryStyle.wait;
    final fg = wait ? c.accent : c.textDim;
    final labelStyle = NardType.labelL.copyWith(
      fontFamily: c.buttonFont,
      fontSize: column ? 15 : 17,
      color: fg,
    );
    final subStyle = NardType.bodyS.copyWith(
      color: fg.withValues(alpha: .75),
      fontFeatures: tabular,
    );
    final children = [
      Flexible(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: labelStyle,
        ),
      ),
      if (sub != null) ...[
        SizedBox(width: column ? 0 : 10, height: column ? 4 : 0),
        Text(sub!, style: subStyle),
      ],
    ];
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: wait ? null : c.surface,
            borderRadius: BorderRadius.circular(
              c.buttonRadius == 999 ? height / 2 : c.buttonRadius,
            ),
            border: Border.all(
              color: wait ? c.accent : c.line,
              width: wait ? 1.5 : 1,
            ),
          ),
          child:
              column
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: children,
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: children,
                  ),
        ),
      ),
    );
  }
}

/// Card shown on the board when no move is possible (game.md §6.1).
class NoMovesCard extends StatelessWidget {
  const NoMovesCard({
    super.key,
    required this.title,
    required this.body,
    required this.duration,
    this.progress = true,
  });

  final String title;
  final String body;
  final Duration duration;
  final bool progress;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: BorderRadius.circular(c.cardRadius),
        border: Border.all(color: c.line),
        boxShadow: c.elevation2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: NardType.title.copyWith(
              fontSize: 17,
              height: 22 / 17,
              color: c.text,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            textAlign: TextAlign.center,
            style: NardType.bodyS.copyWith(
              color: c.textDim,
              fontFeatures: tabular,
            ),
          ),
          if (progress) ...[
            const SizedBox(height: 10),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: duration,
              builder:
                  (_, v, _) =>
                      NardProgressBar(value: v, height: 3, track: c.line),
            ),
          ],
        ],
      ),
    );
  }
}

/// Illegal-move toast over the lower board edge (23.2 / 23.3).
class RuleToast extends StatelessWidget {
  const RuleToast({super.key, required this.title, this.body});

  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: c.surfaceRaised,
          borderRadius: BorderRadius.circular(c.cardRadius),
          border: Border.all(color: c.dangerText, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x8C000000),
              offset: Offset(0, 12),
              blurRadius: 30,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.danger,
              ),
              child: Icon(LucideIcons.x, size: 14, color: c.text),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: NardType.labelM.copyWith(
                      fontSize: 14,
                      color: c.errorTitle,
                    ),
                  ),
                  if (body != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      body!,
                      style: NardType.caption.copyWith(
                        height: 17 / 12,
                        color: c.text.withValues(alpha: .75),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Crawford indicator chip (23.1).
class CrawfordChip extends StatelessWidget {
  const CrawfordChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: c.accent.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.accent.withValues(alpha: .5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.squareSlash, size: 14, color: c.accentHi),
          const SizedBox(width: 8),
          Text(
            label,
            style: NardType.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: c.accentHi,
            ),
          ),
        ],
      ),
    );
  }
}

/// Game-over card when the match continues (game.md §6.3).
class GameOverCard extends StatelessWidget {
  const GameOverCard({
    super.key,
    required this.title,
    required this.result,
    required this.meName,
    required this.oppName,
    required this.meScore,
    required this.oppScore,
    required this.progress,
    required this.nextLabel,
    required this.onNext,
    this.won = true,
  });

  final String title;
  final String result;
  final String meName;
  final String oppName;
  final int meScore;
  final int oppScore;
  final String? progress;
  final String nextLabel;
  final VoidCallback onNext;
  final bool won;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Container(
      width: 318,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: BorderRadius.circular(c.cardRadius),
        border: Border.all(color: c.line),
        boxShadow: c.elevation3,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const OrnamentDivider(line: 44, opacity: .6),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: NardType.displayXl.copyWith(
              fontSize: 38,
              height: 42 / 38,
              letterSpacing: 2.3,
              color: won ? c.accent : c.text,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            decoration: BoxDecoration(
              color: (won ? c.successText : c.dangerText).withValues(
                alpha: .16,
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              result,
              style: NardType.bodyS.copyWith(
                fontWeight: FontWeight.w600,
                color: won ? c.successText : c.dangerText,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: _name(context, meName, TextAlign.right)),
              const SizedBox(width: 16),
              Text(
                '$meScore – $oppScore',
                style: NardType.displayL.copyWith(
                  fontSize: 30,
                  height: 34 / 30,
                  color: c.text,
                  fontFeatures: tabular,
                ),
              ),
              const SizedBox(width: 16),
              Flexible(child: _name(context, oppName, TextAlign.left)),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 14),
            Text(
              progress!,
              textAlign: TextAlign.center,
              style: NardType.caption.copyWith(color: c.textDim),
            ),
          ],
          const SizedBox(height: 14),
          NardButton(
            label: nextLabel,
            onPressed: onNext,
            size: NardButtonSize.m,
          ),
        ],
      ),
    );
  }

  Widget _name(BuildContext context, String text, TextAlign align) => Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    textAlign: align,
    style: NardType.bodyS.copyWith(color: context.nard.textDim),
  );
}
