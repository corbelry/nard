import 'dart:ui';

/// A checker material (store.md §1.1): radial stops from the highlight
/// outwards, optional concentric grooves and rim ring; [flat] drops the
/// bevel and grooves (Minimal Pro).
class CheckerMaterial {
  const CheckerMaterial({
    required this.stops,
    this.groove,
    this.rim,
    this.flat = false,
  });

  final List<Color> stops;
  final Color? groove;
  final Color? rim;
  final bool flat;

  static CheckerMaterial? _parse(Object? json) {
    if (json is! Map) return null;
    final stops = parseColors(json['stops']);
    if (stops == null) return null;
    return CheckerMaterial(
      stops: stops,
      groove: parseColor(json['groove']),
      rim: parseColor(json['rim']),
      flat: json['flat'] == true,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CheckerMaterial &&
      _listEq(other.stops, stops) &&
      other.groove == groove &&
      other.rim == rim &&
      other.flat == flat;

  @override
  int get hashCode => Object.hash(Object.hashAll(stops), groove, rim, flat);
}

/// Die face gradient (145°) and pip gradient (radial).
class DiceLook {
  const DiceLook({required this.face, required this.pip, this.flat = false});

  final List<Color> face;
  final List<Color> pip;
  final bool flat;

  static DiceLook? _parse(Object? json) {
    if (json is! Map) return null;
    final face = parseColors(json['face']);
    final pip = parseColors(json['pip']);
    if (face == null || pip == null) return null;
    return DiceLook(face: face, pip: pip, flat: json['flat'] == true);
  }

  @override
  bool operator ==(Object other) =>
      other is DiceLook &&
      _listEq(other.face, face) &&
      _listEq(other.pip, pip) &&
      other.flat == flat;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(face), Object.hashAll(pip), flat);
}

/// The full look of a cosmetic board set, parsed from a catalog item's
/// `data.look` (ADR-034). Gradients are top → bottom lists.
class BoardLook {
  const BoardLook({
    required this.id,
    required this.frame,
    required this.field,
    required this.pointA,
    required this.pointB,
    required this.tray,
    required this.numbers,
    required this.light,
    required this.dark,
    required this.dice,
    this.grain = false,
    this.glow,
    this.inlay,
    this.table,
  });

  /// The theme id (`data.theme`), e.g. `walnut`.
  final String id;
  final List<Color> frame;
  final List<Color> field;

  /// Odd points (1, 3, 5 …).
  final List<Color> pointA;

  /// Even points.
  final List<Color> pointB;
  final List<Color> tray;
  final Color numbers;

  /// Wood-grain overlay on frame and fields.
  final bool grain;

  /// Radial glow rising from the bottom of each field (Baku Night).
  final Color? glow;

  /// 6 pt band around each field: 2–3 colours = gradient, 4+ = xatam
  /// stripes.
  final List<Color>? inlay;

  /// Light (White) and dark (Black) checker materials.
  final CheckerMaterial light;
  final CheckerMaterial dark;
  final DiceLook dice;

  /// Table background behind the board (outer → … radial stops).
  final List<Color>? table;

  /// Classic Walnut: the built-in default, identical to the pre-Phase-4
  /// painter constants and to the catalog's `board.walnut`.
  static const walnut = BoardLook(
    id: 'walnut',
    frame: [Color(0xFF6E4224), Color(0xFF4B2B16), Color(0xFF5D3720)],
    field: [Color(0xFFC49159), Color(0xFFA87745)],
    pointA: [Color(0xFF2E1C10), Color(0xFF1A0E07)],
    pointB: [Color(0xFFF2E7CF), Color(0xFFD5C29D)],
    tray: [Color(0xFF2A170C), Color(0xFF1C0F07)],
    numbers: Color(0x8CF3EBDD),
    grain: true,
    light: CheckerMaterial(
      stops: [
        Color(0xFFFFFBF2),
        Color(0xFFEFE4CF),
        Color(0xFFD4C3A2),
        Color(0xFFB3A07C),
      ],
      groove: Color(0x2B6E5532),
    ),
    dark: CheckerMaterial(
      stops: [
        Color(0xFF5D564F),
        Color(0xFF2B2724),
        Color(0xFF151312),
        Color(0xFF0A0909),
      ],
      groove: Color(0x0EFFFFFF),
    ),
    dice: DiceLook(
      face: [Color(0xFFFFFAF0), Color(0xFFE4D6B8)],
      pip: [Color(0xFF3A2A1E), Color(0xFF0D0806)],
    ),
    table: [Color(0xFF3B2819), Color(0xFF1B120C)],
  );

