import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import 'extra_tokens.dart';
import 'pressable.dart';

const tabular = [FontFeature.tabularFigures()];

/// Small uppercase section label (strings are stored uppercased in ARB).
class Overline extends StatelessWidget {
  const Overline(this.text, {super.key, this.color, this.spacing = 0.72});

  final String text;
  final Color? color;
  final double spacing;

  @override
  Widget build(BuildContext context) => Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: NardType.caption.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: spacing,
      color: color ?? context.nard.textDim,
    ),
  );
}

/// Header of pushed screens: back button + title. [bare] is the 48-high
/// variant of 10.3 / 15.x / 17.x (chevron without box, title 20).
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
    this.bare = false,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool bare;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final back = onBack ?? () => Navigator.of(context).maybePop();
    if (bare) {
      return SizedBox(
        height: 48,
        child: Padding(
          padding: const EdgeInsets.only(left: 4, right: 16),
          child: Row(
            children: [
              Pressable(
                onTap: back,
                semanticLabel:
                    MaterialLocalizations.of(context).backButtonTooltip,
                child: Center(
                  child: Icon(LucideIcons.chevronLeft, size: 20, color: c.text),
                ),
              ),
              if (title.isNotEmpty)
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NardType.title.copyWith(fontSize: 20, color: c.text),
                  ),
                )
              else
                const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      );
    }
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Pressable(
              onTap: back,
              semanticLabel:
                  MaterialLocalizations.of(context).backButtonTooltip,
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: c.line),
                    borderRadius: BorderRadius.circular(NardRadius.m),
                  ),
                  child: Icon(LucideIcons.chevronLeft, size: 18, color: c.text),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: NardType.title.copyWith(fontSize: 22, color: c.text),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// Title of tab-root screens.
class RootTitle extends StatelessWidget {
  const RootTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
    child: Text(
      text,
      style: NardType.displayL.copyWith(fontSize: 26, color: context.nard.text),
    ),
  );
}

/// Diamond-and-hairline ornament divider.
class OrnamentDivider extends StatelessWidget {
  const OrnamentDivider({super.key, this.line = 40, this.opacity = 1});

  final double line;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final a = context.nard.accent;
    Widget diamond(double s, {required bool filled}) => Transform.rotate(
      angle: pi / 4,
      child: Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          color: filled ? a : null,
          border: filled ? null : Border.all(color: a),
        ),
      ),
    );
    final hair = Container(
      width: line,
      height: 1,
      color: a.withValues(alpha: opacity),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        hair,
        const SizedBox(width: 8),
        diamond(6, filled: false),
        const SizedBox(width: 8),
        diamond(8, filled: true),
        const SizedBox(width: 8),
        diamond(6, filled: false),
        const SizedBox(width: 8),
        hair,
      ],
    );
  }
}

enum BannerTone { brass, dim, danger, ok }

/// One-line turn status with the sebeke ornament on both sides.
class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.title,
    this.sub,
    this.tone = BannerTone.brass,
    this.ornament = true,
  });

  final String title;
  final String? sub;
  final BannerTone tone;
  final bool ornament;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final (dot, titleColor) = switch (tone) {
      BannerTone.brass => (c.accent, c.accent),
      BannerTone.dim => (c.dimDot, c.text),
      BannerTone.danger => (c.dangerText, c.dangerText),
      BannerTone.ok => (c.successText, c.successText),
    };
    Widget side({required bool left}) {
      final parts = [
        Container(width: 28, height: 1, color: c.line),
        const SizedBox(width: 5),
        Transform.rotate(
          angle: pi / 4,
          child: Container(
            width: 5,
            height: 5,
            color: c.accent.withValues(alpha: .7),
          ),
        ),
      ];
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: left ? parts : parts.reversed.toList(),
      );
    }

    final style = NardType.bodyS.copyWith(height: 16 / 13);
    return Semantics(
      liveRegion: true,
      child: SizedBox(
        height: 26,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (ornament && c.latticeBand) ...[
              side(left: true),
              const SizedBox(width: 10),
            ],
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dot,
                boxShadow: [BoxShadow(color: dot, blurRadius: 8)],
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: title,
                      style: style.copyWith(
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                        letterSpacing: .13,
                      ),
                    ),
                    if (sub != null)
                      TextSpan(
                        text: '  $sub',
                        style: style.copyWith(
                          color: c.textDim,
                          fontFeatures: tabular,
                        ),
                      ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (ornament && c.latticeBand) ...[
              const SizedBox(width: 10),
              side(left: false),
            ],
          ],
        ),
      ),
    );
  }
}

