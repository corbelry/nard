# Screens: implementation spec (Phase 2 offline MVP)

Source: `.claude/skills/nardarena-design` (`Ekranlar 2`, `Ekranlar 6`, `TabBar`,
`StatusBar`, `NardArena Dizayn Sistemi`, `components/core/*.jsx`, `tokens/*.css`).
In-game screens (GameScreen, 2.6 result, 2.8 resign, 2.9 game menu, board) are
specified in `game.md`. Frame is 390×844 pt portrait. All values are logical px.

---

## 0. Conventions used in this file

**Color aliases.** The mocks were exported with the `ceviz` brass value `#C9A24A`
for rings and tints, even on sebeke screens. Map them to the theme accent so
other themes keep working:

| Alias in this doc | Flutter | Mock raw value |
|---|---|---|
| `text` | `context.nard.text` | `#F3EBDD` |
| `text@a` | `context.nard.text.withValues(alpha: a)` | `rgba(243,235,221,a)` |
| `dim` | `context.nard.textDim` (sebeke .66) | `rgba(243,235,221,.64)` |
| `accent` | `context.nard.accent` (sebeke `#D4AE58`) | `#C9A24A` |
| `accent@a` | `context.nard.accent.withValues(alpha: a)` | `rgba(201,162,74,a)` |
| `accentHi` | `context.nard.accentHi` (`#E8C468`) | `#E8C468` |
| `line` | `context.nard.line` (sebeke `D4AE58@.32`) | `rgba(201,162,74,.24)` |
| `surfaceRaised` | `context.nard.surfaceRaised` (sebeke `#2A1A20`) | `#34251A` (walnut800) |
| `dangerText` | `context.nard.dangerText` (`#E0566C`) | `#E0566C` |
| `success` / `successText` | `context.nard.success` / `.successText` | `#1F8A5B` / `#3FB57F` |
| `ivory100` | `NardPalette.ivory100` (fixed, theme-independent) | `#F3EBDD` |
| `walnut900` | `NardPalette.walnut900` | `#2B1D14` |

**Type.** `NardType.*` + overrides. Overline = `NardType.caption.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.72)` (12px, 0.06em), referred to below as **overline**. Numbers always use tabular figures (`FontFeature.tabularFigures()`).
Sizes with no exact token are given as `token.copyWith(fontSize: x)` and marked *(no token)*.

**Uppercase.** Overline strings are stored **already uppercased** in ARB (`VARİANT`, `ÜMUMİ`). Never call `toUpperCase()`: Dart is not locale-aware and turns `i` into `I` instead of `İ` for az/tr.

**Rings.** Every "ring" is an inside 1px (or 1.5px) border: `Border.all(color, width, strokeAlign: BorderSide.strokeAlignInside)`. Resting cards have no shadow.

**Spacing.** Screen gutter `NardSpace.screenGutter` (16). Hit targets ≥ `NardSpace.hitMin` (44).

**Press.** All tappables: scale `NardMotion.pressScale` (0.97) over `NardMotion.press` (90ms), curve `NardMotion.standard`, no ripple, no color flash (`NoSplash` is set in `NardTheme`).

---

## 1. Screen chrome (all menu screens)

### 1.1 Sebeke background (default theme)
1. **Base gradient** (full screen, behind everything, does not scroll):
   `LinearGradient(begin: topCenter, end: bottomCenter, colors: [0xFF24161B, 0xFF17121A, 0xFF1F1317], stops: [0, .5, 1])`.
   *No token* — add `bgGradient` to `NardColors` (ceviz: `RadialGradient(center: Alignment(0, -0.08), radius ≈ 1.3, colors: [#3B2819, #2B1D14 @.5, #1B120C])`; komur/light: flat `bg`). Mid stop equals sebeke `bgDeep`.
2. **Şəbəkə lattice band** (sebeke only; other themes: none): a `CustomPainter` layer, fixed to the top of the screen (starts at y=0, under the status bar), full width, **300pt tall**, `IgnorePointer`, above the gradient and below content. Three line families, each 1px wide:
   - lines at **+60°** to the horizontal, perpendicular spacing **18px**, color `accent@.11` (raw `rgba(212,174,88,.11)`);
   - lines at **−60°**, spacing **18px**, `accent@.11`;
   - **horizontal** lines, spacing **15.6px**, `accent@.06`.
   Fade: multiply the whole layer by a vertical mask, opaque at y=0 → transparent at y=300 (linear). Flutter: `ShaderMask(blendMode: BlendMode.dstIn, shaderCallback: LinearGradient(topCenter→bottomCenter, [white, transparent]))`. Line phase is not significant. Token source: `tokens/themes.css --ornament-pattern` (no Dart token; add `ornamentBand: bool` or a painter keyed on theme id).
   Note: the 2.x/9.x/10.x mocks omit the band; the readme and GameScreen 1c draw it on every sebeke screen. **Draw it on all sebeke menu screens** except Splash (own background) and Lesson (board-centric; optional).
3. Ceviz equivalent (for reference only): `radial-gradient(80% 60% at 50% 0%, accent@.12, transparent 70%)` in the same 300pt band.

### 1.2 Status bar (`StatusBar.dc.html`)
System status bar, not drawn by the app. Mock height 50 (iPhone island). Use `SafeArea(top)`; edge-to-edge with transparent status bar; `SystemUiOverlayStyle.light` on dark themes (`dark` on `light`). Content under it starts directly at the safe inset.

