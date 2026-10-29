# Roadmap and phase status

Source of truth for scope: [SPEC.md](SPEC.md) §12. Update this file at the
end of every phase (together with `CHANGELOG.md`).

| Phase | Scope (spec §12) | Status |
|---|---|---|
| 0 – Foundation | Monorepo, CI, docker-compose (MySQL, Redis, api, game_server), CLAUDE.md, DECISIONS.md | ✅ Done (2026-10-30) |
| 1 – Rules engine | `nard_core` Short + Long Nard, match/cube logic, notation, ≥95% coverage, property tests | ✅ Done (2026-10-30) — 108 tests, 98.6% coverage |
| 2 – Offline client MVP | Flutter + Flame board, pass & play, AI Beginner→Hard (heuristic), default cosmetics, settings, i18n az/en/ru/tr, tutorial skeleton — UI from the `nardarena-design` skill (see Design coverage) | ⏭ Next |
| 3 – Accounts & online core | Laravel auth, profiles, game_server, provably fair dice (`docs/FAIRNESS.md`), casual + ranked matchmaking, clocks, reconnection, rating | Planned |
| 4 – Customization & store | Items, inventory, loadouts, remote asset packs, coins/gems ledger, IAP validation | Planned |
| 5 – Social & clans | Friends, private rooms, spectating, emotes, clans, clan chat, clan wars | Planned |
| 6 – Tournaments & seasons | All tournament types, brackets, seasons/pass, leaderboards; neural AI + analysis mode | Planned |
| 7 – Polish & launch | Admin completeness, anti-cheat, notifications, observability, load tests, store listings | Planned |

## Design coverage (nardarena-design skill)

Design source: `.claude/skills/nardarena-design` (exported from Claude Design;
screen references are the `*.dc.html` files, numbered as below). Every
design screen mapped to the phase that builds it:

| Design screen | Phase |
|---|---|
| Design system foundations, components, board states (portrait 390×844 / landscape 844×390) | 2 |
| GameScreen: no legal move banner, cube offer sheet, victory (Mars) | 2 (engine support done in 1) |
| GameScreen: opponent reconnecting / reconnect countdown | 3 |
| 2.1 Home · 2.2 Game setup · 2.3 vs computer level · 2.6 Match result · 2.8 Resign · 2.9 Game menu | 2 (online parts of 2.1/2.6, e.g. rating change: 3) |
| 2.4 Searching opponent · 2.5 VS | 3 |
| 2.7 Emote wheel + quick phrases | 5 |
| 3 · Default cosmetic theme | 2 |
| 3 · Other 5 cosmetic themes, 3.1 Locker (loadouts, show opponent cosmetics), 3.2 Item detail, asset spec / remote packs | 4 |
| 4.1 Tournament list · 4.2 Detail · 4.3 Live bracket · 4.4 Swiss standings · 4.5 Champion ceremony | 6 |
| 5.1 Clan search · 5.2 Profile · 5.3 Emblem builder · 5.4 Clan chat · 5.5 Members/management · 5.6 Clan war · 5.7 Clan leaderboard | 5 |
| 6.1 Friends · 6.2 Add friend · 6.3 Private room · 6.4 Spectator view | 5 |
| 6.5 Leaderboard · 7.1 Season pass · 7.2 Season summary | 6 |
| 7.3 Store · 7.4 Confirm purchase · 7.5 Purchase success | 4 |
| 8.1 Profile + statistics | 3 |
| 8.2 Achievements + titles; level/XP bar on Home | **no phase in spec §12** — proposed: 4 (with economy) |
| 9.0 Logo + app icon | 2 (placeholder), final in 7 |
| 9.1 Splash · 9.2 Language · 9.3 "Which nard do you play?" · 9.5 Interactive lesson (skeleton) | 2 |
| 9.4 Login or guest (Apple / Google / phone / guest) | 3 |
| 10.1 Analysis + replay | replay viewer: **no phase in spec §12** — proposed: 2 (local replays are an offline feature, §8.10); equity analysis: 6 |
| 10.2 Settings | 2 |
| 10.3 Fair dice verification | 3 |
| Offline / empty / error / loading states | 2 (online-specific ones: 3) |

### Screens requested from Claude Design (spec features with no design yet)

Found by keyword search of the design files (2026-10-30); tick off when the
design is updated and re-exported into the skill.

- [ ] Daily/weekly missions + login streak + level-up moment (§8.8) — Phase 4
- [ ] Practice puzzles "find the best move" (§8.8) — Phase 2/6
- [ ] Report player + block flow (§8.5) — Phase 5
- [ ] Account & privacy: delete account, export data (§11) — Phase 3
- [ ] Notification preferences per category + inbox + push permission (§8.11) — Phase 7
- [ ] Pass & play hand-over screen between turns (§1) — Phase 2
- [ ] Clan creation flow: cost, name/tag, open/request/invite, min rating, language (§8.4) — Phase 5
- [ ] Bot badge for casual bot fallback (§7.4) — Phase 3
- [ ] Sit-and-go waiting lobby (8/16/32) and no-show states (§8.3) — Phase 6
- [ ] User-created private tournament (§8.3, P1) — Phase 6
- [ ] Email sign-in option (§8.1) — Phase 3
- [ ] Crawford-game indicator on the match game screen (§2) — Phase 2
- [ ] Long Nard rule feedback: head rule and six-block illegal-move messages (§2) — Phase 2

### Design vs spec conflicts (need a decision)

- **Platforms:** the design says *mobile only, no web or desktop*; spec §3 and
  §10 list Web and Windows/macOS plus desktop/web layouts.
- **Login options:** design shows Apple / Google / phone / guest; spec §8.1
  also lists email.
- **Token file names:** spec §13 says `apps/client/lib/theme/tokens.dart`;
  the design ships `nard_tokens.dart`, `nard_colors.dart`, `nard_theme.dart`,
  `board_theme.dart` — use the design's files as-is (CLAUDE.md updated).

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
7. Progression (level/XP, missions, achievements, titles, login streak,
   spec §8.8) and the replay viewer (§8.9) have no phase in §12 — OK to put
   progression in Phase 4 and the replay viewer in Phase 2?
8. Platforms: design is mobile-only, spec includes web and desktop — which
   one wins?
