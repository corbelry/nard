# Architecture Decision Records

Short ADRs for non-obvious decisions. Status is *Accepted* unless noted.
Items marked **Open question** need product-owner confirmation.

## ADR-001 — Dart pub workspace monorepo (2026-10-30)
Dart packages (`nard_core`, `nard_ai`, `nard_protocol`) and `apps/game_server`
are members of one pub workspace (root `pubspec.yaml`, single lock file).
The Flutter client joins the workspace in Phase 2 when it is created; it was
not scaffolded in Phase 0 to avoid committing generated platform code before
it is needed.

## ADR-002 — Laravel 13 instead of Laravel 11 (2026-10-30)
The spec names Laravel 11. As of today every Laravel 11.x release is blocked
by Packagist security advisories (the line is out of security support), so
`composer create-project laravel/laravel:^11` refuses to install. We use the
current major, **Laravel 13** (PHP ^8.3, pinned to the 8.3 platform), rather
than suppressing security advisories. Filament is added in Phase 7 (admin)
using a version compatible with Laravel 13.

## ADR-003 — Board representation (2026-10-30)
`BoardState` stores, per side, 26 slots in that side's **own** perspective
(0 = off, 1–24 points, 25 = bar). Every rule is written once from the
mover's perspective; variant geometry (`opposite(point)`: 25−p for Short,
p±12 for Long) lives in the `RuleSet`. White's numbering is the absolute
numbering used for rendering (`RuleSet.toAbsolute`).

## ADR-004 — Web-safe 53-bit Zobrist key (2026-10-30)
Web integers are exact only to 2^53 and bitwise ops are 32-bit, so the key
uses two 32-bit XOR lanes (tables from a fixed-seed xorshift32) combined into
21 + 32 = 53 bits. Identical on VM and web.

## ADR-005 — Move generation and partial-turn validation (2026-10-30)
`TurnPlanner` explores (position, remaining dice, head moves) nodes with
memoisation. It computes the maximum number of dice usable; a move is legal
at any point of a turn iff the turn can still be completed with that many
dice (plus the larger-die rule when only one die is usable). This gives
`legalTurns` (one sequence per distinct resulting position, as the spec
requires) and move-by-move validation/undo for UI and server without
enumerating every ordering. Cross-checked against an independent naive
oracle in `test/oracle.dart` on thousands of random positions.

## ADR-006 — Long Nard opening (2026-10-30)
The opening throw (one die each, ties re-thrown) only decides who starts;
the starter then rolls both dice. In Short Nard the opening dice are played.
Configurable per rule set (`openingRollIsFirstMove`).

## ADR-007 — Long Nard head exception (2026-10-30)
On each side's own first turn, 6-6, 4-4 and 3-3 allow two checkers off the
head (one-checker play would be blocked by the opponent's head). Applies to
both players. Taking the second checker is mandatory when it is the only way
to use more dice (max-dice rule).

## ADR-008 — Long Nard six-block rule (2026-10-30)
"Six consecutive points" is measured along the **opponent's** path (so own
points 1 and 24 are adjacent, own 13 and 12 are not). Legal only if at least
one opposing checker is past the block; borne-off checkers count as past.
The rule is checked after **every single move**, not only at the end of the
turn (a move that forms an illegal block is illegal even if a later move of
the same turn would break it).
**Open question:** some clubs apply it only to the final position of a turn.

## ADR-009 — Long Nard koks definition (2026-10-30)
Koks (×3) = the loser has borne off nothing **and** has at least one checker
that has not passed the winner's home board (loser's own points 13–24, which
includes its own starting quarter). Mars = ×2, oyn = ×1. Koks can be disabled
via `LongNardRules(koks: false)`. No "last roll for a draw" rule.
**Open question:** regional definitions of koks vary; confirm for AZ market.

## ADR-010 — No cube in Long Nard (2026-10-30)
Traditional Long Nard has no doubling cube; `LongNardRules.usesCube` is
false and `GameState` disables cube actions.

## ADR-011 — Game actions and resignation (2026-10-30)
A game is an immutable `GameState` driven by validated `GameAction`s
(`OpeningRoll`, `RollDice`, `PlayTurn`, cube, resignation, `Forfeit`).
Dice values are inputs, never generated inside the engine (keeps it pure and
lets the server inject provably-fair rolls). Resignation is offer/accept/
reject at a level; server-imposed losses (timeouts, abandonment) use
`Forfeit`. An empty `PlayTurn` is required when the roll cannot be played
(the server may auto-submit it).

## ADR-012 — Cube options (2026-10-30)
Default maximum cube value 64 (configurable through `GameConfig`). No
beavers, raccoons, automatic doubles, Murphy or Holland rules. Jacoby is a
money-session option only.

## ADR-013 — GNU Backgammon IDs (2026-10-30)
Position ID follows the gnubg manual: player on roll first, points 1–24 then
bar, little-endian bits, Base64 without padding. Match ID uses the 66-bit
layout from gnubg's `matchid.c`; player 0 = White. gnubg's optional extended
bit 66 (Jacoby) is always written as 0 and ignored on read, so IDs match
what other tools expect. Dice are stored high die first, as gnubg does.

## ADR-014 — Crawford edge cases (2026-10-30)
Crawford is triggered only when a side *reaches* N−1 through a game result;
a 1-point match therefore has no Crawford game. It is triggered once.

## ADR-015 — Docker Compose host ports (2026-10-30)
Local compose publishes MySQL/Redis/API/game server on 13306/16379/18000/
18080 by default (overridable with `NARD_*_PORT`) to avoid clashing with
services already installed on developer machines.
