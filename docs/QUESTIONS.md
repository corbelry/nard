# Open questions for the product owner

Collected while working unattended (see `HANDOFF.md` → Unattended work
protocol). Each entry: question, options (recommended first), and the
assumption currently implemented. Answer them and the code is adjusted.

| # | Phase | Question | Options (recommended first) | Assumed now | Status |
|---|---|---|---|---|---|
| 1 | 2 | Should the default board show the xatəm inlay frame seen in the sebeke GameScreen mock? | a) Plain walnut now, inlay as a Phase 4 cosmetic · b) Inlay on the default board | a | answered 2026-10-30: a |
| 2 | 2 | What should "İpuçlarını göstər" (2.3) do? | a) Omit offline; add a "best move" hint with the Phase 6 analysis · b) Highlight the bot's suggested move now · c) Same as "show legal moves" | a (row hidden) | answered 2026-10-30: a |
| 3 | 2 | Sound effects: there are no audio assets yet. | a) Licensed CC0 pack now (dice, checker, hit), custom sounds in Phase 7 · b) Wait for custom sounds | Setting exists, no sounds play | answered 2026-10-30: a (implementing) |
| 4 | 2 | "Taxta istiqaməti" (board direction) has only "Saat əqrəbi" in the design. | a) Phase 7, with a mirrored layout and both values designed · b) Build now | not built | open |
| 5 | 2 | AI "~elo" labels on 2.3 | a) Hide until calibrated (Phase 6) · b) Show the design's illustrative numbers | a | answered 2026-10-30: a |
| 6 | 2 | Lesson: only step 2 was designed; we wrote steps 1, 3–7 (Short Nard basics). | a) Keep, review copy · b) Add a Long Nard lesson · c) Ask Claude Design for all steps | a | answered 2026-10-30: a — keep, **revisit later** (ROADMAP carried over) |
| 7 | 2 | Home layout (no offline mock): hero + Kompüter / Bir cihazda / Dərs / Oyunlarım tiles. | a) Keep · b) Request an offline Home design | a | answered 2026-10-30: a |
| 8 | 2 | Pass & play resign: accepted at once (no confirmation by the other player). | a) Keep · b) Ask the other player | a | answered 2026-10-30: a |
| 9 | 2 | Turkish product name for the variants. | a) "Kısa nard / Uzun nard" · b) "Tavla / Uzun tavla" | a | answered 2026-10-30: **b — Tavla / Uzun tavla** |
| 10 | 2 | Translations en/ru/tr were machine-written in the product voice. | a) Native review before launch (Phase 7) · b) Review now | a | open |
| 11 | 2 | Animation speed options. | a) Yavaş / Normal / Sürətli · b) Slider (DS card) | a | open |
| 12 | 2 | iOS was not built (Linux machine). | a) Build/run on a Mac when available · b) Set up a CI macOS job | open — needs a Mac | open |
| 13 | 3 | Apple / Google Sign-In need keys from the owner's developer accounts. | a) Build server side, keep disabled by config until keys exist · b) Owner provides keys now | — | answered 2026-10-30: a |
| 14 | 3 | E-mail for sign-in codes in development. | a) Mailpit in docker-compose; real provider in Phase 7 · b) Real provider now | — | answered 2026-10-30: a |
| 15 | 3 | Multi-pod scaling (Redis queues, snapshots) now or with the Phase 7 load tests? | a) Phase 7 (single pod is enough until launch tests) · b) Now | a (ADR-032) | assumed |
| 16 | 3 | Bot fallback (ADR-024): the design says the search for a live opponent continues in the background during the bot game; the server stops searching. | a) Stop searching, change the copy (simple, no interrupted games) · b) Keep searching and offer to switch when a player is found | a | assumed: a (ADR-033) |
| 17 | 3 | 15.2 Export: the design promises an e-mailed ZIP within 24 h; the API returns the data at once (guests have no e-mail). | a) Save/share the JSON now, change the copy · b) Async e-mail job | a | assumed: a (ADR-033) |
| 18 | 3 | 15.3 Delete: the design promises a 30-day grace (sign in to cancel); the API deletes at once. | a) Add the 30-day grace (store a deletion date, purge job) · b) Delete at once, change the copy | b for now | answered 2026-11-01: 30-day grace — implemented (sign-in cancels, `accounts:purge` daily) |
| 19 | 3 | Opponent disconnected: the banner says the game is "paused", but the server keeps the absent player's clock running (60 s grace, then forfeit). | a) Keep the clock running, change the copy · b) Pause the clock during the grace | a | assumed: a (ADR-033) |
| 20 | 3 | Time controls: 2.2 shows Blits/Sürətli/Klassik/Gündəlik; the server has one control (3 min + 12 s). | a) Phase 3: 3+12 only; Blits/Klassik next, Gündəlik (correspondence) later · b) All now | a | answered 2026-11-01: add Blits (1+8) and Klassik (5+15) next to Sürətli (3+12); Gündəlik later — queued after the infra work |
| 21 | 3 | Home grid: where do online casual ("Adi" / "Təsadüfi") and ranked go, and is the hero "Oyna" online or offline by default? | a) Hero stays offline vs computer; add an "Onlayn" tile opening casual/ranked choice · b) Hero = online casual when signed in | a | assumed: a (ADR-033) |
| 22 | 3 | Store rules: Apple requires Sign in with Apple when Google sign-in is offered on iOS (guideline 4.8); show Apple on Android too? | a) Apple on iOS only, Google on both · b) Both everywhere | a | answered 2026-11-01: a — Apple on iOS only (implemented) |
| 23 | 4 | Economy numbers (ADR-034, store.md §10): match rewards, XP curve, level-up coins, streak, missions, prices, Yaqut packs. Confirm or change. | a) Keep the design's numbers · b) Give your own | a | answered 2026-11-01: a (keep the design numbers) |
| 24 | 4 | "Sandıq" (day-7 streak, daily missions bonus) — the design shows a chest; random contents would be a loot box. | a) Fixed, visible rewards (coins) · b) Fixed item list shown before opening | a | assumed |
| 25 | 4 | The 2 000 Yaqut pack (19,99 ₼) gives less per ₼ than the 1 200 pack (9,99 ₼). | a) 2 000 → 2 600 Yaqut · b) Keep | — (prices are set in the stores) | open |
| 26 | 4 | Caspian appears as season level 30, premium track level 19 and (earlier) buyable. | a) Season pass only · b) Also buyable | a | assumed |
| 27 | 4 | Should bot and offline games give coins/XP? | a) Online bot games: reduced rewards; offline: none (no farming) · b) Offline too | a | assumed |
| 28 | 5 | 6.4 spectator view shows free-text chat; spec §8.5 forbids free text in ranked games. | a) Spectators: emotes only (no chat) · b) Spectator-only chat, never shown to players | a | assumed |
| 29 | 5 | Clan war scoring: the design gives +3 per won match (25 matches to 5 points); spec says "total points win". | a) +3 per won war match, most points wins · b) Sum of match points | a | assumed |
| 30 | 5 | Clan roles: who may accept requests, kick and promote (design is inconsistent, e.g. an Ağsaqqal kicking an Ağsaqqal). | a) Leader all; co-leader below co-leader; elder: requests, invites, kick members, moderate chat · b) Other | a | assumed |
| 31 | 5 | Weekly clan chest (target 10 000 coins): what do members get when it is reached? Donation limits? | a) Clan XP only for now; decide rewards later · b) Coins back to donors · c) An exclusive item | a | answered 2026-11-01: fixed reward — 300 coins to each donor of the week + clan XP (implemented) |
| 32 | 5 | Clan creation 3 000 coins, rename 1 000, member cap 50, tag 3–5 letters (design numbers). | a) Keep · b) Change | a | assumed |
| 33 | 6 | Do public tournament matches change rating? | a) No — tournaments pay prizes; rating only from ranked queue · b) Yes | a | assumed |
| 34 | 6 | Private tournaments with coin entry fees let friends stake coins against each other. | a) Private tournaments are free entry only · b) Allow coin entry | a | assumed |
| 35 | 6 | No-show timer: 30 s in one mock, 60 s in another. | a) 60 s (same as the reconnect grace) · b) 30 s | a | assumed |
| 36 | 6 | Prize pools from the design (64-player KO 50 000 → 25 000 / 12 000 / 6 500 + 6 500; sit-and-go keeps 10 % of entries; unfilled sit-and-go cancels with full refund after 10 min). | a) Keep · b) Change | a | assumed |
| 37 | 6 | Season pass: 50 levels × 1 000 XP, premium 950 Yaqut, premium track gives some Yaqut back (500 Yaqut over the season, ADR-039). | a) Keep · b) Change | a | assumed |
| 38 | 6 | Analysis numbers come from the heuristic bot, not a trained equity model. | a) Show them as "evaluation" with a note until the neural AI (later) · b) Hide analysis until then | a | assumed |
| 39 | 6 | Neural AI (spec §6 v2, Python training, on-device model) — Usta/Qrossmeyster stay locked until it exists. | a) Later phase, after launch data · b) Now | a | assumed |
| 40 | 7 | Fair-play thresholds (ADR-042): engine flag at expected agreement + 0.15 (bands are guesses), abandonment ≥ 30 % of ≥ 10 matches → 24 h queue cooldown, ≥ 5 reporters in 7 days, shared IP/device + ≥ 2 ranked meetings. | a) Keep as review-only flags (only the cooldown is automatic) and calibrate after launch data · b) Automatic bans | a | assumed |
| 41 | 7 | Banned / muted players: the client has no "banned" screen for `403 {code: banned, until}`, no appeal contact, and does not render the `moderation_warning` inbox type or the `queue_cooldown` error yet. | a) Add a banned screen (until + support e-mail), warning row and cooldown message in the client · b) Generic error for now | a (client work; needs a support e-mail) | open |
| 42 | 7 | Sign-in IP / device sightings for multi-account detection (hashed, 90 days; raw last IP on the user). | a) Keep, mention in the privacy policy · b) Do not store IPs | a | assumed |
| 43 | 7 | Admin panel language. | a) English only (staff tool) · b) Azerbaijani too | a | assumed |
| 44 | 7 | Deleting an account keeps the player's name in opponents' match history. | a) Anonymise names on deletion (API change) · b) Disclose it in the privacy policy | a | answered 2026-11-01: a — implemented (names blanked on deletion, shown as \"Silinmiş oyunçu\") |
| 45 | 7 | Google Play requires an account-deletion web page besides in-app deletion. | a) Simple page on the marketing site calling the API (needs hosting) · b) Support e-mail process | a | open — needs hosting |
| 46 | 7 | Coin-entry tournaments may be read as simulated gambling in store rating questionnaires. | a) Answer "no real money, earned coins only" and keep · b) Make all public tournaments free | a | answered 2026-11-01: a — keep coin-entry tournaments, explain in the questionnaire; make them free if a store objects |

Earlier questions are tracked in `ROADMAP.md` → "Open questions".
