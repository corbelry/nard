import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import 'extra_tokens.dart';
import 'layout.dart';

/// Text field (online.md §0.1): sunken fill, card radius, brass ring when
/// focused, garnet ring on error, optional label above.
class NardTextField extends StatefulWidget {
  const NardTextField({
    super.key,
    required this.controller,
    this.label,
    this.height = 54,
    this.keyboardType,
    this.autofillHints,
    this.autofocus = false,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.onSubmitted,
    this.error = false,
    this.danger = false,
    this.style,
    this.maxLength,
  });

  final TextEditingController controller;
  final String? label;
  final double height;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Garnet ring (validation error).
  final bool error;

  /// Always garnet (delete confirmation, 15.3).
  final bool danger;
  final TextStyle? style;
  final int? maxLength;

  @override
  State<NardTextField> createState() => _NardTextFieldState();
}

class _NardTextFieldState extends State<NardTextField> {
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
    final red = widget.error || widget.danger;
    final focused = _focus.hasFocus;
    final ring =
        red
            ? Border.all(color: c.dangerText, width: 1.5)
            : focused
            ? Border.all(color: c.accent, width: 1.5)
            : Border.all(color: c.line);
    final field = AnimatedContainer(
      duration: NardMotion.fast,
      height: widget.height,
      padding: EdgeInsets.symmetric(horizontal: widget.height >= 54 ? 16 : 14),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: BorderRadius.circular(c.cardRadius),
        border: ring,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        autofocus: widget.autofocus,
        keyboardType: widget.keyboardType,
        autofillHints: widget.autofillHints,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        autocorrect: false,
        enableSuggestions: false,
        cursorColor: c.text,
        cursorWidth: 2,
        maxLength: widget.maxLength,
        style: (widget.style ?? NardType.body.copyWith(fontSize: 16)).copyWith(
          color: c.text,
        ),
        decoration: const InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          counterText: '',
        ),
      ),
    );
    if (widget.label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            widget.label!,
            style: NardType.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: c.text.withValues(alpha: .6),
            ),
          ),
        ),
        field,
      ],
    );
  }
}

/// Six digit cells over one hidden text field (17.3): digits only, paste
/// fills every cell, one-time-code autofill. Shakes when [shake] changes.
class CodeField extends StatefulWidget {
  const CodeField({
    super.key,
    required this.controller,
    this.length = 6,
    this.error = false,
    this.shake = 0,
    this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.semanticLabel,
  });

  final TextEditingController controller;
  final int length;
  final bool error;
  final int shake;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;
  final String? semanticLabel;

  @override
  State<CodeField> createState() => _CodeFieldState();
}

class _CodeFieldState extends State<CodeField>
    with SingleTickerProviderStateMixin {
  final _focus = FocusNode();
  late final _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  );

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
    widget.controller.addListener(_changed);
  }

  @override
  void didUpdateWidget(CodeField old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_changed);
      widget.controller.addListener(_changed);
    }
    if (old.shake != widget.shake &&
        !MediaQuery.of(context).disableAnimations) {
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    _focus.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _changed() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final text = widget.controller.text;
    final active = min(text.length, widget.length - 1);
    final cells = Row(
      children: [
        for (var i = 0; i < widget.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: AnimatedContainer(
              duration: NardMotion.fast,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.surfaceSunken,
                borderRadius: BorderRadius.circular(c.cardRadius),
                border:
                    widget.error
                        ? Border.all(color: c.dangerText, width: 1.5)
                        : i == active && _focus.hasFocus && text.length < 6
                        ? Border.all(color: c.accent, width: 1.5)
                        : Border.all(color: c.line),
              ),
              child: Text(
                i < text.length ? text[i] : '',
                style: NardType.title.copyWith(
                  fontSize: 26,
                  fontFamily: NardFonts.ui,
                  fontWeight: FontWeight.w600,
                  fontFeatures: tabular,
                  color: c.text,
                ),
              ),
            ),
          ),
        ],
      ],
    );
    return Semantics(
      label: widget.semanticLabel,
      textField: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _focus.requestFocus(),
        child: AnimatedBuilder(
          animation: _shake,
          builder:
              (context, child) => Transform.translate(
                offset: Offset(sin(_shake.value * pi * 4) * 6, 0),
                child: child,
              ),
          child: Stack(
            children: [
              cells,
              Positioned.fill(
                child: Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focus,
                    autofocus: true,
                    enabled: widget.enabled,
                    keyboardType: TextInputType.number,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    maxLength: widget.length,
                    showCursor: false,
                    enableInteractiveSelection: false,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(widget.length),
                    ],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    onChanged: (v) {
                      widget.onChanged?.call(v);
                      if (v.length == widget.length) {
                        widget.onCompleted?.call(v);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
