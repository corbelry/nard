import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nard_ai/nard_ai.dart';
import 'package:nard_core/nard_core.dart';

import '../game/match_setup.dart';
import 'providers.dart';

/// The vs-computer setup being edited on 2.2 / 2.3, seeded from the last
/// one played (or the onboarding variant).
class SetupDraft extends Notifier<MatchSetup> {
  @override
  MatchSetup build() {
    final settings = ref.watch(currentSettingsProvider);
    final json = settings.lastSetupJson;
    if (json != null) {
      try {
        return MatchSetup.fromJson(jsonDecode(json) as Map<String, Object?>);
      } on Object {
        // Fall through to the defaults.
      }
    }
    return MatchSetup(
      variant: settings.preferredVariant ?? Variant.shortNard,
      opponent: OpponentKind.computer,
      level: BotLevel.medium,
    );
  }

  void edit(MatchSetup Function(MatchSetup) change) => state = change(state);

  /// Remembers [setup] as the home screen's quick game.
  Future<void> remember(MatchSetup setup) => ref
      .read(settingsProvider.notifier)
      .change((s) => s.copyWith(lastSetupJson: jsonEncode(setup.toJson())));
}

final setupDraftProvider = NotifierProvider<SetupDraft, MatchSetup>(
  SetupDraft.new,
);
