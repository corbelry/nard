import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../clans/clan_models.dart';
import '../clans/emblem_catalog.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import 'extra_tokens.dart';
import 'layout.dart';
import 'pressable.dart';

/// A clan emblem drawn from data (social.md §0.1): clip shape filled with
/// the colour's 160° gradient, optional lattice pattern, inner outline at
/// ≥ 96 px, and a symbol or the clan's initials in the centre.
class ClanEmblem extends StatelessWidget {
  const ClanEmblem({
    super.key,
    required this.emblem,
    required this.width,
    this.initials,
    this.flat = false,
    this.symbol = true,
    this.semanticLabel,
  });

  final Emblem emblem;
  final double width;

  /// Shown when the symbol is `initials` (or forced by list rows, 5.1).
  final String? initials;

  /// Small list emblems use the flat swatch colour (5.7 rows).
  final bool flat;

  /// Draw the centre symbol / initials.
  final bool symbol;
  final String? semanticLabel;

  double get height => width / EmblemCatalog.aspect(emblem.shape);

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Semantics(
      label: semanticLabel,
      image: semanticLabel != null,
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: EmblemPainter(
            emblem: emblem,
            initials: initials,
            flat: flat,
            symbol: symbol,
            accentHi: c.accentHi,
            text: c.text,
            dark: NardPalette.walnut900,
          ),
        ),
      ),
    );
  }
}

/// Paints [ClanEmblem]; public for the painter smoke test.
class EmblemPainter extends CustomPainter {
  const EmblemPainter({
    required this.emblem,
    required this.accentHi,
    required this.text,
    required this.dark,
    this.initials,
    this.flat = false,
    this.symbol = true,
    this.shape = true,
  });

  final Emblem emblem;
  final String? initials;
  final bool flat;
  final bool symbol;

  /// Fill the shape (off for symbol-only tiles, 19.1).
  final bool shape;
  final Color accentHi;
  final Color text;
  final Color dark;

  @override
  void paint(Canvas canvas, Size size) {
    final (swatch, light, deep) = EmblemCatalog.colorOf(emblem.color);
    final outline = EmblemCatalog.path(emblem.shape, size);
    final rect = Offset.zero & size;
    if (!shape) {
      _symbol(canvas, size, onLight: false);
      return;
    }
    // 160°: from the top-left-ish corner down to the bottom-right.
    final fill =
        Paint()
          ..shader =
              flat
                  ? null
                  : LinearGradient(
                    begin: const Alignment(-.34, -.94),
                    end: const Alignment(.34, .94),
                    colors: [light, deep],
                  ).createShader(rect)
          ..color = swatch;
    canvas.drawPath(outline, fill);

    if (emblem.pattern == 'lattice') {
      canvas.save();
      canvas.clipPath(outline);
      final step = 14 * size.width / 170;
      final line =
          Paint()
            ..color = accentHi.withValues(alpha: .22)
            ..strokeWidth = max(1, 2 * size.width / 170)
            ..style = PaintingStyle.stroke;
      final reach = size.height / tan(pi / 3);
      for (var x = -reach; x < size.width + reach; x += step) {
        canvas.drawLine(Offset(x, 0), Offset(x + reach, size.height), line);
        canvas.drawLine(Offset(x + reach, 0), Offset(x, size.height), line);
      }
      canvas.restore();
    }

    if (size.width >= 96) {
      final inset = size.width * .06;
      final inner = EmblemCatalog.path(
        emblem.shape,
        Size(size.width - 2 * inset, size.height - 2 * inset),
      ).shift(Offset(inset, inset));
      canvas.drawPath(
        inner,
        Paint()
          ..color = accentHi
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width >= 150 ? 3 : 2,
      );
    }

    if (!symbol) return;
    _symbol(
      canvas,
      size,
      onLight: EmblemCatalog.lightColors.contains(emblem.color),
    );
  }

  void _symbol(Canvas canvas, Size size, {required bool onLight}) {
    final ink = onLight ? dark : accentHi;
    final center = Offset(size.width / 2, size.height / 2);
    final s = size.width * .32;
    final stroke =
        Paint()
          ..color = ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(1.5, s / 10);
    final useInitials = initials != null || emblem.symbol == 'initials';
    if (useInitials) {
      final tp = TextPainter(
        text: TextSpan(
          text: (initials ?? '').characters.take(3).toString(),
          style: TextStyle(
            fontFamily: NardFonts.display,
            fontWeight: FontWeight.w600,
            fontSize: size.width * .28,
            height: 1,
            color: onLight ? dark : text,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
      return;
    }
    switch (emblem.symbol) {
      case 'circle':
        canvas.drawCircle(center, s / 2 - stroke.strokeWidth / 2, stroke);
      case 'square':
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: s * .8, height: s * .8),
            const Radius.circular(2),
          ),
          stroke,
        );
      case 'diamond_dot':
        _diamond(canvas, center, s, stroke);
        canvas.drawRect(
          Rect.fromCenter(center: center, width: s * .25, height: s * .25),
          Paint()..color = ink,
        );
      default:
        _diamond(canvas, center, s, stroke);
    }
  }

