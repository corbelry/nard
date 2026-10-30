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

## ADR-033 — Online screens: design gaps resolved (2026-10-30)
Assumptions taken while building 9.4/17.x, 2.4/2.5/20.x, 10.3, 8.1, 15.x
from `docs/design-notes/online.md` §12 (open in `QUESTIONS.md` #16–22):
the bot-fallback copy no longer promises a background search; search
estimate and online count are omitted (no data); tier sub-levels I–III are
thirds of each 200-point band; the opponent-disconnected banner says the
connection dropped (the clock keeps running, the present player may move);
export copies the JSON to the clipboard (no e-mailed ZIP); account deletion
is immediate (no 30-day grace) with a localized confirm word compared with
İ/I/ı/i folded; sign-out lives in 15.1 and guests link an e-mail there;
the Profil tab root is the profile (settings via its header icon); the
Home hero stays offline and online play is two new tiles, "Adi" (casual) and
"Reytinqli"; one time control (3 min + 12 s); Apple/Google buttons show on
both platforms and report "not available yet"; sheets use `showNardSheet`;
the fair-dice screen shows both client seeds; avatars use fixed gradients
and only AZ/TR/RU/GB/US flags are drawn; neutral phrasing avoids suffix
harmony. Sign-in opens on demand, not in first-launch onboarding.

## ADR-034 — Cosmetic sets and economy numbers for Phase 4 (2026-10-31)
- A `board` item carries the whole set look of the design (frame, field,
  points, tray, numbers, inlay, light/dark checker materials, dice face and
  pips, table background) as gradients in `items.data.look`; the client
  paints any board from data, so new sets ship without an app update.
  Splitting checkers/dice/cup/table into separately equippable categories
  comes with remote texture packs. Item names/descriptions are per-locale
  maps in `data` (az + en now; ru/tr fall back to en).
- Catalog: the six gallery sets plus "Gecə Qarağacı" (`dark`) and "Şuşa
  Xatəmi" (`xatam`, tournament reward). Bare prices in the design are read
  as coins, Yaqut prices are explicit. Caspian is season-only (not for
  sale), Marble Royale is the featured offer (1 800 Yaqut, was 2 400).
- Economy numbers follow the design (store.md §10): ranked 5-point win
  +250 coins / +120 XP scaled by match length, XP 350 + 50·(n−1), +200
  coins per level, streak 20…80 then 150, design's daily missions (the
  practice-puzzle one waits for Phase 6), a fixed daily bonus for finishing
  all daily missions. "Sandıq" chests are fixed, visible rewards — no loot
  boxes (spec §8.7). Yaqut packs 500 / 1 200 / 2 000. All await the
  owner's confirmation (`QUESTIONS.md`).

## ADR-035 — Store and progression screens: design gaps resolved (2026-10-31)
From `docs/design-notes/store.md` §12: "Sandıq" chests show fixed coin
amounts ("Günlük bonus"); Mağaza is the second tab (Əsas · Mağaza ·
Profil), the Locker opens from the store header and a Profil tile; prices
always show their currency (coins if an item has a coin price, else
Yaqut); a board item is a whole set; seasonal/tournament items are not
buyable ("Tezliklə" in their obtain rows); Yaqut tiles show the gem amount
only (store prices come with the store SDK); match rewards (2.6) are shown
for online matches as before/after diffs of the server's progress; mission
and streak countdowns use the server's reset times; achievements show
unlocked/locked only (no per-achievement progress from the API yet);
titles are picked on 8.2; the opponent's set colours their own checkers
(light if White, dark if Black) when "show opponent's cosmetics" is on, a
local setting for now; replays and lessons still draw walnut. In debug
builds only, Yaqut packs send a fake `test-…` receipt (local `IAP_FAKE`).

