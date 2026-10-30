# Tournaments, seasons, leaderboards, analysis & puzzles: implementation spec (Phase 6)

Source: `.claude/skills/nardarena-design`: `Ekranlar 4` (4.1–4.5),
`Ekranlar 8` (21.1–21.4, 22.1–22.2), `Ekranlar 5` (6.5, 7.1, 7.2; 8.1
"KUBOK VİTRİNİ"), `Ekranlar 6` (10.1 analysis parts; 11.1–11.4 states drawn
on "Turnirlər"), `Ekranlar 7` (13.1–13.3; 12.1 puzzle mission; 16.1/16.2
tournament notifications), `Ekranlar 2` (2.1 live-tournament and season
cards; 2.3 AI levels), `Ekranlar 3` (3.2 obtain row "Bakı Payız Kuboku · Top
3 mükafatı"), `TabBar.dc.html` (Turnirlər tab), `readme.md` (numbers, no
emoji, no exclamation marks). Siblings: `screens.md` (chrome, 10.1 replay
base, 11.x state pattern), `game.md` (GameScreen, 2.6), `online.md`
(Avatar/RankBadge/FlagSwatch, 8.1, tiers), `store.md` (CurrencyIcon/PriceTag,
season numbers §10, rarity colours), `social.md` (UnderlineTabs, FilterChip,
ChoiceChip, GroupCard, LivePill, Podium). This file only adds what they
lack. Frame 390×844 portrait, logical px.

Product rules that override the mocks:
- **Tournament types** (spec §8.3): Knockout, Swiss (Buchholz tie-break),
  Round-robin, Sit-and-go (starts when **8 / 16 / 32** have joined),
  Scheduled daily/weekly championships, Clan championships. Only knockout
  (4.2/4.3), Swiss (4.4) and sit-and-go (21.x) are drawn; round-robin and
  clan championships reuse those screens (§19 ambiguities 1–2).
- **Entry**: free, coins or invite-only. **Coins are earn-only** (ADR-022):
  no "buy coins" path anywhere, an insufficient balance shows
  `purchaseNotEnoughCoins` (existing). Yaqut never pays a tournament entry.
- **Prizes**: coins, cosmetics, titles, trophies on the profile. Prizes are
  **fixed and shown before registration** (no random rewards, spec §8.7).
- **Seasons** (spec §8.2): ~6 weeks, soft rating reset, season rewards by
  tier. **Season pass**: free + premium track; premium is a **one-off Yaqut
  purchase per season** (ADR-025, no subscription); the premium track never
  grants coins (ADR-022). Tiers Bürünc → Gümüş → Qızıl → Platin → Almaz →
  Master → Qrossmeyster (`tierFloors` in `online/rank.dart`).
- **Analysis** (spec §6, §8.9): per-move equity loss, mistakes/blunders,
  best move, computed by the strongest bot (Qrossmeyster). **Puzzles**
  ("find the best move", spec §8.8) work offline (§8.10).
