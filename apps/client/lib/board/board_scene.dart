import 'package:nard_core/nard_core.dart';

/// Everything the board draws for one frame of the game, independent of
/// how the game is driven. Slots are in the owning side's numbering.
class BoardScene {
  const BoardScene({
    required this.rules,
    required this.viewer,
    required this.board,
    this.dice = const [],
    this.diceUsed = const [],
    this.diceOwner,
    this.rolling = false,
    this.cubeValue = 1,
    this.cubeOwner,
    this.cubeVisible = false,
    this.cubeOffered = false,
    this.mover,
    this.selected,
    this.targets = const {},
    this.illegalTarget,
    this.lastMoves = const [],
    this.lastMover,
    this.mustEnter = false,
    this.colorBlind = false,
    this.largePips = false,
  });

  final RuleSet rules;

  /// The side drawn at the bottom (home bottom right).
  final Side viewer;
  final BoardState board;

  /// Dice faces to show (two, or four for doubles).
  final List<int> dice;

  /// Per die: already played this turn.
  final List<bool> diceUsed;

  /// Whose dice: drawn in the right half for the viewer, left otherwise.
  final Side? diceOwner;
  final bool rolling;

  final int cubeValue;
  final Side? cubeOwner;
  final bool cubeVisible;

  /// Draws the large offer cube at [cubeValue] × 2.
  final bool cubeOffered;

  /// The side whose selection and targets are shown.
  final Side? mover;
  final int? selected;
  final Set<int> targets;

  /// A destination refused by the rules (six-block banner, 23.3).
  final int? illegalTarget;

  /// The previous turn, drawn as from-ghosts and to-rings.
  final List<Move> lastMoves;
  final Side? lastMover;

  /// Highlights the mover's bar checkers (must enter first).
  final bool mustEnter;

  final bool colorBlind;
  final bool largePips;
}