### 1.3 Screen header (sub-screens: 2.2, 2.3)
Row, height 52, padding h 16, gap 12:
- Back button: 40×40, radius `NardRadius.m` (12), ring 1px `line`, icon `chevron-left` 18, stroke 2, color `text`. (The design-system IconButton is 44×44; use a 44×44 hit area around the 40 visual.)
- Title: `NardType.title.copyWith(fontSize: 22)` *(no token)*, `text`, sentence case.
Variant without box (10.1): height 46, bare `chevron-left` 20 icon, title `NardType.title` (19).

Root titles (10.2, 11.x): `NardType.displayL.copyWith(fontSize: 26)` *(no token)*, padding `4 16 8` (10.2) / `4 16 12` (11.x), no back button.

### 1.4 Bottom CTA zone (non-tab screens)
Padding `0 16 40` (2.2, 2.3, 9.2) or `16 16 40` (9.3). The 40 includes the 34pt home indicator: use `bottom = max(40, safeBottom + 6)`.

---

## 2. Shared components

### 2.1 Button
Sizes (component): **l 56** (`NardSpace.hitPrimary`), **m 48**, **s 40**. Padding h 20, gap 10 (label + optional `sub`). Label: `NardType.labelL` (l/m), `NardType.labelM` (s). Optional `sub` text: `NardType.bodyS`, opacity .75, tabular.
Screen mocks also use 58 (setup/AI CTA), 64 (home hero "Oyna"), 52/54/46 (secondary). **Snap 58→56, 52/54→48**; keep 64 as a dedicated `hero` size.

| Variant | Fill | Ring / shadow | Label color | Pressed | Disabled |
|---|---|---|---|---|---|
| **primary (sebeke)** | `context.nard.primaryFill` (`#B52A45 → #9E1B32 @.6 → #86152A`, top→bottom) | inner ring 1px `rgba(212,174,88,.65)` (= accent `#D4AE58`@.65) **+** glow `BoxShadow(color: 0x599E1B32, offset (0,6), blur 18)` *(no token: add `primaryShadow`)* | `context.nard.primaryText` `#F8F1E4` | scale .97 only | fill `context.nard.surface`, ring 1px `line`, label `text@.45` (`--text-faint`, no token); no glow |
| **secondary** | transparent | ring 1.5px `accent` | `accent` | fill `accent@.16`, label `accentHi`, scale .97 | ring 1px `accent@.2`, label `text@.4` |
| **outline** (neutral; "Ləğv et", "Kodu kopyala") | transparent | ring 1px `line` (mock `accent@.3`) | `text` | scale .97 | label `text@.4` |
| **ghost** | transparent | none | `text` | fill `text@.08`, scale .97 | label `text@.4` |
| **danger** | `context.nard.danger` `#9E1B32` | none | `#FBEFEF` *(no token)* | fill `#7F1428` *(no token)*, scale .97 | fill `danger@.25`, label `#FBEFEF@.45` |

Radius: primary = `context.nard.buttonRadius` (sebeke pill 999; ceviz/light 16; komur 8). **Non-primary buttons in every sebeke screen mock use radius 14 (= `cardRadius`)**, although `Button.jsx` uses `--radius-button` for all; follow the mocks (`cardRadius`) and flag in §8.
Label font: sebeke = **Noto Serif Display** (`--font-button: display`, GameScreen 1c: 600 17/20, letterSpacing 0.17 = .01em); other themes IBM Plex Sans; komur uppercases + 0.08em tracking (`uppercaseLabels`). *No token for button font*: add `buttonFont` to `NardColors` or derive from theme id. (2.2/2.3/9.x mocks render CTAs in Plex; treat as export inconsistency.)
Labels never wrap (ellipsis); one primary per screen.

### 2.2 Icon button
44×44 (min), radius `NardRadius.m` (12) or circle, ring 1px `line`, icon 20 stroke 2 `text` (accent tone: `accent`; danger tone: `dangerText`). With caption (in-game only): 66×60, caption `NardType.micro` `dim`.

### 2.3 Chip (filter/mode)
Height 34, padding h 14, radius pill, text 13 (`NardType.caption.copyWith(fontSize: 13)`), weight 500 → 600 when selected.
Unselected: transparent, ring 1px `line`, text `text`. Selected: fill `accent@.18`, ring 1px `accent` (`--ring-accent` is 1.5px in the jsx; card shows 1px; use 1.5 for consistency with other selections), text `accentHi`.

### 2.4 Option tile (setup choices; not the Chip)
- **Format tile** (2.2): flex 1, height 44, radius 12, label 14 w500 centered. Unselected ring 1px `line`. Selected fill `accent@.18`, ring 1.5px `accent`, label `accentHi` w600.
- **Time tile** (2.2): 2-col grid gap 8, height 72, radius 14, padding `12 14`, column space-between: name 14 w600, value `NardType.bodyS` `dim` tabular. Unselected fill `text@.05`, ring 1px `accent@.18`, name `text`. Selected fill `accent@.16`, ring 1.5px `accent`, name `accentHi`.

### 2.5 SegmentedControl
Container: padding 4, radius 14, fill `Colors.black@.25` (`--surface-sunken`, *no token*), ring 1px `accent@.16` (`--line-soft`, *no token*). Segments: flex 1, radius 10, label `NardType.labelM` (15/600; DS card uses 14).
Height: **44** in 2.2 (DS card/jsx: 40). Use 44 (hit target).
Selected: fill `ivory100`, label `walnut900` (fixed palette, not themed). Unselected: transparent, label `text@.75` (jsx: `dim`). Animate the selected pill with `NardMotion.fast` / `standard`.

