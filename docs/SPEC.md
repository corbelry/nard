# Project Spec: Professional Backgammon / Nard Game

> **For Claude Code.** This is the master spec. Read it fully before writing code. Work **phase by phase** (see §12), finish each phase with passing tests, and commit after each phase. When something is ambiguous, choose the simplest option consistent with this spec, write the decision into `docs/DECISIONS.md`, and continue.

Working title: **`NardArena`** (placeholder — keep the name in one config constant so it can change).

> Progress and deviations from this spec are tracked in `docs/ROADMAP.md` and `docs/DECISIONS.md` — notably ADR-002 (Laravel 13 instead of 11), ADR-016 (mobile-only client, overrides §3/§10 web and desktop) and ADR-017 (progression in Phase 4, replay viewer in Phase 2) ADR-020 (no phone-number sign-in, overrides §8.1), ADR-022 (coins are never purchasable) and ADR-023 (hard currency "Gems" is shown as Yaqut).

---

## 1. Product Summary

A cross‑platform, professional‑grade backgammon (nard) game with:

- **Offline play** — vs AI (several levels) and local 2‑player (pass & play), fully playable without internet.
- **Online play** — real‑time ranked/casual matches, private rooms with invite code, friends, spectating.
- **Competitive layer** — Elo/rating, seasons & leagues, tournaments (championships), leaderboards.
- **Social layer** — clans (guilds), clan chat, clan wars, friends, emotes.
- **Full cosmetic customization** — every player picks their own dice, board, checkers, dice cup, background, table felt, sound pack, emotes, avatar frame. Cosmetics are **purely visual** — never pay‑to‑win.

Target markets: Azerbaijan, Turkey, CIS, then global. Languages at launch: **az, en, ru, tr** (all strings through i18n from day one).

## 2. Game Variants

Implement as pluggable rule sets behind one interface (`RuleSet`):

| Variant | Priority | Notes |
|---|---|---|
| **Short Nard** (classic international backgammon) | P0 | Hitting, bar, bear‑off, doubling cube, gammon/backgammon, Crawford rule in matches |
| **Long Nard** (Uzun nərd) | P0 | No hitting, all 15 checkers start on the head, both move same direction (counter‑clockwise mirrored), only 1 checker from head per turn (except 6‑6/4‑4/3‑3 on first move), no 6‑block prime rule (cannot build 6 in a row unless an opponent checker is ahead), Mars/Koks scoring |
| Nackgammon, Hypergammon | P2 | Later, via same RuleSet interface |

Rules must be **100% correct** — this is a professional product. Write the rules engine test‑first with exhaustive edge cases (forced moves, must use both dice if possible, must use larger die if only one can be played, bear‑off with higher die, blocked bar entry, doubles = 4 moves, etc.). Document each rule with a test name that cites it.

Match formats: single game, match to N points (3/5/7/11/15/21), money/unlimited session (casual only).

## 3. Tech Stack (decided — do not change without logging in DECISIONS.md)

**Monorepo**, Dart‑first so the rules engine is shared by client and authoritative server.

| Layer | Tech |
|---|---|
| Client (iOS, Android, Web, Windows/macOS) | **Flutter 3.x** + **Flame** for board rendering/animations; Riverpod for state; go_router; Drift (SQLite) for offline storage |
| Shared rules engine | Pure Dart package `packages/nard_core` — no Flutter deps, 100% deterministic, fully unit tested |
| AI | Pure Dart package `packages/nard_ai` (uses `nard_core`); runs in an Isolate on client, and on server for bots |
| Real‑time game server | **Dart** (`shelf` + `shelf_web_socket`) `apps/game_server` — authoritative, imports `nard_core` |
| Meta/backend API | **Laravel 11** (PHP 8.3) `apps/api` — auth, profiles, clans, tournaments, shop, inventory, leaderboards, admin |
| Admin panel | Laravel + Filament |
| Data | MySQL 8 (primary), Redis (matchmaking queues, presence, pub/sub, rate limits, leaderboards via sorted sets) |
| Messaging between API ⇄ game server | Redis Streams (match results, events) + signed internal HTTP |
| Push | FCM / APNs |
| Infra | Docker, Kubernetes (GKE), Helm charts in `infra/`, GitHub Actions CI |
| Observability | OpenTelemetry, Prometheus/Grafana, Sentry (client + server) |