  void _diamond(Canvas canvas, Offset c, double s, Paint p) {
    final h = s / 2;
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy - h)
        ..lineTo(c.dx + h, c.dy)
        ..lineTo(c.dx, c.dy + h)
        ..lineTo(c.dx - h, c.dy)
        ..close(),
      p,
    );
  }

  @override
  bool shouldRepaint(EmblemPainter old) =>
      old.emblem != emblem ||
      old.initials != initials ||
      old.flat != flat ||
      old.symbol != symbol ||
      old.shape != shape ||
      old.accentHi != accentHi;
}

/// Two-letter initials of a clan name ("Qızıl Zər" → "QZ").
String clanInitials(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  if (words.isEmpty) return '';
  if (words.length == 1) {
    return words.first.characters.take(2).toString().toUpperCase();
  }
  return words.take(2).map((w) => w.characters.first).join().toUpperCase();
}

enum PresenceDot { online, inGame, offline }

/// Flat avatar with initials and a presence dot (6.1, 5.5).
class PresenceAvatar extends StatelessWidget {
  const PresenceAvatar({
    super.key,
    required this.name,
    required this.size,
    this.presence,
    this.ring = true,
    this.me = false,
    this.ringBg,
  });

  final String name;
  final double size;
  final PresenceDot? presence;

  /// Flat 1.5px `accent@.5` ring (6.1); members have none (5.5).
  final bool ring;
  final bool me;