### 2.6 Switch
Two sizes in the mocks:
- **Default** (DS, 2.2, 2.3): track 48×28 pill; thumb 22, inset 3 (left 3 off / 23 on).
- **Compact** (10.2 Settings rows): track 44×26; thumb 20, top 3, left 3 off / 21 on.
On: track `accent`, thumb `context.nard.bg` (mock `#2B1D14`). Off: track `text@.14`, thumb `ivory100`. Transition `NardMotion.fast` (160ms) `standard`. Not a Material switch (no thumb icon, no outline); `NardTheme.switchTheme` colors already match if you prefer to style the Material one.
Always paired with a row label; semantics `role=switch` with the label.

### 2.7 Radio indicator (language, resign, variant rows)
22 circle, ring 2px: selected `accent`, unselected `text@.3` (resign: `.35`). Inner dot 10, `accent` when selected, else none.

### 2.8 Cards (resting, no shadow)
| Kind | Radius | Fill | Ring | Used in |
|---|---|---|---|---|
| Tile | 14 (`cardRadius`) | `text@.05` | 1px `accent@.18` | home mode grid, time tiles |
| Group card (list container) | 16 (`NardRadius.l`) | `text@.04` | 1px `accent@.14` | settings groups |
| Selectable card | 16 (rows) / 18 (variant cards, *no token*) | unselected `text@.04`, selected `accent@.12` (AI rows: `.05` / `.16`) | unselected 1px `accent@.16` (AI: `.18`); selected **1.5px `accent`** | 9.2, 9.3, 2.3 |
| Raised card | 18 *(no token)* | `surfaceRaised` (mock walnut800) | 1px `line` | coach bubble, result cards |
| Hero card | 24 (`NardRadius.xl`) | see 2.1 Home | 1px `accent@.35` | home |
Readme rule: card = surface tint + 1px brass hairline, radius `cardRadius`. Sebeke token `surface` is garnet@.18 (`#2E9E1B32`); the menu mocks use ivory tints instead. Use the mock tints (`text@.04/.05`) for menu cards; keep `context.nard.surface` for in-game player cards and disabled buttons.

### 2.9 List rows
- **Settings row** (inside group card): min-height 48, padding h 14, gap 12; label `NardType.body` (15) `text` flex; trailing either compact Switch, or value text 14 `text@.6` + `chevron-right` 14 (stroke 2.5, `text@.5`). Divider: 1px `accent@.08` at row bottom; omit on the last row (mock draws it; clipped by card).
- **Toggle row** (2.2/2.3, no card): padding v 14 (2.3 adds h 4), label 15 `text`; optional sub-line 12 `text@.6`, gap 3; trailing default Switch. List top border 1px `accent@.14`; each row bottom border 1px `accent@.1`.
- **Radio row** (9.2): height 64, radius 16, padding h 16, gap 14: leading swatch, column (title 16 w600, sub 12 `text@.6`, gap 2), trailing radio (2.7). Selectable card colors (2.8).

### 2.10 Section overline
**overline** style, color `dim` (2.2: `.64`; 10.2: `text@.55`, padding-left 4). Gap to its content: 10 (2.2), 6 (10.2). Step overline (9.3): 12 w600, letterSpacing 0.96 (.08em), color `accent`.

### 2.11 Divider ornament (diamond-and-hairline)
Centered row, gap 8: hairline 40×1 `accent` · diamond 6×6 rotated 45°, 1px `accent` outline · diamond 8×8 rotated 45°, filled `accent` · diamond 6×6 outline · hairline 40×1. (Guideline card: hairlines 44.) Used above celebration titles (2.6, see game.md); available for section breaks. Compact in-game variant (StatusBanner): hairline 28×1 `line` + 5×5 filled diamond `accent`@.7.

### 2.12 Progress bar
Height 4 (rank: 6), radius h/2, track `text@.12`, fill `accent` (success: `successText`). Splash: 3px, width 120, track `text@.12`.

---

## 3. TabBar (`TabBar.dc.html`)
Height 86 = padding top 8 + item 52 + bottom 26 (bottom = home-indicator zone; use `max(8, safeBottom − 8)`), padding h 8.
Background: `LinearGradient(top→bottom, [bgDeep@0, bgDeep @30%])` (mock `#1B120C`; use `context.nard.bgDeep`). Top border 1px `accent@.16` (`--line-soft`).
Items: equal flex, height 52, column centered, gap 4: icon 22 stroke 2 round caps; label `NardType.micro` (11, mock line-height 12). Active: color `accentHi`, label w600. Inactive: `text@.6` (`dim`), w500. No indicator pill, no ripple.

| key | az label | Lucide | Phase |
|---|---|---|---|
| home | Əsas | `house` | **2** |
| tour | Turnirlər | `trophy` | 6, omit |
| clan | Klan | `shield` | 5, omit |
| store | Mağaza | `shopping-bag` | 4, omit |
| profile | Profil | `user` | **2** (opens Settings 10.2; Profile+stats is Phase 3) |

**Phase 2: show 2 tabs, Əsas and Profil.** 10.2 Settings is drawn with `active="profile"`, so settings is the Profil tab's root until 8.1 Profile ships. Alternative (not recommended): show all 5 and render the 11.1 offline state in Turnirlər/Klan/Mağaza. TabBar appears only on tab roots (Home, Settings), never on pushed screens.

---

## 4. Screens

### 9.1 Splash
Purpose: brand while the app boots (load prefs, fonts, AI). No status bar content, no tab bar.
- Background (*no token*): elliptical radial gradient, center (50%, 45%) = `Alignment(0, -0.1)`, radii 80% of width × 50% of height (CSS `80% 50% at 50% 45%`; in Flutter use a `RadialGradient` with a `GradientTransform` that scales y), stops `#4A321F` 0 → `#2B1D14` .55 → `#120C08` 1. Same on every theme.
- Lattice overlay (full screen): ±60° lines only, 1px, spacing 22, `accent@.06` (raw `rgba(201,162,74,.06)`), masked by a radial fade centered at (50%, 45%): opaque at center → transparent at 60% radius.
- Center column, gap 22, centered vertically:
  - Mark: 64×64 square rotated 45°, border 6 `accent` (raw `#C9A24A`), inner filled square 16×16 `accentHi`.
  - Wordmark: "Nard" `NardType.displayXl` (Noto 40, height 1, w600, `text`) + "Arena" same size, **italic w500**, color `accent`. Needs Noto Serif Display italic 500 asset.