- **AI**: Usta and Qrossmeyster unlock when the neural evaluator lands
  (ADR-019); the "~elo" labels stay hidden until calibrated (QUESTIONS #5).
- Server is authoritative for brackets, pairings, no-show timers and
  prizes; the client only renders and sends intents.

---

## 0. Conventions

Same as `screens.md` §0 / `online.md` §0 / `store.md` §0 / `social.md` §0:
aliases `text`, `text@a`, `dim`, `accent`, `accent@a`, `accentHi`, `line`,
`surfaceRaised`, `danger`, `dangerText`, `success`/`successText`,
`ivory100`, `walnut900`; `c.` = `context.nard`; **overline** =
`NardType.caption` w600 letterSpacing .72 (.06em), stored uppercase in ARB
(never `toUpperCase()`); "*(no token)*" = raw value; "*(inferred)*" /
"*(proposal)*" = not in the mock.

Mock colour mapping: Ekranlar 4/5/6 are ceviz-era (`#C9A24A` = `accent`,
`#E8C468` = `accentHi`, `#34251A` = `c.surfaceRaised`, `#2B1D14` cards on a
`#1B120C` screen = `c.surfaceRaised`, `#1B120C` flat screen = theme
background `c.bg`, `#231709` on brass = `c.onAccent`). Ekranlar 7/8 are
sebeke-raw (`#D4AE58` = `accent`, `#2A1A20` = `c.surfaceRaised`, `#1D1316`
= `c.onAccent`, `rgba(158,27,50,.18)` = `c.surface`, `#1D1418` = `c.bg`).
`#3FB57F` = `successText`, `#1F8A5B` = `success`, `#E0566C` = `dangerText`,
`#9E1B32` = `danger`, `#F8F1E4` = `c.primaryText`, `#F3EBDD` = `ivory100`
(as a fill) / `text`.

Extra tokens already in `apps/client/lib/ui/extra_tokens.dart` (reuse):
`c.bgGradient`, `c.profileBg`, `c.onAccent`, `c.textFaint`, `c.lineSoft`
(accent@.16), `c.surfaceSunken` (black@.25), `c.codeBox`, `c.scrim`,
`c.tile` (text@.05), `c.tileRing` (accent@.18), `c.selectedFill`,
`c.pillFill` (text@.06), `c.brassRing`, `c.avatarMe/Opponent/Bot`,
`c.tierStops(tier)`, `c.tierFill(tier)`, `c.rankInner`, `c.coinFill`,
`c.gemFill`, `c.levelBadgeFill`, `c.levelUpBg`, `c.successBg(rarity)`,
`c.liveFill` (dangerText@.16), `c.roomBg`, `c.clanLeaderboardBg`,
`c.primaryGlow`, `c.primaryRing`, `c.elevation2/3`.

New raw values in this file (*no token*; add to `extra_tokens.dart`):

| Use | Value |
|---|---|
| Tournament poster fallback (4.2 hero, 2.1 / 4.1 thumbs) | linear 180° `#4A321F` → `#1B120C` (= `c.roomBg` stops) under the poster image; mock placeholder = 135° stripes `text@.05` 6/12 ("turnir afişası", "kubok şəkli" are placeholders, not copy) |
| Home tournament thumb ground (2.1) | `#2A1C12` + stripes `text@.06` 5/10 (placeholder for the trophy art) |
| Bracket canvas (4.3) | `c.bg` + dot grid: radial dot `accent@.12` 1px (fades to 0 at 1.5px), every 16×16 |
| Bracket card | fill `c.surfaceRaised`, radius 10, ring 1px `accent@.2`; mine: ring 1.5px `accentHi`; my next match: + glow `0 0 20 accentHi@.25`; inner divider 1px `accent@.12` |
| Bracket connector | 1px `accent@.35`; my path `accentHi` |
| Standings "me" row / leaderboard me | fill `accent@.14` |
| Champion bg (4.5) | radial `70% 45% at 50% 38%`: `accentHi@.35` → `#2B1D14` 60% → `#120C08` |
| Trophy placeholder (4.5) | 200×240 radius 16, stripes `text@.07` 6/12, ring 1px `accentHi@.4` ("kubok · 3D render" = asset slot) |
| Title reward pill (4.5) | fill `rarityLegendary@.18`, text `#F2C86C` (oklch .85 .12 85) |
| Walkover bg (21.3) | radial `80% 45% at 50% 35%`: `#24402F` → `#17121A` 60% → `#120C0E` (success-tinted twin of `c.levelUpBg`) |
| Success disc (21.3; = 14.4) | 96 Ø, fill `success@.16`, ring 1px `successText@.4`, Lucide `check` 40 stroke 2.5 `successText` |
| Refund pill (21.4) | h 36, padding h 14, pill, fill `success@.16`, ring 1px `successText@.4`, coin 16 + 14 w600 `successText` |
| No-show ring (21.2) | 120 Ø sweep: `accent` for the remaining fraction, `text@.1` rest; inner disc 104 `c.bg` |
| Empty seat (21.1) / empty opponent (21.2) | ring 1px `text@.14` (seat) / 2px `text@.25` + stripes `text@.07` 4/8 (avatar 72), initial `text@.4` |
| Private invite card (22.2) | fill `c.surface` (danger@.18), ring 1px `line` (accent@.32), radius 18 |
| Disabled primary (22.2) | fill `danger@.35`, ring 1px `accent@.3`, label `primaryText@.5` (4th disabled style, §19.26) |
| Season pass bg (7.1) | linear 180°: season colour (`#123844` for "Xəzər") 0 → `#1B120C` 45%; overline in the season ink (`#8FD0DC`). **Season data**, not theme |
| Season summary bg (7.2) | radial `80% 40% at 50% 26%`: tier dark stop @.35 (Almaz `#4F7FD1`) → `#1B120C` 70% (`c.tierStops(tier).$2`) |
| Pass premium tile | linear 180° `accent@.16` → `accent@.04`, ring 1px `accent@.3`; seasonal item ring 1.5px `raritySeasonal` |
| Leaderboard bg (6.5) | radial `90% 40% at 50% 22%`: `accent@.2` → `#1B120C` 70% (≈ `c.profileBg`, centre 22%, alpha .2) |
| Podium rings (6.5) | 1st `c.brassRing` (78 Ø, padding 3); 2nd/3rd linear 160° `c.tierStops(silver/bronze)` (62 Ø); place digit colour: `accentHi` / `#D8DCE0` / `#E0A77A` |
| Pinned "me" bar (6.5) | fill `c.surfaceRaised`, top border 1px `accent@.3` |
| Equity bar (10.1) | h 10, radius 5, ring 1px `accent@.2`; White share linear 90° `#D6C5A0` → `#F3EBDD`; Black share `#151312` |
| Best-move arrow (10.1) | `successText`, stroke 5, round caps, opacity .9, open arrow head (two 5px strokes ±~35°) |
| Your-move arrow (10.1) | `dangerText`, stroke 3, dash 6/6, round caps, opacity .85, no head |
| Blunder row (10.1) | fill `dangerText@.14` |
| Scrubber marks (10.1) | 8 Ø dots on the track: mistake `accentHi`, blunder `dangerText` |
| Puzzle result panel (13.2/13.3) | radius `24 24 0 0`, fill `c.surfaceRaised`, inset top 1px edge `successText@.6` / `dangerText@.6`, shadow `0 −10 30 black@.4` |
| Puzzle icon disc | 40 Ø, fill `success` / `danger`, Lucide `check` / `x` 20 stroke 3 `ivory100` |

### 0.1 New shared widgets (put in `apps/client/lib/ui/` unless noted)
- **TournamentStatus** (overline): optional 6 Ø dot (drawn) + text 11 w700
  letterSpacing .66; colours: live `dangerText`, registration `accentHi`,
  finished `text@.6` *(proposal)*, cancelled `text@.45` *(proposal)*.
- **TournamentCard** (4.1) and **TournamentBanner** (2.1, horizontal with
  an 84-wide thumb).
- **PrizeTiles** (4.2): 3-column grid of place → amount tiles.
- **BracketView** (`tournaments/`): InteractiveViewer canvas, BracketMatch
  cards, connector painter, zoom buttons, **RoundChips**.
- **StandingsTable** (4.4): fixed column grid + header in Plex Mono.
- **RoundSquares** (4.4): 30×30 radius 8 selectable numbers.
- **SeatGrid** (21.1), **CountdownRing** (21.2).
- **EqualChips**: equal-width solid choice chips (21.1 pill h 36; 22.1
  radius 12 h 40) = `NardChoiceChip` in an `Expanded` row with a `radius`
  parameter.
- **CelebrationLayout** (4.5, 21.3, 21.4, 7.2): bg + centred column +
  bottom button zone (same skeleton as 12.3 Level up / 7.5 purchase
  success; reuse that layout).
- **PlayerPodium** (6.5): generalise the private `_Podium` in
  `clans/clan_leaderboard_screen.dart` (pedestals there; avatars + rings
  here — two variants of one widget).
- **PinnedMeRow** (6.5) (also wanted for 5.7, social.md §6.7).
- **SeasonTrack** (7.1): level header row + PULSUZ / PREMİUM rows of
  **PassRewardTile**s, horizontally scrollable.
- **EquityBar**, **MoveArrowsOverlay** (board overlay painter), **EvalMark**
  (✓ / ? / ??), scrubber **marks** on the existing replay scrubber (10.1).
- **PuzzleResultPanel** (13.2/13.3) + **TagChip** (h 26 static chip).

---

## 1. Turnirlər tab · 4.1 Tournament list (Turnir siyahısı)

**Purpose:** browse live / upcoming / my / finished tournaments. New tab
**Turnirlər** (Lucide `trophy`; TabBar order **Əsas · Turnirlər · Klan ·
Mağaza · Profil**, `TabBar.dc.html`); tab root = 4.1.

Layout (bg `c.bgGradient` + lattice band, `NardBackground`):
1. Top block padding `4 16 0`, column gap 14:
   - Title "Turnirlər" `RootTitle` (Noto 26 w600).
   - **UnderlineTabs** h 40 (14px; selected w600 `accentHi` + 2px `accent`
     bar; others w500 `text@.6`; bottom border 1px `accent@.16`): **Canlı ·
     Gələcək · Mənim · Bitmiş** (Canlı selected).
   - **FilterChip** row gap 6 (h 30, padding h 12, pill, 12 w500; selected
     fill `accent@.18` + ring 1px `accent` + `accentHi`; else ring 1px
     `accent@.24` + `text`): **Hamısı** (selected) · **Qısa** · **Uzun** ·
     **Pulsuz**. Hamısı is exclusive; Qısa/Uzun are a variant filter (one
     at a time, *inferred*); Pulsuz = entry free, combinable *(inferred)*.
     Plus a "+" for private tournaments — **not drawn** (§7, §19.12).
2. **List**, flex, scrolls, padding `14 16 0`, gap 10. **TournamentCard**:
   radius 18 *(no token)*, padding 14, fill `c.surfaceRaised`, ring 1px
   `accent@.2`, column gap 10:
   - Row space-between: TournamentStatus ("● CANLI · RAUND 3" `dangerText`
     / "QEYDİYYAT AÇIQDIR" `accentHi`) · time 12 `text@.64` tnum: live =
     **time until my next match** ("14 dəq", matches Home "Növbəti matçın 14
     dəq sonra") — for a live tournament I am not in, time until the next
     round *(inferred)*; registration = countdown "02:14:36" when < 24 h,
     else "Sabah 20:00" / weekday + time *(inferred)*.
   - Name Noto 18 w600 (data, ellipsis 1 line).
   - Meta row gap 14, 12 `text@.7`: format ("Qısa · 5 xal", "Qısa · 3 xal ·
     1+8s", "Uzun · İsveç · 7 raund") · prize fund ("50 000", plain number;
     *proposal*: prefix `CurrencyIcon` coin 12 — the mock has no unit) ·
     entrants "64/64".
   - Fill bar h 4 radius 2, track `text@.1`, fill `accent`, width =
     entrants / max (`NardProgressBar`).
3. `NardTabBar` active `tour`.

Mock data: Bakı Payız Kuboku (CANLI · RAUND 3, 14 dəq, Qısa · 5 xal,
50 000, 64/64) · Gecə Blitsi (CANLI · RAUND 1, 32 dəq, Qısa · 3 xal · 1+8s,
8 000, 128/128) · Novruz Çempionatı (QEYDİYYAT AÇIQDIR, 02:14:36, Qısa · 7
xal, 50 000, 48/64) · Uzun Nərd Liqası (QEYDİYYAT AÇIQDIR, Sabah 20:00,
Uzun · İsveç · 7 raund, 20 000, 91/128).

Tab contents *(inferred; the "Canlı" tab in the mock also lists two open
registrations, §19.3)*: Canlı = running; Gələcək = registration open +
scheduled; Mənim = registered or playing (order: playing, then by start);
Bitmiş = finished in the last N days with my place if I played *(proposal:
"1-ci yer" / "Çıxdı · 1/8" in the time slot)*. A registered card gets a
"Qeydiyyatdasan" marker *(proposal, not drawn)*. Sit-and-go entry: not
drawn in the list (§6, §19.10) — *proposal*: a pinned first card
"Sit-and-go" with `8 · 16 · 32` and "Qoşul".

**States** (`screens.md` §11.x pattern, drawn on this screen):
- 11.1 offline → `OfflineBanner` + `MessageState` (icon `dangerText`),
  title "Turnirlər oflayn görünmür", body "Kompüterə qarşı və bir cihazda
  oyun işləyir. Bağlantı qayıdanda siyahı yenilənəcək.", button
  `playVsComputer` (existing).
- 11.2 empty "Mənim" → icon `accent`, "Hələ turnirin yoxdur" / "Qeydiyyatdan
  keçdiyin turnirlər burada görünəcək." / "Gələcək turnirlərə bax" (→ tab
  Gələcək).
- 11.3 error → "Siyahı yüklənmədi" / "Serverlə əlaqə qurulmadı. Bir az sonra
  yenidən cəhd et." / `retry`.
- 11.4 loading → 4 skeleton cards h 118 (matches the card height).
- Guest without account → `accountNeededTitle` gate (as clans/friends,
  *inferred*; registration needs an account, browsing may not).

Interactions: card tap → 4.2 (registration / upcoming) or 4.3 / 4.4 (live,
by type) *(inferred)*; pull to refresh; live cards update via WS
`tournament.update` while visible *(proposal)*; tabs remember the last one
*(proposal)*.

| key | az |
|---|---|
| tabTournaments | Turnirlər |
| tournamentsTitle | Turnirlər |
| tourTabLive | Canlı |
| tourTabUpcoming | Gələcək |
| tourTabMine | Mənim |
| tourTabFinished | Bitmiş |
| tourFilterAll | Hamısı |
| tourFilterShort / tourFilterLong | Qısa / Uzun *(same text as existing `variantShortAbbr` / `variantLongAbbr`; reuse those)* |
| tourFilterFree | Pulsuz *(same text as existing `obtainFree`; own key)* |
| tourStatusLive | CANLI · RAUND {n} *(dot drawn as a shape)* |
| tourStatusOpen | QEYDİYYAT AÇIQDIR |
| tourStatusUpcoming | GƏLƏCƏK *(4.2 hero)* |
| tourStatusFinished / tourStatusCancelled | BİTDİ / LƏĞV EDİLDİ *(proposals)* |
| tourInMinutes | {n} dəq |
| tourTomorrowAt | Sabah {time} |
| tourFormatSwiss | İsveç |
| tourFormatKnockout | Knockout *(design keeps the English word, 4.2)* |
| tourFormatRoundRobin | Dairəvi *(proposal, not drawn)* |
| tourRounds | {n} raund |
| tourMeta | {variant} · {points} xal *(variant = `variantShortAbbr`/`variantLongAbbr`; `formatPoints` existing "{n} xal")* |
| tourMetaClock | {meta} · {clock} *(clock = `timeControlShort` existing "{minutes}+{delay}s")* |
| tourEntrants | {n}/{max} |
| tourRegistered | Qeydiyyatdasan *(proposal)* |
| tourPlace | {n}-ci yer *(proposal; ordinal suffix varies: 1-ci, 2-ci, 3-cü, 4-cü, 6-cı …, §19.29)* |
| tournamentsOfflineTitle | Turnirlər oflayn görünmür |
| tournamentsOfflineBody | Kompüterə qarşı və bir cihazda oyun işləyir. Bağlantı qayıdanda siyahı yenilənəcək. |
| tournamentsEmptyTitle | Hələ turnirin yoxdur |
| tournamentsEmptyBody | Qeydiyyatdan keçdiyin turnirlər burada görünəcək. |
| tournamentsEmptyCta | Gələcək turnirlərə bax |
| listErrorTitle | Siyahı yüklənmədi |
| listErrorBody | Serverlə əlaqə qurulmadı. Bir az sonra yenidən cəhd et. |
| retry / playVsComputer / offlineBanner | **existing keys** |

Icons: `trophy` (tab). Widgets: `NardBackground`, `RootTitle`,
`UnderlineTabs`, `NardFilterChip`, TournamentCard, `NardProgressBar`,
`MessageState`, `OfflineBanner`, `NardTabBar`, `Pressable`.

---

## 2. 4.2 Tournament detail (Turnir detalı)

**Purpose:** everything needed to decide and register. Pushed from 4.1,
Home banner, notifications.

Layout (bg `c.bg`; no back button drawn → add a bare `chevron-left` 20 over
the hero at top-left, `ivory100` with a soft shadow, *inferred*):
1. **Hero** h 250 (incl. status bar), poster image from data
   (`posterUrl`, cover), fallback §0; bottom block padding `0 18 16`, gap 4:
   TournamentStatus "GƏLƏCƏK · KNOCKOUT 64" in `accentHi` (status · type ·
   size) · name `NardType.displayL` (Noto 28 w600) "Novruz Çempionatı".
   Proposal: a bottom fade `c.bg@0 → c.bg` over the last 60 px for legibility.
2. Body, flex, padding `16 18 0` (18 not 16, *no token*), gap 16:
   - Row space-between, bottom-aligned: left column gap 2: "Başlanğıca" 12
     `text@.6` + countdown Plex 30 w600 tnum "02:14:36" (*no token*; `clock`
     is 20) · right column, end-aligned: "Mükafat fondu" 12 `text@.6` +
     "50 000" `NardType.score` (Noto 22 w600) `accentHi` (*proposal*: coin
     glyph 18 before it). Live: left becomes "Raund 3 · 1/8" *(proposal)*.
   - Participants: row space-between 13: "İştirakçılar" · "48 / 64" tnum;
     bar h 6 radius 3, track `text@.1`, fill `accent` (75%).
   - **PrizeTiles**: grid 3 columns gap 8; tile padding 10, radius 12
     (`NardRadius.m`), column gap 2: label 11 w600 + amount 15 w600 tnum.
     1st tile fill `accent@.12`, label `accentHi`; others fill `text@.05`
     (`c.tile`), label `text@.6`. Labels "1-ci" · "2-ci" · "3–4" (shared
     place); amounts 25 000 · 12 000 · 6 500. Non-coin prizes (title,
     cosmetic, trophy) are **not drawn** → *proposal*: a 4th full-width row
     under the grid: `ItemThumb` 32 + "Titul: {name}" / item name + rarity
     colour; tap → 3.2 item sheet. More places (5–8 …) → "Hamısı" link to a
     sheet *(proposal)*.
   - Rules list (`KeyValueRow`, top border 1px `accent@.14`, rows padding v
     10, bottom border 1px `accent@.1`, 14px, key `text@.64` · value
     `text`): Variant "Qısa nərd" · Format "Knockout · 7 xala qədər" · Vaxt
     "3 dəq + 12s" · Giriş "500 sikkə · min. 1500" · Ədalətli zər
     "Yoxlanıla bilər". Proposal: Ədalətli zər row tap → `docs/FAIRNESS`
     explainer / 10.3; rows for "Kub" (Short only) and "Reytinq" (affects
     rating or not, §19.6) are missing.
3. Footer padding `0 16 40`: primary pill **h 58** (`NardButton` primary,
   l + 2) "Qeydiyyat · ●500" (label 17 w600; coin 16 = `CurrencyIcon`, gap 8;
   build as a Row). Free → "Qeydiyyat · Pulsuz" *(proposal)*.

CTA states *(proposals; only "open" is drawn)*:

| State | CTA |
|---|---|
| open, eligible | primary "Qeydiyyat · ●{fee}" → `POST /tournaments/{id}/register` (debits coins) → button becomes outline "Qeydiyyatı ləğv et" + toast "Qeydiyyatdan keçdin" |
| registered, before start | outline "Qeydiyyatı ləğv et" → confirm sheet → refund |
| not enough coins | disabled + `purchaseNotEnoughCoins` under it (no buy link) |
| rating below min | disabled "Minimum reytinq {n}" |
| full | disabled "Yer qalmayıb" (or waitlist, §19.8) |
| invite-only | "Dəvət kodu ilə qoşul" → code entry (§7.3) |
| live, I'm in | primary "Cədvələ bax" → 4.3 / 4.4 |
| live, not in | outline "İzlə" → 4.3 (spectate any tournament match, spec §8.3) |
| guest | "Hesab yarat" → sign-in (existing gate) |

| key | az |
|---|---|
| tourHeroMeta | {status} · {type} {size} *(e.g. "GƏLƏCƏK · KNOCKOUT 64")* |
| tourTypeKnockoutUpper / tourTypeSwissUpper / tourTypeSngUpper | KNOCKOUT / İSVEÇ / SIT-AND-GO *(only KNOCKOUT drawn)* |
| tourStartsIn | Başlanğıca |
| tourPrizeFund | Mükafat fondu |
| tourParticipants | İştirakçılar |
| tourParticipantsValue | {n} / {max} |
| tourPlaceFirst / tourPlaceSecond | 1-ci / 2-ci |
| tourPlaceRange | {from}–{to} *(e.g. "3–4")* |
| tourRuleVariant | Variant *(same text as existing `roomSettingVariant`; reuse)* |
| tourRuleFormat | Format *(existing `roomSettingFormat`; reuse)* |
| tourRuleTime | Vaxt *(existing `roomSettingTime`; reuse)* |
| tourRuleEntry | Giriş |
| tourRuleFairDice | Ədalətli zər |
| tourFormatValue | {type} · {points} xala qədər |
| tourEntryValue | {price} · min. {rating} *(price = `priceCoins` existing "{amount} sikkə")* |
| tourFairDiceValue | Yoxlanıla bilər |
| timeValue / variantShort / variantLong / priceCoins | **existing keys** |
| tourRegister | Qeydiyyat · {price} *(coin glyph between; Row, not text)* |
| tourRegisterFree | Qeydiyyat · Pulsuz *(proposal)* |
| tourUnregister / tourUnregisterTitle | Qeydiyyatı ləğv et / Qeydiyyat ləğv edilsin? Giriş haqqı qaytarılacaq. *(proposals)* |
| tourRegisteredToast | Qeydiyyatdan keçdin *(proposal, toast)* |
| tourMinRating / tourFull / tourInviteOnly | Minimum reytinq {n} / Yer qalmayıb / Dəvət kodu ilə qoşul *(proposals)* |
| tourOpenBracket | Cədvələ bax *(21.3 text)* |
| tourWatch | İzlə *(same text as existing `friendWatch`; own key)* |
| tourTitlePrize | Titul: {name} *(4.5 text)* |
| purchaseNotEnoughCoins | **existing key** |

Icons: `chevron-left`, `chevron-right` (rule rows that open details,
proposal). Widgets: PrizeTiles, `KeyValueRow`, `NardProgressBar`,
`NardButton` (primary/outline), `CurrencyIcon`, `ItemThumb`,
`showNardSheet`.

---

## 3. 4.3 Live bracket (Canlı bracket · sürüşdür / böyüt)

**Purpose:** live knockout tree; pan/zoom; my next match + ready check.
Mock: Bakı Payız Kuboku, 64 players, round 3 (= 1/8, consistent with 4.1
"RAUND 3").

Layout (bg `c.bg`):
1. Header h 48, padding h 16, gap 12: `chevron-left` 20 · title
   `NardType.title` (19) flex, ellipsis · "● CANLI" 11 w700 `dangerText`
   (dot = 6 Ø shape; plain text, not a pill).
2. **RoundChips** row gap 6, padding `0 16 10`, horizontally scrollable
   (*inferred*: 64 players = 1/32 · 1/16 · 1/8 · 1/4 · 1/2 · Final; the mock
   shows from 1/16): chip h 28, padding h 10, radius 8 (`NardRadius.s`),
   12px; **viewed** round fill `ivory100` + `walnut900` w600 (= compact
   segmented selected); finished rounds ring 1px `accent@.2` text `text@.6`;
   upcoming rounds ring 1px `accent@.2` text `text`. Tap → animate the
   canvas so that round is the left column (`NardMotion.standard`, 320 ms;
   instant under reduce motion).
3. **Canvas** flex, clip, dot grid §0. Content = `InteractiveViewer`
   (constrained: false; min scale .5, max 1.6 *proposal*), initial view
   = current round at scale 1:
   - **BracketMatch** card w 150, two rows h 30 (total 61 incl. 1px
     divider), padding h 10, gap 8, 12px: name flex ellipsis · score tnum.
     Finished: winner w600 `text`, loser w400 `text@.5`. Not started: both
     w600 `text`, scores "–". Live: both w600 with the running score ("2" /
     "1"); *proposal*: 6 Ø `dangerText` dot before the higher row's score
     to mark live. Bye: "—" opponent, `text@.4` *(proposal)*.
   - Card states: default ring 1px `accent@.2`; a match with me ring 1.5px
     `accentHi`; my **upcoming** match also glow `0 0 20 accentHi@.25`.
   - Geometry (scale 1): column pitch **186** (card 150 + connector 36);
     first column x 14; first-column cards y = 20 + i·**120**; a card in
     the next column is centred on its two feeders (y 80, 320 in the
     mock); each later round doubles the vertical pitch (240, 480 …).
   - Connectors 1px `accent@.35` (my path `accentHi`): horizontal 20 from
     the feeder's right edge at its mid-height → vertical joining the two
     feeders at x + 170 → horizontal 16 into the target card's mid-height.
   - **Zoom buttons** at right 14, bottom 14: box radius 12, fill
     `c.surfaceRaised`, ring 1px `accent@.24`; two 42×42 cells (divider 1px
     `accent@.2`), Lucide `plus` / `minus` 20 `text` (mock draws "+" / "−"
     text). Step ×1.25 *(proposal)*. Pinch and double-tap also zoom.
4. **Next-match panel** (only when I am still in): padding `12 16 36`
   (`max(36, safeBottom + 2)`), fill `c.surfaceRaised`, top border 1px
   `accent@.2`, row gap 12:
   - Column flex gap 3: overline 11 w700 letterSpacing .66 `accentHi`
     "NÖVBƏTİ MATÇIN · 1/4" · players 15 w600 "Elvin – Nigar_88" · meta 12
     `text@.6` "14 dəq sonra · 5 xala qədər".
   - **Hazıram** button h 44, padding h 16, radius 12, fill `accent`, 14
     w600 `c.onAccent` (= SmallActionButton solid, h 44).
   States *(proposals)*: after tap → outline "Hazırsan" (disabled) + "Rəqib
   gözlənilir"; when the round opens → full-screen 2.5 VS → GameScreen;
   eliminated → panel shows "Turnirdən çıxdın · 1/8" + outline "İzlə"
   (spectate the current match); champion → 4.5.

Interactions:
- Tap a match card: live → spectate (6.4, `spectate.join {matchId}`);
  finished → replay/analysis (10.1); upcoming → nothing / player menu
  *(inferred)*.
- Live updates via WS (`tournament.update`); my card scrolls into view on
  open (*inferred*).
- **Hazıram** = ready check before my match (`tournament.ready`). The mock
  shows it 14 min before the match → readiness can be given early; the
  no-show timer (21.2) only starts when the round opens (§19.15).

| key | az |
|---|---|
| tourLive | CANLI *(dot as shape)* |
| roundOf | 1/{n} *(1/16, 1/8, 1/4, 1/2)* |
| roundFinal | Final |
| tourNextMatch | NÖVBƏTİ MATÇIN · {round} |
| tourNextPlayers | {a} – {b} *(same pattern as existing `replayPlayers`; reuse)* |
| tourNextMeta | {when} · {points} xala qədər |
| tourInMinutesLater | {n} dəq sonra |
| tourReady | Hazıram |
| tourReadyDone / tourWaitingOpponent | Hazırsan / Rəqib gözlənilir *(proposals)* |
| tourEliminated | Turnirdən çıxdın · {round} *(proposal)* |
| zoomIn / zoomOut | Böyüt / Kiçilt *(a11y labels, proposal; screen caption "sürüşdür / böyüt" is the design's annotation)* |

Icons: `chevron-left`, `plus`, `minus`. Widgets: BracketView, RoundChips,
`ScreenHeader(bare)` + trailing, SmallActionButton (h 44), `Pressable`.

---

## 4. 4.4 Swiss standings (Standings · İsveç sistemi)

**Purpose:** Swiss table with Buchholz tie-break; top N go to a playoff.

Layout (bg `c.bg`; no back drawn → add `ScreenHeader(bare)` chevron,
*inferred*):
1. Block padding `4 16 12`, gap 10: title Noto 22 w600 "Gecə Liqası ·
   Cədvəl" (`{name} · Cədvəl`) · row gap 6: "Raund" 12 `text@.6` +
   **RoundSquares**: 30×30, radius 8, 12 w600; the viewed round (mock 7)
   fill `ivory100` + `walnut900`; others fill `text@.06` + `text`; future
   rounds `text@.3` *(inferred)*. Tap → standings after that round.
2. **Header row**: grid columns `28 | 1fr | 44 | 44 | 36`, gap 6, padding
   `8 16`, Plex Mono 600 10 `text@.5`, bottom border 1px `accent@.16`:
   "#" · "OYUNÇU" · "Q–M" · "BUCH" · "XAL" (right-aligned).
3. **Rows** h 46, same grid, padding h 16, 13 tnum, bottom border 1px
   `accent@.08`: rank w600 — inside the qualifying zone (top 8)
   `accentHi`, else `text@.5`; name ellipsis; W–L "6–1" `text@.7`;
   Buchholz "24.0" `text@.7`; points w600 right. **Me**: fill `accent@.14`,
   name w600 (mock: Elvin 3rd). *Proposal*: a 1px `accent@.35` line under
   the last qualifying row; pin my row at the bottom when off-screen (as
   6.5).
4. Footnote padding `12 16`, 11 `text@.5`: "İlk 8 pley-offa keçir ·
   bərabərlikdə Buchholz".

Mock data (after round 7 of 7): Rauf 6–1 · Aysel_A 6–1 · Elvin 5–2 ·
Kerem_TR 5–2 · Murad 5–2 · Günay 4–3 · Orxan 4–3 · Sevda 4–3 · Tural 3–4 ·
Zaur 3–4 · Leyla 3–4 · Samir_77 2–5; XAL = wins (1 point per match win);
BUCH 24.0, 22.7, 21.4 … (decreasing 1.3 — sample values; Buchholz of whole
points is an integer, §19.16).

Sort: points desc → Buchholz desc → (not shown: median Buchholz / head-to-
head / rating) *(proposal)*. Ranks of tied rows: same number or sequential
— mock is sequential.

Interactions: row tap → player's match list in this tournament (sheet,
*proposal*) or 14.1 player menu; my current/next round match → same
next-match panel as 4.3 *(inferred; not drawn)*. Round-robin uses this
table with columns # · OYUNÇU · Q–M · XAL (no BUCH) *(proposal)*.

| key | az |
|---|---|
| standingsTitle | {name} · Cədvəl |
| standingsRound | Raund |
| standingsColRank | # |
| standingsColPlayer | OYUNÇU |
| standingsColWinLoss | Q–M |
| standingsColBuchholz | BUCH |
| standingsColPoints | XAL |
| standingsWinLoss | {w}–{l} |
| standingsFootnote | İlk {n} pley-offa keçir · bərabərlikdə Buchholz |
| standingsFootnoteNoPlayoff | Bərabərlikdə Buchholz *(proposal, Swiss without playoff)* |
| memberMe | **existing key** ({name} (sən)) — *proposal* for my row name |

Widgets: StandingsTable, RoundSquares, `ScreenHeader(bare)`, PinnedMeRow.

---

## 5. 4.5 Champion ceremony (Çempion mərasimi)

**Purpose:** full-screen celebration for the tournament winner (also shown
after a won final; 2nd/3rd place not designed, §19.18).

Layout (bg champion radial §0; no tab bar, no header):
1. Column centred, flex, padding h 24, gap 22, text centred:
   - **Trophy** 200×240 (asset slot "kubok · 3D render"; per-tournament
     trophy art from data, static image or Lottie/3D later; placeholder §0).
   - `OrnamentDivider` (existing: 40 hairline · 8 diamond · 40 hairline,
     `accent`).
   - "Çempion" `NardType.displayXl` (Noto 40/44 w600) `accentHi`.
   - Two lines 15/22 `text@.8`: "Elvin · Bakı Payız Kuboku 2026" / "Final:
     7 – 4 · Nigar_88" (score with spaced en dash, like `gameScore`).
   - Reward pills row gap 8: h 34, padding h 14, pill, 13 w600: coins
     "+25 000 sikkə" fill `accent@.18` text `text` (*proposal*: coin glyph
     14 instead of the word, as 2.6) · title "Titul: Payız Xanı" fill
     `rarityLegendary@.18`, text `#F2C86C` (§0). Item/trophy prizes would
     add pills (wrap).
2. Footer padding `0 16 40`, row gap 10: **Paylaş** outline flex 1, h 54,
   radius 16, ring 1px `accent@.3`, 15 w600 → system share (image card of
   the trophy + text, *proposal*) · **Kuboku vitrinə qoy** primary flex 1.5,
   h 54, pill → pins this trophy to the 8.1 "KUBOK VİTRİNİ" (4 slots) and
   closes to 4.3 / Home.

Motion *(proposal)*: trophy scale-in `NardMotion.outBack`-like 600 ms, coin
count-up (`CountUpText`), lattice confetti off under reduce motion; haptic
`heavyImpact` once. Shown once per tournament (server flag `ceremonySeen`).

| key | az |
|---|---|
| championTitle | Çempion |
| championLine | {name} · {tournament} |
| championFinal | Final: {score} · {opponent} *(score via existing `gameScore` "{me} – {opp}")* |
| rewardCoins | +{amount} sikkə |
| tourTitlePrize | Titul: {name} |
| championShare | Paylaş *(same text as existing `roomShare`; own key)* |
| championShowcase | Kuboku vitrinə qoy |
| championShareText | {name} {tournament} turnirinin çempionu oldu. NardArena *(proposal)* |
| runnerUpTitle / thirdPlaceTitle | İkinci yer / Üçüncü yer *(proposals, §19.18)* |

Widgets: CelebrationLayout, `OrnamentDivider`, `CountUpText`, `NardButton`
(outline, primary).

---

## 6. Sit-and-go (Ekranlar 8 · 21.x)

Sebeke-raw mocks. Entry not drawn (§1 proposal: a Sit-and-go card / chooser
in 4.1).

### 6.1 21.1 Waiting lobby (Gözləmə lobbisi · 11 / 16)
Bg `c.bgGradient`.
1. `ScreenHeader(bare)` "Sit-and-go · 16" (title 20).
2. Body flex, padding `6 16 0`, gap 16:
   - **EqualChips** (pill h 36, 13 w600; selected fill `accent` +
     `c.onAccent`; else fill `text@.06`, ring 1px `accent@.2`, `text@.75`):
     "8 oyunçu" · "16 oyunçu" (selected) · "32 oyunçu". Switching size
     while queued = leave + join the other queue (fee stays reserved,
     *proposal*).
   - Counter, column centred gap 4, padding `10 0 4`: Noto 48/1 w600 tnum
     "11" + " / 16" in `text@.4` (*no token*, one span) · 13 `text@.65`
     "Dolan kimi başlayır · orta gözləmə 1 dəq" (average wait from server).
   - **SeatGrid**: 8 columns, gap 8, square cells, circles: taken = fill
     `text@.08`, ring 1px `accent@.3`, initial Noto 600 13; **me** = fill
     `c.avatarMe` (150°), ring 1.5px `accent`; empty = ring 1px `text@.14`.
     32 players → 4 rows of 8; 8 → 1 row. New seat fills with a 160 ms
     fade/scale (*proposal*). Names are hidden (initials only).
   - Info `GroupCard` (fill `text@.04`, ring 1px `accent@.14`, radius 16);
     rows min-h 44, padding h 14, bottom border `accent@.08`, 14px: key
     `text@.65` · value w600 tnum:
     Format "Qısa nərd · 3 xal" · Giriş haqqı "500 sikkə" · Mükafat fondu
     "7 200 sikkə" · Vaxt nəzarəti "12 san + 2 dəq bank".
   - Note 12/17 `text@.55`, padding h 4: "Başlayanda 30 saniyə ərzində hazır
     olmayan oyunçu raundu texniki məğlubiyyətlə verir."
3. Footer padding `16 16 40`: outline l (h 56, radius 16, ring 1px
   `accent@.3`, 16 w600) "Çıx · giriş haqqı qaytarılır" → `sng.leave` →
   refund → back.

Start: when the last seat fills → all get `tournament.start` → bracket
(4.3) / first match ready check. Lobby survives app background; leaving the
app does not leave the queue *(proposal: push "Sit-and-go başladı")*.
Prize split for SnG not shown (§19.11).

### 6.2 21.2 Opponent no-show (Rəqib qoşulmayıb)
Bg `c.bgGradient`. Column centred, padding h 28, gap 16, text centred:
- Overline 12 w600 letterSpacing .96 (.08em) `accent` "RAUND 1 · MASA 4".
- Row gap 18: my Avatar 72 (`c.avatarMe`, ring 2px `accent`, initial Noto
  28) · "vs" Noto italic 600 22 `accentHi` (existing `vsLabel`) · empty
  opponent 72 (§0) with the opponent's initial `text@.4`.
- Title Noto 26/32 w600 (margin-top 6) "Rəqib hələ qoşulmayıb".
- Body 14/21 `text@.7`: "Rauf_88 vaxt bitənə qədər gəlməsə, raund sənin
  xeyrinə texniki qələbə ilə bitəcək."
- **CountdownRing** 120 (§0), margin-top 8: "0:47" Plex 30 w600 tnum; ring
  fraction = remaining / total (78% at 0:47 → total **60 s**; 21.1 says
  30 s, §19.14). Updates every second from server `deadline`.
Footer `0 16 40`: outline l "Turnir cədvəli" → 4.3/4.4 (the wait continues
in the background; a banner/push brings me back when the opponent arrives,
*proposal*).
Opponent joins → straight to 2.5 VS → GameScreen. Timer hits 0 → 21.3.

### 6.3 21.3 Walkover win (Texniki qələbə)
Bg walkover radial §0. Column centred, padding h 32, gap 14:
- Success disc §0 (Lucide `check`).
- Title Noto 26 w600 "Növbəti raunda keçdin".
- Body 14/21 `text@.7`: "Rauf_88 vaxtında qoşulmadı. Raund texniki qələbə
  ilə sənə verildi. Reytinq dəyişmir."
- Card full width, margin-top 8, padding 14, radius 14, fill `text@.04`,
  ring 1px `accent@.18`, row space-between 14: "Raund 2 başlayır" `text@.65`
  · "2:10" w700 tnum (countdown).
Footer `0 16 40`: primary l "Cədvələ bax" → 4.3.
Last round won by walkover → 4.5 instead *(inferred)*. The opponent who
did not show sees "Texniki məğlubiyyət" *(not designed, proposal: 2.6-like
loss card "Vaxtında qoşulmadın · raund texniki məğlubiyyətlə verildi")*.

### 6.4 21.4 Tournament not filled (Turnir dolmadı)
Bg `c.bgGradient`. Column centred, padding h 32, gap 14:
- Icon well 96 Ø, ring 1px `accent@.3`, diamond 34 rotated 45° border 3
  `accent` (= `MessageState` icon, `accent` variant).
- Title Noto 24 w600 "Turnir başlamadı".
- Body 14/21 `text@.7`: "10 dəqiqədə 32 oyunçudan yalnız 19-u qoşuldu.
  Giriş haqqı balansına qaytarıldı."
- Refund pill §0: coin 16 + "+500 qaytarıldı".
Footer `0 16 40`, gap 10: primary l "16 nəfərlikə qoşul" (offer = the
largest size ≤ joined count, *inferred*: 19 → 16) → join that SnG queue
(new fee) · text button h 48, 15 w600 `text@.7` "Turnirlərə qayıt" → 4.1.
Timeout **10 min** for SnG (body copy). Same screen for scheduled
tournaments below their minimum *(proposal)*.

### 6.5 Strings (21.x)
| key | az |
|---|---|
| sngTitle | Sit-and-go · {size} |
| sngSize | {n} oyunçu |
| sngCount | {n} / {size} *(build as two spans; second in `text@.4`)* |
| sngStartsWhenFull | Dolan kimi başlayır · orta gözləmə {n} dəq |
| sngFormat | Format *(existing `roomSettingFormat`; reuse)* |
| sngFormatValue | {variant} · {points} xal *(variant = `variantShort`/`variantLong` existing)* |
| sngEntryFee | Giriş haqqı |
| sngPrizeFund | Mükafat fondu *(= `tourPrizeFund`)* |
| sngTimeControl | Vaxt nəzarəti |
| sngTimeValue | {delay} san + {reserve} dəq bank *(design; elsewhere `timeValue` "{minutes} dəq + {delay}s", §19.13)* |
| priceCoins | **existing key** ({amount} sikkə) |
| sngNoShowRule | Başlayanda {n} saniyə ərzində hazır olmayan oyunçu raundu texniki məğlubiyyətlə verir. |
| sngLeave | Çıx · giriş haqqı qaytarılır |
| noShowOverline | RAUND {round} · MASA {table} |
| vsLabel | **existing key** (vs) |
| noShowTitle | Rəqib hələ qoşulmayıb |
| noShowBody | {name} vaxt bitənə qədər gəlməsə, raund sənin xeyrinə texniki qələbə ilə bitəcək. |
| tourBracket | Turnir cədvəli |
| walkoverTitle | Növbəti raunda keçdin |
| walkoverBody | {name} vaxtında qoşulmadı. Raund texniki qələbə ilə sənə verildi. Reytinq dəyişmir. |
| walkoverNextRound | Raund {n} başlayır |
| tourOpenBracket | Cədvələ bax |
| walkoverLossTitle / walkoverLossBody | Texniki məğlubiyyət / Vaxtında qoşulmadın. Raund texniki məğlubiyyətlə verildi. *(proposals)* |
| notFilledTitle | Turnir başlamadı |
| notFilledBody | {minutes} dəqiqədə {size} oyunçudan yalnız {joined}-u qoşuldu. Giriş haqqı balansına qaytarıldı. *(suffix "-u/-i/-ı/-ü" depends on the number, §19.29)* |
| refunded | +{amount} qaytarıldı |
| notFilledJoinSmaller | {n} nəfərlikə qoşul *(suffix varies: 8 nəfərliyə, 16 nəfərlikə, §19.29)* |
| backToTournaments | Turnirlərə qayıt |

Icons: `chevron-left`, `check`. Widgets: EqualChips, SeatGrid,
`GroupCard`, `KeyValueRow`, Avatar (72), CountdownRing, CelebrationLayout,
`MessageState` icon well, `CurrencyIcon`, `NardButton`.

---

## 7. Private tournaments (Ekranlar 8 · 22.x · "Özəl turnir")

Spec §8.3 "user-created private tournaments (P1)". Entry not drawn
(*proposal*: "+" in the 4.1 header → 22.1; also Home "Şəxsi otaq" chooser
gets "Özəl turnir").

### 7.1 22.1 Settings (Parametrlər)
Bg `c.bg`. `ScreenHeader(bare)` "Özəl turnir". Body flex (scroll),
padding `6 16 0`, gap 12:
1. Field "Ad" (label 12 w600 `text@.6`, padding-left 4, gap 6) +
   `NardTextField` h 52, radius 14, fill `c.surfaceSunken`, focused ring
   1.5px `accent`, 16px "Ofis Kuboku · Noyabr". Max length not shown
   (*proposal* 3–32, profanity-checked server-side).
2. Overline "OYUNÇU SAYI" `text@.55` (padding `4 4 0`) + **EqualChips**
   radius 12, h 40, 14 w600: "4" · "8" (selected) · "16" · "32".
3. `GroupCard` rows min-h 48, padding h 14, gap 12, 15px label flex:
   - value rows: value 14 `text@.6` + `chevron-right` 14 stroke 2.5
     `text@.5` → picker sheet (`showNardSheet` with the 2.2 tiles,
     *proposal*): **Oyun** "Qısa nərd" · **Matç uzunluğu** "5 xal" ·
     **Vaxt nəzarəti** "15 san + 3 dəq" · **Başlama vaxtı** "Şənbə, 20:00"
     (date + time picker) · **Giriş haqqı** "Pulsuz".
   - switch rows (`NardSwitch` compact 44×26): **Yalnız dəvət kodu ilə**
     (on) · **Kub istifadəsi** (on; hidden for Uzun nərd — no cube,
     ADR-010).
   Format (knockout / Swiss / round-robin) is **not** offered; sizes 4–32
   powers of two → knockout *(inferred, §19.12)*.
Footer padding `16 16 40`, gap 10: note 12 `text@.55` centred "Yaratmaq
pulsuzdur. Özəl turnirlər reytinqə təsir etmir." + primary l "Turniri
yarat" → `POST /tournaments/private` → 22.2.

### 7.2 22.2 Invite · registration (Dəvət et · qeydiyyat)
Bg `c.bgGradient`. Header bare: title = tournament name (flex, ellipsis) +
trailing text button "Düzəliş" 14 w600 `accentHi` (organizer only; edits
22.1 until start).
Body flex, padding `6 16 0`, gap 14:
1. **Invite card** (§0 fill/ring, radius 18, padding 16, gap 12):
   overline 12 w600 letterSpacing .96 `accent` "DƏVƏT KODU" · code Plex
   Mono 600 34/1 letterSpacing 5.4 (.16em) `text` "K7Q-29M" (6 chars shown
   3-3 with a hyphen; the hyphen is display only) · meta 13 `text@.7`
   "Şənbə, 2 noyabr · 20:00 · Qısa nərd, 5 xal" · buttons row gap 8, each
   flex h 44 radius 12, 14 w600: "Kopyala" (ring 1px `accent@.3`, `text`)
   → copy code + snackbar `copied` · "Linki paylaş" (fill `accent`,
   `c.onAccent`) → system share with link + code.
2. Row baseline space-between, padding h 4: overline "QEYDİYYAT" `text@.55`
   · "5 / 8" 14 w700 tnum.
3. `GroupCard` of entrants, rows h 50, padding h 14, gap 12: avatar 32
   (ring 1px `accent@.5`, initial Noto 14; me `c.avatarMe`, others fill
   `text@.08`) · name 15 flex · status 12: organizer "Təşkilatçı" `accent`;
   others "Qoşuldu" `text@.55`. Organizer row long-press / swipe → remove
   player *(proposal, not drawn)*.
Footer padding `16 16 40`, gap 10:
- Primary l "İndi başlat · ən az 8 oyunçu" — disabled (§0 disabled primary)
  until the minimum is reached; enabled → "İndi başlat" (starts before the
  scheduled time).
- Text button h 44, 15 w600 `dangerText` "Turniri ləğv et" → confirm
  sheet *(proposal)* → refund entries (if any) → 4.1.
Players' view (not drawn, *proposal*): same screen without "Düzəliş",
"İndi başlat" and "Turniri ləğv et"; footer outline "Qeydiyyatı ləğv et".

### 7.3 Join by code (not designed)
*Proposal*: 4.1 "+" opens a chooser sheet "Özəl turnir yarat / Kodla
qoşul"; join = `CodeField` 6 cells (letters + digits, auto-hyphen display)
+ primary "Qoşul" → 22.2 (player view). Deep link
`nardarena://t/{code}` (Phase 7 with deep links, ADR-037).

### 7.4 Strings (22.x)
| key | az |
|---|---|
| privateTourTitle | Özəl turnir |
| privateTourName | Ad |
| privateTourNameHint | Turnirin adı *(proposal)* |
| privateTourSize | OYUNÇU SAYI |
| privateTourGame | Oyun |
| privateTourLength | Matç uzunluğu |
| privateTourTime | Vaxt nəzarəti *(= `sngTimeControl`)* |
| privateTourStart | Başlama vaxtı |
| privateTourEntry | Giriş haqqı *(= `sngEntryFee`)* |
| privateTourInviteOnly | Yalnız dəvət kodu ilə |
| privateTourCube | Kub istifadəsi |
| privateTourFree | Pulsuz *(existing `obtainFree`; own key)* |
| privateTourStartValue | {weekday}, {time} *(locale weekday via `intl`)* |
| privateTourNote | Yaratmaq pulsuzdur. Özəl turnirlər reytinqə təsir etmir. |
| privateTourCreate | Turniri yarat |
| privateTourEdit | Düzəliş |
| privateTourCodeLabel | DƏVƏT KODU |
| privateTourMeta | {date} · {time} · {variant}, {points} xal |
| roomCopy | **existing key** (Kopyala) |
| privateTourShareLink | Linki paylaş |
| privateTourShareText | NardArena-da "{name}" turnirinə qoşul. Dəvət kodu: {code} *(proposal)* |
| privateTourRegistration | QEYDİYYAT |
| privateTourOrganizer | Təşkilatçı |
| privateTourJoined | Qoşuldu |
| privateTourStartNowMin | İndi başlat · ən az {n} oyunçu |
| privateTourStartNow | İndi başlat *(proposal)* |
| privateTourCancel | Turniri ləğv et |
| privateTourCancelTitle / privateTourCancelBody | Turnir ləğv edilsin? / Bütün oyunçulara bildiriş gedəcək. *(proposals)* |
| privateTourJoinByCode / privateTourCreateChoice | Kodla qoşul / Özəl turnir yarat *(proposals)* |
| copied / cancel | **existing keys** |

Icons: `chevron-left`, `chevron-right`, `copy` / `share-2` (optional, mock
buttons are text-only). Widgets: `NardTextField`, EqualChips, `GroupCard`,
`NardSwitch` (compact), `showNardSheet`, `CodeField`, `NardButton`.

---

## 8. 2.1 Home: Phase 6 parts

Adds to `screens.md` 2.1, `online.md` §7.1, `store.md` §6.4.
1. **Live tournament banner** (below the mode grid, full width, only when I
   am registered in / playing a tournament that is live or starts within 1 h
   *(inferred)*): radius 16, clip, fill `c.surfaceRaised`, ring 1px
   `accent@.2`, row:
   - thumb 84 wide, full height: tournament art (data) or fallback §0;
   - content flex, padding `12 14`, gap 4: overline 11 w600 letterSpacing
     .55 (.05em) `dangerText` "● CANLI · RAUND 3" (registration-open /
     upcoming → `accentHi` "QEYDİYYAT AÇIQDIR" / start time, *inferred*) ·
     name Noto 16 w600 · meta 12 `text@.64` "Növbəti matçın 14 dəq sonra ·
     50 000 sikkə" (next match · prize fund).
   Tap → 4.3 / 4.4 (live) or 4.2. Several → the one starting soonest.
2. **Season card** (right half of the 2-column bottom grid next to the
   daily-mission card; in Phase 4 the mission card spans both): radius 16,
   padding 12, fill `c.tile`, ring 1px `c.tileRing`, column gap 8:
   overline 11 w500 `text@.64` "SEZON 4 · 18 GÜN" · 13/17 w500 "Səviyyə 18
   / 50" · bar h 4 radius 2 track `text@.12`, fill `accent`, width = level
   / max (36%). Tap → 7.1.

| key | az |
|---|---|
| homeTourLive | CANLI · RAUND {n} *(= `tourStatusLive`)* |
| homeTourMeta | Növbəti matçın {n} dəq sonra · {prize} |
| homeTourPrize | {amount} sikkə *(`priceCoins` existing)* |
| homeSeason | SEZON {n} · {days} GÜN |
| homeSeasonLevel | Səviyyə {level} / {max} |

---

## 9. 6.5 Leaderboard (Liderlər cədvəli)

**Purpose:** player rating rankings per variant and season, by scope.
Entry not drawn (*proposal*: 8.1 Profile rating tile → 6.5; and a
"Liderlər" link on 4.1). No tab bar and no back in the mock → pushed
screen with a bare back chevron *(inferred)*.

Layout (bg leaderboard radial §0):
1. Top block padding `4 16 0`, gap 12:
   - Row space-between: title Noto 24 w600 "Liderlər" (*no token*) ·
     **season picker** h 32, padding h 12, radius 10, ring 1px `accent@.24`,
     row gap 6: 13 "Sezon 4" + Lucide `chevron-down` 12 stroke 2.5 →
     sheet with seasons (current first; past seasons = frozen end-of-season
     tables) *(inferred)*.
   - **UnderlineTabs** h 38: **Qlobal · Ölkə** (selected) **· Dostlar ·
     Klan**.
   - Variant **compact segmented** (`NardSegmented` compact / `PillSegmented`:
     container padding 3, radius 12, fill `c.surfaceSunken`; segment h 30,
     padding h 14, radius 9, 12px; selected `ivory100` / `walnut900` w600;
     else `text@.7`): "Qısa" · "Uzun"; left-aligned (not full width).
2. **PlayerPodium**, padding `16 16 12`, row bottom-aligned, gap 10, order
   2 · 1 · 3; column width 104, gap 6: Avatar (1st **78** with
   `c.brassRing`, 2nd/3rd **62** with silver/bronze ring §0, padding 3;
   inner fill = player avatar, initial Noto 18) · name 13 w600 · rating 12
   `text@.64` tnum "2 210" · place Noto 18 w600 in the place colour §0.
   No pedestals (unlike 5.7).
3. **Rows** (from 4), flex, scroll: h 50, padding h 16, gap 12, bottom
   border `accent@.08`: rank width 28, 13 `text@.6` tnum · `FlagSwatch`
   18×12 radius 2 · name 14 flex ellipsis · rating 14 tnum.
4. **PinnedMeRow** (always visible): padding `10 16 34` (safe bottom), fill
   `c.surfaceRaised`, top border 1px `accent@.3`, row gap 12: "#412" width
   40, 13 w600 `accentHi` tnum · flag · "Elvin (sən)" 14 w600 flex
   (`memberMe`) · rating 14 w600 tnum "1866". When my row is on screen,
   highlight it (`accent@.14`) and keep the pinned bar *(proposal)*.

Mock data: Ölkə · Qısa · Sezon 4: 1 Rauf 2 210 · 2 Aysel_A 2 105 · 3 Orxan
2 040 · 4 Nigar_88 1990 · 5 Fərid 1972 · 6 Leyla 1961 · 7 Samir_77 1955 ·
8 Günay 1948 · 9 Kamran 1940 · 10 Ülvi 1931 · me #412 1866 (all AZ flags;
thousands space shown on podium "2 210" but not in rows "1990", §19.21).

