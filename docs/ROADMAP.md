# Roadmap and phase status

Source of truth for scope: [SPEC.md](SPEC.md) §12. Update this file at the
end of every phase (together with `CHANGELOG.md`).

| Phase | Scope (spec §12) | Status |
|---|---|---|
| 0 – Foundation | Monorepo, CI, docker-compose (MySQL, Redis, api, game_server), CLAUDE.md, DECISIONS.md | ✅ Done (2026-10-30) |
| 1 – Rules engine | `nard_core` Short + Long Nard, match/cube logic, notation, ≥95% coverage, property tests | ✅ Done (2026-10-30) — 108 tests, 98.6% coverage |
| 2 – Offline client MVP | Flutter + Flame board, pass & play, AI Beginner→Hard (heuristic), default cosmetics, settings, i18n az/en/ru/tr, tutorial skeleton | ⏭ Next |
| 3 – Accounts & online core | Laravel auth, profiles, game_server, provably fair dice (`docs/FAIRNESS.md`), casual + ranked matchmaking, clocks, reconnection, rating | Planned |
| 4 – Customization & store | Items, inventory, loadouts, remote asset packs, coins/gems ledger, IAP validation | Planned |
| 5 – Social & clans | Friends, private rooms, spectating, emotes, clans, clan chat, clan wars | Planned |
| 6 – Tournaments & seasons | All tournament types, brackets, seasons/pass, leaderboards; neural AI + analysis mode | Planned |
| 7 – Polish & launch | Admin completeness, anti-cheat, notifications, observability, load tests, store listings | Planned |

## Carried over / not yet done

- Flutter client (`apps/client`) not created yet — first step of Phase 2
  (add it to the pub workspace, ADR-001).
- `nard_ai`: only `RandomBot`; heuristic levels are Phase 2.
- `nard_protocol`: envelope only; payload models, `seq`, JSON-schema export
  for PHP are Phase 3.
- `game_server`: `/healthz` + WS ping/pong only; game loop is Phase 3.
- Filament admin: Phase 7 (pick a Laravel 13 compatible version, ADR-002).
- `.mat` match-file import/export: not implemented (pending answer below).
- CI workflow has not yet run on GitHub (verified locally only).

## Open questions for the product owner

1. Koks definition (ADR-009): loser has borne off nothing and still has a
   checker on own points 13–24 — correct for the AZ market?
2. Six-block rule (ADR-008): checked after every single move, or only at
   the end of the turn?
3. Long Nard "last roll for a draw" rule — wanted?
4. Long Nard opening (ADR-006): opening throw only decides who starts,
   who then rolls both dice — correct?
5. Cube cap 64, no beavers/automatic doubles (ADR-012) — acceptable?
6. `.mat` match-file import/export — wanted in addition to move notation,
   GNU BG IDs and JSON game records?
