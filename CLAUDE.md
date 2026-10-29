# NardArena — working rules for Claude Code

Master spec: `docs/SPEC.md` (phases in §12). Phase status, carried-over work and
open questions: `docs/ROADMAP.md` — read it first and update it at the end of
every phase. Decisions: `docs/DECISIONS.md`.
Rules catalogues: `docs/RULES_SHORT.md`, `docs/RULES_LONG.md`.

## Rules
- Test-first for `nard_core`; never change rules without a failing test first.
  Name tests after the rule ID they prove (e.g. `SN-10 ...`, `LN-06 ...`).
- Keep `nard_core` pure Dart: no Flutter, no I/O, no dice generation inside
  rules (dice are inputs).
- Server is authoritative — never trust client state; feed client intents
  through `GameState.apply`.
- No hard-coded user-facing strings; use ARB (Flutter) / lang files (Laravel).
- Every cosmetic is data-driven; no cosmetic logic in game rules.
- Small, focused commits per feature; conventional commit messages.
- Log non-obvious decisions in `docs/DECISIONS.md` (ADR style).
- UI must follow the design files exported from Claude Design (tokens in
  `apps/client/lib/theme/tokens.dart` generated from the design system).

## Before finishing a task
```
dart format packages apps/game_server
dart analyze --fatal-infos
(cd packages/nard_core && dart run coverage:test_with_coverage && dart run tool/check_coverage.dart 95)
(cd packages/nard_ai && dart test); (cd packages/nard_protocol && dart test); (cd apps/game_server && dart test)
# API (local PHP lacks extensions; use the dev image):
docker build -t nard-api:dev apps/api && docker run --rm nard-api:dev sh -c \
  'vendor/bin/pint --test && vendor/bin/phpstan analyse --no-progress --memory-limit=1G && cp .env.example .env && php artisan key:generate -q && php artisan test'
```

## Layout
- `packages/nard_core` rules engine · `packages/nard_ai` bots ·
  `packages/nard_protocol` WS models · `apps/game_server` Dart server ·
  `apps/api` Laravel · `infra/` compose/helm · `docs/`.
- Local stack: `docker compose -f infra/docker-compose.yml up --build`
  (ports 13306/16379/18000/18080).
