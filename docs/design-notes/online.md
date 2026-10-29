# Online screens: implementation spec (Phase 3, accounts & online)

Source: `.claude/skills/nardarena-design`: `Ekranlar 2` (2.1, 2.2, 2.4, 2.5, 2.6),
`Ekranlar 5` (8.1), `Ekranlar 6` (9.4, 10.3, 11.1), `Ekranlar 7` (15.x, 17.x),
`Ekranlar 8` (20.1, 20.2), `GameScreen.dc.html`, `PlayerCard.dc.html`,
`components/game/{Clock,RankBadge,PlayerCard}.jsx`, `tokens/colors.css`.
Siblings: `screens.md` (menu chrome, shared components) and `game.md`
(GameScreen, PlayerCard, sheets). This file only adds what they lack.
Frame 390×844 portrait, logical px.

---

## 0. Conventions

Same as `screens.md` §0 and `game.md` §0: aliases `text`, `text@a`, `dim`,
`accent`, `accent@a`, `accentHi`, `line`, `surfaceRaised`, `dangerText`,
`success`/`successText`, `ivory100`, `walnut900`; `c.` = `context.nard`;
**overline** = `NardType.caption` w600 letterSpacing .72, stored uppercase in
ARB; "*(no token)*" = raw value. The 15.x/17.x/20.x mocks are already sebeke
(`#D4AE58` accent, `#1d1316` on-accent, `#2a1a20` sheets).

