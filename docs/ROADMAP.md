# Roadmap and phase status

Source of truth for scope: [SPEC.md](SPEC.md) §12. Update this file at the
end of every phase (together with `CHANGELOG.md`).

| Phase | Scope (spec §12) | Status |
|---|---|---|
| 0 – Foundation | Monorepo, CI, docker-compose (MySQL, Redis, api, game_server), CLAUDE.md, DECISIONS.md | ✅ Done (2026-10-30) |
| 1 – Rules engine | `nard_core` Short + Long Nard, match/cube logic, notation, ≥95% coverage, property tests | ✅ Done (2026-10-30) — 108 tests, 98.6% coverage |
| 2 – Offline client MVP | Flutter + Flame board, pass & play, AI Beginner→Hard (heuristic), default cosmetics, settings, i18n az/en/ru/tr, tutorial skeleton, local replay viewer (ADR-017) — mobile only (ADR-016), UI from the `nardarena-design` skill (see Design coverage) | ✅ Done (2026-10-30) — Android verified on emulator; iOS not built (no Mac) |
| 3 – Accounts & online core | Laravel auth, profiles, game_server, provably fair dice (`docs/FAIRNESS.md`), casual + ranked matchmaking, clocks, reconnection, rating | ✅ Done (2026-10-30) — single game-server pod (ADR-032); Apple/Google keys pending |
| 4 – Customization & store | Items, inventory, loadouts, remote asset packs, coins/gems ledger, IAP validation; progression: level/XP, missions, achievements, titles, login streak (ADR-017) | ✅ Done (2026-10-31) — data-driven sets (ADR-034); texture packs + store receipt APIs pending |
| 5 – Social & clans | Friends, private rooms, spectating, emotes, clans, clan chat, clan wars | ✅ Done (2026-11-01) — ADR-036/037 |
| 6 – Tournaments & seasons | All tournament types, brackets, seasons/pass, leaderboards; neural AI + analysis mode | ✅ Done (2026-11-01) — heuristic analysis; neural AI later (ADR-038–040) |
| 7 – Polish & launch | Admin completeness, anti-cheat, notifications, observability, load tests, store listings | ✅ Done (2026-11-08) — ADR-041–046; launch needs the owner's accounts/keys (docs/store/listing.md §8) |

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
| 8.2 Achievements + titles; level/XP bar on Home | 4 (ADR-017) |
| 9.0 Logo + app icon | 2 (placeholder), final in 7 |
| 9.1 Splash · 9.2 Language · 9.3 "Which nard do you play?" · 9.5 Interactive lesson (skeleton) | 2 |
| 9.4 Login or guest (Apple / Google / email / guest — no phone, ADR-020) | 3 |
| 10.1 Analysis + replay | replay viewer: 2 (ADR-017); equity analysis: 6 |
| 10.2 Settings | 2 |
| 10.3 Fair dice verification | 3 |
| Offline / empty / error / loading states | 2 (online-specific ones: 3) |
| 12.1 Daily/weekly missions · 12.2 Login streak · 12.3 Level up | 4 (ADR-017) |
| 13.x Practice puzzles | 6 |
| 14.1 Player menu · 14.2 Report reason · 14.3 Block confirm · 14.4 Report sent | 5 |
| 15.1 Account & privacy · 15.2 Export my data · 15.3 Delete account | 3 |
| 16.1 Notification settings · 16.2 Inbox · 16.3 Push permission pre-prompt | 7 |
| 17.1 Sign-in · 17.2 Enter email · 17.3 Confirm code | 3 |
| 18.1 Pass & play setup · 18.2 Hand the phone over | 2 |
| 19.1 Create clan: name, tag, emblem · 19.2 Join policy, rating, language, price | 5 |
| 20.1 Opponent found · BOT · 20.2 Game vs BOT | 3 (ADR-024) |
| 21.1 Sit-and-go lobby · 21.2 Opponent no-show · 21.3 Walkover win · 21.4 Tournament not filled | 6 |
| 22.1 Private tournament settings · 22.2 Invite / registration | 6 |
| 23.1 Crawford game · 23.2 Long Nard head rule · 23.3 Long Nard six-block | 2 |

### Screens requested from Claude Design

Delivered in the 2026-10-30 update (Ekranlar 7 and 8):
missions/streak/level-up (12), puzzles (13), report/block (14), account &
privacy (15), notifications (16), email sign-in (17), pass & play hand-over
(18), clan creation (19), BOT badge (20), sit-and-go + no-show (21), private
tournament (22), Crawford indicator and Long Nard rule messages (23).

Second round, delivered and verified 2026-10-30: AI levels Usta and
Qrossmeyster locked "Tezliklə" (2.3); phone sign-in removed (9.4, 17.1);
paid currency shown as "yaqut" everywhere, rank stays "Almaz"; 23.3
six-block example fixed (16/13 with the 3, checked against `nard_core`);
bot fallback text 30 s (20.1); subscription line removed (15.3).

