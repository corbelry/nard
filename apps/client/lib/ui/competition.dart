import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../cosmetics/catalog.dart' show Currency;
import '../online/rank.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import 'buttons.dart';
import 'commerce.dart';
import 'extra_tokens.dart';
import 'identity.dart';
import 'layout.dart';
import 'pressable.dart';

/// Shared Phase 6 widgets (tournaments.md §0.1).

/// Overline with an optional 6 Ø dot: live `dangerText`, registration
/// `accentHi`, finished / cancelled dimmed.
class TournamentStatusLabel extends StatelessWidget {
  const TournamentStatusLabel({
    super.key,
    required this.text,
    required this.color,
    this.dot = false,
    this.fontSize = 11,
  });

  final String text;
  final Color color;
  final bool dot;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (dot) ...[
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
      ],
      Flexible(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: NardType.micro.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: .66,
            color: color,
          ),
        ),
      ),
    ],
  );
}

/// Equal-width solid choice chips (21.1 pill h 36; 22.1 radius 12 h 40).
class EqualChips<T> extends StatelessWidget {
  const EqualChips({
    super.key,
    required this.values,
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.height = 36,
    this.radius = NardRadius.pill,
    this.fontSize = 13,
  });

  final List<T> values;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onChanged;
  final double height;
  final double radius;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Row(
      children: [
        for (var i = 0; i < values.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Semantics(
              selected: values[i] == selected,
              child: Pressable(
                onTap: () => onChanged(values[i]),
                semanticLabel: labels[i],
                minSize: height,
                child: AnimatedContainer(
                  duration: NardMotion.fast,
                  height: height,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: values[i] == selected ? c.accent : c.pillFill,
                    borderRadius: BorderRadius.circular(radius),
                    border:
                        values[i] == selected
                            ? null
                            : Border.all(color: c.accent.withValues(alpha: .2)),
                  ),
                  child: Text(
                    labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NardType.bodyS.copyWith(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color:
                          values[i] == selected
                              ? c.onAccent
                              : c.text.withValues(alpha: .75),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Static tag chip (13.1): h 26, pill.
class TagChip extends StatelessWidget {
  const TagChip(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.pillFill,
        borderRadius: BorderRadius.circular(NardRadius.pill),
        border: Border.all(color: c.accent.withValues(alpha: .2)),
      ),
      child: Text(
        label,
        style: NardType.caption.copyWith(
          fontWeight: FontWeight.w400,
          color: c.text.withValues(alpha: .75),
        ),
      ),
    );
  }
}

/// 135° placeholder stripes (poster / trophy / thumb asset slots).
class StripesPainter extends CustomPainter {
  const StripesPainter({required this.color, this.width = 6, this.gap = 12});

  final Color color;
  final double width;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = width;
    canvas.clipRect(Offset.zero & size);
    for (var x = -size.height; x < size.width + size.height; x += gap) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(StripesPainter old) => old.color != color;
}

/// Poster / trophy slot: walnut fallback gradient under stripes.
class PosterFallback extends StatelessWidget {
  const PosterFallback({super.key, this.icon = LucideIcons.trophy});

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return DecoratedBox(
      decoration: BoxDecoration(gradient: c.posterFallback),
      child: CustomPaint(
        painter: StripesPainter(color: c.stripes),
        child:
            icon == null
                ? const SizedBox.expand()
                : Center(
                  child: Icon(
                    icon,
                    size: 28,
                    color: c.accent.withValues(alpha: .55),
                  ),
                ),
      ),
    );
  }
}

/// 21.2 no-show ring: remaining fraction in `accent`, rest `text@.1`.
class CountdownRing extends StatelessWidget {
  const CountdownRing({
    super.key,
    required this.fraction,
    required this.label,
    this.size = 120,
  });

  final double fraction;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          fraction: fraction.clamp(0, 1).toDouble(),
          fill: c.accent,
          track: c.text.withValues(alpha: .1),
        ),
        child: Center(
          child: Container(
            width: size - 16,
            height: size - 16,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c.bg),
            child: Text(
              label,
              style: NardType.clock.copyWith(fontSize: 30, color: c.text),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.fraction,
    required this.fill,
    required this.track,
  });

  final double fraction;
  final Color fill;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas
      ..drawOval(rect, Paint()..color = track)
      ..drawArc(rect, -pi / 2, 2 * pi * fraction, true, Paint()..color = fill);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.fraction != fraction;
}

/// 4.2 prize grid: 3 columns of place → amount tiles; the first tile is
/// brass-tinted.
class PrizeTiles extends StatelessWidget {
  const PrizeTiles({super.key, required this.tiles});

  /// (place label, amount text).
  final List<(String, String)> tiles;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return LayoutBuilder(
      builder: (context, box) {
        final w = (box.maxWidth - 16) / 3;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < tiles.length; i++)
              Container(
                width: w,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: i == 0 ? c.accent.withValues(alpha: .12) : c.tile,
                  borderRadius: BorderRadius.circular(NardRadius.m),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tiles[i].$1,
                      style: NardType.micro.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            i == 0 ? c.accentHi : c.text.withValues(alpha: .6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const CurrencyIcon(Currency.coins, size: 12),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            tiles[i].$2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: NardType.labelM.copyWith(
                              color: c.text,
                              fontFeatures: tabular,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Bottom bar pinned under a ranked list (6.5, 4.4): my rank, name and
/// value, always visible.
class PinnedMeRow extends StatelessWidget {
  const PinnedMeRow({
    super.key,
    required this.rank,
    required this.name,
    required this.value,
    this.leading,
  });

  final String rank;
  final String name;
  final String value;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final style = NardType.body.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: c.text,
      fontFeatures: tabular,
    );
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, max(14, bottom + 2)),
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        border: Border(top: BorderSide(color: c.accent.withValues(alpha: .3))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              rank,
              style: NardType.bodyS.copyWith(
                fontWeight: FontWeight.w600,
                color: c.accentHi,
                fontFeatures: tabular,
              ),
            ),
          ),
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
          Text(value, style: style),
        ],
      ),
    );
  }
}

/// One place on [PlayerPodium].
class PodiumEntry {
  const PodiumEntry({
    required this.place,
    required this.name,
    required this.value,
    this.me = false,
    this.onTap,
  });

  final int place;
  final String name;
  final String value;
  final bool me;
  final VoidCallback? onTap;
}

/// 6.5 podium: avatars with brass / silver / bronze rings, order 2 · 1 · 3,
/// no pedestals (5.7 keeps its pedestal variant).
class PlayerPodium extends StatelessWidget {
  const PlayerPodium({super.key, required this.entries});

  final List<PodiumEntry> entries;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final byPlace = {for (final e in entries) e.place: e};
    final order =
        [byPlace[2], byPlace[1], byPlace[3]].whereType<PodiumEntry>().toList();
    Widget column(PodiumEntry e) {
      final first = e.place == 1;
      final size = first ? 78.0 : 62.0;
      final Gradient ring =
          first
              ? c.brassRing
              : () {
                final (light, dark) = c.tierStops(
                  e.place == 2 ? Tier.silver : Tier.bronze,
                );
                return LinearGradient(
                  begin: const Alignment(-.34, -.94),
                  end: const Alignment(.34, .94),
                  colors: [light, dark],
                );
              }();
      return SizedBox(
        width: 104,
        child: Pressable(
          onTap: e.onTap,
          semanticLabel: e.name,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: size,
                height: size,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: ring,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: const Alignment(-.5, -.87),
                      end: const Alignment(.5, .87),
                      colors: e.me ? c.avatarMe : c.avatarOpponent,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    e.name.trim().isEmpty
                        ? '?'
                        : e.name.trim().characters.first.toUpperCase(),
                    style: NardType.title.copyWith(fontSize: 18, color: c.text),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                e.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: NardType.bodyS.copyWith(
                  fontWeight: FontWeight.w600,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                e.value,
                style: NardType.caption.copyWith(
                  fontWeight: FontWeight.w400,
                  color: c.text.withValues(alpha: .64),
                  fontFeatures: tabular,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${e.place}',
                style: NardType.title.copyWith(
                  fontSize: 18,
                  color: c.podiumDigit(e.place),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < order.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Flexible(child: column(order[i])),
          ],
        ],
      ),
    );
  }
}

/// Full-screen celebration skeleton (4.5, 21.3, 21.4, 7.2): background,
/// centred column and a bottom button zone.
class CelebrationLayout extends StatelessWidget {
  const CelebrationLayout({
    super.key,
    required this.background,
    required this.content,
    required this.footer,
    this.gap = 14,
    this.padding = 32,
  });

  final Gradient background;
  final List<Widget> content;
  final List<Widget> footer;
  final double gap;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: background),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < content.length; i++) ...[
                          if (i > 0) SizedBox(height: gap),
                          content[i],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, max(24, bottom + 8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < footer.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      footer[i],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 96 Ø success disc with a check (21.3, 14.4).
class SuccessDisc extends StatelessWidget {
  const SuccessDisc({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.success.withValues(alpha: .16),
        border: Border.all(color: c.successText.withValues(alpha: .4)),
      ),
      child: Icon(LucideIcons.check, size: size * .42, color: c.successText),
    );
  }
}

/// 96 Ø well with a brass diamond (21.4; = `MessageState` icon).
class DiamondWell extends StatelessWidget {
  const DiamondWell({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Container(
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
            border: Border.all(color: c.accent, width: 3),
          ),
        ),
      ),
    );
  }
}

/// Reward / refund pill (4.5, 21.4): h 34–36, pill, optional coin.
class RewardPill extends StatelessWidget {
  const RewardPill({
    super.key,
    required this.label,
    required this.fill,
    required this.color,
    this.border,
    this.coin = false,
  });

