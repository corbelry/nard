# Store, cosmetics & progression: implementation spec (Phase 4)

Source: `.claude/skills/nardarena-design`: `Ekranlar 3` (§3 themes, 3.1, 3.2,
asset spec), `Ekranlar 5` (7.3, 7.4, 7.5, 8.2; 7.1/7.2 for links only),
`Ekranlar 7` (12.1, 12.2, 12.3), `Ekranlar 2` (2.1 level/currency/mission
parts, 2.6 rewards), `Board.dc.html` (per-theme `THEMES` table),
`components/commerce/{CurrencyPill,RarityFrame}.jsx`, `tokens/{colors,board}.css`,
`NardArena Dizayn Sistemi` (rarity card). Siblings: `screens.md` (chrome,
shared components), `game.md` (GameScreen, board, 2.6 base), `online.md`
(Phase 3 parts: profile row, rating card, Avatar/RankBadge). This file only
adds what they lack. Frame 390×844 portrait, logical px.

Product rules that override the mocks: coins are **earn-only** (ADR-022);
the paid currency is **Yaqut**, code name `gems` (ADR-023); monetization is
**one-off purchases only**: Yaqut packs + premium season pass (ADR-025);
**no loot boxes** (spec §8.7). Progression ships in Phase 4 (ADR-017).

---

## 0. Conventions

Same as `screens.md` §0 / `online.md` §0: aliases `text`, `text@a`, `dim`,
`accent`, `accent@a`, `accentHi`, `line`, `surfaceRaised`, `dangerText`,
`success`/`successText`, `ivory100`, `walnut900`; `c.` = `context.nard`;
**overline** = `NardType.caption` w600 letterSpacing .72 (.06em), stored
uppercase in ARB (never `toUpperCase()`); "*(no token)*" = raw value.
The 12.x mocks are sebeke-raw (`#D4AE58` = `accent`, `#2a1a20` =
`surfaceRaised`, `#1d1316` = `c.onAccent`, garnet@.18 = `c.surface`,
`D4AE58@.32` = `line`); 3.x/7.x/8.x mocks use ceviz brass `#C9A24A` (= `accent`)
and walnut800 `#34251A` (= `surfaceRaised`). Map every one to the token.

Extra tokens already in `apps/client/lib/ui/extra_tokens.dart` (reuse):
`c.bgGradient`, `c.latticeBand`, `c.primaryGlow`, `c.primaryRing`,
`c.onAccent`, `c.textFaint`, `c.lineSoft` (accent@.16), `c.surfaceSunken`
(black@.25), `c.codeBox` (black@.3), `c.scrim`, `c.tile` (text@.05),
`c.tileRing` (accent@.18), `c.selectedFill` (accent@.16), `c.elevation3`,
`c.buttonFont`, `c.brassRing`, `c.tierFill(tier)`.

**Rarity colors** (`tokens/colors.css`, oklch; sRGB already in `NardPalette`):

| Rarity code | az label | Token | oklch |
|---|---|---|---|
| `common` | Adi | `NardPalette.rarityCommon` #B4B0A8 | 0.75 0.01 80 |
| `rare` | Nadir | `NardPalette.rarityRare` #5FA8E8 | 0.72 0.13 245 |
| `epic` | Epik | `NardPalette.rarityEpic` #B08AE6 | 0.72 0.13 305 |
| `legendary` | Əfsanəvi | `NardPalette.rarityLegendary` #E2BC5A | 0.80 0.13 85 |
| `seasonal` | Mövsümi | `NardPalette.raritySeasonal` #E88A7E | 0.72 0.13 20 |

Alias below: `rarity` = the item's rarity color, `rarity@a` = with alpha.
DS rarity card also defines a tile tint `linear 180° rarity@.18 (legendary .22)
→ black@.2` and a glow `rarity@.2/.25/.35/.3` (common: none); spec §8.6
mentions "Tournament-exclusive" rarity, not in the design (§12).

New raw values in this file (*no token*; add to `extra_tokens.dart`):

