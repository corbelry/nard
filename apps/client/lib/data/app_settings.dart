import 'dart:ui';

import 'package:nard_core/nard_core.dart';

enum AnimationSpeed { slow, normal, fast }

/// Typed view of the key/value settings table.
class AppSettings {
  const AppSettings({
    this.locale,
    this.preferredVariant,
    this.onboardingDone = false,
    this.lastSetupJson,
    this.sound = true,
    this.haptics = true,
    this.confirmMoves = true,
    this.autoRoll = false,
    this.showLegalMoves = true,
    this.showPipCount = true,
    this.animationSpeed = AnimationSpeed.normal,
    this.colorBlind = false,
    this.largePips = false,
    this.reduceMotion = false,
  });

  /// Chosen app language; null until picked on first launch (9.2).
  final Locale? locale;

  /// Answer to "which nard do you play?" (9.3).
  final Variant? preferredVariant;
  final bool onboardingDone;

  /// Last vs-computer setup (`MatchSetup.toJson()` encoded), reused by
  /// the home "Oyna" button.
  final String? lastSetupJson;

  final bool sound;
  final bool haptics;

  /// Turn off to confirm a turn automatically when the last die is used.
  final bool confirmMoves;
  final bool autoRoll;
  final bool showLegalMoves;
  final bool showPipCount;
  final AnimationSpeed animationSpeed;

  /// Adds a ring to light checkers and a dot to dark ones.
  final bool colorBlind;
  final bool largePips;
  final bool reduceMotion;

  static const supportedLanguages = ['az', 'en', 'ru', 'tr'];

  static AppSettings fromMap(Map<String, String> map) {
    bool flag(String key, bool fallback) =>
        map[key] == null ? fallback : map[key] == 'true';
    final lang = map['locale'];
    return AppSettings(
      locale: supportedLanguages.contains(lang) ? Locale(lang!) : null,
      preferredVariant: Variant.values.asNameMap()[map['preferredVariant']],
      onboardingDone: flag('onboardingDone', false),
      lastSetupJson: map['lastSetup'],
      sound: flag('sound', true),
      haptics: flag('haptics', true),
      confirmMoves: flag('confirmMoves', true),
      autoRoll: flag('autoRoll', false),
      showLegalMoves: flag('showLegalMoves', true),
      showPipCount: flag('showPipCount', true),
      animationSpeed:
          AnimationSpeed.values.asNameMap()[map['animationSpeed']] ??
          AnimationSpeed.normal,
      colorBlind: flag('colorBlind', false),
      largePips: flag('largePips', false),
      reduceMotion: flag('reduceMotion', false),
    );
  }

  Map<String, String> toMap() => {
    if (locale != null) 'locale': locale!.languageCode,
    if (preferredVariant != null) 'preferredVariant': preferredVariant!.name,
    'onboardingDone': '$onboardingDone',
    if (lastSetupJson != null) 'lastSetup': lastSetupJson!,
    'sound': '$sound',
    'haptics': '$haptics',
    'confirmMoves': '$confirmMoves',
    'autoRoll': '$autoRoll',
    'showLegalMoves': '$showLegalMoves',
    'showPipCount': '$showPipCount',
    'animationSpeed': animationSpeed.name,
    'colorBlind': '$colorBlind',
    'largePips': '$largePips',
    'reduceMotion': '$reduceMotion',
  };

  AppSettings copyWith({
    Locale? locale,
    Variant? preferredVariant,
    bool? onboardingDone,
    String? lastSetupJson,
    bool? sound,
    bool? haptics,
    bool? confirmMoves,
    bool? autoRoll,
    bool? showLegalMoves,
    bool? showPipCount,
    AnimationSpeed? animationSpeed,
    bool? colorBlind,
    bool? largePips,
    bool? reduceMotion,
  }) => AppSettings(
    locale: locale ?? this.locale,
    preferredVariant: preferredVariant ?? this.preferredVariant,
    onboardingDone: onboardingDone ?? this.onboardingDone,
    lastSetupJson: lastSetupJson ?? this.lastSetupJson,
    sound: sound ?? this.sound,
    haptics: haptics ?? this.haptics,
    confirmMoves: confirmMoves ?? this.confirmMoves,
    autoRoll: autoRoll ?? this.autoRoll,
    showLegalMoves: showLegalMoves ?? this.showLegalMoves,
    showPipCount: showPipCount ?? this.showPipCount,
    animationSpeed: animationSpeed ?? this.animationSpeed,
    colorBlind: colorBlind ?? this.colorBlind,
    largePips: largePips ?? this.largePips,
    reduceMotion: reduceMotion ?? this.reduceMotion,
  );
}
