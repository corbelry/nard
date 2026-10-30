# Session handoff — start here

Last updated: 2026-11-01. Next step: **Phase 7 – Polish & launch**.

## Working with the product owner

- Reply in **Turkish** (they also write short Azerbaijani prompts, e.g.
  "davam et" = continue). Code, commits and repo docs stay in English.
- For product decisions, ask multiple-choice questions with a recommended
  option first, then record the answer as an ADR in `docs/DECISIONS.md`.
- Never add `Co-Authored-By` lines to commits (global rule).
- Commit on the feature branch after each step; **do not push or merge**
  without asking.

## Unattended work protocol (agreed 2026-10-30)

When the product owner is away, keep going — including from one phase to the
next — without waiting for approval (start only after they say "başla").

- **State lives on disk.** Update this file after every step (done / next /
  half-done). After a context compaction, re-read this file first.
- **Questions** go to `docs/QUESTIONS.md` with a recommended option and the
  assumption used. Reversible decisions: apply the recommended option, mark it
  "assumed", continue; revisit when the owner answers.
- **Never alone:** irreversible or account-bound steps (Apple/Google sign-in
  keys, store registration, payments, final bundle ID) — stub and move on.
- **Commits:** small commit after each step on the feature branch; no push or
  merge; no `Co-Authored-By`.
- **Lean context:** delegate large files (design `*.dc.html`) to subagents,
  read only what's needed, keep only tails/errors of test output.
- **Phase end:** run the CLAUDE.md checks, update ROADMAP / CHANGELOG /
  DECISIONS / this file, commit, write the next phase's plan here, start it.
- **Limits:** the session can stop (usage limit, permission prompt, machine
  sleep) — resume from this file on "davam et". iOS can't be built on this
  Linux machine; verify with tests + Android.

## Phase 7 progress (update after every step)

- [x] 1. Notifications (16.1–16.3, ADR-041): design spec
  `docs/design-notes/notifications.md`, API (inbox, settings, devices,
  `Notifier` wired into social/clan/tournament/season/progression, FCM
  sender disabled until `FCM_PROJECT_ID`/`FCM_CREDENTIALS`, queue worker in
  compose), client (bell + 60 s polling, 16.2 inbox, 16.1 settings, 16.3
  pre-prompt, no-op `PushRegistrar`), `docs/api/notifications.md`.
  Not committed yet. Next: Filament admin (plan item 1).

Phase 6 is done (CHANGELOG, ADR-038…040). After changing api or
game_server, rebuild their compose containers before emulator tests.

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

## Phase 7 plan (spec §12 phase 7, §8.11, §8.13, §8.14, §11, design 16.x)

Done when: admins can moderate and run the game from Filament, cheating
signals are flagged, players get push + inbox notifications, services are
observable, load tests pass targets, and store listings are drafted.
Several items need the owner (store accounts, Firebase/APNs keys, hosting):
build them stubbed/disabled by config like Apple/Google sign-in.

1. Filament admin (pick a Laravel 13 compatible version, ADR-002): users
   (ban/mute), reports queue, tournaments, items/offers, seasons, clans,
   ledger view (read-only), puzzles.
2. Anti-cheat signals: engine-assistance check (compare moves to the bot
   over many games, flag outliers), multi-account (device ids), abandonment
   penalties, report thresholds.
3. Notifications: inbox (16.2), settings (16.1), push permission pre-prompt
   (16.3); FCM/APNs sending disabled until keys; events (friend request,
   challenge, tournament start, clan war, season end).
4. Observability: structured logs, health/readiness, Prometheus metrics in
   game_server + API, Sentry DSN by config (no keys committed).
5. Load tests (k6 or Dart script) for WS rooms and API hot paths;
   performance budget from spec §11.
6. Hardening: MySQL test job in CI, rate limits review, security review of
   the diff (`/security-review`), Helm/k8s manifests in `infra/`, store
   listing drafts (texts in az/en/ru/tr), final bundle id question.
