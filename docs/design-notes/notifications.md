# Notifications: implementation spec (Phase 7)

Source: `.claude/skills/nardarena-design`: `Ekranlar 7` (16.1 Bildiriş
ayarları, 16.2 Bildiriş qutusu, 16.3 Push icazəsi), `Ekranlar 6` (10.2
Ayarlar › ÜMUMİ › "Bildirişlər" row), `Ekranlar 2` (2.1 Home header, no
bell drawn). Spec §8.11. Siblings: `screens.md` (chrome), `online.md`
(15.x group cards, `NardSwitch`), `social.md` (`NardChoiceChip`,
`SmallActionButton`, 6.1 challenge join). API: `docs/api/notifications.md`;
decisions: ADR-041. Frame 390×844 portrait, logical px.

Product rules that override the mocks:
- **No "your turn" pushes**: there are no correspondence (async) games, so
  16.1 "Sənin növbən" / "Rəqib tapıldı" and the 16.3 copy "Rəqib gediş
  edəndə" describe nothing we send. Rows without an event are omitted
  (no dead switches) and the 16.3 body promises only what exists (§4).
- **Push is disabled until the owner adds Firebase keys** (ADR-041, like
  Apple/Google sign-in in ADR-030): the inbox is the only channel and the
  client ships a no-op `PushRegistrar` (no `firebase_messaging` yet).
- Category switches govern **pushes only**; the inbox always records
  every event (it is the history). Blocked players never appear.

---

## 0. Conventions

Same as `social.md` §0 (aliases `text`, `text@a`, `accent`, `accentHi`,
`dangerText`, `successText`, `c.` = `context.nard`; overline =
`NardType.caption` w600 letterSpacing .72, stored uppercase in ARB;
"*(proposal)*" = not in the mock). Mock colours: `#D4AE58` = `accent`,
`#E8C468` = `accentHi`, `#1d1316` on brass = `c.onAccent`, `#E0566C` =
`dangerText`, `#3FB57F` = `successText`, `#1b120c` flat = `c.bg`.

New raw values (added to `apps/client/lib/ui/extra_tokens.dart`):

| Use | Value | Token |
|---|---|---|
| 16.3 background | radial `80% 45% at 50% 30%`: `#4A2430` → `#24161B` 60% → `#120C0E` | `c.pushPromptBg` |
| 16.3 app icon tile | radial `90% 90% at 30% 20%`: `#4A321F` → `#2B1D14` 60% → `#160E09` | `c.appIconFill` |
| 16.2 unread row | `accent@.07` | `c.unreadRow` |
| Bell badge *(proposal)* | fill `dangerText`, 2px ring `c.bg`, text `c.onDanger` 10 w600 | — |

---

## 1. Entry points and the bell *(proposal)*

The design draws no bell. Home (2.1) gets a 44×44 bell (Lucide `bell` 22
`text`) at the right end of the profile row (row padding becomes
`0 8 16 16`); unread > 0 → badge min 18×18 pill at top 6 / right 4 with
the count ("99+" above 99). Shown only when signed in. Tap → 16.2.

While the bell is on screen it **polls** `GET /notifications?after=<newest
id>` every 60 s and on app resume; it also (a) registers the push token
when the OS allows push, (b) opens tapped pushes (deep link §3.3), (c) shows
16.3 once (§4).

