import 'package:flutter/material.dart';
import 'nard_tokens.dart';

/// Semantic colors. Variants: sebeke (DEFAULT, 1c), ceviz (1a), komur (1b), light.
@immutable
class NardColors extends ThemeExtension<NardColors> {
  const NardColors({
    required this.bg,
    required this.bgDeep,
    required this.surface,
    required this.surfaceRaised,
    required this.text,
    required this.textDim,
    required this.line,
    required this.accent,
    required this.accentHi,
    required this.primaryFill,
    required this.primaryText,
    required this.danger,
    required this.dangerText,
    required this.success,
    required this.successText,
    required this.clockActiveBg,
    required this.clockActiveText,
    required this.cardRadius,
    required this.buttonRadius,
    required this.uppercaseLabels,
  });

  final Color bg, bgDeep, surface, surfaceRaised, text, textDim, line, accent, accentHi;
  final Gradient primaryFill;
  final Color primaryText, danger, dangerText, success, successText, clockActiveBg, clockActiveText;
  final double cardRadius, buttonRadius;
  final bool uppercaseLabels;

  static const defaultTheme = sebeke;

  static const ceviz = NardColors(
    bg: NardPalette.walnut900,
    bgDeep: NardPalette.walnut950,
    surface: Color(0x0FF3EBDD),
    surfaceRaised: NardPalette.walnut800,
    text: NardPalette.ivory100,
    textDim: Color(0xA3F3EBDD),
    line: Color(0x3DC9A24A),
    accent: NardPalette.brass500,
    accentHi: NardPalette.brass300,
    primaryFill: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFDCB862), Color(0xFFC29A43), Color(0xFFA8822F)], stops: [0, .55, 1]),
    primaryText: Color(0xFF231709),
    danger: NardPalette.garnet600,
    dangerText: NardPalette.garnet400,
    success: NardPalette.emerald600,
    successText: NardPalette.emerald400,
    clockActiveBg: NardPalette.ivory100,
    clockActiveText: NardPalette.walnut900,
    cardRadius: 16,
    buttonRadius: 16,
    uppercaseLabels: false,
  );

  static const komur = NardColors(
    bg: NardPalette.charcoal900,
    bgDeep: Color(0xFF101216),
    surface: NardPalette.charcoal800,
    surfaceRaised: Color(0xFF202329),
    text: Color(0xFFECE7DE),
    textDim: Color(0xFFA19D95),
    line: Color(0x1AECE7DE),
    accent: NardPalette.brass500,
    accentHi: NardPalette.brass300,
    primaryFill: LinearGradient(colors: [NardPalette.brass500, NardPalette.brass500]),
    primaryText: NardPalette.charcoal900,
    danger: NardPalette.garnet600,
    dangerText: NardPalette.garnet400,
    success: NardPalette.emerald600,
    successText: NardPalette.emerald400,
    clockActiveBg: NardPalette.brass500,
    clockActiveText: NardPalette.charcoal900,
    cardRadius: 8,
    buttonRadius: 8,
    uppercaseLabels: true,
  );

  static const sebeke = NardColors(
    bg: Color(0xFF1B1418),
    bgDeep: Color(0xFF17121A),
    surface: Color(0x2E9E1B32),
    surfaceRaised: Color(0xFF2A1A20),
    text: NardPalette.ivory100,
    textDim: Color(0xA8F3EBDD),
    line: Color(0x52D4AE58),
    accent: Color(0xFFD4AE58),
    accentHi: NardPalette.brass300,
    primaryFill: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFB52A45), Color(0xFF9E1B32), Color(0xFF86152A)], stops: [0, .6, 1]),
    primaryText: Color(0xFFF8F1E4),
    danger: NardPalette.garnet600,
    dangerText: NardPalette.garnet400,
    success: NardPalette.emerald600,
    successText: NardPalette.emerald400,
    clockActiveBg: Color(0xFFD4AE58),
    clockActiveText: Color(0xFF1D1316),
    cardRadius: 14,
    buttonRadius: 999,
    uppercaseLabels: false,
  );

  static const light = NardColors(
    bg: NardPalette.ivory100,
    bgDeep: Color(0xFFE9DFCD),
    surface: NardPalette.ivory50,
    surfaceRaised: Color(0xFFFFFFFF),
    text: NardPalette.walnut900,
    textDim: Color(0xFF6B5A49),
    line: Color(0x242B1D14),
    accent: NardPalette.brass700,
    accentHi: NardPalette.brass600,
    primaryFill: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFDCB862), Color(0xFFC29A43), Color(0xFFA8822F)], stops: [0, .55, 1]),
    primaryText: Color(0xFF231709),
    danger: NardPalette.garnet600,
    dangerText: NardPalette.garnet600,
    success: NardPalette.emerald600,
    successText: NardPalette.emerald600,
    clockActiveBg: NardPalette.walnut900,
    clockActiveText: NardPalette.ivory100,
    cardRadius: 16,
    buttonRadius: 16,
    uppercaseLabels: false,
  );

  @override
  NardColors copyWith({Color? bg, Color? surface, Color? text, Color? accent, Gradient? primaryFill, Color? primaryText, double? cardRadius, double? buttonRadius, bool? uppercaseLabels}) => NardColors(
        bg: bg ?? this.bg,
        bgDeep: bgDeep,
        surface: surface ?? this.surface,
        surfaceRaised: surfaceRaised,
        text: text ?? this.text,
        textDim: textDim,
        line: line,
        accent: accent ?? this.accent,
        accentHi: accentHi,
        primaryFill: primaryFill ?? this.primaryFill,
        primaryText: primaryText ?? this.primaryText,
        danger: danger,
        dangerText: dangerText,
        success: success,
        successText: successText,
        clockActiveBg: clockActiveBg,
        clockActiveText: clockActiveText,
        cardRadius: cardRadius ?? this.cardRadius,
        buttonRadius: buttonRadius ?? this.buttonRadius,
        uppercaseLabels: uppercaseLabels ?? this.uppercaseLabels,
      );

  @override
  NardColors lerp(NardColors? o, double t) {
    if (o == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return NardColors(
      bg: c(bg, o.bg), bgDeep: c(bgDeep, o.bgDeep), surface: c(surface, o.surface), surfaceRaised: c(surfaceRaised, o.surfaceRaised),
      text: c(text, o.text), textDim: c(textDim, o.textDim), line: c(line, o.line), accent: c(accent, o.accent), accentHi: c(accentHi, o.accentHi),
      primaryFill: Gradient.lerp(primaryFill, o.primaryFill, t)!, primaryText: c(primaryText, o.primaryText),
      danger: c(danger, o.danger), dangerText: c(dangerText, o.dangerText), success: c(success, o.success), successText: c(successText, o.successText),
      clockActiveBg: c(clockActiveBg, o.clockActiveBg), clockActiveText: c(clockActiveText, o.clockActiveText),
      cardRadius: lerpDouble(cardRadius, o.cardRadius, t), buttonRadius: lerpDouble(buttonRadius, o.buttonRadius, t),
      uppercaseLabels: t < .5 ? uppercaseLabels : o.uppercaseLabels,
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

extension NardThemeX on BuildContext {
  NardColors get nard => Theme.of(this).extension<NardColors>()!;
}
