import 'package:flutter/material.dart';

import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import 'extra_tokens.dart';
import 'pressable.dart';

/// Pill switch: default 48 × 28 (thumb 22), compact 44 × 26 (thumb 20).
class NardSwitch extends StatelessWidget {
  const NardSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.compact = false,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool compact;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final w = compact ? 44.0 : 48.0;
    final h = compact ? 26.0 : 28.0;
    final t = compact ? 20.0 : 22.0;
    return Semantics(
      toggled: value,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: SizedBox(
          height: NardSpace.hitMin,
          child: Center(
            child: AnimatedContainer(
              duration: NardMotion.fast,
              curve: NardMotion.standard,
              width: w,
              height: h,
              decoration: BoxDecoration(
                color: value ? c.accent : c.text.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(h / 2),
              ),
              child: AnimatedAlign(
                duration: NardMotion.fast,
                curve: NardMotion.standard,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    width: t,
                    height: t,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: value ? c.bg : NardPalette.ivory100,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 22 pt radio indicator.
class RadioDot extends StatelessWidget {
  const RadioDot({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? c.accent : c.text.withValues(alpha: .3),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child:
          selected
              ? Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.accent,
                ),
              )
              : null,
    );
  }
}

/// Segmented control. [pill] is the 18.1 variant (accent selection).
class NardSegmented<T> extends StatelessWidget {
  const NardSegmented({
    super.key,
    required this.values,
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.pill = false,
  });

  final List<T> values;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final outer = pill ? 999.0 : 14.0;
    final inner = pill ? 999.0 : 10.0;
    return Container(
      padding: EdgeInsets.all(pill ? 3 : 4),
      decoration: BoxDecoration(
        color: pill ? c.text.withValues(alpha: .06) : c.surfaceSunken,
        borderRadius: BorderRadius.circular(outer),
        border: pill ? null : Border.all(color: c.lineSoft),
      ),
      child: Row(
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Semantics(
                selected: values[i] == selected,
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(values[i]),
                  child: AnimatedContainer(
                    duration: NardMotion.fast,
                    curve: NardMotion.standard,
                    height: pill ? 36 : 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          values[i] == selected
                              ? (pill ? c.accent : NardPalette.ivory100)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(inner),
                    ),
                    child: Text(
                      labels[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NardType.labelM.copyWith(
                        fontSize: pill ? 14 : 15,
                        color:
                            values[i] == selected
                                ? (pill ? c.onAccent : NardPalette.walnut900)
                                : c.text.withValues(alpha: .75),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small selectable tile (2.2 match format).
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: NardMotion.fast,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? c.accent.withValues(alpha: .18) : null,
          borderRadius: BorderRadius.circular(NardRadius.m),
          border: Border.all(
            color: selected ? c.accent : c.line,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          style: NardType.labelM.copyWith(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? c.accentHi : c.text,
          ),
        ),
      ),
    );
  }
}

/// Card that can be selected (language rows, variant cards, AI levels).
class SelectableCard extends StatelessWidget {
  const SelectableCard({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    this.radius = NardRadius.l,
    this.padding = const EdgeInsets.all(14),
    this.enabled = true,
  });

  final bool selected;
  final VoidCallback? onTap;
  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Opacity(
      opacity: enabled ? 1 : .55,
      child: Semantics(
        selected: selected,
        child: Pressable(
          onTap: enabled ? onTap : null,
          child: AnimatedContainer(
            duration: NardMotion.fast,
            curve: NardMotion.standard,
            padding: padding,
            decoration: BoxDecoration(
              color: selected ? c.selectedFill : c.tile,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: selected ? c.accent : c.tileRing,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Thin progress bar.
class NardProgressBar extends StatelessWidget {
  const NardProgressBar({
    super.key,
    required this.value,
    this.height = 4,
    this.track,
    this.fill,
  });

  final double value;
  final double height;
  final Color? track;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(color: track ?? c.text.withValues(alpha: .12)),
            ),
            FractionallySizedBox(
              widthFactor: value.clamp(0, 1),
              child: ColoredBox(color: fill ?? c.accent),
            ),
          ],
        ),
      ),
    );
  }
}
