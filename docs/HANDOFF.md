# Session handoff — start here

Last updated: 2026-10-30. Next step: **Phase 2 – Offline client MVP**.

## Working with the product owner

- Reply in **Turkish** (they also write short Azerbaijani prompts, e.g.
  "davam et" = continue). Code, commits and repo docs stay in English.
- For product decisions, ask multiple-choice questions with a recommended
  option first, then record the answer as an ADR in `docs/DECISIONS.md`.
- Never add `Co-Authored-By` lines to commits (global rule).
- Commit on the feature branch after each step; **do not push or merge**
  without asking.

## Where things stand

- Branch `feat/foundation-and-rules-engine` (not pushed; `main` is behind).
- Phase 0 and Phase 1 are done (see `docs/CHANGELOG.md`): Dart workspace, CI
  workflow (never run on GitHub yet), docker-compose stack, Laravel 13 API
  skeleton, `nard_core` rules engine (108 tests, 98.6% coverage, verified
  against an independent oracle), skeletons for `nard_ai`, `nard_protocol`,
  `game_server`.
- Product decisions: ADR-001…025 in `docs/DECISIONS.md`. The ones that shape
  Phase 2: mobile only (ADR-016), replay viewer in Phase 2 (ADR-017),
  az/en/ru/tr with English fallback (ADR-018), AI levels 1–4 playable and
  Usta/Qrossmeyster locked "Tezliklə" (ADR-019), Long Nard rules confirmed
  (ADR-006/008/009).
- Design: the `nardarena-design` skill in `.claude/skills/nardarena-design`
  (exported from Claude Design). Screen-to-phase mapping: `docs/ROADMAP.md`.
  All requested design fixes were delivered and verified; none are open.

## Environment notes

- Flutter 3.29.2 / Dart 3.7.2 (`/media/dev/Development/SDK/flutter`).
  Dart pub workspaces are supported by this version.
- Local PHP 8.3 lacks mbstring/dom/pdo — run API checks in the
  `apps/api/Dockerfile` image (command in `CLAUDE.md`).
- Host ports 3306/6379/8000 are taken on this machine; compose uses
  13306/16379/18000/18080.
- gnu.org rate-limits fetches; the gnubg source mirror on GitHub
  (`mormegil-cz/gnubg`) worked.

## Phase 2 plan (spec §12 + ADRs)

Done when: everything below works offline on Android and iOS, tests are
green, `docs/` (ROADMAP, CHANGELOG, DECISIONS) are updated.

1. **Engine additions (test-first, `nard_core`).** An API that explains why a
   move is illegal (head rule, six-block, closed point, must enter from the
   bar, must use both dice / the larger die, bearing off not allowed yet),
   needed by the design's illegal-move banners (23.2, 23.3). Keep coverage
   ≥ 95%.
2. **Create `apps/client`.** `flutter create --org com.nardarena
   --project-name nard_client --platforms ios,android apps/client`
   (bundle ID is a placeholder, see ROADMAP); add it to the root workspace
   (`resolution: workspace`); depend on `nard_core`, `nard_ai`.
   Packages: flame, flutter_riverpod, go_router, drift (+ sqlite3_flutter_libs),
   flutter_localizations, intl, lucide_icons. Check versions work with
   Flutter 3.29.2.
3. **Theme.** Copy the skill's `flutter/lib/theme/` into
   `apps/client/lib/theme/` unchanged; follow the skill's `flutter/README.md`
   (fonts into `assets/fonts/`, OFL; default theme `sebeke`). Every visual
   value comes from these tokens.
4. **i18n.** ARB files with Azerbaijani as the template (`app_az.arb`), plus
   en/ru/tr; English fallback; language picker on first launch (9.2). Copy
   rules: the skill's `readme.md` "CONTENT FUNDAMENTALS".
5. **AI (`nard_ai`).** Heuristic evaluator (pip count, blots, primes,
   anchors, home-board strength, race) with 1-ply / 2-ply expectiminimax;
   levels Başlanğıc, Həvəskar, Orta, Güclü via noise / blunder rate; cube
   decisions for Short Nard; runs in an Isolate with a thinking delay.
6. **Game screen (Flame).** `BoardGeometry` 640×H logical space, portrait
   and landscape; drag and tap-tap moves driven by `TurnPlanner.nextMoves`;
   undo before confirm; highlights / ghost checkers / numbers drawn in code;
   motion tokens; haptics; cube offer sheet, resign (2.8), menu (2.9), no
   legal move banner, Crawford indicator (23.1), Long Nard rule banners
   (23.2, 23.3), match result (2.6).
7. **Screens.** Splash 9.1, language 9.2, "which nard" 9.3, lesson skeleton
   9.5, home 2.1 (offline parts), setup 2.2, AI level 2.3, pass & play
   18.1 / 18.2, settings 10.2, local replay viewer, offline / empty / error
   states. Default cosmetic theme only (others are Phase 4).
8. **Storage (Drift).** Settings, local `GameRecord`s (JSON) for replays,
   local stats. Offline games never affect rating (spec §8.10).
9. **CI.** Add a Flutter job (format, analyze, test) to
   `.github/workflows/ci.yml`.

Suggested order: 1 → 2 → 3 → 4 → 6 (pass & play first, no AI) → 5 → 7 → 8 → 9,
committing after each step.
