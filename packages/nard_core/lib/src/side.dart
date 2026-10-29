/// The two players. White is the canonical "absolute" perspective used for
/// rendering; every rule is evaluated from the mover's own perspective.
enum Side {
  white,
  black;

  Side get opponent => this == white ? black : white;
}
