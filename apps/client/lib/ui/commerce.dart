import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../cosmetics/board_look.dart';
import '../cosmetics/catalog.dart';
import '../cosmetics/cosmetics_text.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import 'extra_tokens.dart';
import 'layout.dart';
import 'pressable.dart';

/// Coin disc or Yaqut gem (rotated square at ~0.7× the coin size).
class CurrencyIcon extends StatelessWidget {
  const CurrencyIcon(this.currency, {super.key, this.size = 16});

  final Currency currency;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    if (currency == Currency.coins) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: c.coinFill),
      );
    }
    final gem = size * .7;
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Transform.rotate(
          angle: pi / 4,
          child: Container(
            width: gem,
            height: gem,
            decoration: BoxDecoration(
              gradient: c.gemFill,
              borderRadius: BorderRadius.circular(size * .1),
            ),
          ),
        ),
      ),
    );
  }
}

/// Counts from the previous value to [value] over `NardMotion.counter`.
class CountUpText extends StatelessWidget {
  const CountUpText(this.value, {super.key, required this.style, this.format});

  final int value;
  final TextStyle style;
  final String Function(int)? format;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final f = format ?? formatAmount;
    if (reduce) return Text(f(value), style: style);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.toDouble()),
      duration: NardMotion.counter,
      curve: NardMotion.outExpo,
      builder: (_, v, _) => Text(f(v.round()), style: style),
    );
  }
}

/// Balance pill (`CurrencyPill.jsx`): h 32, ring `line`; [compact] is the
/// h 30 ringless store header variant.
class CurrencyPill extends StatelessWidget {
  const CurrencyPill({
    super.key,
    required this.currency,
    required this.amount,
    this.onTap,
    this.compact = false,
  });

  final Currency currency;
  final int amount;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final l = AppLocalizations.of(context);
    final pill = Container(
      height: compact ? 30 : 32,
      padding: EdgeInsets.fromLTRB(compact ? 6 : 6, 0, compact ? 10 : 12, 0),
      decoration: BoxDecoration(
        color: c.pillFill,
        borderRadius: BorderRadius.circular(NardRadius.pill),
        border: compact ? null : Border.all(color: c.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CurrencyIcon(currency, size: compact ? 16 : 18),
          SizedBox(width: compact ? 6 : 7),
          CountUpText(
            amount,
            style: NardType.labelM.copyWith(
              fontSize: compact ? 12 : 13,
              color: c.text,
              fontFeatures: tabular,
            ),
          ),
        ],
      ),
    );
    final label =
        currency == Currency.coins
            ? l.coinsSemantic(formatAmount(amount))
            : l.gemsSemantic(formatAmount(amount));
    if (onTap == null) {
      return Semantics(label: label, excludeSemantics: true, child: pill);
    }
    return Pressable(onTap: onTap, semanticLabel: label, child: pill);
  }
}

/// Currency glyph + amount, optionally with a struck-through old price.
class PriceTag extends StatelessWidget {
  const PriceTag({
    super.key,
    required this.currency,
    required this.amount,
    this.oldAmount,
    this.color,
    this.fontSize = 12,
    this.iconSize,
  });

  final Currency currency;
  final int amount;
  final int? oldAmount;
  final Color? color;
  final double fontSize;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? context.nard.accentHi;
    final style = NardType.caption.copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: fg,
      fontFeatures: tabular,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (oldAmount != null) ...[
          Opacity(
            opacity: .55,
            child: Text(
              formatAmount(oldAmount!),
              style: style.copyWith(
                fontSize: 12,
                decoration: TextDecoration.lineThrough,
                decorationColor: fg,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
        CurrencyIcon(currency, size: iconSize ?? fontSize + 2),
        const SizedBox(width: 4),
        Text(formatAmount(amount), style: style),
      ],
    );
  }
}

/// Board tile swatch: field colour with a zigzag of 12 point triangles.
class BoardSwatch extends StatelessWidget {
  const BoardSwatch({super.key, required this.look, this.radius = 9});

  final BoardLook look;
  final double radius;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: CustomPaint(
      painter: _SwatchPainter(look),
      child: const SizedBox.expand(),
    ),
  );
}

class _SwatchPainter extends CustomPainter {
  _SwatchPainter(this.look);

  final BoardLook look;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: look.field,
          stops: evenStops(look.field.length),
        ).createShader(rect),
    );
    const inset = 8.0;
    final h = min(34.0, size.height - inset);
    final w = (size.width - 2 * inset) / 12;
    for (var i = 0; i < 12; i++) {
      final x = inset + i * w;
      final path =
          Path()
            ..moveTo(x, size.height)
            ..lineTo(x + w / 2, size.height - h)
            ..lineTo(x + w, size.height)
            ..close();
      canvas.drawPath(
        path,
        Paint()..color = (i.isEven ? look.pointA : look.pointB).first,
      );
    }
  }

  @override
  bool shouldRepaint(_SwatchPainter old) => old.look != look;
}

