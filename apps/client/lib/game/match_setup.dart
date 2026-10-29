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
  };

  static MatchSetup fromJson(Map<String, Object?> json) => MatchSetup(
    variant: Variant.values.byName(json['variant']! as String),
    opponent: OpponentKind.values.byName(json['opponent']! as String),
    level: BotLevel.values.byName(json['level']! as String),
    matchLength: json['matchLength']! as int,
    whiteName: json['whiteName']! as String,
    blackName: json['blackName']! as String,
  );
}