## 4. Repository Structure

```
/
├─ apps/
│  ├─ client/            # Flutter app
│  ├─ game_server/       # Dart realtime authoritative server
│  └─ api/               # Laravel meta API + Filament admin
├─ packages/
│  ├─ nard_core/         # rules, board state, move gen, notation, scoring, dice RNG interfaces
│  ├─ nard_ai/           # bots
│  └─ nard_protocol/     # shared WS message models (Dart) + JSON schema export for PHP
├─ infra/                # docker-compose (local), helm, k8s manifests
├─ docs/                 # ARCHITECTURE.md, PROTOCOL.md, DECISIONS.md, RULES_SHORT.md, RULES_LONG.md
└─ CLAUDE.md             # short working rules for Claude Code (generate from §13)
```

## 5. Core Engine (`nard_core`)

- `BoardState` — immutable; 24 points + bar + borne‑off per side; Zobrist hash for AI/transposition.
- `Dice` — `DiceRoll` value object; RNG behind `DiceSource` interface (local secure RNG offline; server RNG online).
- `MoveGenerator` — returns all **legal full‑turn move sequences**, deduplicated by resulting position, respecting max‑dice‑usage rules.
- `RuleSet` interface: `initialState()`, `legalTurns(state, roll)`, `apply(state, turn)`, `isGameOver()`, `score(state, cube)`.
- `DoublingCube` (Short Nard), `MatchState` (score, Crawford, post‑Crawford), `GameRecord` (full move log).
- Notation: import/export standard backgammon notation and **Position ID / Match ID** (GNU BG compatible) for Short Nard.
- Pure functions, no I/O. Target: move generation < 1 ms for typical positions.

## 6. AI (`nard_ai`)

Levels: **Beginner, Easy, Medium, Hard, Expert, Master**.

- v1: heuristic evaluator (pip count, blots, primes, anchors, home board strength, race detection) + 1‑ply / 2‑ply expectiminimax over dice; weaker levels add controlled noise / blunder rate.
- v2 (Phase 6): neural net evaluator (TD‑Gammon style, trained via self‑play in a separate Python training tool in `tools/train/`, exported to TFLite / ONNX and run on device). Separate nets for Short and Long Nard.
- Cube decisions for Short Nard (double/take/pass).
- **Analysis mode**: after a game, show per‑move equity loss, blunders/mistakes, and “best move” suggestions (uses Master level).
- AI runs in an Isolate; never blocks UI; configurable “thinking delay” for natural feel.

## 7. Online Architecture

**Server‑authoritative.** Client sends intents; server validates with `nard_core` and broadcasts state.

### 7.1 Provably fair dice
Per game: server generates `serverSeed`, publishes `sha256(serverSeed)` at game start; each client supplies a `clientSeed`; roll N = HMAC‑SHA256(serverSeed, clientSeedA|clientSeedB|N) → mapped to dice without modulo bias. `serverSeed` revealed after the game; client has a “Verify fairness” screen. Document in `docs/FAIRNESS.md`.

### 7.2 WebSocket protocol (`nard_protocol`)
JSON messages `{ type, id, ts, payload }`, versioned. Minimum set:
`hello/auth`, `queue.join/leave`, `match.found`, `game.state`, `game.roll`, `game.move`, `game.undo` (only within current turn, before confirm), `game.confirmTurn`, `cube.offer/take/drop`, `game.resign` (single/gammon/backgammon), `game.timeout`, `chat.emote`, `spectate.join`, `ping/pong`.
Server is the single source of truth; clients reconcile on every `game.state` (include `seq` number for ordering).

### 7.3 Clocks
Chess‑style: reserve time + per‑move delay (e.g. 12s delay + 3 min reserve per game, configurable per mode). Disconnect grace: 60s reconnect window, then auto‑play / forfeit by mode rules.

### 7.4 Matchmaking
Redis queues per (variant, format, mode). Rating‑band expansion over time (±50 → ±400). Region/latency aware. Bot fallback only in casual mode after 30s, and bots must be clearly labeled.

### 7.5 Scaling
Game server pods are stateful per match; route by `matchId` (consistent hashing via Redis registry). Live match state snapshotted to Redis every turn so another pod can resume after crash.

