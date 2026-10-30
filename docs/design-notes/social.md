# Social & clans: implementation spec (Phase 5)

Source: `.claude/skills/nardarena-design`: `Ekranlar 2` (2.7), `Ekranlar 5`
(6.1–6.4), `Ekranlar 4` (5.1–5.7; tournaments 4.x are Phase 6), `Ekranlar 7`
(14.1–14.4), `Ekranlar 8` (19.1, 19.2), `PlayerCard.dc.html` (emote button),
`GameScreen.dc.html` (Long Nard "Söhbət" control), `TabBar.dc.html` (Klan
tab), `readme.md` (emblem shapes, no emoji). Siblings: `screens.md` (chrome),
`game.md` (GameScreen, sheets), `online.md` (Avatar, RankBadge, FlagSwatch,
NardTextField, 15.1 privacy rows), `store.md` (CurrencyIcon/PriceTag, coin
price rules). This file only adds what they lack. Frame 390×844 portrait,
logical px.

Product rules that override the mocks:
- **No free text during games** (spec §8.5, anti-toxicity): players exchange
  emote and quick-phrase **ids** only (`chat.emote`, `Emotes` in
  `nard_protocol`). Applies to every online game, ranked or not; the 6.4
  spectator text chat conflicts with this (§13.4).
- **Block & report** everywhere a player is shown (spec §8.5).
- **Clans** per spec §8.4: creating costs **coins**; coins are earn-only, so
  there is no "buy coins" path when the balance is short (ADR-022). Roles
  Leader / Co-leader / Elder / Member, join policy open / request /
  invite-only, min rating, language, clan chat with moderation + report, clan
  XP & level, leaderboard, weekly clan wars (assigned matches, total points),
  coin donations to a shared chest. Chests give **fixed, visible** rewards
  (ADR-034/035, no loot boxes).

---

## 0. Conventions

Same as `screens.md` §0 / `online.md` §0 / `store.md` §0: aliases `text`,
`text@a`, `dim`, `accent`, `accent@a`, `accentHi`, `line`, `surfaceRaised`,
`danger`, `dangerText`, `success`/`successText`, `ivory100`, `walnut900`;
`c.` = `context.nard`; **overline** = `NardType.caption` w600 letterSpacing
.72 (.06em), stored uppercase in ARB; "*(no token)*" = raw value;
"*(inferred)*" / "*(proposal)*" = not in the mock.

Mock colour mapping used below: `#C9A24A` / `#D4AE58` = `accent`;
`#E8C468` = `accentHi`; `#34251a` (ceviz walnut800) and `#2a1a20` (sebeke) =
`c.surfaceRaised`; `#1b120c` flat screen = theme background `c.bg`;
`#2B1D14` panels on the game screen = `c.bg` (mock walnut900);
`#231709` / `#1d1316` on solid brass = `c.onAccent`; `#3FB57F` =
`successText`; `#E0566C` = `dangerText`; `#9E1B32` = `danger`;
`#F8F1E4` = `c.primaryText`; `rgba(8,6,5,.55–.62)` = `c.scrim`.

