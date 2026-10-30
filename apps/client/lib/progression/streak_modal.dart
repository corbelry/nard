import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../cosmetics/catalog.dart';
import '../cosmetics/cosmetics_text.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/buttons.dart';
import '../ui/commerce.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import 'progress_models.dart';

/// 12.2 Login streak modal over Home, once per day after the check-in
/// credited [coins] for streak day [streakDay]. The coins are already
/// credited by the server; the button only closes the card.
Future<void> showStreakModal(
  BuildContext context, {
  required int streakDay,
  required int coins,
  required List<int> rewards,
}) {
  final c = context.nard;
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: c.scrim,
    transitionDuration: NardMotion.sheetIn,
    pageBuilder:
        (ctx, _, _) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Material(
              type: MaterialType.transparency,
              child: StreakCardModal(
                streakDay: streakDay,
                coins: coins,
                rewards: rewards,
                onClaim: () => Navigator.of(ctx).pop(),
              ),
            ),
          ),
        ),
    transitionBuilder:
        (_, anim, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: NardMotion.standard),
          child: ScaleTransition(
            scale: Tween(begin: .96, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: NardMotion.standard),
            ),
            child: child,
          ),
        ),
  );
}

class StreakCardModal extends StatelessWidget {
  const StreakCardModal({
    super.key,
    required this.streakDay,
    required this.coins,
    required this.rewards,
    required this.onClaim,
  });

  final int streakDay;
  final int coins;
  final List<int> rewards;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final today = Streak.cycleDay(streakDay);

    Widget tile(int day) {
      final claimed = day < today;
      final current = day == today;
      final reward = rewards.isEmpty ? 0 : rewards[(day - 1) % rewards.length];
      return Opacity(
        opacity: claimed ? .6 : 1,
        child: Container(
          height: 84,
          decoration: BoxDecoration(
            color:
                current
                    ? c.accent.withValues(alpha: .18)
                    : c.text.withValues(alpha: .04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: current ? c.accent : c.lineSoft,
              width: current ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                streakDayLabel(l, day),
                style: NardType.micro.copyWith(
                  fontWeight: FontWeight.w600,
                  color: c.text.withValues(alpha: .6),
                ),
              ),
              const SizedBox(height: 6),
              if (claimed)
                Icon(LucideIcons.check, size: 20, color: c.successText)
              else
                const CurrencyIcon(Currency.coins, size: 20),
              const SizedBox(height: 6),
              Text(
                l.missionReward(reward),
                style: NardType.bodyS.copyWith(
                  fontWeight: FontWeight.w700,
                  color: c.text,
                  fontFeatures: tabular,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget row(List<int> days, {bool lastWide = false}) => Row(
      children: [
        for (var i = 0; i < days.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            flex: lastWide && i == days.length - 1 ? 2 : 1,
            child: tile(days[i]),
          ),
        ],
      ],
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: BorderRadius.circular(NardRadius.xl),
        border: Border.all(color: c.accent.withValues(alpha: .4)),
        boxShadow: c.elevation3,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Overline(l.streakOverline, color: c.accent, spacing: .96),
          const SizedBox(height: 18),
          Text(
            streakDayLabel(l, today),
            textAlign: TextAlign.center,
            style: NardType.displayL.copyWith(color: c.text),
          ),
          const SizedBox(height: 10),
          Text(
            l.streakBody,
            textAlign: TextAlign.center,
            style: NardType.body.copyWith(
              fontSize: 14,
              color: c.text.withValues(alpha: .7),
            ),
          ),
          const SizedBox(height: 18),
          row([1, 2, 3, 4]),
          const SizedBox(height: 8),
          row([5, 6, 7], lastWide: true),
          const SizedBox(height: 18),
          NardButton(label: l.streakClaim(coins), onPressed: onClaim),
          const SizedBox(height: 18),
          Text(
            l.streakResetNote,
            textAlign: TextAlign.center,
            style: NardType.caption.copyWith(
              fontWeight: FontWeight.w400,
              height: 17 / 12,
              color: c.text.withValues(alpha: .55),
            ),
          ),
        ],
      ),
    );
  }
}