Scopes: Qlobal (all), Ölkə (my profile country), Dostlar (me + friends,
ranks within), Klan (members of my clan — players, not clans; clans are
5.7) *(inferred, §19.20)*. Unranked (provisional / fewer than N games)
players are not listed *(proposal)*; empty Dostlar/Klan → `MessageState`.
Tap a row → profile (8.1 of another player) / 14.1 *(inferred)*.

| key | az |
|---|---|
| leaderboardTitle | Liderlər |
| seasonN | Sezon {n} |
| lbScopeGlobal | Qlobal |
| lbScopeCountry | Ölkə |
| lbScopeFriends | Dostlar *(same text as existing `friendsTitle`; own key)* |
| lbScopeClan | Klan *(same text as existing `tabClan`; own key)* |
| variantShortAbbr / variantLongAbbr | **existing keys** (Qısa / Uzun) |
| lbRank | #{n} |
| memberMe | **existing key** ({name} (sən)) |
| lbEmptyFriends / lbEmptyClan / lbUnranked | Dostların hələ reytinqdə yoxdur / Klanın yoxdur / Reytinqə düşmək üçün {n} reytinq oyunu oyna *(proposals)* |
| lbSeasonPicker | Sezon seç *(proposal, sheet title)* |

Icons: `chevron-down`, `chevron-left`. Widgets: `UnderlineTabs`,
`NardSegmented` (compact), PlayerPodium, Avatar, `FlagSwatch`,
PinnedMeRow, `showNardSheet`, `MessageState`.