Extra tokens already in `apps/client/lib/ui/extra_tokens.dart` (reuse):
`c.bgGradient`, `c.profileBg`, `c.onAccent`, `c.onDanger`, `c.textFaint`,
`c.lineSoft` (accent@.16), `c.surfaceSunken` (black@.25), `c.codeBox`
(black@.3), `c.scrim`, `c.tile` (text@.05), `c.tileRing` (accent@.18),
`c.selectedFill` (accent@.16), `c.errorTitle` (#F3B0BC), `c.pillFill`
(text@.06), `c.brassRing`, `c.avatarMe/Opponent/Bot`, `c.tierStops(tier)`,
`c.coinFill`, `c.elevation2/3`, `c.primaryGlow`, `c.primaryRing`.

New raw values in this file (*no token*; add to `extra_tokens.dart`):

| Use | Value |
|---|---|
| Private room bg (6.3) | radial `90% 45% at 50% 35%`: `#4A321F` → `#1B120C` 70% |
| Clan profile bg (5.2) | radial `90% 40% at 50% 18%`: `danger@.35` → `#2B1D14` 60% → `#1B120C` (tint = the clan's primary colour, *proposal*, §13.20) |
| Clan war bg (5.6) | linear 90°: `danger@.3` 0 → transparent 45% · transparent 55% → `rgba(38,52,110,.35)` 100%, over `#1B120C` (left = my clan colour, right = opponent clan colour, *proposal*) |
| Clan leaderboard bg (5.7) | radial `90% 40% at 50% 20%`: `accent@.22` → `#1B120C` 70% (= `c.profileBg` with centre 20%) |
| Emblem preview glow (5.3) | radial circle `accent@.14` → transparent 60% (= `c.lockerGlow` family) |
| Emote wheel disc (2.7) | 280 circle: radial, `#2B1D14` 0–32% (hub), `rgba(52,37,26,.96)` from 32.5% (ring); ring 1px `accent@.35`; shadow `0 20 50 black@.5` |
| Emote slot hover | fill `accent@.25`, ring 2px `accentHi`, glow `0 0 16 accentHi@.5` |
| Presence dot | online `successText`, in game `accentHi`, offline `text@.3`; 2px ring in the screen bg colour |
| Clan role badge | Lider: fill `accent@.22`, text `accentHi` · Müavin / Ağsaqqal: fill `danger@.25`, text `c.errorTitle` · Üzv: fill `text@.06`, text `text@.6` |
| Chat bubble | others: fill `text@.08`, radius `16 16 16 4`; mine: fill `accent`, text `c.onAccent`, name `c.onAccent@.7`, radius `16 16 4 16` |
| War result pill | finished `accent@.14` / `accentHi` · live `dangerText@.16` / `dangerText` · scheduled `text@.05` / `text@.6` |
| Clan chest glyph (5.4) | 36×32, radius `6 6 4 4`, linear 180° `#C9A24A` → `#6E4224` (drawn, not an icon) |
| Podium pedestal (5.7) | linear 180° tier light → dark: gold / silver / bronze = `c.tierStops(Tier.gold/silver/bronze)` |
| Spectator LIVE pill | fill `dangerText@.16`, text `dangerText` (same as tournament "CANLI") |
| Sheet top hairline (14.1/14.3) | `inset 0 1 0 accent@.4` (same as 15.2/15.3; use `showNardSheet`, §13.25) |

### 0.1 New shared widgets (put in `apps/client/lib/ui/`)
- **ClanEmblem** (`social.dart`): clip-path shape (§6.3 data) filled with the
  colour's 160° gradient; optional pattern overlay; optional inner outline
  (same shape inset 6 at 96 px / 10 at 170 px, ring 2/3 px `accentHi`);
  centre = symbol (outline glyph in `accentHi`, stroke ≈ size/32) **or**
  initials (Noto Serif 700, ≈ 0.28×width: 13 at 48, 14 at 46, 18 at 64).
  Sizes used: 30×34, 40×46, 46×52, 48×54, 64×74, 96×110, 170×196 (shield
  aspect 1:1.15; octagon/circle 1:1). Pure data → painter; no images.
- **PresenceAvatar**: `Avatar` + presence dot (12 at 42, 11 at 36; offset
  right −1 bottom −1; 2px ring in the bg colour). Friends/members use a
  **flat** ring `1.5px accent@.5` (6.1) or none (5.5), not the brass conic.
- **UnderlineTabs** (5.3, 5.4): equal-width tabs h 40/42, 14px; selected
  w600 `accentHi` + bottom bar 2px `accent` (inset shadow in the mock);
  unselected w500 `text@.6`; container bottom border 1px `accent@.16`,
  margin h 16. (Same as 6.5 leaderboard tabs, Phase 6.)
- **FilterChip** (5.1) = DS Chip: h 30, padding h 12, pill, 12px; selected
  fill `accent@.18` + ring 1px `accent` + `accentHi` w600; else ring 1px
  `accent@.24` + `text`.
- **ChoiceChip (solid)** (19.2 languages): h 34, padding h 14, pill, 13 w600;
  selected fill `accent` + `c.onAccent`; else fill `text@.06` + ring 1px
  `accent@.2` + `text@.75`. Multi-select.
- **SmallActionButton** (6.1, 6.2, 5.1): h 36 (5.1: 34), padding h 14, radius
  10, 13 w600; `solid` = fill `accent` / `c.onAccent`; `outline` = ring 1px
  `accent@.4` / `accentHi`; `strong outline` = ring 1px `accent` /
  `accentHi`; `disabled` = ring 1px `text@.15` / `text@.4`.
- **RoleBadge** (5.5): 11 w600, padding `4 8`, radius 6 *(no token)*, colours
  §0.
- **ChatBubble**, **ChatComposer**, **SystemMessagePill** (5.4).
- **CodeCells** (6.3, display only): 6 cells 46×60, radius 12, fill
  `c.surfaceRaised`, ring 1px `accent@.35`, Plex Mono 600 28 `accentHi`,
  gap 8. (Entry of a code reuses `CodeField` from 17.3, letters allowed.)
- **EmoteWheel** + **PhraseChip** (2.7).
- **GroupCard** with radio / check rows (14.2, 19.2) = the 15.2 group card
  (`text@.04` fill — use `c.tile`, ring 1px `accent@.14`, radius 16) + existing
  `RadioDot` (22) + a 22×22 radius 6 checkbox (fill `accent`, Lucide `check`
  14 stroke 3.5 `c.onAccent`; unchecked: ring 2px `text@.3`, *inferred*).
- **RatingSlider** (19.2): track 4 high radius 2 `text@.12`, fill `accent`,
  thumb 22 circle `ivory100` shadow `0 2 6 black@.4`, h 24; end labels 11
  `text@.5` tnum.
- **Podium** (5.7) and **WarScoreboard** (5.6).

---

## 1. 2.7 Emote wheel + quick phrases (GameScreen overlay)

**Purpose:** the only in-game communication (spec §8.5): 8 emotes + 6 quick
phrases, sent as ids. Entry: the emote button on my PlayerCard (portrait
only, `game.md` §3.1: 40 Ø, ring 1px `line`, Lucide `smile` 20 `dim`) and
the Long Nard "Söhbət" control (66×62, `message-square`, `game.md` §1). The
mock is drawn over GameScreen `state="opp"` → usable on the opponent's turn
too.

Layout (full-screen overlay above the game, below sheets):
1. Scrim `c.scrim` (mock `rgba(8,6,5,.62)`). Column, `mainAxis: end`,
   centred, padding-bottom 40 (`max(40, safeBottom + 6)`), gap 22.
2. **Wheel** 280×280 (disc colours §0). 8 slots, each 56 Ø, centred on a
   circle of radius **112** around the centre (140, 140); slot 0 at the top
   (−90°), then clockwise every 45°. Slot: emote art (from the equipped
   emote pack — mock shows a hatched placeholder `text@.07` stripes 135° +
   ring 1px `accent@.25`); hovered slot = §0 "emote slot hover" (mock: slot
   1). Hub label centred, 12 `text@.64`, two lines "Sürüşdür / və burax".
3. **Phrase chips**: wrap, gap 8, centred, padding h 16. Chip h 36, padding
   h 14, pill, fill `c.surfaceRaised`, ring 1px `accent@.3`, 14 `text`.

Interactions:
- **Press-and-hold** the emote button → wheel opens under the finger area;
  drag onto a slot (hover state + `HapticFeedback.selectionClick` on slot
  change), **release** sends; release on the hub / outside cancels. **Tap**
  the button → wheel stays open; tap a slot or chip to send *(inferred)*.
- Tap a phrase chip → send + close. Tap the scrim / system back → close.
- Send = `chat.emote {id}`; the server relays `{id, from}` to both players
  and spectators. Nothing is typed, so no moderation is needed in games.
- **Receiving** is not designed *(proposal)*: a bubble anchored to the
  sender's PlayerCard (emote art 40, or phrase text in a chip like above),
  shows 2.5 s, fades `NardMotion.fast`; muted players (14.1 "Söhbəti
  səssizə al") are dropped client-side.
- Rate limit not designed *(proposal)*: 1 send / 3 s, client greys the button
  for the cooldown; server drops extras.
- Hidden vs the bot (`online.md` 2.4), in pass & play and vs computer
  (offline). Spectators cannot send *(inferred)*.
- Reduce motion: wheel appears without scale-in.

Emote/phrase ids (`nard_protocol` `Emotes`, uncommitted working copy):
emotes `smile, laugh, wow, think, sad, angry, tea, clap` (8 = 8 slots, art
not designed, §13.1); phrases `hello, good_luck, well_played, nice_roll,
oops, thanks, sorry, good_game` (8 ids vs 6 phrases in the design).

| key | az | protocol id |
|---|---|---|
| emoteWheelHint | Sürüşdür\nvə burax | — |
| phraseHello | Salam! | `hello` |
| phraseGoodLuck | Uğurlar | `good_luck` |
| phraseNiceMove | Əla gediş | `well_played` *(mapping proposal)* |
| phraseDice | Zərlər… | `oops`? / `nice_roll`? (§13.2) |
| phraseThanks | Təşəkkürlər | `thanks` |
| phraseGoodGame | Yaxşı oyun | `good_game` |
| emoteButton | Emosiya göndər *(proposal, a11y label)* | — |
| gameChat | Söhbət *(Long Nard control caption; check `game.md` key — not in ARB yet)* | — |

Readme: "no exclamation marks in system copy (quick-chat phrases are the
exception)" → "Salam!" is correct.

Icons: `smile`, `message-square`. Widgets: new `EmoteWheel`, `PhraseChip`;
existing `PlayerCard` (add the emote trailing button), `Pressable`.

---

## 2. Friends

### 2.1 6.1 Friends (Dostlar)
**Purpose:** friend list with presence; invite a friend to a game or watch
their running game. Drawn with TabBar `active="profile"` → lives under the
Profil tab (entry from 8.1 not drawn, §13.9).

Layout (bg `c.bgGradient` + lattice band):
1. **Header row**, padding `4 16 12`, space-between: title "Dostlar"
   `NardType.displayL.copyWith(fontSize: 26)` *(no token)* · add button h 36,
   padding h 14, radius 10, ring 1px `accent`, label 13 w600 `accentHi`
   "+ Əlavə et" (render `+` as Lucide `plus` 14 + gap 4, *inferred*) → 6.2.
2. **List** (scrolls), rows h 64, padding h 16, gap 12, bottom border 1px
   `accent@.08`:
   - PresenceAvatar 42 (ring 1.5px `accent@.5`, initials Noto 16; mock uses
     the teal "me" fill for everyone → per-user avatar, §13.27);
   - column flex gap 2: name 15 w600 (ellipsis); status 12, colour by
     presence: online `successText` "Onlayn", in game `accentHi`
     "Oyunda · Qısa nərd 4–2" / "Oyunda · Turnir", offline `text@.55`
     "2 saat əvvəl" / "Dünən" / "5 gün əvvəl" / "2 həftə əvvəl";
   - action SmallActionButton h 36: online → **solid** "Çağır"; in game →
     **outline** "İzlə"; offline → **outline** "Çağır".
   - Offline rows at opacity .7.
   Order: available (online + in game) first, then offline by last seen
   (mock mixes online and in-game in the top group; sort by name inside,
   matching the API `overview` sort).
3. `NardTabBar` active Profil.

Interactions:
- **Çağır** (online) → create a private room (§3) with my last room settings
  and send the invite to that friend *(inferred; invite transport §12)*;
  push 6.3. **Çağır** on an offline friend: push invite, or disable
  (§13.8).
- **İzlə** → `spectate.join {matchId}` → 6.4. Hidden if the friend's game
  is not spectatable (privacy toggle, tournament rules; §13.10).
- Row tap → 14.1 player menu over the friend's profile header *(inferred)*.
- Pull to refresh; presence refresh via WS `presence.query` every ~30 s
  while visible *(proposal)*.
- Not designed: incoming / outgoing requests (API returns both), friend
  limit (200), empty list. Proposals: a "SORĞULAR" section above the list
  with Accept (solid "Qəbul et") / dismiss (Lucide `x`) per row; empty →
  `MessageState` with "Dost əlavə et" CTA.

### 2.2 6.2 Add friend (Dost əlavə et)
Bg theme `c.bg` (mock flat walnut950). Header `ScreenHeader(bare: true)`:
`chevron-left` 20 + title Noto 20 w600 "Dost əlavə et".
Body padding `8 16`, column gap 22:
1. **Search field** h 48, radius 14, fill `c.surfaceSunken`, ring 1.5px
   `accent` (focused; unfocused 1px `accent@.2`, *inferred*), padding h 14,
   gap 10: Lucide `search` 18 `accent`, input 15, cursor 1.5×20 `accentHi`.
   = `NardTextField` with a leading icon (h 48). API: `GET /users/search?q=`
   min **3**, max **20** chars; debounce 300 ms *(proposal)*.
2. **Result row** (mock shows one; list of up to N, *inferred*): gap 12,
   Avatar 42 (no ring, opponent fill), column flex gap 2: name 15 w600;
   meta 12 `text@.6` "Almaz III · 1990 · Qızıl Zər" (rank · rating · clan
   name); SmallActionButton **solid** "Əlavə et". After tap: becomes
   outline "Göndərildi" (`requested`) or "Dostsunuz" (`accepted`)
   *(proposals)*.
3. **Divider** row gap 12: hairline flex 1px `accent@.2` · "və ya" 12
   `text@.5` · hairline.
4. **QR card**: padding 20, radius 20 *(no token)*, fill `c.surfaceRaised`,
   ring 1px `accent@.2`, column centred gap 14:
   - QR 180×180, radius 14, ivory ground (`ivory100`) with dark modules
     (`walnut900`), opacity .9 (mock is a placeholder pattern). Encode the
     invite link (§12).
   - Caption 13 `text@.7` "Dostun bu kodu skan etsin".
   - Buttons row gap 10, each flex × h 48, radius 14, 14 w600: "Skan et"
     (ring 1px `accent@.3`, `text`) → camera QR scanner; "Linki kopyala"
     (ring 1.5px `accent`, `accentHi`) → copy link + snackbar `copied`.
   The 8-character friend code (API `friendCode`) is not shown as text in
   the mock → *proposal*: Plex Mono 16 w600 `accentHi` letterSpacing .1em
   under the QR, tap = copy (§13.7).

Errors (API → copy, *proposals*): `not_found` "Oyunçu tapılmadı",
`blocked` "Bu oyunçu ilə əlaqə mümkün deyil", `already_friends`
"Artıq dostsunuz", `already_requested` "Sorğu artıq göndərilib",
`too_many_friends` "Dost limiti dolub ({max})", 429 → `authTooManyTries`.

### 2.3 Strings (friends)
| key | az |
|---|---|
| friendsTitle | Dostlar |
| friendsAdd | Əlavə et *(same text as `accountEmailAdd`; use its own key)* |
| presenceOnline | Onlayn |
| presenceInGame | Oyunda · {detail} |
| presenceInGameScore | {variant} {me}–{opp} (`variantShort` existing, e.g. "Qısa nərd 4–2") |
| presenceInTournament | Turnir |
| lastSeenHours | {n} saat əvvəl |
| lastSeenYesterday | Dünən *(capitalised; `dateYesterday` "dünən" exists, lowercase)* |
| lastSeenDays | {n} gün əvvəl |
| lastSeenWeeks | {n} həftə əvvəl |
| lastSeenMinutes | {n} dəq əvvəl *(proposal)* |
| friendInvite | Çağır |
| friendWatch | İzlə |
| addFriendTitle | Dost əlavə et |
| addFriendSearchHint | Ad ilə axtar *(proposal; mock shows typed text only)* |
| addFriendMeta | {rank} · {rating} · {clan} (`profileMeta` existing for the first two) |
| addFriendAction | Əlavə et |
| addFriendOr | və ya |
| addFriendQrCaption | Dostun bu kodu skan etsin |
| addFriendScan | Skan et |
| addFriendCopyLink | Linki kopyala |
| copied | **existing key** (Kopyalandı) |
| addFriendCodeLabel | Dost kodu *(proposal)* |
| friendRequested | Göndərildi *(proposal)* |
| friendAccepted | Dostsunuz *(proposal)* |
| friendRequestsTitle | SORĞULAR *(proposal)* |
| friendAccept | Qəbul et *(proposal; `cubeAccept` in game.md has the same text)* |
| friendsEmptyTitle / friendsEmptyBody | Hələ dostun yoxdur / Adı ilə axtar və ya QR kodunu paylaş. *(proposals)* |
| friendErrNotFound / friendErrBlocked / friendErrAlready / friendErrPending / friendErrLimit | Oyunçu tapılmadı / Bu oyunçu ilə əlaqə mümkün deyil / Artıq dostsunuz / Sorğu artıq göndərilib / Dost limiti dolub ({max}) *(proposals)* |

Icons: `plus`, `chevron-left`, `search`, `x` (dismiss, proposal),
`scan-line` (scanner screen, proposal). Widgets: `ScreenHeader(bare)`,
`NardTextField` (+ leading icon), Avatar/PresenceAvatar, SmallActionButton,
`NardButton` outline, `MessageState`, `NardTabBar`.

---

## 3. 6.3 Private room (Şəxsi otaq)

**Purpose:** host an unrated game with a friend by code (spec §8.5). Entry:
Home mode tile "Şəxsi otaq" (`lock`, `online.md` §7.1), 6.1 "Çağır".
Protocol (working copy): `room.create {variant, matchLength}` →
`room.created {code, expiresAt}`; guest `room.join {code}`; host
`room.cancel`. Code = 6 chars `[A-Z2-9]`.

Layout (bg private-room radial §0, no tab bar):
1. Header `ScreenHeader(bare: true)` "Şəxsi otaq".
2. Body: column centred, flex, padding `30 16 0`, gap 20:
   - Overline "OTAQ KODU": **13** w500 letterSpacing .06em `text@.64`
     (one step larger than other overlines; *no token*).
   - **CodeCells** (§0.1) "N R D 4 8 2".
   - Row gap 10: "Kopyala" and "Paylaş", each h 40, padding h 16, radius 12
     (`NardRadius.m`), ring 1px `accent@.3`, 14 w600 `text` (= `NardButton`
     outline size s). Kopyala → clipboard code + snackbar `copied`; Paylaş →
     system share sheet with the deep link + code *(inferred)*.
   - **Waiting card** (margin-top 16 → 36 from the buttons): full width,
     padding 16, radius 18 *(no token)*, fill `c.tile`-like `text@.04`, ring
     1px `accent@.16`; row gap 16: empty seat 48 Ø (ring 1.5px `text@.3` +
     2px dashed `text@.25`; dashed border needs a painter) · column gap 3:
     title 15 w600 "Dost gözlənilir…"; sub 12 `text@.6` tnum
     "Kod 9:41-də bitir · 14:32 qaldı" (expiry clock time · countdown).
     When the guest joins *(inferred)*: Avatar 48 + name + `profileMeta`,
     sub "Qoşuldu" in `successText`.
   - **Settings list**: full width, top border 1px `accent@.14`; rows
     space-between, padding v 12, bottom border 1px `accent@.1`, 14px: key
     `text@.64` · value `text`. Rows: Variant "Uzun nərd" · Format
     "5 xala qədər" · Vaxt "5 dəq + 15s" · Reytinq "Təsir etmir". Editing is
     not drawn (no chevrons) → *proposal*: rows tappable before a guest
     joins, each opens a `showNardSheet` picker reusing 2.2 tiles.
3. Footer padding `0 16 40`: **Başla** h 56, radius 16; disabled look (fill
   `text@.06`, ring 1px `accent@.2`, label `text@.45` w600 — the 17.3/DS
   disabled mismatch again, §13.26) until the guest joins; then primary.

Interactions: Başla (host) → both get `match.found` → 2.5 VS (unrated, no
rating chip) → GameScreen. Back / leaving → `room.cancel` (confirm sheet
not designed). Code expiry → card turns to "Kodun vaxtı bitdi" + "Yeni kod"
*(proposals)*. **Join by code** (guest side) is not designed (§13.11):
proposal = Home "Şəxsi otaq" opens a chooser sheet "Otaq yarat / Koda
qoşul"; join = `CodeField` (6 cells, letters+digits) + primary "Qoşul".
Deep link `nardarena://room/{code}` / universal link opens the join screen
pre-filled.

| key | az |
|---|---|
| roomTitle | Şəxsi otaq |
| roomCodeLabel | OTAQ KODU |
| roomCopy | Kopyala |
| roomShare | Paylaş |
| roomShareText | NardArena-da mənimlə oyna. Otaq kodu: {code} {link} *(proposal)* |
| roomWaiting | Dost gözlənilir… |
| roomExpiry | Kod {time}-də bitir · {left} qaldı *(suffix harmony on the clock time, §13.29)* |
| roomJoined | Qoşuldu *(proposal)* |
| roomSettingVariant | Variant |
| roomSettingFormat | Format **existing key** `exportFormat` has the same text — use its own key |
| roomSettingTime | Vaxt |
| roomSettingRating | Reytinq **existing key** `statRating` has the same text — own key |
| matchToPoints | {n} xala qədər |
| timeValue | **existing key** ({minutes} dəq + {delay}s) |
| variantLong / variantShort | **existing keys** |
| roomUnrated | Təsir etmir |
| roomStart | Başla |
| roomExpired / roomNewCode | Kodun vaxtı bitdi / Yeni kod *(proposals)* |
| roomCreate / roomJoinByCode / roomJoin | Otaq yarat / Koda qoşul / Qoşul *(proposals)* |
| roomNotFound | Otaq tapılmadı və ya vaxtı bitib *(proposal)* |
| roomCancelTitle | Otaq bağlansın? *(proposal)* |

Icons: `chevron-left`, `copy` / `share-2` (optional leading icons,
*inferred*; mock buttons are text-only). Widgets: `ScreenHeader(bare)`,
CodeCells, `CodeField` (join), `NardButton` (outline s, primary), settings
rows (= `KeyValueRow`), `showNardSheet`.

---

## 4. 6.4 Spectator view (İzləyici görünüşü)

**Purpose:** watch a friend's (or clan war) game live. GameScreen in a
read-only mode (mock: GameScreen `dir="1c" state="opp"` with two overlays).

Deltas vs GameScreen:
1. **Top bar replaced**: h 52 (same slot as the game top bar), fill `c.bg`
   (mock walnut900), content centred: LIVE pill h 30, padding h 12, pill,
   fill `dangerText@.16`, 12 w700 letterSpacing .72 `dangerText`
   "● İZLƏYİCİ · 128" (dot = 6 Ø circle, not a glyph). No menu, no fair-dice
   button (fair-dice for spectators → after the game, *inferred*).
2. Both PlayerCards as in play (clocks run, offline pill, no emote button).
   Board is not interactive; no highlights / ghost moves.
3. **Bottom panel replaces the controls row**: h 130 incl. safe area,
   fill `c.bg`, top border 1px `accent@.16`, padding `12 16 34`, column
   gap 10:
   - Recent spectator messages: one row, gap 6, clipped (newest right,
     scroll horizontally, *inferred*); chip 12px, padding `6 10`, pill, fill
     `text@.06`: **name** w700 `accentHi` "Rauf:" + text "gözəl blok".
   - Row gap 8: input h 44, radius 22, fill `c.surfaceSunken`, ring 1px
     `accent@.2`, padding h 16, placeholder 14 `text@.45` "İzləyici
     söhbəti…" · "Çıx" 44×44, radius 12, ring 1px `accent@.24`, 12 w600.
4. Emotes sent by the players appear as in §1 (receiving).

Interactions: Çıx / system back → `spectate.leave` → previous screen. Game
end → 2.6-like summary for spectators is not designed (proposal: banner
"{name} qalib gəldi · 5–3" + "Çıx"). Spectator count updates live.
**Spectator text chat conflicts with the no-free-text rule** (§13.4):
proposal = spectators use the same phrase chips as §1 (ids only, never
shown to the players); free text only if PO accepts moderation.
Spectate delay not designed (§13.5).

| key | az |
|---|---|
| spectatorLive | ● İZLƏYİCİ · {count} *(draw the dot as a shape; store "İZLƏYİCİ · {count}")* |
| spectatorChatHint | İzləyici söhbəti… |
| spectatorLeave | Çıx **existing key** `leaveConfirm` has the same text — own key |
| spectatorChatName | {name}: |
| spectatorGameOver | {name} qalib gəldi · {score} *(proposal)* |
| spectatorUnavailable | Bu oyunu izləmək mümkün deyil *(proposal)* |

Icons: none new. Widgets: GameScreen (`spectator: true` mode), StatusBanner
(still shows turn status, *inferred*), PhraseChip, `NardTextField` (pill
variant h 44 radius 22, if free text is kept).

---

## 5. Player menu, report, block (Ekranlar 7 · 14.x)

All four are sebeke-raw mocks (`#D4AE58` accent, `#2a1a20` sheets). Entry
points *(inferred; not drawn)*: tap an opponent's PlayerCard (in game and on
2.6), a friend row (6.1), a member row (5.5 "Profilə bax" → profile → menu),
a chat bubble long-press (5.4), a search result (6.2).

### 5.1 14.1 Player menu (Oyunçu menyusu)
Background: the player's mini profile, padding `40 16 0`, column centred
gap 10: Avatar 96 (brass ring `c.brassRing`, padding 4, opponent fill,
initials Noto 36) · name Noto 24 w600 "Kerem_TR" · meta 13 `text@.7`
"Platin I · 1867" (`profileMeta`). Over it scrim `c.scrim` (.6) and the sheet.

Sheet (use `showNardSheet`; mock = full width, radius 24 top, padding
`10 16 36`, fill `c.surfaceRaised`, top hairline `accent@.4`, handle 40×5
radius 3 `text@.25` + margin-bottom 6), column gap 10:
1. Group card radius 16, fill `text@.04`, ring 1px `accent@.14`; rows h 52,
   padding h 16, gap 14, bottom border 1px `accent@.08`, 16px, icon 20
   stroke 2:

| Row | Icon (Lucide) | Colour / weight | Action |
|---|---|---|---|
| Dost əlavə et | `user-plus` | `text` w500 | `POST /friends/requests {userId}` → toast "Göndərildi" |
| Oyuna çağır | `dice-3` (mock: square + 3 pips) | `text` w500 | create private room + invite (§3) |
| Söhbəti səssizə al | `volume-x` | `text` w500 | local mute of this player's emotes/phrases/chat |
| Şikayət et | `flag` | `dangerText` w600 | → 14.2 |
| Blokla | `ban` | `dangerText` w600 | → 14.3 |

2. "Ləğv et" h 56, radius 16, ring 1px `accent@.3`, 16 w600 (= `NardButton`
   outline l).

Context rules *(inferred)*: already friends → hide "Dost əlavə et" (or
"Dostluqdan çıxar", not designed); during a ranked game → hide "Oyuna
çağır"; muted → row reads "Səsini aç"; blocked → "Bloku götür"; bot → no
menu.

### 5.2 14.2 Report reason (Şikayət səbəbi)
Pushed screen, bg `c.bg` (mock walnut950). Header `ScreenHeader(bare)`
title "Kerem_TR-i şikayət et" (accusative suffix depends on the name,
§13.29). Body flex, padding `6 16 0`, gap 12:
1. Overline "SƏBƏB" `text@.55`, padding-left 4.
2. Radio group card (radius 16, fill `text@.04`, ring 1px `accent@.14`),
   rows min-h 50, padding h 14, gap 12, bottom border `accent@.08`: label
   15 flex · `RadioDot` 22 (selected: ring 2px `accent` + dot 10 `accent`;
   unselected ring 2px `text@.3`). Selected row fill `accent@.1`. Six
   reasons (first selected in the mock; default none + disabled CTA,
   *inferred*):

| az | API `reason` |
|---|---|
| Təhqiramiz söhbət | `abuse` |
| Qeyri-münasib ad və ya avatar | `name` |
| Kömək proqramı istifadəsi | `cheating` |
| Qəsdən vaxt uzatma | `stalling` |
| Oyunu qəsdən tərk etmə | **missing in API** (add e.g. `leaving`, §13.13) |
| Digər | `other` |

3. Note field: h 84 (multi-line, 3 lines), radius 14, padding `12 14`, fill
   `c.surfaceSunken`, ring 1px `accent@.2`, placeholder 14 `text@.45`
   "Əlavə qeyd (istəyə görə)". API `note` max **500** → `maxLength: 500`
   with counter when > 400 *(proposal)*.
4. Checkbox row, padding h 4, gap 12: box 22 (checked in the mock) +
   "Bu oyunçunu da blokla" 15.
5. Disclosure 12/17 `text@.55`, padding h 4: "Son oyunun qeydi və söhbət
   şikayətə avtomatik əlavə olunur. Kerem_TR şikayətçinin kim olduğunu
   görməyəcək."
Footer padding `16 16 40`: primary l "Şikayəti göndər".
→ `POST /reports {userId, reason, matchId?, note?}` (+ `POST /blocks/{id}`
if checked) → 14.4. 429 `rate_limited` (10 / day) → toast *(proposal)*.

### 5.3 14.3 Block confirm (sheet)
Sheet over the caller (mock: over bgGradient), padding `10 20 36`, gap 16:
1. Handle; title Noto 22/28 w600, margin-top 6 (`SheetTitle`)
   "Kerem_TR bloklansın?".
2. Bullets column gap 10; row gap 12: diamond 6×6 rotated 45° **`accent`**
   (15.3 used `dangerText`), margin-top 7 · text 14/20 `text@.8`:
   - "Təsadüfi oyunlarda səninlə qarşılaşmayacaq."
   - "Sənə mesaj, dostluq və oyun dəvəti göndərə bilməyəcək."
   - "Bloku Ayarlar › Hesab və məxfilik › Bloklananlar bölməsindən götürə
     bilərsən."
3. Buttons column gap 10, margin-top 6: **danger** h 56 pill, fill `danger`,
   label `c.primaryText` (DS danger uses `c.onDanger`, fine) "Blokla";
   outline h 56 radius 16 "Ləğv et".
→ `POST /blocks/{userId}` (also ends friendship server-side) → toast
"{name} bloklandı" *(proposal)* → close the menu. If blocked mid-game, the
game continues; emotes from them are hidden *(inferred)*.

### 5.4 14.4 Report sent (full screen)
Bg `c.bg`. Centre column, padding h 36, gap 14, text centred:
- Disc 96, fill `success@.16`, ring 1px `successText@.4`, Lucide `check` 40
  stroke 2.5 `successText` (same success card colours as 10.3).
- Title Noto 24 w600 "Şikayət göndərildi".
- Body 14/21 `text@.7`: "Moderator 24 saat ərzində baxacaq. Nəticə barədə
  bildiriş alacaqsan." + " {name} bloklandı." only if block was checked.
Footer `0 16 40`: outline l "Bağla" → pop back to where the menu opened.
API returns `reference` "R-000123" — not shown in the design (§13.14).

### 5.5 Strings (14.x)
| key | az |
|---|---|
| playerMenuAddFriend | Dost əlavə et |
| playerMenuInvite | Oyuna çağır |
| playerMenuMute | Söhbəti səssizə al |
| playerMenuUnmute | Səsini aç *(proposal)* |
| playerMenuReport | Şikayət et |
| playerMenuBlock | Blokla |
| playerMenuUnblock | Bloku götür *(proposal)* |
| playerMenuUnfriend | Dostluqdan çıxar *(proposal)* |
| cancel | **existing key** (Ləğv et) |
| profileMeta / rankWithSub | **existing keys** |
| reportTitle | {name}-i şikayət et *(per-name suffix, §13.29)* |
| reportReasonLabel | SƏBƏB |
| reportReasonAbuse | Təhqiramiz söhbət |
| reportReasonName | Qeyri-münasib ad və ya avatar |
| reportReasonCheating | Kömək proqramı istifadəsi |
| reportReasonStalling | Qəsdən vaxt uzatma |
| reportReasonLeaving | Oyunu qəsdən tərk etmə |
| reportReasonOther | Digər |
| reportNoteHint | Əlavə qeyd (istəyə görə) |
| reportAlsoBlock | Bu oyunçunu da blokla |
| reportDisclosure | Son oyunun qeydi və söhbət şikayətə avtomatik əlavə olunur. {name} şikayətçinin kim olduğunu görməyəcək. |
| reportSend | Şikayəti göndər |
| reportLimit | Bu gün çox şikayət göndərdin. Sabah yenidən yoxla. *(proposal)* |
| blockTitle | {name} bloklansın? |
| blockInfoMatchmaking | Təsadüfi oyunlarda səninlə qarşılaşmayacaq. |
| blockInfoContact | Sənə mesaj, dostluq və oyun dəvəti göndərə bilməyəcək. |
| blockInfoUndo | Bloku Ayarlar › Hesab və məxfilik › Bloklananlar bölməsindən götürə bilərsən. *(compose from `settingsTitle`, `settingsAccountPrivacy` (existing) and `privacyBlocked` so renames stay in sync)* |
| blockConfirm | Blokla |
| blockDone | {name} bloklandı. |
| reportSentTitle | Şikayət göndərildi |
| reportSentBody | Moderator 24 saat ərzində baxacaq. Nəticə barədə bildiriş alacaqsan. |
| close | **existing key** `purchaseClose` (Bağla) — add a generic `close` |

Icons: `user-plus`, `dice-3`, `volume-x`, `flag`, `ban`, `chevron-left`,
`check`. Widgets: `showNardSheet`, `SheetTitle`, `NardButton` (primary,
danger, outline), Avatar (96, new size), GroupCard + `RadioDot` +
checkbox, `NardTextField` (multi-line), `MessageState`-like success layout.

---

## 6. Clans (Ekranlar 4 · 5.x, Ekranlar 8 · 19.x)

Role names in the design: **Lider** (Leader), **Müavin** (Co-leader),
**Ağsaqqal** (Elder), **Üzv** (Member). 19.2 copy says "Rəhbər və
köməkçilər" instead (§13.15). New tab: **Klan** (TabBar order Əsas ·
Turnirlər · Klan · Mağaza · Profil; Lucide `shield`; Turnirlər stays
hidden until Phase 6). Tab root = 5.1 when clanless, 5.4 when in a clan
*(inferred)*.

