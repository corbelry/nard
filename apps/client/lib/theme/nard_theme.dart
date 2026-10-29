import 'package:flutter/material.dart';
import 'nard_colors.dart';
import 'nard_tokens.dart';

abstract final class NardTheme {
  static ThemeData build(NardColors c, {Brightness brightness = Brightness.dark}) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.primaryText,
      secondary: c.accentHi,
      onSecondary: c.primaryText,
      error: c.danger,
      onError: NardPalette.ivory100,
      surface: c.bg,
      onSurface: c.text,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      fontFamily: NardFonts.ui,
      extensions: [c],
      splashFactory: NoSplash.splashFactory,
      textTheme: TextTheme(
        displayLarge: NardType.displayXl.copyWith(color: c.text),
        displayMedium: NardType.displayL.copyWith(color: c.text),
        titleLarge: NardType.title.copyWith(color: c.text),
        labelLarge: NardType.labelL.copyWith(color: c.text),
        labelMedium: NardType.labelM.copyWith(color: c.text),
        bodyLarge: NardType.body.copyWith(color: c.text),
        bodyMedium: NardType.bodyS.copyWith(color: c.textDim),
        bodySmall: NardType.caption.copyWith(color: c.textDim),
        labelSmall: NardType.micro.copyWith(color: c.textDim),
      ),
      dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceRaised,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(NardRadius.xl))),
        showDragHandle: true,
        dragHandleColor: c.text.withValues(alpha: .25),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.bg : c.text),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.accent : c.text.withValues(alpha: .14)),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    );
  }
}
