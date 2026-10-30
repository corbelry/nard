/// Why a requested checker movement is not legal right now.
///
/// Returned by `TurnPlanner.explain` so a UI can show the matching banner
/// instead of silently ignoring the gesture. Rule IDs refer to
/// docs/RULES_SHORT.md and docs/RULES_LONG.md.
enum MoveRejection {
  /// Every die of the roll has already been used.
  turnComplete,

  /// The side to move has no checker on the source point.
  noChecker,

  /// The distance does not match any unused die (SN-03), including moves
  /// in the wrong direction.
  noMatchingDie,

  /// Checkers on the bar must enter before any other move (SN-07).
  mustEnterFromBar,

  /// The destination is held by the opponent (SN-05, LN-03).
  pointClosed,

  /// Only one checker may leave the head this turn (LN-04, LN-05).
  headRule,

  /// The move would build six consecutive points with no opposing checker
  /// past them (LN-06).
  sixBlock,

  /// Bearing off needs every checker in the home board (SN-12, LN-09).
  bearOffNotAllowed,

  /// A die higher than needed bears off only from the highest occupied
  /// point (SN-13).
  bearOffHigherDie,

  /// The move leaves fewer dice playable than another sequence would
  /// (SN-09, SN-11, LN-07).
  mustUseBothDice,

  /// Only one die can be used, so it must be the larger one (SN-10, LN-07).
  mustUseLargerDie,
}