- Progress: bottom 70, centered, 120×3, radius 2, track `text@.12`, fill `accent` (determinate; mock 40%).
- Exit: fade to 9.2 on first launch, else Home; no minimum display time specified (suggest ≤ 1s after ready). Logo is a placeholder (readme).
- Strings: none localizable (brand "NardArena" constant).

### 9.2 Language picker
Purpose: first-launch language choice; also opened from Settings › Dil (then: no CTA step, back button, apply on tap).
Layout (padding `60 16 0`, column gap 10):
1. Title `NardType.displayL.copyWith(fontSize: 30, height: 36/30)` *(no token; displayL is 28/34)*, padding-bottom 4.
2. Subtitle 14 `dim`, padding-bottom 18.
3. 4 radio rows (2.9): leading flag swatch 28×19, radius 3, outer ring 1px `black@.3`; title = endonym (16 w600), sub = English name (12 `text@.6`). Default selection = device locale if supported, else az.
   Flag swatches (drawn, placeholders): AZ 3 horizontal bands `#00B5E2/#EF3340/#509E2F`; TR `#E30A17` with white disc at 42% x; RU bands white/`#1C3578`/`#E4181C`; EN top half `#1C3578`, bottom `#E4181C`. These are simplified; consider real flag assets.
4. Spacer; CTA primary l "Davam et" (1.4) → 9.3. Selection applies the locale immediately (live preview).

| key | az |
|---|---|
| languageTitle | Dil seçin |
| languageSubtitle | Choose language · Выберите язык · Dil seçin *(same in every locale)* |
| languageNameAz / Tr / Ru / En | Azərbaycanca / Türkçe / Русский / English *(endonyms, not translated)* |
| languageSubAz / Tr / Ru / En | Azerbaijani / Turkish / Russian / İngilis *(mock is inconsistent: "İngilis" is az; use "English"? see §8)* |

### 9.3 "Which nard do you play?"
Purpose: pick default variant, or start the lesson.
Layout (padding `40 16 0`, gap 12):
1. Step overline (2.10) `accent`: "ADDIM 2 / 3".
2. Title `NardType.displayL` (28/34), padding-bottom 12.
3. 3 selectable cards (radius 18, 2.8). Selected card expands: board preview on top (padding-top 14, centered, **240 wide** board rendered with `BoardGeometry` landscape space 640×460 → 240×172.5, theme `walnut` (default cosmetic), variant start position, no dice, cube hidden for Uzun nərd), then text block padding `14 16`, gap 3: name `NardType.title` (19), description `NardType.bodyS` (13/18) `dim`. Collapsed cards show only the text block. Animate expand with `NardMotion.standard`, 220–320ms.
4. CTA primary l "Davam et", zone padding `16 16 40`.
Navigation: Qısa/Uzun → save default variant → Home (Phase 2; 9.4 sign-in is Phase 3). "Öyrənmək istəyirəm" → 9.5 Lesson; lesson end → Home.

| key | az |
|---|---|
| onboardingStep | ADDIM {current} / {total} *(mock "ADDIM 2 / 3"; offline flow has 2 steps → "2 / 2")* |
| variantQuestionTitle | Hansı nərdi oynayırsan? |
| variantShortDesc | Klassik backgammon: vurmaq, bar, ikiqat kub. |
| variantLongDesc | Bütün daşlar başda. Vurmaq yoxdur, yalnız bloklamaq. |
| variantLearnTitle | Öyrənmək istəyirəm |
| variantLearnDesc | 7 addımlıq interaktiv dərs, 5 dəqiqə. |
(`variantShort` / `variantLong` names: common table.)

### 9.5 Interactive lesson (skeleton)
Purpose: 7-step guided tutorial on a live board; only step 2 is designed.
Layout (column):
1. Top row, padding `4 16 0`, gap 12: "Keç" text button 15 `text@.7` (skip → confirm-free exit to Home) · progress: 7 segments, flex, gap 4, height 4, radius 2, done `accent`, rest `text@.15` · counter "2/7" 13 `text@.6` tabular.
2. Middle (flex, vertically centered, gap 18):
   - Board 378 wide (portrait space 640×566 → 378×334), theme walnut, scripted position, dice shown (mock [6,1]), selected point (13) with select ring, legal target highlighted (7) using `BoardOverlay` colors. Only the scripted move is accepted.
   - Coach bubble: margin h 16, padding `16 18`, radius 18 *(no token)*, fill `surfaceRaised`, ring 1px `accent@.35`, shadow `0 10 30 black@.4` (floating; *no token*, near `--elev-2`). Tail: 14×14 square rotated 45° at top −8, left 56, same fill, ring only on its top-left edges. Row gap 14: avatar 40 circle placeholder (diagonal stripes `text@.08`, ring 1.5 `accent`; coach art TBD) · column gap 5: title `NardType.title.copyWith(fontSize: 17)` *(no token)*, body 14/20 `text@.75`.
3. Bottom spacer 40.
Behavior: on correct move → auto-advance to next step. Completion of step 7 → Home. Step content for steps 1, 3–7 is not designed (see §8); keep steps data-driven (title, body, position, dice, allowed move).

