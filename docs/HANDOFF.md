# Session handoff — start here

Last updated: 2026-10-30. Next step: **Phase 3 – Accounts & online core**.

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

## Phase 3 progress (update after every step)

- [x] 1. Provably fair dice: `FairDice` in nard_core, `docs/FAIRNESS.md`
  (FD-01…05, vectors from an independent Python script).
- [x] 2. Protocol payloads (`nard_protocol`: messages, `game.seed`,
  `MatchResult` + JSON schema), `docs/PROTOCOL.md`.
- [x] 4. game_server: `MatchRoom` (fair dice, server-side pending moves,
  clocks, reconnect grace, results), `BotDriver`, signed `Ticket`s,
  in-memory `Matchmaker` (band ±50→±400, casual bot at 30 s), `Hub` (WS ↔
  rooms, takeover on reconnect); e2e test over real WebSockets. Results go
  to `MemoryResultSink` until the API endpoint exists. Redis snapshots /
  multi-pod queue: step 5.
- [x] 3. API (Laravel 13 + Sanctum): guest/device accounts, e-mail codes
  (Mailpit in compose), Apple/Google endpoints disabled by config (501
  when enabled — token verification still to do), profile edit, export,
  delete (15.x), match history, signed game tickets, signed match-result
  ingestion with FIBS Elo + tiers; 13 feature tests. game_server posts
  results via `HttpResultSink` (`API_URL`).
- [x] 7. End-to-end on docker compose: `apps/game_server/tool/e2e.dart`
  (2 guests → tickets → ranked match on the server → API records match +
  FIBS rating → e-mail sign-in via Mailpit) passes. Fixed: compose api ran
  `artisan serve`, which drops DB_/REDIS_ env → now `php -S` from public/.
- [ ] 6. Client online mode — next (sign-in 9.4/17.x, online play, search
  2.4, VS 2.5, BOT 20.x, reconnect, clocks, fair-dice verify 10.3, profile
  8.1, account 15.x). First get specs from the design files into
  `docs/design-notes/online.md` with a subagent.
- [→] 5. Redis queues/snapshots/registry deferred to Phase 7 (ADR-032).

Phase 2 is done (see CHANGELOG, ADR-026…030). Leftovers: lesson
content revisit, iOS build (sounds done: Kenney CC0).

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

## Phase 3 plan (spec §7, §8.1–8.2, §12 + ADRs)

Done when: two clients can sign in (guest / e-mail code), find each other
(casual + ranked) or get a labelled bot after 30 s in casual, play a full
match on the authoritative server with clocks, reconnect within 60 s,
verify the dice afterwards, and see rating changes on the result screen;
tests green; docs updated.

1. **Provably fair dice** (spec §7.1): HMAC-SHA256(serverSeed,
   clientSeedA|clientSeedB|N) → dice without modulo bias, as a `DiceSource`
   (not inside rules) shared by server and client verification; test
   vectors; `docs/FAIRNESS.md`.
2. **Protocol** (`nard_protocol`): typed payloads for the §7.2 messages,
   `seq` ordering, errors (reuse `MoveRejection`), JSON-schema export for
   PHP; `docs/PROTOCOL.md`.
3. **API (Laravel)**: guest device accounts, e-mail code sign-in (Mailpit in
   compose, ADR-030), Apple/Google built but disabled by config; Sanctum
   tokens; profiles (nickname, avatar, flag); per-variant ratings (Elo with
   match-length weighting, FIBS reference) and tiers; match history;
   game-server tickets (signed); results via Redis Streams + signed HTTP.
   Run checks in the Docker image (CLAUDE.md).
4. **game_server**: ticket auth, rooms per match feeding intents through
   `GameState.apply`, clocks (reserve + delay, §7.3), 60 s reconnect grace,
   Redis snapshots per turn, result publishing; bots via `nard_ai` for the
   casual fallback (ADR-024).
5. **Matchmaking** in Redis: queues per (variant, format, mode), rating
   band ±50 → ±400 over time, casual bot fallback at 30 s.
6. **Client**: sign-in 9.4 / 17.1–17.3, online mode on Home, searching 2.4,
   VS 2.5, BOT badge 20.x, reconnect states, low-time state, fair-dice
   verification 10.3, profile + stats 8.1, account & privacy 15.x, offline
   banner; online parts of 2.1 / 2.6 (rating change). Ask the design spec
   subagents for these screens first (`docs/design-notes/online.md`).
7. **Infra/CI**: Mailpit, env docs, end-to-end test (two simulated clients
   against game_server + API in compose).

Suggested order: 1 → 2 → 4 (local rooms, no auth) → 3 → 5 → 6 → 7.
