import 'package:flutter/material.dart';

import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';

/// Values the design uses that have no token in the exported theme
/// (`lib/theme/` is kept identical to the design skill). Documented as
/// "no token" in docs/design-notes/*.md. Derived from the active
/// [NardColors] where possible so other themes keep working.
extension NardExtras on NardColors {
  /// Sebeke screen background (vertical garnet-black gradient).
  Gradient get bgGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF24161B), Color(0xFF17121A), Color(0xFF1F1317)],
    stops: [0, .5, 1],
  );

  /// Ring + glow of the primary (garnet pill) button.
  List<BoxShadow> get primaryGlow => const [
    BoxShadow(color: Color(0x599E1B32), offset: Offset(0, 6), blurRadius: 18),
  ];
  Color get primaryRing => accent.withValues(alpha: .65);

  /// Label colour on solid garnet (danger button, low clock).
  Color get onDanger => const Color(0xFFFBEFEF);
  Color get dangerPressed => const Color(0xFF7F1428);

  /// Text drawn on a solid accent fill.
  Color get onAccent => clockActiveText;

  Color get textFaint => text.withValues(alpha: .45);
  Color get lineSoft => accent.withValues(alpha: .16);
  Color get surfaceSunken => const Color(0x40000000);
  Color get scrim => const Color(0x9E080605);

  /// Menu card tints (ivory) used instead of the garnet `surface`.
  Color get tile => text.withValues(alpha: .05);
  Color get tileRing => accent.withValues(alpha: .18);
  Color get selectedFill => accent.withValues(alpha: .16);

  /// Dim dot of the status banner.
  Color get dimDot => const Color(0xFF8F877B);

  /// Title colour of the illegal-move toast.
  Color get errorTitle => const Color(0xFFF3B0BC);

  List<BoxShadow> get elevation2 => const [
    BoxShadow(color: Color(0x80000000), offset: Offset(0, 12), blurRadius: 30),
  ];
  List<BoxShadow> get elevation3 => const [
    BoxShadow(color: Color(0x99000000), offset: Offset(0, 20), blurRadius: 60),
  ];

  /// Sebeke sets button labels in Noto Serif Display.
  String get buttonFont => latticeBand ? NardFonts.display : NardFonts.ui;

  /// Sebeke shows the şəbəkə lattice band at the top of screens.
  bool get latticeBand => buttonRadius == 999;
}