### 6.1 5.1 Clan search (Klanlar)
Bg `c.bgGradient` (+ lattice band), TabBar active `clan`.
1. Top block padding `4 16 0`, gap 12:
   - Row space-between: title "Klanlar" Noto 26 w600 · text button
     "+ Yarat" 14 w600 `accentHi` (44 hit area) → 19.1.
   - Search field h 46, radius 14, fill `c.surfaceSunken`, ring 1px
     `accent@.2`, padding h 14, gap 10: `search` 18 `text@.5`, placeholder
     15 `text@.5` "Ad və ya teq axtar".
   - Filter chips row gap 6 (FilterChip): "Dil: AZ" (selected; default = app
     language), "Açıq" (only open clans), "Min. reytinq ≤ 1842" (only clans
     whose minimum I meet; value = my rating in the selected variant).
2. List padding `8 16 0`, scrolls; rows padding v 12, gap 12, bottom border
   1px `accent@.1`:
   - ClanEmblem 46×52 with **initials** (Noto 700 14 `text`);
   - column flex gap 3: row baseline gap 6: name 15 w600 ellipsis + tag
     Plex Mono 500 11 `accent` "[QZR]"; meta 12 `text@.6` tnum
     "Səv. 14 · 42/50 · 2140" (level · members/cap · clan rating);
   - SmallActionButton h 34: open → **solid** "Qoşul"; request → **strong
     outline** "Müraciət"; full → **disabled** "Dolu"; invite-only → not
     drawn (*proposal*: disabled "Dəvətlə").