/// Thumbnail of any item: board swatch, else a category glyph.
class ItemThumb extends StatelessWidget {
  const ItemThumb({super.key, required this.item, this.radius = 9});

  final CatalogItem item;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final look = item.look;
    if (look != null) return BoardSwatch(look: look, radius: radius);
    final c = context.nard;
    final color = rarityColor(item.rarity);
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Icon(categoryIcon(item.category), size: 24, color: c.text),
    );
  }
}

IconData categoryIcon(String category) => switch (category) {
  ItemCategory.board => LucideIcons.layoutGrid,
  ItemCategory.checkers => LucideIcons.circle,
  ItemCategory.dice => LucideIcons.dice5,
  ItemCategory.diceCup => LucideIcons.cupSoda,
  ItemCategory.cube => LucideIcons.box,
  ItemCategory.table => LucideIcons.image,
  ItemCategory.sounds => LucideIcons.music,
  ItemCategory.emotes => LucideIcons.smile,
  ItemCategory.avatarFrame => LucideIcons.userCircle,
  ItemCategory.title => LucideIcons.award,
  ItemCategory.winEffect => LucideIcons.sparkles,
  _ => LucideIcons.package,
};

/// Item tile (`RarityFrame.jsx`): thumb, name, status line; equipped ✓ /
/// locked badges; [previewing] = 2 px `accentHi` ring.
class RarityFrame extends StatelessWidget {
  const RarityFrame({
    super.key,
    required this.item,
    required this.name,
    required this.status,
    this.statusColor,
    this.equipped = false,
    this.previewing = false,
    this.locked = false,
    this.onTap,
    this.onLongPress,
    this.thumbHeight = 64,
    this.padding = 6,
  });

  final CatalogItem item;
  final String name;
  final Widget status;
  final Color? statusColor;
  final bool equipped;
  final bool previewing;
  final bool locked;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double thumbHeight;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final rarity = rarityColor(item.rarity);
    final ring =
        previewing
            ? Border.all(color: c.accentHi, width: 2)
            : Border.all(color: rarity);
    return GestureDetector(
      onLongPress: onLongPress,
      child: Pressable(
        onTap: onTap,
        semanticLabel: name,
        minSize: 0,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: c.text.withValues(alpha: .04),
                borderRadius: BorderRadius.circular(14),
                border: ring,
                boxShadow:
                    item.rarity == 'legendary'
                        ? [
                          BoxShadow(
                            color: rarity.withValues(alpha: .35),
                            blurRadius: 18,
                          ),
                        ]
                        : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: thumbHeight,
                    width: double.infinity,
                    child: Opacity(
                      opacity: locked ? .55 : 1,
                      child: ItemThumb(item: item),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NardType.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: c.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  DefaultTextStyle(
                    style: NardType.micro.copyWith(
                      color:
                          statusColor ??
                          (locked ? c.text.withValues(alpha: .6) : rarity),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: status,
                  ),
                ],
              ),
            ),
            if (equipped)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: c.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.check, size: 12, color: c.onAccent),
                ),
              )
            else if (locked)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0x99000000),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(LucideIcons.lock, size: 12, color: c.text),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Locker category chip: radius 10, ivory when selected.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
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
      semanticLabel: label,
      minSize: 0,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? NardPalette.ivory100 : null,
          borderRadius: BorderRadius.circular(10),
          border:
              selected
                  ? null
                  : Border.all(color: c.accent.withValues(alpha: .2)),
        ),
        child: Text(
          label,
          style: NardType.bodyS.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color:
                selected
                    ? NardPalette.walnut900
                    : c.text.withValues(alpha: .75),
          ),
        ),
      ),
    );
  }
}

