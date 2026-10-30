# Session handoff — start here

Last updated: 2026-11-08. **All spec phases (0–7) are done.** Next: the
post-Phase-7 backlog below (owner picks the order), then launch steps that
need the owner's accounts (docs/store/listing.md §8).

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

## Phase 7 — done (2026-11-08)

Notifications (ADR-041), Filament admin + fair play (ADR-042), client
moderation (QUESTIONS #41), observability / load test / Helm / MySQL CI
(ADR-043), time controls (ADR-044), live moderation + WebSocket limits
(ADR-045), security review fixes incl. admin MFA (ADR-046), store listing
drafts, and every owner answer in `docs/QUESTIONS.md` (all answered
2026-10-30). Summary in `docs/CHANGELOG.md`.

## Post-Phase-7 backlog (ask the owner for the order)

1. DONE 2026-11-08: emulator smoke on the rebuilt stack — 2.2 tiles, Blits
   search chip "1+8s", bot fallback game on the 1-min clock, 15.2 guest
   sheet ("E-poçt bağla"); fixed the misleading match count (ce9f760).
   Local admin now needs an authenticator app on first `/admin` sign-in.
2. DONE 2026-11-08: production API image — `apps/api/Dockerfile` target
   `production`, FrankenPHP classic mode, uid 10001 on a read-only root,
   chart uses it (ADR-047).
3. DONE 2026-11-08: time choice in the 6.3 room (Vaxt row → 2.2 tiles)
   and friend challenges (`POST /challenges` `timeControl`, shown on 6.1,
   inbox and join; ADR-044 amendment, docs/api/social.md).
4. `game.state` deltas instead of the full record (docs/LOAD_TEST.md).
5. Other carry-overs in `docs/ROADMAP.md` ("Carried over / not yet done").
Owner-only before launch: store accounts + IAP keys, Apple/Google sign-in
keys, FCM keys, hosting + domain (support mailbox, deletion page URL,
`ingress.adminAllowlist`), final bundle id, native translation review.

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
  `docker build apps/api` is the dev image (default, last stage); the
  production image is `--target production` (ADR-047).
- Host ports 3306/6379/8000 are taken on this machine; compose uses
  13306/16379/18000/18080.
- gnu.org rate-limits fetches; the gnubg source mirror on GitHub
  (`mormegil-cz/gnubg`) worked.