---

## 10. Seasons

### 10.1 7.1 Season pass (Sezon bileti)
Entry: Home season card, store card (`store.md` §3.1 note 3), 3.2 obtain
row "Sezon bileti · Premium".
Layout (bg season gradient §0, season data):
1. Header padding `4 16 16`, gap 6 (no back drawn → bare chevron,
   *inferred*):
   - Overline 12 w600 letterSpacing .96 (.08em) season ink `#8FD0DC`
     "SEZON 4 · 18 GÜN 6 SAAT" (days + hours left; < 1 day → "SAAT · DƏQ"
     *proposal*).
   - Season name Noto 30 w600 "Xəzər" (data).
   - Level row, padding-top 6, gap 12: level box 44×44, radius 12, fill
     `accent`, Plex 700 18 `c.onAccent` "18" · column flex gap 5: row
     space-between 12: "Səviyyə 19-a" · "640 / 1000 XP" tnum `text@.7`
     (`xpProgress` existing) · bar h 6 radius 3 track `text@.12` fill
     `accent` (64%).
2. **SeasonTrack** grid: columns `62 | 4 × 1fr`, gap 8, padding h 16,
   horizontally scrollable by level (mock shows 17–20 of 50; current level
   centred on open, *inferred*):
   - Header row: empty cell + level numbers 12 w600 tnum (current
     `accentHi`, else `text@.6`).
   - Row **PULSUZ** (11 w600 `text@.6`) + tiles: aspect 3:4, radius 12,
     fill `text@.05`, ring 1px `accent@.16`, column centred gap 4: art 28×28
     radius 8 (item thumb / coin glyph; mock placeholder stripes) · label
     10/12 centred, padding h 4 · claimed mark "✓" 10 w700 `successText`
     (claimed tiles opacity .6). The **next** reward (level 19) ring 1.5px
     `accent`. Claimable (reached, not claimed) state not drawn →
     *proposal*: ring 1.5px `successText` + tap to claim.
   - Row **PREMİUM** (11 w600 `accentHi`) + premium tiles §0, Lucide
     `lock` 12 stroke 2.5 `accentHi` at top 6 / right 6 while premium is not
     owned; seasonal-rarity item ring 1.5px `raritySeasonal`.
   Mock rewards (levels 17 · 18 · 19 · 20): free "200 sikkə" ✓ · "Emote" ✓ ·
   "300 sikkə" · "Zər · Nadir"; premium "Daşlar · Epik" · "50 yaqut" ·
   "Caspian taxta" · "Çərçivə". Tile tap → item sheet (3.2) / claim.
