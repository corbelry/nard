import 'dart:ui';

/// Clan emblem drawing data (social.md §6.3; ids match
/// `apps/api/config/clans.php` `emblem`). Pure data: shapes are polygons
/// in fractions of the box (CSS `clip-path` of the design), colours are the
/// 5.3 swatches and the 160° emblem fills. No images, no emoji.
abstract final class EmblemCatalog {
  /// Polygons; `circle` is drawn as an oval.
  static const shapes = <String, List<Offset>>{
    'shield': [
      Offset(.5, 0),
      Offset(1, .18),
      Offset(1, .62),
      Offset(.5, 1),
      Offset(0, .62),
      Offset(0, .18),
    ],
    'hexagon': [
      Offset(.5, 0),
      Offset(1, .25),
      Offset(1, .75),
      Offset(.5, 1),
      Offset(0, .75),
      Offset(0, .25),
    ],
    'octagon': [
      Offset(.3, 0),
      Offset(.7, 0),
      Offset(1, .3),
      Offset(1, .7),
      Offset(.7, 1),
      Offset(.3, 1),
      Offset(0, .7),
      Offset(0, .3),
    ],
    'circle': [],
    'diamond': [Offset(.5, 0), Offset(1, .5), Offset(.5, 1), Offset(0, .5)],
    'banner': [
      Offset(0, 0),
      Offset(1, 0),
      Offset(1, 1),
      Offset(.5, .8),
      Offset(0, 1),
    ],
    'star': [
      Offset(.5, 0),
      Offset(.62, .35),
      Offset(1, .38),
      Offset(.7, .6),
      Offset(.8, 1),
      Offset(.5, .76),
      Offset(.2, 1),
      Offset(.3, .6),
      Offset(0, .38),
      Offset(.38, .35),
    ],
    'arch': [
      Offset(0, .3),
      Offset(.2, .08),
      Offset(.5, 0),
      Offset(.8, .08),
      Offset(1, .3),
      Offset(1, 1),
      Offset(0, 1),
    ],
  };

  /// Shapes drawn in a square box (others use the 1 : 1.15 shield box).
  static const square = {'octagon', 'circle', 'diamond', 'star'};

  /// id → (swatch, fill light, fill dark). `blue` and `walnut` are the
  /// 19.1 extras (§13.17).
  static const colors = <String, (Color, Color, Color)>{
    'garnet': (Color(0xFF9E1B32), Color(0xFFC52F4A), Color(0xFF6E0F20)),
    'indigo': (Color(0xFF26346E), Color(0xFF4A5A9A), Color(0xFF18214A)),
    'emerald': (Color(0xFF1F8A5B), Color(0xFF3FB57F), Color(0xFF145A3A)),
    'brass': (Color(0xFFC9A24A), Color(0xFFC9A24A), Color(0xFF6E4224)),
    'purple': (Color(0xFF7D4FC4), Color(0xFF7D4FC4), Color(0xFF3A1F66)),
    'slate': (Color(0xFF2A2D32), Color(0xFF5C6068), Color(0xFF2A2D32)),
    'ivory': (Color(0xFFF3EBDD), Color(0xFFF3EBDD), Color(0xFFBFB29C)),
    'blue': (Color(0xFF4F7FD1), Color(0xFF6E98DE), Color(0xFF2F5296)),
    'walnut': (Color(0xFF2B1D14), Color(0xFF5D3720), Color(0xFF2B1D14)),
  };

  /// 5.3 "ƏSAS RƏNG" swatch order.
  static const swatchOrder = [
    'garnet',
    'indigo',
    'emerald',
    'brass',
    'purple',
    'slate',
    'ivory',
    'blue',
    'walnut',
  ];

  /// Light colours draw their symbol dark.
  static const lightColors = {'ivory'};

  static const symbols = [
    'diamond',
    'diamond_dot',
    'circle',
    'square',
    'initials',
  ];

  static const patterns = ['none', 'lattice'];

  static (Color, Color, Color) colorOf(String id) =>
      colors[id] ?? colors['garnet']!;

  /// Width / height of the emblem box for [shape].
  static double aspect(String shape) => square.contains(shape) ? 1 : 1 / 1.15;

  /// The shape outline in a box of [size].
  static Path path(String shape, Size size) {
    if (shape == 'circle' || !shapes.containsKey(shape)) {
      if (shape == 'circle') return Path()..addOval(Offset.zero & size);
      return path('shield', size);
    }
    final points = [
      for (final p in shapes[shape]!)
        Offset(p.dx * size.width, p.dy * size.height),
    ];
    return Path()..addPolygon(points, true);
  }
}