3. `NardTabBar`.
Interactions: row tap → 5.2. Qoşul → join at once → 5.4. Müraciət → apply
→ button "Gözləyir" *(proposal)*. Search: name or tag, min 2 chars
*(proposal)*, paged. Empty → `MessageState` "Klan tapılmadı" + "Klan
yarat" *(proposal)*.

Mock data (6 clans): Qızıl Zər [QZR] Səv. 14 · 42/50 · 2140 (shield,
garnet, Müraciət) · Xəzər Qartalları [XQ] 12 · 50/50 · 2085 (octagon,
indigo, Dolu) · Şəki Ustaları [ŞKU] 9 · 31/50 · 1910 (hexagon, emerald) ·
Gəncə Nərdçiləri [GNC] 11 · 44/50 · 1880 (shield, brass) · Abşeron 6-5
[A65] 7 · 22/50 · 1760 (circle, purple, initials "65") · Bayıl Gecələri
[BYL] 6 · 18/50 · 1690 (diamond, slate). Note tag "XQ" is 2 letters (< 3,
§13.16).

### 6.2 5.2 Clan profile (Klan profili)
Bg clan-profile radial §0. No header in the mock → add a bare back chevron
*(inferred)*.
1. Hero, column centred gap 8, padding `16 16 18`: ClanEmblem 96×110
   (shield, garnet, inner outline inset 6 / 2px `accentHi`, symbol = diamond
   30 border 3 `accentHi`) · row baseline gap 8: name Noto 26 w600 + tag
   Plex Mono 500 13 `accent` · description 13/19 `text@.7` centred
   "Bakıdan ciddi nərd oyunçuları. Hər cümə klan döyüşü." (user content).
2. **Stats strip**: 4 columns, 1px gaps (grid on a `accent@.16` ground),
   margin h 16, radius 14, clip; cell fill `c.bg` (mock walnut900), padding
   `10 6`, column gap 2 centred: value 16 w600 tnum · label 11 `text@.6`:
   Səviyyə 14 · Üzv 42/50 · Reytinq 2140 · Dil AZ.
3. "TƏLƏBLƏR" overline (`text@.6`, padding-bottom 6), padding `18 16 0`;
   rows space-between, padding v 8, 14px: label `text@.7` · value + "✓"
   `successText` when I meet it (else `dangerText` "✕", *inferred*):
   Min. reytinq "1500 ✓" · Min. səviyyə "10 ✓" · Qəbul "Müraciət ilə".
4. "ƏN YAXŞI ÜZVLƏR" overline (padding-bottom 4), padding `14 16 0`; 3
   rows padding v 8, gap 10: Avatar 32 (ring 1.5px `accent`, initials 13)
   · name 14 flex ("Rauf · Lider") · rating 13 `text@.7` tnum.
5. Spacer; CTA zone `0 16 40`: primary l **"Müraciət et"**.
CTA by state *(proposals)*: open → "Qoşul"; request → "Müraciət et";
pending → disabled "Müraciət göndərildi"; invite-only → disabled
"Yalnız dəvətlə"; full → disabled "Klan doludur"; requirement not met →
disabled "Tələblərə uyğun deyilsən"; already in another clan → disabled
"Əvvəlcə hazırkı klandan çıx"; my own clan → no CTA (or "Klana keç").
Requests are reviewed by Lider/Müavin (19.2 copy).

### 6.3 5.3 Emblem builder (Emblem)
Bg `c.bg`. Pushed from clan settings (Lider/Müavin) and from 19.1 *(inferred;
19.1 has its own compact picker, §13.17)*.
1. Header h 48, padding h 16, three slots: "Ləğv et" 15 `text@.7` · title
   Noto 18 w600 "Emblem" · "Saxla" 15 w600 `accentHi`.
2. Preview h 280, emblem-preview glow §0: ClanEmblem 170×196 with pattern
   (lattice ±60° 2px `accentHi@.22` every 14), inner outline inset 10 / 3px
   `accentHi`, symbol diamond 54 border 5 `accentHi`.
3. UnderlineTabs h 42: **Forma · Simvol · Rəng · Naxış** (Forma selected).
4. Shape grid: 4 columns, gap 10, padding 16; tile square, radius 14, fill
   `c.tile`, ring 1px `accent@.16`; selected ring 2px `accent`; shape 42×48
   inside, filled with the current colour gradient when selected, else
   `text@.4`.
5. Padding h 16, gap 10: overline "ƏSAS RƏNG" (`text@.6`) + swatch row gap
   10: circles 38; selected ring = 2px gap in bg colour + 2px `accentHi`;
   others inset ring 1px `white@.15`.
"Saxla" → `PATCH /clans/{id} {emblem}` (Lider/Müavin). "Ləğv et" discards.
Simvol and Naxış tab contents are not drawn (§13.17).

**Emblem data (catalogue; put in a data file, not code):**

Shapes (CSS `clip-path` polygons, % of the box; 5.3 grid order):

| id | az name *(proposal)* | polygon |
|---|---|---|
| `shield` | Qalxan | `50% 0, 100% 18%, 100% 62%, 50% 100%, 0 62%, 0 18%` |
| `hexagon` | Altıbucaq | `50% 0, 100% 25%, 100% 75%, 50% 100%, 0 75%, 0 25%` (= RankBadge hex) |
| `octagon` | Səkkizbucaq | `30% 0, 70% 0, 100% 30%, 100% 70%, 70% 100%, 30% 100%, 0 70%, 0 30%` |
| `circle` | Dairə | `circle(50%)` |
| `diamond` | Romb | `50% 0, 100% 50%, 50% 100%, 0 50%` |
| `banner` | Bayraq | `0 0, 100% 0, 100% 100%, 50% 80%, 0 100%` |
| `star` | Ulduz | `50% 0, 62% 35%, 100% 38%, 70% 60%, 80% 100%, 50% 76%, 20% 100%, 30% 60%, 0 38%, 38% 35%` |
| `arch` | Tağ | `0 30%, 20% 8%, 50% 0, 80% 8%, 100% 30%, 100% 100%, 0 100%` |