  /// Parses `data.look`; missing or malformed parts fall back to
  /// [walnut] so a partial catalog entry still renders.
  static BoardLook fromJson(Object? json, {String id = 'walnut'}) {
    if (json is! Map) return walnut;
    List<Color> list(String key, List<Color> fallback) =>
        parseColors(json[key]) ?? fallback;
    return BoardLook(
      id: id,
      frame: list('frame', walnut.frame),
      field: list('field', walnut.field),
      pointA: list('pointA', walnut.pointA),
      pointB: list('pointB', walnut.pointB),
      tray: list('tray', walnut.tray),
      numbers: parseColor(json['numbers']) ?? walnut.numbers,
      grain: json['grain'] == true,
      glow: parseColor(json['glow']),
      inlay: parseColors(json['inlay']),
      light: CheckerMaterial._parse(json['light']) ?? walnut.light,
      dark: CheckerMaterial._parse(json['dark']) ?? walnut.dark,
      dice: DiceLook._parse(json['dice']) ?? walnut.dice,
      table: parseColors(json['table']),
    );
  }

  /// Flat swatch colours for small tiles (field, point).
  Color get fieldSwatch => field.last;
  Color get pointSwatch => pointA.first;

  @override
  bool operator ==(Object other) =>
      other is BoardLook &&
      other.id == id &&
      _listEq(other.frame, frame) &&
      _listEq(other.field, field) &&
      _listEq(other.pointA, pointA) &&
      _listEq(other.pointB, pointB) &&
      _listEq(other.tray, tray) &&
      other.numbers == numbers &&
      other.grain == grain &&
      other.glow == glow &&
      _listEq(other.inlay, inlay) &&
      other.light == light &&
      other.dark == dark &&
      other.dice == dice &&
      _listEq(other.table, table);

  @override
  int get hashCode => Object.hash(
    id,
    Object.hashAll(frame),
    Object.hashAll(field),
    Object.hashAll(pointA),
    Object.hashAll(pointB),
    numbers,
    light,
    dark,
    dice,
  );
}

/// `#AARRGGBB` or `#RRGGBB` → [Color]; null when malformed.
Color? parseColor(Object? value) {
  if (value is! String) return null;
  var hex = value.startsWith('#') ? value.substring(1) : value;
  if (hex.length == 6) hex = 'FF$hex';
  if (hex.length != 8) return null;
  final v = int.tryParse(hex, radix: 16);
  return v == null ? null : Color(v);
}

/// A list of hex colours; a single colour is doubled into a flat
/// gradient. Null when empty or any entry is malformed.
List<Color>? parseColors(Object? value) {
  if (value is! List || value.isEmpty) return null;
  final out = <Color>[];
  for (final v in value) {
    final c = parseColor(v);
    if (c == null) return null;
    out.add(c);
  }
  return out.length == 1 ? [out[0], out[0]] : out;
}

/// Evenly spaced gradient stops for [n] colours.
List<double> evenStops(int n) =>
    n < 2 ? const [0, 1] : [for (var i = 0; i < n; i++) i / (n - 1)];

bool _listEq(List<Color>? a, List<Color>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null || a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