  /// Colour of the dot's ring (the screen background).
  final Color? ringBg;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final initials =
        name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase();
    final dot = size >= 40 ? 12.0 : 11.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: const Alignment(-.5, -.87),
                end: const Alignment(.5, .87),
                colors: me ? c.avatarMe : c.avatarOpponent,
              ),
              border:
                  ring
                      ? Border.all(
                        color: c.accent.withValues(alpha: .5),
                        width: 1.5,
                      )
                      : null,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: NardType.title.copyWith(
                fontSize: size * .38,
                height: 1,
                color: c.text,
              ),
            ),
          ),
          if (presence != null)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: dot,
                height: dot,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: switch (presence!) {
                    PresenceDot.online => c.presenceOnline,
                    PresenceDot.inGame => c.presenceInGame,
                    PresenceDot.offline => c.presenceOffline,
                  },
                  border: Border.all(color: ringBg ?? c.bgDeep, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Equal-width underline tabs (5.3, 5.4).
class UnderlineTabs extends StatelessWidget {
  const UnderlineTabs({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
    this.height = 40,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.lineSoft)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                selected: i == index,
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: Container(
                    height: height,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: i == index ? c.accent : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      labels[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NardType.body.copyWith(
                        fontSize: 14,
                        fontWeight:
                            i == index ? FontWeight.w600 : FontWeight.w500,
                        color:
                            i == index
                                ? c.accentHi
                                : c.text.withValues(alpha: .6),
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

/// DS filter chip (5.1): h 30, pill, 12 px.
class NardFilterChip extends StatelessWidget {
  const NardFilterChip({
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
    return Semantics(
      selected: selected,
      child: Pressable(
        onTap: onTap,
        minSize: 30,
        child: AnimatedContainer(
          duration: NardMotion.fast,
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? c.accent.withValues(alpha: .18) : null,
            borderRadius: BorderRadius.circular(NardRadius.pill),
            border: Border.all(
              color: selected ? c.accent : c.accent.withValues(alpha: .24),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            style: NardType.caption.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? c.accentHi : c.text,
            ),
          ),
        ),
      ),
    );
  }
}

/// Solid choice chip (19.2 language): h 34, pill, 13 w600.
class NardChoiceChip extends StatelessWidget {
  const NardChoiceChip({
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
    return Semantics(
      selected: selected,
      child: Pressable(
        onTap: onTap,
        minSize: 34,
        child: AnimatedContainer(
          duration: NardMotion.fast,
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? c.accent : c.pillFill,
            borderRadius: BorderRadius.circular(NardRadius.pill),
            border:
                selected
                    ? null
                    : Border.all(color: c.accent.withValues(alpha: .2)),
          ),
          child: Text(
            label,
            maxLines: 1,
            style: NardType.bodyS.copyWith(
              fontWeight: FontWeight.w600,
              color: selected ? c.onAccent : c.text.withValues(alpha: .75),
            ),
          ),
        ),
      ),
    );
  }
}

enum SmallButtonStyle { solid, outline, strong, disabled }

/// Row action button (6.1, 6.2, 5.1): h 36 (34), radius 10, 13 w600.
class SmallActionButton extends StatelessWidget {
  const SmallActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.style = SmallButtonStyle.solid,
    this.height = 36,
    this.icon,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onTap;
  final SmallButtonStyle style;
  final double height;
  final IconData? icon;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final disabled = style == SmallButtonStyle.disabled || onTap == null;
    final (Color? fill, Border? border, Color fg) = switch (style) {
      _ when disabled => (
        null,
        Border.all(color: c.text.withValues(alpha: .15)),
        c.text.withValues(alpha: .4),
      ),
      SmallButtonStyle.solid => (c.accent, null, c.onAccent),
      SmallButtonStyle.outline => (
        null,
        Border.all(color: c.accent.withValues(alpha: .4)),
        c.accentHi,
      ),
      SmallButtonStyle.strong => (
        null,
        Border.all(color: c.accent),
        c.accentHi,
      ),
      SmallButtonStyle.disabled => (null, null, c.textDim),
    };
    return Pressable(
      onTap: disabled || busy ? null : onTap,
      semanticLabel: label,
      minSize: height,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: fill,
          border: border,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (busy)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: fg),
              )
            else if (icon != null)
              Icon(icon, size: 14, color: fg),
            if (busy || icon != null) const SizedBox(width: 4),
            Text(
              label,
              maxLines: 1,
              style: NardType.bodyS.copyWith(
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Clan role badge (5.5).
class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.role, required this.label});

  final ClanRole role;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final (fill, fg) = switch (role) {
      ClanRole.leader => (c.accent.withValues(alpha: .22), c.accentHi),
      ClanRole.coLeader ||
      ClanRole.elder => (c.danger.withValues(alpha: .25), c.errorTitle),
      ClanRole.member => (c.pillFill, c.text.withValues(alpha: .6)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: NardType.micro.copyWith(fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

/// A clan chat bubble (5.4); [mine] is right-aligned brass.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.name,
    required this.text,
    required this.mine,
    this.onLongPress,
  });

  final String name;
  final String text;
  final bool mine;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final bubble = Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
      decoration: BoxDecoration(
        color: mine ? c.bubbleMine : c.bubbleOther,
        borderRadius:
            mine
                ? const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                )
                : const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(16),
                ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: NardType.micro.copyWith(
              fontWeight: FontWeight.w600,
              color: mine ? c.onAccent.withValues(alpha: .7) : c.accentHi,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            text,
            style: NardType.body.copyWith(
              fontSize: 14,
              height: 19 / 14,
              color: mine ? c.onAccent : c.text,
            ),
          ),
        ],
      ),
    );
    final row = Row(
      mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!mine) ...[
          PresenceAvatar(name: name, size: 28, ring: false),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: LayoutBuilder(
            builder:
                (context, box) => ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        box.maxWidth.isFinite
                            ? box.maxWidth * (mine ? .78 : .86)
                            : 300,
                  ),
                  child: bubble,
                ),
          ),
        ),
      ],
    );
    if (onLongPress == null) return row;
    return GestureDetector(onLongPress: onLongPress, child: row);
  }
}

/// Centred system line in the chat (joins, wars, donations).
class SystemMessagePill extends StatelessWidget {
  const SystemMessagePill(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        decoration: BoxDecoration(
          color: c.text.withValues(alpha: .05),
          borderRadius: BorderRadius.circular(NardRadius.pill),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: NardType.caption.copyWith(
            fontWeight: FontWeight.w400,
            color: c.text.withValues(alpha: .55),
          ),
        ),
      ),
    );
  }
}

