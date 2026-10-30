import 'package:flutter/material.dart';

import '../theme/nard_tokens.dart';

/// Press feedback used by every tappable: scale 0.97 over 90 ms, no ripple
/// and no colour flash. [pressedBuilder] may swap decoration while held.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.onTap,
    required this.child,
    this.semanticLabel,
    this.button = true,
    this.minSize = NardSpace.hitMin,
  });

  final VoidCallback? onTap;
  final Widget child;
  final String? semanticLabel;
  final bool button;
  final double minSize;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool down) {
    if (widget.onTap == null || down == _down) return;
    setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.button,
      enabled: widget.onTap != null,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: widget.minSize,
            minHeight: widget.minSize,
          ),
          child: AnimatedScale(
            scale: _down ? NardMotion.pressScale : 1,
            duration: NardMotion.press,
            curve: NardMotion.standard,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
