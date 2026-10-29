# Changelog

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