| key | az |
|---|---|
| lessonSkip | Keç |
| lessonProgress | {current}/{total} |
| lessonStep2Title | Daşı 6 xana irəli apar |
| lessonStep2Body | Zər 6 göstərir. 13-cü xanadakı daşa toxun, sonra işıqlanan 7-ci xanaya toxun və ya sürüşdür. |

### 2.1 Home (offline parts)
Purpose: start a game. Tab root (Əsas).
Design layout (padding `6 16 0`, gap 16), with Phase 2 decision:
1. ~~Profile row~~ (avatar 48 with conic brass ring, name, rank hexagon, "Platin II · 1842", "Səv. 24" + XP bar). **Omit**: rating Phase 3, level/XP Phase 4, no local nickname.
2. ~~Currency pills (coins "12 450", yaqut "320") + bell with garnet dot~~. **Omit** (Phase 4 / 7).
3. **Hero card** (keep): radius 24, padding `22 20 20`, column gap 16, clip.
   - Fill: `LinearGradient(160°, [accent@.22, accent@.04 @60%])` over `surfaceRaised` (mock walnut800 `#34251A`). Ring 1px `accent@.35`.
   - Decorative lattice: 160×160 at right −30, top −30; ±60° lines 1px, spacing 16, `accent@.12`; radial mask (opaque center → transparent 70%).
   - Overline (caption, 0.06em, `dim`, w500): mock "QISA NƏRD · REYTİNQLİ · 3+12s". Phase 2: "{VARIANT} · {FORMAT}" e.g. "QISA NƏRD · 5 XALA QƏDƏR" (vocabulary from the DS caption sample).
   - Second line `NardType.labelM` (15/600) `text@.85`: mock "Onlayn: 4 218 oyunçu" (online, omit). Phase 2: "Kompüterə qarşı · {level}".
   - **Oyna** button: height 64 (hero size), pill, primary sebeke fill + ring + glow, label Noto Serif Display 26 w600, letterSpacing 1.04 (.04em), `primaryText`.
   - Footer row, space-between, 12 `dim`: "Rejimi dəyiş" (left) · "{other variant} →" in `accentHi` (right; tap toggles variant). Whole row tappable (≥44 high hit area).
4. **Mode grid**: design = 4 columns, gap 8; tile height 74, radius 14, fill `text@.05`, ring 1px `accent@.18`, column centered gap 7: icon 22 stroke 2 `accent`, label `NardType.micro` (11/13, w500) centered, may wrap to 2 lines.
   | Tile | Lucide | Phase 2 |
   |---|---|---|
   | Adi (online casual) | `dice-3` | omit (3) |
   | Kompüter | `monitor` | **keep** → 2.2 (vs computer) |
   | Bir cihazda | `smartphone` | **keep** → 18.1 pass & play setup (Ekranlar 8; spec not in this file) |
   | Şəxsi otaq | `lock` | omit (5) |
   Phase 2: 2 tiles in a 2-column grid, same tile style.
5. ~~Live tournament card~~ (6), ~~daily mission / season cards~~ (4/6): omit.
6. TabBar (§3), active `home`.
Navigation: Oyna → start vs computer with last-used settings (first run: onboarding variant, Orta, 1 oyun); hero footer toggles variant; tiles as above.

| key | az |
|---|---|
| homePlay | Oyna |
| homeChangeMode | Rejimi dəyiş |
| homeOtherVariant | {variant} → |
| homeHeroMeta | {VARIANT} · {FORMAT} *(proposal; uppercase pieces from ARB, e.g. QISA NƏRD, UZUN NƏRD, 1 OYUN, {n} XALA QƏDƏR)* |
| homeHeroMode | Kompüterə qarşı · {level} *(proposal)* |
| modeComputer | Kompüter |
| modeSameDevice | Bir cihazda |
| *(later)* modeCasual, modePrivateRoom | Adi, Şəxsi otaq |

### 2.2 Game setup ("Yeni oyun")
Purpose: choose variant, match length, cube before a vs-computer game. Pushed screen, no tab bar.
Layout: header (1.3) "Yeni oyun"; content padding `10 16`, gap 22:
1. Overline "VARİANT" + SegmentedControl (2.5, h 44): Qısa nərd | Uzun nərd.
2. Overline "FORMAT" + row of 4 format tiles (2.4), gap 8: "1 oyun", "3 xal", "5 xal", "7 xal" (mock selection: 5 xal).
3. ~~Overline "VAXT NƏZARƏTİ" + 2×2 time tiles: Blits "1 dəq + 8s", Sürətli "3 dəq + 12s", Klassik "5 dəq + 15s", Gündəlik "24 saat / gediş"~~. **Omit in Phase 2** (clocks are an online feature; Gündəlik is correspondence). Keep the tile component for later.
4. Toggle list (2.9): ~~"Reytinqli" / "±1842 · 150 xal aralıq"~~ (Phase 3, omit) · **"İkiqat kub"** default Switch (on). Hide the cube row when Uzun nərd is selected (no cube in Long Nard).
5. CTA primary (mock 58 → 56): mock "Rəqib axtar" (online). Phase 2: **"Davam et"** → 2.3.
Persist last choices.

| key | az |
|---|---|
| setupTitle | Yeni oyun |
| setupVariantLabel | VARİANT |
| setupFormatLabel | FORMAT |
| formatOneGame | 1 oyun |
| formatPoints | {n} xal *(3, 5, 7)* |
| setupCube | İkiqat kub |
| *(later)* setupTimeLabel, timeBlitz/Rapid/Classic/Daily + values, setupRated, setupRatedSub, setupFindOpponent | VAXT NƏZARƏTİ · Blits · 1 dəq + 8s · Sürətli · 3 dəq + 12s · Klassik · 5 dəq + 15s · Gündəlik · 24 saat / gediş · Reytinqli · ±1842 · 150 xal aralıq · Rəqib axtar |

