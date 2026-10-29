# Session handoff — start here

Last updated: 2026-10-30. Next step: **Phase 4 – Customization & store**.

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

## Phase 4 progress (update after every step)

- [x] 1. API economy: `items` (seeded: design's 6 boards + default
  checkers/dice/cube, placeholder prices), `user_items`, `loadouts`,
  `wallets` + append-only `wallet_transactions` with idempotency keys;
  `WalletService` (coins earn-only enforced, ADR-022), `StoreService`;
  endpoints catalog / inventory / purchase / loadouts. Compose seeds on
  start. Theme files restored byte-for-byte + guard test.
- [ ] 2. Rewards & progression (API) — next.

Phase 3 is done (CHANGELOG, ADR-031…033). Leftovers: Apple/Google token
verification (needs keys), multi-pod Redis (Phase 7), iOS build, lesson
content revisit.

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

## Phase 4 plan (spec §8.6–8.8, ADR-017/022/023/025)

Done when: a player earns coins and XP by playing, completes missions and a
login streak, levels up, buys cosmetics with coins (or Yaqut via a stubbed
IAP), equips them in loadouts, sees them live on the board (and the
opponent's, if enabled), and new items can ship without an app update;
tests green; docs updated.

1. **API catalog & economy**: `items` (category, rarity, price in coins and/or
   Yaqut, data JSON for colors, asset pack URL + version, availability),
   `user_items`, `loadouts`, wallet ledger (`wallet_transactions`, balances
   derived; coins earn-only ADR-022, Yaqut = `gems` ADR-023); endpoints:
   catalog, inventory, purchase, loadouts, equip. Seed the design's 6 board
   themes and default checker/dice sets.
2. **Rewards & progression (API)**: coins + XP per finished match (from the
   match-result ingest; casual/ranked/bot amounts in config), levels, daily
   and weekly missions, login streak, achievements + titles (ADR-017).
3. **IAP**: server-side receipt validation endpoints for Google Play / App
   Store, disabled until the owner has store accounts (stub like ADR-030);
   Yaqut packs + premium pass products defined in config (no subscription,
   ADR-025).
4. **Client cosmetics**: data-driven `BoardTheme`/checker/dice sets from the
   catalog (the design's `BoardTheme.all` as built-ins), remote asset packs
   downloaded + cached, "show opponent's cosmetics" setting, opponent loadout
   in `match.found` (PlayerInfo gets cosmetics), live preview.
5. **Client screens**: Locker 3.1, item detail 3.2, store 7.3, confirm 7.4,
   success 7.5, missions 12.1, streak 12.2, level up 12.3, achievements +
   titles 8.2, level/XP on Home, rewards on 2.6. Get a design spec first
   (`docs/design-notes/store.md`, subagent).
6. Tests, docs, CHANGELOG; ask the owner about prices/rewards (QUESTIONS).
