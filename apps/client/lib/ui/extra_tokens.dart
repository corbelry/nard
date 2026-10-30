import 'dart:math';

import 'package:flutter/material.dart';

import '../online/rank.dart';
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

  // ---- Online screens (online.md §0) -----------------------------------

  /// Sign-in (9.4 / 17.1) background, same family as the splash.
  Gradient get authBg => const RadialGradient(
    center: Alignment(0, -.4),
    radius: .9,
    colors: [Color(0xFF4A321F), Color(0xFF2B1D14), Color(0xFF120C08)],
    stops: [0, .6, 1],
  );

  /// Searching opponent (2.4) background.
  Gradient get searchBg => const RadialGradient(
    center: Alignment(0, -.16),
    radius: .95,
    colors: [Color(0xFF4A321F), Color(0xFF2B1D14), Color(0xFF1B120C)],
    stops: [0, .55, 1],
  );

  /// VS (2.5): garnet top = opponent, teal bottom = me; [bot] greys the top.
  Gradient vsBg({required bool bot}) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      bot ? const Color(0xFF2A2A30) : const Color(0xFF3A1A1C),
      const Color(0xFF2B1D14),
      const Color(0xFF1C2A2C),
    ],
    stops: const [0, .48, 1],
  );

  /// Profile (8.1) background glow.
  Gradient get profileBg => RadialGradient(
    center: const Alignment(0, -.72),
    radius: .9,
    colors: [accent.withValues(alpha: .22), const Color(0xFF1B120C)],
    stops: const [0, .7],
  );

  /// Brass avatar ring (conic from 210°).
  Gradient get brassRing => const SweepGradient(
    startAngle: 210 * pi / 180,
    endAngle: 210 * pi / 180 + 2 * pi,
    colors: [
      Color(0xFF8A6A22),
      Color(0xFFE8C468),
      Color(0xFFA07C30),
      Color(0xFFE8C468),
      Color(0xFF8A6A22),
    ],
  );

  /// Avatar fills (150°): me (teal), opponent (garnet), bot (grey).
  List<Color> get avatarMe => const [Color(0xFF2F4A52), Color(0xFF162428)];
  List<Color> get avatarOpponent => const [
    Color(0xFF5B2A2A),
    Color(0xFF2A1414),
  ];
  List<Color> get avatarBot => const [Color(0xFF3A3A44), Color(0xFF1D1D22)];

  /// Light and dark stop of a rank tier (`tokens/colors.css`).
  (Color, Color) tierStops(Tier tier) => switch (tier) {
    Tier.bronze => (const Color(0xFFE0A77A), const Color(0xFF8A5330)),
    Tier.silver => (const Color(0xFFEEF0F2), const Color(0xFF8D939B)),
    Tier.gold => (const Color(0xFFF4DC8E), const Color(0xFFB0852C)),
    Tier.platinum => (const Color(0xFFD6F1EE), const Color(0xFF6AA9A5)),
    Tier.diamond => (const Color(0xFFBFE0FF), const Color(0xFF4F7FD1)),
    Tier.master => (const Color(0xFFE2C6FF), const Color(0xFF7D4FC4)),
    Tier.grandmaster => (const Color(0xFFE8C468), const Color(0xFF9E1B32)),
  };

  /// Tier fill (160°; grandmaster is a garnet/brass conic).
  Gradient tierFill(Tier tier) {
    if (tier == Tier.grandmaster) {
      return const SweepGradient(
        startAngle: 200 * pi / 180,
        endAngle: 200 * pi / 180 + 2 * pi,
        colors: [
          Color(0xFF9E1B32),
          Color(0xFFE8C468),
          Color(0xFF9E1B32),
          Color(0xFFE8C468),
          Color(0xFF9E1B32),
        ],
      );
    }
    final (light, dark) = tierStops(tier);
    return LinearGradient(
      begin: const Alignment(-.34, -.94),
      end: const Alignment(.34, .94),
      colors: [light, dark],
    );
  }

  /// Inner hexagon of a rank badge.
  Color get rankInner => const Color(0x8C140C08);

  /// Code / value boxes (one step darker than [surfaceSunken]).
  Color get codeBox => const Color(0x4D000000);

  /// Sign-in Apple button: ivory fill, charcoal label.
  Color get appleFill => NardPalette.ivory100;
  Color get appleText => NardPalette.charcoal900;

  // ---- Store & progression (store.md §0) -------------------------------

  /// Coin glyph (radial at 35% 30%).
  Gradient get coinFill => const RadialGradient(
    center: Alignment(-.3, -.4),
    radius: .8,
    colors: [Color(0xFFFBE7A6), Color(0xFFC9A24A), Color(0xFF8A6A22)],
    stops: [0, .6, 1],
  );

  /// Yaqut glyph (linear 135°, drawn as a rotated square).
  Gradient get gemFill => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9FB0), Color(0xFF9E1B32)],
  );

  /// Currency pill fill.
  Color get pillFill => text.withValues(alpha: .06);

  /// Level badge fill (garnet primary ends).
  Gradient get levelBadgeFill => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB52A45), Color(0xFF86152A)],
  );

  /// 12.3 level-up background.
  Gradient get levelUpBg => const RadialGradient(
    center: Alignment(0, -.24),
    radius: .9,
    colors: [Color(0xFF5A2430), Color(0xFF24161B), Color(0xFF120C0E)],
    stops: [0, .6, 1],
  );

  /// 3.1 Locker preview glow.
  Gradient get lockerGlow => RadialGradient(
    center: const Alignment(0, .1),
    radius: .6,
    colors: [accent.withValues(alpha: .14), accent.withValues(alpha: 0)],
    stops: const [0, .7],
  );

  /// 7.5 purchase success background in the item's [rarity] colour.
  Gradient successBg(Color rarity) => RadialGradient(
    center: const Alignment(0, -.24),
    radius: .7,
    colors: [rarity.withValues(alpha: .3), const Color(0xFF1B120C)],
    stops: const [0, .7],
  );

  /// 3.2 item sheet: rarity tint fading into the raised surface.
  Gradient itemSheetFill(Color rarity) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [rarity.withValues(alpha: .22), surfaceRaised],
    stops: const [0, .45],
  );

  /// Featured / legendary card (160°).
  Gradient featuredFill(Color rarity) => LinearGradient(
    begin: const Alignment(-.34, -.94),
    end: const Alignment(.34, .94),
    colors: [rarity.withValues(alpha: .3), surfaceRaised],
    stops: const [0, .6],
  );

  /// Achievement hex fill without a tier (garnet).
  Gradient get garnetHexFill => const LinearGradient(
    begin: Alignment(-.34, -.94),
    end: Alignment(.34, .94),
    colors: [Color(0xFFC52F4A), Color(0xFF6E0F20)],
  );

  /// Discount / bonus tag.
  Color get tagFill => success;
  Color get tagText => NardPalette.ivory100;

  /// Lattice lines of the level-up screen.
  Color get levelUpLattice => accent.withValues(alpha: .08);

  // ---- Social & clans (social.md §0) -----------------------------------

  /// 2.7 emote wheel disc: walnut hub, raised ring.
  Gradient get emoteWheelDisc => const RadialGradient(
    colors: [Color(0xFF2B1D14), Color(0xFF2B1D14), Color(0xF534251A)],
    stops: [0, .32, .325],
  );
  List<BoxShadow> get emoteWheelShadow => const [
    BoxShadow(color: Color(0x80000000), offset: Offset(0, 20), blurRadius: 50),
  ];

  /// 6.3 private room background.
  Gradient get roomBg => const RadialGradient(
    center: Alignment(0, -.3),
    radius: .9,
    colors: [Color(0xFF4A321F), Color(0xFF1B120C)],
    stops: [0, .7],
  );

  /// 5.2 clan profile background, tinted with the clan's colour.
  Gradient clanProfileBg(Color tint) => RadialGradient(
    center: const Alignment(0, -.64),
    radius: .9,
    colors: [
      tint.withValues(alpha: .35),
      const Color(0xFF2B1D14),
      const Color(0xFF1B120C),
    ],
    stops: const [0, .6, 1],
  );

  /// 5.6 war background: my clan colour left, theirs right.
  Gradient clanWarBg(Color mine, Color theirs) => LinearGradient(
    colors: [
      mine.withValues(alpha: .3),
      mine.withValues(alpha: 0),
      theirs.withValues(alpha: 0),
      theirs.withValues(alpha: .35),
    ],
    stops: const [0, .45, .55, 1],
  );

  /// 5.7 leaderboard background.
  Gradient get clanLeaderboardBg => RadialGradient(
    center: const Alignment(0, -.6),
    radius: .9,
    colors: [accent.withValues(alpha: .22), const Color(0xFF1B120C)],
    stops: const [0, .7],
  );

  /// 5.3 emblem preview glow.
  Gradient get emblemGlow => RadialGradient(
    radius: .6,
    colors: [accent.withValues(alpha: .14), accent.withValues(alpha: 0)],
  );

  /// Presence dots: online, in game, offline.
  Color get presenceOnline => successText;
  Color get presenceInGame => accentHi;
  Color get presenceOffline => text.withValues(alpha: .3);

  /// Chat bubbles (5.4): others / mine.
  Color get bubbleOther => text.withValues(alpha: .08);
  Color get bubbleMine => accent;

  /// 5.4 clan chest glyph.
  Gradient get chestFill => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFC9A24A), Color(0xFF6E4224)],
  );

  /// Spectator / war "live" pill.
  Color get liveFill => dangerText.withValues(alpha: .16);
}

/// Rarity colour of an item (`tokens/colors.css`); tournament items use
/// brass (no rarity colour in the design, store.md §12.34).
Color rarityColor(String rarity) => switch (rarity) {
  'rare' => NardPalette.rarityRare,
  'epic' => NardPalette.rarityEpic,
  'legendary' => NardPalette.rarityLegendary,
  'seasonal' => NardPalette.raritySeasonal,
  'tournament' => NardPalette.brass300,
  _ => NardPalette.rarityCommon,
};