/// Pill input + round send button (5.4 composer).
class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.hint,
    required this.sendLabel,
    required this.onSend,
    this.maxLength = 300,
    this.busy = false,
    this.notice,
  });

  final String hint;
  final String sendLabel;
  final Future<bool> Function(String text) onSend;
  final int maxLength;
  final bool busy;

  /// An inline line above the field (e.g. "muted until …").
  final String? notice;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final _text = TextEditingController();

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _text.text.trim();
    if (text.isEmpty || widget.busy) return;
    if (await widget.onSend(text) && mounted) _text.clear();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final empty = _text.text.trim().isEmpty;
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        max(12, MediaQuery.paddingOf(context).bottom),
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.accent.withValues(alpha: .12))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.notice case final notice?)
            Semantics(
              liveRegion: true,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                child: Row(
                  children: [
                    Icon(LucideIcons.volumeX, size: 14, color: c.dangerText),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        notice,
                        style: NardType.caption.copyWith(
                          fontWeight: FontWeight.w400,
                          color: c.dangerText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          _field(c, empty),
        ],
      ),
    );
  }

  Widget _field(NardColors c, bool empty) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: c.surfaceSunken,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: c.accent.withValues(alpha: .2)),
            ),
            child: TextField(
              controller: _text,
              maxLength: widget.maxLength,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              cursorColor: c.accentHi,
              style: NardType.body.copyWith(fontSize: 14, color: c.text),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                counterText: '',
                hintText: widget.hint,
                hintStyle: NardType.body.copyWith(
                  fontSize: 14,
                  color: c.text.withValues(alpha: .45),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Pressable(
          onTap: empty || widget.busy ? null : _send,
          semanticLabel: widget.sendLabel,
          child: AnimatedOpacity(
            duration: NardMotion.fast,
            opacity: empty ? .4 : 1,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.accent,
              ),
              child: Icon(LucideIcons.arrowRight, size: 18, color: c.onAccent),
            ),
          ),
        ),
      ],
    );
  }
}

/// Six display cells of a room code (6.3).
class CodeCells extends StatelessWidget {
  const CodeCells({super.key, required this.code, this.semanticLabel});

  final String code;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final chars = code.padRight(6).characters.take(6).toList();
    return Semantics(
      label: semanticLabel ?? code,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < chars.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Container(
              width: 46,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.surfaceRaised,
                borderRadius: BorderRadius.circular(NardRadius.m),
                border: Border.all(color: c.accent.withValues(alpha: .35)),
              ),
              child: Text(
                chars[i],
                style: NardType.mono.copyWith(
                  fontSize: 28,
                  height: 1,
                  fontWeight: FontWeight.w600,
                  color: c.accentHi,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Group card (14.2, 19.2): tile fill, hairline ring, radius 16; rows are
/// separated by hairlines.
class GroupCard extends StatelessWidget {
  const GroupCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.tile,
        borderRadius: BorderRadius.circular(NardRadius.l),
        border: Border.all(color: c.accent.withValues(alpha: .14)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++)
            DecoratedBox(
              decoration: BoxDecoration(
                border:
                    i == children.length - 1
                        ? null
                        : Border(
                          bottom: BorderSide(
                            color: c.accent.withValues(alpha: .08),
                          ),
                        ),
              ),
              child: children[i],
            ),
        ],
      ),
    );
  }
}

/// 22 × 22 checkbox (14.2).
class NardCheckbox extends StatelessWidget {
  const NardCheckbox({super.key, required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return AnimatedContainer(
      duration: NardMotion.fast,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: checked ? c.accent : null,
        borderRadius: BorderRadius.circular(6),
        border:
            checked
                ? null
                : Border.all(color: c.text.withValues(alpha: .3), width: 2),
      ),
      child:
          checked ? Icon(LucideIcons.check, size: 14, color: c.onAccent) : null,
    );
  }
}

/// Rating slider (19.2): 4-high track, brass fill, ivory thumb.
class RatingSlider extends StatelessWidget {
  const RatingSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    required this.startLabel,
    required this.endLabel,
    this.semanticLabel,
  });

  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final String startLabel;
  final String endLabel;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final ends = NardType.micro.copyWith(
      color: c.text.withValues(alpha: .5),
      fontFeatures: tabular,
    );
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            activeTrackColor: c.accent,
            inactiveTrackColor: c.text.withValues(alpha: .12),
            thumbColor: NardPalette.ivory100,
            overlayColor: c.accent.withValues(alpha: .12),
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 11,
              elevation: 3,
            ),
            showValueIndicator: ShowValueIndicator.never,
            tickMarkShape: SliderTickMarkShape.noTickMark,
          ),
          child: Semantics(
            label: semanticLabel,
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(startLabel, style: ends),
              Text(endLabel, style: ends),
            ],
          ),
        ),
      ],
    );
  }
}