Extra tokens already in `apps/client/lib/ui/extra_tokens.dart` (use them):
`c.bgGradient`, `c.primaryGlow`, `c.primaryRing`, `c.onDanger` (#FBEFEF),
`c.onAccent` (#1d1316), `c.textFaint`, `c.lineSoft` (accent@.16),
`c.surfaceSunken` (black@.25), `c.scrim`, `c.tile` (text@.05), `c.tileRing`
(accent@.18), `c.selectedFill` (accent@.16), `c.errorTitle` (#F3B0BC),
`c.elevation2/3`, `c.buttonFont`, `c.latticeBand`.

New raw values in this file (*no token*, add to `extra_tokens.dart` if reused):

| Use | Value |
|---|---|
| Auth bg (9.4/17.1) | radial `80% 45% at 50% 30%`: `#4A321F` → `#2B1D14` 60% → `#120C08` (same family as Splash) |
| Searching bg (2.4) | radial `90% 50% at 50% 42%`: `#4A321F` 0 → `#2B1D14` 55% → `#1B120C` |
| VS bg (2.5) | linear 180°: `#3A1A1C` → `#2B1D14` 48% → `#1C2A2C` (garnet top = opponent, teal bottom = me) |
| VS bg vs BOT (20.1) | linear 180°: `#2A2A30` → `#2B1D14` 48% → `#1C2A2C` |
| Profile bg (8.1) | radial `90% 35% at 50% 14%`: `accent@.22` → `#1B120C` 70% |
| Brass avatar ring | conic from 210°: `#8A6A22, #E8C468, #A07C30, #E8C468, #8A6A22` (same as game.md §3.1) |
| Avatar fills (150°) | teal `#2F4A52→#162428` (me), garnet `#5B2A2A→#2A1414` (opponent), bot `#3A3A44→#1D1D22` |
| Rank tier fills (160°, `tokens/colors.css`) | bronze `#E0A77A→#8A5330` · silver `#EEF0F2→#8D939B` · gold `#F4DC8E→#B0852C` · platinum `#D6F1EE→#6AA9A5` · diamond `#BFE0FF→#4F7FD1` · master `#E2C6FF→#7D4FC4` · grandmaster conic from 200° `#9E1B32,#E8C468,#9E1B32,#E8C468,#9E1B32` |
| Code/value box | `black@.3` (one step darker than `c.surfaceSunken`) |
| Low-time vignette | inset glow 90 `dangerText@.38` + inset 2px ring `dangerText@.5` |
| Success card | fill `success@.16`, ring 1px `successText@.4` |
| Apple button | fill `ivory100`, label/glyph `NardPalette.charcoal900` (#16181D) |

### 0.1 New shared widgets (put in `apps/client/lib/ui/`)
- **Avatar**: sizes 44/46 (cards), 48 (home), 72 (profile), 110 (VS), 120
  (searching). Brass ring = padding 3 (≤48), 4 (≥72); inner circle with avatar
  fill + initials Noto Serif 600 at ≈0.37×size (18/28/40/42). Options: `glow`
  (active: `0 0 0 2 accent@.2`, `0 0 16 accent@.4`), `bot` (flat ring `text@.2`,
  bot fill, Lucide `bot` icon instead of initials).
- **RankBadge** (`components/game/RankBadge.jsx`): hexagon clip
  `polygon(50% 0,100% 25%,100% 75%,50% 100%,0 75%,0 25%)`, height = size×52/46,
  tier fill. < 24 px: solid hex only (inline 14×16 / 11×13 / 44×50).
  ≥ 24 px: inner hex 74%×75% `rgba(20,12,8,.55)` with sub-level Noto Serif
  600 at .3×size.
- **FlagSwatch**: w×h 18×12 / 20×13 / 16×11, radius 2, ring 1px `black@.3`;
  country code → flag (only az/tr/ru/en drawn in the design; see §12).
- **NardTextField**: h 54 (email) / 50 (delete confirm), radius 14
  (`c.cardRadius`), padding h 16/14, fill `c.surfaceSunken`, text 16
  (`NardType.body.copyWith(fontSize: 16)`), cursor 2px `text`. Focused ring
  1.5px `accent`; unfocused ring 1px `line` *(inferred)*; error ring 1.5px
  `dangerText` *(inferred)*. Label above: 12 w600 `text@.6`, padding-left 4,
  gap 6.
- **BotBadge**: in card h 20, padding h 7, radius 5, gap 4, Lucide `bot` 11
  stroke 3 + `BOT` 11 w700 letterSpacing .66; on VS h 24, padding h 10,
  radius 6, no icon, 12 w700 letterSpacing .96. Fill `ivory100`, text
  `c.onAccent`.

---

## 1. Sign-in

### 1.1 9.4 Login or guest = 17.1 Sign-in (identical mocks)
**Purpose:** first sign-in choice (onboarding step after 9.3) and the entry
when a guest links an account or a signed-out user opens an online feature.
ADR-020: Apple / Google / e-mail / guest; **no phone**. Apple/Google are built
but hidden while disabled by config (ADR-030).

Layout (bg auth radial §0; no lattice band, no tab bar):
1. Center block (flex, centered, padding h 24, gap 16, text centered):
   - Mark: 44×44 square rotated 45°, border 5 `accent`, inner square 11×11
     `accentHi` (splash mark at 0.69×).
   - Title `NardType.displayL.copyWith(fontSize: 30, height: 36/30)` *(no token)*.
   - Body `NardType.body` 15/22 `text@.7`.
2. Bottom zone padding `0 16 40` (`max(40, safeBottom+6)`), column gap 10:
   - **Apple** h 54, radius 16 (`NardRadius.l`), fill `ivory100`, label 16 w600
     `charcoal900`, gap 10, Apple logo 18 (mock placeholder square r5).
   - **Google** h 54, radius 16, ring 1px `text@.3`, label 16 w600 `text`,
     Google "G" 18 (mock placeholder conic `#EA4335/#FBBC05/#34A853/#4285F4`).
   - **E-mail** same as Google, Lucide `mail` 18 stroke 2.
   - **Guest** text button h 48, 15 w600 `accentHi` (= `NardButton` ghost with
     `accentHi` label).
   - Legal 11/16 `text@.5`, centered; "İstifadə şərtləri" and "Məxfilik
     siyasəti" should be tappable links (`accentHi`, *inferred*).
Use brand-mandated Apple/Google button assets; the three provider buttons are
not `NardButton` variants (radius 16, ivory fill) → small `AuthButton` widget.

Interactions: Apple/Google → native sign-in → Home (or back to the caller).
E-mail → 17.2. Guest → `AccountNotifier.signInAsGuest` → Home. Busy: spinner
in the tapped button, others disabled *(inferred)*. Failure → toast/inline
error (§1.4).

### 1.2 17.2 Enter e-mail
Bg `c.bgGradient` (+ lattice band). Header h 48, padding h 16: bare
`chevron-left` 20 (no box, no title; 44 hit area).
Body padding `20 16 0`, gap 12:
1. Title `NardType.displayL` (28/34).
2. Body 14/20 `text@.7`, padding-bottom 10.
3. Field: label `E-poçt` + NardTextField h 54 (mock shows focused, ring 1.5
   `accent`). Keyboard `emailAddress`, `autofillHints: [email]`, autofocus,
   action `send`.
CTA zone `0 16 40`: `NardButton` primary l "Kodu göndər" — disabled until the
address is syntactically valid *(inferred)*. → `requestCode` → 17.3.

### 1.3 17.3 Confirm code
Same header/bg. Body padding `20 16 0`, gap 12:
1. Title `NardType.displayL` "Kodu yaz".
2. Body 14/20 `text@.7`, padding-bottom 10, with the e-mail inline.
3. **Code cells**: row gap 8, 6 cells flex×60, radius 14, fill
   `c.surfaceSunken`; digit `NardType.title.copyWith(fontSize: 26)` w600 tnum
   *(no token)*, centered. Ring: active (next empty) 1.5px `accent`; others
   1px `line`. Implement as one hidden `TextField` (digits only, maxLength 6,
   `autofillHints: [oneTimeCode]`, paste fills all) painted as 6 cells.
4. Resend line: padding `10 4 0`, 14 `text@.6` tnum, "Kodu yenidən göndər ·
   0:42" while cooling down; at 0 → tappable, `accentHi` w600, no timer
   *(inferred)*. Cooldown not specified: suggest 60 s (API throttles
   `email/start` to 5 per 10 min).
CTA zone: primary l "Təsdiqlə". **Disabled look in this mock differs from
DS**: fill `danger@.35` (`rgba(158,27,50,.35)`), label `primaryText@.5`, ring
1px `accent@.3`, no glow (DS disabled = `surface` + faint text; see §12).
Enabled when 6 digits; auto-submit on the 6th digit *(inferred)*.
→ `verifyCode`; success → pop the auth flow to the caller / Home.

### 1.4 Error states (not designed; proposal)
Inline message under the field/cells, padding `8 4 0`, 13/18 `dangerText`;
field/cells ring 1.5px `dangerText`; cells shake 80 ms (same as hit shake).
API codes: `code_invalid` (422), `code_expired` (422, also after 5 attempts),
429 throttled, network → offline banner (§9).

### 1.5 Strings
| key suggestion | az text |
|---|---|
| authWelcomeTitle | Xoş gəldin |
| authWelcomeBody | Hesab yaratsan reytinqin, kosmetikan və klanın bütün cihazlarda saxlanacaq. |
| authApple | Apple ilə davam et |
| authGoogle | Google ilə davam et |
| authEmail | E-poçt ilə davam et |
| authGuest | Qonaq kimi oyna |
| authLegal | Davam etməklə {terms} və {privacy} ilə razılaşırsan. |
| authTerms | İstifadə şərtləri |
| authPrivacy | Məxfilik siyasəti |
| emailTitle | E-poçtunu yaz |
| emailBody | Şifrə lazım deyil. 6 rəqəmli giriş kodu göndərəcəyik. |
| emailLabel | E-poçt |
| emailSend | Kodu göndər |
| codeTitle | Kodu yaz |
| codeBody | {email} ünvanına göndərdik. Spam qovluğunu da yoxla. |
| codeResendIn | Kodu yenidən göndər · {time} |
| codeResend | Kodu yenidən göndər *(proposal: timer finished)* |
| actionConfirm | **existing key** (Təsdiqlə) |
| emailInvalid | E-poçt ünvanı düzgün deyil *(proposal)* |
| codeInvalid | Kod yanlışdır. Yenidən yoxla. *(proposal)* |
| codeExpired | Kodun vaxtı bitib. Yeni kod istə. *(proposal)* |
| authTooManyTries | Çox cəhd etdin. Bir az sonra yenidən yoxla. *(proposal)* |

Icons: `mail`, `chevron-left`, `bot` (n/a here). Widgets: `NardButton`
(primary, ghost), new `AuthButton`, new `NardTextField`, new `CodeField`.

---

## 2. Matchmaking

### 2.1 2.4 Searching opponent
**Purpose:** waiting in the queue (casual or ranked). No tab bar, no header.
Layout (bg searching radial §0, content centered):
1. Center column (flex, centered, gap 34):
   - **Radar**: outer circle 260, ring 1px `accent@.14`; middle circle 190,
     ring 1px `accent@.24` with a 2px `accent` top arc (the mock draws
     `border-top`; animate as a rotating arc, 1 turn ≈ 1.6 s *(inferred)*; static
     under reduce-motion); inner Avatar 120 (ring padding 4, initials Noto 42,
     glow `0 0 40 accent@.35`).
   - Text column gap 8: title Noto Serif 26 w600 (`NardType.displayL.copyWith
     (fontSize: 26)`) "Rəqib axtarılır…"; sub 14 `dim` tnum
     "Keçən vaxt 0:07 · təxminən 0:12".
   - Chips row gap 8 (read-only, not the selectable Chip): h 30, padding h 12,
     pill, ring 1px `line`, 12 `text`: variant · format · time control ·
     rating range. Range updates every 5 s (server band ±50 → ±400, +50/5 s);
     casual queue: omit the range chip *(inferred)*.
2. Bottom zone `0 16 40`, column gap 12, centered: tip 12 `text@.55`; cancel
   button h 56, radius 16, ring 1px `accent@.3`, 16 w600 `text` (=
   `NardButton` outline, radius `NardRadius.l`).
Interactions: Cancel / system back → `queue.leave` → previous screen. On
`match.found` → 2.5 (or 20.1 if the opponent `bot == true`).
**Bot fallback (ADR-024, casual only):** after 30 s the server sends a match
with a bot; there is no extra searching-screen copy — the notice lives on
20.1. Ranked never falls back. Suggested sub-line change at ≥ 20 s in casual:
none designed (§12).

### 2.2 2.5 VS (opponent found)
Bg VS gradient §0. Content padding `30 24 44`, column `spaceBetween`:
1. Opponent (column centered gap 10): Avatar 110 (opponent fill) · row gap 8:
   name Noto Serif 24 w600 *(no token)* + FlagSwatch 20×13 · meta 13 `text@.7`
   "{tier} {sub} · {rating} · Qələbə {n}%".
2. **VS divider** row gap 14: hairline flex×1 gradient `transparent → accent`;
   diamond 76×76 rotated 45°, fill `walnut900`, ring 1.5 `accent`, label "vs"
   Noto Serif italic 600 30 `accentHi` (counter-rotated); hairline `accent →
   transparent`.
3. Me (mirrored): meta · name + flag · Avatar 110 (my fill).
4. Footer column centered gap 6: overline 12 `dim` .06em
   "QISA NƏRD · 5 XAL · 3+12s · REYTİNQLİ"; countdown 15 w600 `accentHi`
   "Oyun 3 saniyəyə başlayır" (tnum).
Interactions: none (no cancel); auto-push GameScreen when the countdown ends
(3 s, *client-side; the server starts the match on its own clock* — align
with the first `game.state`). Entrance: avatars slide in from top/bottom,
diamond scales in, `NardMotion.standard` 320 ms *(inferred)*; off with reduce
motion.

### 2.3 20.1 Opponent found · BOT
Same frame as 2.5 with deltas:
- Bg VS-vs-BOT gradient §0.
- Opponent: Avatar 110 `bot` style (flat ring `text@.2`, bot fill, Lucide
  `bot` 44 stroke 1.6 `text`) + BotBadge (VS size) centered on the bottom edge
  (bottom −6). Name margin-top 6: Noto 24 "Kompüter · Orta". Meta 13 `text@.7`
  "Reytinqə təsir etmir". No flag.
- Me: meta "{tier} {sub} · {rating}" (no win %), name (mock has no flag —
  keep the flag for consistency, *inferred*), Avatar 110.
- **Footer replaced by a notice** (no overline, no countdown): padding `12 14`,
  radius 14, fill `c.surfaceSunken`, ring 1px `text@.18`, 13/19 `text@.8`,
  centered: the 30 s fallback text. Auto-start after the same 3 s *(inferred)*.

### 2.4 20.2 Game vs BOT — deltas vs GameScreen (`game.md` §1/§3)
The 20.2 mock uses the simplified card from `game.md` §10; GameScreen stays
canonical. Only these differ:
- Top bar overline: "Təsadüfi · reytinqsiz"; score "0 – 0". Fair-dice button
  (brass `shield-check`) is shown — bot games use fair dice too.
- Opponent PlayerCard: Avatar `bot` style; name "Kompüter · Orta" + BotBadge
  (card size) after the name (gap 8, before the flag slot; no flag); meta
  line "Reytinqə təsir etmir · Pip 158" — no rank hexagon, no rating
  (mock writes lowercase "pip"; use `playerPip`). Clock slot shows "—" in
  idle style.
- Banner sub: "6 – 2 · 2 gediş" (dice + moves this turn) instead of
  `bannerLegalMoveCount`.
- My card meta keeps tier + rating ("Platin II · Pip 146").
- No emote/chat towards the bot (*inferred*); Oflayn/reconnect never shown for
  the bot seat.

### 2.5 Strings
| key suggestion | az text |
|---|---|
| searchTitle | Rəqib axtarılır… |
| searchElapsed | Keçən vaxt {elapsed} |
| searchEstimate | təxminən {estimate} *(joined with " · "; omit until the server sends an estimate)* |
| searchTip | Məsləhət: {tip} |
| searchTipHeadRule | Uzun nərddə başdan yalnız bir daş götürülür. |
| timeControlShort | {minutes}+{delay}s |
| ratingRange | {min}–{max} |
| variantShort / formatPoints / formatOneGame | **existing keys** (Qısa nərd / {n} xal / 1 oyun) |
| cancel | **existing key** (Ləğv et) |
| vsMeta | {rank} · {rating} · Qələbə {percent}% |
| vsMetaNoStats | {rank} · {rating} |
| vsLabel | vs *(constant)* |
| pointsUpper | {n} XAL (`matchToPointsUpper` "{n} XALA QƏDƏR" is a different string) |
| rankedUpper | REYTİNQLİ |
| unrankedUpper | REYTİNQSİZ *(proposal, casual)* |
| vsStartsIn | Oyun {seconds} saniyəyə başlayır |
| botBadge | BOT |
| playerBotLevel | **existing key** (Kompüter · {level}) + `aiLevelMedium` |
| botNoRating | Reytinqə təsir etmir |
| botFallbackNotice | 30 saniyədə canlı rəqib tapılmadı. Bot ilə oynayırsan, axtarış arxa fonda davam edir. |
| gameModeCasual | Təsadüfi · reytinqsiz |
| playerBotMeta | {noRating} · {pip} (compose `botNoRating` + `playerPip`) |
| bannerDiceMoves | {a} – {b} · {count} gediş |
| clockNone | — |

Icons: `bot`, `x` (n/a). Widgets: `NardButton` (outline), Avatar, FlagSwatch,
RankBadge, BotBadge, existing `PlayerCard`/`StatusBanner`.

---

## 3. GameScreen online states (adds to `game.md`)

`game.md` already has: clock block layout and idle/active/low colors
(§3.1, §3.2), banner strings `bannerLowTime`, `bannerTimeLeft`,
`bannerPaused`, `bannerDisconnected`, `reconnectTitle`, `reconnectBody`,
`playerOffline`, `cubeAnswerTime`, `menuFairDice(Verify)` — **none of them is
in `app_az.arb` yet**; add them under those names.

### 3.1 Clock behaviour (PlayerCard)
- Data: `ClockState { whiteMs, blackMs, delayMs, running, sentAt }`; clock =
  reserve (default `ClockConfig.standard` 3 min + 12 s delay). Interpolate
  locally from `sentAt`; delay counts down first, then reserve.
- Text `m:ss` (`NardType.clock`, tnum). Delay bar fill = remaining delay /
  `clock.delayMs` (full while idle; mock `delay: [1,1]`).
- State: `running == my side` → active; else idle; remaining reserve < 10 s
  **and** running → low (also for the opponent's clock). Landscape `side`
  layout adds "+12s" (Plex 11/13 .75 tnum) = configured delay.
- Clock bg/text/track per `game.md` §3.1 table; low glow `0 0 0 3
  dangerText@.3, 0 0 20 dangerText@.45`. Low uses `c.danger` fill and
  `c.onDanger` text.
- Bot seat: "—" in idle style (see 2.4); pass & play / vs computer: hidden
  (Phase 2 rule unchanged).

### 3.2 Low time (my clock < 10 s on my turn)
- Banner: `Vaxt azalır` / `0:09 qaldı`, tone `danger` (`StatusBanner`
  `BannerTone.danger`).
- **Vignette**: full-screen `IgnorePointer` layer above everything except
  sheets: inset glow 90 `dangerText@.38` + 2px inner ring `dangerText@.5`
  following the screen corners (Flutter has no inset shadow → paint 4 edge
  gradients or a `RadialGradient` frame in a `CustomPainter`). Fade in
  `NardMotion.fast`; pulse not specified (keep static; none under reduce
  motion).
- Haptic tick every whole second below 10 s (`HapticFeedback.selectionClick`)
  if Settings › Vibrasiya is on.
- Primary/undo unchanged (mock: `Təsdiqlə · 0 / 2`, wait).

### 3.3 Opponent reconnecting (`opponentConnected == false`)
- Opponent PlayerCard: avatar + text column opacity .45 + grayscale
  (`ColorFiltered` saturation 0); **Oflayn pill** inserted between text and
  clock (row layout only): padding `4 8`, pill, fill `dangerText@.14`, text 11/14
  w600 `dangerText`. Clock keeps its normal style (server keeps it running;
  it is not paused). Landscape `side` card: no pill in the design (dimming
  only).
- Card centered on the board (portrait and landscape): width 270, padding
  `14 18`, radius `c.cardRadius`, fill `c.surfaceRaised`, `c.elevation2` +
  1px `line` ring; row gap 14, center:
  - Spinner 26 circle, 2.5px stroke `line` with a quarter arc `accent`,
    rotating *(inferred)*.
  - Column gap 4: title 15/19 w600 `text` "{name} yenidən qoşulur…"; sub
    12/16 `dim` tnum "0:42 qaldı · vaxt bitsə, qələbə sənindir" (landscape:
    only "0:42 qaldı"). Countdown from `reconnectDeadline` (server grace 60 s).
- Banner `Oyun dayandırılıb` / `Bağlantı kəsildi` (dim); primary `Zər at` off
  (mock is on the opponent's turn). On my turn I can keep playing
  *(inferred, see §12)*.
- Grace ends → match ends `abandoned` → 2.6 result as a win.

### 3.4 My own connection lost (not designed; proposal)
Same centered card with title "Bağlantı bərpa olunur…" and no sub; banner
`Bağlantı kəsildi` (danger); all controls off until the socket resumes and a
fresh `game.state` arrives (ADR-031 replays the record).

### 3.5 Strings (all new to the ARB)
| key suggestion | az text |
|---|---|
| bannerLowTime | Vaxt azalır *(game.md key)* |
| bannerTimeLeft | {time} qaldı *(game.md key)* |
| bannerPaused | Oyun dayandırılıb *(game.md key)* |
| bannerDisconnected | Bağlantı kəsildi *(game.md key)* |
| playerOffline | Oflayn *(game.md key)* |
| reconnectTitle | {name} yenidən qoşulur… *(game.md key)* |
| reconnectBody | {time} qaldı · vaxt bitsə, qələbə sənindir *(game.md key)* |
| selfReconnectTitle | Bağlantı bərpa olunur… *(proposal)* |
| clockDelay | +{seconds}s |
| playerMeta | {rating} {rank} · Pip {pip} *(game.md §3.1 order; `playerPip` exists)* |
| menuFairDice / menuFairDiceVerify | Ədalətli zər / Yoxla *(game.md keys)* |
| cubeAnswerTime | Cavab vaxtı *(game.md key; cube sheet timer now applies online)* |

Icons: `shield-check` (top bar, now active → 10.3). Widgets: existing
`PlayerCard` (add clock, offline, bot), `StatusBanner`, `NoMovesCard` frame
for the reconnect card.

---

## 4. 10.3 Fair dice verification

**Purpose:** show the commit–reveal data and recompute a roll (`docs/FAIRNESS.md`
FD-01…05, `FairDice` in `nard_core`). Entry: GameScreen top-bar shield,
game menu "Ədalətli zər · Yoxla", online replay. Pushed screen, no tab bar.
Bg: theme background (mock flat `#1B120C`).

Layout:
1. Header h 48, padding h 16, gap 12: bare `chevron-left` 20 + title Noto
   Serif 20 w600 *(no token)*.
2. Body padding `6 16 0`, gap 16:
   - Intro 14/21 `text@.75`.
   - Steps list, gap 10. Row gap 12: number disc 26, fill `accent@.16`, 12
     w700 `accentHi` · column gap 5: label 13 w600 `text`; value box
     `NardType.mono.copyWith(fontSize: 11, height: 1.5)`, `text@.7`, padding
     `8 10`, radius 8 (`NardRadius.s`), fill `black@.3`, wraps anywhere
     (break-all). Make values selectable.
     1. commitment (`sha256: …`) 2. server seed (after the game; before: proposal
     "oyundan sonra açılacaq" in `text@.45`) 3. my client seed 4. roll number
     `#47 · HMAC → 6, 3`.
   - Result card: padding 14, radius 14, success card colors §0; row gap 12:
     disc 32 `c.success` with check (Lucide `check` 16 stroke 3, `text`) ·
     column gap 2: title 14 w600 `successText`; sub 12 `text@.65`.
3. Footer padding `16 16 40`, row gap 10, each flex × 52, radius 14:
   - "Kodu kopyala": outline, ring 1px `accent@.3`, 14 w600 `text` → copies
     all four values (+ opponent seed) as text; snackbar "Kopyalandı"
     *(proposal)*.
   - "Başqa atışı yoxla": **solid accent** fill `accent`, label `c.onAccent`
     (mock `#231709`), 14 w600 — no such `NardButton` variant (add `accent`
     variant or use secondary). Opens a roll picker (not designed: suggest a
     `showNardSheet` list "#N · a – b", tap = verify).
- States not designed: mismatch (same card with `danger@.16` / `dangerText@.4`
  / `c.danger` disc + Lucide `x`), game in progress (server seed hidden →
  result card replaced by a dim note). Proposal strings below.

| key suggestion | az text |
|---|---|
| fairTitle | Ədalətli zər |
| fairIntro | Hər zər atışı oyundan əvvəl kilidlənən server açarından, sənin açarından və atışın sırasından hesablanır. Oyundan sonra hər atışı özün yoxlaya bilərsən. |
| fairCommitment | Server açarının heşi (oyundan əvvəl) |
| fairCommitmentValue | sha256: {hash} |
| fairServerSeed | Server açarı (oyundan sonra açılır) |
| fairYourSeed | Sənin açarın |
| fairRollNumber | Atış nömrəsi |
| fairRollValue | #{n} · HMAC → {a}, {b} |
| fairMatch | Uyğundur · {a} – {b} |
| fairMatchSub | Atış #{n} hesablanmış nəticə ilə eynidir |
| fairCopy | Kodu kopyala |
| fairCheckAnother | Başqa atışı yoxla |
| fairOpponentSeed | Rəqibin açarı *(proposal; FD-02 uses both seeds)* |
| fairPending | Oyundan sonra açılacaq *(proposal)* |
| fairMismatch | Uyğun deyil · {a} – {b} *(proposal)* |
| fairMismatchSub | Atış #{n} hesablanmış nəticədən fərqlidir *(proposal)* |
| copied | Kopyalandı *(proposal)* |

Icons: `chevron-left`, `check`, `x`. Widgets: `NardButton` (outline +
new accent variant), `showNardSheet`.

---

## 5. 8.1 Profile + statistics

**Purpose:** own profile, Profil tab root from Phase 3 (Phase 2 used Settings
as the root, `screens.md` §3). Bg profile radial §0 (+ lattice band optional).
Data: `GET /me` → name, avatar, country, `ratings[variant] {rating, peak,
matches, wins, tier}`; `GET /me/matches` → history.

Layout:
1. Header row, padding `8 16 16`, gap 14, center:
   - Avatar 72 (ring padding 4, initials Noto 28).
   - Column flex gap 4: row gap 8: name Noto Serif 22 w600 *(no token,
     `NardType.title.copyWith(fontSize: 22)`)*, ellipsis + FlagSwatch 18×12 ·
     ~~title "Zər ustası" (Noto italic 13 `accentHi`)~~ **Phase 4** ·
     meta 12 `dim`: "{tier} {sub} · {rating}" for the selected variant
     (mock "Platin I · 1866 · Qızıl Zər"; ~~clan name~~ **Phase 5**).
   - Edit button 40×40, radius 12, ring 1px `line`, Lucide `pencil` 18 →
     edit sheet (name; country *(inferred)*; avatar later).
2. Variant segmented, margin h 16: **compact variant** — container padding 3,
   radius 12, fill `c.surfaceSunken`, no ring; segments h 34, radius 9, 13px;
   selected `ivory100` / `walnut900` w600; unselected `text@.7` w400. Extend
   `NardSegmented` with a `compact` size. Switches all stats below.
3. Stats grid: 2 columns, gap 8, padding `12 16`. Tile padding `12 14`, radius
   14, fill `c.tile`, ring 1px `accent@.16` (`c.lineSoft`); value Plex 22 w600
   tnum *(no token)*; label 12 `text@.6`, gap 2.
   Phase 3 tiles (backed data only): **Reytinq** (value + small RankBadge 14
   inline, *inferred*), **Qələbə faizi** (wins/matches, "—" if 0 matches),
   **Matçlar**, **Qələbələr**. Mock tiles `Mars`, `Ən uzun seriya`,
   `Orta səhv dərəcəsi` → later (no data; error rate = Phase 6 analysis).
4. ~~Trophy showcase "KUBOK VİTRİNİ" + "Hamısı", 4 tiles 76 high~~ **Phase 6**.
5. Overline "MATÇ TARİXÇƏSİ", padding `10 16 4`, `dim`.
6. History list (scrolls with the page). Row h 54, padding h 16, gap 12,
   bottom border 1px `accent@.08`:
   - result bar 4×30 radius 2: win `successText`, loss `dangerText`, unrated /
     bot / tournament `accent`;
   - column flex gap 2: opponent name 14 w600 (bot → `computerName`); meta 12
     `text@.6` "Qısa · 5 xal · bu gün";
   - score 14 w600 tnum "5–2" (mock: en dash **without** spaces here);
   - rating delta 12, width 34, right-aligned, tnum, result color: "+24",
     "−18", "—" (casual/bot);
   - Lucide `play` 18 `accent` (filled-stroke triangle) → replay viewer
     (`screens.md` 10.1) with `GET /me/matches/{id}`.
   Pagination: load more on scroll *(inferred)*. Empty / error / offline:
   `MessageState` (§9).
7. TabBar active `profile`.
Settings entry is missing from the mock (see §12): suggest a `settings`
icon button next to the edit button.

| key suggestion | az text |
|---|---|
| tierBronze / tierSilver / tierGold / tierPlatinum / tierDiamond / tierMaster / tierGrandmaster | Bürünc / Gümüş / Qızıl / Platin / Almaz / Master / Qrossmeyster (`RankBadge.jsx`) |
| rankWithSub | {tier} {sub} (sub = I / II / III) |
| profileMeta | {rank} · {rating} |
| variantShort / variantLong | **existing keys** (segmented labels) |
| statWinRate | Qələbə faizi |
| statRating | Reytinq *(proposal)* |
| statMatches | Matçlar *(proposal)* |
| statWins | Qələbələr *(proposal)* |
| statPercent | {n}% |
| profileHistory | MATÇ TARİXÇƏSİ |
| historyMeta | {variant} · {format} · {date} |
| variantShortAbbr / variantLongAbbr | Qısa / Uzun |
| formatPoints / formatOneGame | **existing keys** ({n} xal / 1 oyun) |
| dateToday / dateYesterday | bu gün / dünən (older: locale date via `intl`) |
| historyScore | {me}–{opp} |
| ratingDeltaUp / ratingDeltaDown | +{n} / −{n} (U+2212 minus) |
| computerName | **existing key** (Kompüter) |
| profileEdit | Profili redaktə et *(proposal, a11y + sheet title)* |
| historyEmptyTitle | Hələ onlayn matç yoxdur *(proposal)* |
| historyEmptyBody | Onlayn oynadığın matçlar burada görünəcək. *(proposal)* |
| *(later)* profileTitleLabel, statMars, statLongestStreak, statErrorRate, trophyShowcase, seeAll | Zər ustası · Mars · Ən uzun seriya · Orta səhv dərəcəsi · KUBOK VİTRİNİ · Hamısı |

Widgets: Avatar, FlagSwatch, RankBadge, `NardSegmented` (compact),
`NardIconButton`, `NardTabBar`, `MessageState`, `Overline`.

---

## 6. Account & privacy

### 6.1 15.1 Account & privacy
Pushed from Settings › "Hesab və məxfilik" (row already listed as later in
`screens.md` 10.2). Bg theme background (mock flat `#1B120C`). Header h 48:
bare `chevron-left` 20 + title Noto 20 w600 (same as 10.3).
Body padding `4 16 0`, groups gap 14; each group = overline (`text@.55`,
padding-left 4) + 6 + group card (`screens.md` 2.8/2.9 settings rows, compact
switch 44×26: on track `accent`, thumb `c.onAccent`).

| Group | Row | Trailing (mock) | Phase |
|---|---|---|---|
| HESAB | E-poçt | `elvin@mail.az` › | 3 (guest: opens 17.2 to link; value proposal "Əlavə et") |
| | Bağlı hesablar | `Apple, Google` › | 3 when Apple/Google enabled; hide otherwise |
| | Oyunçu adı | `Elvin` › | 3 → rename sheet |
| MƏXFİLİK | Profil hamıya açıqdır | switch on | **5, omit** |
| | Onlayn statusu göstər | switch on | **5, omit** |
| | Oyun tarixçəsini göstər | switch off | **5, omit** |
| | Dostluq təklifləri | `Hamı` › | **5, omit** |
| | Bloklananlar | `2` › | **5, omit** |
| MƏLUMAT | Məlumatlarımı ixrac et | › | 3 → 15.2 |
| | Hesabı sil | › , label `dangerText` | 3 → 15.3 |

Value 14 `text@.6` + `chevron-right` 14 stroke 2.5 `text@.5`. Sign-out is not
designed (§12): proposal row "Hesabdan çıx" at the end of HESAB.

### 6.2 15.2 Export my data (sheet over 15.1)
Scrim `c.scrim`. Mock sheet: full width, bottom 0, radius 24 top only,
padding `10 20 36`, fill `c.surfaceRaised`, top hairline `inset 0 1 0
accent@.4`, handle 40×5 r3 `text@.25` — differs from `showNardSheet` (inset 8,
24/42, ring); **use `showNardSheet`** for consistency (§12). Column gap 14:
1. Title Noto 22/28 w600, margin-top 6 (`SheetTitle`).
2. Body 14/20 `text@.7` (with the e-mail).
3. Group card (`c.tile`-like: `text@.04`, ring 1px `accent@.14`, radius 16),
   rows min-h 48, padding h 14, gap 12, bottom border 1px `accent@.08`:
   check box 22, radius 6, fill `accent`, Lucide `check` 14 stroke 3.5
   `c.onAccent` · label 15 · trailing 12 `text@.55`.
   Rows: "Profil və hesab" · "Oyun tarixçəsi" ("1 248 oyun", count from
   `matches`) · ~~"Alışlar və balans" ("14 əməliyyat")~~ Phase 4 ·
   ~~"Söhbətlər"~~ Phase 5. Boxes are display-only (all included).
4. Row space-between, padding h 4, 13 `text@.6`: "Format" · value mono
   (`NardType.mono` 13) "ZIP · JSON + CSV".
5. Buttons column gap 10, margin-top 4: primary l "İxracı başlat"; ghost h 48,
   15 w600 `text@.7` "Ləğv et".
The API (`GET /me/export`) returns JSON immediately; mock copy promises an
e-mailed ZIP within 24 h (§12).

### 6.3 15.3 Delete account (sheet)
Same sheet frame; mock top hairline `dangerText@.5`. Column gap 14:
1. Icon disc 52, fill `dangerText@.14`, ring 1px `dangerText@.5`, Lucide
   `triangle-alert` 24 stroke 2.2 `dangerText`; margin-top 6.
2. Title Noto 22/28 w600 "Hesab silinsin?".
3. Bullets column gap 9; row gap 12: diamond 6×6 rotated 45° `dangerText`
   (margin-top 7) + text 14/20 `text@.8`. Phase 3 keeps only the rating/history
   bullet (wallet → Phase 4, friends/clan → Phase 5).
4. Note 13/19 `text@.6` (30-day grace — not implemented, §12).
5. Confirm field: label 12 `text@.6` "Təsdiq üçün SİL yaz"; NardTextField
   h 50, ring 1.5px `dangerText`, text 16 w600 letterSpacing 1.6 (.1em),
   `textCapitalization.characters`. Compare with the localized word.
6. Buttons gap 10, margin-top 4: **danger** h 56 pill "Hesabı sil" — mock fill
   `c.danger`, label `primaryText` (#F8F1E4; `NardButton` danger uses
   `c.onDanger`, fine) — enabled only when the field matches *(inferred)*;
   ghost h 48 "Ləğv et".
→ `DELETE /me` → clear credentials → 9.4.

### 6.4 Strings
| key suggestion | az text |
|---|---|
| settingsAccountPrivacy | Hesab və məxfilik *(screens.md later key; row + screen title)* |
| accountGroupAccount | HESAB |
| accountEmail | E-poçt |
| accountLinked | Bağlı hesablar |
| accountNickname | Oyunçu adı |
| accountEmailAdd | Əlavə et *(proposal, guest)* |
| accountSignOut | Hesabdan çıx *(proposal)* |
| accountGroupData | MƏLUMAT |
| accountExport | Məlumatlarımı ixrac et |
| accountDelete | Hesabı sil |
| *(Phase 5)* accountGroupPrivacy, privacyPublicProfile, privacyOnlineStatus, privacyShowHistory, privacyFriendRequests, privacyEveryone, privacyBlocked | MƏXFİLİK · Profil hamıya açıqdır · Onlayn statusu göstər · Oyun tarixçəsini göstər · Dostluq təklifləri · Hamı · Bloklananlar |
| exportTitle | Məlumatlarını ixrac et |
| exportBody | Arxiv hazır olanda {email} ünvanına yükləmə linki göndərəcəyik. Adətən 24 saata qədər çəkir. |
| exportProfile | Profil və hesab |
| exportGames | Oyun tarixçəsi |
| exportGamesCount | {n} oyun |
| exportFormat | Format |
| exportFormatValue | ZIP · JSON + CSV |
| exportStart | İxracı başlat |
| *(Phase 4/5)* exportPurchases, exportPurchasesCount, exportChats | Alışlar və balans · {n} əməliyyat · Söhbətlər |
| deleteTitle | Hesab silinsin? |
| deleteItemRating | Reytinq ({rating}), dərəcə və bütün oyun tarixçəsi |
| *(Phase 4/5)* deleteItemWallet, deleteItemSocial | {coins} sikkə, {gems} yaqut və alınmış kosmetikalar · Dostlar siyahısı və klan üzvlüyü |
| deleteGrace | 30 gün ərzində yenidən daxil olsan silinmə ləğv edilir. |
| deleteConfirmLabel | Təsdiq üçün {word} yaz |
| deleteConfirmWord | SİL |
| deleteConfirm | Hesabı sil |
| cancel | **existing key** (Ləğv et) |

Icons: `chevron-left`, `chevron-right`, `check`, `triangle-alert`. Widgets:
`ScreenHeader` (needs a bare variant, §12), settings rows + `NardSwitch`
(compact), `showNardSheet`, `SheetTitle`, `NardButton` (primary, danger,
ghost), NardTextField.

---

## 7. Online parts of 2.1 Home, 2.2 Setup, 2.6 Match result

### 7.1 2.1 Home
Offline layout per `screens.md` 2.1 stays; Phase 3 adds:
1. **Profile row** (top, before the hero), row gap 12: Avatar 48 (ring
   padding 3, initials 18) · column flex gap 5: row gap 8: name 16 w600 ·
   RankBadge 14×16 · "{tier} {sub} · {rating}" 12 `dim` (rating of the hero's
   variant). ~~Second row "Səv. 24" + XP bar (4 high, `accent`, track
   `text@.12`)~~ **Phase 4**. ~~Currency pills + bell~~ Phase 4/7. Tap → Profil
   tab *(inferred)*. Signed-out: hidden (or a "sign in" prompt — not designed).
2. **Hero overline** online: "QISA NƏRD · REYTİNQLİ · 3+12s"
   (`{VARIANT} · {MODE} · {TIME}`); second line "Onlayn: 4 218 oyunçu" needs
   a server count (not available → keep Phase 2 line). **Oyna** → 2.4 with the
   last online settings; offline → Phase 2 behaviour (§12).
3. **Mode grid**: design tiles Adi (`dice-3`) · Kompüter (`monitor`) · Bir
   cihazda (`smartphone`) · Şəxsi otaq (`lock`, Phase 5). "Adi" = online
   casual → 2.2 in casual mode (Reytinqli off). Current build has 4 tiles
   (Kompüter, Bir cihazda, Dərs, Oyunlarım) → placement decision in §12.
   Offline: Adi tile opacity .55 + not tappable *(inferred)*.

### 7.2 2.2 Setup — online additions (`screens.md` 2.2 omitted these)
- "VAXT NƏZARƏTİ" 2×2 time tiles (`screens.md` 2.4 time tile): Blits
  `1 dəq + 8s`, Sürətli `3 dəq + 12s` (default), Klassik `5 dəq + 15s`,
  Gündəlik `24 saat / gediş` — server supports only 3+12 now (§12).
- Toggle row "Reytinqli" + sub "±1842 · 150 xal aralıq", default Switch.
- CTA "Rəqib axtar" → 2.4. Vs-computer flow keeps "Davam et".

### 7.3 2.6 Match result — rating card (ranked only)
Between header and the (Phase 4) rewards. Radius 18 *(no token)*, padding 16,
fill `c.surfaceRaised` (mock walnut800), ring 1px `line`; column gap 12:
1. Row space-between: overline "REYTİNQ" (`dim`) · delta 14 w600 tnum,
   `successText` "+24" (loss `dangerText` "−18", *inferred*).
2. Row gap 14: RankBadge 44×50 (solid, no sub label) · column flex gap 6:
   - baseline row gap 8, tnum: new rating Plex 30 w600 *(no token)* "1866" +
     "1842-dən" 13 `text@.55`;
   - progress 6 high, radius 3, track `text@.1`: segment 1 (0 → old position)
     tier dark stop, segment 2 (old → new) tier light stop (platinum
     `#6AA9A5` / `#D6F1EE`); loss: shrink, no second segment *(inferred)*.
     Position = progress inside the tier (bands of 200 from `Rating::TIERS`);
   - caption 12 `dim` "Platin I-ə 34 xal qaldı".
Motion: number counts old → new over `NardMotion.counter` / `outExpo`, bar
fills with it; off under reduce motion. Casual/bot match: no card (or a dim
`botNoRating` line, *inferred*). Bottom buttons online: "Revanş" (needs a
rematch protocol; else re-queue), "Təhlil" Phase 6, "Replayı paylaş" later
(`actionViewReplay` existing).

### 7.4 Strings
| key suggestion | az text |
|---|---|
| homeRankMeta | {rank} · {rating} (= `profileMeta`) |
| homeHeroMetaOnline | {variant} · {mode} · {time} *(pieces uppercase: `variantShortUpper` existing, `rankedUpper`, `unrankedUpper`)* |
| modeCasual | Adi |
| *(later)* homeOnlinePlayers, homeLevel | Onlayn: {count} oyunçu · Səv. {n} |
| setupTimeLabel | VAXT NƏZARƏTİ |
| timeBlitz / timeRapid / timeClassic / timeDaily | Blits / Sürətli / Klassik / Gündəlik |
| timeValue | {minutes} dəq + {delay}s |
| timeDailyValue | 24 saat / gediş |
| setupRated | Reytinqli |
| setupRatedSub | ±{rating} · {band} xal aralıq |
| setupFindOpponent | Rəqib axtar |
| matchRatingLabel | REYTİNQ |
| matchRatingFrom | {old}-dən *(suffix harmony, §12)* |
| matchRatingToNext | {rank}-ə {points} xal qaldı *(suffix harmony)* |
| matchWonTitle / matchMeta / matchRematch / actionViewReplay | **existing keys** |

---

## 8. Navigation (Phase 3 additions)
```
Splash ▶ 9.2 ▶ 9.3 ▶ 9.4 Login/guest ─Apple/Google/Guest▶ Home
                          └─E-poçt▶ 17.2 ─Kodu göndər▶ 17.3 ─Təsdiqlə▶ Home
Home: Oyna (online) ▶ 2.4 ─match.found▶ 2.5 VS ─3 s▶ GameScreen ▶ 2.6
      Adi ▶ 2.2 (casual) ─Rəqib axtar▶ 2.4 ─30 s, bot▶ 20.1 ─3 s▶ GameScreen (20.2)
      profile row ▶ Profil tab
GameScreen: shield / menu "Ədalətli zər" ▶ 10.3
Profil tab ▶ 8.1 ─history row▶ 10.1 replay (▶ 10.3) ; ─edit▶ rename sheet
Settings ▶ Hesab və məxfilik 15.1 ─E-poçt (guest)▶ 17.2 ; ─ixrac▶ 15.2 ; ─sil▶ 15.3 ▶ 9.4
Any online action while signed out ▶ 17.1 (= 9.4) then back to the caller
```

## 9. 11.1 Offline banner and online-unavailable states
- **Banner** (`screens.md` §4 11.x spec): margin `0 16 8`, h 40, radius 12,
  fill `dangerText@.14`, ring 1px `dangerText@.4`, padding h 14, gap 10: dot 8
  `dangerText` + text 13 `c.errorTitle`. Directly under the safe area, above
  the root title / profile row. Shown on tab roots (Home, Profil) and online
  screens (2.2 online mode, 2.4) while the device is offline or the API/socket
  is unreachable; slides away when connectivity returns *(inferred)*. Not on
  GameScreen (§3.3/§3.4 cover it) or offline games.
- While shown: hero Oyna and Adi tile fall back / disable (§7.1); 2.4 returns
  to Home with the banner; 8.1 shows cached profile, else `MessageState`
  (danger) with `playVsComputer` / `retry`.
- New widget: `OfflineBanner` in `ui/layout.dart` (none exists yet).

| key suggestion | az text |
|---|---|
| offlineBanner | İnternet yoxdur · oflayn rejim |
| onlineOfflineTitle | Onlayn oyun əlçatan deyil *(proposal; design copy is tournament-specific: "Turnirlər oflayn görünmür")* |
| onlineOfflineBody | Kompüterə qarşı və bir cihazda oyun işləyir. Bağlantı qayıdanda yenidən cəhd et. *(proposal, adapted from 11.1)* |
| playVsComputer / retry / errorTitle / errorBody | **existing keys** |

---

## 10. Later phase — omit in Phase 3
Profile title, level/XP, clan line, trophy showcase, Mars/streak/error-rate
stats (4/5/6); privacy toggles, friend requests, blocked list (5); export of
purchases/chats, delete bullets for wallet/social (4/5); currency pills, bell
(4/7); rewards + missions on 2.6 (4); Təhlil (6); Şəxsi otaq tile (5); emote
button (5); online player count; non-standard time controls (until the server
supports them).

## 11. Widget reuse summary
| Need | Reuse | New / extend |
|---|---|---|
| CTAs | `NardButton` primary/outline/ghost/danger | `accent` (solid brass) variant for 10.3 |
| Headers | `ScreenHeader`, `RootTitle` | bare variant (h 48, chevron 20, title 20) |
| Toggles/rows | `NardSwitch(compact)`, settings rows | — |
| Segmented | `NardSegmented` | compact size (8.1) |
| Sheets | `showNardSheet`, `SheetTitle` | — |
| States | `MessageState`, `StatusBanner`, `Overline`, `NardTabBar` | `OfflineBanner` |
| Player | `PlayerCard` (game_parts.dart) | clock, offline pill/dim, bot badge, tier |
| New | — | Avatar, RankBadge, FlagSwatch, BotBadge, NardTextField, CodeField, AuthButton, SearchRadar, VsDivider |

## 12. Ambiguities / open questions
1. **Background search after bot fallback**: 20.1 says "axtarış arxa fonda
   davam edir" (ADR-024), but `Matchmaker` removes the player from the queue
   when the bot is assigned. Either implement it (and design the "live opponent
   found" interrupt) or change the copy.
2. **Search estimate** "təxminən 0:12" and home "Onlayn: 4 218 oyunçu" have no
   server data. Omit until added.
3. **VS meta "Qələbə 58%"** and tier sub-levels (I/II/III): `PlayerInfo` has only
   name/rating/country/bot; the API returns `tier` but no sub-level. Define
   sub-levels (e.g. thirds of each 200-pt band; bronze 0–1299 and grandmaster
   ≥ 2300 are irregular) or drop them.
4. **Reconnect banner "Oyun dayandırılıb"** says paused, but the server keeps
   the absent player's clock running; and whether the present player may move
   during the grace is not designed. Mock grace 0:42 vs server 60 s (fine).
5. **15.2 export**: copy promises an e-mailed ZIP (JSON + CSV) within 24 h; the
   API returns JSON synchronously. Guests have no e-mail. Pick: share/save the
   JSON file now (rewrite copy) or build an async e-mail job.
6. **15.3 delete**: "30 gün … ləğv edilir" grace is not implemented (`DELETE
   /me` deletes at once). Also the confirm word must be localized and compared
   locale-aware (az "SİL" contains İ).
7. **Sign-out** and guest → account linking entry are not designed (15.1 has no
   sign-out row; 17.1 entry point from Settings is implied only).
8. **Settings entry** after 8.1 becomes the Profil tab root: not in the 8.1 mock.
9. **Home grid**: design has Adi/Kompüter/Bir cihazda/Şəxsi otaq; the build has
   Kompüter/Bir cihazda/Dərs/Oyunlarım. Where do Adi and ranked go, and does
   Oyunlarım move to 8.1 history? Is the hero Oyna online or offline by default?
10. **Casual naming**: Home tile "Adi" vs 20.2 mode "Təsadüfi · reytinqsiz".
11. **Time controls**: 2.2 shows 4 controls; server has only `ClockConfig.standard`
    (3+12). "Gündəlik" (correspondence) is a different product. Also "±1842 · 150
    xal aralıq" contradicts the widening ±50 → ±400 band.
12. **Auth copy** mentions cosmetics and clans (Phase 4/5) — keep as promise or
    trim. Apple button on Android, and Apple required on iOS when Google is
    offered (App Store 4.8) — confirm platform rules.
13. **Disabled primary** in 17.3 (garnet@.35 + faint ivory) ≠ DS disabled
    (`surface` + `textFaint`). Pick one.
14. **Sheet frame** for 15.2/15.3 (full width, radius 24 top, top hairline,
    5px handle) ≠ `showNardSheet` (inset 8, 24/42, ring, 4px handle). Spec says
    use `showNardSheet`.
15. **Fair dice**: only "Sənin açarın" is shown, but each roll uses both client
    seeds (FD-02) → add "Rəqibin açarı". Mismatch, in-progress and roll picker
    states are not designed. Mock values are middle-truncated; spec shows full
    selectable values.
16. **Avatars & flags**: API `avatar` is a free string (≤ 64); design uses
    per-player gradients. Suggest preset ids (teal/garnet/…) until Phase 4
    cosmetics. Flags: only az/tr/ru/en simplified swatches exist; `country` is
    any ISO code → needs a flag asset set (no emoji per readme).
17. **Score format**: history uses "5–2" (no spaces) vs "5 – 2" elsewhere.
    `pip` lowercase in 20.2 vs `Pip` in PlayerCard. BOT avatar shows "B" in 20.2
    vs bot icon in 20.1.
18. **Suffix harmony**: `{old}-dən`, `{rank}-ə` depend on the word (az vowel
    harmony; tier names are fixed, so a per-tier ARB string is possible).
19. **Header variants**: 10.3/15.x/17.x use a bare 48-high header (chevron 20,
    title 20) while 2.2/2.3 use the boxed 52-high one; `ScreenHeader` has only
    the boxed form.
20. **Loss variants** of the 2.6 rating card and the casual VS overline (only
    "REYTİNQLİ" is drawn) are inferred.