  final String label;
  final Color fill;
  final Color color;
  final Color? border;
  final bool coin;

  @override
  Widget build(BuildContext context) => Container(
    height: 36,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(NardRadius.pill),
      border: border == null ? null : Border.all(color: border!),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (coin) ...[
          const CurrencyIcon(Currency.coins, size: 16),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: NardType.bodyS.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
              fontFeatures: tabular,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Key / value row inside a `GroupCard` (21.1 info card; the card draws
/// the dividers).
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final row = Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: NardType.body.copyWith(
                fontSize: 14,
                color: c.text.withValues(alpha: .65),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: NardType.body.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: c.text,
                fontFeatures: tabular,
              ),
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 6),
            Icon(
              LucideIcons.chevronRight,
              size: 14,
              color: c.text.withValues(alpha: .5),
            ),
          ],
        ],
      ),
    );
    return onTap == null ? row : Pressable(onTap: onTap, child: row);
  }
}

/// A list skeleton card (11.4 loading).
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.height = 118});

  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: c.tile,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.accent.withValues(alpha: .1)),
      ),
    );
  }
}

/// Small avatar used in rows (22.2 entrants).
class RowAvatar extends StatelessWidget {
  const RowAvatar({super.key, required this.name, this.me = false});

  final String name;
  final bool me;

  @override
  Widget build(BuildContext context) => Avatar(
    name: name,
    size: 32,
    tone: me ? AvatarTone.me : AvatarTone.opponent,
  );
}

/// Confirm sheet (unregister, cancel): title, body, action + cancel.
Future<bool> confirmSheet(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
  required String cancel,
  bool danger = false,
}) async =>
    await showNardSheet<bool>(
      context,
      builder:
          (ctx) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetTitle(title),
              const SizedBox(height: 8),
              Text(
                body,
                style: NardType.body.copyWith(
                  fontSize: 14,
                  color: ctx.nard.text.withValues(alpha: .8),
                ),
              ),
              const SizedBox(height: 18),
              NardButton(
                label: action,
                variant:
                    danger
                        ? NardButtonVariant.danger
                        : NardButtonVariant.primary,
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
              const SizedBox(height: 10),
              NardButton(
                label: cancel,
                variant: NardButtonVariant.outline,
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
            ],
          ),
    ) ??
    false;
