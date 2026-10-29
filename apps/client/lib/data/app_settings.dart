import 'dart:ui';

import 'package:nard_core/nard_core.dart';

/// Typed view of the key/value settings table.
class AppSettings {
  const AppSettings({
    this.locale,
    this.preferredVariant,
    this.onboardingDone = false,
    this.sound = true,
    this.haptics = true,
    this.fastDice = false,
    this.autoConfirm = false,
    this.showPipCount = true,
    this.colorBlind = false,
    this.largePips = false,
  });

  /// Chosen app language; null until picked on first launch (9.2).
  final Locale? locale;

  /// Answer to "which nard do you play?" (9.3).
  final Variant? preferredVariant;
  final bool onboardingDone;
  final bool sound;
  final bool haptics;

  /// Dice resolve in 300 ms instead of 800 ms.
  final bool fastDice;

  /// Confirm a turn automatically when the last die is used.
  final bool autoConfirm;
  final bool showPipCount;

  /// Adds a ring to light checkers and a dot to dark ones.
  final bool colorBlind;
  final bool largePips;

  static const supportedLanguages = ['az', 'en', 'ru', 'tr'];

  static AppSettings fromMap(Map<String, String> map) {
    bool flag(String key, bool fallback) =>
        map[key] == null ? fallback : map[key] == 'true';
    final lang = map['locale'];
    final variant = map['preferredVariant'];
    return AppSettings(
      locale: supportedLanguages.contains(lang) ? Locale(lang!) : null,
      preferredVariant: Variant.values.asNameMap()[variant],
      onboardingDone: flag('onboardingDone', false),
      sound: flag('sound', true),
      haptics: flag('haptics', true),
      fastDice: flag('fastDice', false),
      autoConfirm: flag('autoConfirm', false),
      showPipCount: flag('showPipCount', true),
      colorBlind: flag('colorBlind', false),
      largePips: flag('largePips', false),
    );
  }

  Map<String, String> toMap() => {
    if (locale != null) 'locale': locale!.languageCode,
    if (preferredVariant != null) 'preferredVariant': preferredVariant!.name,
    'onboardingDone': '$onboardingDone',
    'sound': '$sound',
    'haptics': '$haptics',
    'fastDice': '$fastDice',
    'autoConfirm': '$autoConfirm',
    'showPipCount': '$showPipCount',
    'colorBlind': '$colorBlind',
    'largePips': '$largePips',
  };

  AppSettings copyWith({
    Locale? locale,
    Variant? preferredVariant,
    bool? onboardingDone,
    bool? sound,
    bool? haptics,
    bool? fastDice,
    bool? autoConfirm,
    bool? showPipCount,
    bool? colorBlind,
    bool? largePips,
  }) => AppSettings(
    locale: locale ?? this.locale,
    preferredVariant: preferredVariant ?? this.preferredVariant,
    onboardingDone: onboardingDone ?? this.onboardingDone,
    sound: sound ?? this.sound,
    haptics: haptics ?? this.haptics,
    fastDice: fastDice ?? this.fastDice,
    autoConfirm: autoConfirm ?? this.autoConfirm,
    showPipCount: showPipCount ?? this.showPipCount,
    colorBlind: colorBlind ?? this.colorBlind,
    largePips: largePips ?? this.largePips,
  );
}