3. **Season-end reward card**, margin `18 16 0`, padding 14, radius 16,
   fill `text@.04`, ring 1px `accent@.16`, row gap 12: hex 38×44
   `c.tierFill(current target tier)` (Almaz) · column flex gap 2: 13 w600
   "Sezon sonu mükafatı · Almaz" · 12 `text@.6` "Çərçivə + 2 000 sikkə · 158
   xal qaldı" (reward of the next tier + rating points still needed). At
   Qrossmeyster or max: "Qrossmeyster · Çərçivə + … · əldə edildi"
   *(proposal)*. Tap → sheet with all tier rewards *(proposal)*.
4. Spacer; footer `0 16 40`: primary **h 58** pill "Premium aç · ◆950"
   (gem glyph 12 `c.gemFill`, gap 8) → 7.4-style confirm sheet (price,
   Yaqut balance after; shortfall → Yaqut pack, `store.md` §3.2) → unlock;
   premium owned → footer hidden or "Hamısını al" (claim all,
   *proposal*). Unlocking premium later grants all premium rewards of
   levels already reached *(proposal, standard)*.

### 10.2 7.2 Season summary (Sezon xülasəsi)
Shown once on first open after a season ends (modal full screen), and from
profile history *(inferred)*. Bg season-summary radial §0 (tier tint).
Body flex, width 100%, padding `30 16 0`, column centred gap 18:
1. Overline 12 w600 .08em `text@.64` "SEZON 3 BAŞA ÇATDI".
2. **RankBadge 110×126** (hex `c.tierFill(diamond)`, inner hex 82×94
   `c.rankInner`, numeral Noto 30 w600 tier ink `#CFE6FF` "III") — existing
   `RankBadge` at a new size.
3. Tier name Noto 30 w600 "Almaz III" (`rankWithSub` existing).
4. Stats grid 2 columns, gap 8: tile padding 14, radius 14, fill `text@.05`,
   ring 1px `accent@.16`, column gap 3: value Plex 22 w600 tnum · label 12
   `text@.6` (= 8.1 stat tile): 214 Oyun · 61% Qələbə · 38 Mars · 9 Ən
   uzun seriya · #412 Ölkədə yer · +386 Reytinq artımı.