/// Loadout chip: ivory pill when active, hairline otherwise.
class LoadoutChip extends StatelessWidget {
  const LoadoutChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
    this.onLongPress,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return GestureDetector(
      onLongPress: onLongPress,
      child: Pressable(
        onTap: onTap,
        semanticLabel: label,
        child: Center(
          child: Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? NardPalette.ivory100 : null,
              borderRadius: BorderRadius.circular(NardRadius.pill),
              border: active ? null : Border.all(color: c.line),
            ),
            child: Text(
              label,
              maxLines: 1,
              style: NardType.caption.copyWith(
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? NardPalette.walnut900 : c.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 12.1 Daily/Weekly switch: brass selected pill.
class PillSegmented<T> extends StatelessWidget {
  const PillSegmented({
    super.key,
    required this.values,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  final List<T> values;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.pillFill,
        borderRadius: BorderRadius.circular(NardRadius.pill),
      ),
      child: Row(
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Semantics(
                selected: values[i] == selected,
                button: true,
                label: labels[i],
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(values[i]),
                  child: AnimatedContainer(
                    duration: NardMotion.fast,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: values[i] == selected ? c.accent : null,
                      borderRadius: BorderRadius.circular(NardRadius.pill),
                    ),
                    child: Text(
                      labels[i],
                      style: NardType.labelM.copyWith(
                        fontSize: 14,
                        color:
                            values[i] == selected
                                ? c.onAccent
                                : c.text.withValues(alpha: .7),
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

/// Label / value row with a bottom hairline (3.2 obtain, 7.4, 7.5).
class KeyValueRow extends StatelessWidget {
  const KeyValueRow({
    super.key,
    required this.label,
    required this.value,
    this.padding = 12,
  });

  final String label;
  final Widget value;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Container(
      padding: EdgeInsets.symmetric(vertical: padding),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: c.accent.withValues(alpha: .1)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: NardType.body.copyWith(fontSize: 14, color: c.textDim),
            ),
          ),
          const SizedBox(width: 12),
          DefaultTextStyle(
            style: NardType.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: c.text,
              fontFeatures: tabular,
            ),
            child: value,
          ),
        ],
      ),
    );
  }
}

/// Rotated garnet diamond with the level number (12.3).
class LevelBadge extends StatelessWidget {
  const LevelBadge({super.key, required this.level, this.size = 104});

  final int level;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final box = size * 150 / 104;
    return SizedBox(
      width: box,
      height: box,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: pi / 4,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: c.levelBadgeFill,
                border: Border.all(color: c.accent, width: 5),
                boxShadow: [
                  BoxShadow(
                    color: c.accent.withValues(alpha: .45),
                    blurRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Text(
            '$level',
            style: NardType.displayXl.copyWith(
              fontSize: size * 44 / 104,
              height: 1,
              color: c.primaryText,
              fontFeatures: tabular,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small XP badge (2.6 rewards).
class XpBadge extends StatelessWidget {
  const XpBadge({super.key, this.size = 26});

  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.accent,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        AppLocalizations.of(context).xpBadge,
        style: NardType.micro.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: c.onAccent,
        ),
      ),
    );
  }
}

/// 2.6 reward tile: glyph · value · label (horizontal).
class RewardTile extends StatelessWidget {
  const RewardTile({
    super.key,
    required this.glyph,
    required this.value,
    required this.label,
  });

  final Widget glyph;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.tile,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.tileRing),
      ),
      child: Row(
        children: [
          glyph,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CountUpText(
                  value,
                  format: (v) => l.missionReward(v),
                  style: NardType.labelM.copyWith(
                    fontSize: 16,
                    color: c.text,
                    fontFeatures: tabular,
                  ),
                ),
                Text(
                  label,
                  style: NardType.micro.copyWith(
                    fontWeight: FontWeight.w400,
                    color: c.text.withValues(alpha: .6),
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

/// Hexagon clip (achievement tiles), same shape as `RankBadge`.
class HexClipper extends CustomClipper<Path> {
  const HexClipper();

  @override
  Path getClip(Size s) =>
      Path()
        ..moveTo(s.width / 2, 0)
        ..lineTo(s.width, s.height * .25)
        ..lineTo(s.width, s.height * .75)
        ..lineTo(s.width / 2, s.height)
        ..lineTo(0, s.height * .75)
        ..lineTo(0, s.height * .25)
        ..close();

  @override
  bool shouldReclip(HexClipper oldClipper) => false;
}

/// The 3.2 near-full-height sheet: radius 28 top, rarity gradient fill
/// and ring (store.md §2.2; `showNardSheet` is the short inset sheet).
Future<T?> showTallSheet<T>(
  BuildContext context, {
  required Color rarity,
  required WidgetBuilder builder,
}) {
  final c = context.nard;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: c.scrim,
    transitionDuration: NardMotion.sheetIn,
    pageBuilder: (ctx, _, _) {
      final media = MediaQuery.of(ctx);
      return Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            margin: EdgeInsets.only(top: media.padding.top + 34),
            padding: EdgeInsets.fromLTRB(
              18,
              12,
              18,
              max(media.padding.bottom, 16) + 18,
            ),
            decoration: BoxDecoration(
              gradient: c.itemSheetFill(rarity),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border.all(color: rarity.withValues(alpha: .5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                const SizedBox(height: 12),
                Flexible(child: builder(ctx)),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: NardMotion.standard,
        reverseCurve: NardMotion.standard.flipped,
      );
      return SlideTransition(
        position: Tween(
          begin: const Offset(0, .3),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );
}
