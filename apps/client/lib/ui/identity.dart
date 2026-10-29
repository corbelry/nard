import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../online/rank.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import 'extra_tokens.dart';

enum AvatarTone { me, opponent, bot }

/// Round avatar with the brass ring and initials (online.md §0.1). Sizes
/// 44/46 cards, 48 home, 72 profile, 110 VS, 120 searching.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.name,
    required this.size,
    this.tone = AvatarTone.me,
    this.glow = false,
    this.haloBlur = 16,
  });

  final String name;
  final double size;
  final AvatarTone tone;

  /// Active / searching glow.
  final bool glow;
  final double haloBlur;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final bot = tone == AvatarTone.bot;
    final fill = switch (tone) {
      AvatarTone.me => c.avatarMe,
      AvatarTone.opponent => c.avatarOpponent,
      AvatarTone.bot => c.avatarBot,
    };
    final initials =
        name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase();
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size >= 72 ? 4 : 3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: bot ? null : c.brassRing,
        color: bot ? c.text.withValues(alpha: .2) : null,
        boxShadow:
            glow
                ? [
                  BoxShadow(
                    color: c.accent.withValues(alpha: .2),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: c.accent.withValues(alpha: .4),
                    blurRadius: haloBlur,
                  ),
                ]
                : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: const Alignment(-.5, -.87),
            end: const Alignment(.5, .87),
            colors: fill,
          ),
        ),
        alignment: Alignment.center,
        child:
            bot
                ? Icon(LucideIcons.bot, size: size * .4, color: c.text)
                : Text(
                  initials,
                  style: NardType.title.copyWith(
                    fontSize: size * .37,
                    height: 1,
                    color: c.text,
                  ),
                ),
      ),
    );
  }
}

class _HexClipper extends CustomClipper<Path> {
  const _HexClipper();

  @override
  Path getClip(Size s) =>
      Path()
        ..moveTo(s.width / 2, 0)
        ..lineTo(s.width, s.height * .25)
        ..lineTo(s.width, s.height * .75)
        ..lineTo(s.width / 2, s.height)
        ..lineTo(0, s.height * .75)
        ..lineTo(0, s.height * .25)
        ..close();

  @override
  bool shouldReclip(_HexClipper oldClipper) => false;
}

/// Hexagonal rank badge (`RankBadge.jsx`): solid below 24 px, with the
/// sub-level numeral inside from 24 px up.
class RankBadge extends StatelessWidget {
  const RankBadge({super.key, required this.tier, this.sub, this.size = 14});

  final Tier tier;
  final int? sub;

  /// Width; height is size × 52 / 46.
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final h = size * 52 / 46;
    final hex = ClipPath(
      clipper: const _HexClipper(),
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: c.tierFill(tier)),
        child: SizedBox(width: size, height: h),
      ),
    );
    if (size < 24 || sub == null) return hex;
    return SizedBox(
      width: size,
      height: h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          hex,
          ClipPath(
            clipper: const _HexClipper(),
            child: Container(
              width: size * .74,
              height: h * .75,
              color: c.rankInner,
              alignment: Alignment.center,
              child: Text(
                subNumeral(sub!),
                style: NardType.title.copyWith(
                  fontSize: size * .3,
                  height: 1,
                  color: c.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simplified flag swatch (only the four app languages' countries are
/// drawn; other countries get a neutral swatch). Flag colours are data,
/// not theme values.
class FlagSwatch extends StatelessWidget {
  const FlagSwatch({
    super.key,
    required this.country,
    this.width = 18,
    this.height = 12,
  });

  /// ISO 3166-1 alpha-2.
  final String? country;
  final double width;
  final double height;

  static const _az = [Color(0xFF00B5E2), Color(0xFFEF3340), Color(0xFF509E2F)];
  static const _ru = [Color(0xFFFFFFFF), Color(0xFF0039A6), Color(0xFFD52B1E)];
  static const _trRed = Color(0xFFE30A17);
  static const _gbBlue = Color(0xFF012169);
  static const _gbRed = Color(0xFFC8102E);
  static const _white = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final code = country?.toUpperCase();
    if (code == null || code.isEmpty) return const SizedBox.shrink();
    final c = context.nard;
    Widget stripes(List<Color> colors) => Column(
      children: [
        for (final col in colors) Expanded(child: ColoredBox(color: col)),
      ],
    );
    final Widget body = switch (code) {
      'AZ' => stripes(_az),
      'RU' => stripes(_ru),
      'TR' => ColoredBox(
        color: _trRed,
        child: Center(
          child: Container(
            width: height * .45,
            height: height * .45,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _white,
            ),
          ),
        ),
      ),
      'GB' || 'US' => ColoredBox(
        color: _gbBlue,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(height: height * .3, color: _white),
            Container(width: height * .3, color: _white),
            Container(height: height * .16, color: _gbRed),
            Container(width: height * .16, color: _gbRed),
          ],
        ),
      ),
      _ => ColoredBox(color: c.text.withValues(alpha: .2)),
    };
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: c.codeBox),
      ),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
      child: body,
    );
  }
}

/// "BOT" label: card size (h 20, icon) or VS size (h 24, no icon).
class BotBadge extends StatelessWidget {
  const BotBadge({super.key, required this.label, this.large = false});

  final String label;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Container(
      height: large ? 24 : 20,
      padding: EdgeInsets.symmetric(horizontal: large ? 10 : 7),
      decoration: BoxDecoration(
        color: NardPalette.ivory100,
        borderRadius: BorderRadius.circular(large ? 6 : 5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!large) ...[
            Icon(LucideIcons.bot, size: 11, color: c.onAccent),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: NardType.micro.copyWith(
              fontSize: large ? 12 : 11,
              height: 1,
              fontWeight: FontWeight.w700,
              letterSpacing: large ? .96 : .66,
              color: c.onAccent,
            ),
          ),
        ],
      ),
    );
  }
}