### 2.3 Vs computer: AI level
Purpose: pick bot strength and hints, then start. Pushed screen.
Layout: header (1.3) "Kompüterə qarşı"; content padding `10 16`, gap 8:
1. 6 level rows: padding 14, radius 16, row gap 14. Selected: fill `accent@.16`, ring 1.5px `accent`. Unselected: fill `text@.05`, ring 1px `accent@.18`. Locked: whole row opacity .55, not tappable.
   - Strength meter: fixed width 62, 6 bars, gap 3, each 7 wide, heights 8/12/16/20/24/28 (bottom-aligned), radius 2; bar k filled `accent` if k ≤ level index, else `text@.15`.
   - Column (flex, gap 3): name 16 w600 `text` (stays `text` even when selected); description 12/16 `dim`.
   - Trailing: playable → "~{elo}" 12 `dim` tabular; locked → pill height 26, padding h 10, radius pill, fill `black@.3`, ring 1px `accent@.3`, gap 6: `lock` icon 12 (stroke 2.5) + "Tezliklə" 12 w600 `text@.8`.
   | # | Name | Description | Trailing | Phase 2 |
   |---|---|---|---|---|
   | 0 | Başlanğıc | Qaydaları öyrənənlər üçün | ~800 | playable (nard_ai Beginner) |
   | 1 | Həvəskar | Sadə səhvlər edir | ~1100 | playable |
   | 2 | Orta | Əsas strategiyanı bilir | ~1400 | playable |
   | 3 | Güclü | Nadir səhv, kubu düzgün işlədir | ~1700 | playable (Hard) |
   | 4 | Usta | Klub oyunçusu səviyyəsi | Tezliklə | locked |
   | 5 | Qrossmeyster | Ən güclü rejim, səhv etmir | Tezliklə | locked |
2. Toggle row (padding `14 4`): "İpuçlarını göstər", default Switch (mock off).
3. CTA primary (56): "Başla · {level}" (mock "Başla · Güclü") → GameScreen (game.md) with variant/format/cube from 2.2.

| key | az |
|---|---|
| aiTitle | Kompüterə qarşı |
| aiLevelBeginner / Amateur / Medium / Strong / Master / Grandmaster | Başlanğıc / Həvəskar / Orta / Güclü / Usta / Qrossmeyster |
| aiLevelBeginnerDesc | Qaydaları öyrənənlər üçün |
| aiLevelAmateurDesc | Sadə səhvlər edir |
| aiLevelMediumDesc | Əsas strategiyanı bilir |
| aiLevelStrongDesc | Nadir səhv, kubu düzgün işlədir |
| aiLevelMasterDesc | Klub oyunçusu səviyyəsi |
| aiLevelGrandmasterDesc | Ən güclü rejim, səhv etmir |
| aiElo | ~{elo} |
| aiShowHints | İpuçlarını göstər |
| aiStart | Başla · {level} |
(`comingSoon` "Tezliklə": common.)

### 10.1 Replay viewer (from "Təhlil və replay")
Purpose: step through a finished local game. Entry: 2.6 match result "Təhlil" (game.md). Pushed screen. Mock background flat `#1B120C` (walnut950, ceviz `bgDeep`); use the theme background (§1.1) instead.
Layout:
1. Header (1.3 bare variant, h 46, padding h 16, gap 12): `chevron-left` 20 · title "Təhlil · Oyun {n}" `NardType.title` flex · players "{p1} – {p2}" 12 `text@.6`, ellipsis.
2. ~~Equity bar row ("Ekvitet", bar, "+0.24")~~: Phase 6, omit.
3. Board: 378 wide (portrait space → 378×334), centered, theme = player's default cosmetic. Shows the position **before** the current move with its dice; last-move markers per game.md. ~~Best-move / your-move arrows (green solid 5px, garnet dashed 3px)~~ and ~~legend "Ən yaxşı: 13/7 13/10" / "Sənin: 13/4 · −0.142"~~: Phase 6, omit.
4. Move list: flex, scrolls, padding `10 16 0`. Row: height 40, padding h 8, radius 10, grid columns `28 | 44 | 1fr | 54`, gap 8, 13px tabular:
   - move number `text@.5`; dice "5-2" `text@.7`; notation `NardType.mono` (12, IBM Plex Mono) `text` (e.g. "13/8 13/11", "8/5(2) 6/3(2)"); 4th column = eval mark (✓ `successText`, ? `accentHi`, ?? `dangerText` + row fill `dangerText@.14`): **Phase 6, leave empty** in Phase 2.
   - Current move row: not designed. Proposal: fill `accent@.12`, auto-scrolled into view. Tap a row → jump to that move.
5. Controls zone: padding `10 16 34` (34 = home indicator; use safe area), gap 10, top border 1px `accent@.14`.
   - Scrubber, height 22: track 4 `text@.12` radius 2; progress `accent` up to current; thumb 20 circle `ivory100`, shadow `0 2 6 black@.4`; draggable, snaps to moves. ~~Blunder dots (8px, `accentHi`/`dangerText`)~~: Phase 6.
   - Buttons row, centered, gap 18, all circles with ring 1px `line`, glyph 18 filled (`currentColor`):
     | Button | Size | Fill / glyph color | SVG path (24 box) | Lucide closest |
     |---|---|---|---|---|
     | To start | 40 | none / `text` | `M6 5h2v14H6zM20 5v14L9 12z` | `skip-back` |
     | Step back | 40 | none / `text` | `M16 5v14L6 12z` | `play` mirrored |
     | Play/Pause | 52 | `accent` / `#231709` (on-accent, *no token*; ceviz `primaryText`) | `M8 5v14l11-7z` | `play` / `pause` |
     | Step forward | 40 | none / `text` | `M8 5v14l10-7z` | `play` (smaller) |
     | To end | 40 | none / `text` | `M4 5v14l11-7zM16 5h2v14h-2z` | `skip-forward` |
     Play auto-advances one move per ~1s (not specified); disabled ends: glyph `text@.4`. Hit targets ≥ 44 (pad the 40s).