Footer `0 16 40`: primary l "Mükafatları al" → `POST
/seasons/{id}/rewards/claim` → reward reveal (12.3-style list of fixed
items/coins; not drawn, *proposal*) → Home.
Not shown: per-variant split (which variant's tier?), the soft-reset new
rating, the rewards themselves (§19.22).

### 10.3 Strings (seasons)
| key | az |
|---|---|
| seasonPassTitle | Sezon bileti *(same text as existing `itemSeason`; own key, a11y/title)* |
| seasonOverline | SEZON {n} · {days} GÜN {hours} SAAT |
| seasonOverlineHours | SEZON {n} · {hours} SAAT {minutes} DƏQ *(proposal)* |
| seasonLevelTo | Səviyyə {n}-a *(suffix harmony: 19-a, 20-yə, 40-a, 50-yə, §19.29)* |
| xpProgress | **existing key** ({xp} / {next} XP) |
| seasonTrackFree | PULSUZ |
| seasonTrackPremium | PREMİUM |
| seasonRewardCoins | {amount} sikkə *(`priceCoins` existing)* |
| seasonRewardGems | {amount} yaqut *(`priceGems` existing)* |
| seasonRewardItem | {category} · {rarity} *(e.g. "Zər · Nadir", "Daşlar · Epik"; category/rarity labels existing: `categoryDice`, `rarityRare` …)* |
| seasonEndReward | Sezon sonu mükafatı · {tier} |
| seasonEndRewardMeta | {reward} · {points} xal qaldı |
| seasonPremiumUnlock | Premium aç · {price} *(gem glyph; Row)* |
| seasonClaim / seasonClaimAll / seasonClaimed | Al / Hamısını al / Alındı *(proposals; `missionClaim` "Al" exists)* |
| seasonPremiumOwned | Premium aktivdir *(proposal)* |
| seasonEnded | SEZON {n} BAŞA ÇATDI |
| rankWithSub / tierDiamond … | **existing keys** |
| seasonStatGames | Oyun |
| seasonStatWinRate | Qələbə |
| seasonStatMars | Mars |
| seasonStatStreak | Ən uzun seriya |
| seasonStatCountryRank | Ölkədə yer |
| seasonStatRatingGain | Reytinq artımı |
| statPercent / ratingDeltaUp / ratingDeltaDown | **existing keys** |
| seasonClaimRewards | Mükafatları al |
| seasonSoftReset | Yeni sezon: reytinqin {rating} oldu *(proposal, §19.22)* |

Icons: `lock`, `chevron-left`, `check` (claim, proposal). Widgets:
SeasonTrack/PassRewardTile, `LevelBadge`-like square (new: radius 12 brass
box), `NardProgressBar`, `RankBadge` (110), stat tile (8.1), `CurrencyIcon`,
`ItemThumb`, purchase confirm sheet (`store/purchase_flow.dart`).

---

## 11. 10.1 Analysis (Təhlil) — Phase 6 parts on the replay viewer

Base layout = `screens.md` 10.1 / `apps/client/lib/screens/replay_screen.dart`
(header, board, move list, scrubber, 5 controls). Phase 6 adds the parts
that were struck out there. Entry: 2.6 "Təhlil" (`game.md` §7), 8.1 history
row, 13.2 "Təhlilə bax", 4.3 finished match. Analysis runs on device
(`nard_ai`, strongest level, in an Isolate, spec §6) when the screen opens;
results cached per game record.

Deltas (top to bottom):
1. **Header** title becomes "Təhlil · Oyun 3" (`analysisTitle`; the replay
   keeps `replayTitle` "Replay · Oyun {n}") + "Elvin – Kerem_TR".
2. **Equity row** padding `4 16 10`, gap 10: label "Ekvitet" 12 `text@.6`
   width 44 · **EquityBar** flex (§0): White share = (1 + E) / 2 of the
   width, E = equity for White in [−1, +1] (mock +0.24 → 62%); values
   beyond ±1 (gammons) clamp *(proposal)* · value 13 w600 tnum width 44
   right "+0.24" (sign always shown; U+2212 minus). Equity shown = the
   position **after the best play** of the current move, from the
   viewer's side or White's side (§19.24). Animate width `NardMotion.fast`.
3. **Board overlay** (`MoveArrowsOverlay`, painted above the Flame board,
   not interactive): **best move** solid arrow (§0) per checker step,
   **your move** dashed arrow (§0); same from-point → arrows overlap like
   the mock (13 → 7/10 vs 13 → 4). Shown only when your move ≠ best.
   Board shows the position **before** the move with its dice (6-3).
4. **Legend** row gap 16, padding `10 16 0`, 12px: swatch 16×3 radius 2
   `successText` + "Ən yaxşı: 13/7 13/10" `text` · dashed swatch 16 (2px
   dashed `dangerText`) + "Sənin: 13/4 · −0.142" `dangerText`. When equal:
   one line "Ən yaxşı gediş ✓" in `successText` *(proposal)*.
5. **Move list** 4th column (EvalMark, 54 wide, right, w700): "✓"
   `successText` (best or within threshold) · "?" `accentHi` (mistake) ·
   "??" `dangerText` (blunder) + row fill `dangerText@.14`. Current row
   keeps the replay highlight `accent@.12` (blunder fill wins *(proposal)*).
   Opponent's moves are evaluated too (marks shown, *inferred*); cube
   actions (İkiqat / Qəbul / İmtina) get marks from cube analysis (not
   designed, §19.25).
6. **Scrubber marks**: 8 Ø dots at each mistake (`accentHi`) / blunder
   (`dangerText`) position along the track, under the thumb (mock 22%,
   46%, 64%, 81%). Tap a dot → jump there *(proposal)*.
7. Controls unchanged. *Proposal*: a "Növbəti səhv" (next mistake) action
   — long-press "İrəli".

Loading: while analysing, eval column shows a 12 px spinner per row and the
equity row shows "Təhlil edilir…" `text@.6`; progress fills top-down
*(proposal)*. Long Nard: same UI (no cube). Summary (error rate "Orta səhv
dərəcəsi" on 8.1, achievement "Səhvsiz matç") derives from these numbers
(§13).

Classification thresholds are not in the design: mock −0.142 = "??",
puzzle −0.084 = wrong. *Proposal*: ✓ < 0.04, "?" 0.04–0.10, "??" ≥ 0.10
equity loss (cubeless, per move) — §19.23.

| key | az |
|---|---|
| analysisTitle | Təhlil · Oyun {n} |
| replayPlayers | **existing key** ({p1} – {p2}) |
| analysisEquity | Ekvitet |
| analysisEquityValue | {sign}{value} *(2 decimals; dot vs comma §19.27)* |
| analysisBest | Ən yaxşı: {moves} |
| analysisYours | Sənin: {moves} · {loss} *(loss 3 decimals, U+2212)* |
| analysisBestPlayed | Ən yaxşı gediş ✓ *(proposal; ✓ allowed in small badges only — use a drawn check)* |
| analysisRunning | Təhlil edilir… *(proposal)* |
| analysisMarkGood / analysisMarkMistake / analysisMarkBlunder | Yaxşı gediş / Səhv / Kobud səhv *(proposals, a11y labels for ✓ / ? / ??)* |
| analysisNextMistake | Növbəti səhv *(proposal)* |
| actionAnalysis | Təhlil *(2.6 button, `game.md`; not in ARB yet)* |
| replayStart … replayEnd | **existing keys** |

Icons: same as replay. Widgets: EquityBar, MoveArrowsOverlay, EvalMark,
scrubber marks (extend the replay scrubber), `ScreenHeader(bare)`.

---

## 12. Practice puzzles (Ekranlar 7 · 13.x · "Məşq tapmacaları")

Sebeke-raw mocks. Entry not drawn (*proposal*: Home mode tile "Tapmaca"
(Lucide `puzzle`) and the 12.1 mission "Məşq tapmacası həll et" →
puzzles). Works offline (spec §8.10); rating syncs when online
*(proposal)*.

### 12.1 13.1 Find the best move (Ən yaxşı gedişi tap)
Bg `c.bg`.
1. Header bare h 48: `chevron-left` · "Tapmaca 14 / 40" Noto 20 flex
   (position in the current set / pack) · "Reytinq 1420" 13 `text@.65`
   tnum (puzzle rating, separate from game rating).
2. **TagChips** row gap 6, padding `0 16 12`: h 26, padding h 10, pill,
   fill `text@.06`, ring 1px `accent@.2`, 12 `text@.75` (static): variant
   "Qısa nərd" · phase "Ara oyun" · difficulty "Orta".
3. Prompt padding `0 16 14`, gap 4: title Noto 22/28 w600 "Ən yaxşı gedişi
   tap" · body 14/20 `text@.7` "Ağ daşlarla oynayırsan. Zər: 6 – 4. Hesab 3
   – 5, 7 xala qədər." (side · dice · match score/length; money/single
   game → omit the score part *(proposal)*).
4. **Board** 378 wide (`board/` widget, portrait), dice 6-4 shown, normal
   move input: selection ring on point 24, legal targets 18 and 14
   highlighted (= game input with "show legal moves"). Moves are staged
   locally, undo allowed, nothing is sent until confirm.
5. Spacer; footer row padding `0 16 40`, gap 10: **İpucu** 120×56, radius
   16, ring 1px `accent@.3`, row gap 8: diamond 10 rotated 45° border 2
   `accent` + 15 w600 "İpucu" · primary flex h 56 "Gedişi təsdiqlə"
   (disabled until a full legal move is staged, *inferred*).
Hint *(not designed, proposal)*: highlights the from-point(s) of the best
move with the brass ring; using it caps the rating gain at +0 / marks
"İpucu ilə".

### 12.2 13.2 Correct (Doğru)
Board shows my played move with last-move markers (24 → 14). The footer is
replaced by **PuzzleResultPanel** (§0), padding `20 16 40`, gap 14:
1. Row gap 12: icon disc (success, `check`) · column flex gap 2: title Noto
   20 w600 `successText` "Doğru!" · sub 13 `text@.65` "Ən yaxşı gediş · ilk
   cəhddə" · rating delta 15 w700 tnum `successText` "+12".
2. Compare box padding `12 14`, radius 12, fill `c.surfaceSunken`, 13px,
   rows gap 6; row gap 10: swatch 16×3 radius 2 (row colour) · label flex
   `text@.75` · move Plex Mono 12 · eval width 54 right w700 tnum (row
   colour): "Sənin · 24/14 · 0.000" (`successText`) · "İkinci yaxşı ·
   13/7 13/9 · −0.084" (`text@.6`).
3. Buttons row gap 10, each flex h 52: outline radius 16 "Təhlilə bax" →
   10.1-style analysis of this position (*inferred*: board + arrows +
   ranked candidate list) · primary pill "Növbəti tapmaca".

### 12.3 13.3 Wrong (Yanlış)
Board resets to the puzzle position (no markers). Panel edge `dangerText@.6`:
icon disc (danger, `x`) · title `dangerText` "Ən yaxşı gediş deyil" · sub
"Bir cəhd qaldı" · delta "−8" `dangerText`. Compare rows: "Sənin · 13/7
13/9 · −0.084" (`dangerText`) · "Ən yaxşı · gizli" (`successText` swatch,
move text "gizli", eval empty). Buttons: outline "Həllə bax" (reveals the
best move; counts as failed) · primary "Yenidən cəhd et" (`retry`
existing) → back to 13.1 with the panel closed.
After the 2nd wrong attempt *(not designed, proposal)*: title "Düzgün
cavab: {move}", sub "Cəhdlər bitdi", buttons "Təhlilə bax" · "Növbəti
tapmaca".

Scoring seen: first-try correct +12, wrong −8 (puzzle rating 1420);
2 attempts per puzzle; "ilk cəhddə" implies less for a second-try success
*(proposal: +6)*. Correct = equal to the best move (or within a small
tolerance, §19.23 — the 2nd best at −0.084 is **wrong**).

### 12.4 Strings (13.x)
| key | az |
|---|---|
| puzzleTitle | Tapmaca {n} / {total} |
| puzzleRating | Reytinq {n} |
| puzzlePhaseOpening / puzzlePhaseMiddle / puzzlePhaseBearOff | Açılış / Ara oyun / Çıxarış *(only "Ara oyun" drawn; others proposals)* |
| puzzleLevelEasy / puzzleLevelMedium / puzzleLevelHard | Asan / Orta / Çətin *(only "Orta" drawn; "Orta" = existing `aiLevelMedium` text, own key)* |
| variantShort / variantLong | **existing keys** (tag) |
| puzzlePrompt | Ən yaxşı gedişi tap |
| puzzleContext | {side} oynayırsan. Zər: {d1} – {d2}. Hesab {me} – {opp}, {points} xala qədər. |
| puzzleSideWhite / puzzleSideBlack | Ağ daşlarla / Qara daşlarla |
| puzzleContextNoScore | {side} oynayırsan. Zər: {d1} – {d2}. *(proposal)* |
| puzzleHint | İpucu |
| puzzleConfirm | Gedişi təsdiqlə |
| puzzleCorrect | Doğru! *(exclamation in system copy vs readme, §19.28)* |
| puzzleCorrectFirstTry | Ən yaxşı gediş · ilk cəhddə |
| puzzleCorrectSecondTry | Ən yaxşı gediş · ikinci cəhddə *(proposal)* |
| puzzleRatingDelta | +{n} / −{n} *(existing `ratingDeltaUp` / `ratingDeltaDown`)* |
| puzzleYours | Sənin *(same text as existing `you`; own key)* |
| puzzleSecondBest | İkinci yaxşı |
| puzzleBest | Ən yaxşı |
| puzzleHidden | gizli |
| puzzleSeeAnalysis | Təhlilə bax |
| puzzleNext | Növbəti tapmaca |
| puzzleWrong | Ən yaxşı gediş deyil |
| puzzleAttemptsLeft | Bir cəhd qaldı *(plural form proposal: "{n} cəhd qaldı")* |
| puzzleShowSolution | Həllə bax |
| retry | **existing key** (Yenidən cəhd et) |
| puzzleOutOfTries / puzzleAnswer | Cəhdlər bitdi / Düzgün cavab: {move} *(proposals)* |
| puzzleSetDone | Bu dəst bitdi *(proposal; after 40 / 40)* |
| missionPuzzle | Məşq tapmacası həll et *(12.1 daily mission, x2, +30)* |
| modePuzzles | Tapmaca *(proposal, Home tile)* |

Icons: `chevron-left`, `check`, `x`, `puzzle` (tile, proposal). Widgets:
board widget (interactive, puzzle mode), TagChip, PuzzleResultPanel,
`NardButton` (outline, primary), compare rows (like 10.1 legend).

---

## 13. Phase-6 deltas on existing screens

- **TabBar**: insert `NardTab(LucideIcons.trophy, l.tabTournaments)` after
  Əsas (design order Əsas · Turnirlər · Klan · Mağaza · Profil;
  `tab_shell.dart`).
