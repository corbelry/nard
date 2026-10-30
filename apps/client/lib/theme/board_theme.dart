import 'package:flutter/painting.dart';

/// Board geometry in logical units. Render the board in a 640 x H space and scale uniformly.
abstract final class BoardGeometry {
  static const width = 640.0;
  static const heightPortrait = 566.0;
  static const heightLandscape = 460.0;
  static const frame = 20.0;
  static const quadrant = 252.0; // 6 points
  static const pointWidth = 42.0;
  static const bar = 36.0;
  static const trayGap = 14.0;
  static const tray = 46.0;
  static const checker = 38.0;
  static const barChecker = 34.0;
  static const die = 44.0;
  static const cube = 34.0;
  static const cubeOffer = 56.0;
  static const pointHeightRatio = 0.43; // of (H - 2*frame)
  static const offSlab = Size(40, 10);

  /// x of column c (0..11, left to right)
  static double colX(int c) =>
      c < 6
          ? frame + c * pointWidth
          : frame + quadrant + bar + (c - 6) * pointWidth;

  /// Point 1..24 from the local player's view. 1-12 bottom row (right to left), 13-24 top row (left to right).
  static ({double x, bool bottom}) point(int i) =>
      i <= 12
          ? (x: colX(12 - i), bottom: true)
          : (x: colX(i - 13), bottom: false);
}

/// Cosmetic board set. Textures come from assets/themes/{id}/ (see Asset spec). Fallback colors are used for
/// highlights and while textures load.
class BoardTheme {
  const BoardTheme({
    required this.id,
    required this.name,
    required this.rarity,
    required this.pointA,
    required this.pointB,
    required this.field,
    required this.frame,
    required this.numberColor,
    this.hasCube = true,
  });
  final String id, name, rarity;
  final Color pointA, pointB, field, frame, numberColor;
  final bool hasCube;

  String asset(String part, {int scale = 3}) =>
      'assets/themes/$id/$part@${scale}x.webp';

  static const walnut = BoardTheme(
    id: 'walnut',
    name: 'Classic Walnut',
    rarity: 'common',
    pointA: Color(0xFF1A0E07),
    pointB: Color(0xFFE3D3B4),
    field: Color(0xFFB4824D),
    frame: Color(0xFF5D3720),
    numberColor: Color(0x8CF3EBDD),
  );
  static const bakuNight = BoardTheme(
    id: 'baku_night',
    name: 'Baku Night',
    rarity: 'epic',
    pointA: Color(0xFFB08A35),
    pointB: Color(0xFF2C3352),
    field: Color(0xFF1E2230),
    frame: Color(0xFF171A23),
    numberColor: Color(0x8CE8C468),
  );
  static const carpet = BoardTheme(
    id: 'carpet_heritage',
    name: 'Carpet Heritage',
    rarity: 'rare',
    pointA: Color(0xFF1F2B5C),
    pointB: Color(0xFFE6D6B4),
    field: Color(0xFF7B1C22),
    frame: Color(0xFF3C1C12),
    numberColor: Color(0x8CF3EBDD),
  );
  static const marble = BoardTheme(
    id: 'marble_royale',
    name: 'Marble Royale',
    rarity: 'legendary',
    pointA: Color(0xFF1C1C20),
    pointB: Color(0xFFCFAE5C),
    field: Color(0xFFE8E4DD),
    frame: Color(0xFF1A1A1E),
    numberColor: Color(0xB3E8C468),
  );
  static const caspian = BoardTheme(
    id: 'caspian',
    name: 'Caspian',
    rarity: 'seasonal',
    pointA: Color(0xFFDDD0B8),
    pointB: Color(0xFF08242C),
    field: Color(0xFF16546A),
    frame: Color(0xFF0C323C),
    numberColor: Color(0x8CECE3D1),
  );
  static const minimalPro = BoardTheme(
    id: 'minimal_pro',
    name: 'Minimal Pro',
    rarity: 'common',
    pointA: Color(0xFFE9E6DF),
    pointB: Color(0xFF5C6068),
    field: Color(0xFF2A2D32),
    frame: Color(0xFF1F2125),
    numberColor: Color(0xB3ECE7DE),
  );

  static const all = [walnut, bakuNight, carpet, marble, caspian, minimalPro];
}

/// Shared overlay colors drawn in code (not textures).
abstract final class BoardOverlay {
  static const legalFill = Color(0xD9F0CD6E);
  static const legalGhostBorder = Color(0xF2F4D478);
  static const legalGhostFill = Color(0x2EF0CD6E);
  static const lastMoveGhost = Color(0x73F3EBDD);
  static const selectRing = Color(0xFFF0CD6E);
}