| Use | Value |
|---|---|
| Coin glyph (CurrencyPill) | radial at 35% 30%: `#FBE7A6` → `#C9A24A` 60% → `#8A6A22` (12.x variant `#F4DC8E → #C9A24A → #7A5C1E`; store pill 2-stop `#FBE7A6 → #8A6A22` — unify, §12) |
| Gem (Yaqut) glyph | square rotated 45°, linear 135° `#FF9FB0` → `#9E1B32` |
| Pill fill | `text@.06` |
| Legendary/featured card | linear 160° `rarity@.3` → `surfaceRaised` 60%, ring 1px `rarity@.5` |
| Item sheet (3.2) | linear 180° `rarity@.22` → `surfaceRaised` 45%, ring 1px `rarity@.5` |
| Purchase success bg (7.5) | radial `70% 45% at 50% 38%`: `rarity@.3` → `#1B120C` 70% |
| Level-up bg (12.3) | radial `80% 50% at 50% 38%`: `#5A2430` → `#24161B` 60% → `#120C0E` |
| Level badge fill | linear 135° `#B52A45` → `#86152A` (= primary garnet ends) |
| Locker preview glow | radial `60% 60% at 50% 55%`: `accent@.14` → transparent 70% |
| Achievement extra hex fill | garnet linear 160° `#C52F4A` → `#6E0F20` (others reuse `c.tierFill`) |
| Discount/bonus tag | fill `success` (#1F8A5B), text `ivory100` |
| Lighter scrim (7.4) | `rgba(8,6,5,.5)` (12.2 uses .6 ≈ `c.scrim` .62 → use `c.scrim` for both) |

---

## 1. Cosmetic board sets (Ekranlar 3 §3 + `Board.dc.html`)

"Hər tema = taxta + daşlar + zər + zər qabı + fon" (one theme = board +
checkers + dice + dice cup + table background). Gallery card: board 512 wide
on a 24-padded radius-20 tile filled with the theme's table bg; below it a
cup swatch 44×58 (radius `8 8 14 14`, inset ring 1px `white@.12`, shadow
`0 4 8 black@.4`), name Noto 19 w600 (`NardType.title`), rarity 11 w600 in
`rarity`, description 13/18 `dim`. Design note: the cup swatch is a color
sample only; the real 3D cup model comes with the asset phase.

### 1.1 Per-theme data (use as catalog data)
`odd` = points 1,3,5…  (`i % 2 ? ptA : ptB` in the mock = `BoardTheme.pointA`);
gradients are top→bottom (180°) unless noted. Grain = the walnut wood-grain
overlay (3 repeating line families + 2 radial highlights; dark/light colors
listed). All six show the doubling cube in the gallery.

| Field | walnut | baku | carpet | marble | caspian | minimal |
|---|---|---|---|---|---|---|
| code id (`BoardTheme.id`) | `walnut` | `baku_night` | `carpet_heritage` | `marble_royale` | `caspian` | `minimal_pro` |
| name (catalog) | Classic Walnut | Baku Night | Carpet Heritage | Marble Royale | Caspian | Minimal Pro |
| rarity | common (Adi) | epic (Epik) | rare (Nadir) | legendary (Əfsanəvi) | seasonal (Mövsümi) | common (Adi) |
| frame | `#6E4224 → #4B2B16 55% → #5D3720` + grain (dark `rgba(30,12,4,.2)`, light `rgba(255,220,170,.06)`) | `#1D212C → #11131A` + 1px lines `white@.025` every 10 | `#4A2418 → #2E140C` + grain (`black@.2`, `rgba(255,210,170,.05)`) | black marble: 160° `#2A2A2E → #0F0F12` + veins (118° `rgba(220,220,230,.10)`, 40° `accent@.16`) | `#0F3D48 → #082731` + lines `white@.03` every 8 | flat `#1F2125` |
| field | `#C49159 → #A87745` + grain (`rgba(90,45,15,.15)`, `rgba(255,240,210,.11)`) | `#232838 → #171A26` + orange glow `radial 90% 60% at 50% 100% rgba(232,120,60,.18)` + 3 light specks `rgba(255,190,90,.5/.45)`, `rgba(255,150,80,.4)` | `#8A2228 → #6C171D` + ±45° lattice 2px `ivory@.07` every 14 | white marble: 160° `#F4F1EC → #DCD7CF` + veins (118° `rgba(120,120,130,.18)`, 32° `rgba(140,140,150,.12)`) + highlight | `#1D6577 → #0E4351` + wave arcs `white@.05` | flat `#2A2D32` |
| inlay band (6px around each field) | — | — | — | gold `#E9CF82 → #A8822F` | — | — |
| point odd (A) | ebony `#2E1C10 → #1A0E07` + 1px lines `rgba(255,235,200,.035)`/4 | gold `#D9B560 → #8A6A22` | indigo `#26346E → #18214A` + ±45° `accent@.35` 2px/8 | black marble | sand `#ECE3D1 → #CDBD9F` | `#E9E6DF` |
| point even (B) | bone `#F2E7CF → #D5C29D` + lines `rgba(120,90,50,.09)`/5 | indigo `#39406A → #20253F` | bone `#F1E4C8 → #D6C39D` + ±45° `rgba(140,30,36,.35)` | gold `#E9CF82 → #B38A35` | `#0A2C36 → #061C23` | `#5C6068` |
| bear-off tray | `#2A170C → #1C0F07` | `#0B0D12` | `#1F0D08 → #140804` | `#141416 → #08080A` | `#05161B` | `#17181B` |
| point numbers | `ivory@.55` | `#E8C468@.55` | `ivory@.55` | `#E8C468@.7` | `#ECE3D1@.55` | `#ECE7DE@.7` |
| checker light (mine) material | ivory, radial at 38% 30% `#FFFBF2, #EFE4CF 42%, #D4C3A2 78%, #B3A07C` + concentric grooves `rgba(110,85,50,.17)` every 6 | gold `#FFF3C8, #E8C86E 45%, #B08A35 85%, #8A6A22` + grooves `rgba(120,80,10,.2)` + glow `0 0 10 rgba(232,196,104,.35)` | ivory (as walnut) + rim ring 2.5px `#B88F3A` | white marble + highlight, rim 2px `#C9A24A` | pearl `#FFFFFF, #F1F0F4 30%, #E6DDE8 55%, #CFD9E2 80%, #B6C3CF` (no grooves) | flat `#F5F3EE`, ring 2px `#C9C4B9` |
| checker dark (opponent) material | onyx `#5D564F, #2B2724 40%, #151312 80%, #0A0909` + grooves `white@.055` | onyx + rim 1.5px `rgba(232,196,104,.6)` | indigo `#4A5A9A, #26346E 50%, #141C40` + grooves `white@.06` + rim 2.5px `#C9A24A` | black marble + highlight, rim 2px `#C9A24A` | slate-teal `#3A5566, #142836 50%, #08141C` + grooves | flat `#111214`, ring 2px `#4A4D53` |
| checker bevel/shadow | SHW / SHB (below) | SHW-gold / SHB | SHW / SHB | SHW / SHB | own light shadow (inset `rgba(120,130,160,.35)`) / SHB | **no bevel**, `0 1 2 black@.4` only |
| die face (radius 9, 145°) | ivory `#FFFAF0 → #E4D6B8` | black `#2C2C33 → #101014` | ivory (default) | crystal `rgba(235,245,255,.95) → rgba(170,200,230,.75) 50% → rgba(220,235,250,.9)` | shell `#FFF4EE → #ECD2C4` + 2px stripes `rgba(160,110,90,.12)` | flat `#F5F3EE`, no bevel |
| die pips (radial at 40% 35%) | `#3A2A1E → #0D0806` | gold `#FFF0B8 → #C9A24A` | garnet `#C2323C → #6C171D` | sapphire `#3A5A8A → #0E1D36` | teal `#1D4A5A → #061C23` | flat `#111214` |
| dice cup swatch | `#6E4224 → #3B2112` | `#2C2C33 → #0D0D12` | `#8A2228 → #4A1014` | `#E9CF82 → #8A6A22` | `#F5DED0 → #C9A99A` | flat `#2A2D32` |
| table background (Fon) | radial `80% 80% at 50% 40%` `#3B2819 → #1B120C` | radial at 50% 80% `#3A2418 → #0D0F16` | at 50% 40% `#3A1416 → #140708` | `#2E2A24 → #0C0B0A` | `#123844 → #051318` | flat `#16181D` |
| cube | shared ivory cube: 34×34 radius 6, 145° `#FBF5E8 → #D6C5A0`, text `#2B1D14` 13 w700 (offer: 56, radius 10, Noto 28) — same in every theme in the mocks; asset spec wants one set per theme (§12) |
| locker tile swatch (field / points) | `#A87745` / `#2E1C10` | `#232838` / `#C9A24A` | `#7D1F24` / `#26346E` | `#DCD7CF` / `#1A1A1E` | `#1D6577` / `#ECE3D1` | `#2A2D32` / `#E9E6DF` |
| description (catalog, az) | Standart. Oyma ceviz, fil sümüyü və qara daşlar, qara xallı ağ zərlər. | Gecə şəhəri, Flame Towers işıltısı. Qızıl və oniks daşlar, qara zərdə qızıl xal. | Xalça naxışlı xanalar, qırmızı/indiqo palitrası, pirinç kənarlı daşlar. | Ağ və qara mərmər, qızıl kakma, kristal zərlər. *(3.2 adds: "Daş səsi: daş üzərində mərmər.")* | Xəzər mavisi, mirvari daşlar, balıqqulağı teksturalı zərlər. | Düz, yüksək kontrast, turnir üslubu. Heç bir yayındırıcı detal yoxdur. |

Shared shadows (`Board.dc.html`): **SHW** (light checker) `0 2 2 black@.35,
0 4 8 black@.25, inset 0 −2 3 rgba(80,55,25,.35), inset 0 1 1 white@.9`;
**SHB** (dark) `0 2 2 black@.45, 0 4 8 black@.3, inset 0 −2 3 black@.6, inset
0 1 1 white@.18`. Bear-off slabs and hinges are the same in all themes
(`game.md` §2). Board frame: radius 12, shadow `0 18 40 black@.55, 0 4 10
black@.4`, inset top highlight `rgba(255,220,170,.18)`.

Two more board themes exist in `Board.dc.html` and match Locker items
(not in the gallery): `dark` ↔ "Gecə Qarağacı" (Nadir, 900): frame grain
`#3B2617 → #22150C 55% → #2E1D11`, field `#4D3322 → #3A2519`, point A brass
`#B08B3F → #7D5F24`, point B garnet `#7E1B2D → #530E1C`, tray `#140C07 →
#0C0704`, dark checker gets an inset 2px `accent@.8` rim, numbers
`#ECE7DE@.5`. `xatam` ↔ "Şuşa Xatəmi" (Epik, tournament reward): frame
`#5C2B17 → #3E1C0E 55% → #4C2414`, field `#9C683D → #835330`, point A garnet
`#A8213B → #72111F`, point B bone, tray `#24120A → #170A05`, xatəm inlay
stripes 45° `#C9A24A 0–3, #F3EBDD 3–5, #9E1B32 5–8, #1C120B 8–10`. "Kəhrəba"
(Nadir, 1 200; swatch `#C4883A` / `#3A2010`) has no board data.

### 1.2 Differences vs `BoardTheme.all` (`apps/client/lib/theme/board_theme.dart`)
Values in `BoardTheme.all` are identical to the skill's copy and are the
**flat mid-tones** of the design gradients (all six within ±3 per channel);
rarity and `numberColor` match. Differences / gaps:
1. **Missing data**: tray, inlay, gradient stops and texture overlays (grain,
   lattice, veins, waves), checker materials (light/dark, rim, grooves,
   bevel flag), die face + pip colors, cup, table background, description,
   sound set, cube style. `BoardTheme` only has pointA/B, field, frame,
   numberColor (OK as load fallback, per its doc comment).
2. **ids**: design keys `baku`, `carpet`, `marble`, `minimal` vs code
   `baku_night`, `carpet_heritage`, `marble_royale`, `minimal_pro`. The API
   seeder uses the code ids (`board.{id}`, `data.theme`) → use code ids as
   `{theme}` in asset names.
3. **Asset path**: `asset()` returns `assets/themes/{id}/{part}@{scale}x.webp`
   (bundled, always `.webp`); the asset spec (§4) names files
   `board_{theme}_frame@3x.webp`, `point_{theme}_a@3x.png` (sprites are PNG)
   and packs are remote. Replace with a pack resolver.
4. **`hasCube`**: true for all; no design theme hides the cube (cube is hidden
   per variant/Crawford, not per theme). Drop it or document it.
5. **Names** are English constants; Locker also has az-named items ("Gecə
   Qarağacı", "Şuşa Xatəmi", "Kəhrəba") → name/description must be per-locale
   catalog data, not code.
6. **Rendering**: `BoardPainter.theme` is `const walnut` and the painter
   hard-codes walnut gradients/checker colors → must take a full theme object.
7. `dark`, `xatam`, Kəhrəba are not in `BoardTheme.all` (and not in the seeder).
8. Color-blind fallback outline per checker set (spec §8.6) is not in theme data.

---

## 2. Locker (Dolab)

### 2.1 3.1 Locker · Taxta category
**Purpose:** browse owned/available cosmetics per category, preview live on a
board, equip, manage loadouts, opponent-cosmetics preference. Drawn with
TabBar `active="store"` (lives under the Mağaza tab; entry not drawn, §12).
Bg `c.bgGradient` (+ lattice band). No scroll except the item grid.

Layout top → bottom:
1. **Header** h 48, padding h 16, space-between: title "Dolab"
   `NardType.displayL.copyWith(fontSize: 24)` *(no token)* · coin pill (§7.1,
   h 30 variant) "12 450".
2. **Live preview** h 230, fill = locker preview glow (§0), centered: board
   330 wide (landscape space 640×460 → 330×237) in the **previewed** loadout,
   `Transform` perspective 900 + `rotateX(24°)` + translateY −6 *(no token;
   use `Matrix4.identity()..setEntry(3, 2, 1/900)..rotateX(...)`)*. Shows a
   static mid-game position + dice [6,3]. Re-renders on every tile tap.
3. **Loadout row**, padding `6 16 10`, gap 8, centered vertically:
   - active loadout chip: h 30, padding h 12, pill, fill `ivory100`, label
     12 w600 `walnut900` "Dəst 1 · Turnir";
   - other loadout chip: h 30, padding h 12, pill, ring 1px `line`, label 12
     `text` "Dəst 2";
   - add: 30 circle, ring 1px `line`, Lucide `plus` 16 `accent`;
   - spacer; "Saxla" text button 12 w500 `accentHi` (44 hit area).
4. **Category chips**, padding `0 16 12`, gap 6, horizontal scroll: h 34,
   padding h 14, **radius 10** *(not pill; no token)*, 13. Selected: fill
   `ivory100`, label `walnut900` w600. Unselected: transparent, ring 1px
   `accent@.2`, label `text@.75` w500. (Same ivory-on-walnut selection as
   `NardSegmented`.)
5. **Item grid** (flex, scrolls), 3 columns, gap 8, padding h 16 — tiles are
   **RarityFrame** (new widget, §7.2).
6. **Opponent toggle**, padding `10 18 0`, top border 1px `accent@.12`:
   label 13 `text` "Rəqibin kosmetikasını göstər" + `NardSwitch(compact)`
   (44×26, mock on).
7. `NardTabBar`, active `store`.

Mock grid content (category Taxta):

| Tile | Rarity | Status line | State |
|---|---|---|---|
| Classic Walnut | Adi | Taxılıb | equipped (✓ badge) |
| Marble Royale | Əfsanəvi | Sınanır | being previewed (2px `accentHi` ring) |
| Baku Night | Epik | Sahibsən | owned |
| Carpet Heritage | Nadir | 1 200 | locked, buyable |
| Caspian | Mövsümi | Sezon · Səv. 30 | locked, season pass |
| Minimal Pro | Adi | Sahibsən | owned |
| Gecə Qarağacı | Nadir | 900 | locked |
| Şuşa Xatəmi | Epik | Turnir mükafatı | locked, tournament |
| Kəhrəba | Nadir | 1 200 | locked |

Status color: locked → `text@.6`; equipped or previewed → `accentHi`;
otherwise `rarity`. Prices have **no currency glyph** in the mock (§12).

**Categories** (11, = spec §8.6 / API `items.category`):

| key | az | category code (spec) | Phase 4 content |
|---|---|---|---|
| categoryBoard | Taxta | `board` | 6 boards |
| categoryCheckers | Daşlar | `checkers` | default only in seeder |
| categoryDice | Zər | `dice` | default |
| categoryDiceCup | Zər qabı | `dice_cup` | none yet |
| categoryCube | İkiqat kub | `doubling_cube` (API: `cube`) | default; same text as existing `setupCube`, use its own key |
| categoryBackground | Fon | `table_background` | none yet |
| categorySounds | Səslər | `sound_pack` | none yet |
| categoryEmote | Emote | `emote_pack` | Phase 5 (emotes) |
| categoryAvatarFrame | Avatar çərçivəsi | `avatar_frame` | none yet |
| categoryTitle | Titul | `title` | from achievements (§5) |
| categoryWinEffect | Qələbə effekti | `win_effect` | none yet |

**Interactions**
- Tap tile → preview it on the board (status "Sınanır"); owned → equip into the
  active loadout (✓ moves); locked → opens 3.2 Item detail. *(Inferred: the
  mock separates "previewed" from "equipped".)*
- Long-press / second tap on owned → 3.2 as well *(proposal)*.
- Loadout chip tap → switch active loadout (server `loadouts.active`); "+" →
  new loadout "Dəst {n}" (rename UI not designed); "Saxla" → persist slots
  (API `PUT /loadouts`). Equip outside a saved loadout = unsaved state.
- Toggle → local + server preference "show opponent cosmetics" (spec §8.6:
  "Show opponent's cosmetics" vs "Always show my theme"). Default on (mock).
- Empty category: use `MessageState` (not designed).

### 2.2 3.2 Item detail (sheet)
**Purpose:** show one item large, how to get it, try or buy.
Frame: near full-height sheet, top at 84 (34 below the status bar), radius
**28** top *(no token)*, padding `12 18 34`, column gap 16, fill = item sheet
gradient (§0), ring 1px `rarity@.5`. Background behind = `#1B120C` (walnut950,
no scrim in the mock; use `c.scrim`). Build on `showNardSheet` with a
`fullHeight` option (current sheet = inset 8, radius 24; §12).
1. Handle 40×4, radius 2, `text@.25`.
2. Board 354 wide (354×254), padding v 8, drop-shadow `0 0 30 rarity@.35`.
3. Text column gap 6:
   - row gap 10: rarity overline 12 w700 letterSpacing .96 (.08em) `rarity`
     "ƏFSANƏVİ" + set meta 12 `text@.55` "Kral dəsti · 4 əşya";
   - name `NardType.displayL` (28) "Marble Royale";
   - description 14/20 `text@.7` (catalog).
4. Obtain list: top border 1px `accent@.14`; overline "NECƏ ƏLDƏ EDİLİR"
   `text@.6`, padding `12 0 4`; rows padding v 10, bottom border 1px
   `accent@.1`, 14: source `text` · value `dim`.
   | Source | Value |
   |---|---|
   | Mağaza | 1 800 yaqut |
   | Sezon bileti · Premium | Səviyyə 40 |
   | Bakı Payız Kuboku | Top 3 mükafatı |
5. Spacer; buttons row gap 10, h 56:
   - "Sına" outline, flex 1, radius 16 (`NardRadius.l`), ring 1px `accent@.3`,
     w600 → closes sheet, previews on the Locker board ("Sınanır");
   - "Al · ◆ 1 800" primary, flex 2, pill, 16 w600, gem glyph 12 inline →
     7.4 Confirm purchase. Owned item: replace with "Tax" *(proposal)*;
     not purchasable (season/tournament only): hide "Al" *(proposal)*.

### 2.3 Strings (Locker, item detail)
| key | az |
|---|---|
| lockerTitle | Dolab |
| loadoutName | Dəst {n} |
| loadoutNameLabeled | Dəst {n} · {label} *(mock "Dəst 1 · Turnir")* |
| lockerSave | Saxla *(≠ existing `actionSave` "Yadda saxla")* |
| category* | see category table |
| itemEquipped | Taxılıb |
| itemPreviewing | Sınanır |
| itemOwned | Sahibsən |
| itemSeasonLevel | Sezon · Səv. {level} |
| itemTournamentReward | Turnir mükafatı |
| lockerShowOpponentCosmetics | Rəqibin kosmetikasını göstər |
| rarityCommon / Rare / Epic / Legendary / Seasonal | Adi / Nadir / Epik / Əfsanəvi / Mövsümi |
| rarityLegendaryUpper (+ others) | ƏFSANƏVİ *(others proposed: ADİ, NADİR, EPİK, MÖVSÜMİ)* |
| itemSetMeta | {set} · {count} əşya |
| itemObtainTitle | NECƏ ƏLDƏ EDİLİR |
| obtainStore | Mağaza *(same text as tab label `tabStore`)* |
| obtainSeasonPremium | Sezon bileti · Premium |
| obtainSeasonLevel | Səviyyə {level} |
| obtainTournamentTop | Top {n} mükafatı *(tournament name is data)* |
| priceGems | {amount} yaqut |
| itemTry | Sına |
| itemBuy | Al · {price} *(gem glyph is a widget between "Al ·" and the number)* |
| *(proposal)* itemEquip | Tax |
Item names, set names and descriptions are **catalog data** (per-locale map
in `items.data`), not ARB.

---

## 3. Store (Mağaza)

### 3.1 7.3 Store
**Purpose:** Mağaza tab root: featured offer, daily rotating picks, Yaqut packs.
Bg `c.bgGradient` (+ band). TabBar active `store`.
1. **Header**, padding `4 16 12`, space-between: `RootTitle` "Mağaza" (Noto 26)
   · pills row gap 6: coin "12 450", gem "320" (store variant: h 30, padding
   `0 10 0 6/8`, no ring, 12 w600, coin 16, gem 11 → unify with §7.1).
2. **Scroll body**, padding h 16, gap 14:
   1. **Featured card**: radius 20 *(no token)*, clip, legendary card gradient
      + ring (§0, color = item rarity). Board 300 wide (300×216), padding
      `14 0 6`. Footer padding `10 16 16`, row end-aligned, space-between, gap
      10: column gap 3: overline 11 w700 letterSpacing .88 (.08em) `rarity`
      "TÖVSİYƏ · 2 GÜN" · name Noto 20 w600 *(no token)* "Kral dəsti" ·
      contents 12 `dim` "Taxta, daşlar, zər, qab". Price button: h 42,
      padding h 14, radius 12 (`NardRadius.m`), fill `accent`, text
      `c.onAccent` 14 w600, gap 6: old price 12, opacity .55, line-through
      "2 400" + new price "1 800" (= `NardButton` `accent` variant + small
      height; add gem glyph, §12). Tap card or button → 3.2 for the set.
   2. Row space-between, baseline: overline "GÜNLÜK SEÇİM" `dim` · "Yenilənir
      06:12:40" 12 `text@.55` tnum (live countdown to rotation).
   3. **Daily picks** grid 3 cols, gap 8. Tile: radius 14, padding 8, fill
      `text@.04`, ring 1px `rarity`, column gap 6: image 62 h, radius 9 (mock
      placeholder stripes + mono label; real = item render) · name 12 w600
      ellipsis · price 12 w600 `accentHi`. Tap → 3.2.
      | Item | Category | Rarity | Price |
      |---|---|---|---|
      | Kəhrəba daşlar | daşlar | Nadir | 900 |
      | Şəbəkə zər qabı | zər qabı | Epik | 1 400 |
      | Çay emote | emote | Adi | 300 |
   4. Overline "YAQUT".
   5. **Yaqut packs** grid 3 cols, gap 8. Tile: radius 14, padding `12 8`,
      fill `text@.04`, ring 1px `accent@.18`, column centered gap 6: gem 22 ·
      amount 15 w600 tnum · price 12 `text@.7`. Bonus tag: absolute top −8,
      centered, 10 w700, padding `2 6`, radius 5, fill `success`, text
      `ivory100` "+20%". Tap → native IAP sheet (StoreKit / Play Billing) →
      server receipt validation → gems credited → toast/7.5 variant (§12).
      | Pack | Price (mock) | Tag |
      |---|---|---|
      | 500 | 4,99 ₼ | — |
      | 1 200 | 9,99 ₼ | +20% |
      | 2 000 | 19,99 ₼ | — |
      Prices must come from the platform store (`ProductDetails.price`,
      localized), never from ARB/code.
3. **Season pass link** (7.1 is Phase 6): 7.3 has no pass entry. Store needs
   a card linking to 7.1 (proposal: below the featured card, same style as the
   Home season card: overline "SEZON {n} · {days} GÜN", "Səviyyə {lvl} / 50",
   bar) and the 3.2 obtain row "Sezon bileti · Premium". The pass costs
   **950 yaqut** in 7.1 ("Premium aç · ◆ 950", 58 h primary) — it is not a
   pack, so it must never appear among Yaqut packs. Phase 4 can omit the card.

No coin packs, no "buy coins", no yaqut→coin exchange anywhere (ADR-022).
No random rewards (spec §8.7).

### 3.2 7.4 Confirm purchase (sheet, insufficient balance shown)
Scrim `c.scrim` (mock .5). Sheet: inset 8 (left/right/bottom), padding
`12 20 30`, radius 24 top (`NardRadius.xl`), fill `surfaceRaised`, ring 1px
`line`, column gap 16 (= `showNardSheet`).
1. Handle 40×4 `text@.25`.
2. Item row gap 14: thumb 72×72, radius 14, ring 1.5px `rarity` (item render)
   · column gap 3: overline 11 w700 letterSpacing .66 `rarity` "ƏFSANƏVİ DƏST"
   · name Noto 20 w600 "Kral dəsti" · meta 12 `text@.6` "4 əşya · Marble Royale".
3. Table: top border 1px `accent@.14`; rows padding v 12, bottom border 1px
   `accent@.1`, 14, space-between: "Qiymət" `dim` / "1 800 yaqut" w600;
   "Balans sonra" `dim` / "−1 480 çatmır" w600 `dangerText`.
4. Note 13/18 `text@.7`: "Balansın kifayət etmir. 2 000 yaqut paketini al və
   dəsti birbaşa aç."
5. Primary l (56): "2 000 yaqut al · 19,99 ₼" → IAP for the **smallest pack
   ≥ shortfall** (1 480 → 2 000), then the server spends 1 800 in the same
   flow ("birbaşa aç").
6. Text button h 44, 15 `text@.7` "Ləğv et" (= ghost).
States not designed (*proposal*): **enough balance** → "Balans sonra" =
"{n} yaqut" in `text`, no note, primary "Al · ◆ 1 800"; **coin price** → coin
glyph + "sikkə"; busy (spinner in primary, sheet not dismissible); IAP
cancelled → stay on sheet; failed/pending validation → inline `dangerText`
line + retry; offline → `OfflineBanner`, buttons disabled.

### 3.3 7.5 Purchase success (full screen)
Bg = purchase success radial (§0, item rarity). No tab bar.
1. Center column (flex, centered), padding h 24, gap 18, text centered:
   - success disc 72, fill `success`, Lucide `check` 34 stroke 2.6 `ivory100`;
   - title `NardType.displayL` (28) "Kral dəsti sənindir";
   - board 320 wide (320×230) in the bought theme;
   - receipt card: full width, padding 14, radius 14, fill `c.tile`, column
     gap 6, 12 `text@.7`, rows space-between: "Qəbz" / `NardType.mono`
     "NA-7F3K-2291"; "Ödəniş" / "1 800 yaqut".
2. Bottom row, padding `0 16 40`, gap 10, h 54 (snap 56): "Bağla" outline
   flex 1, radius 16, ring 1px `accent@.3` → back to Store; "İndi tax"
   primary flex 1.4, pill → equip into the active loadout, open Locker.
Motion (*proposal*): disc scales in 0.6→1 over `NardMotion.sheetIn` with
`NardMotion.standard`; off under reduce motion. Yaqut-pack-only success
(no item) is not designed: reuse with gem glyph 48 instead of the board,
title "+{n} yaqut" *(proposal)*.

### 3.4 Strings (store, purchase)
| key | az |
|---|---|
| tabStore | Mağaza |
| storeTitle | Mağaza |
| storeFeaturedOverline | TÖVSİYƏ · {days} GÜN |
| storeDailyTitle | GÜNLÜK SEÇİM |
| storeRefreshesIn | Yenilənir {time} |
| storeGemsTitle | YAQUT |
| storeGemBonus | +{percent}% |
| purchaseSetOverline | {RARITY} DƏST *(mock "ƏFSANƏVİ DƏST"; uppercase rarity from ARB)* |
| purchaseSetMeta | {count} əşya · {board} |
| purchasePrice | Qiymət |
| purchaseBalanceAfter | Balans sonra |
| purchaseShortfall | −{amount} çatmır |
| purchaseNotEnough | Balansın kifayət etmir. {pack} yaqut paketini al və dəsti birbaşa aç. *("dəsti" = the set; needs a generic variant for single items)* |
| purchaseBuyPack | {amount} yaqut al · {price} *(price = store-localized string)* |
| cancel | **existing key** (Ləğv et) |
| purchaseOwnedTitle | {item} sənindir |
| purchaseReceipt | Qəbz |
| purchasePaid | Ödəniş |
| priceGems | {amount} yaqut |
| purchaseClose | Bağla |
| purchaseEquipNow | İndi tax |
| *(later, 7.1)* seasonPremiumUnlock | Premium aç · {price} |
| *(later, 7.1)* seasonOverline / seasonLevelOf | SEZON {n} · {days} GÜN · Səviyyə {level} / {max} |
Bundle contents line ("Taxta, daşlar, zər, qab") and featured names are
catalog data.

---

## 4. Asset spec · remote packs (contract)

From Ekranlar 3 "Asset spesifikasiyası · developer üçün" (Flutter + Flame,
all sizes logical px). Written as the contract every cosmetic pack must meet.

### 4.1 Files (exact from the design)
`{theme}` = item theme id (code ids, §1.2). Opaque textures **WebP quality
85**; transparent sprites **PNG**.

| Asset (az label) | @1x | @2x / @3x (px) | File name |
|---|---|---|---|
| Board frame (Taxta çərçivə) | 640×460 | 1280×920 / 1920×1380 | `board_{theme}_frame@3x.webp` |
| Playing field, one half (Oyun sahəsi, yarım) | 252×420 | 504×840 / 756×1260 | `board_{theme}_field@3x.webp` |
| Point A / B triangle (Xana) | 40×181 | 80×362 / 120×543 | `point_{theme}_{a\|b}@3x.png` |
| Checker light / dark (Daş ağ / qara) | 38×38 | 76×76 / 114×114 | `checker_{theme}_{w\|b}@3x.png` |
| Checker side view, borne off (Daş yan görünüş) | 40×10 | 80×20 / 120×30 | `checker_{theme}_{w\|b}_side@3x.png` |
| Die face ×6 (Zər üzü) | 44×44 | 88×88 / 132×132 | `die_{theme}_face{1-6}@3x.png` |
| Die roll atlas (Zər fırlanma atlası) | 12 frames | 132×132 per frame | `die_{theme}_roll_atlas.png` |
| Dice cup (Zər qabı) | 96×128 | 192×256 / 288×384 | `cup_{theme}@3x.png` |
| Doubling cube ×7 (İkiqat kub) | 34×34 | 68×68 / 102×102 | `cube_{theme}_{2-64}@3x.png` |
| Background (Fon) | 430×932 | 1290×2796 (@3x only) | `bg_{theme}.webp` |

Other rules from the design:
- **Format**: textures WebP q85, transparent sprites PNG. Dice roll: **12
  frames at 30 fps**, one atlas per theme. Sounds: **OGG, 48 kHz, −14 LUFS**.
- **Board geometry**: logical 640×460 (landscape), 640×566 (portrait). Frame
  20, point width 42, bar 36, bear-off tray 46; checker 38, die 44, cube 34;
  point height = 43% of the inner height (= `BoardGeometry`).
- **Safe zones**: portrait top 59, bottom 34, board 378 pt wide with 6 pt side
  gutters; landscape left 50 (Dynamic Island), right 18, bottom 21. Android:
  use `WindowInsets`, never fixed numbers.
- **Drawn in code, not in packs**: legal-move highlight, ghost checkers,
  selection ring, last-move markers, point numbers; they read theme colors
  from the ThemeExtension.

### 4.2 Pack contract (proposal where marked; the design gives only §4.1)
- One pack per item (a set = several items) *(proposal)*; delivered via the
  API's `items.asset_url` + `items.asset_version` (columns exist) as a ZIP
  *(proposal)* with the §4.1 files at its root.
- Ship **@2x and @3x** of every sprite *(proposal; the table names only
  `@3x`)*; client picks `@3x` when `devicePixelRatio ≥ 2.5`. Roll atlas and
  `bg` exist only at @3x.
- Roll atlas layout *(proposal)*: one row of 12 frames → 1584×132 PNG, frame
  i at x = 132·i.
- `manifest.json` *(proposal)*: `{ id, category, theme, version, minApp,
  files: {name: sha256}, colors: {pointA, pointB, field, frame, tray,
  numberColor, checkerLight, checkerDark, dieFace, diePip}, sounds: [...] }`.
  `colors` = the flat fallbacks of §1.1, used for code-drawn parts, while the
  pack downloads, and when it fails.
- Client: download on first preview/equip, verify sha256, unpack to app
  support dir `cosmetics/{id}/{version}/`, delete older versions; walnut +
  default checkers/dice/cube are bundled (always available offline).
- Server never trusts the client's equipped set; the opponent's loadout ids
  come from the match payload (needs `nard_protocol` fields, not yet present).
- Sound pack file list is not in the design (3.2 only says "Daş səsi: daş
  üzərində mərmər") → §12.

---

## 5. Achievements + titles (8.2)

**Purpose:** list achievements with progress; pick the title shown under the
name (8.1 shows it: Noto Serif italic 500 13 `accentHi`, "Zər ustası").
Pushed screen (entry not drawn; from 8.1 Profile, §12). Bg flat `#1B120C`
in the mock → use `c.bgGradient`.
1. Header (bare, = `ScreenHeader(bare: true)`): h 48, padding h 16, gap 12:
   Lucide `chevron-left` 20 · title Noto 20 w600 flex "Nailiyyətlər" · count
   13 `text@.6` tnum "34 / 80".
2. Grid 3 cols, gap 10, padding `8 16`: tile padding `12 8`, radius 14, fill
   `text@.04`, ring 1px `c.lineSoft`, column centered gap 8: hexagon 48×54
   (RankBadge clip) with fill · name 12 w600 centered, line-height 15 · bar
   3 high, radius 2, track `text@.1`, fill `accent`, width = progress. Tile
   opacity .45 when progress 0%.
   | Achievement | Progress | Hex fill | Phase note |
   |---|---|---|---|
   | Mars ustası | 100% | gold (`tierFill(gold)`) | 4 |
   | İlk koks | 100% | master purple | 4 |
   | 10 seriya | 100% | diamond blue | 4 |
   | Uzun yol | 60% | platinum teal | 4 |
   | Klan qəhrəmanı | 40% | garnet `#C52F4A → #6E0F20` | 5 (clan), hide |
   | Turnir qalibi | 100% | gold | 6 (tournaments), hide |
   | 1000 oyun | 41% | flat `text@.2` | 4 |
   | Qrossmeyster | 0% | flat `text@.2` | 4 (rating tier) |
   | Səhvsiz matç | 0% | flat `text@.2` | 6 (needs analysis), hide |
3. Overline "TİTUL", padding `16 16 6`.
4. Title chips, wrap, gap 8, padding h 16: h 34, padding h 14, pill, **Noto
   Serif Display italic 500 14** *(no token)*. Selected: fill `accent@.18`,
   ring 1.5px `accent`, text `accentHi` ("Zər ustası"). Others: ring 1px
   `line`, text `text` ("Payız Xanı", "Mars kralı", "Klan dayağı"). Dimmed
   `text@.4`: "Yeni başlayan" (locked or default? §12). Tap → set title
   (server `users.title_item_id`).
Achievement detail / reward on tap: not designed. Achievements pay coins
(ADR-017); reward amounts are not shown anywhere.

| key | az |
|---|---|
| achievementsTitle | Nailiyyətlər |
| achievementsCount | {done} / {total} |
| titlesOverline | TİTUL |
| *(catalog / ARB by id)* achievement names | Mars ustası · İlk koks · 10 seriya · Uzun yol · 1000 oyun · Qrossmeyster · *(later)* Klan qəhrəmanı · Turnir qalibi · Səhvsiz matç |
| *(catalog / ARB by id)* title names | Zər ustası · Payız Xanı · Mars kralı · Yeni başlayan · *(later)* Klan dayağı |
Titles are items (`category = title`), so their names are catalog data;
if achievements stay config-defined on the server, give them ARB keys by id.
Social/clan parts of 8.1 (clan line "Qızıl Zər", trophy showcase) stay later.

---

## 6. Progression screens (Ekranlar 7 + Ekranlar 2)

### 6.1 12.1 Daily / weekly missions
**Purpose:** mission list with claim, streak summary, daily chest. Drawn
with TabBar `active="home"` → pushed inside the Home tab from the Home
mission card. Bg `c.bgGradient` (+ band).
1. Header padding `4 16 12`, space-between: `RootTitle` "Tapşırıqlar"
   (Noto 26) · coin pill variant: h 32, padding `0 12 0 8`, fill `c.codeBox`,
   ring 1px `line`, gap 7, 14 w600 tnum, coin 16 "3 450". (Root title + no
   back button although pushed → add back, §12.)
2. **Streak card**: margin `0 16 14`, padding `14 16`, radius 16, fill
   `c.surface` (garnet@.18), ring 1px `line`, column gap 10:
   - row space-between, baseline: "Giriş seriyası · 5 gün" Noto 17 w600
     *(no token)* · "Sabah: +80" 12 `text@.6`;
   - 7 segments, row gap 6, each flex × 6 h, radius 3: done `accent`, rest
     `text@.12`.
3. **Daily/Weekly switch**: margin h 16, padding 3, pill, fill `text@.06`;
   segments flex, h 36, pill, 14 w600. Selected fill `accent`, label
   `c.onAccent`; unselected label `text@.7`. (**Differs from
   `NardSegmented`**: brass pill vs ivory r10 → new `PillSegmented`.)
4. Reset line: padding `10 20 8`, 12 `text@.55` tnum "Yenilənməyə 06:42:10"
   (live countdown).
5. **Mission list**, padding h 16, gap 8 (scrolls). Row: padding `12 14`,
   radius 14, fill `text@.04`, ring 1px `accent@.14`, gap 12:
   - icon box 34 with a 20×20 diamond (square rotated 45°), 2px outline in the
     state color (no icon per mission type in the design);
   - column flex gap 7: row space-between gap 8: name 14 w600 · progress 12
     `text@.6` tnum "2 / 3"; bar 4, radius 2, track `text@.1`;
   - trailing pill 64×34, pill radius, 13 w700.
   | State | Diamond / bar | Progress text | Trailing | Row |
   |---|---|---|---|---|
   | in progress | `accent` | "{a} / {b}" | fill `c.surfaceSunken`, ring 1px `line`, `text` "+{reward}" | 1 |
   | claimable | `successText` (bar full) | "{b} / {b}" | fill `accent`, `c.onAccent` "Al" | 1 |
   | claimed | `text@.3` | "Alındı" | transparent, `text@.5` "✓" (Lucide `check` 14) | opacity .55 |
   Mock daily list:
   | Mission | Progress | Reward | State |
   |---|---|---|---|
   | 3 dubl at | 3 / 3 | +40 | claimable |
   | Reytinq oyunu qazan | 2 / 3 | +60 | in progress |
   | Kubu qəbul et və qazan | 0 / 1 | +80 | in progress |
   | Məşq tapmacası həll et | 1 / 2 | +30 | in progress (puzzles = Phase 6) |
   | Uzun nərd oyna | 1 / 1 | +30 | claimed |
6. **Daily chest row**: margin-top 4, padding `12 14`, radius 14, ring 1px
   `line` (no fill), gap 12: 40×34 radius 8 placeholder (ring `accent@.4`) ·
   column gap 3: "Günlük sandıq" 14 w600 · "Bütün tapşırıqları bitir · 2 / 5"
   12 `text@.6`. Contents must be fixed and shown (no loot box, §12).
7. `NardTabBar`, active `home`.
Interactions: "Al" → `POST` claim (idempotent) → coin pill counts up
(`NardMotion.counter`, `outExpo`), row → claimed. Weekly tab: same list
(content not designed). Missions update from match results (server).

### 6.2 12.2 Login streak (modal on app open)
**Purpose:** daily check-in reward, shown once per day on first open
(after sign-in), over Home.
- Scrim `c.scrim` (mock `rgba(8,6,5,.6)`). Card: left/right 16, vertically
  centered (mock top 150), padding `24 18 18`, radius 24, fill
  `surfaceRaised`, ring 1px `accent@.4`, shadow `c.elevation3` (mock `0 20 60
  black@.6`). Column centered gap 18, text centered:
  1. overline 12 w600 letterSpacing .96 `accent` "GİRİŞ SERİYASI";
  2. title `NardType.displayL` (28/34) "5-ci gün";
  3. body 14/20 `text@.7`, margin-top −8: "Hər gün daxil ol, 7-ci gün sandığı aç.";
  4. day grid 4 cols, gap 8 (day 7 spans 2 cols): tile h 84, radius 14, column
     centered gap 6: label 11 w600 `text@.6` "{n}-ci gün" · glyph 20 · value 13
     w700 tnum.
     | Day state | Fill / ring | Glyph | Opacity |
     |---|---|---|---|
     | claimed (1–4) | `text@.04` / 1px `c.lineSoft` | Lucide `check` 20 stroke 3 `successText` | .6 |
     | today (5) | `accent@.18` / 1.5px `accent` | coin 20 | 1 |
     | future (6, 7) | `text@.04` / 1px `c.lineSoft` | coin 20 | 1 |
     Values: +20, +30, +40, +50, +60, +80, day 7 "Sandıq".
  5. primary l, full width: "+60 sikkəni al" → claim → close (coin pill on
     Home counts up);
  6. footnote 12/17 `text@.55`: "Bir gün buraxsan, seriya 1-ci gündən başlayır."
- Not dismissible without claiming *(inferred; no close button in the mock;
  allow back/scrim tap = claim later?)* → §12.

### 6.3 12.3 Level up (full screen)
**Purpose:** celebrate a new player level and its rewards. Shown after 2.6
when the match result raises the level *(inferred)*.
- Bg level-up radial (§0) + lattice overlay full screen: ±60° 1px lines every
  18, `accent@.08`, masked by a radial fade at (50%, 36%) opaque → transparent
  55%.
- Center column (flex, centered), padding h 24, gap 16, text centered:
  1. **Level badge** in a 150 box: 104×104 square rotated 45°, border 5
     `accent`, fill level badge gradient (§0), glow `0 0 40 accent@.45`; number
     un-rotated, Noto 44 w600 *(no token)* `c.primaryText` "24".
  2. overline 12 w600 letterSpacing .96 `accent`, margin-top 6:
     "SƏVİYYƏ 23 → 24".
  3. title Noto 32/38 w600 *(no token)* "Səviyyə yüksəldi".
  4. XP block 220 wide, gap 6: bar 6, radius 3, track `text@.12`, fill
     `accent` (8%) · caption 12 `text@.6` tnum "120 / 1 500 XP".
  5. Rewards row, gap 10, margin-top 10 — **RewardTile** 110 wide, padding v
     14, radius 16, fill `c.tile`, column centered gap 8:
     - coin: ring 1px `accent@.3`; coin 30; "+200" 14 w700; "Sikkə" 11 `text@.6`;
     - item: ring 1.5px `rarity`; swatch 30×30 radius 7 (item render; mock
       fill `#2A2340`, ring 1px `rarity`); name 14 w700 "Ametist zər"; rarity
       label 11 `rarity` "Epik".
- Bottom padding `0 16 40`, gap 10: primary l "Davam et" → back to 2.6/Home;
  text button h 48, 15 w600 `accentHi` "Zəri indi tax" → equip the reward,
  open Locker (category of the item).
Motion *(proposal)*: badge scales 0.8 → 1 with `outBack`-like overshoot, XP
bar fills over `NardMotion.counter`; reduce motion = static.

### 6.4 2.1 Home: Phase 4 parts
Adds to `online.md` §7.1 (profile row) and `screens.md` 2.1:
1. **Level line** under the name/rank line (profile row column gap 5): row
   gap 8: "Səv. 24" 11 `dim` tnum + XP bar flex, h 4, radius 2, track
   `text@.12`, fill `accent` (mock 64%). Tap row → 8.1 Profile.
2. **Currency pills** row, gap 8: coin pill + gem pill (§7.1, h 32 default
   variant), spacer, ~~bell~~ (Phase 7). Coin pill tap → 12.1 Missions
   *(proposal; earn-only, never a buy screen)*; gem pill tap → Store, Yaqut
   section *(proposal)*.
3. **Daily mission card** (left half of the 2-col bottom grid, gap 8): radius
   16, padding 12, fill `c.tile`, ring 1px `c.tileRing`, column gap 8:
   overline 11 w500 `dim` "GÜNLÜK MİSSİYA · 2/3" · text 13/17 w500 "3 oyunda
   mars et" · bar 4, track `text@.12`, fill **`successText`** (66%; 12.1 uses
   `accent` for in-progress, §12). Tap → 12.1.
4. ~~Season card~~ "SEZON 4 · 18 GÜN" / "Səviyyə 18 / 50" (36% bar `accent`):
   Phase 6; in Phase 4 the mission card can span both columns.

### 6.5 2.6 Match result: rewards parts
Adds to `game.md` §7 (layout) and `online.md` §7.3 (rating card). Order in
the content column (gap 18): header → rating card (ranked) → **rewards row**
→ **mission progress** → bottom buttons.
1. **Rewards row**, gap 8, two tiles flex 1: radius 14, padding 12, fill
   `c.tile`, ring 1px `c.tileRing`, row gap 10:
   - coin 26 · column: "+250" 16 w600 tnum · "sikkə" 11 `text@.6`;
   - XP badge 26×26, radius 7, fill `accent`, "XP" 10 w700 `c.onAccent` ·
     column: "+120" 16 w600 · "təcrübə" 11 `text@.6`.
2. **Mission progress**, padding `4 2`, column gap 10; each: column gap 6:
   row space-between 13: name `text` · value. Bar 4, radius 2.
   | Mission | Value | Style |
   |---|---|---|
   | 3 oyunda mars et | 3/3 ✓ | value `successText` w600; bar full `successText` |
   | 5 reytinqli matç qazan | 2/5 | value `dim`; bar track `text@.12`, fill `accent` 40% |
   Show only missions whose progress changed in this match *(inferred)*; max 2.
3. Values come from the server's match-result payload (authoritative). Offline
   / vs computer games: no rewards, hide both blocks *(proposal, §12)*.
4. Count-up motion: numbers count from 0 over `NardMotion.counter` /
   `outExpo` (with the rating counter); level-up → push 12.3 after the
   counters finish.

### 6.6 Strings (progression)
| key | az |
|---|---|
| missionsTitle | Tapşırıqlar |
| streakCardTitle | Giriş seriyası · {days} gün |
| streakTomorrow | Sabah: +{coins} |
| missionsDaily | Günlük |
| missionsWeekly | Həftəlik |
| missionsResetsIn | Yenilənməyə {time} |
| missionProgress | {done} / {target} *(12.1 spaced; 2.6/Home unspaced "3/3", §12)* |
| missionReward | +{n} |
| missionClaim | Al |
| missionClaimed | Alındı |
| missionDoubles | {n} dubl at |
| missionWinRanked | Reytinq oyunu qazan |
| missionCubeTakeWin | Kubu qəbul et və qazan |
| missionPuzzle | Məşq tapmacası həll et *(Phase 6)* |
| missionPlayLong | Uzun nərd oyna |
| missionMarsGames | {n} oyunda mars et |
| missionWinRankedMatches | {n} reytinqli matç qazan |
| dailyChestTitle | Günlük sandıq *(rename if contents are fixed coins, §12)* |
| dailyChestBody | Bütün tapşırıqları bitir · {done} / {total} |
| streakOverline | GİRİŞ SERİYASI |
| streakDayTitle | {n}-ci gün *(wrong for 3, 4, 6 → use per-day keys below)* |
| streakDay1 … streakDay7 | 1-ci gün · 2-ci gün · 3-cü gün · 4-cü gün · 5-ci gün · 6-cı gün · 7-ci gün *(mock prints "3-ci/4-ci/6-ci", which is wrong az)* |
| streakBody | Hər gün daxil ol, 7-ci gün sandığı aç. |
| streakChest | Sandıq |
| streakClaim | +{coins} sikkəni al |
| streakResetNote | Bir gün buraxsan, seriya 1-ci gündən başlayır. |
| levelUpOverline | SƏVİYYƏ {from} → {to} |
| levelUpTitle | Səviyyə yüksəldi |
| xpProgress | {xp} / {next} XP |
| rewardCoins | +{n} |
| rewardCoinsLabel | Sikkə |
| continueAction | **existing key** (Davam et) |
| levelUpEquipDice | Zəri indi tax *(category-specific accusative; one key per category or fall back to `purchaseEquipNow` "İndi tax")* |
| homeLevel | Səv. {n} |
| homeDailyMission | GÜNLÜK MİSSİYA · {done}/{total} |
| matchCoins | sikkə |
| matchXp | təcrübə |
| xpBadge | XP |
| matchMissionDone | {done}/{target} ✓ |
| matchRematch / matchWonTitle / matchMeta | **existing keys** |
| *(later)* homeSeason / homeSeasonLevel | SEZON {n} · {days} GÜN · Səviyyə {level} / {max} |
| *(later)* seasonLevelTo | Səviyyə {n}-a *(suffix harmony: 19-a, 20-yə)* |

---

## 7. Shared widgets

### 7.1 New
- **CurrencyIcon** (`coin` | `gem`, size): coin = disc with coin gradient (§0);
  gem = square rotated 45°, gem gradient, drawn at ~0.7× the coin size (20 →
  14 + margin 3). Sizes used: 11/12 (inline), 16, 18, 20, 22, 26, 30.
- **CurrencyPill** (`components/commerce/CurrencyPill.jsx`): h 32, padding
  `0 12 0 6`, pill, fill `text@.06`, ring 1px `line`, gap 7, `NardType.labelM`
  13 tnum, thousands separator = space ("12 450", use `NumberFormat` with
  `' '`). Mocks vary (h 30 no ring 12 w600 in 7.3; `c.codeBox` fill 14 w600 in
  12.1) → one widget, optional `compact`. Count-up when the value changes.
- **PriceTag**: CurrencyIcon + amount; optional struck-through old price
  (12, opacity .55). Used in buttons, tiles, sheets.
- **RarityFrame / ItemTile** (`RarityFrame.jsx`): width from grid, radius 14,
  padding 6, fill `text@.04`, ring `equipped ? 2px accentHi : 1px rarity`
  (+ legendary glow `0 0 18 rarity@.35`), column gap 6: thumb h 64 radius 9
  (opacity .55 when locked; board swatch = field color + zigzag of 12 point
  triangles, 34 high, inset 8, point color), name `NardType.caption` w600
  ellipsis, status `NardType.micro` (`text@.6` when locked, else `rarity`).
  Badges top 10 right 10: equipped ✓ disc 20 `accent` + `c.onAccent` 11 w700;
  locked 22×22 radius 6 `black@.6` + Lucide `lock` 12 stroke 2.5 `text`.
  (Store daily tile = same frame with padding 8, thumb 62, price line.)
- **RarityLabel** (text + uppercase variant, color = rarity).
- **CategoryChip** (radius 10, ivory selected) and **LoadoutChip** (h 30 pill).
- **PillSegmented** (12.1): brass selected pill (see §6.1).
- **KeyValueRow** list (3.2 obtain, 7.4 table, 7.5 receipt): row padding v
  10/12, bottom hairline `accent@.1`, label `dim`, value `text`/w600.
- **TiltedBoardPreview** (3.1) and a themed `BoardPreview(theme:)` (3.2, 7.3,
  7.5): needs the data-driven painter (§1.2.6).
- **FeaturedOfferCard**, **GemPackTile** (with bonus tag).
- **MissionRow**, **StreakSegments** (7 segments), **StreakDayTile**.
- **RewardTile** (coin / XP / item; 2.6 horizontal variant, 12.3 vertical).
- **LevelBadge** (rotated diamond, number), **XpBar** (= `NardProgressBar`
  h 4/6 + caption).
- **AchievementTile** (hex = `RankBadge` hex clip at 48×54 + fill), **TitleChip**
  (Noto italic).

### 7.2 Reuse
| Need | Reuse |
|---|---|
| CTAs | `NardButton` primary / outline / ghost / `accent` (featured price; needs leading/trailing widget for gem glyph and line-through) |
| Headers | `RootTitle` (Mağaza, Tapşırıqlar), `ScreenHeader(bare: true)` (8.2) |
| Switch | `NardSwitch(compact)` (opponent cosmetics) |
| Progress | `NardProgressBar` (heights 3, 4, 6; custom fill) |
| Sheets | `showNardSheet` + handle (7.4); add a full-height option for 3.2 |
| Overlays | `MessageState` (empty category / load error), `OfflineBanner` (store offline) |
| Nav | `NardTabBar` + `tab_shell.dart`: add `NardTab(LucideIcons.shoppingBag, l.tabStore)` |
| Background | `NardBackground` (band on 3.1, 7.3, 12.1) |
| Press | `Pressable` for all tiles/chips |
| Identity | `Avatar`, `RankBadge` (hex clip), `c.tierFill` (achievement fills) |

Icons (Lucide, `lucide_icons`): `shopping-bag` (tab), `chevron-left`
(8.2), `plus` (new loadout), `lock` (locked tiles), `check` (equipped,
claimed, streak days, 7.5 disc). Coin, gem, XP badge, mission diamond,
achievement hex and level badge are drawn shapes, not icons (readme).

---

## 8. Navigation (Phase 4 additions)
```
Tabs: Əsas · Mağaza · Profil   (Turnirlər 6, Klan 5 still hidden)
Home: level row ▶ 8.1 ; coin pill ▶ 12.1 ; gem pill ▶ 7.3 (Yaqut) ; mission card ▶ 12.1
App open (first time per day, signed in) ▶ 12.2 modal over Home ─claim▶ Home
Mağaza tab: 7.3 ─featured/daily tile▶ 3.2 ─Al▶ 7.4 ─buy▶ (IAP) ▶ 7.5 ─İndi tax▶ 3.1
                                                              └─Bağla▶ 7.3
            7.3 ─gem pack▶ IAP ▶ gems credited
            7.3 ⇄ 3.1 Dolab (switch not designed, §12)
3.1 ─locked tile▶ 3.2 ─Sına▶ 3.1 preview ; ─Al▶ 7.4
GameScreen ▶ 2.6 (rewards) ─level changed▶ 12.3 ─Zəri indi tax▶ 3.1
Profil ▶ 8.1 ─(entry not drawn)▶ 8.2
```

## 9. Later phases — omit in Phase 4
7.1 Season pass, 7.2 Season summary, Home season card, season-pass rows
except the 3.2 obtain line (6); tournament rewards/obtain row content (6);
emotes category content, clan achievements/titles, clan line in 8.1,
"Klan qəhrəmanı", "Klan dayağı" (5); "Məşq tapmacası həll et", "Səhvsiz
matç", "Turnir qalibi" (6); notification bell (7).

---

## 10. Economy numbers seen in the design (for product-owner confirmation)

"Placeholder" = current working-tree values in `apps/api/config/progression.php`
and `apps/api/database/seeders/ItemCatalogSeeder.php` (marked placeholders).

| # | Number in the design | Where | Implied rule | Placeholder now |
|---|---|---|---|---|
| 1 | Coins 12 450, Yaqut 320 | 2.1, 3.1, 7.3 | sample balances (12.1 shows 3 450) | — |
| 2 | Kral dəsti (4 items, legendary) **1 800 yaqut**, was **2 400** | 7.3, 3.2, 7.4, 7.5 | bundles discounted (−25%) | marble_royale board 800 gems |
| 3 | Featured "TÖVSİYƏ · 2 GÜN" | 7.3 | featured offer runs 2 days | — |
| 4 | Carpet Heritage **1 200** (currency not shown) | 3.1 | rare board price | 6 000 coins |
| 5 | Gecə Qarağacı **900**, Kəhrəba **1 200** (rare) | 3.1 | rare board prices | not seeded |
| 6 | Baku Night, Minimal Pro "Sahibsən" (owned) | 3.1 | — | 300 gems / 2 000 coins |
| 7 | Caspian "Sezon · Səv. **30**" | 3.1 | seasonal = season pass only, level 30 | 400 gems (buyable!) |
| 8 | Caspian taxta on premium track at level **19** | 7.1 | conflicts with #7 | — |
| 9 | Şuşa Xatəmi "Turnir mükafatı" | 3.1 | tournament-only item | not seeded |
| 10 | Marble/Kral: store 1 800 yaqut · premium pass level **40** · Bakı Payız Kuboku **top 3** | 3.2 | one item, three sources | — |
| 11 | Daily picks: Kəhrəba daşlar **900** (rare), Şəbəkə zər qabı **1 400** (epic), Çay emote **300** (common) | 7.3 | 3 picks/day; currency not shown | — |
| 12 | Daily pick refresh "Yenilənir 06:12:40" | 7.3 | daily rotation at a fixed time | — |
| 13 | Yaqut packs **500 = 4,99 ₼**, **1 200 = 9,99 ₼ (+20%)**, **2 000 = 19,99 ₼** | 7.3 | 3 packs; AZN prices; 2 000 pack gives less per ₼ than 1 200 | — |
| 14 | Shortfall **−1 480** → offer **2 000** pack | 7.4 | smallest pack ≥ shortfall; buy + spend in one flow | — |
| 15 | Premium pass **950 yaqut** | 7.1 | pass bought with Yaqut (one-off per season) | — |
| 16 | Season: **50** levels, **1 000** XP/season level, "18 GÜN 6 SAAT" left | 7.1, Home | season-pass XP separate from player XP | — |
| 17 | Free track **200 / 300 sikkə**, premium track **50 yaqut** | 7.1 | free track gives coins (OK, ADR-022); premium track gives Yaqut (confirm) | — |
| 18 | Season-end Almaz: frame + **2 000 sikkə** | 7.1 | season-end coins by rank (OK, ADR-022) | — |
| 19 | Match win: **+250 sikkə, +120 XP** (ranked, 5-point match, 5–2) | 2.6 | rewards scale with match length? | ranked win 60 coins / 40 XP (+10/+5 mars bonus) |
| 20 | Level **24**, next level needs **1 500 XP** | 12.3, Home | XP curve | base 100 + 50·(n−1) → 1 250 at level 24 |
| 21 | Level 24 reward **+200 sikkə + Ametist zər (Epik)** | 12.3 | level-ups give coins and items | 20·level = 480 coins, no item |
| 22 | Home XP bar 64% at Səv. 24 | 2.1 | — | — |
| 23 | Login streak **+20, +30, +40, +50, +60, +80**, day 7 **Sandıq** | 12.2, 12.1 ("Sabah: +80") | 7-day cycle; miss a day → back to day 1 | [20, 30, 40, 50, 60, 80, **150**] |
| 24 | Daily missions: 3 dubl at → **+40** · Reytinq oyunu qazan ×**3** → **+60** · Kubu qəbul et və qazan ×**1** → **+80** · Məşq tapmacası ×**2** → **+30** · Uzun nərd oyna ×**1** → **+30** | 12.1 | **5** daily missions; rewards coins (currency not shown) | 3 daily: play 3 (50c/30xp), win 2 (80/40), mars 1 (100/50) |
| 25 | Daily chest for all **5** missions | 12.1 | bonus for completing all | — |
| 26 | Mission reset "06:42:10" | 12.1 | daily reset at a fixed time (differs from #12) | period = calendar date |
| 27 | "3 oyunda mars et" target **3** (Home 2/3, 2.6 3/3) | 2.1, 2.6 | daily mission | mars target 1 |
| 28 | "5 reytinqli matç qazan" **2/5** | 2.6 | weekly mission | weekly ranked win 5 (400c/200xp) |
| 29 | Achievements **80** total (34 done) | 8.2 | catalog size | 5 defined |
| 30 | "10 seriya", "1000 oyun", "Uzun yol" 60% | 8.2 | streak / games-played achievements | wins 1/10/100, mars 10, ranked wins 25 |

---

## 11. Phase-4 data the screens need (summary for API/protocol)
Wallet (coins, gems) · inventory with source (store/season/tournament/level/
achievement) · item catalog with per-locale name/description, rarity,
price_coins/price_gems, set membership, obtain sources, asset url/version ·
loadouts (named, active) · opponent cosmetics preference · store offers
(featured with end time, daily picks with rotation time, old price) · IAP
products (ids ↔ pack size, bonus %) · purchase receipts (reference like
"NA-7F3K-2291") · player level/xp/next · missions (daily/weekly, progress,
target, reward, claimed) + reset time · daily chest state · login streak
(day, claimable, rewards table) · achievements (progress %, unlocked) ·
titles (owned, selected) · match-result rewards (coins, xp, mission deltas,
level change) · opponent loadout in the match payload.

---

## 12. Ambiguities / open questions
1. **Loot boxes**: "Günlük sandıq" (12.1) and the day-7 "Sandıq" (12.2) are
   chests with unknown contents. Spec §8.7 / brief: no loot boxes → contents
   must be fixed and shown (or plain coins; placeholder day 7 = 150 coins);
   consider renaming away from "sandıq".
2. **Locker vs Store navigation**: both are drawn under the Mağaza tab; no
   switch between them is designed (segmented "Mağaza | Dolab"? Dolab entry
   from Profil?).
3. **Currency of prices**: Locker tiles, daily picks and the featured button
   show bare numbers; seeder mixes coin and gem prices. Which items cost
   coins vs yaqut, and show the glyph everywhere.
4. **Item vs set**: 3.2 shows Marble Royale with "Kral dəsti · 4 əşya" and
   price 1 800 — is 1 800 the board or the set? Partial-ownership pricing for
   sets is undefined.
5. **Equipped vs previewed**: mock = 2px `accentHi` ring for previewed, ✓ for
   equipped; `RarityFrame.jsx` = 2px ring + ✓ for equipped. Pick one.
6. **Caspian**: Locker "Sezon · Səv. 30" vs 7.1 premium track level 19 vs
   seeder 400 gems (buyable). Seasonal items: buyable or pass-only?
7. **Yaqut pack values**: 2 000 for 19,99 ₼ is worse value than 2 × 1 200 for
   9,99 ₼; likely 2 500 / "+25%". Final prices come from the stores anyway.
8. **Premium pass** priced 950 yaqut in 7.1: confirm it is bought with Yaqut
   (not a direct IAP product), and that "50 yaqut" on the premium track is
   allowed (ADR-022 bans only coins there).
9. **7.4 states** not designed: enough balance, coin price, busy, IAP
   cancelled/failed/pending, offline; and the generic copy for single items
   ("dəsti" is set-specific).
10. **Purchase success for packs** (no item) not designed; receipt id format
   "NA-…" not defined.
11. **Rewards for offline/bot games**: are coins/XP/missions earned vs
   computer (offline, untrusted), vs BOT (online), pass & play? Proposal:
   online only; casual/bot reduced (placeholder already does this).
12. **Mission rewards**: currency not shown (+40 = coins?); do missions also
   give XP (placeholder: yes)? Weekly tab content and mission icons not
   designed. "Məşq tapmacası" needs Phase 6 puzzles.
13. **Home mission card** "GÜNLÜK MİSSİYA · 2/3": mission progress or 2 of 3
   missions done? Green bar there vs brass in 12.1. Daily missions = 3
   (placeholder) or 5 (12.1)?
14. **Two reset timers** (06:42:10 missions, 06:12:40 store): one server reset
   time or two? Timezone (UTC vs Baku, UTC+4)?
15. **Streak**: what happens after day 7 (repeat?); day boundary/timezone;
   modal dismissible without claiming?; guests eligible?; ordinal suffixes in
   the mock are wrong for days 3, 4, 6 (spec uses per-day keys).
16. **XP curve / level cap**: 1 500 XP at level 24 vs placeholder formula
   (1 250); max level; Home bar meaning (XP within level).
17. **Level-up reward item** ("Ametist zər"): level rewards table not
   designed; "Zəri indi tax" needs per-category accusative forms.
18. **Achievements**: hex color meaning (tier? category?); locked vs 0%
   (opacity .45 only at 0%); detail sheet and coin rewards not designed;
   80 achievements implied, 5 defined; later-phase ones should be hidden.
19. **Titles**: "Yeni başlayan" drawn dim — locked or the default/no-title
   option? Where titles show besides 8.1 (PlayerCard, VS) is not designed.
20. **8.2 entry** from 8.1 is not drawn (8.1 only has "KUBOK VİTRİNİ ·
   Hamısı", which is trophies).
21. **Missions screen chrome**: root title without back button but reached
   from Home (pushed) → add a back chevron or make it a Home sub-tab.
22. **Asset spec covers landscape only**: frame 640×460, field 252×420,
   points 181 high; portrait (566 → frame 640×566, field 252×526, points 226)
   is missing. Stretch/9-slice or a second set?
23. **Cube ×7** but values 2–64 are six (2, 4, 8, 16, 32, 64); the 7th is
   unclear (blank "64" centre face? offer size 56?). Mocks draw one shared
   ivory cube for every theme.
24. **Roll atlas**: layout not given; 12 frames @30 fps = 400 ms vs dice
   motion 800 ms (fast 300 ms).
25. **Sound pack** contents/file names not specified (OGG 48 kHz −14 LUFS
   only).
26. **Fon (table background)**: replaces only the GameScreen background, or
   menus too? `bg_{theme}` (430×932) vs the UI-theme backgrounds (sebeke
   gradient + lattice).
27. **Opponent cosmetics**: one shared board — when "show opponent
   cosmetics" is on, which parts are the opponent's (their checkers/dice
   only?). Needs loadout ids in the match payload.
28. **3.2 sheet frame** (full width, top 84, radius 28) ≠ `showNardSheet`
   (inset 8, radius 24).
29. **Currency pill and coin glyph variants** (4 pill styles, 3 coin
   gradients) → one CurrencyPill / CurrencyIcon.
30. **Number formats**: "3 / 3" (12.1) vs "3/3" (2.6, Home); "{n} XP" has no
   localized word while 2.6 says "təcrübə".
31. **Locker categories** with no Phase-4 content (Zər qabı, Fon, Səslər,
   Emote, Avatar çərçivəsi, Qələbə effekti): hide or show empty state?
   Loadout rename/delete, max loadouts, explicit "Saxla" vs auto-save not
   designed.
32. **3D tilt preview** (`rotateX(24°)`) and Flame textures in 9 tiles + board
   may be heavy; static thumbnails per item (catalog image) recommended.
33. **Theme ids** (design keys vs code ids) and `BoardTheme.asset()` path/
   extension must change before packs exist (§1.2).
34. **Rarity "Tournament-exclusive"** (spec §8.6) has no color/label in the
   design (Şuşa Xatəmi is Epik + "Turnir mükafatı").