/// Opens the design's bottom sheet: inset 8 pt, radius 24 top / 42
/// bottom, drag handle, 60 % scrim. Landscape: centered, 380 wide.
Future<T?> showNardSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool dismissible = true,
  bool handle = true,
}) {
  final c = context.nard;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: c.scrim,
    transitionDuration: NardMotion.sheetIn,
    pageBuilder: (ctx, _, _) {
      final media = MediaQuery.of(ctx);
      final landscape = media.size.width > media.size.height;
      final sheet = Material(
        type: MaterialType.transparency,
        child: Container(
          width: landscape ? 380 : double.infinity,
          padding: EdgeInsets.fromLTRB(20, handle ? 12 : 20, 20, 24),
          decoration: BoxDecoration(
            color: c.surfaceRaised,
            borderRadius:
                landscape
                    ? BorderRadius.circular(22)
                    : const BorderRadius.vertical(
                      top: Radius.circular(NardRadius.xl),
                      bottom: Radius.circular(42),
                    ),
            border: Border.all(color: c.line),
            boxShadow: c.elevation2,
          ),
          child: SafeArea(
            top: false,
            left: false,
            right: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (handle) ...[
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: c.text.withValues(alpha: .25),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Flexible(child: builder(ctx)),
              ],
            ),
          ),
        ),
      );
      return Align(
        alignment: landscape ? Alignment.center : Alignment.bottomCenter,
        child: Padding(padding: const EdgeInsets.all(8), child: sheet),
      );
    },
    transitionBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: NardMotion.standard,
        reverseCurve: NardMotion.standard.flipped,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, .25),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Sheet title (Noto Serif 22).
class SheetTitle extends StatelessWidget {
  const SheetTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: NardType.title.copyWith(
      fontSize: 22,
      height: 28 / 22,
      color: context.nard.text,
    ),
  );
}

/// One item of the bottom tab bar.
class NardTab {
  const NardTab(this.icon, this.label);

  final IconData icon;
  final String label;
}

/// Bottom tab bar (tab roots only).
class NardTabBar extends StatelessWidget {
  const NardTabBar({
    super.key,
    required this.tabs,
    required this.index,
    required this.onTap,
  });

  final List<NardTab> tabs;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(8, 8, 8, max(8, bottom - 8)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.bgDeep.withValues(alpha: 0), c.bgDeep],
          stops: const [0, .3],
        ),
        border: Border(top: BorderSide(color: c.lineSoft)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: Semantics(
                selected: i == index,
                button: true,
                label: tabs[i].label,
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: SizedBox(
                    height: 52,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tabs[i].icon,
                          size: 22,
                          color: i == index ? c.accentHi : c.textDim,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tabs[i].label,
                          style: NardType.micro.copyWith(
                            height: 12 / 11,
                            color: i == index ? c.accentHi : c.textDim,
                            fontWeight:
                                i == index ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
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

/// Centered message state (empty / error), §11.x.
class MessageState extends StatelessWidget {
  const MessageState({
    super.key,
    required this.title,
    required this.body,
    this.action,
    this.onAction,
    this.danger = false,
  });

  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.accent.withValues(alpha: .3)),
            ),
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: pi / 4,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: danger ? c.dangerText : c.accent,
                    width: 3,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: NardType.title.copyWith(fontSize: 21, color: c.text),
          ),
          const SizedBox(height: 14),
          Text(
            body,
            textAlign: TextAlign.center,
            style: NardType.body.copyWith(
              fontSize: 14,
              color: c.text.withValues(alpha: .7),
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 20),
            Pressable(
              onTap: onAction,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(c.cardRadius),
                  border: Border.all(color: c.accent, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  action!,
                  style: NardType.labelM.copyWith(
                    fontSize: 14,
                    color: c.accentHi,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 11.1 offline banner: garnet-tinted strip with a dot, shown on tab roots
/// and online screens while the server is unreachable. Slides away when
/// [visible] turns false.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.text, required this.visible});

  final String text;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return AnimatedSize(
      duration: NardMotion.sheetIn,
      curve: NardMotion.standard,
      alignment: Alignment.topCenter,
      child:
          !visible
              ? const SizedBox(width: double.infinity)
              : Semantics(
                liveRegion: true,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: c.dangerText.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(NardRadius.m),
                    border: Border.all(
                      color: c.dangerText.withValues(alpha: .4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.dangerText,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NardType.bodyS.copyWith(color: c.errorTitle),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
