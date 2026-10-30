# Session handoff — start here

Last updated: 2026-10-31. Next step: **Phase 5 – Social & clans**.

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

## Phase 5 progress (update after every step)

- [x] 1. Social API: friend codes (8 chars, no look-alikes), requests
  (crossed requests auto-accept), accept/decline/cancel/unfriend, search
  (prefix, hides blocks), blocks (end friendships), reports (reasons from
  config, daily limit, reference R-000001), presence via `TouchLastSeen`
  (online = seen within 120 s). 32 API tests.
- [ ] 2. Private rooms + friend challenges + spectating + emotes
  (game server) — next.

Phase 4 is done (CHANGELOG, ADR-034/035). Leftovers: texture packs, store
receipt APIs, Apple/Google keys, iOS build, lesson content, Redis scaling.

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

## Phase 5 plan (spec §8.4–8.5, design 2.7, 5.x, 6.1–6.4, 14.x, 19.x)

Done when: players add friends (search / invite code), see presence,
challenge a friend or play in a private room with a code, spectate,
send emotes and quick phrases in games (no free text in ranked), block and
report; create/join clans (name, tag, emblem, join policy, roles), chat in
the clan, see the clan leaderboard and play a clan war; tests green; docs.

1. **API social**: friends + friend requests, blocks, reports (14.x),
   presence via game-server heartbeat (Redis-free: last-seen in DB/cache).
2. **Private rooms & challenges**: game server rooms created by code
   (`room.create` / `room.join`), friend challenge = private room invite.
3. **Spectating**: read-only subscribers on `MatchRoom` (`spectate.join`),
   delayed clocks hidden info none (backgammon has no hidden state).
4. **Emotes & quick phrases** (2.7): `chat.emote` relayed by the room with
   rate limit; default emote pack item; mute opponent.
5. **Clans API**: clans (name, tag, emblem JSON from the 5.3 builder,
   language, min rating, join policy open/request/invite, coin cost from
   the wallet), members + roles, join requests, clan chat (HTTP + polling or
   WS relay, moderation/report), clan XP and leaderboard, clan war
   (pairings, assigned matches, scoring).
6. **Client screens**: 6.1 friends, 6.2 add friend, 6.3 private room, 6.4
   spectator, 2.7 emote wheel, 14.1–14.4 player menu/report/block, 5.1–5.7
   clans, 19.1–19.2 create clan. Design spec first
   (`docs/design-notes/social.md`, subagent), then implementation subagent.
7. Tests (API features, room relay, e2e extension), docs, CHANGELOG.