16.1 opens from 10.2 Ayarlar › ÜMUMİ › "Bildirişlər" (row between "Hesab
və məxfilik" and "Səs"); signed-out players go through sign-in first.

---

## 2. 16.1 Notification settings (Bildirişlər)

Bg flat `c.bg`. Header `ScreenHeader(bare: true)` "Bildirişlər" (chevron
20 + Noto 20 w600). Body padding `4 16 0`, groups gap 12.

Group = overline 12 w600 .06em `text@.55` padding-left 4, gap 6, card
radius 16 fill `text@.04` ring 1px `accent@.14`; rows min-h 46, padding
`4 14`, gap 12, bottom border 1px `accent@.08`; name 15; subtitle 12
`text@.55` gap 1; switch = `NardSwitch(compact)` 44×26 (on: `accent`;
off: `text@.14`, ivory thumb; the mock's on-thumb `#1d1316` is drawn with
the shared switch's `c.bg`); value rows: value 14 `text@.6` + Lucide `chevron-right` 14
`text@.5`.

| Group | Row | Kind | Default | API |
|---|---|---|---|---|
| ÜMUMİ | Push bildirişləri | switch | on | `push` |
| | Sakit saatlar | value "23:00 – 08:00" / "Söndürülüb" → sheet | on, 23–08 | `quietHours` |
| OYUN | Oyun dəvətləri | switch | on | `game_invites` |
| TURNİR | Turnir başlayır · *15 dəqiqə əvvəl* | switch | on | `tournament_start` |
| | Raund hazırdır · *Və turnir nəticələri (proposal)* | switch | on | `tournament_round` |
| SOSİAL | Dostluq sorğuları | switch | on | `friend_requests` |
| | Klan dəvətləri *(proposal; replaces "Klan söhbəti")* | switch | on | `clan` |
| | Klan müharibəsi | switch | on | `clan_war` |
| MÜKAFATLAR *(was "MÜKAFAT VƏ TƏKLİF")* | Sezon nəticələri *(proposal)* | switch | on | `rewards` |

Omitted mock rows (no event exists): "Sənin növbən · Yazışmalı oyunlarda",
"Rəqib tapıldı", "Klan söhbəti", "Seriya xatırlatması", "Mağaza
təklifləri". They return with their events (§7).

States: push off → every other row at opacity .5 and inert; server
without FCM (`pushAvailable: false`) → subtitle under "Push bildirişləri":
"Bu versiyada push hələ işləmir; hamısı qutuda görünür". Switching push
on while the OS was never asked → 16.3 first. Each change is optimistic,
sent with the device `utcOffset`; failure reverts and shows a snackbar.

**Quiet hours sheet** *(proposal)*: `showNardSheet`; `SheetTitle` "Sakit
saatlar"; body 13 `text@.7` "Bu saatlarda push gəlmir, bildirişlər qutuda
qalır."; switch row; two stepper rows "Başlanğıc" / "Son": label 15,
`NardIconButton` chevron-left/right (whole hours, wraps 23→00), value
`NardType.labelM` `accentHi` tnum, width 64; primary "Yadda saxla".

---

## 3. 16.2 Inbox (Bildiriş qutusu)

Bg `c.bgGradient` (`NardBackground`). Header bare "Bildirişlər" + trailing
"Hamısını oxu" 14 w600 `accentHi` (only while unread > 0).

1. **Chips** padding `0 16 12`, gap 8 (horizontal scroll):
   "Hamısı" · "Oyun" · "Sosial" · "Turnir" = `NardChoiceChip` (mock h 32 /
   chip h 34). Oyun = challenge; Sosial = friend + clan types; Turnir =
   tournament types; level-up and season rows only under Hamısı.
2. **Groups** "BU GÜN" / "DÜNƏN" / "ƏVVƏL" *(ƏVVƏL proposal)*: 12 w600
   .06em `text@.55`, padding `8 20 6`.
3. **Row** padding `12 16`, gap 12, fill `c.unreadRow` when unread:
   - icon disc 40, fill `text@.06` (`c.pillFill`), ring 1px `accent@.3`,
     Lucide 18: game / tournament / season / level in `accent`, social in
     `text` (mock: play / dice / trophy in brass, user-plus in ivory);
   - text 14/19: **who** w600 + rest; time 12 `text@.5` gap 4;
   - actions (gap 8, margin-top 4): pill h 32, padding h 14, 13 w600 —
     solid `accent` / `c.onAccent`, outline ring 1px `accent@.3` / `text`;
   - unread dot 8, margin-top 6, `dangerText` (read: none).

Time: "indi" (< 1 min) · "{n} dəq" · "{n} saat" (today) · "Dünən HH:mm" ·
"dd.MM HH:mm".

### 3.1 Rows (az copy; who = bold)
| type | icon | who | text | actions |
|---|---|---|---|---|
| friend_request | user-plus | {name} | dostluq sorğusu göndərdi | Qəbul et / Sil |
| friend_accepted | user-check | {name} | dostluq sorğunu qəbul etdi | — |
| challenge | dices | {name} | səni oyuna çağırır · {variant}, {points} xal | Qəbul et / Rədd et (while not expired) |
| clan_invite | users | {name} | səni {clan} [{tag}] klanına dəvət edir | — (tap → 5.2 with "Dəvəti qəbul et") |
| clan_joined | users | {clan} | klanına qəbul olundun | — |
| clan_war | swords | Klan döyüşü: | rəqib {opponent} [{tag}]. Hər qələbə klana xal gətirir | — |
| tournament_reminder | trophy | {tournament} | {n} dəqiqəyə başlayır | — |
| tournament_started | trophy | {tournament} | başladı. İlk oyunun hazırdır | — |
| tournament_round | trophy | {tournament} | · Raund {round} hazırdır. Rəqib: {opponent} | — |
| tournament_eliminated | trophy | {tournament} | · Raund {round}: mübarizə bitdi (with `place`: ". Yerin: {place}") | — |
| tournament_won | trophy | {tournament} | · Çempionsan! Mükafat hesabındadır | — |
| tournament_finished | trophy | {tournament} | bitdi · Yerin: {place} | — |
| tournament_cancelled *(proposal, ADR-049)* | trophy | {tournament} | ləğv edildi (refund > 0: "· {coins} sikkə geri qaytarıldı") | — |
| season_end | award | Sezon {n} | bitdi · Dərəcən: {tier}. Nəticələrə bax (with `rank`: "bitdi · Dərəcən: {tier}, yerin: #{rank}. Mükafat: {coins} sikkə") | — |
| season_started *(proposal, ADR-049)* | award | Sezon {n} | başladı. Yeni sezon keçidi və mükafatlar səni gözləyir | — |
| level_up | sparkles | Səviyyə {level}! | +{coins} sikkə qazandın | — |
| *unknown* | bell | — | Yeni bildiriş | — |

The mock's "Kerem_TR gediş etdi. Növbə səndədir" (no async games) and
"Moderasiya: şikayətinə baxıldı" (admin step, Phase 7.1) are not built.

### 3.2 Actions
- **Qəbul et** (friend request) → `POST /friends/requests/{id}/accept`,
  then `DELETE /notifications/{id}`; **Sil** → `DELETE /friends/requests/{id}`
  + delete the row. A 404 (already handled elsewhere) removes the row and
  shows "Bu dəvət artıq keçərli deyil".
- **Qəbul et** (challenge) → mark read, `room.join` over the social socket
  (as 6.1 "Qoşul"), push `/room/join?code=…`; **Rədd et** → delete the row
  (the challenge simply expires after 10 min). Expired → no buttons; a tap
  shows "Bu dəvət artıq keçərli deyil".
- **Hamısını oxu** → `POST /notifications/read {all:true}`.
- Pull to refresh = full reload.

### 3.3 Deep links (row tap and push tap; the row is marked read)
friend_* → `/friends` · challenge → `/room/join?code=` · clan_invite,
clan_joined → `/clans/{clanId}` · clan_war → Klan tab (`go('/clan')`) ·
tournament_* → `/tournaments/{id}` · season_end → `/season/summary?n=` ·
season_started → `/season` (pass) · level_up → Profil tab.

Empty: `MessageState` "Bildiriş yoxdur" / "Dostluq sorğuları, oyun
dəvətləri və turnir xəbərləri burada görünəcək." Load error: `errorTitle`
/ `authOffline` / "Yenidən cəhd et".

---

## 4. 16.3 Push pre-prompt (Push icazəsi)

Full screen (route `/push-prompt`, fade), bg `c.pushPromptBg`.
- Centre column padding h 24, gap 22: two preview cards gap 8 — padding
  `12 14`, radius 18 *(no token)*, fill `text@.1`, ring 1px `text@.12`,
  gap 12: app tile 36 radius 9 `c.appIconFill` ring 1px `accent@.35` with a
  15×15 diamond outline 2px `accent` (rotated 45°); "NardArena" 13 w600 +
  time 12 `text@.55` right; text 13/18 `text@.85`. Second card opacity .6,
  scale .96.
- Title Noto 600 28/34 "Növbəni qaçırma"; body 15/22 `text@.7` centred,
  margin-top 14 above the title block.
- Bottom padding `0 16 24` (mock 40 incl. home indicator), gap 10: primary
  `NardButton` 56 "Bildirişləri aç"; ghost 48 "İndi yox" 15 w600 `text@.7`.

Copy (az): previews "Nigar səni oyuna çağırır · Qısa nərd, 5 xal" ·
"indi" and "Bakı Cümə Kuboku 15 dəqiqəyə başlayır." · "14 dəq" (mock's
first preview was a your-turn push); body "Turnir başlayanda, raundun
hazır olanda və dost dəvət göndərəndə xəbər verək. Hər kateqoriyanı
ayarlardan söndürə bilərsən." (mock: "Rəqib gediş edəndə, turnir
başlayanda və dost dəvət göndərəndə…").

When: **once per install** (`AppSettings.pushPromptShown`), the first
time a signed-in player reaches Home **and** the OS was never asked
(`PushStatus.notDetermined`); also before switching push on in 16.1. The
no-op registrar reports `unsupported`, so the screen never auto-opens until
the plugin exists. "Bildirişləri aç" → OS dialog → on grant register the
token; "İndi yox" → only remembers. Both pop back.

---

## 5. Push copy (server, `lang/{az,en,ru,tr}/notifications.php`)

Title / body per type in the device locale (token `locale`, else the
account locale):

| type | az title | az body |
|---|---|---|
| friend_request | Dostluq sorğusu | :name dostluq sorğusu göndərdi |
| friend_accepted | Yeni dost | :name dostluq sorğunu qəbul etdi |
| challenge | Oyun dəvəti | :name səni oyuna çağırır · :variant, :points xal |
| clan_invite | Klan dəvəti | :name səni :clan [:tag] klanına dəvət edir |
| clan_joined | Klana qəbul olundun | :clan [:tag] klanına xoş gəldin! |
| clan_war | Klan döyüşü başladı | Həftənin rəqibi: :opponent [:tag]. Hər qələbə klana xal gətirir. |
| tournament_reminder | Turnir başlayır | :tournament :minutes dəqiqəyə başlayır. |
| tournament_started | Turnir başladı | :tournament başladı. İlk oyunun hazırdır. |
| tournament_round | Raund hazırdır | :tournament · Raund :round. Rəqib: :opponent. |
| tournament_eliminated | Turnirdə mübarizə bitdi | :tournament · Raund :round. Növbəti turnirdə uğurlar! |
| tournament_won | Çempion! | :tournament qalibisən. Mükafatın hesabındadır. |
| tournament_finished | Turnir bitdi | :tournament · Yerin: :place. |
| tournament_cancelled | Turnir ləğv edildi | :tournament ləğv edildi. (+ " :refund sikkə geri qaytarıldı." when refunded) |
| season_end | Sezon :season bitdi | Dərəcən: :tier, yerin: #:rank. Mükafat: :coins sikkə. |
| season_started | Sezon :season başladı | Yeni sezon keçidi və mükafatlar səni gözləyir. |
| level_up | (inbox only) | — |

Neutral phrasing avoids Azerbaijani suffix harmony after names (ADR-033).

---

## 6. Strings (client ARB, az)

| key | az |
|---|---|
| notifTitle | Bildirişlər |
| notifReadAll | Hamısını oxu |
| notifTabAll / Game / Social / Tournament | Hamısı / Oyun / Sosial / Turnir |
| notifToday / notifYesterday / notifEarlier | BU GÜN / DÜNƏN / ƏVVƏL |
| notifNow / notifMinutesAgo / notifHoursAgo / notifYesterdayAt | indi / {n} dəq / {n} saat / Dünən {time} |
| notifEmptyTitle / notifEmptyBody | Bildiriş yoxdur / Dostluq sorğuları, oyun dəvətləri və turnir xəbərləri burada görünəcək. |
| notifDelete | Sil (accept / decline reuse `friendAccept` "Qəbul et", `friendDismiss` "Rədd et") |
| notifBellLabel | Bildirişlər, {n} oxunmamış |
| notifGone | Bu dəvət artıq keçərli deyil |
| notifFriendRequest … notifLevelUp | §3.1 texts |
| notifTournamentEliminatedPlace, notifTournamentCancelled(+Refund), notifSeasonEndRank, notifSeasonStarted | §3.1 texts added by ADR-049 |
| notifGroupGame / Tournament / Social / Rewards | OYUN / TURNİR / SOSİAL / MÜKAFATLAR (ÜMUMİ = `settingsGroupGeneral`) |
| notifPush / notifPushUnavailable | Push bildirişləri / Bu versiyada push hələ işləmir; hamısı qutuda görünür |
| notifQuietHours / notifQuietRange / notifQuietOff | Sakit saatlar / {start} – {end} / Söndürülüb |
| notifQuietBody / notifQuietFrom / notifQuietTo / notifQuietSave | Bu saatlarda push gəlmir, bildirişlər qutuda qalır. / Başlanğıc / Son / Yadda saxla |
| notifEarlierHour / notifLaterHour | Bir saat əvvəl / Bir saat sonra (stepper semantics) |
| notifGameInvites, notifTournamentStart (+Sub "{n} dəqiqə əvvəl"), notifRoundReady (+Sub "Və turnir nəticələri"), notifFriendRequests, notifClanInvites, notifClanWars, notifSeasonResults | §2 rows |
| notifPromptTitle / Body / Sample1 / Sample2 / Allow / Later | §4 |

---

## 7. Later
Your-turn pushes with correspondence games; "Rəqib tapıldı" (needs the
game server to report queue matches to the API); clan chat pushes (rate
limited, default off); streak reminder (local evening, scheduled); store
offers (marketing consent); moderation results (admin, Phase 7.1).

## 8. Live banner *(proposal; ADR-049 — the design has no in-app toast)*

Rows that arrive over the socket while the app is open pop up over any
screen (`LiveBannerHost` in the app builder, above the navigator):

- Position: top, under the status bar (`SafeArea`), margin `8 16 0`
  (`NardSpace.s2` / `screenGutter`); slides down + fades in
  (`NardMotion.sheetIn`, `standard`), out with `sheetOut`.
- Card: fill `c.surfaceRaised`, radius `c.cardRadius`, ring 1px
  `accent@.3`, shadow `c.elevation2` (floating layer, readme: shadows only
  on sheets/toasts/dialogs). Padding `12 0 12 14`.
- Content = the 16.2 row: icon disc 36 (`c.pillFill`, ring `accent@.3`,
  Lucide 18 with the 16.2 icon colour), gap 12, text 14/19 `text` with
  **who** w600 (max 3 lines); trailing × (Lucide `x` 16 `text@.6`, 44×44
  hit, label "Bağla").
- Tap → mark read + the §3.3 deep link (challenge: join as in 16.2);
  swipe up or × → dismiss; auto-hide after 5 s; a newer row replaces it.
- Not shown on `/game`, `/online/vs`, `/online/fair`, onboarding /
  language / splash / lesson, `/push-prompt`, `/levelup` and the inbox
  itself; level-up and unknown types never pop up. The row is in the
  inbox and the bell badge either way.