(The readme lists the same 8: "shield, hexagon, octagon, circle, diamond,
banner, star, arch".)

Primary colours (5.3 "ƏSAS RƏNG" swatches) and the 160° fills used on
emblems:

| id *(proposal)* | swatch (5.3) | emblem fill 160° (5.1/5.2/5.6/5.7) | seen in |
|---|---|---|---|
| `garnet` | `#9E1B32` | `#C52F4A → #6E0F20` | Qızıl Zər |
| `indigo` | `#26346E` | `#4A5A9A → #18214A` | Xəzər Qartalları; Qəbələ Dağları (flat `#26346E`) |
| `emerald` | `#1F8A5B` | `#3FB57F → #145A3A` | Şəki Ustaları; Lənkəran Çayı (flat `#1F8A5B`) |
| `brass` | `#C9A24A` | `#C9A24A → #6E4224` | Gəncə Nərdçiləri |
| `purple` | `#7D4FC4` | `#7D4FC4 → #3A1F66` | Abşeron 6-5 |
| `slate` | `#2A2D32` | `#5C6068 → #2A2D32` | Bayıl Gecələri |
| `ivory` | `#F3EBDD` | not drawn (*proposal* `#F3EBDD → #BFB29C`, symbol in `walnut900`) | — |

19.1 offers a different set of 6: `#9E1B32`, `#1F8A5B`, `#C9A24A`,
**`#4F7FD1`** (blue), `#7D4FC4`, **`#2B1D14`** (walnut) — §13.17.
Small list emblems (5.7 rows) use the flat swatch colour, not the gradient.

Symbols (drawn as outline shapes, stroke `accentHi`, never emoji/icons):

| id *(proposal)* | geometry | seen in |
|---|---|---|
| `diamond` | square rotated 45°, outline (border ≈ size/10) | 5.2, 5.3, 5.4, 5.6 |
| `diamond_dot` | rotated square outline (ivory) + filled 10 square `accentHi` in the centre | 19.1 preview |
| `circle` | ring, border 3 at 20 | 19.1 picker |
| `square` | square outline radius 2 | 19.1 picker |
| `initials` | 2 chars, Noto 700 (clan initials or digits "65") | 5.1, 5.6, 5.7 |

Patterns (Naxış): only `lattice` is drawn (±60° 2px `accentHi@.22`
every 14 on the 170 preview — scale the spacing with size); `none`
implied. Others not designed (§13.17).

Inner outline: shown at ≥ 96 px only (5.2, 5.3); small emblems have none.

### 6.4 5.4 Clan home · chat (Klan evi · söhbət)
Bg `c.bgGradient`. Tab root for members (TabBar not drawn in this mock —
5.1 shows it; keep it, §13.21).
1. **Header row**, padding `4 16 12`, gap 12: ClanEmblem 40×46 (symbol 12
   border 2) · column flex gap 2: name `NardType.title` (Noto 19 w600)
   "Qızıl Zər" + "● 18 onlayn" 12 `successText` · Lucide `menu` 22 → clan
   menu sheet (Üzvlər → 5.5, Klan reytinqi → 5.7, Klan profili → 5.2,
   Tənzimləmələr (Lider/Müavin), Klandan çıx — *proposal*, not drawn).
2. UnderlineTabs h 40: **Söhbət · Fəaliyyət · Döyüş · Sandıq** (Söhbət
   selected). Döyüş = 5.6; Fəaliyyət and Sandıq not drawn (§13.22).
3. **Weekly chest card**, margin `12 16 0`, padding `12 14`, radius 14, fill
   `accent@.12`, ring 1px `accent@.3`, row gap 12: chest glyph §0 · column
   flex gap 5: row space-between 13: "Həftəlik sandıq" w600 · "7 400 /
   10 000" tnum `text@.7`; progress h 4 radius 2 track `text@.12` fill
   `accent` (`NardProgressBar`). Tap → Sandıq tab *(inferred)*.
4. **Messages** (flex, reversed list, newest at the bottom), padding
   `14 16`, gap 10:
   - System pill, centred: 12 `text@.55`, padding `5 12`, pill, fill
     `text@.05`: "Rauf klan döyüşündə qalib gəldi · +3".
   - Others: row gap 8, max-width 78%: Avatar 28 (initials 11) + bubble
     (padding `9 12`, colours/radius §0), column gap 3: name 11 w600
     `accentHi`; text 14/19 `text`.
   - Mine: right-aligned, no avatar, name "Sən" (`you`, existing key).
   - Grouping, timestamps, read state: not drawn (*proposal*: time 11
     `text@.45` under the last bubble of a group; day separators as system
     pills "Bu gün" / "Dünən").
5. **Composer**, padding `8 12 34` (`max(34, safeBottom)`), top border 1px
   `accent@.12`, row gap 8: input h 44, radius 22, fill `c.surfaceSunken`,
   ring 1px `accent@.2`, padding h 16, placeholder 14 `text@.45` "Mesaj
   yaz…" · send 44 Ø, fill `accent`, Lucide `arrow-right` 18 stroke 2.4
   `c.onAccent` (disabled at .4 when empty, *inferred*).
Spec §8.4 says "text + emotes": the composer has **no emote button** →
*proposal*: a `smile` icon button (44) left of the input opening the §1
wheel (ids rendered as art/phrases in the chat).
Moderation *(proposals, not drawn)*: long-press a bubble → sheet "Şikayət
et" (→ 14.2 with reason `abuse`, message id attached) / "Səssizə al"
(player) / "Sil" (own message; Lider/Müavin/Ağsaqqal for others, §6.5);
server-side profanity filter + max length + rate limit (§11); blocked
players' messages hidden. Emoji: the mock code strips "👍" from sample
data (readme: no emoji in UI) — decide whether users may type emoji
(§13.23).

### 6.5 5.5 Members & management (Üzvlər və idarəetmə)
Bg `c.bg`. Pushed from the 5.4 menu; no back button drawn (add bare
chevron, *inferred*).
1. Header padding `4 16 10`, baseline space-between: title Noto 22 w600
   "Üzvlər" · count 13 `text@.6` "42 / 50".
2. Rows h 58, padding h 16, gap 12, bottom border 1px `accent@.08`:
   PresenceAvatar 36 (initials 14, dot 11) · column flex gap 2: name 14
   w600 ("Elvin (sən)" for me) · sub 12 `text@.6` "{presence} · {rating}"
   ("Onlayn · 2210", "Oyunda · 2105", "2 saat əvvəl · 1801", "Dünən ·
   1720", "3 gün əvvəl · 1695") · RoleBadge. The row whose sheet is open
   has fill `accent@.1`. Order: role (Lider → Üzv), then rating.
3. **Member action sheet** (`showNardSheet`; mock = inset 8, padding
   `12 20 30`, radius `24 24 42 42`, fill `c.surfaceRaised`, ring 1px
   `accent@.24`, handle 40×4, scrim `c.scrim`): title Noto 18 w600
   "Nigar_88 · Ağsaqqal" (padding-bottom 8); rows h 50, bottom border
   `accent@.1`, 15px:
   - "Profilə bax" `text` → profile (8.1 of another player, with 14.1 menu);
   - "Dostluq matçına çağır" `text` → private room invite (§3);
   - "Müavin et" `accentHi` → promote;
   - "Klandan çıxar" `dangerText` → confirm sheet *(proposal)* → kick.

Role actions (design shows only the four rows above, seen by an
**Ağsaqqal** acting on another **Ağsaqqal** — unlikely to be allowed,
§13.15). Proposed permission matrix (PO to confirm):

| Action | Lider | Müavin | Ağsaqqal | Üzv |
|---|---|---|---|---|
| Accept / decline requests, invite | ✓ | ✓ | ✓ *(proposal)* | — |
| Kick | anyone below | Ağsaqqal, Üzv | Üzv *(proposal)* | — |
| Promote to Ağsaqqal / demote to Üzv | ✓ | ✓ | — | — |
| Promote to Müavin / demote Müavin | ✓ | — | — | — |
| Transfer leadership | ✓ | — | — | — |
| Edit name/tag/emblem/description/policy/min rating/language | ✓ | ✓ (name/tag: Lider only, costs 1 000 coins) | — | — |
| Start / assign clan war matches | ✓ | ✓ | — | — |
| Delete others' chat messages, mute in chat | ✓ | ✓ | ✓ | — |
| Donate to chest, chat, play war | ✓ | ✓ | ✓ | ✓ |
| Leave clan | after transferring or if last member | ✓ | ✓ | ✓ |

Strings for actions not drawn are proposals (§6.9).

### 6.6 5.6 Clan war (Klan döyüşü)
Bg clan-war gradient §0. No header drawn (add bare chevron; reached via
5.4 "Döyüş" tab).
1. Status line centred, padding `6 16 0`: 11 w700 letterSpacing .88 (.08em)
   `dangerText` "● CANLI · BİTMƏSİNƏ 1:42:08" (live; dot = shape).
   Other states not drawn (*proposals*): upcoming "BAŞLAYIR: CÜMƏ 20:00"
   in `accentHi`; finished "BİTDİ · QƏLƏBƏ" / "BİTDİ · MƏĞLUBİYYƏT".
2. **Scoreboard** grid `1fr auto 1fr`, gap 8, padding `18 16`, centred:
   my clan (left: ClanEmblem 64×74 shield + name 14 w600) · centre column:
   score `NardType.displayXl.copyWith(fontSize: 44, height: 48/44)` tnum
   "12 : 9" (colon `text@.4`) + caption 11 `text@.6` "25 matçdan" ·
   opponent (right: ClanEmblem 64×64 octagon with initials "XQ" Noto 700
   18 + name).
3. **Split bar** h 6, radius 3, margin h 16: my share (12/25 = 48%) in my
   clan colour (`#9E1B32`), theirs (9/25 = 36%) in theirs (`#26346E`), rest
   `text@.12` (= unplayed).
4. "MATÇ TƏYİNATLARI" overline (`text@.6`, padding-bottom 6), padding
   `18 16 0`; rows grid `1fr 64 1fr`, gap 8, h 52, bottom border 1px
   `accent@.1`, 13px: my player (left, ellipsis) · pill (12 w600 tnum,
   padding v 4, radius 6, centred; colours §0) · their player (right
   aligned). Winner name w600. Pills: "Bitdi 5–3", "Canlı 2–2", "21:30".
   My own row is not highlighted in the mock (*proposal*: `accent@.1` fill
   + "Oyna" when it is my scheduled match and the time has come).
5. Spacer; footer `0 16 40`: outline (ring 1.5px `accent`, `accentHi`)
   h 54 radius 16 "Canlı matçları izlə · 4" → list of live war matches →
   6.4.
Mock assignments: Rauf–Kamran Bitdi 5–3 · Aysel_A–Ülvi Canlı 2–2 ·
Elvin–Rəşad Canlı 3–1 · Nigar_88–Fidan Bitdi 1–5 · Murad–Elçin 21:30 ·
Günay–Lalə 21:30.
Tap a live row → spectate; finished row → replay *(inferred)*.

### 6.7 5.7 Clan leaderboard (Klan reytinqi)
Bg clan-leaderboard radial §0. No back drawn (add, *inferred*).
1. Title Noto 22 w600 "Klan reytinqi · Sezon 4", padding `4 16 0`.
2. **Podium**, h 210, padding `24 16 0`, row bottom-aligned, gap 10, order
   2 · 1 · 3; column width 106, gap 8: ClanEmblem 48×54 (initials Noto 700
   13; mock clips all three as shields — use each clan's shape) · name 12
   w600 centred lh 15 (2 lines) · pedestal full width, height **96 / 70 /
   52** (1st/2nd/3rd), radius `10 10 0 0`, tier fill (gold/silver/bronze,
   §0), centred column gap 2: place Noto 22 w600 `c.onAccent` · points 11
   w600 `c.onAccent` tnum ("51 940", "48 210", "44 100").
3. Rows (4+), h 54, padding h 16, gap 12, bottom border `accent@.08`: rank
   width 22, 13 w600 `text@.6` · ClanEmblem 30×34 flat colour (no
   initials) · name 14 w500 flex · points 13 tnum. My clan row: fill
   `accent@.14`, name w600 (the mock has the hook, unused) and, when off
   screen, pinned at the bottom like 6.5 *(proposal)*.
Mock rows: 4 Gəncə Nərdçiləri 41 870 · 5 Abşeron 6-5 39 200 · 6 Bayıl
Gecələri 35 640 · 7 Lənkəran Çayı 33 010 · 8 Qəbələ Dağları 30 560.
Season picker / filters (country, language) not drawn.

### 6.8 19.1 / 19.2 Create clan (Klan yarat), two steps
Entry: 5.1 "+ Yarat". Bg `c.bg` (sebeke-raw mock). Header
`ScreenHeader(bare)` "Klan yarat" + trailing step "1 / 2" / "2 / 2": 12 w600
letterSpacing .96 (.08em) `accent`.

**19.1 Name, tag, emblem.** Body flex, padding `6 16 0`, gap 14:
1. Emblem preview centred, padding v 6: **96×96 rounded square radius 24**
   (not a clip shape, §13.17), fill selected colour `#9E1B32`, ring 2px
   `accent`; symbol `diamond_dot` (40, border 4 `ivory100`, centre 10
   `accentHi`).
2. Field "Klanın adı" (label 12 w600 `text@.6`, padding-left 4, gap 6):
   NardTextField h 52 (focused ring 1.5px `accent`), text 16, trailing
   counter 12 `text@.5` "15 / 24" → **max 24 chars**.
3. Field "Teq (3–5 hərf)": h 52, ring 1px `accent@.24` (unfocused), text
   Plex Mono 600 16 letterSpacing 1.6 (.1em) shown as "[ŞRV]" (brackets are
   decoration; input is 3–5 letters, auto-uppercase locale-aware), trailing
   availability 12 w500: "Boşdur" `successText`; taken → "Tutulub"
   `dangerText`; checking → spinner *(proposals)*.
4. Overline "EMBLEM" (`text@.55`, padding `4 4 0`) + grid 5 columns gap 8:
   tiles square radius 14; selected fill = colour + ring 2px `accent`,
   glyph `ivory100`; others fill `text@.05`, ring 1px `accent@.2`, glyph
   `text@.6`; glyph 20×20 border 3 (rhomb / circle / rhomb / square /
   circle — placeholder repeats). Treat as the **symbol** picker; "Daha
   çox" → 5.3 builder *(proposal)*.
5. Overline "RƏNG" + swatches 36 Ø gap 10 (selected ring as 5.3).
Footer padding `16 16 40`: primary l "Davam et" — enabled when name ≥ 3
*(proposal)* and tag valid + free.

**19.2 Join policy, rating, language, price.** Body flex, padding `6 16 0`,
gap 12:
1. Overline "QOŞULMA"; GroupCard radio rows min-h 56, padding `6 14`, gap
   12; title 15 w600 + sub 12 `text@.6`; `RadioDot`; selected row fill
   `accent@.1`. Default **Müraciət ilə** (selected in the mock):
   - Açıq — "Reytinq şərtinə uyğun hər kəs dərhal qoşulur"
   - Müraciət ilə — "Rəhbər və köməkçilər təsdiqləyir"
   - Yalnız dəvət — "Siyahıda görünür, amma qoşulmaq üçün dəvət lazımdır"
2. Row baseline space-between, padding `6 4 0`: overline "MİNİMUM REYTİNQ" ·
   value 15 w700 tnum "1400". RatingSlider (thumb at 40%), end labels
   "Hamı" / "2400+". Range/step not specified (§13.18; proposal: 0 = Hamı,
   then 1000–2400 in steps of 50).
3. Overline "DİL" (padding `6 4 0`); ChoiceChips (multi-select):
   Azərbaycanca · Türkçe · Русский · English (mock: first two selected).
Footer padding `16 16 40`, gap 10:
- Row space-between, 13 `text@.65` tnum, padding h 4: "Balans: 3 450 →
  450" · "Ad sonra 1 000 sikkəyə dəyişir".
- Primary l "Klanı yarat · ●3 000" (coin `CurrencyIcon` 16, gap 10).
  Insufficient coins → disabled + `purchaseNotEnoughCoins` (existing; coins
  are earn-only, no shop link) *(proposal)*.
→ `POST /clans` → 5.4 of the new clan (I am Lider).
Description (spec §8.4, shown on 5.2) is not part of the flow → *proposal*:
optional multi-line field in 19.2 (max 150) or editable later in settings.
Clan level requirement ("Min. səviyyə 10" on 5.2) has no control here
(§13.19).

### 6.9 Strings (clans)
| key | az |
|---|---|
| tabClan | Klan |
| clansTitle | Klanlar |
| clanCreateShort | Yarat |
| clanSearchHint | Ad və ya teq axtar |
| clanFilterLanguage | Dil: {code} |
| clanFilterOpen | Açıq |
| clanFilterMinRating | Min. reytinq ≤ {rating} |
| clanTag | [{tag}] |
| clanListMeta | Səv. {level} · {members}/{max} · {rating} *(`homeLevel` "Səv. {n}" exists; compose)* |
| clanJoin | Qoşul |
| clanApply | Müraciət |
| clanFull | Dolu |
| clanInviteOnlyShort | Dəvətlə *(proposal)* |
| clanPending | Gözləyir *(proposal)* |
| clanEmpty | Klan tapılmadı *(proposal)* |
| clanStatLevel | Səviyyə |
| clanStatMembers | Üzv |
| clanStatRating | Reytinq *(same text as existing `statRating`; own key)* |
| clanStatLanguage | Dil *(same text as existing `settingsLanguage`; own key)* |
| clanMembersValue | {members}/{max} |
| clanRequirements | TƏLƏBLƏR |
| clanReqMinRating | Min. reytinq |
| clanReqMinLevel | Min. səviyyə |
| clanReqPolicy | Qəbul |
| clanTopMembers | ƏN YAXŞI ÜZVLƏR |
| clanMemberWithRole | {name} · {role} |
| clanApplyCta | Müraciət et |
| clanJoinCta / clanAppliedCta / clanInviteOnlyCta / clanFullCta / clanReqNotMet / clanLeaveFirst | Qoşul / Müraciət göndərildi / Yalnız dəvətlə / Klan doludur / Tələblərə uyğun deyilsən / Əvvəlcə hazırkı klandan çıx *(proposals)* |
| policyOpen | Açıq |
| policyOpenSub | Reytinq şərtinə uyğun hər kəs dərhal qoşulur |
| policyRequest | Müraciət ilə |
| policyRequestSub | Rəhbər və köməkçilər təsdiqləyir *(role wording §13.15)* |
| policyInvite | Yalnız dəvət |
| policyInviteSub | Siyahıda görünür, amma qoşulmaq üçün dəvət lazımdır |
| roleLeader | Lider |
| roleCoLeader | Müavin |
| roleElder | Ağsaqqal |
| roleMember | Üzv |
| emblemTitle | Emblem |
| emblemSave | Saxla *(same text as existing `lockerSave`; own key)* |
| cancel | **existing key** (Ləğv et) |
| emblemTabShape | Forma |
| emblemTabSymbol | Simvol |
| emblemTabColor | Rəng |
| emblemTabPattern | Naxış |
| emblemPrimaryColor | ƏSAS RƏNG |
| emblemShapeShield … emblemShapeArch | Qalxan / Altıbucaq / Səkkizbucaq / Dairə / Romb / Bayraq / Ulduz / Tağ *(proposals, a11y labels)* |
| clanOnline | ● {n} onlayn *(dot as a shape; store "{n} onlayn")* |
| clanTabChat | Söhbət |
| clanTabActivity | Fəaliyyət |
| clanTabWar | Döyüş |
| clanTabChest | Sandıq |
| clanChestTitle | Həftəlik sandıq |
| clanChestProgress | {current} / {target} |
| clanChatHint | Mesaj yaz… |
| you | **existing key** (Sən) — chat author name for me |
| clanSysWarWin | {name} klan döyüşündə qalib gəldi · +{points} |
| clanSysJoined / clanSysLeft / clanSysPromoted / clanSysDonated | {name} klana qoşuldu / {name} klandan çıxdı / {name} {role} oldu / {name} sandığa {amount} sikkə qoydu *(proposals; role in nominative)* |
| clanMenuMembers / clanMenuLeaderboard / clanMenuProfile / clanMenuSettings / clanMenuLeave | Üzvlər / Klan reytinqi / Klan profili / Tənzimləmələr / Klandan çıx *(proposals except "Üzvlər")* |
| chatReport / chatMute / chatDelete | Şikayət et / Səssizə al / Sil *(proposals)* |
| membersTitle | Üzvlər |
| membersCount | {members} / {max} |
| memberMeta | {presence} · {rating} |
| memberMe | {name} (sən) |
| memberViewProfile | Profilə bax |
| memberInviteFriendly | Dostluq matçına çağır |
| memberPromoteCoLeader | Müavin et |
| memberKick | Klandan çıxar |
| memberPromoteElder / memberDemote / memberTransferLead / memberKickConfirm | Ağsaqqal et / Rütbəsini endir / Liderliyi ver / {name} klandan çıxarılsın? *(proposals)* |
| warLive | ● CANLI · BİTMƏSİNƏ {time} *(dot as shape)* |
| warOfMatches | {n} matçdan |
| warScore | {mine} : {theirs} |
| warAssignments | MATÇ TƏYİNATLARI |
| warFinished | Bitdi {a}–{b} |
| warLiveScore | Canlı {a}–{b} |
| warScheduled | {time} *(clock time)* |
| warWatchLive | Canlı matçları izlə · {n} |
| warUpcoming / warWon / warLost / warPlayNow | BAŞLAYIR: {when} / BİTDİ · QƏLƏBƏ / BİTDİ · MƏĞLUBİYYƏT / Oyna *(proposals)* |
| clanLeaderboardTitle | Klan reytinqi · Sezon {n} |
| clanPoints | {points} *(thousands separator = space)* |
| createClanTitle | Klan yarat |
| createStep | {step} / {total} |
| createNameLabel | Klanın adı |
| createNameCounter | {n} / {max} |
| createTagLabel | Teq (3–5 hərf) |
| createTagFree | Boşdur |
| createTagTaken / createTagInvalid | Tutulub / Yalnız 3–5 hərf *(proposals)* |
| createEmblemLabel | EMBLEM |
| createColorLabel | RƏNG |
| continueAction | **existing key** (Davam et) |
| createPolicyLabel | QOŞULMA |
| createMinRatingLabel | MİNİMUM REYTİNQ |
| createMinRatingAny | Hamı |
| createMinRatingMax | {n}+ |
| createLanguageLabel | DİL |
| languageNameAz / Tr / Ru / En | **existing keys** (Azərbaycanca / Türkçe / Русский / English) |
| createBalance | Balans: {from} → {to} |
| createRenameNote | Ad sonra {price} sikkəyə dəyişir |
| createSubmit | Klanı yarat · {price} *(coin glyph between; build as a Row, not text)* |
| purchaseNotEnoughCoins | **existing key** (Sikkən kifayət etmir. Sikkə yalnız qazanılır: oyna və tapşırıqları bitir.) |
| createDescriptionLabel | Təsvir *(proposal)* |

Icons (Lucide): `shield` (tab), `plus`, `search`, `menu`, `arrow-right`
(send), `chevron-left`, `smile` (composer emote, proposal). Emblems,
chest, podium, presence dots, status dots are drawn shapes.
Widgets: ClanEmblem, UnderlineTabs, FilterChip, ChoiceChip,
SmallActionButton, RoleBadge, PresenceAvatar, ChatBubble/Composer,
RatingSlider, Podium, WarScoreboard; existing `NardTextField`,
`RadioDot`, `NardProgressBar`, `CurrencyIcon`, `NardButton`,
`showNardSheet`, `ScreenHeader(bare)`, `NardTabBar`, `MessageState`.

---

## 7. Phase-5 deltas on existing screens (keys mostly in sibling specs)
- **2.1 Home** mode grid: "Şəxsi otaq" tile (`lock`) → §3 (`online.md`
  §7.1 placement question still open).
- **GameScreen**: my PlayerCard emote button (`game.md` §3.1) and Long Nard
  "Söhbət" control (`game.md` §1, caption key `gameChat`) → §1; opponent
  PlayerCard tap → 14.1.
- **8.1 Profile**: meta gains the clan name "Platin I · 1866 · Qızıl Zər"
  (`online.md` §5); Friends entry not drawn (§13.9).
- **15.1 Account & privacy**: MƏXFİLİK group (keys listed as Phase-5 in
  `online.md` §6.4: `accountGroupPrivacy`, `privacyPublicProfile`,
  `privacyOnlineStatus`, `privacyShowHistory`, `privacyFriendRequests`
  "Dostluq təklifləri" value "Hamı", `privacyBlocked` "Bloklananlar" value
  count) → Bloklananlar list screen not designed (proposal: user rows +
  outline "Bloku götür").
- **15.2 / 15.3**: `exportChats` "Söhbətlər", `deleteItemSocial` "Dostlar
  siyahısı və klan üzvlüyü" now apply.
- **TabBar**: add `NardTab(LucideIcons.shield, l.tabClan)` between Turnirlər
  (hidden) and Mağaza.
- Notification toggles "Dostluq sorğuları / Klan söhbəti / Klan müharibəsi"
  (16.1) are Phase 7.

## 8. Navigation (Phase 5 additions)
```
Tabs: Əsas · Klan · Mağaza · Profil   (Turnirlər hidden until 6)
Home: Şəxsi otaq ▶ (chooser) ▶ 6.3 host ─guest joins─Başla▶ 2.5 ▶ GameScreen
                           └▶ join by code ▶ waiting / GameScreen
Profil ▶ 6.1 Dostlar ─+ Əlavə et▶ 6.2 ─Skan et▶ QR scanner
         6.1 ─Çağır▶ 6.3 (+ invite) ; ─İzlə▶ 6.4 ; ─row▶ 14.1
GameScreen: emote button / Söhbət ▶ 2.7 overlay ; opponent card ▶ 14.1
14.1 ─Şikayət et▶ 14.2 ─göndər▶ 14.4 ─Bağla▶ caller
     ─Blokla▶ 14.3 ─Blokla▶ caller (toast)
Klan tab (no clan) ▶ 5.1 ─row▶ 5.2 ─Qoşul/Müraciət et▶ 5.4 / pending
                     5.1 ─+ Yarat▶ 19.1 ─Davam et▶ 19.2 ─Klanı yarat▶ 5.4
Klan tab (member) ▶ 5.4 ─☰▶ 5.5 (─row▶ action sheet) · 5.7 · 5.2 · settings ▶ 5.3
                    5.4 tab Döyüş ▶ 5.6 ─Canlı matçları izlə▶ list ▶ 6.4
Deep links: room/{code} ▶ join ; friend/{code} ▶ 6.2 with the request pre-filled
```

## 9. Widget reuse summary
| Need | Reuse | New / extend |
|---|---|---|
| Headers | `ScreenHeader(bare: true)`, `RootTitle` | 3-slot header (5.3: Ləğv et · title · Saxla), step trailing (19.x) |
| Buttons | `NardButton` primary / outline / danger / ghost | SmallActionButton (h 34/36, radius 10) |
| Fields | `NardTextField` (+ leading icon, trailing counter/status, multi-line), `CodeField` (letters) | pill input h 44 radius 22 (chat) |
| Selection | `RadioDot`, `NardSegmented`, settings group card | GroupCard radio/check rows, checkbox, FilterChip, ChoiceChip, UnderlineTabs, RatingSlider |
| Sheets | `showNardSheet`, `SheetTitle` | — |
| Identity | `Avatar` (new size 96, flat ring option), `RankBadge`, `FlagSwatch`, `HexClipper` | PresenceAvatar, ClanEmblem, RoleBadge |
| Lists | `KeyValueRow` (6.3 settings), `MessageState`, `OfflineBanner` | ChatBubble, SystemMessagePill, ChatComposer |
| Commerce | `CurrencyIcon`, `PriceTag`, `purchaseNotEnoughCoins` | — |
| Progress | `NardProgressBar` (h 4 chest, h 6 split bar needs 2 segments) | WarScoreboard, Podium |
| Game | `PlayerCard` (emote trailing), GameScreen | spectator mode, EmoteWheel, PhraseChip, received-emote bubble |
| Nav | `NardTabBar` + `tab_shell.dart` | Klan tab |
| Press | `Pressable` for all rows/tiles/chips | — |

## 10. Later phases — omit in Phase 5
Tournaments 4.x and clan tournaments (6); 6.5 player leaderboard and
Sezon picker (6); clan achievements "Klan qəhrəmanı"/"Klan dayağı" (they
need clan data; ship with Phase 6 achievements or here if trivial);
notification settings/inbox for social events (7); push delivery of
invites (7, unless invites need it now — §13.8).

---

## 11. Rules and numbers seen in the design (for product-owner confirmation)

"API now" = committed `apps/api/config/social.php` / `SocialController` /
`nard_protocol` working copy.

| # | Number / rule in the design | Where | Implied rule | API / protocol now |
|---|---|---|---|---|
| 1 | 8 emote slots | 2.7 | wheel shows 8 emotes (from the equipped emote pack) | 8 emote ids |
| 2 | 6 quick phrases: Salam! · Uğurlar · Əla gediş · Zərlər… · Təşəkkürlər · Yaxşı oyun | 2.7 | fixed list, ids only | 8 phrase ids (sorry, nice_roll, oops extra) |
| 3 | Emotes usable on the opponent's turn | 2.7 (state opp) | any time during the game | — |
| 4 | Presence: Onlayn / Oyunda · {variant score} / Oyunda · Turnir / last seen (2 saat, Dünən, 5 gün, 2 həftə) | 6.1, 5.5 | 3 presence states + last-seen age | `online` bool (seen ≤ 120 s), no last-seen, in-game via WS presence (matchId only) |
| 5 | Offline friends can be "Çağır"-ed | 6.1 | invites reach offline players (push) | — |
| 6 | Friend search typed "nig" → match "Nigar_88" | 6.2 | prefix search on name | min 3, max 20 chars, 30/min |
| 7 | Friend list size | — | not shown | max 200 friends |
| 8 | QR + invite link; no visible code | 6.2 | link carries the friend code | 8-char friend code `[A-HJKMNP-Z2-9]` (no I, L, O) |
| 9 | Room code 6 chars "NRD482" | 6.3 | letters + digits | `[A-Z2-9]{6}` |
| 10 | "Kod 9:41-də bitir · 14:32 qaldı" | 6.3 | room code lives ~15 min | `expiresAt` (TTL not fixed) |
| 11 | Private room: Uzun nərd · 5 xala qədər · 5 dəq + 15s · Reytinq təsir etmir | 6.3 | host picks variant/length/time; always unrated | create has variant + matchLength only; server clock 3+12 only |
| 12 | One guest seat ("Dost gözlənilir…") | 6.3 | 1 v 1 only | — |
| 13 | 128 spectators | 6.4 | public count; many spectators per game | `spectate.join/leave`, no count message |
| 14 | Spectator free-text chat | 6.4 | spectators chat with each other | none (conflicts with §8.5 spirit) |
| 15 | Player menu: add friend, invite, mute chat, report, block | 14.1 | mute is local | — |
| 16 | 6 report reasons | 14.2 | incl. "Oyunu qəsdən tərk etmə" | 5 reasons (no leaving) |
| 17 | Optional note | 14.2 | free text to moderators | max 500 chars |
| 18 | Last game record + chat auto-attached; reporter anonymous | 14.2 | server attaches matchId/chat log | `matchId` optional field |
| 19 | "Bu oyunçunu da blokla" checked by default | 14.2 | report defaults to block | separate call |
| 20 | Moderator reviews within **24 h**; reporter gets a notification with the result | 14.4 | moderation SLA + outcome notification | reference "R-000123" returned; no outcome flow |
| 21 | Reports per day | — | not shown | 10 / reporter / 24 h |
| 22 | Block: never matched in casual ("Təsadüfi") games; no messages, friend requests, game invites; undo in Settings › Hesab və məxfilik › Bloklananlar | 14.3 | matchmaking must skip blocked pairs (ranked too? §13.12) | block ends friendship; matchmaking not wired |
| 23 | Clan member cap **50** | 5.1, 5.2, 5.5 | fixed cap (or grows with level?) | — |
| 24 | Clan level (6–14 in samples) | 5.1, 5.2 | clan XP & level | — |
| 25 | Clan rating 1690–2140 | 5.1, 5.2 | aggregate member rating (avg? top-N?) | — |
| 26 | Requirements: Min. reytinq 1500, Min. səviyyə 10, Qəbul | 5.2 | min player level is a requirement | — |
| 27 | Filter "Min. reytinq ≤ 1842" | 5.1 | filter clans whose minimum ≤ my rating | — |
| 28 | Join policies Açıq / Müraciət ilə / Yalnız dəvət; default Müraciət ilə | 19.2 | invite-only clans still listed | — |
| 29 | Min rating slider "Hamı" … "2400+", sample 1400 | 19.2 | 0 = no minimum, max 2400 | initial rating 1500 |
| 30 | Clan languages: 4, multi-select | 19.2, 5.1 ("Dil: AZ"), 5.2 ("AZ") | ≥ 1 language; profile shows the first | app languages az/tr/ru/en |
| 31 | Name max **24** chars ("15 / 24") | 19.1 | min not shown (*proposal* 3) | — |
| 32 | Tag **3–5** letters, unique ("Boşdur"); Azerbaijani letters allowed ("ŞRV", "ŞKU"); digits in "A65" | 19.1, 5.1 | letters **and digits**? (§13.16) | — |
| 33 | Create price **3 000 coins**; balance 3 450 → 450 | 19.2 | paid in earn-only coins | — |
| 34 | Rename later **1 000 coins** | 19.2 | name change costs coins (tag too?) | — |
| 35 | Emblem: 8 shapes, 7 colours (5.3) / 6 (19.1), symbols ≥ 4, pattern lattice | 5.3, 19.1 | free to change? (save has no price) | — |
| 36 | "● 18 onlayn" | 5.4 | online member count | — |
| 37 | Weekly chest target **10 000**, progress 7 400 | 5.4 | weekly coin donation goal; fixed reward when full | — |
| 38 | "Sandığa 500 qoydum" | 5.4 (sample chat) | donations of coins, free amount | — |
| 39 | Chest reward | — | not shown (must be fixed, ADR-035) | — |
| 40 | War score "12 : 9" "25 matçdan" | 5.6 | 25 matches per war; score = matches won (spec says total points) | — |
| 41 | War match result "5–3", "1–5" | 5.6 | war matches are 5-point matches | — |
| 42 | Scheduled war matches "21:30" | 5.6 | assigned pairings with start times | — |
| 43 | "BİTMƏSİNƏ 1:42:08" | 5.6 | war has a fixed end time (one evening?) | — |
| 44 | "Hər cümə klan döyüşü" | 5.2 (description) | weekly, Friday | spec: weekly |
| 45 | "Rauf klan döyüşündə qalib gəldi · +3" | 5.4 | a war match win = +3 clan points (or XP) | — |
| 46 | "Canlı matçları izlə · 4" | 5.6 | live war matches are spectatable | — |
| 47 | Clan leaderboard per season ("Sezon 4"), points 30 560–51 940 | 5.7 | seasonal clan points; top 3 podium gold/silver/bronze | — |
| 48 | Roles Lider / Müavin / Ağsaqqal / Üzv; Ağsaqqal shown "Müavin et" + "Klandan çıxar" on another Ağsaqqal | 5.5 | permission matrix (§6.5 proposal) | — |
| 49 | Requests approved by "Rəhbər və köməkçilər" | 19.2 | Lider + Müavin (+Ağsaqqal?) approve | — |
| 50 | Chat message samples ≤ 45 chars, no emoji | 5.4 | max length / emoji policy undefined | — |

## 12. Data the screens need (API / protocol)

**REST (Laravel), existing:** `GET /friends` → `{friends, incoming,
outgoing, friendCode}` with `publicCard {id, name, country, avatar, level,
title, online, ratings{variant: rating}}`; `POST /friends/requests {code |
userId}` → `requested | accepted`; accept/dismiss/unfriend; `GET
/users/search?q`; `GET/POST/DELETE /blocks`; `POST /reports {userId,
reason, matchId?, note?}` → `{reference}`.

**Missing for the friend screens:** `lastSeenAt` (6.1, 5.5), tier +
sub-level per variant (6.2 "Almaz III", 14.1 "Platin I"), clan `{id, name,
tag}` on the public card (6.2 meta, 8.1), privacy flags (profile public,
show online status, show history, who may send requests: everyone /
friends of friends / nobody), invite link base URL + QR payload
(`https://…/f/{friendCode}`), report reason `leaving`, `alsoBlock` flag
(or two calls), reporter notification of the outcome (Phase 7 inbox).

**WS (game server / `nard_protocol`):**
- `chat.emote {id}` → `{id, from}` to players + spectators; server-side
  rate limit; ids validated (`Emotes`).
- `presence.query {userIds}` → `{matches: {userId: matchId}}`; for 6.1 the
  row also needs `variant`, live score (`4–2`), and `tournament` flag →
  extend to `{matchId, variant, score: [a, b], kind: casual|ranked|room|
  tournament|clanWar, spectatable}`.
- `room.create {variant, matchLength, timeControl?}` → `room.created
  {code, expiresAt}`; `room.join {code}`; `room.cancel`; **missing:**
  `room.update` (host changes settings), `room.guest {player}` (guest
  joined/left → 6.3 card), `room.start` (host taps Başla), error codes
  `room_not_found | room_expired | room_full | blocked`.
- **Invites (missing):** `invite.send {userId, roomCode}` / incoming
  `invite {from, roomCode, expiresAt}` / `invite.decline`; push for
  offline friends.
- `spectate.join {matchId}` / `spectate.leave`; **missing:** spectator
  count (`spectators {count}`), a spectator-safe snapshot (no clocks
  manipulation, read-only), optional delay, spectator chat or phrase
  relay (`spectate.chat {id}` if ids only).

**Clans (all new):**
- `Clan {id, name, tag, description, emblem {shape, symbol, color,
  pattern}, level, xp, xpNext, memberCount, maxMembers (50), rating,
  languages[], joinPolicy (open|request|invite), minRating, minLevel,
  onlineCount, season, seasonPoints, rank, createdAt}`.
- `GET /clans?q&language&open&maxMinRating&cursor` (5.1), `GET
  /clans/{id}` (+ `topMembers[3]`, `requirementsMet {rating, level}`,
  `myStatus none|pending|member|invited`) (5.2).
- `POST /clans {name, tag, emblem, joinPolicy, minRating, languages,
  description?}` → debits `clan_create_price` (3 000) from coins; `GET
  /clans/tag-available?tag=` (19.1); `PATCH /clans/{id}` (rename costs
  1 000; emblem/policy free); prices in `config/economy.php`.
- Membership: `POST /clans/{id}/join` (open) / `apply` (request) /
  `invites` (invite-only, by Lider/Müavin) / `requests/{id}/accept|decline`
  / `leave` / `members/{userId}/kick|role {role}` / `transfer`.
- `GET /clans/{id}/members` → `{userId, name, avatar, role, rating,
  presence, lastSeenAt, joinedAt, weeklyDonation?}` (5.5).
- Chat: `GET /clans/{id}/messages?before=` (history, 50/page) + realtime
  delivery (WS `clan.message {id, author, text, emoteId?, system?,
  createdAt}`; which socket: game server or a separate channel — decide);
  `POST /clans/{id}/messages {text | emoteId}` with length cap, rate
  limit, profanity filter; `DELETE` (own / moderator); report message →
  `POST /reports {userId, reason: abuse, messageId}`; mute list.
- Chest: `GET /clans/{id}/chest` → `{weekStart, progress, target (10 000),
  reward (fixed, shown), myDonated}`; `POST /clans/{id}/chest/donate
  {amount}` (coins; min/max per donation and per week, §13.22).
- War: `GET /clans/{id}/war` → `{status upcoming|live|finished, startsAt,
  endsAt, opponent {clan}, score {mine, theirs}, totalMatches (25),
  pointsPerWin?, assignments[{id, mine {player}, theirs {player},
  scheduledAt, status scheduled|live|finished|forfeit, score [a, b],
  matchId}]}`; live count; "play my war match" entry (server creates the
  game; ranked or not? §13.24).
- Leaderboard: `GET /clans/leaderboard?season=` → `{season, entries[{rank,
  clan {id, name, tag, emblem}, points}], me {rank, points}}`.
- System events into chat (joins, promotions, donations, war results).
- Wallet balance for 19.2 (`GET /me` already returns coins in Phase 4).

---

## 13. Ambiguities / open questions
1. **Emote art**: the 8 wheel slots are placeholders ("emote"). Which 8
   emotes, drawn how (no emoji per readme → custom illustrations or
   Lottie)? Store sells emotes ("Çay emote", emote packs) → the wheel shows
   the equipped pack; what is the free default pack?
2. **Phrase ids**: design has 6 phrases, protocol working copy has 8 ids
   (`sorry`, `nice_roll`, `oops` extra). "Zərlər…" ("the dice…", a lament)
   maps to `oops`? `nice_roll`? "Əla gediş" = `well_played`? Align the
   list (6 or 8 chips; 8 also wraps to 2 rows).
3. **Receiving emotes**, cooldown, and opponent mute in game are not
   designed (proposals §1).
4. **Spectator free-text chat (6.4)** conflicts with the anti-toxicity rule
   and needs moderation, reporting and storage. Options: ids-only phrases
   for spectators, free text only between friends, or drop it.
5. **Spectating rules**: who may watch (friends only? anyone via clan war?
   ranked games? tournament games?), spectate delay (e.g. 1 move or 15 s)
   to stop coaching via another device, and whether players see the
   spectator count.
6. **Friend requests UI** (incoming/outgoing) is not designed though the
   API has it; nor are the blocked list screen (15.1 › Bloklananlar) and
   friend-request privacy values (only "Hamı" drawn).
7. **Friend code**: API code is 8 chars; the design shows only QR + link.
   Show the code as text too? Link domain/format and app-not-installed
   fallback (store page) undefined.
8. **Invites to offline friends** ("Çağır" on offline rows): needs push
   (Phase 7). Disable for offline until then, or send an in-app invite only?
9. **Entry points**: Friends (6.1) lives under Profil but no entry is drawn
   in 8.1; 14.1 entry points are not drawn; Klan tab root when in a clan
   (5.4?) vs clanless (5.1) is inferred.
10. **"İzlə" availability**: friends in tournaments ("Oyunda · Turnir") are
    spectatable? Privacy toggle "Onlayn statusu göstər" off → show offline?
11. **Join by code** screen (guest side of 6.3) and the Home "Şəxsi otaq"
    chooser are not designed. Room settings editing is not drawn. Host
    leaving / guest leaving / code expired states missing.
12. **Block scope**: 14.3 says blocked players won't meet you in "Təsadüfi"
    (casual/random) games — also ranked? Avoiding someone in ranked could be
    abused for rating; and with low population blocks may lengthen queues.
13. **Report reasons**: design has 6 (adds "Oyunu qəsdən tərk etmə"), API
    has 5. Also "Təhqiramiz söhbət" when in-game chat is ids-only → applies
    to clan/spectator chat and names; game-leaving is detectable server-side
    (abandon) — keep as a reason?
14. **Report reference**: API returns "R-000123" ("14.4 shows a reference")
    but 14.4 doesn't show it; the "you'll get a notification" promise needs
    an outcome flow (Phase 7 inbox). The 24 h SLA needs moderators/admin
    (Filament is Phase 7).
15. **Role names and permissions**: 19.2 says "Rəhbər və köməkçilər"
    (leader and helpers) but roles are Lider/Müavin/Ağsaqqal/Üzv. 5.5 shows
    an Ağsaqqal (Elvin) seeing "Müavin et" and "Klandan çıxar" on another
    Ağsaqqal. Confirm the matrix in §6.5. Also: what does Ağsaqqal allow?
    Max number of Müavin?
16. **Tag rules**: "3–5 hərf" (letters) but samples include "XQ" (2) and
    "A65" (digits). Allowed alphabet (az letters ə ğ ı ö ü ç ş, Cyrillic?),
    uniqueness case-insensitive, profanity check, rename price for the tag.
17. **Emblem builder inconsistencies**: 19.1 previews a rounded square, 5.x
    use clip shapes; 19.1 colours (6, incl. blue `#4F7FD1`, walnut
    `#2B1D14`) ≠ 5.3 colours (7, incl. indigo `#26346E`, slate `#2A2D32`,
    ivory); the 19.1 grid repeats symbols. Simvol and Naxış tabs have no
    content; is there a secondary/symbol colour? Do emblems cost coins or
    unlock with clan level (cosmetic, data-driven)?
18. **Min-rating slider**: thumb at 40% shows 1400 with ends "Hamı"/"2400+"
    → range/step unknown (0–3500 would put 1400 at 40%; 800–2300 too).
    Which variant's rating (Short vs Long)? Same question for the 5.1
    filter "≤ 1842".
19. **Min. səviyyə 10** on 5.2 has no control in 19.2; player level is
    Phase 4 data. Add a level slider or drop the row.
20. **Clan profile background** is garnet (= Qızıl Zər's colour?) — tint by
    clan colour or fixed?
21. **TabBar on clan screens**: 5.1 shows it, 5.2–5.7 don't; back buttons
    are missing on 5.2, 5.5, 5.6, 5.7.
22. **Chest/Sandıq**: target 10 000 per week, fixed reward contents, who
    receives it (all members? donors only? members who joined before the
    week?), donation min/max, refunds when leaving, and the "Sandıq" tab
    screen are undefined. "Fəaliyyət" tab content undefined. Coin
    donations must not become a coin-transfer loophole (e.g. alt accounts
    feeding a chest) — cap per day.
23. **Clan chat policy**: max length, rate limit, profanity filter
    language(s), emoji allowed or stripped (mock strips "👍"), history
    retention, who can delete, mute duration, and the spec's "emotes" in
    clan chat (no button drawn).
24. **Clan war format**: score "12 : 9 / 25 matçdan" reads as matches won,
    spec says "total points win"; "+3" per win in chat suggests points.
    Who assigns pairings (auto by rating or Lider/Müavin)? 25 matches with
    ≤ 50 members: how are participants chosen; no-show = forfeit? Matches
    5-point, rated or unrated? War window ("Hər cümə", ends in 1:42:08 →
    one evening?) and matchmaking of clans (by level/rating). Mock numbers
    don't add up (21 finished + 4 live + 2 scheduled > 25).
25. **Sheets**: 14.1/14.3 mock = full-width bottom sheets with a top
    hairline; 5.5 = inset sheet (= `showNardSheet`). Spec: use
    `showNardSheet` everywhere (as in `online.md` §12.14).
26. **Disabled CTA** on 6.3 "Başla" (fill `text@.06`, ring `accent@.2`,
    faint label) is a third disabled style (DS / 17.3 / this). Pick one.
27. **Avatars**: lists use the teal "me" fill for every player; per-user
    avatar data (Phase 4 cosmetics or preset ids) decides the fill.
28. **Clan rating & level**: how is the clan rating computed (5.1/5.2:
    2140), how is clan XP earned (wars, donations, member wins?), level cap,
    and does the 50-member cap grow with level?
29. **Suffix harmony**: "Kerem_TR-i şikayət et", "Kod 9:41-də bitir",
    "{role} oldu" depend on the last sound of a user name / time. Rephrase
    to suffix-free forms (e.g. "Şikayət: {name}", "Bitir: {time}") or add
    a harmony helper.
30. **Season**: clan leaderboard "Sezon 4" implies seasons exist (Phase 6
    season pass). Clan points reset per season? Season-end clan rewards?
31. **Leave/disband clan, edit settings, invite players, pending request
    list** (for Lider/Müavin) are not designed.