## 8. Feature Modules

### 8.1 Accounts & Profile
Guest (device) account → upgrade to Google / Apple / email / phone. Profile: nickname, avatar, avatar frame, country flag, title, stats per variant (games, win %, gammons, avg PR/error rate), match history with replays, achievements showcase.

### 8.2 Rating & Seasons
Separate ratings per variant (Elo‑based with match‑length weighting, FIBS formula as reference). Visible tiers: Bronze → Silver → Gold → Platinum → Diamond → Master → Grandmaster. Seasons of ~6 weeks with soft reset and season rewards (cosmetics).

### 8.3 Tournaments / Championships
- Types: **Knockout**, **Swiss**, **Round‑robin**, **Sit‑and‑go** (starts when 8/16/32 players join), **Scheduled** daily/weekly championships, **Clan championships**.
- Entry: free, coins, or invite‑only. Prize: coins, exclusive cosmetics, titles, trophies on profile.
- Bracket view live‑updating, spectate any tournament match, auto‑advance, no‑show handling, tie‑breakers (Buchholz for Swiss).
- Admin can create tournaments from Filament; also user‑created private tournaments (P1).

### 8.4 Clans
Create (cost in coins), name/tag/emblem (emblem builder from shapes+colors), description, language, min rating, open/request/invite‑only.
Roles: Leader, Co‑leader, Elder, Member — with permissions. Clan chat (text + emotes, moderation, report). Clan XP & level, clan leaderboard, weekly **Clan Wars** (two clans matched, members play assigned matches, total points win), clan tournaments, clan donations of coins to a shared chest.

### 8.5 Social
Friends (search, QR, invite link), presence, challenge friend, private room with code, spectating friends, in‑game emotes & quick phrases (no free text chat during ranked games — anti‑toxicity), block & report.

### 8.6 Customization (core differentiator)
Item categories, each independently selectable and previewable live on a board:
`board` (wood/marble/leather/etc. + point colors), `checkers` (material, color, rim, pattern), `dice` (material, pips style, color), `dice_cup`, `table_background`, `doubling_cube`, `sound_pack`, `emote_pack`, `avatar_frame`, `title`, `win_effect` (bear‑off/victory animation).
- **Loadouts**: save multiple presets (e.g. “Classic”, “Night”) and switch quickly.
- **Opponent view setting**: “Show opponent’s cosmetics” vs “Always show my theme” (accessibility + preference).
- Rarity: Common, Rare, Epic, Legendary, plus Seasonal / Tournament‑exclusive.
- All cosmetics are data‑driven: defined in DB + remote asset bundles (CDN), so new items ship **without app updates**. Asset spec: see the design brief.
- Color‑blind safe check: checker sets must pass a contrast check against board; enforce a fallback outline.

### 8.7 Economy & Store
Soft currency **Coins** (earned by playing, missions, achievements), hard currency **Gems** (IAP). Store with daily rotating offers, bundles, battle/season pass (free + premium track). Server‑side receipt validation (Google Play / App Store). No loot boxes with paid currency (legal risk) — direct purchase only.

### 8.8 Progression
Player level/XP, daily & weekly missions, achievements, login streak, onboarding tutorial (interactive, teaches both variants), practice puzzles (“find the best move”).

### 8.9 Replays & Analysis
Every game stored as `GameRecord`; replay viewer with step controls; share replay link; post‑game AI analysis (§6).

### 8.10 Offline Mode
Full offline: vs AI, pass & play, tutorial, puzzles, replays of local games, customization with owned items (inventory cached). Queue offline stats/achievements and sync when online (server re‑validates; offline games never affect rating).

### 8.11 Notifications
Your turn (async), tournament starting, clan war, friend request, season end. User‑controlled per category.

### 8.12 Settings
Language, sound/music/haptics, move confirmation on/off, auto‑roll, auto bear‑off, highlight legal moves, pip count display, animation speed, left/right‑handed board direction, color‑blind mode, theme (light/dark UI).

### 8.13 Admin (Filament)
Users (ban, mute, grant items), reports moderation queue, tournaments CRUD, cosmetics CRUD & asset upload, store offers, seasons, missions, live dashboards (CCU, matches/min, revenue), audit log.

