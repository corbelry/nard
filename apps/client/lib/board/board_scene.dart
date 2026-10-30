import 'package:nard_core/nard_core.dart';

import '../cosmetics/board_look.dart';

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
    this.look = BoardLook.walnut,
    this.sideLooks = const {},
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

  /// The board set drawn (frame, field, points, numbers, tray).
  final BoardLook look;

  /// Per-side sets for checkers and dice (opponent cosmetics); sides
  /// missing here use [look].
  final Map<Side, BoardLook> sideLooks;

  /// The checker material of [side]: White = light, Black = dark.
  CheckerMaterial material(Side side) {
    final set = sideLooks[side] ?? look;
    return side == Side.white ? set.light : set.dark;
  }

  /// The dice of the side that rolled (or [look] for the opening roll).
  DiceLook get diceLook => (sideLooks[diceOwner] ?? look).dice;

  /// This scene drawn in other sets.
  BoardScene withLook(
    BoardLook look, {
    Map<Side, BoardLook> sideLooks = const {},
  }) => BoardScene(
    rules: rules,
    viewer: viewer,
    board: board,
    dice: dice,
    diceUsed: diceUsed,
    diceOwner: diceOwner,
    rolling: rolling,
    cubeValue: cubeValue,
    cubeOwner: cubeOwner,
    cubeVisible: cubeVisible,
    cubeOffered: cubeOffered,
    mover: mover,
    selected: selected,
    targets: targets,
    illegalTarget: illegalTarget,
    lastMoves: lastMoves,
    lastMover: lastMover,
    mustEnter: mustEnter,
    colorBlind: colorBlind,
    largePips: largePips,
    look: look,
    sideLooks: sideLooks,
  );
}