/// Red "live" pill with a drawn dot (6.4 spectators, 5.6 war).
class LivePill extends StatelessWidget {
  const LivePill({super.key, required this.label, this.compact = false});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Container(
      height: compact ? null : 30,
      padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 12),
      decoration:
          compact
              ? null
              : BoxDecoration(
                color: c.liveFill,
                borderRadius: BorderRadius.circular(NardRadius.pill),
              ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.dangerText,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: NardType.caption.copyWith(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: compact ? .88 : .72,
              color: c.dangerText,
              fontFeatures: tabular,
            ),
          ),
        ],
      ),
    );
  }
}

/// A list row with a bottom hairline (friends, members, clans).
class HairlineRow extends StatelessWidget {
  const HairlineRow({
    super.key,
    required this.child,
    this.height,
    this.onTap,
    this.highlighted = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.semanticLabel,
  });

  final Widget child;
  final double? height;
  final VoidCallback? onTap;
  final bool highlighted;
  final EdgeInsets padding;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final row = Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: highlighted ? c.accent.withValues(alpha: .1) : null,
        border: Border(
          bottom: BorderSide(color: c.accent.withValues(alpha: .08)),
        ),
      ),
      child: child,
    );
    if (onTap == null) return row;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: row,
      ),
    );
  }
}

/// Sheet action row (14.1 / 5.5 menus): icon, label, optional colour.
class SheetActionRow extends StatelessWidget {
  const SheetActionRow({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.danger = false,
    this.accent = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool danger;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final fg =
        danger
            ? c.dangerText
            : accent
            ? c.accentHi
            : c.text;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: fg),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NardType.body.copyWith(
                      fontSize: 16,
                      fontWeight:
                          danger || accent ? FontWeight.w600 : FontWeight.w500,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Multi-line note field (14.2, 19.2): h 84, sunken fill, hint, counter
/// once 80 % of [maxLength] is used.
class NardMultilineField extends StatefulWidget {
  const NardMultilineField({
    super.key,
    required this.controller,
    required this.hint,
    required this.maxLength,
    this.height = 84,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLength;
  final double height;

  @override
  State<NardMultilineField> createState() => _NardMultilineFieldState();
}

class _NardMultilineFieldState extends State<NardMultilineField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  void _changed() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final used = widget.controller.text.characters.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          height: widget.height,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: c.surfaceSunken,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.accent.withValues(alpha: .2)),
          ),
          child: TextField(
            controller: widget.controller,
            maxLength: widget.maxLength,
            maxLines: null,
            expands: true,
            cursorColor: c.accentHi,
            style: NardType.body.copyWith(fontSize: 14, color: c.text),
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              counterText: '',
              hintText: widget.hint,
              hintStyle: NardType.body.copyWith(
                fontSize: 14,
                color: c.text.withValues(alpha: .45),
              ),
            ),
          ),
        ),
        if (used > widget.maxLength * .8)
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 4),
            child: Text(
              '$used / ${widget.maxLength}',
              style: NardType.micro.copyWith(
                color: c.text.withValues(alpha: .5),
                fontFeatures: tabular,
              ),
            ),
          ),
      ],
    );
  }
}

/// Search field with a leading `search` icon (6.2 h 48, 5.1 h 46).
class NardSearchField extends StatefulWidget {
  const NardSearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.height = 48,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength = 24,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final double height;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final int maxLength;

  @override
  State<NardSearchField> createState() => _NardSearchFieldState();
}

class _NardSearchFieldState extends State<NardSearchField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final focused = _focus.hasFocus;
    return AnimatedContainer(
      duration: NardMotion.fast,
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: focused ? c.accent : c.accent.withValues(alpha: .2),
          width: focused ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.search,
            size: 18,
            color: focused ? c.accent : c.text.withValues(alpha: .5),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              autofocus: widget.autofocus,
              onChanged: widget.onChanged,
              maxLength: widget.maxLength,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: widget.textCapitalization,
              textInputAction: TextInputAction.search,
              cursorColor: c.accentHi,
              cursorWidth: 1.5,
              style: NardType.body.copyWith(color: c.text),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                counterText: '',
                hintText: widget.hint,
                hintStyle: NardType.body.copyWith(
                  color: c.text.withValues(alpha: .5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hairline – label – hairline divider ("və ya", 6.2).
class OrDivider extends StatelessWidget {
  const OrDivider(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final line = Expanded(
      child: Container(height: 1, color: c.accent.withValues(alpha: .2)),
    );
    return Row(
      children: [
        line,
        const SizedBox(width: 12),
        Text(
          label,
          style: NardType.caption.copyWith(
            fontWeight: FontWeight.w400,
            color: c.text.withValues(alpha: .5),
          ),
        ),
        const SizedBox(width: 12),
        line,
      ],
    );
  }
}
