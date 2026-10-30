import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/extra_tokens.dart';
import '../ui/pressable.dart';

/// The 8 wheel emotes in slot order (`Emotes.emotes`, 2.7). Art is not
/// designed yet (§13.1): Lucide outlines stand in, never emoji.
const wheelEmotes = [
  'smile',
  'laugh',
  'wow',
  'think',
  'sad',
  'angry',
  'tea',
  'clap',
];

/// Quick phrases shown as chips (the design's six; `nice_roll` and
/// `sorry` are only rendered when received from another client).
const quickPhrases = [
  'hello',
  'good_luck',
  'well_played',
  'oops',
  'thanks',
  'good_game',
];

IconData emoteIcon(String id) => switch (id) {
  'smile' => LucideIcons.smile,
  'laugh' => LucideIcons.laugh,
  'wow' => LucideIcons.sparkles,
  'think' => LucideIcons.brain,
  'sad' => LucideIcons.frown,
  'angry' => LucideIcons.angry,
  'tea' => LucideIcons.coffee,
  'clap' => LucideIcons.thumbsUp,
  _ => LucideIcons.smile,
};

bool isPhrase(String id) => !wheelEmotes.contains(id);

/// Localized text of an emote (a11y) or quick phrase.
String emoteText(AppLocalizations l, String id) => switch (id) {
  'smile' => l.emoteSmile,
  'laugh' => l.emoteLaugh,
  'wow' => l.emoteWow,
  'think' => l.emoteThink,
  'sad' => l.emoteSad,
  'angry' => l.emoteAngry,
  'tea' => l.emoteTea,
  'clap' => l.emoteClap,
  'hello' => l.phraseHello,
  'good_luck' => l.phraseGoodLuck,
  'well_played' => l.phraseNiceMove,
  'oops' => l.phraseDice,
  'thanks' => l.phraseThanks,
  'good_game' => l.phraseGoodGame,
  'nice_roll' => l.phraseNiceRoll,
  'sorry' => l.phraseSorry,
  _ => id,
};

/// Drives the wheel from the emote button's press-and-hold: the finger's
/// global position while dragging, and the release.
class EmoteWheelDrag extends ChangeNotifier {
  Offset? _pointer;
  bool _released = false;

  Offset? get pointer => _pointer;
  bool get released => _released;

  void move(Offset global) {
    _pointer = global;
    notifyListeners();
  }

  void release() {
    _released = true;
    notifyListeners();
  }
}

/// Opens the 2.7 overlay; [onSend] receives a protocol id only.
Future<void> showEmoteWheel(
  BuildContext context, {
  required ValueChanged<String> onSend,
  EmoteWheelDrag? drag,
}) {
  final c = context.nard;
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: c.scrim,
    transitionDuration:
        MediaQuery.of(context).disableAnimations
            ? Duration.zero
            : NardMotion.fast,
    pageBuilder:
        (ctx, _, _) => EmoteWheelOverlay(
          drag: drag,
          onSend: (id) {
            Navigator.of(ctx).pop();
            onSend(id);
          },
          onClose: () => Navigator.of(ctx).pop(),
        ),
    transitionBuilder:
        (ctx, anim, _, child) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween(begin: .92, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: NardMotion.standard),
            ),
            child: child,
          ),
        ),
  );
}

/// Wheel (8 emote slots on a 112 radius) + phrase chips, bottom-aligned.
class EmoteWheelOverlay extends StatefulWidget {
  const EmoteWheelOverlay({
    super.key,
    required this.onSend,
    required this.onClose,
    this.drag,
  });

  final ValueChanged<String> onSend;
  final VoidCallback onClose;
  final EmoteWheelDrag? drag;

  @override
  State<EmoteWheelOverlay> createState() => _EmoteWheelOverlayState();
}

class _EmoteWheelOverlayState extends State<EmoteWheelOverlay> {
  static const _size = 280.0;
  static const _radius = 112.0;
  static const _slot = 56.0;
  final _wheelKey = GlobalKey();
  int? _hover;

  @override
  void initState() {
    super.initState();
    widget.drag?.addListener(_dragged);
  }

  @override
  void dispose() {
    widget.drag?.removeListener(_dragged);
    super.dispose();
  }

  Offset _center(int i) {
    final a = -pi / 2 + i * pi / 4;
    return Offset(_size / 2 + _radius * cos(a), _size / 2 + _radius * sin(a));
  }

  int? _slotAt(Offset local) {
    for (var i = 0; i < wheelEmotes.length; i++) {
      if ((local - _center(i)).distance <= _slot / 2 + 6) return i;
    }
    return null;
  }

  void _dragged() {
    final drag = widget.drag!;
    if (drag.released) {
      final hover = _hover;
      if (hover != null) {
        widget.onSend(wheelEmotes[hover]);
      } else {
        widget.onClose();
      }
      return;
    }
    final box = _wheelKey.currentContext?.findRenderObject() as RenderBox?;
    final pointer = drag.pointer;
    if (box == null || pointer == null) return;
    _setHover(_slotAt(box.globalToLocal(pointer)));
  }