| key | az |
|---|---|
| replayTitle | Təhlil · Oyun {n} |
| replayPlayers | {p1} – {p2} |
| *(later)* analysisEquity, analysisBest, analysisYours | Ekvitet · Ən yaxşı: {moves} · Sənin: {moves} · {delta} |
Accessibility labels for the 5 buttons are not in the design (see §8).

### 10.2 Settings
Purpose: gameplay, accessibility, general preferences. Profil tab root in Phase 2. Mock background flat `#1B120C`; use §1.1.
Layout: root title "Ayarlar" (1.3); scroll body padding h 16, groups gap 14; each group = overline (2.10, `text@.55`, padding-left 4) + 6 + group card (2.8) of settings rows (2.9, compact switch); TabBar active `profile`.

| Group | Row | Control (mock default) | Phase 2 |
|---|---|---|---|
| OYUN | Gedişi təsdiqlə | switch (on) | keep |
| | Avtomatik zər at | switch (off) | keep |
| | Avtomatik çıxarış | switch (on) | keep |
| | Mümkün gedişləri göstər | switch (on) | keep |
| | Pip sayı | switch (on) | keep |
| | Animasiya sürəti | value "Normal" › | keep (picker not designed) |
| | Taxta istiqaməti | value "Saat əqrəbi" › | keep (picker not designed) |
| ƏLÇATANLIQ | Rəng korluğu rejimi | switch (off) | keep |
| | Böyük zər xalları | switch (off) | keep |
| | Hərəkəti azalt | switch (off) | keep (default = OS reduce-motion) |
| ÜMUMİ | Səs və vibrasiya | value "Açıq" › | keep (sub-screen not designed) |
| | Dil | value = current endonym › | keep → 9.2 in settings mode |
| | Bildirişlər | › | omit (Phase 7) |
| | Hesab və məxfilik | › | omit (Phase 3) |
Value rows: open a bottom Sheet (game.md sheet spec: inset 8, top radius 24, handle 40×4) with radio rows; only the shown value strings exist in the design. DS card also shows "Animasiya sürəti" as a slider (track 4, thumb 20) with value "Normal"; pick one (see §8).

| key | az |
|---|---|
| settingsTitle | Ayarlar |
| settingsGroupGame | OYUN |
| settingsGroupAccessibility | ƏLÇATANLIQ |
| settingsGroupGeneral | ÜMUMİ |
| settingsConfirmMove | Gedişi təsdiqlə |
| settingsAutoRoll | Avtomatik zər at |
| settingsAutoBearOff | Avtomatik çıxarış |
| settingsShowLegalMoves | Mümkün gedişləri göstər |
| settingsPipCount | Pip sayı |
| settingsAnimationSpeed | Animasiya sürəti |
| animationSpeedNormal | Normal |
| settingsBoardDirection | Taxta istiqaməti |
| boardDirectionClockwise | Saat əqrəbi |
| settingsColorBlind | Rəng korluğu rejimi |
| settingsLargePips | Böyük zər xalları |
| settingsReduceMotion | Hərəkəti azalt |
| settingsSoundVibration | Səs və vibrasiya |
| settingsLanguage | Dil |
| *(later)* settingsNotifications, settingsAccountPrivacy | Bildirişlər · Hesab və məxfilik |
(`valueOn` "Açıq": common.)

### 11.x Offline / empty / error / loading states (generic list-screen pattern)
Shown in the design on "Turnirlər" (11.1–11.4, all Phase 3/6); the same pattern is meant for every list screen. Phase 2 uses the **pattern**; tournament-specific copy is later.
Common frame: root title (1.3, 26) then one of:
- **Offline banner** (11.1; Phase 3+, only when online features exist): directly under status bar, before the title; margin `0 16 8`, height 40, radius 12, fill `dangerText@.14`, ring 1px `dangerText@.4`, padding h 14, gap 10: dot 8 `dangerText` + text 13 `#F3B0BC` *(no token)*.
- **Message state** (11.1 offline, 11.2 empty, 11.3 error): flex-centered column, padding h 36, gap 14, text centered:
  icon well 96 circle, ring 1px `accent@.3`, containing a 34×34 square rotated 45°, 3px outline: `dangerText` (offline, error) or `accent` (empty) · title Noto 21 w600 (`NardType.title.copyWith(fontSize: 21)`, *no token*) · description 14/20 `text@.7` · secondary button height 46 (snap 48), padding h 20, radius 14, ring 1.5 `accent`, label 14 w600 `accentHi`, extra top margin 6.
- **Loading skeleton** (11.4): column gap 10, padding h 16, 4 placeholder cards: height 118, radius 18, fill `text@.04`, padding 16, gap 12; bars: 40% × 10 (r5, `text@.08`), 70% × 16 (r6, `text@.11`), 55% × 10 (r5, `text@.08`), 100% × 4 (r2, `text@.06`). No shimmer specified; if animated, a slow opacity pulse, off under reduce-motion.
Then spacer + TabBar.

