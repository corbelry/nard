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

Earlier questions are tracked in `ROADMAP.md` → "Open questions".
