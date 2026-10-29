# NardArena — working rules for Claude Code

**Start every session with `docs/HANDOFF.md`** (current state, next step,
how to work with the product owner).

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
- The client is mobile only: iOS + Android, phone portrait/landscape, tablet
  as a scaled phone layout — no web/desktop work (ADR-016).
- UI must follow the `nardarena-design` skill (`.claude/skills/nardarena-design`,
  exported from Claude Design): copy its `flutter/lib/theme/` into
  `apps/client/lib/theme/` and map every visual value to those tokens
  (`context.nard.*`, `NardSpace`, `NardRadius`, `NardMotion`, `NardType`);
  never hard-code colors. Screen references are its `*.dc.html` files; which
  phase builds which screen is in `docs/ROADMAP.md`.

## Before finishing a task
```
dart format packages apps/game_server $(find apps/client/lib apps/client/test -name '*.dart' -not -path '*/theme/*' -not -path '*/gen/*' -not -name '*.g.dart')
dart analyze --fatal-infos
(cd packages/nard_core && dart run coverage:test_with_coverage && dart run tool/check_coverage.dart 95)
(cd packages/nard_ai && dart test); (cd packages/nard_protocol && dart test); (cd apps/game_server && dart test)
(cd apps/client && flutter gen-l10n && flutter test)   # drift: dart run build_runner build -d
# API (local PHP lacks extensions; use the dev image):
docker build -t nard-api:dev apps/api && docker run --rm nard-api:dev sh -c \
  'vendor/bin/pint --test && vendor/bin/phpstan analyse --no-progress --memory-limit=1G && cp .env.example .env && php artisan key:generate -q && php artisan test'
```

## Layout
- `apps/client` Flutter app (`lib/theme` vendored from the design skill,
  excluded from analysis; design specs in `docs/design-notes/`) ·
  `packages/nard_core` rules engine · `packages/nard_ai` bots ·
  `packages/nard_protocol` WS models · `apps/game_server` Dart server ·
  `apps/api` Laravel · `infra/` compose/helm · `docs/`.
- Local stack: `docker compose -f infra/docker-compose.yml up --build`
  (ports 13306/16379/18000/18080).
