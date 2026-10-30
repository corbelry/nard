# NardArena Design System

Premium, cross-platform **backgammon / nard** mobile game (Short Nard + Long Nard), built in **Flutter + Flame**.
Concept: *Modern Caucasian luxury*. The warmth of a handcrafted wooden nard set (walnut, inlay, brass, felt) in a calm, dark, modern UI.
Working title "NardArena" is a placeholder and can be swapped.

**Sources:** the product brief (pasted in chat) and the HTML design references in this project. There is no existing codebase, Figma file or logo; the wordmark and icon in `guidelines/brand-wordmark.html` are placeholders.

## Index
| Path | What |
|---|---|
| `styles.css` | Global entry, `@import` only |
| `tokens/` | CSS custom properties: colors, themes, typography, spacing, effects, motion, board |
| `flutter/lib/theme/` | **Dart mirror of the tokens**: `nard_tokens.dart`, `nard_colors.dart` (ThemeExtension), `nard_theme.dart` (ThemeData), `board_theme.dart` (geometry + 6 cosmetic sets) |
| `flutter/tokens.json` | Same tokens as JSON (for codegen) |
| `components/` | React reference primitives (jsx + d.ts + prompt.md): core, game, commerce, navigation |
| `guidelines/` | Foundation specimen cards |
| `ui_kits/nardarena-mobile/` | Index of full-screen references |
| `*.dc.html` (root) | Full hi-fi screen references: `NardArena Dizayn Sistemi` (directions, board states, tokens), `Ekranlar 2–6` (all other screens), `GameScreen`, `Board`, `PlayerCard` |
| `SKILL.md` | Agent-skill entry for Claude Code |

**Components:** Button, IconButton, Chip, SegmentedControl, Switch, ProgressBar, Die, Checker, Clock, RankBadge, PlayerCard, StatusBanner, CurrencyPill, RarityFrame, TabBar, Sheet.

## Platform rules (Flutter)
- **Mobile only.** Phone portrait 390×844 is primary, phone landscape 844×390 for the board. Tablet is a scaled-up version of the same layouts. No web or desktop.
- The **board keeps its traditional horizontal orientation** in portrait: edge to edge at 378pt, 6pt gutters. All game controls sit in the bottom thumb zone (one-handed).
- The board is rendered in a **640 × H logical space** (H = 566 portrait, 460 landscape) and scaled uniformly. See `BoardGeometry`.
- Legal-move highlights, ghost checkers, the selection ring, last-move markers and point numbers are **drawn in code**, not baked into textures.
- Use `context.nard.*` for semantic colors and never hard-code palette values in widgets.

## CONTENT FUNDAMENTALS
- **Primary language Azerbaijani** (AZ). Localized into TR, RU and EN. RU and TR strings run longest, so always test overflow (ellipsis on names; labels may wrap to two lines, buttons may not).
- **Voice:** a calm, respectful club host. Short, plain sentences. Address the player as informal *sən* ("Sənin növbən", "Qəbul etsən, kub sənə keçir").
- **Casing:** sentence case for buttons and titles (Təsdiqlə, Növbəti oyun). UPPERCASE only for small overlines and meta lines, with 0.06em tracking ("QISA NƏRD · 7 XALA QƏDƏR", "● CANLI · RAUND 3"). The `komur` theme uppercases button labels.
- **Separators:** a middle dot " · " between meta items. An en dash for scores ("3 – 1"). Arrows for change ("1 → 2 xal", "1842 → 1866").
- **Numbers:** tabular figures everywhere. The thousands separator is a space ("12 450").
- **Core vocabulary:** Oyna, Zər at, Təsdiqlə, Geri al, İkiqat, Qəbul et / İmtina et, Təslim ol, Mars (gammon), Koks (backgammon), Pip, Qısa nərd, Uzun nərd, Turnirlər, Klan, Mağaza, Profil, Dolab (locker), Taxta, Daşlar, Zər.
- **Tone around play:** during a game the UI is quiet and informational ("Rəqib düşünür", "Mümkün gediş yoxdur"). Around play it can celebrate: "Qələbə", "Matç qələbəsi", "Çempion". Even then keep it to one big word plus facts.
- **No emoji.** No exclamation marks in system copy (quick-chat phrases are the exception).