## ADR-036 — Clans: rules taken from the design (2026-11-01)
Numbers in `apps/api/config/clans.php` (create 3 000 coins, rename 1 000,
cap 50, name 3–24, tag A–Z 3–5, chat 300 chars / 10 per minute, weekly
chest 10 000 → clan XP only, wars +3 per win up to 25 matches). Roles
stack (leader > co-leader > elder > member); kicks and role changes only
on members strictly below you; leadership moves via `role: leader`; a
leader must transfer before leaving unless last (then disband). Min rating
is checked against the best rating of both variants; invites bypass policy
and rating. Clan XP: online wins against humans outside the clan, donations,
full chest, war wins (no XP from bots or in-clan games). Wars pair clans of
similar level weekly; any online match between their members counts while
the war is live. Spectators see emotes only, no chat (QUESTIONS #28).
Contract: `docs/api/clans.md`.

## ADR-037 — Social and clan screens: decisions (2026-11-01)
Tab bar Əsas · Klan · Mağaza · Profil (social.md adds Klan; its root is the
clan home when in a clan, else search). Home tiles add "Şəxsi otaq" and
"Dostlar". A room match starts as soon as the guest joins (no "Başla");
"Paylaş" copies an invite text; inviting a friend creates a room and posts
a challenge that waits 10 minutes. Quick phrases show the design's six;
emote art is Lucide line icons (no emoji) until an emote pack ships.
Spectators see emotes only; seats are labelled by colour (names are not in
the spectator protocol). Report also blocks by default. Clan language is a
single choice; min rating 1000–2400 step 50 or none; donations use preset
amounts; the war tab shows score and counted matches (no assigned
pairings); the leaderboard ranks by clan XP. Not built yet: QR codes, last
seen, spectator count, guest-joined card, clan rename/settings UI, deep
links (Phase 7 with push).

## ADR-038 — Tournament backend (2026-11-03)
Product answers assumed (QUESTIONS #33–36): tournament matches are
**unrated** (queue mode `tournament`, no ratings in seats or results);
private tournaments are **free** knockouts with an invite code (sizes
4/8/16/32, start with ≥ 2); the no-show timer is **3 min** (owner, #35; was 60 s) from the moment
the game server receives the pairing; scheduled prizes are fixed,
house-funded coin credits (reason `tournament`, ADR-022 keeps coins
earn-only), sit-and-go withholds **10 %** of the entries and an unfilled
table is cancelled with a full refund after **10 min**. Entry fees are
ledger debits keyed by the client's idempotency key; a refunded key cannot
be reused. The API is the source of truth for brackets
(`PairingEngine`, pure PHP): knockout seeded by rating with byes to the top
seeds and no third-place match (semi-finalists share 3rd); Swiss pairs
top-down by points then rating, avoiding rematches (backtracking), bye = 1
point, full integer Buchholz then rating as tie-breaks (tournaments.md
§19.16); round-robin by the circle method. Pairings are pushed to the game
server over signed HTTP (`/internal/tournament-matches`, same HMAC as
results, reversed) from `tournaments:tick` and after each round; the game
server starts a match when both players are connected or sent
`tournament.ready`, reports a `walkover` result for a single no-show and a
`TournamentNoShow` when both are absent (nobody advances; in a knockout
the opponent of the next round gets a bye). Walkovers give no match
rewards or clan XP; played tournament matches pay like casual ones.
Sit-and-go: Short Nard to 3, 500 coins at every size (8/16/32), joined over
REST rather than WS so the ledger stays in the API. Bracket changes reach
clients by polling for now. Contract: `docs/api/tournaments.md`.

## ADR-039 — Seasons, season pass, leaderboards and puzzles backend (2026-11-04)
Product answers assumed (QUESTIONS #37). **Seasons** last 42 days and end at
00:00 UTC; the daily `seasons:roll` freezes final ranks per variant (players
with ≥ 5 ranked matches that season; global and country rank), grants one
season-end reward per player by the **best final tier over both variants**
(coins 100 … 5 000, plus a frame from Almaz up, design 7.1 "Almaz: Çərçivə +
2 000"), applies the soft reset `1500 + (r − 1500) × 0.5` (peak kept) and
starts the next season. Rewards are granted at the roll — 7.2 "Mükafatları
al" only acknowledges. Each season copies the pass and end-reward tables
from `config/seasons.php` when it starts, so a running season never changes.
**Pass**: 50 levels × 1 000 XP; season XP is every player-XP grant while the
season runs (one hook in `ProgressionService::addXp`: matches and missions;
idempotent match ingestion keeps it single-counted). Free track = coins on
every level (design 200/300 on odd levels, 100 even, 500 every 10th);
premium track = 950 Yaqut once per season (ADR-025), 50 Yaqut on levels
ending in 3/8 (500 in total) and cosmetics on 10/20/30/40/50; other premium
levels are empty until more seasonal cosmetics exist (the design's "Emote",
"Zər · Nadir", "Daşlar · Epik" tiles need categories that are not
equippable yet, ADR-034). **Caspian is premium level 30** (Locker/3.2 "Sezon
· Səv. 30"; the pass mock's 19 is a sample window), Marble Royale level 40
(3.2). Premium-track rewards are credited with ledger reason
`season_premium`, which `economy.credit_reasons.coins` does not allow, so a
paid track can never mint coins (ADR-022); free track and season-end coins
use `season`. Unlocking premium later makes already-reached premium rewards
claimable. **Leaderboards** rank live ratings for the current season (≥ 5
rated matches to be listed; `ratings(variant, rating)` index) and frozen
`season_results` for past seasons, scopes global / country / friends /
clan, ranks within the scope. **Puzzles**: generated offline by
`nard_ai/tool/gen_puzzles.dart` (heuristic self-play, 2-ply best ≥ 0.06
equity ahead of the second best; only a clearly best turn is correct,
tournaments.md §19.23); an attempt is checked by the resulting **position**
(the client sends the board after its moves; any move order is accepted), 2
attempts, puzzle rating 1500 with +12/+6 correct and −8/−4 wrong (design
+12/−8; second attempt halved), "Həllə bax" counts as a failed attempt, the
solution is returned only once finished, daily puzzle = one per UTC day,
mission `daily_puzzle_2` (×2 → 30 coins). Not tracked yet for 7.2: mars
count and longest win streak per season. Contract: `docs/api/seasons.md`.

## ADR-040 — Competition screens: decisions (2026-11-01)
A fifth tab, Turnirlər (Əsas · Turnirlər · Klan · Mağaza · Profil, ~75 pt
each). Leaderboard from the tournament header and Profile; season pass
from the Home season card, Store and Profile; daily puzzle card on Home.
Screens poll (bracket/standings 15 s, sit-and-go 5 s) until tournament
pushes exist. Analysis runs on the device (heuristic 2-ply per position
in isolates), labelled "Qiymət"/evaluation with a note (QUESTIONS #38),
marks at 0.04 / 0.10; "Təhlil" replaces "Replay" on result screens.
Puzzles are online only; hints run on the device. Sharing copies text
(no share plugin). Not built: trophy showcase, private tournament editing,
tournament push messages, error-rate stats, season mars/streak stats.

## ADR-041 — Notifications: inbox first, push disabled until keys (2026-11-05)
Every event is stored in a `notifications` inbox row (typed, JSON `data`,
deduplicated per player and event) and shown in 16.2; the client polls it
(`?after=` newest id) every 60 s while the Home bell is visible and on app
resume. Events: friend request / accepted (SocialService), challenge
(SocialController), clan invite / join request accepted / war started
(ClanService), tournament reminder 15 min before / started / round ready /
eliminated / won / finished (TournamentService, reminders from
`tournaments:tick`), season end (SeasonService), level up (inbox only,
earned with the app open). Senders blocked either way are dropped and
hidden. 16.1 switches (`notification_settings`: master push, quiet hours
23:00–08:00 by default in the device's UTC offset, muted categories)
govern **pushes only**; the inbox keeps everything. Pushes go through a
`PushSender` interface on the database queue (`SendPushNotification`,
after commit; compose runs a `queue` worker): `FcmPushSender` (FCM HTTP v1,
service-account JWT → OAuth token, iOS via APNs-through-FCM, unregistered
tokens deleted) is bound only when `FCM_PROJECT_ID` and `FCM_CREDENTIALS`
(service-account JSON path) are set; otherwise `NullPushSender` and the
notifier log "push disabled" and queue nothing — the same "built, disabled
by config" pattern as Apple/Google sign-in (ADR-030). Design gaps: the bell
sits on the Home profile row (not drawn); 16.1 shows only categories with
an event ("Sənin növbən", "Rəqib tapıldı", "Klan söhbəti", "Seriya
xatırlatması", "Mağaza təklifləri" wait for their events; "Klan dəvətləri"
and "Sezon nəticələri" added); the 16.3 copy no longer promises your-turn
pushes; 16.3 shows once per install, before the OS dialog, only when the
OS was never asked. Rows are pruned after 60 days.

**Client push seam.** No new dependencies: `PushRegistrar`
(`apps/client/lib/notifications/push_registrar.dart`) with
`NoopPushRegistrar` (status `unsupported`, no token) behind
`pushRegistrarProvider`. To enable push: create the Firebase project, add
`google-services.json` / `GoogleService-Info.plist` and the APNs key in
Firebase, add `firebase_core` + `firebase_messaging`, implement
`PushRegistrar` with them (`status` ← `getNotificationSettings`,
`requestPermission`, `token` ← `getToken`, `tokenRefresh` ←
`onTokenRefresh`, `opened` ← `onMessageOpenedApp` + `getInitialMessage`
mapping `data{id,type,data}` to `PushOpen`), override
`pushRegistrarProvider` in `main.dart`, and set `FCM_PROJECT_ID` /
`FCM_CREDENTIALS` on the API. The bell then registers the token
(`POST /me/devices`), sign-out unregisters it, and 16.3 starts appearing.
Contract: `docs/api/notifications.md`; screens:
`docs/design-notes/notifications.md`.

## ADR-042 — Admin panel (Filament 5) and fair-play signals (2026-11-06)
**Admin.** Filament **v5.11** (Livewire 4) — the first major that supports
Laravel 13 (ADR-002); no Laravel downgrade, no extra PHP extensions (needs
`intl`, already in the image). Panel at `/admin` with Filament's own
e-mail + password session login on the `web` guard, separate from the
mobile Sanctum tokens; `User::canAccessPanel` = `is_admin` and not banned.
Admins are made with `php artisan admin:create {email} [--password=]`
(promotes or creates; guests have no password so cannot log in). The panel
is staff-only and English-only (labels inline, not in lang files). Writes
go through services (`ModerationService`, `TournamentService`,
`SeasonService`, `ClanService::adminRename`) and every one lands in
`admin_actions` (audit log). Resources are read-heavy: no create/edit/delete
except tournaments (create scheduled public ones), items (create/edit) and
puzzles (rating/phase/enabled); the featured offer moved to
`app_settings.featured` (config stays the default). Admin grants credit
coins or Yaqut with ledger reason `admin` and a mandatory note, capped at
`fairplay.max_grant` — support compensation only, never sold (ADR-022).
Report actions: dismiss (`reviewed`), warn (inbox `moderation_warning`),
mute, ban (`actioned`).

**Enforcement.** Banned users (`banned_at` set, `banned_until` null =
permanent) get `403 {code: banned, until}` from a middleware on every
authenticated API route, the same answer (and no token) at sign-in, and
`TicketSigner` refuses them. Muted users (`muted_until`) cannot post clan
chat (`403 muted`) and their ticket carries `muted: true`; the game server
drops their emotes silently. The abandonment penalty is a
`queue_cooldown_until` timestamp carried in the ticket
(`queueCooldownUntil`); the game server refuses `queue.join` with the new
error code `queue_cooldown` (private rooms and tournaments stay open), so
the API never has to refuse the whole ticket.

**Fair-play signals** (`anticheat:scan`, daily): flags for review in
`cheat_flags`; only abandonment acts automatically (24 h queue cooldown).
(a) Engine assistance is scored in Dart (`MoveQualityAnalyzer` in
`nard_ai`, CLI `tool/move_quality.dart`) because the rules and bots are
Dart: it replays stored game records and measures agreement with
`HeuristicBot(hard)` (same resulting position) and average evaluation loss;
the API exports ranked matches (`anticheat:export`) and imports the
per-player results (`--engine=<file>` or `MOVE_QUALITY_CMD`). A player is
flagged when agreement ≥ the rating band's expected agreement + 0.15 over
≥ 10 matches / 150 decisions. Caveat: an external engine (gnubg) need not
agree with our heuristic bot, so the signal is weak until the neural AI
exists; the bands are placeholders to calibrate on real data. (b)
Multi-accounting: sign-ins store hashed IP / device sightings (and
`users.last_ip`), kept 90 days; accounts sharing one that meet ≥ 2 times in
ranked are flagged with their head-to-head wins (shared IPs — families,
carrier NAT — make this review-only). (c) Abandonment: ≥ 30 % of ≥ 10
matches in 14 days lost by `abandoned`/`timeout`. (d) Reports: ≥ 5 distinct
reporters in 7 days. One flag per player and kind within the rule's window:
open flags are refreshed, reviewed ones are not raised again. Thresholds
are first guesses (QUESTIONS #40). Tournament collusion detection is not
built yet.

## ADR-043 — Observability, load test, Helm chart and MySQL CI (2026-11-07)
**Game server.** No new dependencies: a small Prometheus registry
(`lib/src/metrics.dart`, text format 0.0.4) served at `GET /metrics` —
connections, authenticated users, active rooms, bots, spectators, private
rooms, pending tournament matches, queue size per `variant/length/mode`,
matches started (by mode) / finished (by mode, reason), results reported /
failed (rejected, lost) / retried, WebSocket frames in/out, error messages
by code, auth failures, internal errors, a room-handle latency histogram
per intent type (unknown types share `other`, so clients cannot create
series) and process memory. `GET /readyz` is 200 once the server listens
and 503 after SIGTERM (then it closes after `SHUTDOWN_GRACE_SECONDS`);
`/healthz` stays the liveness probe. Logs are JSON lines (`level`, `ts`,
`msg`, then fields; `LOG_LEVEL`), and the shelf `logRequests` middleware
became a JSON request logger that also turns handler errors into 500 +
error report. Errors go to a pluggable `ErrorReporter`: no-op by default,
`SentryReporter` when `SENTRY_DSN` is set — it posts to the DSN's `store`
endpoint with the existing `http` client (no SDK), capped at 30 events/min.
`/metrics` is not authenticated: the Ingress exposes only `/ws`.

**API.** `json` log channel (stderr, `App\Logging\JsonLineFormatter`, same
shape as the game server; PSR level names) and a `sentry` channel
(`SentryHandler`, error level, no-op without `SENTRY_DSN`); containers use
`LOG_CHANNEL=stack LOG_STACK=json,sentry`. `GET /api/v1/internal/metrics`
(Prometheus text, bearer `METRICS_TOKEN`, 404 when unset): users by kind,
matches ended in the last 24 h by mode (new index on
`game_matches.ended_at`), database queue depth by queue, failed jobs, open
reports, open cheat flags by kind. Request rates and latencies are left to
the ingress controller's metrics. `GET /readyz` (outside the web
middleware, since sessions use the database) checks the database and
Redis (`READINESS_CHECKS`); `/up` stays liveness. **Bug fixed:** the API
trusted no proxies, so behind the ingress every player would share the
ingress IP for the per-IP limits (guest sign-up 20/min, e-mail codes) —
`TRUSTED_PROXIES` (`*` = the immediate peer, or CIDRs) now feeds
`TrustProxies`; the chart sets `*`.

**Load test.** `apps/game_server/tool/load_test.dart` (Dart, not k6: it
reuses the protocol models and the heuristic bot, and the latency that
matters is intent → authoritative `game.state`). Results and method in
`docs/LOAD_TEST.md`; spec §11's `tools/load/` path is replaced by this tool.
Locally, 200 concurrent matches (400 clients, 500 ms think time) gave a
move round-trip p95 of 18 ms (target < 150 ms), zero errors and 53 MB RSS.
One pod (one isolate, one core) saturates at about 900 intents per second,
so the multi-pod work of spec §7.5 stays the path to 50k CCU.

**Kubernetes.** Helm chart `infra/helm/nardarena`: API Deployment + Service
+ HPA (CPU 70 %, 2–10) + PDB, scheduler (1, Recreate), queue workers,
game server (replicas 1, Recreate; the chart refuses > 1 until the Redis
queue / matchId registry / sticky routing of spec §7.5 exist, ADR-032),
ConfigMap for non-secret API settings, one existing Secret referenced by
name (no values in the repo), Ingresses for the API host and the WS host
(`/ws` only, long proxy timeouts), probes on `/readyz`, Prometheus
annotations on the game server and an optional ServiceMonitor (the API
endpoint needs the bearer token), migrations as a `pre-install,pre-upgrade`
hook Job with its settings inline (the ConfigMap does not exist yet on a
first install). MySQL and Redis are external values. The API container
still runs PHP's built-in server (`PHP_CLI_SERVER_WORKERS`) until a
production image (php-fpm or Octane) is built.

**CI.** New `api-mysql` job runs the API suite against a `mysql:8.4`
service; `helm` job lints, renders and schema-checks the chart
(kubeconform); the e2e job also checks `/readyz` + metrics and runs a
2-match load-test smoke. The MySQL failures were test assumptions, not
product bugs: MySQL normalizes the key order of JSON columns (new
`assertSameIgnoringKeyOrder` helper) and does not reset auto-increment ids
between transactional tests (the report reference is computed from the
stored id).

## ADR-044 — Online time controls: Blits, Sürətli, Klassik (2026-11-07)
QUESTIONS #20 (owner, 2026-11-01): three controls next to each other,
correspondence ("Gündəlik") later as a separate product.

**Controls.** `TimeControl` in `nard_protocol` carries its clock (spec
§7.3, reserve per player + delay per turn): `blitz` 1 min + 8 s, `rapid`
3 min + 12 s (the former single `ClockConfig.standard`, still the
default), `classic` 5 min + 15 s.

**Protocol.** `queue.join` and `room.create` take an optional
`timeControl` (`blitz|rapid|classic`); absent means `rapid`, so older
clients keep working; any other value is refused with `bad_request`
(`ProtocolException`). `match.found` is unchanged — it already carries the
clock values, which clients display.

**Matchmaking.** One queue per `variant/length/mode/timeControl`: players
never meet someone who chose another control, also in ranked; the casual
bot fallback (ADR-024) plays the player's control. The queue-size metric
label gains the control (`shortNard/1/casual/blitz`). The room clock comes
from the request; tournament matches keep `rapid` (the API's pairing has
no clock field; per-tournament clocks remain on the roadmap, ADR-038).
Private rooms default to `rapid` (see the amendment below for the 6.3
choice).

**Ratings and results.** Ratings stay shared across controls (one rating
per variant). `MatchResult` gets an optional `timeControl` (the game server
always sends it; optional in `match_result.schema.json`). The API stores
it in `game_matches.time_control` (null for older matches) and returns it
as `timeControl` in match summaries.

**Client.** 2.2 shows the design's 2×2 time tiles (`TimeTile`, screens.md
"Time tile"): Blits / Sürətli / Klassik selectable, Gündəlik disabled with
"Tezliklə". The choice lives in the in-memory online draft like the other
2.2 options (not persisted across launches) and is sent with `queue.join`;
2.4 and 2.5 show the chosen clock.

**Amendment (2026-11-08): private rooms and friend challenges.** The host
picks the control; the room decides for both players — the guest joins by
code and plays the host's clock, whatever it last queued for (game server
test). 6.3 keeps the design's settings list ("Vaxt · 5 dəq + 15s"); the
Vaxt row opens the 2.2 tiles in a sheet (shared `TimeControlTiles`,
Gündəlik disabled), like Variant/Format, and a change recreates the room
(new code) and becomes the 2.2 draft. Rooms start from the draft's
control (Home chooser, 6.1 "Çağır", 14.1/5.5 invites); a private-room
rematch keeps the match's clock. `POST /challenges` takes an optional
`timeControl` (absent = `rapid`, other values 422), stored in
`challenges.time_control` (existing rows `rapid`) and returned in `GET
/friends` challenges, the `challenge` notification data and the push copy
("…, 5 points, Blitz 1+8s"). 6.1 challenge rows, inbox rows and the join
screen show "Blits 1+8s"; the challenge's control is display only — a
stale or forged value cannot change the room's clock.

## ADR-045 — Live moderation push and WebSocket abuse limits (2026-11-08)

**Context.** A security review found that bans, mutes and the abandonment
cooldown (ADR-042) reached the game server only through the ticket, which
is checked once at `auth`: a player who kept the socket open kept queueing,
playing and emoting, and the cooldown set by the fair-play scan never hit
the current session. Separately, `/ws` on the single game-server pod
(ADR-032) had no frame size limit, auth deadline, message rate, connection
cap or ping, so one client could tie up the pod.

**Decision — moderation push.** The API pushes the player's *whole*
moderation state to the game server's `POST /internal/moderation`
(`ModerationPayload` / `schema/moderation.schema.json`:
`{userId, banned, muted, queueCooldownUntil: epoch s|null}`), signed like
tournament pairings (`X-Nard-Signature`, `GameServerClient`).
`ModerationService` sends it after ban, unban, mute, unmute and clear
cooldown (after the surrounding transaction commits, so report handling
pushes only what was saved), and `AntiCheatService` after it sets an
abandonment cooldown. Full state rather than a delta makes repeats and
reordering harmless. Delivery is best effort: a failure (game server down,
refused) is logged and never fails the admin action; the next ticket
carries the same state. On the game server:

- `banned` → error `banned`, the socket closes with `4008 banned`, the
  player leaves the queue and private rooms, and a running match continues
  as a disconnect (the opponent wins by abandonment if they do not return —
  they cannot, the API issues no ticket).
- `muted` → the live session's emotes are dropped.
- `queueCooldownUntil` → `queue.join` is refused with `queue_cooldown`; a
  queued player is taken out of the queue with that error.
- The push is remembered for 10 minutes (twice the 5-minute ticket
  lifetime) and overrides tickets presented in that window, so a ticket
  signed just before a ban cannot be used after it.

Sessions are *not* closed when the ticket's `exp` passes: that would cut
live matches; the push is the revocation mechanism.

**Decision — WebSocket limits** (`WsLimits`, env with defaults; 0 turns a
limit off):

| Limit | Default | Env | On breach |
|---|---|---|---|
| Frame size | 16 KiB | `WS_MAX_FRAME_BYTES` | close `4009 frame_too_large` |
| Auth deadline | 10 s | `WS_AUTH_TIMEOUT_SECONDS` | close `4008 auth_timeout` |
| Message rate | 20/s, burst 40 | `WS_MESSAGES_PER_SECOND`, `WS_BURST` | error `rate_limited` (once per run); > burst refusals in a row → close `4008 rate_limited` |
| Connections per client address | 20 | `WS_MAX_CONNECTIONS_PER_IP` | HTTP 429 before the upgrade |
| WebSocket ping | 30 s | `WS_PING_SECONDS` | dead peers are dropped |

The client address is the TCP peer, or with `TRUST_PROXY=true` the
rightmost `X-Forwarded-For` entry (the hop the proxy appended; entries to
its left are client-controlled). Helm sets `TRUST_PROXY` (the pods are only
reachable through the ingress, NetworkPolicy) and adds ingress-nginx
`limit-connections: 20` / `limit-rps: 5` per IP on the WebSocket ingress;
docker compose leaves it off. Rejections are counted in
`nard_ws_rejected_total{reason=ip_limit|frame_too_large|auth_timeout|rate_limited}`.

Close codes are 4000 + the RFC 6455 code they stand for (`CloseCode` in
`nard_protocol`): `package:web_socket` lets a server send only 1000 or
3000–4999, so 1008/1009 are not available. dart:io buffers a whole frame
before the size check; the ingress (and the pod's memory limit) bound what
reaches it.

**Consequences.** Mobile carriers put many players behind one address
(CGNAT): the per-address caps may need raising — watch
`nard_ws_rejected_total{reason="ip_limit"}`. The client does not yet treat
`banned` / close 4008 specially: it reconnects and the API refuses the
ticket with 403 `banned`; a dedicated banned screen is open work.

## ADR-046 — Security review of Phase 7: limits, codes, admin and cluster (2026-11-08)

**Context.** A read-only review of the Phase 7 surface (admin, observability,
deletion page, export, rate limits, Helm, moderation) found 12 issues.
Findings 3–4 (live moderation, WebSocket abuse) are ADR-045; the rest are
here.

**Decision.**
- **Limiters are per route.** An un-named `throttle:N,M` keys by user/IP
  only, so every route shared one counter and the first route set the
  window (browsing clans blocked `POST /game/ticket`). Every legacy throttle
  now has a prefix (`throttle:30,1,post-game-ticket`); sign-in uses named
  limiters in `AppServiceProvider`: `auth` and `email-verify` 20/min,
  `email-start` 5 per 10 min per IP **and** `nard.login_code_hourly_issues`
  (5) per hour per address. IPv6 clients are keyed by their /64.
- **Login codes are capped per address.** `LoginCodes::check` counts wrong
  guesses per e-mail; after `nard.login_code_daily_failures` (10) in 24 h
  every code for that address answers `code_expired`. Worst case for an
  attacker: 10 guesses a day against 10^6 codes. Trade-off accepted: someone
  can lock an address out of e-mail sign-in for a day.
- **Codes have a purpose** (`login_codes.purpose`: `sign_in` | `deletion`):
  a deletion-page code never signs in, and issuing one leaves a pending
  sign-in code alone.
- **The deletion page queues its code** (`SendDeletionCode`) for every
  address, so known and unknown addresses answer equally fast.
- **Export hides internals:** `reports.action/handled_by/handled_at` and
  admin ids in `wallet_transactions.reference` (`admin:<id>` → `admin`).
- **Sentry (API) redacts** e-mails and IPv4/IPv6 addresses in messages,
  exception text, traces and context, and sends at most 30 events a minute
  per process. `/readyz` is throttled (60/min per IP) because the API
  ingress serves `/`.
- **Admin:** Filament requires an authenticator app with recovery codes
  (`AppAuthentication::make()->recoverable()`, secrets in encrypted
  columns); Helm sets `SESSION_SECURE_COOKIE=true` and offers
  `ingress.adminAllowlist` (a second Ingress for `/admin` and `/livewire`
  with `whitelist-source-range`).
- **Cluster:** `podSecurityContext.seccompProfile: RuntimeDefault`; every
  container drops all capabilities and disallows privilege escalation; the
  game server (`FROM scratch`) runs as uid 65532 on a read-only root. A
  NetworkPolicy lets only the ingress namespace, the monitoring namespace
  and NardArena's own pods reach the API (8000) and game server (8080);
  scheduler, queue and migrate pods accept nothing. That is what makes
  `TRUSTED_PROXIES="*"` safe; without the policy, pin it to the ingress CIDR.

**Not done (ROADMAP):** the interim API image still runs as root (Laravel
writes `storage/`); the production php-fpm/Octane image should run as
non-root on a read-only root with an emptyDir for `storage/framework`.
Per-IP WebSocket caps may be low for carrier NAT — watch
`nard_ws_rejected_total{reason="ip_limit"}`.


## ADR-047 — Production API image: FrankenPHP, non-root, read-only root (2026-11-08)

**Context.** The Helm chart ran the dev image (`php:8.3-cli-alpine`, dev
dependencies, root) with PHP's built-in server and `PHP_CLI_SERVER_WORKERS`
(ADR-043); ADR-046 left non-root + read-only root as open work.

**Decision.**
- **One Dockerfile, two targets** (`apps/api/Dockerfile`): `production`
  (`docker build --target production apps/api`) and `dev`. `dev` stays the
  last stage, so builds without `--target` — compose and the CLAUDE.md
  checks — still get the dev image with dev dependencies.
- **Server: FrankenPHP in classic mode** (`dunglas/frankenphp:1.12.7-php8.3-alpine`,
  pinned; PHP 8.3 like dev and CI). Caddy and PHP are one process, so one
  container per pod and no supervisor — php-fpm would need nginx beside it
  (two processes or a sidecar). Classic mode runs one request per PHP
  thread with a fresh app, exactly like php-fpm; no Octane: its worker mode
  keeps the app in memory between requests and would need an audit of
  singletons and static state (Filament, Livewire, our services) for little
  gain at our traffic. Threads: `FRANKENPHP_NUM_THREADS` (chart
  `api.threads`, default 8). Plain HTTP on :8000; TLS ends at the ingress.
  Caddy's admin API, automatic HTTPS and config persistence are off.
- **Build:** `composer install --no-dev` + `dump-autoload --optimize
  --classmap-authoritative` (split for layer caching), extensions
  pdo_mysql, redis, intl, zip, pcntl, bcmath, opcache (no gd: nothing uses
  it); `php.ini-production` + opcache with `validate_timestamps=0`; no
  tests, phpunit/phpstan configs or composer in the final image. Baked
  caches are env-independent only: `route:cache`, `event:cache`,
  `filament:optimize` (components + Blade icons) and the package/service
  manifests. **No `config:cache`** (configuration comes from the
  environment at runtime) and **no `view:cache`** (compiled views live in
  `storage/`, a volume; Livewire/Blade also compile on demand).
  `bootstrap/cache/*.php` is in `.dockerignore` so a host route cache never
  ships.
- **Runtime:** uid/gid 10001 (`nard`); code is root-owned and read-only.
  Only `/app/storage` (compiled views, file cache, logs) and `/tmp`
  (uploads, export ZIPs, Caddy state via `XDG_*_HOME`) must be writable.
  The entrypoint recreates `storage/`'s directories in an empty volume and
  `exec`s the command — the web server by default, or `php artisan …`.
  The image's file capability `cap_net_bind_service` is removed: pods drop
  every capability and port 8000 needs none.
- **Helm:** `containerSecurityContext.api` adds `runAsNonRoot`,
  `runAsUser/Group: 10001`, `readOnlyRootFilesystem`; API, scheduler, queue
  and migrate pods mount emptyDirs at `/app/storage` and `/tmp`
  (`api.storageSizeLimit`, `api.tmpSizeLimit`) and pass their artisan
  commands as `args` (a `command` would skip the entrypoint). The interim
  `api.command` and `PHP_CLI_SERVER_WORKERS` are gone.
- **Compose keeps the dev image** (live dev loop, seeding, `key:generate`
  at start).

**Verified** (2026-11-08) with `--read-only --user 10001:10001 --cap-drop
ALL --security-opt no-new-privileges` and tmpfs at `/app/storage` and
`/tmp`, against the compose MySQL/Redis: `/up` 200, `/readyz` ready,
guest sign-in 200, Filament login page and assets 200, account-export ZIP,
`migrate:status`, `schedule:list`, `schedule:run`, `queue:work --once`.
CI builds the target and checks `/up` on a read-only root. Image: 362 MB
(the FrankenPHP base and ICU make up most of it).

**Consequences.** `php artisan down` (file maintenance driver) only
affects one pod's volume — use the ingress for maintenance pages. Outside
Kubernetes, the writable volumes must be writable by uid 10001 (e.g.
`--tmpfs /app/storage:mode=1777`). Bumping FrankenPHP is a tag change in
the Dockerfile.

## ADR-048 — `game.state` deltas (2026-11-08)

**Context.** Every `game.state` carried the whole game record, so frames
grew with the game: 5.1 KB on average, 10.9 KB at p95 and up to 15.4 KB in
the load test (docs/LOAD_TEST.md), most of the bytes to clients and most
of the server's JSON work. The server broadcasts after every intent,
including single checker moves and clock or connection changes, so most
frames repeat the record unchanged.

**Decision.** Opt-in deltas, full snapshots whenever a receiver has no
base:

- `auth` gains `features: ["stateDelta"]`; the server echoes what it
  enabled in `hello.features`. A client that announces nothing (every app
  build before this one) keeps getting full states: a staged rollout
  needs no version switch and `protocolVersion` stays 1.
- The room remembers, per receiver (each seat and each spectator), what
  the last state it sent held: game index, record length, number of
  client seeds and the score object. For a `stateDelta` receiver with a
  base in the same game it sends `delta: {from, actions}` instead of
  `record`, drops `commitment` (fixed per game) and sends `match` and
  `clientSeeds` only when they changed. Everything else (pending moves,
  clock, revealed server seed, connection flags) is complete in every
  frame, so only the append-only record is incremental.
- Full states: the first state on a socket (match start, reconnect — the
  room forgets the seat's base on `connected`), `spectate.join`, a new
  game of the match (index changes) and `game.sync`. Bots take deltas
  (they read the room directly).
- Clients rebuild full states with `GameStateSync` (`nard_protocol`): a
  delta applies only if match id, game index and record length match;
  otherwise the client sends `game.sync {matchId}` once, ignores deltas
  until a full state comes, and never guesses. The server answers with
  the full state of the match the socket plays or watches.
- The rebuilt `GameStatePayload` is identical to the full one, so the
  controllers, last-move ghosts, fair-dice check, result screen, replay
  and analysis are unchanged.

Rejected: sending only the last turn and fetching the record on demand
(another request type and a second source of truth for replays), and a
seq-based ack protocol (WebSocket is ordered; reconnects already reset to
a full state, so the record length is a sufficient base check).

**Measured** (50 matches, 60 s, 500 ms think, same machine as ADR-043):
average frame 5 116 → 372 bytes (−93 %), p95 10 863 → 452, max 15 422 →
568; data to clients 162 → 11.4 MB; move round trip p50/p95/p99 2/8/12 →
2/6/9 ms; room handle p99 ≤ 2.5 ms → ≤ 1 ms; server peak RSS 54 → 26 MB.

**Consequences.** Server memory per receiver is one small record. Lost
frames cannot happen on one socket, so `game.sync` is a safety net; the
load tool counts any gap as an error (`state_gap`). Clients must keep
handling full frames at any time. Compose now reads
`WS_MAX_CONNECTIONS_PER_IP` (default 20) so the load test, whose clients
share one address, can turn the ADR-045 cap off.
