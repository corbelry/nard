import 'package:nard_ai/nard_ai.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';

/// Who sits opposite the local player.
enum OpponentKind { computer, passAndPlay, online }

/// Seats and clock of an online match (from `match.found`).
class OnlineMatch {
  const OnlineMatch({
    required this.matchId,
    required this.mode,
    required this.white,
    required this.black,
    required this.clock,
  });

  final String matchId;
  final QueueMode mode;
  final PlayerInfo white;
  final PlayerInfo black;
  final ClockConfig clock;

  PlayerInfo player(Side side) => side == Side.white ? white : black;
}

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
    this.localSide = Side.white,
    this.online,
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

  /// The local player's side: White against the computer, either side
  /// online. Pass & play has no single local side.
  final Side localSide;

  /// Online matches only.
  final OnlineMatch? online;

  bool get vsComputer => opponent == OpponentKind.computer;
  bool get isOnline => opponent == OpponentKind.online;

  /// Whether one side is played by someone else (bot or online opponent).
  bool get hasRemote => opponent != OpponentKind.passAndPlay;

  /// Whether [side] is moved by the bot or the online opponent.
  bool isRemote(Side side) => hasRemote && side != localSide;

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