  void _setHover(int? i) {
    if (i == _hover) return;
    if (i != null) unawaited(HapticFeedback.selectionClick());
    setState(() => _hover = i);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final bottom = max(40.0, MediaQuery.paddingOf(context).bottom + 6);
    final wheel = SizedBox(
      key: _wheelKey,
      width: _size,
      height: _size,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: c.emoteWheelDisc,
                border: Border.all(color: c.accent.withValues(alpha: .35)),
                boxShadow: c.emoteWheelShadow,
              ),
            ),
          ),
          Center(
            child: Text(
              l.emoteWheelHint,
              textAlign: TextAlign.center,
              style: NardType.caption.copyWith(
                fontWeight: FontWeight.w400,
                color: c.text.withValues(alpha: .64),
              ),
            ),
          ),
          for (var i = 0; i < wheelEmotes.length; i++)
            Positioned(
              left: _center(i).dx - _slot / 2,
              top: _center(i).dy - _slot / 2,
              child: _EmoteSlot(
                id: wheelEmotes[i],
                label: emoteText(l, wheelEmotes[i]),
                hovered: _hover == i,
                onTap: () => widget.onSend(wheelEmotes[i]),
              ),
            ),
        ],
      ),
    );
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onClose,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              wheel,
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final id in quickPhrases)
                      PhraseChip(
                        label: emoteText(l, id),
                        onTap: () => widget.onSend(id),
                      ),
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

class _EmoteSlot extends StatelessWidget {
  const _EmoteSlot({
    required this.id,
    required this.label,
    required this.hovered,
    required this.onTap,
  });

  final String id;
  final String label;
  final bool hovered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      minSize: 56,
      child: AnimatedContainer(
        duration: NardMotion.fast,
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: hovered ? c.accent.withValues(alpha: .25) : c.tile,
          border: Border.all(
            color: hovered ? c.accentHi : c.accent.withValues(alpha: .25),
            width: hovered ? 2 : 1,
          ),
          boxShadow:
              hovered
                  ? [
                    BoxShadow(
                      color: c.accentHi.withValues(alpha: .5),
                      blurRadius: 16,
                    ),
                  ]
                  : null,
        ),
        child: Icon(emoteIcon(id), size: 26, color: c.accentHi),
      ),
    );
  }
}

/// Quick-phrase chip (2.7, also the received-phrase bubble).
class PhraseChip extends StatelessWidget {
  const PhraseChip({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final chip = Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: BorderRadius.circular(NardRadius.pill),
        border: Border.all(color: c.accent.withValues(alpha: .3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            style: NardType.body.copyWith(fontSize: 14, color: c.text),
          ),
        ],
      ),
    );
    if (onTap == null) return chip;
    return Pressable(onTap: onTap, semanticLabel: label, child: chip);
  }
}

/// A received emote / phrase next to the sender's card: shows 2.5 s, then
/// fades out (`NardMotion.fast`).
class EmoteBubble extends StatefulWidget {
  const EmoteBubble({super.key, required this.id});

  final String id;

  static const visible = Duration(milliseconds: 2500);

  @override
  State<EmoteBubble> createState() => _EmoteBubbleState();
}

class _EmoteBubbleState extends State<EmoteBubble> {
  bool _shown = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(EmoteBubble.visible, () {
      if (mounted) setState(() => _shown = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final text = emoteText(l, widget.id);
    final Widget body =
        isPhrase(widget.id)
            ? PhraseChip(label: text)
            : Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.surfaceRaised,
                border: Border.all(color: c.accent.withValues(alpha: .3)),
                boxShadow: c.elevation2,
              ),
              child: Icon(
                emoteIcon(widget.id),
                size: 40 * .6,
                color: c.accentHi,
              ),
            );
    return IgnorePointer(
      child: Semantics(
        liveRegion: true,
        label: text,
        child: AnimatedOpacity(
          opacity: _shown ? 1 : 0,
          duration: NardMotion.fast,
          child: ExcludeSemantics(child: body),
        ),
      ),
    );
  }
}

/// The emote button on my PlayerCard (40 Ø, `smile`): tap opens the
/// wheel, press-and-hold drags onto a slot and sends on release.
class EmoteButton extends StatefulWidget {
  const EmoteButton({
    super.key,
    required this.onSend,
    this.enabled = true,
    this.size = 40,
    this.caption,
  });

  final ValueChanged<String> onSend;
  final bool enabled;
  final double size;

  /// Long Nard "Söhbət" control (66 × 62 with a caption).
  final String? caption;

  @override
  State<EmoteButton> createState() => _EmoteButtonState();
}

class _EmoteButtonState extends State<EmoteButton> {
  EmoteWheelDrag? _drag;

  void _open({EmoteWheelDrag? drag}) {
    unawaited(showEmoteWheel(context, onSend: widget.onSend, drag: drag));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final caption = widget.caption;
    final icon = Icon(
      caption == null ? LucideIcons.smile : LucideIcons.messageSquare,
      size: 20,
      color: caption == null ? c.textDim : c.text,
    );
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: l.emoteButton,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enabled ? _open : null,
        onLongPressStart:
            widget.enabled
                ? (d) {
                  final drag = _drag = EmoteWheelDrag()..move(d.globalPosition);
                  _open(drag: drag);
                }
                : null,
        onLongPressMoveUpdate: (d) => _drag?.move(d.globalPosition),
        onLongPressEnd: (_) {
          _drag?.release();
          _drag = null;
        },
        child: AnimatedOpacity(
          duration: NardMotion.fast,
          opacity: widget.enabled ? 1 : .35,
          child: Container(
            width: caption == null ? widget.size : 66,
            height: caption == null ? widget.size : 62,
            decoration: BoxDecoration(
              shape: caption == null ? BoxShape.circle : BoxShape.rectangle,
              borderRadius:
                  caption == null
                      ? null
                      : BorderRadius.circular(c.buttonRadius),
              border: Border.all(color: c.line),
            ),
            child:
                caption == null
                    ? Center(child: icon)
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        icon,
                        const SizedBox(height: 4),
                        Text(
                          caption,
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
      ),
    );
  }
}
