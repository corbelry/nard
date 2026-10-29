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
Configurable per rule set (`openingRollIsFirstMove`). Confirmed by the product owner (2026-10-30).

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
Confirmed by the product owner (2026-10-30).

## ADR-009 — Long Nard koks definition (2026-10-30)
Koks (×3) = the loser has borne off nothing **and** has at least one checker
that has not passed the winner's home board (loser's own points 13–24, which
includes its own starting quarter). Mars = ×2, oyn = ×1. Koks can be disabled
via `LongNardRules(koks: false)`. No "last roll for a draw" rule: the first
side to bear off all checkers wins. Confirmed by the product owner (2026-10-30).

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

## ADR-016 — Mobile-only client (2026-10-30)
Product-owner decision, matching the design system: the Flutter client
targets **iOS and Android only** — phone portrait (390×844, primary), phone
landscape (844×390) for the board, tablet as a scaled-up phone layout. No web
or Windows/macOS builds; this overrides spec §3 (client row) and §10
(desktop/web layouts). `nard_core` stays web-safe (ADR-004) at no cost, so
the decision can be revisited without engine changes.

## ADR-017 — Phase placement for progression and replays (2026-10-30)
Product-owner decision. Spec §8.8 (progression) and §8.9 (replays) had no
phase in §12:
- Progression — player level/XP, daily/weekly missions, achievements,
  titles, login streak — ships in **Phase 4** with the coins/gems economy
  (missions and achievements pay out coins).
- The replay viewer for local games ships in **Phase 2** (offline feature,
  §8.10); shared replay links follow in Phase 3, and per-move equity analysis
  stays in Phase 6.

## ADR-018 — Languages (2026-10-30)
The app ships in **az, en, ru, tr** (ARB files in the client, lang files in
Laravel; no hard-coded user-facing strings). Azerbaijani is the design's
source language. On first launch the language picker (design 9.2) is always
shown, preselected from the device locale when it is one of the four;
otherwise it falls back to **English**. Product-owner decision.

## ADR-019 — AI levels and names (2026-10-30)
Spec levels map to the design's names: Beginner = Başlanğıc, Easy =
Həvəskar, Medium = Orta, Hard = Güclü, Expert = Usta, Master = Qrossmeyster.
Phase 2 ships the first four (heuristic). Usta and Qrossmeyster are shown
**locked with a "Tezliklə" (coming soon) state** until the neural evaluator
lands in Phase 6. Product-owner decision.

## ADR-020 — Sign-in methods (2026-10-30)
Sign-in methods are **guest, Apple, Google and email**. Phone-number
sign-in is **removed** (overrides spec §8.1): no SMS provider, no phone
field on accounts. The design shows a phone option and lacks email; both
changes have been requested from Claude Design. Product-owner decision.

## ADR-021 — No .mat match files for now (2026-10-30)
Move notation, GNU BG Position/Match IDs and JSON game records cover the
product's needs; `.mat` import/export is not planned. Revisit if serious
players ask for external analysis. Product-owner decision.

## ADR-022 — Coins can never be bought (2026-10-30)
Coins (soft currency) are **only earned** — playing, missions, achievements,
the free season-pass track and season-end rewards. Nothing purchasable with
real money or with the hard currency may grant coins: no coin packs, no
hard-currency→coin exchange, no coins in bundles or on the premium
season-pass track. Reason: coin-entry tournaments pay coin prizes; tying
coins to money would make a dice game look like gambling in several target
markets (incl. Turkey) and in store review. The hard currency buys only
cosmetics and the premium pass. Enforce server-side in the ledger
(Phase 4). Product-owner decision.

## ADR-023 — Hard currency is "Yaqut" (2026-10-30)
The design used "Almaz" both for the paid currency and for the Diamond rank
tier. The paid currency is renamed **Yaqut** (az), matching its garnet gem
icon; localized as Yakut (tr), Рубины (ru), Rubies (en). The rank tier stays
Almaz / Diamond. Code and DB keep the neutral identifier `gems`
(`wallets.gems`, `CurrencyPill kind="gem"`). Product-owner decision.

## ADR-024 — Bot fallback after 30 seconds (2026-10-30)
In casual (unrated) queues only, if no live opponent is found within **30 s**
the player is matched with a clearly labelled BOT (spec §7.4) while the
search continues in the background. Bots never affect rating. The design's
20 s text is to be corrected. Product-owner decision.

## ADR-025 — No subscription at launch (2026-10-30)
Launch monetization is one-off purchases only: Yaqut packs and the premium
season pass (one purchase per season). No auto-renewing subscription.
A subscription may come later; any future product that would grant coins
(subscription perks, coin packs) conflicts with ADR-022 and needs a legal
review plus a change to coin-entry tournament prizes first.
Product-owner decision.

## ADR-026 — The engine explains illegal moves (2026-10-30)
`TurnPlanner.explain(from, to, played)` returns a `MoveRejection`
(turnComplete, noChecker, noMatchingDie, mustEnterFromBar, pointClosed,
headRule, sixBlock, bearOffNotAllowed, bearOffHigherDie, mustUseBothDice,
mustUseLargerDie) or null when the move is legal. A property test checks
that `explain` rejects exactly the moves `nextMoves` omits. The client maps
reasons to the rule banners (23.2, 23.3) and toasts; the server can reuse it
for error replies in Phase 3.

