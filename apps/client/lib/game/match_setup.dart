import 'package:nard_ai/nard_ai.dart';
import 'package:nard_core/nard_core.dart';

/// Who sits opposite the local player.
enum OpponentKind { computer, passAndPlay }

/// Everything chosen on the setup screens before a match starts.
class MatchSetup {
  const MatchSetup({
    required this.variant,
    required this.opponent,
    this.level = BotLevel.easy,
    this.matchLength = 1,
    this.whiteName = '',
    this.blackName = '',
    this.cube = true,
    this.hideBetweenTurns = true,
    this.flipBoard = true,
    this.allowUndo = false,
  });

  final Variant variant;
  final OpponentKind opponent;

  /// Bot strength (computer games only).
  final BotLevel level;

  /// Points needed to win the match; 1 is a single game.
  final int matchLength;

  /// Display names; empty means "use the localized default".
  final String whiteName;
  final String blackName;

  /// Whether the doubling cube is used (Short Nard only).
  final bool cube;

  /// Pass & play: show the hand-over screen between turns (18.2).
  final bool hideBetweenTurns;

  /// Pass & play: turn the board toward the player to move.
  final bool flipBoard;

  /// Pass & play: the previous player may take back the turn on the
  /// hand-over screen.
  final bool allowUndo;

  /// The local player always plays White against the computer.
  static const Side humanSide = Side.white;

  bool get vsComputer => opponent == OpponentKind.computer;

  /// Whether [side] is moved by the bot.
  bool isBot(Side side) => vsComputer && side != humanSide;

  Map<String, Object?> toJson() => {
    'variant': variant.name,
    'opponent': opponent.name,
    'level': level.name,
    'matchLength': matchLength,
    'whiteName': whiteName,
    'blackName': blackName,
    'cube': cube,
    'hideBetweenTurns': hideBetweenTurns,
    'flipBoard': flipBoard,
    'allowUndo': allowUndo,
  };

  MatchSetup copyWith({
    Variant? variant,
    OpponentKind? opponent,
    BotLevel? level,
    int? matchLength,
    String? whiteName,
    String? blackName,
    bool? cube,
    bool? hideBetweenTurns,
    bool? flipBoard,
    bool? allowUndo,
  }) => MatchSetup(
    variant: variant ?? this.variant,
    opponent: opponent ?? this.opponent,
    level: level ?? this.level,
    matchLength: matchLength ?? this.matchLength,
    whiteName: whiteName ?? this.whiteName,
    blackName: blackName ?? this.blackName,
    cube: cube ?? this.cube,
    hideBetweenTurns: hideBetweenTurns ?? this.hideBetweenTurns,
    flipBoard: flipBoard ?? this.flipBoard,
    allowUndo: allowUndo ?? this.allowUndo,
  );

  static MatchSetup fromJson(Map<String, Object?> json) => MatchSetup(
    variant: Variant.values.byName(json['variant']! as String),
    opponent: OpponentKind.values.byName(json['opponent']! as String),
    level: BotLevel.values.byName(json['level']! as String),
    matchLength: json['matchLength']! as int,
    whiteName: json['whiteName']! as String,
    blackName: json['blackName']! as String,
    cube: json['cube'] as bool? ?? true,
    hideBetweenTurns: json['hideBetweenTurns'] as bool? ?? true,
    flipBoard: json['flipBoard'] as bool? ?? true,
    allowUndo: json['allowUndo'] as bool? ?? false,
  );
}
