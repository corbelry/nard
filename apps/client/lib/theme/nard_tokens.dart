// GENERATED from NardArena Design System — keep names in sync with tokens/*.css
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

abstract final class NardPalette {
  static const walnut950 = Color(0xFF1B120C);
  static const walnut900 = Color(0xFF2B1D14);
  static const walnut800 = Color(0xFF34251A);
  static const walnut700 = Color(0xFF3B2819);
  static const charcoal900 = Color(0xFF16181D);
  static const charcoal800 = Color(0xFF1F2128);
  static const ivory50 = Color(0xFFFBF7F0);
  static const ivory100 = Color(0xFFF3EBDD);
  static const ivoryDim = Color(0xFFA89C8B);
  static const brass300 = Color(0xFFE8C468);
  static const brass500 = Color(0xFFC9A24A);
  static const brass600 = Color(0xFFA8822F);
  static const brass700 = Color(0xFF7A5C1E);
  static const garnet400 = Color(0xFFE0566C);
  static const garnet600 = Color(0xFF9E1B32);
  static const emerald400 = Color(0xFF3FB57F);
  static const emerald600 = Color(0xFF1F8A5B);

  // Rarity (sRGB approximations of the oklch tokens)
  static const rarityCommon = Color(0xFFB4B0A8);
  static const rarityRare = Color(0xFF5FA8E8);
  static const rarityEpic = Color(0xFFB08AE6);
  static const rarityLegendary = Color(0xFFE2BC5A);
  static const raritySeasonal = Color(0xFFE88A7E);
}

abstract final class NardSpace {
  static const s1 = 4.0,
      s2 = 8.0,
      s3 = 12.0,
      s4 = 16.0,
      s5 = 20.0,
      s6 = 24.0,
      s8 = 32.0,
      s12 = 48.0;
  static const hitMin = 44.0,
      hitPrimary = 56.0,
      screenGutter = 16.0,
      boardGutter = 6.0;
}

abstract final class NardRadius {
  static const xs = 4.0, s = 8.0, m = 12.0, l = 16.0, xl = 24.0, pill = 999.0;
}

abstract final class NardMotion {
  static const press = Duration(milliseconds: 90);
  static const fast = Duration(milliseconds: 160);
  static const sheetIn = Duration(milliseconds: 320);
  static const sheetOut = Duration(milliseconds: 220);
  static const checker = Duration(milliseconds: 280);
  static const hit = Duration(milliseconds: 220);
  static const bearOff = Duration(milliseconds: 240);
  static const dice = Duration(milliseconds: 800);
  static const diceFast = Duration(milliseconds: 300);
  static const counter = Duration(milliseconds: 1200);

  static const standard = Cubic(0.2, 0.8, 0.2, 1);
  static const checkerCurve = Cubic(0.3, 0.7, 0.2, 1);
  static const outCubic = Curves.easeOutCubic;
  static const outQuart = Curves.easeOutQuart;
  static const outExpo = Curves.easeOutExpo;
  static const inBack = Curves.easeInBack;
  static const pressScale = 0.97;
}

abstract final class NardFonts {
  static const display = 'NotoSerifDisplay';
  static const ui = 'IBMPlexSans';
  static const uiCondensed = 'IBMPlexSansCondensed';
  static const mono = 'IBMPlexMono';
}

abstract final class NardType {
  static const _tnum = [FontFeature.tabularFigures()];
  static const displayXl = TextStyle(
    fontFamily: NardFonts.display,
    fontSize: 40,
    height: 44 / 40,
    fontWeight: FontWeight.w600,
  );
  static const displayL = TextStyle(
    fontFamily: NardFonts.display,
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w600,
  );
  static const title = TextStyle(
    fontFamily: NardFonts.display,
    fontSize: 19,
    height: 24 / 19,
    fontWeight: FontWeight.w600,
  );
  static const score = TextStyle(
    fontFamily: NardFonts.display,
    fontSize: 22,
    height: 24 / 22,
    fontWeight: FontWeight.w600,
    fontFeatures: _tnum,
  );
  static const labelL = TextStyle(
    fontFamily: NardFonts.ui,
    fontSize: 17,
    height: 20 / 17,
    fontWeight: FontWeight.w600,
  );
  static const labelM = TextStyle(
    fontFamily: NardFonts.ui,
    fontSize: 15,
    height: 18 / 15,
    fontWeight: FontWeight.w600,
  );
  static const body = TextStyle(
    fontFamily: NardFonts.ui,
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w400,
  );
  static const bodyS = TextStyle(
    fontFamily: NardFonts.ui,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
  );
  static const caption = TextStyle(
    fontFamily: NardFonts.ui,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
  );
  static const micro = TextStyle(
    fontFamily: NardFonts.ui,
    fontSize: 11,
    height: 13 / 11,
    fontWeight: FontWeight.w500,
  );
  static const clock = TextStyle(
    fontFamily: NardFonts.ui,
    fontSize: 20,
    height: 1,
    fontWeight: FontWeight.w600,
    fontFeatures: _tnum,
  );
  static const mono = TextStyle(
    fontFamily: NardFonts.mono,
    fontSize: 12,
    height: 16 / 12,
  );
}
