# Game screen — implementation spec (from `nardarena-design`)

Extracted from `.claude/skills/nardarena-design/`: `GameScreen.dc.html`, `Board.dc.html`,
`PlayerCard.dc.html`, `StatusBar.dc.html`, `NardArena Dizayn Sistemi.dc.html`,
`Ekranlar 2 - Lobi ve Oyun.dc.html`, `Ekranlar 8 - Bot Klan SnG Ozel Turnir Qaydalar.dc.html`,
plus `components/*.jsx` and `tokens/*.css` where the HTML references them.

UI theme: `NardColors.sebeke` (design direction "1c"). Board cosmetic: `BoardTheme.walnut`.
Units are logical pt. `c.` = `context.nard`. "no token" = raw value, nothing in `apps/client/lib/theme/`.

---

## 0. Token mapping cheat-sheet (sebeke values seen in the mocks)

| Raw value in HTML | Flutter token |
|---|---|
| `#F3EBDD` | `c.text` (= `NardPalette.ivory100`) |
| `rgba(243,235,221,.66)` | `c.textDim` |
| `rgba(212,174,88,.32)` | `c.line` |
| `rgba(158,27,50,.18)` | `c.surface` |
| `#2a1a20` (sheetBg) | `c.surfaceRaised` |
| `#D4AE58` | `c.accent` |
| `#E8C468` | `c.accentHi` (= `NardPalette.brass300`) |
| garnet gradient `#b52a45→#9E1B32 60%→#86152a` | `c.primaryFill` |
| `#F8F1E4` | `c.primaryText` |
| `#9E1B32` | `c.danger` (= `NardPalette.garnet600`) |
| `#E0566C` | `c.dangerText` (= `NardPalette.garnet400`) |
| `#3FB57F` | `c.successText` (= `NardPalette.emerald400`) |
| `#D4AE58` / `#1d1316` (active clock) | `c.clockActiveBg` / `c.clockActiveText` |
| card radius 14 / button radius 999 | `c.cardRadius` / `c.buttonRadius` |
| `#F0CD6E` | `BoardOverlay.selectRing` |
| `rgba(240,205,110,.85)` | `BoardOverlay.legalFill` |
| `rgba(244,212,120,.95)` | `BoardOverlay.legalGhostBorder` |
| `rgba(240,205,110,.18)` | `BoardOverlay.legalGhostFill` |
| `rgba(243,235,221,.45)` (last-move ghost) | `BoardOverlay.lastMoveGhost` |
| `#34251a` | `NardPalette.walnut800` (ceviz `surfaceRaised`; used by 2.8/2.9 sheets, see §8) |
| `#2B1D14`, `#1b120c` | `NardPalette.walnut900`, `NardPalette.walnut950` |
| BG gradient `#24161b 0% → #17121a 50% → #1f1317 100%` (vertical) | **no token** (`c.bg` #1B1418 is the solid fallback, `c.bgDeep` = #17121a) |
| primary shadow `inset 0 0 0 1px rgba(212,174,88,.65), 0 6 18 rgba(158,27,50,.35)` | **no token** |
| scrim `rgba(8,6,5,.6)` (`.62` in 2.8/2.9) | **no token** (CSS `--scrim`) |
| elev-2 `0 12 30 rgba(0,0,0,.5)`, elev-3 `0 20 60 rgba(0,0,0,.6)` | **no token** (CSS `--elev-2/3`) |
| `#FBEFEF` (text on solid garnet) | **no token** |
| `#8f877b` (dim banner dot) | **no token** |
| `rgba(243,235,221,.45)` text-faint, `rgba(0,0,0,.25)` surface-sunken, `rgba(201,162,74,.12)` line-soft | **no token** (CSS only) |
| şəbəkə lattice (`60°/−60°` 1px lines @ `rgba(212,174,88,.11)` every 18px + `0°` @ `.06` every 15.6px) | **no token** — CustomPainter |

Fonts: `NardType.*` as listed; when a size has no token it is written "Noto Serif 17/22 600 (no token)" — implement as `NardType.title.copyWith(fontSize: 17, height: 22/17)` etc. Sebeke button labels use **Noto Serif Display** (`NardFonts.display`), not Plex. All numbers use tabular figures.

Spacing: screen gutter `NardSpace.screenGutter` (16), board gutter `NardSpace.boardGutter` (6), min hit `NardSpace.hitMin` (44), primary `NardSpace.hitPrimary` (56).

---

## 1. GameScreen — portrait 390×844

**Purpose:** the in-game screen (Short / Long Nard). Board horizontal, all controls in the bottom thumb zone.

### 1.1 Layout top → bottom
| # | Element | Size | Details |
|---|---|---|---|
| 0 | Background | full screen | vertical gradient (no token, see §0) + şəbəkə lattice band, top 300pt, masked `#000→transparent` top→bottom. Never flat. |
| 1 | System status bar | 50 | `StatusBar.dc.html` is only an iOS mock (9:41, Dynamic Island). → `SafeArea`, nothing to build. |
| 2 | Top bar | h 52, padding H 14 | Row, space-between. |
| 2a | Menu button (left) | 42×42 | radius `c.buttonRadius` (pill → circle), border 1px `c.line`, icon `menu` 20 `c.text`. Opens Game menu sheet (§8.3). |
| 2b | Center | column, gap 3 | Overline: mode label, `NardType.micro` (11/13 500), UPPERCASE, letterSpacing .06em, `c.textDim`. Score: `NardType.score` (Noto Serif 22/24 600 tnum), letterSpacing .02em, `c.text`. |
| 2c | Fair-dice button (right) | 42×42 | same as 2a, icon `shield-check` 20 in `c.accent`. Online/provably-fair → **Phase 3, omit** (or leave empty 42 slot to keep centering). |
| 3 | Opponent PlayerCard (row) | h 66 | padding T6 H10. See §3. |
| 4 | Center area | flex 1, column, `MainAxisAlignment.center`, gap 10 | holds 4a + 4b, vertically centered (≈64pt free above/below). |
| 4a | StatusBanner | h 26 | See §4. |
| 4b | Board | 378 × 334 | logical 640×566 scaled ×0.5906; horizontally centered (6pt gutters). Overlays (no-moves card etc.) are centered on the board. See §2. |
| 5 | My PlayerCard (row) | h 66 | padding H10 B10. |
| 6 | Control bar | h 62, padding H16, gap 10 | Row: Undo (66 wide) · Primary (flex) · Double (66 wide) — or Chat in Long Nard. See §1.3. |
| 7 | Home indicator | 34 | system; = bottom safe area. |

### 1.2 Banner/primary/undo/double per state (from `ST` table)
| State | Banner title / sub (tone) | Primary label / sub (style) | Undo | Double | Board |
|---|---|---|---|---|---|
| myturn (dice rolled) | `Sənin növbən` / `3 mümkün gediş` (brass) | `Təsdiqlə` / `0 / 2` (wait) | enabled | .35 (dice already rolled) | dice right half, selection + legal targets, opponent's last move markers |
| before roll (inferred, not drawn) | `Sənin növbən` (brass) | `Zər at` (on) | .35 | enabled (only when my turn & no dice) | no dice |
| rolling | `Zərlər atılır` / – (brass) | `Zər at` (pressed) | .35 | .35 | dice rolling state |
| opp | `Rəqib düşünür` / `Zərlər 5 – 2` (dim) | `Zər at` (off) | .35 | .35 | dice on **left** half, opp card active |
| cube (offer received) | `İkiqat təklifi` / `Kerem_TR-dən` (brass) | `Zər at` (off) | .35 | .35 | offer cube at center of right half + sheet §6.2 |
| nomoves | `Gediş yoxdur` / `Bar bağlıdır` (dim) | `Keç` / `0:02` (wait) | .35 | .35 | dice `used` (.4 opacity), card §6.1 |
| won | `Oyun bitdi` / `Mars` (ok) | `Növbəti oyun` (on) | .35 | .35 | 15 slabs in my tray + card §6.3 |
| longnard | `Sənin növbən` / `Başdan yalnız bir daş` (brass) | `Təsdiqlə` / `0 / 2` (wait) | enabled | hidden → `Söhbət` button | no cube |
| lowtime | `Vaxt azalır` / `0:09 qaldı` (danger) | `Təsdiqlə` / `0 / 2` | | | clock low + red vignette → **Phase 3** |
| reconnect | `Oyun dayandırılıb` / `Bağlantı kəsildi` (dim) | `Zər at` (off) | | | **Phase 3, omit** |

`0 / 2` = moves placed / moves required this turn (4 on doubles — inferred). Primary switches `wait → on` once all required moves are placed (inferred; only `wait` drawn for Təsdiqlə).

### 1.3 Control bar (portrait)
- **Undo**: 66×62, radius `c.buttonRadius`, border 1px `c.line`, column centered gap 4: icon `undo-2` 20 (`c.text`) + caption `Geri al` `NardType.micro` size 11/12 `c.textDim`. Disabled = opacity .35.
- **Primary**: flex 1 × 62, radius `c.buttonRadius`, row centered gap 10: label Noto Serif 17/20 600 (`NardType.labelL` with `fontFamily: NardFonts.display`), letterSpacing .01em, case `c.uppercaseLabels`; sub `NardType.bodyS` 13/16, opacity .75, tnum. Note: height 62 here, not the 56 button token.
  - `on`: `c.primaryFill`, text `c.primaryText`, primary shadow (§0).
  - `pressed`: `c.primaryFill`, shadow `inset 0 3 8 rgba(0,0,0,.3)` (no token), scale `NardMotion.pressScale` over `NardMotion.press`.
  - `wait`: transparent, border 1.5px `c.accent`, text `c.accent` (still tappable).
  - `off`: bg `c.surface`, border 1px `c.line`, text `c.textDim` (disabled).
- **Double (İkiqat)**: 66×62, same frame as Undo; glyph = 20×20 box, radius 4, 2px border currentColor, "2" Plex 700 9pt; caption `İkiqat`. Opacity 1 only when it's my turn and dice not rolled; else .35. Hidden in Long Nard and in a Crawford game (§10.1).
- **Chat (Söhbət)** (Long Nard only): 66×62, icon `message-square` 20 + caption `Söhbət` → chat is **Phase 5, omit** (leave slot empty or let Primary expand).

### 1.4 Clocks in offline games (Phase 2)
Clocks are Phase 3 (ROADMAP). Design hints: the BOT game mock (Ekranlar 8, 20.2) shows the opponent's clock slot as `—` while the player's still runs; pass & play has no clock design. **Recommendation:** in Phase 2 hide the clock block in PlayerCard (row: name/meta take the width) — or render `—` in the idle clock style if a stable layout is preferred. Low-time state, vignette and haptic tick: Phase 3. The "auto-pass" countdown on no-moves (`Keç · 0:02`) is local UI timing, not a game clock — keep it.

---

## 1L. GameScreen — landscape 844×390

Root: row, padding T14 R18 B14 **L50** (notch side; use safe-area insets), gap 14.

| Column | Width | Content (top → bottom) |
|---|---|---|
| Left: players | 158 | column `spaceBetween`, gap 10: Opp PlayerCard `side` (≈158×104) · info block · My PlayerCard `side`. |
| — info block | padding H4, column gap 6 | mode overline Plex 10/12 500 UPPERCASE .06em `c.textDim` (no token; `micro` is 11) · score Noto Serif 24/26 600 tnum (no token; nearest `NardType.score`) · banner row: dot 6×6 + title Plex 12/15 600 tone color (no sub line in landscape). |
| Center: board | flex (≈494) | Board 480×345 (640×460 ×0.75), centered; overlays centered on board. |
| Right: controls | 96 | column gap 10: row (gap 8) of Menu + Fair-dice icon buttons (each flex×44, radius `c.buttonRadius`, border `c.line`) · spacer · Undo h60 · Double h60 (if shown) · Primary h88 (label Noto Serif 15/18 600, sub Plex 12/14 .75, both centered, column gap 4). |

Landscape states drawn: L1 myturn, L2 cube (sheet centered, width 380), L3 won, L4 longnard. No-moves card (landscape): same card, gap 8, sub only `Növbə 2 saniyəyə rəqibə keçir.`, **no progress bar**. Reconnect: Phase 3.

---

## 2. Board (Flame) — `Board.dc.html`

Logical space 640 × H (`BoardGeometry.width`, `heightPortrait` 566 / `heightLandscape` 460), uniform scale `s = targetWidth/640`.
All geometry below in logical units; constants map to `BoardGeometry`:
`frame`=20 (F), `quadrant`=252 (Q), `bar`=36, `pointWidth`=42, `checker`=38 (D), `barChecker`=34, `trayGap`=14, `tray`=46, `die`=44, `cube`=34, `cubeOffer`=56, `pointHeightRatio`=.43, `offSlab`=40×10.
Derived: point height `ph = round((H−40)·0.43)` → **226** portrait / **181** landscape. `maxFit = floor(ph/38)` → **5** portrait / **4** landscape. Tray x `TX = 20+252+36+252+14 = 574`.

### 2.1 Layers (draw order)
1. **Frame**: 640×H, radius 12, walnut grain over gradient `#6e4224 → #4b2b16 55% → #5d3720` (`BoardTheme.walnut.frame` = #5D3720 is the flat fallback; texture `walnut/frame`). Shadow: `0 18 40 rgba(0,0,0,.55)`, `0 4 10 rgba(0,0,0,.4)`, inset top highlight 1px `rgba(255,220,170,.18)`, inset bottom 3px `rgba(0,0,0,.35)`, inset 1px ring `rgba(0,0,0,.45)` (no tokens).
2. *(sebeke mock only)* **Xatəm inlay**: band behind each field: rect (x−6, 14, 264, H−28), radius 3, stripes 45° `#C9A24A 0–3, #F3EBDD 3–5, #9E1B32 5–8, #1c120b 8–10`, 1px `rgba(0,0,0,.5)` ring. Appears because GameScreen 1c uses the `xatam` board; the Ekranlar 8 mocks use plain `walnut`. See Open questions.
3. **Fields** (2): x = 20 and 308 (`colX`), y = 20, 252 × (H−40), radius 2, grain over `#c49159 → #a87745` (`BoardTheme.walnut.field` #B4824D fallback).
4. **Bar**: x 277, width 26, full field height, radius 2, horizontal gradient `rgba(0,0,0,.4) → .06 @30% → .06 @70% → .4` (frame wood shows through).
5. **Hinges** (2, brass): 8×26 at x 286, y = 0.2·H and 0.8·H−26, radius 2, gradient `#8a6a2a → #e2c472 45% → #a07c30`, shadow `0 1 2 rgba(0,0,0,.6)`.
6. **Points** 1–24: triangle 40 wide (column x+1) × ph; bottom row tip up, top row tip down. Odd points = dark (`BoardTheme.walnut.pointA` #1A0E07; texture ebony `#2e1c10→#1a0e07` + fine vertical lines), even = light (`pointB` #E3D3B4; bone `#f2e7cf→#d5c29d`).
   Geometry: `BoardGeometry.point(i)` — 1–12 bottom row right→left (point 1 = bottom-right next to tray), 13–24 top row left→right. Always from the local (bottom) player's view.
7. **Legal-target overlay** (per highlighted point): same triangle, linear gradient from base to tip `BoardOverlay.legalFill` (.85) → `rgba(240,205,110,.12)`.
   **Illegal overlay** (23.3 only): `rgba(224,86,108,.9)` → `rgba(224,86,108,.15)` (no token; `c.dangerText` based).
8. **Point numbers**: in the frame strip, centered on the 42 column, Plex 9/12 600 tnum (no token). Bottom row y = H−16, top row y = 4. Color `BoardTheme.walnut.numberColor` (.55 ivory); legal target → `BoardOverlay.selectRing` (#F0CD6E); illegal → `c.dangerText`. Drawn in code, not textured.
9. **Field inner shadow** (on top of points): `inset 0 3 10 rgba(0,0,0,.55)`, `inset 0 0 0 1 rgba(0,0,0,.35)`.
10. **Bear-off trays** (2): x 574, w 46, radius 4. Top tray y 20, bottom tray y H/2+26, each h = (H−40)/2 − 26 → 237 portrait / 184 landscape. Fill `#2a170c → #1c0f07` (no token), inset shadow `0 3 8 rgba(0,0,0,.7)` + 1px `rgba(0,0,0,.5)` ring + `0 1 0 rgba(255,220,170,.12)` lip. Local player's tray = bottom, opponent = top.
11. **Last-move "from" ghost**: at the next free slot of each `lastFrom` point: 38 circle, 2px **dashed** `BoardOverlay.lastMoveGhost`, no fill.
12. **Checkers** (see 2.2).
13. **Legal ghost** at the next free slot of each target point: 38 circle, 2px dashed `BoardOverlay.legalGhostBorder`, fill `BoardOverlay.legalGhostFill`. Illegal ghost: 2px dashed `c.dangerText`, fill `rgba(224,86,108,.22)`.
14. **Bar checkers** (34): x 273. Mine: y = H/2+22 + k·30 (downwards); opponent: y = H/2−56 − k·30 (upwards). Optional "must enter" glow: + 3px `BoardOverlay.selectRing` ring.
15. **Borne-off slabs** 40×10 radius 3 at x 577: mine from the bottom y = H−34 − k·11; opponent from the top y = 24 + k·11. Ivory `#fbf4e4→#d9c9a8`, onyx `#4a4440→#151312`, shadow `0 1 1 rgba(0,0,0,.5/.6)`. 15 slabs fit both orientations.
16. **Cube** (hidden in Long Nard, Crawford):
    - Centered (no owner): 34×34 at (580, H/2−17) — in the gap between the trays — radius 6, `#fbf5e8→#d6c5a0` 145°, shadow `0 3 6 rgba(0,0,0,.55)` + inset bottom `0 −2 3 rgba(0,0,0,.2)`, label Plex 700 13 `#2B1D14` = `64` when centered, else the value.
    - Offer: 56×56 radius 10, centered in the **right** half (x 406, y H/2−28), `#fbf5e8→#ddcdaa`, ring 3px `#F0CD6E` + glow `0 0 30 8 rgba(240,205,110,.45)`, label Noto Serif 700 28 `#2B1D14` = proposed value.
    - Owned cube position (by me / by opponent) is **not drawn** — see Open questions.
17. **Dice** (2): 44×44 radius 9, `#fffaf0→#e4d6b8` 145°, shadow `0 4 6 rgba(0,0,0,.45)`, inset bottom `0 −3 4 rgba(0,0,0,.18)`, inset top highlight `0 2 2 rgba(255,255,255,.8)`. Pips 7.5 Ø on a 3×3 grid at offset 8 + idx·10.5, radial `#3a2a1e→#0d0806` with inset shadow; layout per value: 1:[4] 2:[2,6] 3:[2,4,6] 4:[0,2,6,8] 5:[0,2,4,6,8] 6:[0,2,3,5,6,8] (idx = row·3+col).
    Position: center x = 434 (right half) for me, 146 (left half) for opponent; die j at x = cx−48 + j·52, y = H/2−22. Idle tilt −3° / +4°.
    States: `rolling` = rotate −22° translate(−8,12) / +31° translate(10,−14), blur .8, deeper shadow; `used` = opacity .4 (design dims both together; per-die dimming inferred).
18. Overlays (no-moves card, error toast) are Flutter widgets above the Flame view.

### 2.2 Checkers
- 38 Ø (`BoardGeometry.checker`). Ivory (local player in mocks): radial `#fffbf2 0, #efe4cf 42%, #d4c3a2 78%, #b3a07c` at 38%/30% + concentric grooves (repeating ring every 6px, `rgba(110,85,50,.17)`); shadow `0 2 2 rgba(0,0,0,.35), 0 4 8 rgba(0,0,0,.25)`, inset bottom `rgba(80,55,25,.35)`, inset top 1px white .9.
  Onyx: radial `#5d564f, #2b2724 40%, #151312 80%, #0a0909`, grooves `rgba(255,255,255,.055)`; shadow .45/.3, inset bottom `rgba(0,0,0,.6)`, top highlight .18. Flat fallbacks: CSS `--checker-ivory` #efe4cf / `--checker-onyx` #2b2724 (no Dart token).
- Stacking from the point base: x = column x + 2. Bottom row y = H−20−38−k·sp; top row y = 20 + k·sp. `sp = 38` while count ≤ maxFit, else `(ph−38)/(count−1)` (compress to point height).
- **Stack count label**: only when count > maxFit, on the top checker: Plex 700 15 (no token), `#4a3620` on ivory / `#efe4cf` on onyx.
- **Selected** (top checker of the selected point): extra ring 3px `BoardOverlay.selectRing` + glow `0 0 18 5 rgba(240,205,110,.55)` (CSS `--glow-legal`), lifted 5 toward the board center.
- **Last move "to"**: top checker gets 2px ring `rgba(240,205,110,.6)` (no token).
- **Color-blind mode** (DS): ivory gets a dark ring (`#2B1D14` band at 24–32% radius, + 2px inset `#2B1D14` edge); onyx gets a center dot `#E8C468` (≤18% radius, + 2px inset `#E8C468` edge). Legal moves are always also shown with the dashed ghost.

### 2.3 Interaction / motion
- Tap own checker → selected (lift + ring), legal target points highlighted + ghost; tap target → move. Primary shows `n / required`.
- Opponent's last move stays marked (from-ghost + to-ring) during my turn (when it clears: Open questions).
- Motion (`NardMotion`): checker slide on an arc 280 ms `checkerCurve`; hit → bar 220 ms `inBack` + 80 ms shake; bear-off 240 ms `outQuart`; dice 800 ms spring(0.55, 260) with 2 bounces, fast mode 300 ms `outCubic`; button press 90 ms scale .97. Reduce motion: dice resolve instantly, checkers 120 ms linear, celebrations off.

---

## 3. PlayerCard — `PlayerCard.dc.html`

### 3.1 `row` layout (portrait, h 66)
Row, padding V10 H12, gap 12, radius `c.cardRadius`.
- Active (their turn): bg `c.surface`, inset 1px `c.line` ring. Inactive: transparent, no ring.
- **Avatar** 46: conic brass ring `from 210°: #8a6a22, #E8C468, #a07c30, #E8C468, #8a6a22` (no token), inner disc inset 3 with avatar bg (mock: `#2f4a52→#162428` 150°; TR player `#5b2a2a→#2a1414`), initials Noto Serif 600 18 `c.text`. Active glow: `0 0 0 2 accent@20%`, `0 0 16 accent@40%`.
- **Text column** (flex, gap 5): line 1 = name `NardType.labelM` (15/18 600), single line, ellipsis + flag 18×12 radius 2 (1px `rgba(0,0,0,.3)` ring). Line 2 = `NardType.caption` 12/14, `c.textDim`, tnum, gap 7: rank hexagon 14×16 · rating (`c.text`, 500) · rank name · `·` (50% opacity) · `Pip 167`.
  Phase 2 offline: rating/rank/flag are Phase 3 data — show name + `Pip N` (and bot level for AI).
- **Offline pill** (`Oflayn`): Plex 11/14 600 `c.dangerText` on `rgba(224,86,108,.14)`, padding 4×8, pill; card content opacity .45 + grayscale → **Phase 3, omit**.
- **Emote button** (my card, portrait only): 40 Ø, 1px `c.line` border, icon `smile` 20 `c.textDim` → **Phase 5, omit**.
- **Clock** (Phase 3 — see §1.4): min-width 74, padding T6 R10 B7 L10, radius min(cardRadius,10)=10, column right-aligned gap 4: time `NardType.clock` (20/20 600 tnum, letterSpacing .01em) + delay bar 3px radius 2 (fill width = remaining delay fraction).
  | state | bg | text & bar fill | bar track | extra |
  |---|---|---|---|---|
  | idle | `c.surface` | `c.textDim` | `rgba(255,255,255,.08)` | |
  | active | `c.clockActiveBg` | `c.clockActiveText` | `rgba(0,0,0,.15)` | |
  | low (<10 s) | `c.danger` | `#FBEFEF` | `rgba(255,255,255,.25)` | glow `0 0 0 3 rgba(224,86,108,.3), 0 0 20 rgba(224,86,108,.45)` |

### 3.2 `side` layout (landscape, 158 wide)
Column, padding 12, gap 10, radius `c.cardRadius`, same active bg/ring.
- Row gap 10: avatar 38 (ring inset 2.5, initials Noto Serif 15) + column gap 3: name Plex 13/17 600 ellipsis + flag 16×11; meta Plex 11/13 `c.textDim`: hexagon 11×13 · rating (`c.text`) · `Pip N`.
- Clock block (Phase 3): padding T7 R10 B8 L10, radius 10, column gap 5: row baseline space-between: time Plex 22/22 600 tnum (no token) + `+12s` Plex 11/13 .75; delay bar 3px.

---

## 4. StatusBanner

Row h 26, centered, gap 10, `NardType.bodyS` size 13 / line 16.
- Ornament on both sides (sebeke only; ceviz/komur have none): left = line 28×1 `c.line` + gap 5 + diamond 5×5 rotated 45° `c.accent` @ .7; mirrored on the right.
- Dot 7×7 circle + glow `0 0 8` in the tone color.
- Title 600, tone text color, case per theme (sebeke none), letterSpacing .01em. Sub `c.textDim`.
- Tones: `brass` → dot + title `c.accent`; `dim` → dot `#8f877b` (no token), title `c.text`; `danger` → `c.dangerText`; `ok` → `c.successText`.
- Text must stay one line → ellipsize sub first (RU/TR overflow).

---

## 5. Design-system components used by the game (`NardArena Dizayn Sistemi` + `components/*.jsx`)

DS card is rendered in ceviz (1a); values below are given as tokens so they resolve to sebeke.

| Component | Spec |
|---|---|
| **Button** | Heights l 56 / m 48 / s 40 (DS header says "56 / 48 / 44"; jsx s=40). Padding H20, gap 10, radius `c.buttonRadius`, label `NardType.labelL` (s: `labelM`) in `NardFonts.display` for sebeke, optional sub `NardType.bodyS` .75 tnum. **primary**: `c.primaryFill`, `c.primaryText`, primary shadow. **secondary**: transparent, 1.5px inset `c.accent` ring, text `c.accent`. **ghost**: text `c.text`. **danger**: `c.danger` fill, text `#FBEFEF`. **outline**: 1px `c.line` ring, text `c.text`. **Pressed**: scale .97 / 90 ms (`NardMotion.press`, `standard`); DS card also shows per-variant pressed fills — primary inset shadow `0 3 8 rgba(0,0,0,.3)`; secondary bg `rgba(201,162,74,.16)` + text `c.accentHi`; ghost bg `rgba(243,235,221,.08)`; danger bg `#7f1428` (no tokens). **Disabled**: bg `c.surface`, 1px `c.line` ring, text faint `rgba(243,235,221,.4–.45)` (no token); danger-disabled bg `rgba(158,27,50,.25)`, text `rgba(251,239,239,.45)`. No ripple (`NoSplash`). |
| **IconButton** | 44×44 (game top bar: 42×42), radius `NardRadius.m` (12) — in GameScreen sebeke it is `c.buttonRadius` (circle); `round` = circle. 1px `c.line` ring, icon 20 Lucide 2px stroke. Tone: default `c.text`, accent `c.accent`, danger `c.dangerText`. With caption: 66×60, column gap 4, caption `NardType.micro` `c.textDim`. |
| **Chip** | h 34, padding H14, pill. Unselected: 1px `c.line` ring, `c.text`, Plex 13 500. Selected: bg `rgba(201,162,74,.18)` (no token), 1.5px `c.accent` ring (DS card draws 1px), text `c.accentHi` 600. |
| **SegmentedControl** | Container padding 4, radius 14, bg surface-sunken `rgba(0,0,0,.25)`, 1px line-soft ring (no tokens). Segment h 40 radius 10, Plex 14 600. Selected bg `NardPalette.ivory100`, text `NardPalette.walnut900`; unselected text `c.textDim` (.7). **18.1 uses a different variant** (§9.1). |
| **Switch** | 48×28 pill; thumb 22 Ø at top 3, left 3 (off) / 23 (on). On: track `c.accent`, thumb `c.bg`. Off: track `rgba(243,235,221,.14)`, thumb `NardPalette.ivory100`. Animate `NardMotion.fast` `standard`. (`NardTheme.switchTheme` already maps colors; size differs from Material.) |
| **Die** | §2.1 item 17. Reference size 44, scales by size/44. |
| **Checker** | §2.2. DS demo size 46. |
| **StatusBanner** | §4. |
| **Sheet** | Inset 8 from left/right/bottom; padding T12 H20 B30; radius **24 top / 42 bottom** (matches device corners); bg `c.surfaceRaised`; 1px `c.line` ring + elev-2; column gap 14. Drag handle 40×4 radius 2 `rgba(243,235,221,.25)` (`c.text` @ .25), centered. Optional title Noto Serif 22/28 600 (no token; between title and displayL). Scrim `rgba(8,6,5,.6)`. Motion: in 320 ms / out 220 ms `NardMotion.standard`. Note `NardTheme.bottomSheetTheme` has only a 24 top radius and full width → build a custom sheet. |
| **PlayerCard / Clock** | §3. DS card shows 4 states: passive, active + delay bar, low time, offline. |
| **ProgressBar** | Height 4 default (3 in game overlays, 6 in rank card), radius h/2, track `rgba(243,235,221,.12)` (game overlays use `c.line`), fill tone: accent `c.accent`, success `c.successText`, danger `c.dangerText`. |

Motion table (DS "HAREKET"): dice 800 ms spring(0.55, 260) · 2 bounces; dice fast 300 ms easeOutCubic; checker arc 280 ms cubic(.3,.7,.2,1); hit → bar 220 ms easeInBack + 80 ms shake; bear-off 240 ms easeOutQuart; sheet 320/220 ms cubic(.2,.8,.2,1); button 90 ms scale .97 easeOut; rating counter 1200 ms easeOutExpo. All in `NardMotion`.

### 5.1 DS "Tahta durumları" (board states) — captions translated
01 My turn + selection: point 13 selected; targets 7, 10, 4 shown as brass triangle + dashed ghost; opponent's last move = dashed ring (from) + thin ring (to). · 02 Opponent's turn: dice in the left half, opponent card active, primary disabled. · 03 Rolling: dice blurred while spinning, button pressed; 800 ms, 300 ms in fast mode. · 04 Cube offer: thumb-reachable bottom sheet, answer time visible. · 05 No legal move: bar closed, dice dimmed, auto-pass countdown. · 06 Low time: clock turns garnet, red edge vignette, haptic tick below 10 s (Phase 3). · 07 Reconnecting: opponent faded + Oflayn badge, countdown on board (Phase 3). · 08 Game won · mars: if the match continues, score + "Növbəti oyun"; match end = 2.6. · 09 Long Nard: no cube (chat instead), head rule in the banner.
Landscape: "players left, controls right (right thumb), board 480 pt".

---

## 6. In-game overlays (GameScreen states; Ekranlar 2 maps them to Phase 2)

### 6.1 No legal move
- Card centered on the board: width 250, padding V14 H18, radius `c.cardRadius`, bg `c.surfaceRaised`, shadow elev-2 + 1px `c.line` ring; column, center, gap 10 (landscape 8), text centered.
- Title `Mümkün gediş yoxdur` Noto Serif 17/22 600 (no token). Sub `NardType.bodyS` `c.textDim`: `5 – 5 · bar bağlıdır. Növbə 2 saniyəyə rəqibə keçir.` (dice + reason + handover).
- Countdown bar (portrait only): 3px, radius 2, track `c.line`, fill `c.accent`, animates 0→100% over the auto-pass delay (2 s).
- Banner `Gediş yoxdur` / reason (dim); dice `used`; primary `Keç` / `0:02` (wait) = skip the countdown. Reason text comes from the engine (bar closed etc.).

### 6.2 Cube offer sheet (received)
- Scrim `rgba(8,6,5,.6)`. Portrait: sheet at left/right/bottom 8; landscape: centered, width 380.
- Container: padding 20, radius **22 all corners** (no token; ≠ DS sheet 24/42), bg `c.surfaceRaised`, shadow `0 −10 40 rgba(0,0,0,.5)` + 1px `c.line`; column gap 18. **No drag handle** (modal decision — not dismissible by swipe; inferred).
- Row gap 16: cube 60×60 radius 11, `#fbf5e8→#ddcdaa` 145°, shadow + 2px `c.accent` ring + glow `0 0 26 rgba(232,196,104,.4)`, "2" Noto Serif 700 30 `NardPalette.walnut900` | column gap 5: title `NardType.title` (19/24) `Kerem_TR ikiqat təklif edir`; body `NardType.bodyS` `c.textDim` `Oyunun dəyəri 1 → 2 xal. Qəbul etsən, kub sənə keçir.`
- Answer timer (column gap 7): row space-between Plex 12/14 `c.textDim` `Cavab vaxtı` + `0:14` (`c.text` 600 tnum); bar 4px radius 2, track `c.line`, fill `c.accent`. → clock-driven, **Phase 3, omit** offline.
- Buttons row gap 10, each flex × 56, radius `c.buttonRadius`, column centered gap 2:
  - Decline: transparent, 1.5px border `rgba(224,86,108,.6)` (no token), text `c.dangerText`; label Plex 16/19 600 `İmtina et`, sub 11/13 .85 `−1 xal, oyun bitir`.
  - Accept: primary; label `Qəbul et`, sub (.8) `Dəyər 2 xal`.
- Board shows the offer cube (§2.1-16). Banner `İkiqat təklifi` / `Kerem_TR-dən`.
- Offline: offers come from the bot or from the other pass & play player. My own "waiting for answer" state is not designed.

### 6.3 Game won (Mars) — match continues
- Scrim radial `60% 50% at center: rgba(201,162,74,.18) → rgba(8,6,5,.78) 70%` (no token).
- Card centered: width 318, padding T22 H22 B20, radius `c.cardRadius`, bg `c.surfaceRaised`, shadow elev-3 + 1px `c.line`; column center gap 14, text centered.
  1. Ornament divider (gap 8): line 44×1 `c.accent` @.6 · diamond 6×6 1px outline · diamond 8×8 filled · diamond 6×6 outline · line.
  2. Column gap 6: `QƏLƏBƏ` Noto Serif 38/42 600, letterSpacing .06em, `c.accent` (no token; nearest `displayXl` 40/44) + pill `Mars · +2 xal` Plex 13/16 600, padding 4×10, bg `rgba(63,181,127,.16)`, text `c.successText`.
  3. Row gap 16 tnum: my name Plex 13/16 `c.textDim` · score Noto Serif 30/34 600 `5 – 1` · opponent name.
  4. `7 xala qədər · matça 2 xal qaldı` Plex 12/14 `c.textDim`.
  5. Buttons row gap 10, h 50: `Təhlil` (flex 1, outline 1px `c.line`, Plex 15 600) — analysis is **Phase 6**, omit/hide (replay viewer is Phase 2 — could repurpose, see Open questions) · `Növbəti oyun` (flex 1.6, primary).
- Banner `Oyun bitdi` / `Mars` (ok); bottom primary `Növbəti oyun` (on). Variants by result (single game / koks / loss) are not drawn — inferred strings below.

### 6.4 GameScreen strings
| key suggestion | az text |
|---|---|
| gameModeShortTo | `Qısa nərd · {points} xala qədər` |
| gameModeLongTo | `Uzun nərd · {points} xala qədər` |
| gameScore | `{me} – {opp}` |
| bannerYourTurn | `Sənin növbən` |
| bannerLegalMoveCount | `{count} mümkün gediş` |
| bannerRolling | `Zərlər atılır` |
| bannerOpponentThinking | `Rəqib düşünür` |
| bannerDice | `Zərlər {a} – {b}` |
| bannerCubeOffer | `İkiqat təklifi` |
| bannerCubeOfferFrom | `{name}-dən` (suffix harmony — see Open questions) |
| bannerNoMoves | `Gediş yoxdur` |
| bannerBarClosed | `Bar bağlıdır` |
| bannerGameOver | `Oyun bitdi` |
| bannerHeadRuleHint | `Başdan yalnız bir daş` |
| bannerLowTime (Phase 3) | `Vaxt azalır` |
| bannerTimeLeft (Phase 3) | `{time} qaldı` |
| bannerPaused (Phase 3) | `Oyun dayandırılıb` |
| bannerDisconnected (Phase 3) | `Bağlantı kəsildi` |
| actionRoll | `Zər at` |
| actionConfirm | `Təsdiqlə` |
| actionMovesProgress | `{done} / {total}` |
| actionPass | `Keç` |
| actionNextGame | `Növbəti oyun` |
| actionUndo | `Geri al` |
| actionDouble | `İkiqat` |
| actionChat (Phase 5) | `Söhbət` |
| playerPip | `Pip {pip}` |
| playerOffline (Phase 3) | `Oflayn` |
| noMovesTitle | `Mümkün gediş yoxdur` |
| noMovesBody | `{a} – {b} · bar bağlıdır. Növbə 2 saniyəyə rəqibə keçir.` (portrait; reason part should be a separate key per rejection reason) |
| noMovesHandover | `Növbə 2 saniyəyə rəqibə keçir.` |
| reconnectTitle (Phase 3) | `{name} yenidən qoşulur…` |
| reconnectBody (Phase 3) | `{time} qaldı · vaxt bitsə, qələbə sənindir` |
| cubeOfferTitle | `{name} ikiqat təklif edir` |
| cubeOfferBody | `Oyunun dəyəri {from} → {to} xal. Qəbul etsən, kub sənə keçir.` |
| cubeAnswerTime (Phase 3) | `Cavab vaxtı` |
| cubeDecline | `İmtina et` |
| cubeDeclineSub | `−{points} xal, oyun bitir` |
| cubeAccept | `Qəbul et` |
| cubeAcceptSub | `Dəyər {points} xal` |
| gameWonTitle | `QƏLƏBƏ` (render as uppercase of `Qələbə`; az uppercase needs locale-aware İ/I) |
| gameWonResult | `Mars · +{points} xal` (inferred variants: `Koks · +{points} xal`, `+{points} xal`) |
| gameMatchProgress | `{target} xala qədər · matça {left} xal qaldı` |
| actionAnalysis (Phase 6) | `Təhlil` |

Icons: `menu`, `shield-check`, `undo-2`, `message-square`, `smile`; cube glyph drawn.

---

## 7. 2.6 Match result (full screen, Ekranlar 2)

**Purpose:** match finished (match target reached). Mock = win; loss not drawn.
- Background: radial `90% 45% at 50% 22%`: `rgba(201,162,74,.28) 0% → #2B1D14 60% → #1b120c 100%` (walnut, warm brass glow; no token — celebration bg). Status bar 50.
- Content: padding T20 H16, column gap 18.
  1. Header column centered gap 8: ornament divider (lines 40×1 full `c.accent`, diamonds as §6.3) · `Matç qələbəsi` Noto Serif 34/40 600 `c.accentHi`, letterSpacing .04em (no token) · score `5 – 2` Noto Serif 44/48 600 tnum (no token) · `Elvin · Kerem_TR · 5 xala qədər` Plex 13 `c.textDim`.
  2. Rating card (radius 18, bg `#34251a`, `REYTİNQ`, `+24`, `1866`, `1842-dən`, `Platin I-ə 34 xal qaldı`) → **Phase 3, omit**.
  3. Rewards tiles (`+250 sikkə`, `+120 təcrübə`) → **Phase 4, omit**.
  4. Mission progress (`3 oyunda mars et 3/3 ✓`, `5 reytinqli matç qazan 2/5`) → **Phase 4, omit**.
- Bottom: padding H16 B40, column gap 10:
  - Row gap 10, h 52, radius 14 (note: not pill): `Təhlil` secondary (1.5px `c.accent` ring, text `c.accentHi`, Plex 15 600) → Phase 6 / `Replayı paylaş` outline (1px `rgba(201,162,74,.3)`) → sharing not in Phase 2; local replay viewer is (ADR-017) — candidate replacement "view replay" (needs new string).
  - `Revanş` primary h 56 pill, Plex 17 600 (sebeke: Noto Serif) → offline = new match, same settings.

| key suggestion | az text |
|---|---|
| matchWonTitle | `Matç qələbəsi` |
| matchScore | `{me} – {opp}` |
| matchMeta | `{me} · {opp} · {points} xala qədər` |
| matchRematch | `Revanş` |
| matchAnalysis (Phase 6) | `Təhlil` |
| matchShareReplay (later) | `Replayı paylaş` |
| matchRatingLabel (Phase 3) | `REYTİNQ` |
| matchRatingFrom (Phase 3) | `{old}-dən` |
| matchRatingToNext (Phase 3) | `{rank}-ə {points} xal qaldı` |
| matchCoins (Phase 4) | `sikkə` |
| matchXp (Phase 4) | `təcrübə` |

Motion: rating counter 1200 ms `outExpo` (Phase 3). Celebration off with reduce motion.

---

## 8. In-game sheets (Ekranlar 2)

### 8.1 Common sheet frame (2.8, 2.9)
Scrim `rgba(8,6,5,.62)` over GameScreen; sheet left/right/bottom 8, radius 24 top / 42 bottom, bg `#34251a` in the mock (= walnut800; in sebeke use `c.surfaceRaised` #2a1a20 for consistency with the cube sheet — Open question), 1px ring `rgba(201,162,74,.24)` (≈ `c.line`). Handle 40×4 radius 2 `rgba(243,235,221,.25)`.

### 8.2 2.8 Resign (Təslim ol)
- Padding 20, column gap 14: handle · title `Təslim ol` Noto Serif 22 600 · body Plex 13/18 `c.textDim` `Kubun dəyəri ×1. Rəqibə verəcəyin xalı seç.`
- 3 radio rows: padding 14, radius 14, row gap 14. Selected: 1.5px `c.accent` ring, bg `rgba(201,162,74,.1)`; unselected: 1px `rgba(201,162,74,.18)` ring, transparent. Radio 22 Ø, 2px ring (`c.accent` / `rgba(243,235,221,.35)`), inner dot 10 `c.accent` when selected. Title Plex 15 600, desc Plex 12 `rgba(243,235,221,.6)`, trailing value Plex 15 600 `c.dangerText` tnum.
  1. `Tək oyun` · `Adi məğlubiyyət` · `−1` (default selected)
  2. `Mars` · `Heç daş çıxarılmayıb` · `−2`
  3. `Koks` · `Daş barda və ya rəqib evində` · `−3`
  Values = level × cube value.
- Buttons row gap 10, padding-bottom 16, h 54, radius 14: `Ləğv et` (flex 1, 1px `rgba(201,162,74,.3)` ring, Plex 15 600) · `Təslim ol · −1` (flex 1.4, `c.danger` fill, text `#FBEFEF`), label updates with the selected value.

| key suggestion | az text |
|---|---|
| resignTitle | `Təslim ol` |
| resignBody | `Kubun dəyəri ×{cube}. Rəqibə verəcəyin xalı seç.` |
| resignSingle | `Tək oyun` |
| resignSingleDesc | `Adi məğlubiyyət` |
| resignMars | `Mars` |
| resignMarsDesc | `Heç daş çıxarılmayıb` |
| resignKoks | `Koks` |
| resignKoksDesc | `Daş barda və ya rəqib evində` |
| resignPoints | `−{points}` |
| resignCancel | `Ləğv et` |
| resignConfirm | `Təslim ol · −{points}` |

### 8.3 2.9 Game menu (Oyun menyusu)
- Padding T12 H20 B30; handle (margin-bottom 12); list of rows h 54, row gap 14, bottom border 1px `rgba(201,162,74,.12)` (line-soft): icon 20 · label Plex 16 500 (flex) · trailing value Plex 13 `rgba(243,235,221,.5)`.

| key suggestion | az text | icon (Lucide) | trailing | color / phase |
|---|---|---|---|---|
| menuResume | `Oyuna qayıt` | `play` | – | `c.text` |
| menuSettings | `Ayarlar` | `settings` (mock: sun-like circle + 4 rays) | – | `c.text` |
| menuFairDice | `Ədalətli zər` | `shield-check` | `Yoxla` (key `menuFairDiceVerify`) | **Phase 3, omit** |
| menuRules | `Qaydalar` | `file-text` | `Qısa nərd` / `Uzun nərd` (current variant) | `c.text` |
| menuSound | `Səs` | `volume-1` | `Açıq` (key `commonOn`; off state `Bağlı` inferred, not in mock) | `c.text` — toggles |
| menuResign | `Təslim ol` | `flag` | – | `c.dangerText` → opens 8.2 |

Interactions: scrim tap / drag down / `Oyuna qayıt` closes. Sheet 320/220 ms.

---

## 9. Pass & play (Ekranlar 8, Phase 2)

### 9.1 18.1 Setup (Bir cihazda · quraşdırma)
- Background `#1b120c` flat (= `NardPalette.walnut950`; no sebeke gradient here — use `c.bgDeep` or the sebeke gradient; Open question).
- Header h 48, padding H16, gap 12: `chevron-left` 20 + title `Bir cihazda` Noto Serif 20 600 (no token).
- Body padding T6 H16, column gap 14:
  1. Two player rows: padding V12 H14, radius 16 (`NardRadius.l`), bg `rgba(243,235,221,.04)`, 1px ring `rgba(201,162,74,.18)` (no tokens), gap 12: checker swatch 32 Ø (ivory `#efe4cf` / onyx `#2b2724`, inset `0 −3 0 rgba(0,0,0,.25)`, 1px `rgba(0,0,0,.4)`) · column gap 2: side label Plex 12 `rgba(243,235,221,.55)` + name Plex 16 600 · trailing `pencil` 16 @ .5 (tap = edit name).
  2. Overline `OYUN` Plex 12 600, letterSpacing .06em, `rgba(243,235,221,.55)`, padding T6 H4.
  3. Variant segmented (pill variant): padding 3, pill, bg `rgba(243,235,221,.06)`; segments h 36 pill, Plex 14 600; selected bg `c.accent`, text `c.clockActiveText` (#1d1316, no dedicated "onAccent" token); unselected `rgba(243,235,221,.7)`.
  4. Options group: radius 16, bg `rgba(243,235,221,.04)`, 1px ring `rgba(201,162,74,.14)`, clip. Rows min-h 52, padding V4 H14, gap 12, bottom border 1px `rgba(201,162,74,.08)`: column gap 1 (label Plex 15, sub Plex 12 @.55) + switch **44×26** (thumb 20 at x 3/21; on: track `c.accent`, thumb #1d1316; off: track `rgba(243,235,221,.14)`, thumb ivory) — smaller than DS switch 48×28.
- Footer padding T16 H16 B40: primary h 56 pill `Oyuna başla` Plex 16 600 (sebeke button font = Noto Serif).
- Not in the mock: match length, cube on/off (2.2 Game setup covers these) — Open question.

| key suggestion | az text |
|---|---|
| hotseatTitle | `Bir cihazda` |
| hotseatWhite | `Ağ daşlar` |
| hotseatBlack | `Qara daşlar` |
| hotseatGameSection | `OYUN` |
| variantShort | `Qısa nərd` |
| variantLong | `Uzun nərd` |
| hotseatHideBetweenTurns | `Növbələr arası ekranı gizlət` |
| hotseatHideBetweenTurnsSub | `“Telefonu rəqibə ver” ekranı` |
| hotseatFlipBoard | `Taxtanı çevir` |
| hotseatFlipBoardSub | `Hər növbədə növbəti oyunçuya tərəf` |
| hotseatAllowUndo | `Gedişi geri almaq` |
| hotseatAllowUndoSub | `Rəqib hazıram deyənə qədər` |
| hotseatStart | `Oyuna başla` |

Defaults: hide screen ON, flip board ON, undo OFF. Mock names: Elvin / Nigar.

### 9.2 18.2 Hand the phone over (Telefonu rəqibə ver)
Shown between turns when "hide between turns" is ON; hides the board.
- Background radial `80% 50% at 50% 45%: #4a321f → #2B1D14 55% → #120c08` + full-screen lattice (60°/−60° at `rgba(212,174,88,.07)`, 18px) (no tokens).
- Center column (centered, padding H28, gap 16, text centered):
  1. Checker 120 Ø in the next player's color (mock onyx `#2b2724`), shadow `inset 0 −8 0 rgba(0,0,0,.35)`, ring 4px `rgba(212,174,88,.5)`, drop `0 20 40 rgba(0,0,0,.5)`.
  2. Overline `NÖVBƏ DƏYİŞDİ` Plex 12 600, letterSpacing .08em, `c.accent`, margin-top 10.
  3. Title `Telefonu Nigar-a ver` Noto Serif 32/38 600 (no token).
  4. Body Plex 15/22 `rgba(243,235,221,.7)`: `Qara daşlar. Elvin son gedişi etdi: 24/18 18/13. Taxta Nigar tərəfə çevriləcək.` (move list in standard notation; last sentence only when flip is ON — inferred).
- Footer padding H16 B40, gap 10: primary h 56 pill `Nigar, hazıram` (Plex 16 600) → reveals board for Nigar · ghost h 48 Plex 15 600 `rgba(243,235,221,.7)` `Elvin: gedişi geri al` → only when "allow undo" is ON (inferred), undoes the previous player's turn.

| key suggestion | az text |
|---|---|
| handoffOverline | `NÖVBƏ DƏYİŞDİ` |
| handoffTitle | `Telefonu {name}-a ver` (`-a/-ə` vowel harmony!) |
| handoffBody | `{side}. {prevName} son gedişi etdi: {moves}. Taxta {name} tərəfə çevriləcək.` |
| handoffSideWhite / handoffSideBlack | `Ağ daşlar` / `Qara daşlar` (reuse hotseat keys) |
| handoffReady | `{name}, hazıram` |
| handoffUndo | `{prevName}: gedişi geri al` |

---

## 10. Rules messages (Ekranlar 8, section "Oyun ekranı · BOT · Crawford · Uzun nərd qaydaları")

These mocks use a **simplified GameScreen** (player cards h 66 with a 44 avatar + 1.5px `rgba(212,174,88,.6)` ring, name Plex 16 600, meta `Platin I · 1867 · pip 151`, clock box h 36 min-w 70 radius 10; opponent card in `c.surface` + `c.line`, my card `rgba(243,235,221,.04)` + `rgba(212,174,88,.2)`; no control bar, 24 pt spacer). Treat GameScreen (§1/§3) as canonical and take only the new elements below. Board = `walnut`, 378 wide.

### 10.1 23.1 Crawford indicator
- Chip under the top bar, centered, padding-bottom 6: h 28, padding H12, pill, bg `rgba(212,174,88,.14)`, 1px ring `rgba(212,174,88,.5)` (no tokens), gap 8, Plex 12 600 `c.accentHi`. Icon: 14×14 radius 3 square, 1.5px `c.accentHi` stroke + diagonal slash (crossed cube; Lucide closest `square-slash`).
- Text: `Crawford oyunu · kub yoxdur`.
- Cube hidden on board; İkiqat button hidden. Banner: `Sənin növbən` / `Rəqibə 1 xal qalıb`. Mode label `Matç · 7 xala qədər`, score `6 – 4`.

### 10.2 23.2 Long Nard head rule / 10.3 23.3 six-block
- Banner: dot `c.dangerText`, title `Qeyri-qanuni gediş`, sub = dice `5 – 2` / `3 – 1` (`c.textDim`).
- Board: selected checker (23.2: head point 24; 23.3: point 16). 23.3 also marks the illegal target point 13: red triangle overlay, red dashed ghost, red point number (§2.1-7/8/13).
- **Error toast** over the board bottom: absolute left 24, right 24, bottom −14 (overlaps the board's lower edge); padding V12 H14; radius 14 (`c.cardRadius`); bg `c.surfaceRaised`; 1.5px inset `c.dangerText` ring + `0 12 30 rgba(0,0,0,.55)`; row gap 12, top-aligned:
  - icon disc 26 Ø `c.danger` with `x` 14 (stroke 3.5, `c.text`);
  - column gap 3: title Plex 14 600 `#F3B0BC` (no token); body Plex 12/17 `rgba(243,235,221,.75)`.
- Trigger (inferred): user attempts an illegal move → engine `MoveRejection` reason → toast; dismiss on next valid action / timeout (not specified).

| key suggestion | az text |
|---|---|
| crawfordChip | `Crawford oyunu · kub yoxdur` |
| bannerOpponentNeedsOne | `Rəqibə 1 xal qalıb` |
| gameModeMatchTo | `Matç · {points} xala qədər` |
| bannerIllegalMove | `Qeyri-qanuni gediş` |
| ruleHeadTitle | `Başdan yalnız bir daş götürmək olar` |
| ruleHeadBody | `Bu növbədə başdan artıq bir daş oynadın. İstisna: ilk atışda 6-6, 4-4 və ya 3-3 düşəndə iki daş götürmək olar.` |
| ruleSixBlockTitle | `Ardıcıl 6 xananı bağlamaq olmaz` |
| ruleSixBlockBody | `{from} → {to} gedişi {high}–{low} xanalarında 6 xanalıq sədd qurur, qabağında isə rəqibin heç bir daşı yoxdur. Başqa gediş seç.` (mock: `16 → 13 gedişi 18–13 xanalarında …`) |

(For reference, the BOT mock 20.2 in the same section uses `Təsadüfi · reytinqsiz`, `Kompüter · Orta`, `BOT` badge, `Reytinqə təsir etmir · pip 158`, `6 – 2 · 2 gediş`, opponent clock `—` — not in scope, but confirms the "no clock → `—`" hint in §1.4.)

---

## 11. Open questions / ambiguities

1. **Board frame inlay**: sebeke GameScreen renders the `xatam` board (xatəm inlay around both fields, garnet dark points); readme says sebeke = "xatəm-inlay board frame"; ROADMAP/cosmetic default = `walnut` (Ekranlar 8 mocks use plain walnut). Decide: plain walnut, or walnut + inlay as a UI-theme decoration.
2. **Owned-cube position** not drawn (only centered at 64 and the offer). Suggest: cube at top/bottom end of the tray gap toward the owner.
3. **Doubles**: only 2 dice are drawn; no 4-dice layout, no per-die "used" state.
4. **Pass & play perspective**: mocks assume local = ivory at the bottom. With "Taxtanı çevir" the bottom player changes color — renderer must take colors per side, not "me = ivory". Without flip, whose view is fixed is unspecified.
5. **Banner wording in pass & play / vs bot** (`Rəqib düşünür` fits bot; for pass & play the handoff screen replaces it, or a `{name}-in növbəsi` string is needed — not designed).
6. **Azerbaijani suffixes** in `{name}-dən`, `{name}-a ver`, `{rank}-ə`: vowel harmony depends on the name → need a suffix helper or neutral rephrasing (also for RU/TR).
7. **Sheet colors/radii differ**: cube sheet radius 22 all corners, bg `#2a1a20`, no handle; resign/menu sheets 24/42 radius, bg `#34251a` (ceviz walnut800) with handle. Recommend one custom sheet with `c.surfaceRaised`.
8. **Button radius**: sebeke is pill, but 2.6/2.8 secondary buttons use radius 14. Primary heights: 62 (control bar), 56 (CTAs), 54 (sheets), 52/50 (result buttons) vs tokens 56/48/40.
9. **Pressed style**: readme says "scale .97, no color flash"; DS card shows color changes for pressed variants.
10. **Loss / single-game / koks** variants of the won card and 2.6 match result are not designed; and whether 2.6 replaces §6.3 at match end (DS: "match end screen = 2.6").
11. **`Təhlil`** (analysis, Phase 6) and **`Replayı paylaş`** on result screens: Phase 2 has a local replay viewer (ADR-017) — replace with a "view replay" action? (needs a new string).
12. **18.1 setup** lacks match length / cube toggle / Long-vs-Short already there; reuse 2.2 setup options? Background `#1b120c` vs sebeke gradient.
13. **When do opponent last-move markers clear** (after my first move or at end of my turn)?
14. **Resign options**: should Mars/Koks rows be disabled when not reachable, and is Koks offered in Long Nard? Not specified.
15. Error toast duration and the no-moves auto-pass delay (mock: 2 s) are not tokenized.
16. Clocks (Phase 3): hide vs `—` placeholder offline (§1.4).
