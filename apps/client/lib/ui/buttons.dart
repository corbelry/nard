import 'package:flutter/material.dart';

import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import 'extra_tokens.dart';
import 'pressable.dart';

enum NardButtonVariant { primary, secondary, outline, ghost, danger }

/// Button heights: hero 64 (home "Oyna"), l 56, m 48, s 40.
enum NardButtonSize {
  hero(64),
  l(56),
  m(48),
  s(40);

  const NardButtonSize(this.height);
  final double height;
}

/// The design-system button. Primary is the theme's pill (sebeke: garnet
/// gradient with a brass inner ring and glow); other variants use the card
/// radius as in the screen mocks.
class NardButton extends StatefulWidget {
  const NardButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = NardButtonVariant.primary,
    this.size = NardButtonSize.l,
    this.height,
    this.sub,
    this.icon,
    this.expand = true,
    this.labelStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final NardButtonVariant variant;
  final NardButtonSize size;

  /// Overrides the size's height (game control bar: 62).
  final double? height;
  final String? sub;
  final IconData? icon;
  final bool expand;
  final TextStyle? labelStyle;

  @override
  State<NardButton> createState() => _NardButtonState();
}

class _NardButtonState extends State<NardButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final enabled = widget.onPressed != null;
    final v = widget.variant;
    final primary = v == NardButtonVariant.primary;
    final radius = primary ? c.buttonRadius : c.cardRadius;

    Gradient? gradient;
    Color? fill;
    Border? border;
    List<BoxShadow>? shadow;
    Color fg;
    switch (v) {
      case NardButtonVariant.primary:
        if (enabled) {
          gradient = c.primaryFill;
          border = Border.all(color: c.primaryRing);
          shadow = _down ? null : c.primaryGlow;
          fg = c.primaryText;
        } else {
          fill = c.surface;
          border = Border.all(color: c.line);
          fg = c.textFaint;
        }
      case NardButtonVariant.secondary:
        fill = _down ? c.accent.withValues(alpha: .16) : null;
        border = Border.all(
          color: enabled ? c.accent : c.accent.withValues(alpha: .2),
          width: enabled ? 1.5 : 1,
        );
        fg =
            !enabled
                ? c.text.withValues(alpha: .4)
                : _down
                ? c.accentHi
                : c.accent;
      case NardButtonVariant.outline:
        border = Border.all(color: c.line);
        fg = enabled ? c.text : c.text.withValues(alpha: .4);
      case NardButtonVariant.ghost:
        fill = _down ? c.text.withValues(alpha: .08) : null;
        fg = enabled ? c.text : c.text.withValues(alpha: .4);
      case NardButtonVariant.danger:
        fill =
            !enabled
                ? c.danger.withValues(alpha: .25)
                : _down
                ? c.dangerPressed
                : c.danger;
        fg = enabled ? c.onDanger : c.onDanger.withValues(alpha: .45);
    }

    final small = widget.size == NardButtonSize.s;
    final hero = widget.size == NardButtonSize.hero;
    final base =
        widget.labelStyle ??
        (hero
            ? NardType.displayL.copyWith(fontSize: 26, letterSpacing: 1.04)
            : (small ? NardType.labelM : NardType.labelL));
    final label = c.uppercaseLabels ? widget.label.toUpperCase() : widget.label;
    final labelStyle = base.copyWith(
      color: fg,
      fontFamily: c.buttonFont,
      letterSpacing: c.uppercaseLabels ? 1.2 : base.letterSpacing,
    );

    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: fg),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: labelStyle,
          ),
        ),
        if (widget.sub != null) ...[
          const SizedBox(width: 10),
          Text(
            widget.sub!,
            maxLines: 1,
            style: NardType.bodyS.copyWith(
              color: fg.withValues(alpha: fg.a * .75),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        child: AnimatedScale(
          scale: _down ? NardMotion.pressScale : 1,
          duration: NardMotion.press,
          curve: NardMotion.standard,
          child: Container(
            height: widget.height ?? widget.size.height,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: gradient,
              color: fill,
              border: border,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: shadow,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Square/circular icon button with a hairline ring, optionally with a
/// caption below (in-game controls, 66 × 60).
class NardIconButton extends StatelessWidget {
  const NardIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.caption,
    this.size = 44,
    this.width,
    this.height,
    this.circle = false,
    this.color,
    this.iconWidget,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final String? caption;
  final double size;
  final double? width;
  final double? height;
  final bool circle;
  final Color? color;

  /// Replaces [icon] (e.g. the drawn cube glyph).
  final Widget? iconWidget;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final fg = color ?? c.text;
    final glyph = iconWidget ?? Icon(icon, size: 20, color: fg);
    return Pressable(
      onTap: onPressed,
      semanticLabel: semanticLabel,
      child: AnimatedOpacity(
        opacity: onPressed == null ? .35 : 1,
        duration: NardMotion.fast,
        child: Container(
          width: width ?? size,
          height: height ?? size,
          decoration: BoxDecoration(
            border: Border.all(color: c.line),
            borderRadius: BorderRadius.circular(
              circle ? c.buttonRadius : NardRadius.m,
            ),
          ),
          child:
              caption == null
                  ? Center(child: glyph)
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      glyph,
                      const SizedBox(height: 4),
                      Text(
                        caption!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NardType.micro.copyWith(
                          color: c.textDim,
                          height: 12 / 11,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
