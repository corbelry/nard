import '../data/app_settings.dart';
import '../theme/nard_tokens.dart';

/// How long a dice throw takes on the board (zero: no animation).
Duration diceRollTime(AppSettings s) {
  if (s.reduceMotion) return Duration.zero;
  return switch (s.animationSpeed) {
    AnimationSpeed.fast => NardMotion.diceFast,
    AnimationSpeed.normal => NardMotion.dice,
    AnimationSpeed.slow => const Duration(milliseconds: 1100),
  };
}
