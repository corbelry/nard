# Changelog

## Phase 3 — Accounts & online core (2026-10-30)
- `nard_core`: provably fair dice `FairDice` (HMAC-SHA256, no modulo bias,
  `docs/FAIRNESS.md`).
- `nard_protocol`: typed payloads, `game.seed`, `MatchResult` + JSON schema
  (`docs/PROTOCOL.md`, ADR-031).
- `game_server`: authoritative `MatchRoom` (server-side pending moves,
  clocks 3+12, 60 s reconnect grace, forfeits), `BotDriver`, signed tickets,
  matchmaker (rating band ±50→±400, casual bot after 30 s), WebSocket hub,
  signed result reporting to the API (ADR-032: one pod until Phase 7).
- `api`: Sanctum; guest device accounts, e-mail codes (Mailpit), Apple /
  Google endpoints disabled until keys exist; profile, export, delete;
  game tickets; match-result ingestion with FIBS Elo and tiers.
- Client: sign-in, online setup, searching, VS, BOT seat, clocks, low time,
  reconnect/offline states, fair-dice verification, profile, account &
  privacy, rating card (ADR-033); CC0 sound effects.
- End-to-end test on docker compose (`apps/game_server/tool/e2e.dart`) in
  CI; compose API now keeps its environment (was silently using `.env`).

## Phase 2 — Offline client MVP (2026-10-30)
- `nard_core`: `TurnPlanner.explain` → `MoveRejection` for rule banners
  (ADR-026); 98.6% coverage.
- `nard_ai`: heuristic evaluator, `HeuristicBot` levels Başlanğıc…Güclü
  with 2-ply search for Güclü, cube decisions (ADR-027).
- `apps/client` (Flutter 3.29, mobile only): vendored design theme, fonts,
  az/en/ru/tr; Flame board (drag + tap, animations, highlights, dice, cube,
  portrait/landscape); vs computer and pass & play (hand-over screen, board
  flip, undo); cube, resign, menu, rules sheets; illegal-move toasts;
  Crawford chip; match result; splash, language, onboarding, 7-step lesson,
  home, setup, AI level, settings, replay list + viewer; Drift storage for
  settings and finished games; placeholder app icon (ADR-028/029/030).
- CI: Flutter client job; workspace resolved with the Flutter SDK; the
  game_server image drops the client from the workspace.

## Phase 1 — Rules engine (2026-10-30)
- `nard_core`: Short Nard and Long Nard rule sets, move generator with
  max-dice / larger-die rules, Long Nard head and six-block rules,
  doubling cube, Jacoby, Crawford match logic, resignation, game state
  machine with validated actions, replayable JSON game records, move
  notation, GNU BG Position ID / Match ID.
- 108 tests incl. property tests and an independent move-generation
  oracle; 98.6% line coverage.

## Phase 0 — Foundation (2026-10-30)
- Dart pub workspace, shared lints, CI (format, analyze, tests, coverage
  gate, Laravel pint/phpstan/tests, Docker builds).
- Skeletons: `nard_ai` (RandomBot), `nard_protocol` (envelope),
  `game_server` (health, WS ping/pong), Laravel 13 API.
- `infra/docker-compose.yml` with MySQL 8.4, Redis 7.4, api, game_server.