### 8.14 Anti‑cheat & Fair Play
Server authority, provably fair dice, rate limiting, detection of engine assistance (compare move quality to AI over many games, flag outliers for review), multi‑account detection, collusion detection in tournaments, abandonment penalties.

## 9. Data Model (initial, Laravel migrations)

`users, user_devices, auth_identities, profiles, ratings (user_id, variant, rating, rd, games), seasons, season_rewards, matches, games, game_moves (or game_records JSON), tournaments, tournament_entries, tournament_rounds, tournament_pairings, clans, clan_members, clan_join_requests, clan_messages, clan_wars, clan_war_matches, friends, friend_requests, blocks, reports, items, item_assets, user_items, loadouts, currencies/wallets, wallet_transactions (ledger, append‑only), store_offers, purchases, missions, user_missions, achievements, user_achievements, notifications, audit_logs`.

Money/currency changes **only** via ledger transactions inside DB transactions with idempotency keys.

## 10. Client Architecture (Flutter)

- Feature‑first folders: `features/{auth,home,play,game,tournaments,clans,social,store,inventory,profile,settings,tutorial,replay}`.
- `GameScene` in Flame: board, checkers, dice, cube, drag & drop + tap‑tap moves, legal move highlighting, smooth 60fps animations, dice physics‑like roll animation, haptics.
- Theme engine: loads cosmetic packs (textures/sprites/sounds + JSON manifest) from cache/CDN; fallback to bundled default set.
- Responsive: phone portrait & landscape, tablet, desktop, web.
- Accessibility: screen reader labels for board state (“Point 13: 5 white checkers”), scalable text, color‑blind mode.

## 11. Non‑Functional Requirements

- Move round‑trip latency p95 < 150 ms in‑region.
- 50k CCU target architecture; load test with k6 (`tools/load/`).
- Crash‑free sessions > 99.5%.
- GDPR‑style account deletion & data export.
- Security: JWT (short‑lived) + refresh tokens, WS auth via token, all inputs validated, secrets in K8s secrets / Secret Manager.

## 12. Delivery Phases

Each phase ends with: tests green, `docs/` updated, short changelog entry.

1. **Phase 0 – Foundation**: monorepo, CI (lint, test, build), docker‑compose (MySQL, Redis, api, game_server), CLAUDE.md, DECISIONS.md.
2. **Phase 1 – Rules engine**: `nard_core` Short + Long Nard, match/cube logic, notation, ≥ 95% coverage, property‑based tests (random games never produce illegal state).
3. **Phase 2 – Offline client MVP**: Flame board, pass & play, AI Beginner→Hard (heuristic), default cosmetics, settings, i18n (az/en/ru/tr), tutorial skeleton.
4. **Phase 3 – Accounts & online core**: Laravel auth, profiles, game_server, provably fair dice, casual + ranked matchmaking, clocks, reconnection, rating.
5. **Phase 4 – Customization & store**: items, inventory, loadouts, remote asset packs, coins/gems ledger, IAP validation.
6. **Phase 5 – Social & clans**: friends, private rooms, spectating, emotes, clans, clan chat, clan wars.
7. **Phase 6 – Tournaments & seasons**: all tournament types, brackets, seasons/pass, leaderboards; neural AI + analysis mode.
8. **Phase 7 – Polish & launch**: admin panel completeness, anti‑cheat, notifications, observability, load tests, store listings.

## 13. Working Rules for Claude Code (put into `CLAUDE.md`)

- Test‑first for `nard_core`; never change rules without a failing test first.
- Keep `nard_core` pure Dart, no Flutter, no I/O.
- Server is authoritative — never trust client state.
- No hard‑coded user‑facing strings; use ARB (Flutter) / lang files (Laravel).
- Every cosmetic is data‑driven; no cosmetic logic in game rules.
- Small, focused commits per feature; conventional commit messages.
- Log non‑obvious decisions in `docs/DECISIONS.md` (ADR style).
- Before finishing a task: run formatters, analyzers (`dart analyze`, `phpstan` level 8, `pint`), and the full test suite.
- UI must follow the design files exported from Claude Design (tokens in `apps/client/lib/theme/tokens.dart` generated from the design system).

## 14. First Task for Claude Code

Start with **Phase 0 and Phase 1**. Output a short plan first, then implement. Report: what was built, test results, open questions.
