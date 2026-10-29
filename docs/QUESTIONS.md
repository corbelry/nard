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
| 16 | 3 | Bot fallback (ADR-024): the design says the search for a live opponent continues in the background during the bot game; the server stops searching. | a) Stop searching, change the copy (simple, no interrupted games) · b) Keep searching and offer to switch when a player is found | a | open |
| 17 | 3 | 15.2 Export: the design promises an e-mailed ZIP within 24 h; the API returns the data at once (guests have no e-mail). | a) Save/share the JSON now, change the copy · b) Async e-mail job | a | open |
| 18 | 3 | 15.3 Delete: the design promises a 30-day grace (sign in to cancel); the API deletes at once. | a) Add the 30-day grace (store a deletion date, purge job) · b) Delete at once, change the copy | b for now | open |
| 19 | 3 | Opponent disconnected: the banner says the game is "paused", but the server keeps the absent player's clock running (60 s grace, then forfeit). | a) Keep the clock running, change the copy · b) Pause the clock during the grace | a | open |
| 20 | 3 | Time controls: 2.2 shows Blits/Sürətli/Klassik/Gündəlik; the server has one control (3 min + 12 s). | a) Phase 3: 3+12 only; Blits/Klassik next, Gündəlik (correspondence) later · b) All now | a | open |
| 21 | 3 | Home grid: where do online casual ("Adi" / "Təsadüfi") and ranked go, and is the hero "Oyna" online or offline by default? | a) Hero stays offline vs computer; add an "Onlayn" tile opening casual/ranked choice · b) Hero = online casual when signed in | a | open |
| 22 | 3 | Store rules: Apple requires Sign in with Apple when Google sign-in is offered on iOS (guideline 4.8); show Apple on Android too? | a) Apple on iOS only, Google on both · b) Both everywhere | a | open |

Earlier questions are tracked in `ROADMAP.md` → "Open questions".