- **2.3 AI level**: Usta and Qrossmeyster unlocked (remove `locked` in
  `ai_level_screen.dart`) when the stronger evaluator ships (ADR-019);
  descriptions `aiLevelMasterDesc` "Klub oyunçusu səviyyəsi",
  `aiLevelGrandmasterDesc` "Ən güclü rejim, səhv etmir" (existing). Design
  "~elo" 2000 / 2300 stay hidden (QUESTIONS #5). "İpuçlarını göstər" row
  (`screens.md` key `aiShowHints`, not in ARB) returns as the best-move
  hint (QUESTIONS #2 answer a).
- **2.6 Match result**: "Təhlil" button (`game.md` §7 `actionAnalysis` /
  `matchAnalysis`) → §11; tournament matches show "Cədvələ bax" instead of
  "Revanş" *(proposal)*.
- **GameScreen** in a tournament: mode line "Turnir · 1/8 · 5 xala qədər"
  *(proposal; not drawn)*; no rematch, no resign-to-leave without a
  confirm that mentions elimination *(proposal)*.
- **8.1 Profile**: "KUBOK VİTRİNİ" + "Hamısı" (`online.md` §5 item 4, keys
  `trophyShowcase` / `seeAll`): 4 tiles flex, h 76, radius 12, stripes
  placeholder, ring 1px by placement (1st `accentHi`, 2nd `#D8DCE0`, empty
  slot `accent@.2`); tap → trophy list (not designed). Stat
  "Orta səhv dərəcəsi" (`statErrorRate`) from analysis (§11). History
  row for tournaments: meta "Turnir · 1/16", rating "—", bar `accent`
  (already in `online.md`).
- **8.2 Achievements**: "Turnir qalibi" (win a tournament) and "Səhvsiz
  matç" (a match without "?"/"??") unlock now (`store.md` §5).
- **3.2 Item sheet**: obtain row "{tournament} · Top {n} mükafatı" (e.g.
  "Bakı Payız Kuboku · Top 3 mükafatı") and "Sezon bileti · Premium ·
  Səviyyə 40" become live data.
- **7.3 Store**: season-pass card linking to 7.1 (`store.md` §3.1 note 3).
- **12.1 Missions**: daily "Məşq tapmacası həll et" 1/2 → +30 (waits for
  puzzles, ADR-034).
- **16.1 / 16.2 notifications** (Phase 7): group "TURNİR": "Turnir
  başlayır" (sub "15 dəqiqə əvvəl") and "Raund hazırdır"; inbox item
  "Bakı Cümə Kuboku · 15 dəqiqəyə başlayır" (Lucide `trophy`). Phase 6
  should already emit these events.

| key | az |
|---|---|
| tabTournaments | Turnirlər |
| trophyShowcase | KUBOK VİTRİNİ |
| seeAll | Hamısı |
| statErrorRate | Orta səhv dərəcəsi |
| obtainTournamentTop | {tournament} · Top {n} mükafatı *(`store.md` key `obtainTournamentTop` "Top {n} mükafatı")* |
| historyTournament | Turnir · {round} |
| achTournamentWinner / achFlawlessMatch | Turnir qalibi / Səhvsiz matç |
| aiShowHints | İpuçlarını göstər |
| notifTournamentStarts / notifTournamentStartsSub / notifRoundReady / notifTournamentSoon | Turnir başlayır / 15 dəqiqə əvvəl / Raund hazırdır / {name} {n} dəqiqəyə başlayır *(Phase 7)* |

---

## 14. Navigation (Phase 6 additions)
```
Tabs: Əsas · Turnirlər · Klan · Mağaza · Profil
Turnirlər ▶ 4.1 ─card (open/upcoming)▶ 4.2 ─Qeydiyyat▶ registered (4.2)
               ─card (live KO)▶ 4.3 ─Hazıram▶ (round opens) 2.5 VS ▶ GameScreen ▶ 2.6 ▶ 4.3
                                    ─live card▶ 6.4 spectate ; ─finished card▶ 10.1
               ─card (live Swiss)▶ 4.4 (playoff ▶ 4.3)
               ─Sit-and-go▶ 21.1 ─full▶ 4.3 ; ─timeout▶ 21.4 ─join smaller▶ 21.1
               ─"+"▶ chooser ▶ 22.1 ─Turniri yarat▶ 22.2 ─İndi başlat▶ 4.3
                              └▶ join by code ▶ 22.2 (player view)
Round opens, opponent absent ▶ 21.2 ─timer 0▶ 21.3 ─Cədvələ bax▶ 4.3
Final won ▶ 4.5 ─Kuboku vitrinə qoy▶ 8.1 showcase / back
Home: tournament banner ▶ 4.3/4.4/4.2 ; season card ▶ 7.1 ; Tapmaca tile ▶ 13.1
Season end (first open) ▶ 7.2 ─Mükafatları al▶ reward reveal ▶ Home
7.1 ─Premium aç▶ confirm sheet (Yaqut) ▶ 7.1 ; tile ▶ 3.2 item sheet / claim
Profil ▶ rating ▶ 6.5 ; 8.1 history row ▶ 10.1 (analysis)
2.6 ─Təhlil▶ 10.1 ; 13.2 ─Təhlilə bax▶ 10.1-style ; ─Növbəti tapmaca▶ 13.1
Deep links (Phase 7): t/{code} ▶ 22.2 ; tournament/{id} ▶ 4.2
```

## 15. Widget reuse summary
| Need | Reuse | New / extend |
|---|---|---|
| Chrome | `NardBackground`, `RootTitle`, `ScreenHeader(bare)` (+ trailing), `NardTabBar` (+ Turnirlər) | hero header with back over image (4.2) |
| Tabs / filters | `UnderlineTabs`, `NardFilterChip`, `NardSegmented` (compact) / `PillSegmented` | RoundChips, RoundSquares, EqualChips (`NardChoiceChip` expanded + radius), TagChip |
| Cards / lists | `GroupCard`, `KeyValueRow`, `HairlineRow`, `MessageState`, `OfflineBanner`, skeleton | TournamentCard, TournamentBanner, PrizeTiles, StandingsTable, PinnedMeRow |
| Identity | `Avatar` (72, 78, 62, 32), `FlagSwatch`, `RankBadge` (110 new size), `PresenceAvatar` | SeatGrid, PlayerPodium (generalise `_Podium`) |
| Commerce | `CurrencyIcon`, `PriceTag`, `ItemThumb`, purchase confirm sheet, `purchaseNotEnoughCoins` | refund pill, title pill, PassRewardTile |
| Progress / time | `NardProgressBar` (4, 6), `CountUpText` | CountdownRing, EquityBar |
| Celebration | 12.3 / 7.5 layouts, `OrnamentDivider`, success disc (14.4) | CelebrationLayout (shared), trophy asset slot |
| Board | board widget + replay viewer | MoveArrowsOverlay, EvalMark, scrubber marks, puzzle input mode |
| Buttons | `NardButton` primary (h 56/58) / outline / text, `SmallActionButton` (h 44) | 4th disabled primary style (§19.26) |
| Sheets | `showNardSheet`, `SheetTitle` | season picker, tier rewards, picker rows (22.1) |
| Spectate | 6.4 spectator mode | — |

## 16. Later phases — omit in Phase 6
Push/inbox delivery of tournament events (7); deep links (7); trophy 3D
renders and Lottie (assets later; static art or placeholder); clan
championships UI beyond reusing 4.x (needs PO input, §19.2); admin
tournament CRUD (Filament, 7); sharing images (4.5 "Paylaş" may share text
only).

---

## 17. Rules and numbers seen in the design (for product-owner confirmation)

"Spec" = `docs/SPEC.md`; "API now" = nothing exists for tournaments,
seasons, puzzles or analysis (only `/clans/leaderboard`).

| # | Number / rule in the design | Where | Implied rule | Spec / API now |
|---|---|---|---|---|
| 1 | Knockout **64** players, rounds 1/32 … Final; "RAUND 3" = 1/8 | 4.1, 4.2, 4.3 | KO sizes are powers of two; byes if not full? | spec: knockout |
| 2 | Knockout prize split **50 000 = 25 000 / 12 000 / 6 500 + 6 500** | 4.2 | 1st 50%, 2nd 24%, 3rd–4th 13% each (no 3rd-place match) | spec: coin prizes |
| 3 | Prize fund 50 000 vs 64 × 500 entry = 32 000 | 4.1, 4.2 | scheduled prizes are house-funded (coin faucet), not entry pools | coins earn-only (ADR-022) |
| 4 | Entry **500 sikkə · min. 1500** rating | 4.2 | coin entry + minimum rating per tournament | spec: free / coins / invite-only |
| 5 | Registration counter "48 / 64", countdown "02:14:36" | 4.2 | registration closes at start or when full | — |
| 6 | Novruz Çempionatı KO, **7-point** matches, **3 dəq + 12s** | 4.2 | per-tournament match length + clock | server clock 3+12 only (QUESTIONS #20) |
| 7 | Bakı Payız Kuboku "Qısa · **5** xal" but final **7–4** | 4.1, 4.5 | longer final match? | — |
| 8 | Gecə Blitsi **128** players, Qısa · 3 xal · **1+8s** | 4.1 | blitz time control 1 min + 8 s | — |
| 9 | Uzun Nərd Liqası **Swiss · 7 rounds · 128** players, starts "Sabah 20:00" | 4.1 | scheduled Swiss | spec: Swiss |
| 10 | Swiss: **1 point per match win**, W–L column, Buchholz tie-break | 4.4 | standings sort points → Buchholz | spec: Buchholz |
| 11 | "İlk **8** pley-offa keçir" after 7 Swiss rounds | 4.4 | Swiss + top-8 knockout playoff | — |
| 12 | Buchholz shown with one decimal ("24.0", "22.7") | 4.4 | fractional Buchholz (median/cut?) or sample noise | — |
| 13 | Next match "**14 dəq** sonra · 5 xala qədər", "Hazıram" | 4.3, 2.1 | rounds are scheduled; ready check opens ≥ 14 min early | spec: auto-advance |
| 14 | Spectate any tournament match | spec §8.3 | live bracket cards open 6.4 | spec |
| 15 | Champion: **+25 000 sikkə** + title "**Payız Xanı**" + trophy for the showcase | 4.5 | prizes = coins + title + trophy | spec: coins, titles, trophies |
| 16 | Tournament cosmetic prize "Bakı Payız Kuboku · **Top 3** mükafatı" (Marble/Kral set) | 3.2 | cosmetics for top N | rarity `tournament` exists in `economy.php` |
| 17 | Trophy showcase **4** slots; gold/silver rings | 8.1, 4.5 | player picks which trophies to show | — |
| 18 | SnG sizes **8 / 16 / 32** | 21.1 | three queues per format | spec: 8/16/32 |
| 19 | SnG 16 × **500** = 8 000 → fund **7 200** | 21.1 | **10 %** of entries withheld (coin sink) | — |
| 20 | SnG "orta gözləmə 1 dəq" | 21.1 | server shows average fill time | — |
| 21 | SnG **Qısa nərd · 3 xal**, "**12 san + 2 dəq bank**" | 21.1 | SnG uses short matches and a faster clock | clock 3+12 only |
| 22 | Not ready within **30 s** of start → round lost by forfeit | 21.1 | ready check timeout 30 s | spec: no-show handling; §7.3 60 s reconnect grace |
| 23 | No-show ring **0:47 at 78 %** → **60 s** timer | 21.2 | no-show timer 60 s (conflicts with #22) | — |
| 24 | Walkover: "Reytinq dəyişmir"; next round in **2:10** | 21.3 | walkovers unrated; rounds start on a schedule, not when both are free | — |
| 25 | SnG not filled in **10 min** (19 / 32) → full refund (+500) and offer the **16** queue | 21.4 | fill timeout 10 min; refund to balance | — |
| 26 | "Çıx · giriş haqqı qaytarılır" | 21.1 | leaving before start = full refund | — |
| 27 | Private tournament sizes **4 / 8 / 16 / 32** | 22.1 | knockout only; 4 allowed (below SnG's 8) | spec: private (P1) |
| 28 | Private: creating is **free**; "Özəl turnirlər reytinqə **təsir etmir**" | 22.1 | private = unrated; implies public ones may be rated (§19.6) | — |
| 29 | Private entry fee row ("Pulsuz" default, editable) | 22.1 | organizer can set a coin fee? (coin transfer between friends, §19.9) | — |
| 30 | Private clock "**15 san + 3 dəq**", length **5 xal**, cube toggle, invite-code toggle | 22.1 | organizer chooses clock, length, cube, privacy | — |
| 31 | Scheduled start "**Şənbə, 20:00**" + "İndi başlat · ən az **8** oyunçu" | 22.1, 22.2 | min players to start = 8 (= size?); can start early | — |
| 32 | Invite code **K7Q-29M** (6 chars, shown 3-3) | 22.2 | own code format; room codes are 6 chars without hyphen | room code `[A-Z2-9]{6}` |
| 33 | Organizer can edit ("Düzəliş") and cancel | 22.2 | edit until start; cancel refunds | — |
| 34 | Leaderboard scopes Qlobal / Ölkə / Dostlar / Klan × Qısa / Uzun × Sezon | 6.5 | per variant, per season, per scope; my rank always shown (#412) | spec: per-variant ratings |
| 35 | Podium top 3, list from 4, rating as the score | 6.5 | ranking = current rating (season-final for past seasons) | — |
| 36 | Season **4**, "**18 GÜN 6 SAAT**" left; summary of season **3** | 7.1, 7.2, 2.1 | ~6-week seasons (42 d → ~24 d elapsed) | spec: ~6 weeks |
| 37 | Pass **50** levels, **1 000 XP** per level ("640 / 1000 XP"), level 18 | 7.1, 2.1 | flat XP per pass level; pass XP source not shown | store.md §10 #16 |
| 38 | Free track: **200 sikkə** (17), **Emote** (18), **300 sikkə** (19), **Zər · Nadir** (20) | 7.1 | coins on the free track (OK, ADR-022) | — |
| 39 | Premium track: **Daşlar · Epik** (17), **50 yaqut** (18), **Caspian taxta** (19), **Çərçivə** (20) | 7.1 | premium gives Yaqut back (OK, not coins); Caspian at 19 vs Locker "Səv. 30" (QUESTIONS #26) | — |
| 40 | Premium pass **950 yaqut**, one-off | 7.1 | ADR-025 | store.md §10 #15 |
| 41 | Season-end reward **Almaz: Çərçivə + 2 000 sikkə**, "**158 xal qaldı**" | 7.1 | season-end rewards by best/final tier; coins OK (ADR-022) | tiers: Almaz floor **1900** (`rank.dart`); 158 doesn't fit Elvin's 1842/1866 |
| 42 | Season summary: **214** games, **61 %**, **38** Mars, streak **9**, **#412** country, **+386** rating, final **Almaz III** | 7.2 | per-season stats; country rank snapshot at season end | — |
| 43 | Soft reset | spec §8.2 | not shown in any screen (§19.22) | — |
| 44 | Equity **+0.24** ↔ bar **62 %** | 10.1 | bar = (1 + E) / 2, E ∈ [−1, 1] | spec §6 |
| 45 | Your move **−0.142** = "??" blunder | 10.1 | blunder threshold < 0.142 | spec: blunders/mistakes |
| 46 | Marks ✓ / ? / ?? ; 4 marked moves on the scrubber | 10.1 | three classes | — |
| 47 | Best move shown as arrows + notation "13/7 13/10" | 10.1 | best move from the strongest bot | spec: Master level |
| 48 | Puzzle set "**14 / 40**" | 13.1 | puzzles come in sets/packs of 40 | spec §8.8 |
| 49 | Puzzle rating **1420**, **+12** correct (first try), **−8** wrong | 13.2, 13.3 | Elo-like puzzle rating separate from game rating | — |
| 50 | **2 attempts** ("Bir cəhd qaldı"); "ilk cəhddə" | 13.2, 13.3 | second try allowed, worth less | — |
| 51 | 2nd-best move **−0.084** counts as wrong | 13.2, 13.3 | only the best move (or ties) is correct | — |
| 52 | Tags: variant · phase ("Ara oyun") · difficulty ("Orta") | 13.1 | puzzle metadata | — |
| 53 | Hint button ("İpucu") | 13.1 | hint available; cost not shown | — |
| 54 | Daily mission "Məşq tapmacası həll et" **×2 → +30** | 12.1 | puzzles feed missions | ADR-034 (waits for Phase 6) |
| 55 | Tournament notification **15 min** before start; "Raund hazırdır" | 16.1, 16.2 | events for Phase 7 push | spec §8.11 |
| 56 | "Bakı **Cümə** Kuboku" | 16.2 | weekly Friday championship | spec: scheduled weekly |
| 57 | Tournament history row "Turnir · 1/16 · 5–2 · —" | 8.1 | tournament matches show no rating change | — |
| 58 | AI Usta ~2000, Qrossmeyster ~2300 | 2.3 | hidden until calibrated | ADR-019, QUESTIONS #5 |

## 18. Data the screens need (API / protocol)

**REST (Laravel), new:**
- `Tournament {id, name (per-locale map), posterUrl?, trophyArt?, type
  knockout|swiss|round_robin|sng|private, kind scheduled|sng|private|clan,
  status registration|upcoming|live|finished|cancelled, variant,
  matchLength, finalMatchLength?, clock {reserve, delay}, cube bool,
  size (max), minPlayers, entrants, entry {kind free|coins|invite, coins?},
  minRating?, rated bool, startsAt, registrationClosesAt, currentRound,
  totalRounds, roundLabels ("1/8"…), playoffSize? (Swiss top 8),
  prizes [{from, to, coins?, itemId?, titleId?, trophy?}], prizeFund,
  fairDice true, myStatus none|registered|playing|eliminated|champion,
  myPlace?, myNextMatch {id, round, opponent {id, name}, startsAt,
  matchLength, readyState}}`.
- `GET /tournaments?tab=live|upcoming|mine|finished&variant&free&cursor`
  (4.1, Home banner via `mine`); `GET /tournaments/{id}` (4.2);
  `POST /tournaments/{id}/register` (debits coins via the ledger,
  idempotency key) / `DELETE …/register` (refund before start);
  errors `insufficient_coins | rating_too_low | full | closed |
  invite_required | already_registered | account_required`.
- `GET /tournaments/{id}/bracket` → `rounds [{label, startsAt, matches [{id,
  slot, a {userId, name}?, b?, score [a, b], status
  pending|ready|live|finished|walkover|bye, winner, matchId}]}]` (4.3).
- `GET /tournaments/{id}/standings?round=` → `rows [{rank, userId, name,
  wins, losses, points, buchholz, qualified}]`, `me`, `rounds`,
  `playoffSize` (4.4).
- `POST /tournaments/{id}/showcase` (4.5 "Kuboku vitrinə qoy");
  `GET /users/{id}/trophies` + `showcase [4]` (8.1).
- **Sit-and-go:** `GET /sng` → `[{size, variant, matchLength, clock, entry,
  prizeFund, joined, avgWaitSec}]`; join/leave over WS (below).
- **Private:** `POST /tournaments/private {name, size, variant, matchLength,
  clock, startsAt, entry, inviteOnly, cube}` → `{id, code}`; `PATCH` (before
  start), `POST …/start`, `DELETE` (cancel + refunds), `POST
  /tournaments/join-by-code {code}`, `DELETE …/entrants/{userId}`
  (organizer); `organizerId` on the model.
- **Seasons:** `GET /seasons/current` → `{id, number, name (locale map),
  theme {bg, ink}, startsAt, endsAt, pass {levels 50, xpPerLevel 1000,
  myLevel, myXp, premiumOwned, premiumPrice {gems 950}, rewards [{level,
  track free|premium, kind coins|gems|item, amount?, itemId?,
  claimed}]}, endRewards [{tier, coins, itemId?}], myTarget {tier,
  pointsLeft}}`; `POST /seasons/{id}/pass/premium` (Yaqut ledger),
  `POST /seasons/{id}/pass/claim {level, track}` (+ claim all);
  `GET /seasons/{id}/summary` → `{tier, sub, games, winRate, mars,
  longestStreak, countryRank, ratingDelta, rewards[], claimed,
  newRatings {short, long}}` + `POST …/rewards/claim`; `GET /seasons`
  (picker). Season XP source events (matches, missions, puzzles?) on the
  server; `GET /me/progress` gains `season {level, xp}` for Home.
- **Leaderboards:** `GET /leaderboards?variant=short|long&scope=
  global|country|friends|clan&season=&cursor` → `{entries [{rank, userId,
  name, country, avatar, rating}], me {rank, rating}}` (6.5).
- **Puzzles:** `GET /puzzles/sets` / `GET /puzzles/next` → `{id, setIndex,
  setSize 40, variant, phase, difficulty, side, dice [d1, d2], position
  (GNU BG position id or JSON board), matchScore? [me, opp], matchLength?,
  cubeValue?}` (solution not sent before the attempt, or sent hashed for
  offline packs); `POST /puzzles/{id}/attempt {move, attempt 1|2,
  hintUsed}` → `{correct, best, secondBest {move, loss}, yourLoss,
  ratingDelta, rating, attemptsLeft}`; offline: bundled pack with
  solutions + client-side check, attempts queued and re-validated by the
  server on sync (spec §8.10). Mission event `puzzle_solved`.

**WS (game server / `nard_protocol`), new:**
- `tournament.update {id, round, matchId?, status}` (bracket/standings
  diffs, 4.1/4.3/4.4 live), `tournament.ready {matchId}` (Hazıram) →
  `tournament.readyState {matchId, me, opponent}`,
  `tournament.matchStart {matchId, deadline}` (no-show timer start),
  `tournament.noShow {matchId, deadline, opponent}` (21.2 countdown),
  `tournament.walkover {matchId, nextRoundAt}` (21.3),
  `tournament.eliminated {place}`, `tournament.champion {place, prizes}`
  (4.5), `tournament.cancelled {reason not_filled, refund}` (21.4).
- `sng.join {size, variant}` / `sng.leave` → `sng.state {size, joined,
  seats [{initial, me}], avgWaitSec, expiresAt}` → `tournament.start`.
- `match.found` gains `{tournamentId, round, table}` (2.5 VS and the
  "RAUND 1 · MASA 4" overline); `game.state` keeps `rated:false` for
  walkovers/private.
- `spectate.join {matchId}` for tournament matches (exists).
- Game records of tournament matches must be fetchable for 10.1
  (`GET /me/matches/{id}` exists; add others' tournament matches when
  public).

**Client-only (no server):** analysis per move `{index, side, dice,
played, best, bestEquity, playedEquity, loss, class good|mistake|blunder,
equityAfter}` computed by `nard_ai` in an Isolate and cached in the local
DB keyed by game record; error rate / "Səhvsiz matç" for online games need
the server to compute or re-validate (§19.24).

---

## 19. Ambiguities / open questions
1. **Round-robin** has no screen. Reuse 4.4 without BUCH, or a cross-table?
   Group size?
2. **Clan championships** have no screen and no rules (teams? members
   playing individually for clan points? entry by clan leader?). Spec
   lists them; the clan war (5.6) is the closest design.
3. **4.1 tabs**: the "Canlı" tab shows two "QEYDİYYAT AÇIQDIR" cards. Is
   "Canlı" = live + open registration, and "Gələcək" = scheduled later?
   The time slot means "time to my next match" for live cards — what does
   it show if I'm not in the tournament?
4. **4.2 status words**: the hero says "GƏLƏCƏK · KNOCKOUT 64" while 4.1
   says "QEYDİYYAT AÇIQDIR" for the same tournament. One status or two
   (upcoming vs registration open)?
5. **Non-coin prizes on 4.2**: titles/cosmetics/trophies (4.5, 3.2) are not
   listed on the detail screen. Where do they go (proposal §2)?
6. **Rating**: are public tournament matches rated? 8.1 shows "—" for a
   tournament match and 21.3 "Reytinq dəyişmir" for walkovers, but 22.1
   says only *private* tournaments don't affect rating. Recommend:
   tournaments unrated (separate tournament points/trophies), private
   always unrated.
7. **Prize funding and splits**: KO 64 pays 50 000 from a 32 000 entry pool
   (house-funded faucet); SnG keeps 10 %. Confirm the economy (coin
   inflation vs sink) and the split tables per size (only 64-KO drawn;
   SnG 8/16/32 split unknown).
8. **Full tournaments**: waitlist, or hard "Yer qalmayıb"? Unregistration
   deadline and refund rules?
9. **Private tournament entry fee**: allowing coin fees among friends turns
   coins into a transferable stake (gambling look, ADR-022 rationale).
   Recommend: private tournaments always free (hide the row), or fees burnt
   with house-paid prizes.
10. **Sit-and-go entry point** and variants: which formats run (Qısa 3 xal
    only? Uzun?), fixed fee per size, and is 32 realistic with low
    population (21.4 shows it failing)?
11. **SnG prize split** (7 200 among how many places?) not shown.
12. **Private tournament format**: only sizes 4–32, no format picker →
    knockout only? Does a 16-size tournament start with 9 players (byes)?
    "İndi başlat · ən az 8 oyunçu" for size 8 means it must be full —
    min players = size, or a separate minimum?
13. **Time-control wording** differs: "3 dəq + 12s", "1+8s", "12 san + 2 dəq
    bank", "15 san + 3 dəq". Pick one format (recommend existing
    `timeValue` / `timeControlShort`). The server has one clock (3+12,
    QUESTIONS #20): which clocks do tournaments need?
14. **No-show timer**: 21.1 says 30 s, 21.2's ring implies 60 s; spec §7.3
    has a 60 s reconnect grace. Which, and does it start at round open or
    at the scheduled match time?
15. **Ready check** ("Hazıram" 14 min early): mandatory? What if both are
    ready early — start early? Not ready = no-show?
16. **Buchholz decimals** ("22.7") are impossible with integer points and
    no draws. Use full Buchholz (integers) or a cut/median variant? Further
    tie-breaks (Sonneborn-Berger isn't meaningful without draws; head-to-
    head; rating)?
17. **Bracket mock inconsistencies**: the panel says my next 1/4 match is
    "Elvin – Nigar_88" while the tree pairs Elvin with Orxan and Nigar_88
    with Kerem_TR; round chips start at 1/16 for a 64 field. Final length
    7 vs tournament 5 (4.1/4.5). Confirm: final may be longer?
18. **Ceremony**: only the champion has a screen. Runner-up / 3rd place /
    elimination screens? Is "Kuboku vitrinə qoy" a choice (4 slots) or
    automatic? Trophy art per tournament (3D render) — asset pipeline?
19. **Title rarity**: "Titul: Payız Xanı" uses the legendary colour; titles
    in 8.2 are not rarity-coloured. Rarity "tournament" exists in the API
    but has no colour in the design (`store.md` §12.34).
20. **Leaderboard "Klan" tab**: players of my clan, or clans (5.7 already
    ranks clans)? "Dostlar": ranks among friends or global ranks of
    friends? Minimum games to appear? Entry point (not drawn).
21. **Thousands separator**: readme says "12 450" with a space; 6.5 shows
    "2 210" on the podium but "1990" in rows, 7.1 "1000 XP". Apply the
    space for ≥ 10 000 only, or always?
22. **Season reset & summary**: soft-reset formula (e.g. halfway to 1500?),
    which variant's tier is the season tier (7.2 shows one "Almaz III"),
    season-end reward by peak or final tier, and what 7.2 "Mükafatları
    al" grants (no list drawn). The "158 xal qaldı" sample does not match
    the API floors (Almaz 1900).
23. **Mistake thresholds**: −0.142 is "??" and −0.084 is wrong in puzzles,
    nothing else is given. Recommend ✓ < 0.04, ? 0.04–0.10, ?? ≥ 0.10
    (cubeless equity loss), puzzles correct only within 0.001 of best.
24. **Analysis engine & perspective**: spec wants the neural Master level;
    HANDOFF suggests shipping with the heuristic 2-ply bot first — its
    "equity" is a heuristic score, not a probability, so the bar and
    numbers would be misleading until a calibrated evaluator exists.
    Equity from White's side or from the viewer's? Online error-rate stats
    computed on device can be faked — compute server-side for 8.1?
25. **Cube analysis** (double/take/pass errors) is not designed; mark cube
    rows too?
26. **Disabled button styles**: 22.2 adds a 4th disabled primary (garnet
    @.35, faded label) next to DS / 17.3 / 6.3 variants. Pick one.
27. **Decimal mark**: equity "+0.24", "−0.142", Buchholz "24.0" use a dot;
    Azerbaijani uses a comma. Keep the backgammon convention (dot) or
    localise?
28. **"Doğru!"** has an exclamation mark, which the readme forbids in
    system copy. Use "Doğru" (recommended)?
29. **Suffix harmony** in new copy: "Səviyyə 19-a" / "20-yə", "19-u" /
    "8-i", "16 nəfərlikə" / "8 nəfərliyə", "{n}-ci yer" (1-ci, 3-cü, 6-cı),
    "balansına". Needs a number-suffix helper or suffix-free rephrasing
    (as social.md §13.29).
30. **Puzzles**: where do the 40-puzzle sets come from (generated from bot
    self-play blunders? curated?), is puzzle rating per variant, does the
    hint cost rating, does a second-try success give points, and do
    offline attempts count for rating and missions?
31. **Season pass XP**: which actions give pass XP (same as player XP?
    missions only?), and can levels be bought with Yaqut (pay-to-skip would
    be a monetization choice, not in the design)?
32. **Screens without back buttons**: 4.2, 4.4, 6.5, 7.1 (and no tab bar on
    6.5) — pushed vs tab roots inferred here.
33. **Entry points not drawn**: sit-and-go, private tournament create/join,
    leaderboard (6.5), puzzles, trophy list ("Hamısı").