## ADR-027 — Heuristic AI levels (2026-10-30)
`nard_ai` scores positions with a hand-tuned, antisymmetric logit
(race/pip term, blot risk, made home points, primes, anchors for Short Nard;
blocking runs and point coverage for Long Nard) and maps it to a win
probability. Levels: Başlanğıc = `beginner` (1-ply, heavy noise, 25 %
random turns), Həvəskar = `easy` (1-ply, light noise, 8 %), Orta = `medium`
(1-ply), Güclü = `hard` (2-ply expectiminimax over the opponent's 21 rolls
for the best 4 candidates). Usta/Qrossmeyster (`expert`/`master`) are locked
in the UI (ADR-019) and play like `hard`. Cube: double at ≥ 68 % win
probability, take at ≥ 25 % (no gammon-aware "too good"). The bot runs in an
`Isolate` with a 0.5–1 s thinking delay. The "~elo" labels of 2.3 are not
shown until the bots are calibrated.

## ADR-028 — Client architecture (2026-10-30)
- State: Riverpod 3; navigation: go_router (tab shell for Əsas/Profil);
  storage: Drift 2.28 (newer Drift needs Dart ≥ 3.9; Flutter is 3.29.2).
- Rules flow through a pure `Session` (`lib/game/session.dart`) wrapping
  `GameState`/`TurnPlanner`; `GameController` adds dice, bot, timers and
  saving; `GamePresenter` maps state to the screen. The Flame board only
  draws a `BoardScene` and reports taps/drags in the mover's numbering.
- `lib/theme/` is vendored unchanged from the design skill and excluded
  from analysis and formatting; values the design uses without a token live
  in `lib/ui/extra_tokens.dart`.
- Fonts are static instances (fontTools) of the Google Fonts variable
  files; IBM Plex Sans Condensed has no Cyrillic (only the komur theme uses
  it).
- Offline dice use `Random.secure()`; provably fair dice are Phase 3.
- Pub workspaces don't support `generate: true`, so `flutter gen-l10n` runs
  explicitly and the generated files are committed (CI checks they are up to
  date). The game_server Docker build removes the client from the workspace.

## ADR-029 — Design gaps resolved for Phase 2 (2026-10-30)
Assumptions taken while building from `docs/design-notes/*` (open questions
there); each can be changed without touching the rules:
plain walnut board without the xatəm inlay; an owned cube rests at the inner
end of its owner's tray; doubles show four dice that dim one by one; the
opponent's last-move markers clear with the player's first move; one sheet
style (surfaceRaised, radius 24/42) except the cube offer (no handle, not
dismissible); non-primary buttons use the card radius, sebeke button labels
use Noto Serif Display; names in sentences use neutral phrasing to avoid
Azerbaijani suffix harmony ("Növbə: {name}"); Home = hero card + four tiles
(Kompüter, Bir cihazda, Dərs, Oyunlarım); vs computer flow 2.2 → 2.3; time
controls, the rated toggle and "İpuçlarını göstər" are omitted offline;
"Təhlil" on result screens becomes "Replay"; the Profil tab opens Settings
until 8.1; offline resignations are accepted at once; pass & play adds a
match-length row and keeps the cube on for Short Nard; the clock block is
hidden in offline games; lesson steps 1 and 3–7 were written by us.
Listed for review in `docs/QUESTIONS.md`.

## ADR-030 — Product-owner answers, Phase 2 review (2026-10-30)
Default board stays plain walnut (xatəm inlay → Phase 4 cosmetic);
"İpuçlarını göstər" waits for the Phase 6 analysis; a CC0 sound pack ships
now, custom sounds in Phase 7; Turkish names the variants **Tavla / Uzun
tavla**; the lesson steps we wrote stay for now and are revisited later;
the offline Home layout is accepted; AI "~elo" labels stay hidden until
calibrated; pass & play resignations are accepted at once. Phase 3:
Apple/Google sign-in is built but disabled by config until the owner adds
keys; development e-mail goes to Mailpit (real provider in Phase 7).

## ADR-031 — Online protocol shape (2026-10-30)
`game.state` always carries the full `GameRecord` plus pending moves, clock
and match score; clients rebuild the position by replaying it with
`nard_core` and ignore states with an old `seq`. The turn being built is
server state (`game.move` / `game.undo` / `game.confirmTurn`), so the
opponent sees moves live and a reconnecting client resumes mid-turn.
Resignations are accepted at once online as offline (ADR-030); the
`OfferResignation`/`AcceptResignation` pair is still recorded. Fair-dice
client seeds travel in `game.seed` before the opening roll (FD-02).

## ADR-032 — Single game-server pod in Phase 3; Redis scaling in Phase 7 (2026-10-30)
Phase 3 ships an in-memory `Matchmaker` and `MatchRoom`s in one game_server
process: it already implements the queue rules (per variant/length/mode,
rating band ±50 → ±400, casual bot after 30 s), clocks, reconnect grace and
fair dice, and passes the compose end-to-end test. The multi-pod pieces of
spec §7.5 — Redis queues, a `matchId` → pod registry and per-turn Redis
snapshots for crash recovery — move to Phase 7 together with Kubernetes,
load tests and observability, where they can be measured. The `Matchmaker`
and `ResultSink` interfaces are the seams for that work. Results reach the
API over signed HTTP with retries (idempotent by match id) instead of
Redis Streams for now.