## VISUAL FOUNDATIONS
- **Color:** deep walnut (#2B1D14) and charcoal grounds, ivory ink (#F3EBDD), **brass** (#C9A24A) as the single action accent, **garnet** for danger and low time, **emerald** for success. Rarity colors share the same oklch L/C and vary only in hue. Text contrast is WCAG AA. Brass and garnet are never used as text on light grounds (use brass-700 / garnet-600 there).
- **UI themes** (`data-theme` / `NardColors`): **`sebeke` (DEFAULT, 1c): garnet pill primary with a brass inner ring, şəbəkə lattice header band, Noto Serif button labels, xatəm-inlay board frame.** Alternatives: `ceviz` (1a, brass gradient primary), `komur` (1b, flat tournament style with condensed caps), `light` (menus only). Brass stays the accent for selection, highlights and links in every theme.
- **Type:** Noto Serif Display for titles, scores and celebrations. IBM Plex Sans for all UI and numbers. Plex Mono only for codes and specs. Both families cover ə ğ ı ö ü ç ş and Cyrillic.
- **Backgrounds:** sebeke = a vertical garnet-black gradient (#24161b → #17121a → #1f1317) with a şəbəkə lattice band fading out of the top 300pt; ceviz = a soft radial walnut gradient. Never flat black. Celebration screens add a warm brass radial glow. No photography in chrome; imagery is item renders and trophies.
- **Ornament (level 3/10):** şəbəkə lattice (60° / −60° hairlines at 11% brass) in header bands, the diamond-and-hairline divider, and xatəm inlay stripes on board frames. **Never on the playing field.**
- **Board realism:** wood grain, inset shadows, brass hinges, bevelled checkers with concentric grooves, ivory dice with recessed pips. Menus stay flat (no skeuomorphism outside the board).
- **Cards:** `surface` tint (ivory at 6%) plus a 1px brass hairline ring at 24%, radius 16 (8 in komur, 14 in sebeke). There are no drop shadows on resting cards; shadows are reserved for floating layers (sheets, toasts, dialogs).
- **Buttons:** primary (sebeke) = garnet gradient pill with a 1px brass inner ring, a soft garnet glow and an ivory label (ceviz: brass gradient). Secondary = 1.5px brass ring. Ghost = text only. Danger = solid garnet. Heights 56 / 48 / 40. **Press** = scale 0.97 over 90ms, no color flash, no ripple (`NoSplash`). Disabled = surface fill with faint text.
- **Selection:** a brass-tint fill with a 1.5px brass ring (chips, options, radio rows). The legal-move state is brighter brass (#F0CD6E): triangle fill, dashed ghost checker and glow ring.
- **Sheets:** inset 8pt from the screen edges, 24pt top radius with a drag handle, over a 60% black scrim. Used for every in-game decision (cube offer, resign, menu).
- **Transparency and blur:** scrims only; avoid backdrop blur on the game screen for performance.
- **Motion:** quick and physical. The checker slides on an arc (280ms), a hit sends the checker to the bar with ease-in-back, and dice bounce twice (800ms, fast mode 300ms). The rating counter runs over 1200ms with ease-out-expo. Respect reduce-motion: dice resolve instantly and checkers move in 120ms linear.
- **Low time:** the clock turns garnet with a glow, the screen edge gets a red vignette, and a haptic tick fires every second below 10s.
- **Accessibility:** color-blind mode adds a ring to ivory checkers and a brass dot to onyx checkers. Large-pip dice are optional. Minimum hit target is 44pt.

## ICONOGRAPHY
- **Line icons, 2px stroke, round caps and joins, 20–22px**, in currentColor. Substitute: **Lucide** (CDN / `lucide_icons` Flutter package), which is the closest match to the inline paths used in the mocks. *No proprietary icon set was provided; this is a flagged substitution.*
- Game-specific glyphs (dice, cube "2", bar, bear-off, pip) are drawn as simple shapes, never emoji.
- Currency: coin = gold radial disc, gem = garnet rotated square.
- Rank badges are hexagons; clan emblems are clip-path shapes (shield, hexagon, octagon, circle, diamond, banner, star, arch).
- No emoji or Unicode pictographs, except ✓ inside small badges.

## Intentional additions
- **StatusBanner:** one-line turn status, needed by every game state.
- **Die / Checker:** reference renders of the Classic Walnut look; production uses Flame sprites.
