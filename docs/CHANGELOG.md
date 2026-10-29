# Changelog

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