No design requests are open.

### Design vs spec conflicts

- **Platforms — resolved:** mobile only (iOS + Android), as in the design
  (ADR-016).
- **Login options — resolved:** guest / Apple / Google / email; phone
  sign-in removed (ADR-020). Both changes requested from Claude Design.
- **Token file names:** spec §13 says `apps/client/lib/theme/tokens.dart`;
  the design ships `nard_tokens.dart`, `nard_colors.dart`, `nard_theme.dart`,
  `board_theme.dart` — use the design's files as-is (CLAUDE.md updated).

## Carried over / not yet done

- Sound effects: Kenney "Casino Audio" (CC0) in
  `apps/client/assets/sounds/` (owner's choice); custom sounds later
  (ADR-030).
- `.mat` match-file import/export: not planned (ADR-021).
- CI workflow has not yet run on GitHub (verified locally only).
- App/bundle ID: use placeholder `com.nardarena.app` in Phase 2; the final
  ID must be fixed before the app is first registered in App Store Connect /
  Play Console (it cannot change after that).

- Lesson (9.5): steps 1 and 3–7 were written by us (Short Nard only);
  the owner wants to **revisit the lesson content later** (ADR-030) —
  consider a Long Nard lesson and designed coach art.
- Board direction setting ("Taxta istiqaməti"): later, once both
  directions are designed (QUESTIONS #4).
- iOS build not verified: build on a Mac when available (QUESTIONS #12).
- Native-speaker review of en/ru/tr before launch (QUESTIONS #10).

- Multi-pod game server (Redis queues, match registry, per-turn snapshots,
  Redis Streams for results): after launch, when traffic needs it
  (ADR-032, QUESTIONS #15; one pod measured in docs/LOAD_TEST.md).
- IAP receipt verification (Google Play / App Store APIs): when the
  owner has store accounts (endpoints exist, disabled by config).
- Apple / Google token verification: when the owner provides keys
  (endpoints exist, disabled by config, ADR-030).

- Remote texture packs (asset contract in `docs/design-notes/store.md` §4)
  and separately equippable checkers/dice/cup/table categories (ADR-034).
- Server-side "show opponent's cosmetics" preference (local setting now).
- Item names/descriptions in ru/tr (catalog has az + en).
- Level-up reward items and per-achievement progress (API returns
  unlocked ids only).

- Tournaments (ADR-038): WS pushes for bracket updates / elimination /
  champion / cancellation (clients poll), Swiss top-8 playoff, longer
  finals, per-tournament clocks, private-tournament editing, trophy
  showcase, clan championships (admin creation is in Filament, ADR-042).

- Seasons (ADR-039): per-season mars / longest-streak stats for 7.2, more
  seasonal cosmetics for empty premium-pass levels, admin editing of season
  reward tables (Filament only lists seasons and ends them),
  season-end push notification.

- Social: QR friend codes, last-seen times, spectator count, room
  "guest joined" message, clan rename/settings UI, deep links (ADR-037).

- Infra (ADR-043, ADR-046): multi-pod game server
  (Redis queues, matchId registry, sticky routing, per-turn snapshots —
  the chart refuses replicas > 1), Grafana dashboards / alert rules,
  OpenTelemetry traces, Sentry SDKs for the Flutter client. `game.state`
  carries the full game record on every message (≈5 KB per frame on
  average in the load test, growing with the game): send deltas or only the
  last turn (docs/LOAD_TEST.md).

- Time controls (ADR-044, QUESTIONS #20): Blits 1+8 / Sürətli 3+12 /
  Klassik 5+15 done (separate queues, room clock, 2.2 tiles, 6.3 room and
  friend challenges). Later: Gündəlik (correspondence), per-tournament
  clocks. The API stores it (`game_matches.time_control`, in match
  summaries; `challenges.time_control`).

- Neural AI (spec §6 v2) — training pipeline, on-device model, unlocks
  Usta/Qrossmeyster, real equity in analysis (QUESTIONS #39).
- Tournament pushes (eliminated/champion/cancelled), trophy showcase,
  private tournament editing, Swiss playoff, season mars/streak stats.

## Open questions for the product owner

1. Cube cap 64, no beavers/raccoons/automatic doubles (ADR-012) — current
   default; change only if needed.

Resolved 2026-10-30: platforms → mobile only (ADR-016); progression →
Phase 4, replay viewer → Phase 2 (ADR-017); koks, six-block per move,
Long Nard opening, no draw rule (ADR-006/008/009); languages az/en/ru/tr
with English fallback (ADR-018); AI levels 5–6 locked until Phase 6
(ADR-019); sign-in = guest/Apple/Google/email, no phone (ADR-020); no `.mat` files (ADR-021); coins never purchasable (ADR-022);
paid currency named Yaqut (ADR-023); bot fallback after 30 s (ADR-024);
no subscription at launch (ADR-025).