| key | az | Phase |
|---|---|---|
| offlineBanner | İnternet yoxdur · oflayn rejim | 3 |
| retry | Yenidən cəhd et | 2 (generic) |
| playVsComputer | Kompüterə qarşı oyna | 2 (offline-state CTA) |
| *(later)* tournamentsTitle | Turnirlər | 6 |
| *(later)* tournamentsOfflineTitle / Desc | Turnirlər oflayn görünmür / Kompüterə qarşı və bir cihazda oyun işləyir. Bağlantı qayıdanda siyahı yenilənəcək. | 3 |
| *(later)* tournamentsEmptyTitle / Desc / Cta | Hələ turnirin yoxdur / Qeydiyyatdan keçdiyin turnirlər burada görünəcək. / Gələcək turnirlərə bax | 6 |
| *(later)* listErrorTitle / Desc | Siyahı yüklənmədi / Serverlə əlaqə qurulmadı. Bir az sonra yenidən cəhd et. | 3 |
No other offline/empty/error/loading states exist in any `*.dc.html` (searched); in-game reconnect/"Mümkün gediş yoxdur" states are in game.md.

---

## 5. Common strings

| key | az |
|---|---|
| appName | NardArena *(brand, not translated, placeholder name)* |
| continueAction | Davam et |
| comingSoon | Tezliklə |
| back (a11y) | Geri *(not in design; proposal)* |
| variantShort | Qısa nərd |
| variantLong | Uzun nərd |
| variantShortUpper | QISA NƏRD |
| variantLongUpper | UZUN NƏRD |
| matchToPointsUpper | {n} XALA QƏDƏR |
| oneGameUpper | 1 OYUN *(proposal)* |
| valueOn | Açıq |
| tabHome | Əsas |
| tabProfile | Profil |
| *(later)* tabTournaments, tabClan, tabStore | Turnirlər · Klan · Mağaza |

---

## 6. Navigation map (Phase 2)
```
Splash ──first launch──▶ 9.2 Language ─Davam et▶ 9.3 Variant ─Qısa/Uzun + Davam et▶ Home
   │                                                └─Öyrənmək istəyirəm + Davam et▶ 9.5 Lesson ─done/Keç▶ Home
   └──otherwise──▶ Home (tab Əsas)
Home: Oyna ▶ GameScreen (vs computer, last settings)
      footer "Uzun nərd →" ▶ toggles variant in place
      Kompüter tile ▶ 2.2 Setup ─Davam et▶ 2.3 AI level ─Başla · {level}▶ GameScreen
      Bir cihazda tile ▶ 18.1 Pass & play setup (Ekranlar 8) ▶ GameScreen
GameScreen ▶ 2.6 Match result (game.md) ─Təhlil▶ 10.1 Replay
Tab Profil ▶ 10.2 Settings ─Dil▶ 9.2 (settings mode) ; other value rows ▶ picker sheet
```
Back from 2.2/2.3/10.1/9.2-settings pops. Onboarding is shown once (persist flag).

## 7. Later phase, omit (do not build in Phase 2)
Profile row, rank, rating, level/XP, coins, yaqut, notification bell, live tournament card, missions, season card, Adi + Şəxsi otaq tiles, time controls, Reytinqli toggle, "Rəqib axtar", 9.4 login/guest, equity bar/arrows/blunder marks, 10.3 fair dice, Bildirişlər/Hesab rows, Turnirlər/Klan/Mağaza tabs, offline banner, all tournament copy.

## 8. Ambiguities / open questions
1. **Lattice band** missing from 2.x/9.x/10.x mocks but required by readme/GameScreen 1c for sebeke → spec says draw it (§1.1).
2. **Backgrounds** of 10.1/10.2 are flat `#1B120C` (ceviz-era) → use theme background.
3. **Button radius**: `Button.jsx` = `--radius-button` (pill in sebeke) for every variant; all sebeke mocks give non-primary buttons radius 14. Spec follows the mocks.
4. **Button font**: readme/GameScreen 1c = Noto Serif for sebeke; screen mocks render Plex. Spec follows readme; `NardColors` has no `buttonFont`, `bgGradient`, `primaryShadow`, `lineSoft`, `surfaceSunken`, `textFaint` tokens; add them.
5. **Card fills**: mocks use ivory tints; sebeke `surface` token is garnet@.18. Spec uses mock tints for menu cards.
6. **Home offline content** (hero meta lines, Oyna behavior, 2-tile grid, no profile row) is a proposal; there is no offline Home mock. A lesson entry point after onboarding is not designed (suggest a third tile "Dərs" or a Settings row).
7. **Flow 2.2 → 2.3** for vs computer, and the CTA "Davam et" replacing "Rəqib axtar", are proposals. Time controls offline: omitted pending PO decision.
8. **AI "~elo"** labels are illustrative; heuristic bots are not calibrated. Consider hiding until measured. Default level not specified (mock selects Güclü; suggest Orta / last used).
9. **"İpuçlarını göstər"** semantics undefined (best-move hint vs legal-move highlight, which already has a Settings toggle). Needs PO decision; nard_ai must support it.
10. **Settings pickers** (Animasiya sürəti, Taxta istiqaməti, Səs və vibrasiya) have one value string each; other options and their copy are missing (e.g. Yavaş/Sürətli, counter-clockwise). DS card shows animation speed as a slider instead.
11. **Language sub-labels**: three are English names, "İngilis" is Azerbaijani. Use English for all ("English") or localized names; also flags are simplified placeholders.
12. **Onboarding step count**: mock "ADDIM 2 / 3" assumes 9.4 login; offline flow is 2 steps.
13. **Lesson**: only step 2 content exists; steps 1, 3–7 copy/positions and the coach avatar art are missing.
14. **Replay**: current-move highlight, play speed, disabled states and a11y labels are not designed; title says "Təhlil" although Phase 2 has no analysis.
15. **Variant card preview** size: 240 wide using the 640×460 landscape geometry (mock hint 240×172).
