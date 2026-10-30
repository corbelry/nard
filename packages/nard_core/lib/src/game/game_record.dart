import '../rules/long_nard.dart';
import '../rules/rule_set.dart';
import '../rules/short_nard.dart';
import 'game_action.dart';
import 'game_state.dart';

/// Rule set for a [Variant] with default options.
RuleSet rulesFor(Variant variant) => switch (variant) {
  Variant.shortNard => const ShortNardRules(),
  Variant.longNard => const LongNardRules(),
};

/// Complete, replayable log of one game.
class GameRecord {
  GameRecord({
    required this.variant,
    this.config = const GameConfig(),
    List<GameAction> actions = const [],
  }) : actions = List.unmodifiable(actions);

  final Variant variant;
  final GameConfig config;
  final List<GameAction> actions;

  GameRecord add(GameAction action) => GameRecord(
    variant: variant,
    config: config,
    actions: [...actions, action],
  );

  /// Replays every action, validating each one.
  GameState replay([RuleSet? rules]) {
    var state = GameState.newGame(rules ?? rulesFor(variant), config: config);
    for (final action in actions) {
      state = state.apply(action);
    }
    return state;
  }

  Map<String, Object?> toJson() => {
    'version': 1,
    'variant': variant.name,
    'config': {
      'cube': config.cubeEnabled,
      'jacoby': config.jacoby,
      'maxCube': config.maxCubeValue,
    },
    'actions': [for (final a in actions) a.toJson()],
  };

  static GameRecord fromJson(Map<String, Object?> json) {
    if (json['version'] != 1) {
      throw FormatException('Unsupported record version ${json['version']}');
    }
    final config = json['config']! as Map<String, Object?>;
    return GameRecord(
      variant: Variant.values.byName(json['variant']! as String),
      config: GameConfig(
        cubeEnabled: config['cube']! as bool,
        jacoby: config['jacoby']! as bool,
        maxCubeValue: config['maxCube']! as int,
      ),
      actions: [
        for (final a in (json['actions']! as List).cast<Map<String, Object?>>())
          GameAction.fromJson(a),
      ],
    );
  }
}
