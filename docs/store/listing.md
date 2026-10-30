# Store listing drafts (Google Play + App Store)

Status: **draft for the product owner** (Phase 7). Nothing here is submitted.
"NardArena" is still the placeholder name (SPEC, `appName` in the ARB files,
bundle id `com.nardarena.app`); replace it everywhere once the name is final.

Voice: a calm club host. No emoji, no exclamation marks, no gambling words
(bet, stake, wager, jackpot, casino, cash, "win money", "luck"). Coins are
earned only and can never be bought or cashed out (ADR-022); Yaqut buys only
cosmetics and the premium season pass (ADR-023); nothing pays out real money.

Limits used below:

| Field | Google Play | App Store |
|---|---|---|
| App name | 30 chars | 30 chars |
| Short description / subtitle | 80 chars | subtitle 30 chars |
| Promotional text | — | 170 chars (editable without review) |
| Full description | 4 000 chars | 4 000 chars |
| Keywords | none (indexed from text) | 100 bytes, comma-separated, no spaces needed |

Lengths were counted when written; re-count after any edit
(`python3 -c "print(len(open('x').read()))"`), and remember App Store
keywords are counted in **bytes** (Cyrillic and Azerbaijani letters such as
`ə`, `ş` take 2 bytes).

---

## 1. App name ideas

Check each against the stores, trademarks (WIPO / Turkpatent / AzPatent /
Rospatent) and domain availability before choosing. Names that mention
"Backgammon" or "Tavla" in the title help store search.

| # | Name | Why | Risk |
|---|---|---|---|
| 1 | **Nard Club** | Matches the "club host" voice; short; works in all four languages | Generic; may be taken |
| 2 | **Şeşbeş Club** | "Şeşbeş" is how many Azerbaijani and Iranian players call the game | Hard to type outside az/tr; `ş` in a bundle-free name only |
| 3 | **NardArena** (keep) | Already in the code; clear | "Arena" sounds louder than the brand voice |
| 4 | **Nard House** | Calm, social, club feeling | Weak in ru |
| 5 | **Uzun & Qısa** | Names both variants in Azerbaijani | Meaningless outside az |
| 6 | **Zər Nard** | "Zər" = dice (az) | Close to existing "Zar" tavla apps in tr |

Suggested store titles (30 chars max), brand + search words:

- Google Play / App Store (en): `Nard Club: Backgammon & Tavla` (29)
- az: `Nard Club: Nərd və Şeşbeş` (25)
- ru: `Nard Club: Нарды онлайн` (23)
- tr: `Nard Club: Tavla ve Uzun Tavla` (30)

App Store subtitle (30 chars): en `Short and Long Nard, online` (27) ·
az `Qısa və uzun nərd, onlayn` (25) · ru `Короткие и длинные нарды` (24) ·
tr `Klasik ve uzun tavla, online` (28).

---

## 2. Short descriptions (Google Play, max 80)

| Lang | Text | Chars |
|---|---|---|
| en | Short and Long Nard with friends, clans and tournaments. Fair dice, no ads. | 75 |
| az | Qısa və uzun nərd: dostlar, klanlar və turnirlər. Ədalətli zər, reklamsız. | 74 |
| ru | Короткие и длинные нарды: друзья, кланы и турниры. Честные кости, без рекламы. | 78 |
| tr | Klasik ve uzun tavla: arkadaşlar, klanlar ve turnuvalar. Adil zar, reklamsız. | 77 |

"No ads" / "reklamsız" is true today (no ad SDK). Drop it if ads are ever
added.

App Store promotional text (170):

- en: A quiet table is always ready. Play Short or Long Nard against the computer, a friend on the same phone, or players online, with dice you can verify. (149)
- az: Sakit masa həmişə hazırdır. Qısa və ya uzun nərdi kompüterə qarşı, eyni telefonda dostla və ya onlayn oyna; zərləri özün yoxlaya bilərsən. (138)
- ru: Тихий стол всегда готов. Играйте в короткие и длинные нарды с компьютером, с другом на одном телефоне или онлайн, с костями, которые можно проверить. (149)
- tr: Sakin bir masa her zaman hazır. Klasik veya uzun tavlayı bilgisayara karşı, aynı telefonda bir arkadaşla ya da online oyna; zarları kendin doğrulayabilirsin. (157)

---

## 3. Full descriptions (max 4 000)

Same text for Google Play and the App Store. Section headings are plain
lines (Play does not render Markdown; the App Store shows plain text).

### en (≈ 1 900 chars; az, ru, tr similar)

```
Welcome to the table. NardArena is backgammon the way it is played in
Baku, Istanbul and across the region: Short Nard, the classic game with
hitting and the doubling cube, and Long Nard, where all fifteen checkers
start on the head and nobody is hit.

PLAY YOUR WAY
- Against the computer, from first lessons to a strong club player.
- With a friend on the same phone, passing it across the table.
- Online, casual or ranked, single games or matches to 3, 5, 7 points and more.
- In private rooms with a six-letter code for friends and family.

FAIR DICE YOU CAN CHECK
Online dice are rolled on the server and sealed before every game. When
the game ends you can open the seal and confirm that no roll was changed.
The rules engine is the same on your phone and on the server, so every
move is checked the same way.

A CLUB, NOT A CROWD
- Friends list, invitations and quiet emotes.
- Clans with their own emblem, chat, weekly chest and clan wars.
- Report and block tools, and moderators who review reports.

COMPETITION
- A rating for each variant, leagues from Bronze to Grandmaster.
- Seasons with a soft reset and a free reward track.
- Tournaments: knockout, Swiss, round-robin and quick sit-and-go tables.
- Private tournaments for your own group.

GET BETTER
- Daily puzzles taken from real positions.
- Match analysis that shows where a game turned.
- Replays of your games, saved on your phone.

YOUR TABLE, YOUR STYLE
Boards, checkers, dice, dice cups and tables to collect. Every cosmetic is
purely visual and never changes a roll or a move.

ABOUT COINS AND PURCHASES
Coins are earned by playing, missions and seasons. They cannot be bought
and cannot be exchanged for money. Optional Yaqut purchases unlock
cosmetics and the premium season track only. Nothing in the game pays out
real money.

Offline games work without an internet connection. Available in
Azerbaijani, English, Russian and Turkish.
```

### az

```
Masaya xoş gəldin. NardArena nərdi Bakıda, İstanbulda və bütün regionda
oynandığı kimi təqdim edir: vurmaq və ikiqat kubu olan klassik qısa nərd
və bütün on beş daşın başdan başladığı, heç kimin vurulmadığı uzun nərd.

İSTƏDİYİN KİMİ OYNA
- Kompüterə qarşı: ilk dərslərdən güclü klub oyunçusuna qədər.
- Eyni telefonda dostla, telefonu masanın o biri tərəfinə ötürərək.
- Onlayn, adi və ya reytinqli: tək oyun və ya 3, 5, 7 və daha çox xallıq matçlar.
- Dostlar və ailə üçün altı simvollu kodla şəxsi otaqlarda.

YOXLAYA BİLƏCƏYİN ƏDALƏTLİ ZƏR
Onlayn zərlər serverdə atılır və hər oyundan əvvəl möhürlənir. Oyun bitəndə
möhürü açıb heç bir atışın dəyişdirilmədiyinə əmin ola bilərsən. Qaydalar
mühərriki telefonunda və serverdə eynidir, ona görə hər gediş eyni qaydada
yoxlanılır.

İZDİHAM YOX, KLUB
- Dostlar siyahısı, dəvətlər və təmkinli emosiyalar.
- Öz emblemi, söhbəti, həftəlik sandığı və klan döyüşləri olan klanlar.
- Şikayət və bloklama, şikayətlərə baxan moderatorlar.

YARIŞ
- Hər növ üçün ayrıca reytinq, Bürüncdən Qrossmeystərə qədər liqalar.
- Yumşaq sıfırlama və pulsuz mükafat xətti olan sezonlar.
- Turnirlər: nokaut, İsveç sistemi, dairəvi və tez başlayan masalar.
- Öz qrupun üçün şəxsi turnirlər.

DAHA YAXŞI OYNA
- Real mövqelərdən gündəlik tapmacalar.
- Oyunun harada dəyişdiyini göstərən matç təhlili.
- Telefonunda saxlanan oyun təkrarları.

SƏNİN MASAN, SƏNİN ÜSLUBUN
Toplamaq üçün taxtalar, daşlar, zərlər, zər stəkanları və masalar. Hər
kosmetika yalnız görünüşdür, heç vaxt atışı və ya gedişi dəyişmir.

SİKKƏLƏR VƏ ALIŞLAR HAQQINDA
Sikkələr oynayaraq, tapşırıqlar və sezonlarla qazanılır. Onları almaq və
pula dəyişmək olmaz. İstəyə bağlı Yaqut alışları yalnız kosmetikanı və
premium sezon xəttini açır. Oyunda heç nə real pul ödəmir.

Oflayn oyunlar internetsiz işləyir. Azərbaycan, ingilis, rus və türk
dillərində.
```

### ru

```
Добро пожаловать за стол. NardArena — это нарды такими, какими в них играют
в Баку, Стамбуле и по всему региону: короткие нарды, классическая игра со
взятием шашек и кубом удвоения, и длинные нарды, где все пятнадцать шашек
начинают с головы и никого не бьют.

ИГРАЙТЕ ТАК, КАК УДОБНО
- С компьютером: от первых уроков до сильного клубного игрока.
- С другом на одном телефоне, передавая его через стол.
- Онлайн, обычные и рейтинговые партии: одна игра или матч до 3, 5, 7 очков и больше.
- В приватных комнатах по шестизначному коду для друзей и семьи.

ЧЕСТНЫЕ КОСТИ, КОТОРЫЕ МОЖНО ПРОВЕРИТЬ
Онлайн-броски делает сервер, и перед каждой партией они запечатываются.
После игры печать можно открыть и убедиться, что ни один бросок не был
изменён. Движок правил одинаков на телефоне и на сервере, поэтому каждый
ход проверяется одинаково.

КЛУБ, А НЕ ТОЛПА
- Список друзей, приглашения и сдержанные эмоции.
- Кланы со своим гербом, чатом, недельным сундуком и войнами кланов.
- Жалобы и блокировка, модераторы рассматривают жалобы.

СОРЕВНОВАНИЯ
- Отдельный рейтинг для каждого вида нард, лиги от Бронзы до Гроссмейстера.
- Сезоны с мягким сбросом и бесплатной линией наград.
- Турниры: на выбывание, швейцарская система, круговые и быстрые столы sit-and-go.
- Приватные турниры для своей компании.

ИГРАЙТЕ ЛУЧШЕ
- Ежедневные задачи из реальных позиций.
- Анализ матча показывает, где решилась партия.
- Повторы ваших партий хранятся на телефоне.

ВАШ СТОЛ, ВАШ СТИЛЬ
Доски, шашки, кости, стаканы и столы для коллекции. Любая косметика только
меняет внешний вид и никогда не влияет на броски и ходы.

О МОНЕТАХ И ПОКУПКАХ
Монеты зарабатываются в игре, заданиях и сезонах. Их нельзя купить и нельзя
обменять на деньги. Необязательные покупки Якутов открывают только
косметику и премиальную линию сезона. Игра не выплачивает реальные деньги.

Офлайн-партии работают без интернета. Языки: азербайджанский, английский,
русский и турецкий.
```

### tr

```
Masaya hoş geldin. NardArena, tavlayı Bakü'de, İstanbul'da ve bölgenin her
yerinde oynandığı gibi sunar: pul kırmanın ve katlama zarının olduğu klasik
tavla ve on beş pulun hepsinin baştan başladığı, kimsenin kırılmadığı uzun
tavla.

İSTEDİĞİN GİBİ OYNA
- Bilgisayara karşı: ilk derslerden güçlü kulüp oyuncusuna kadar.
- Aynı telefonda bir arkadaşla, telefonu masanın karşısına uzatarak.
- Online, normal veya dereceli: tek oyun ya da 3, 5, 7 ve daha fazla sayılık maçlar.
- Arkadaşların ve ailen için altı haneli kodla özel odalarda.

DOĞRULAYABİLECEĞİN ADİL ZAR
Online zarlar sunucuda atılır ve her oyundan önce mühürlenir. Oyun bitince
mührü açıp hiçbir atışın değiştirilmediğini görebilirsin. Kural motoru
telefonunda ve sunucuda aynıdır; her hamle aynı şekilde kontrol edilir.

KALABALIK DEĞİL, KULÜP
- Arkadaş listesi, davetler ve ölçülü ifadeler.
- Kendi arması, sohbeti, haftalık sandığı ve klan savaşları olan klanlar.
- Şikâyet ve engelleme araçları, şikâyetleri inceleyen moderatörler.

REKABET
- Her oyun türü için ayrı puan, Bronzdan Büyükustaya ligler.
- Yumuşak sıfırlamalı ve ücretsiz ödül hattı olan sezonlar.
- Turnuvalar: eleme, İsviçre sistemi, lig usulü ve hızlı sit-and-go masaları.
- Kendi grubun için özel turnuvalar.

DAHA İYİ OYNA
- Gerçek pozisyonlardan günlük bulmacalar.
- Oyunun nerede döndüğünü gösteren maç analizi.
- Telefonunda saklanan oyun tekrarları.

SENİN MASAN, SENİN TARZIN
Toplanacak tahtalar, pullar, zarlar, zar kapları ve masalar. Her kozmetik
yalnızca görünümü değiştirir; hiçbir atışı veya hamleyi etkilemez.

PARALAR VE SATIN ALMALAR HAKKINDA
Paralar oynayarak, görevler ve sezonlarla kazanılır. Satın alınamaz ve
gerçek paraya çevrilemez. İsteğe bağlı Yakut satın alımları yalnızca
kozmetikleri ve premium sezon hattını açar. Oyun gerçek para ödemez.

Çevrimdışı oyunlar internet olmadan çalışır. Azerbaycanca, İngilizce,
Rusça ve Türkçe.
```

Wording checks before submitting:

- League names must match the ARB tier names (`tierBronze` … `tierGrandmaster`)
  and AI level names (`aiLevel*`) in each language; the two strongest AI
  levels are still "coming soon" (ADR-019), so the copy says "strong club
  player", not "master".
- "Sit-and-go" stays in Latin script in ru/tr, as in the app.
- If push notifications are not live at launch (ADR-041), do not add any
  "we will notify you" line.

---

## 4. Keywords

App Store keyword field (≤ 100 bytes, no words already in the suggested
title or subtitle from §1, singular forms, no competitor names). If the
title changes, move its search words (backgammon, tavla, nərd, нарды) back
into this field. Google Play has no keyword
field: work the same words naturally into the full description.

| Lang | App Store keyword field | Bytes |
|---|---|---|
| en | `narde,board game,dice,puzzle,tournament,clan,classic,strategy,offline,gammon` | 76 |
| az | `taxta oyunu,zər,turnir,klan,tapmaca,oflayn,strategiya,backgammon` | 65 |
| ru | `бэкгаммон,кости,турнир,клан,офлайн,задачи,шашки` | 88 (Cyrillic = 2 bytes) |
| tr | `zar,masa oyunu,turnuva,klan,bulmaca,çevrimdışı,strateji,gammon,backgammon` | 77 |

Search terms to monitor (both stores): en "backgammon", "backgammon online",
"long nard"; az "nərd", "şeşbeş"; ru "нарды", "длинные нарды", "нарды
онлайн"; tr "tavla", "uzun tavla", "online tavla". Do not use "okey",
"101" or other games' names; that breaks store keyword policy.

---

## 5. Screenshot shot list

Phone portrait 6.7"/6.9" (1290×2796) and 6.5" (1242×2688) for the App Store;
1080×1920 or larger for Google Play; tablet sets are the scaled phone layout
(ADR-016). 8 shots, in this order (first three carry most installs). Use the
default sebeke theme, a believable mid-game position, real-looking nicknames
(no real people), Azerbaijani UI for the az listing, English for en, etc.
Caption sits above the device frame, one line, sentence case, no full stop.

| # | Screen (route) | What to show | Caption en | az | ru | tr |
|---|---|---|---|---|---|---|
| 1 | Game board, Short Nard (`/game`) | Mid-game, dice just rolled, move hints visible | Backgammon as it is played at home | Nərd evdə oynandığı kimi | Нарды, как их играют дома | Tavla, evde oynandığı gibi |
| 2 | Game board, Long Nard | All checkers in play, head rule visible | Short and Long Nard, both done right | Qısa və uzun nərd, qaydasında | Короткие и длинные нарды по правилам | Klasik ve uzun tavla, kurallarına uygun |
| 3 | 10.3 Fair dice (`/online/fair`) | Seal opened, "match" state | Every online roll can be checked | Hər onlayn atışı yoxlaya bilərsən | Каждый онлайн-бросок можно проверить | Her online atışı doğrulayabilirsin |
| 4 | 2.5 VS screen (`/online/vs`) | Two players, ranks, ranked match to 5 | Ranked play with a rating for each variant | Hər növ üçün reytinqli oyun | Рейтинговые партии в каждом виде | Her tür için dereceli oyun |
| 5 | Tournament bracket (`/tournaments/:id/bracket`) | Knockout in progress | Tournaments, from quick tables to knockouts | Turnirlər: tez masalardan nokauta qədər | Турниры: от быстрых столов до плей-офф | Turnuvalar: hızlı masalardan elemeye |
| 6 | 5.4 Clan home (`/clan`) | Chat, weekly chest, war banner | A clan to call your own | Öz klanın | Свой клан | Kendi klanın |
| 7 | Practice puzzle (`/puzzles`) or analysis | Puzzle with the best move highlighted | Daily puzzles from real games | Real oyunlardan gündəlik tapmacalar | Ежедневные задачи из реальных партий | Gerçek oyunlardan günlük bulmacalar |
| 8 | Locker (`/locker`) | A board set preview | Boards and dice to collect, never pay-to-win | Toplamaq üçün taxtalar və zərlər, üstünlük satılmır | Доски и кости для коллекции, без преимуществ за деньги | Toplanacak tahtalar ve zarlar, parayla avantaj yok |

Do not show: prices, Yaqut packs, coin amounts next to tournament prizes
(reads as wagering), the banned or offline states, debug banners, or any
placeholder name if the final name differs.

Google Play also needs a **feature graphic** (1024×500, no text near the
edges) and optionally a 30 s preview video (board close-ups, no voice-over).

---

## 6. Age rating questionnaire notes

### Google Play (IARC)

| Question | Answer | Note |
|---|---|---|
| Category | Game (Board) | |
| Violence, fear, sexuality, crude humour, drugs, alcohol, tobacco | No | |
| Profanity | No in our content | Chat is user content (see below) |
| **Simulated gambling** | **No** | Backgammon is a dice board game. No betting, no casino games, no wagering of anything bought with money. Coins are earned only, cannot be bought (ADR-022), cannot be cashed out. |
| Real-money gambling | No | No real-money prizes anywhere |
| Users can interact / communicate | Yes | Clan chat, nicknames, clan names, preset emotes; report + block + moderation (ADR-042) |
| Shares user location | No | Country is self-chosen for leaderboards; no GPS |
| Digital purchases | Yes | Yaqut (cosmetics and premium season pass only) |
| Unrestricted internet / web browsing | No | |

Expected result: the lowest tier (IARC 3 / PEGI 3 / USK 0 / ESRB E) with
the notices "Users Interact" and "In-App Purchases". If the questionnaire
asks whether players can "wager" virtual currency: coin-entry tournaments
pay earned coins to the top places. Answer honestly that entry uses
earned-only, non-purchasable, non-cashable coins; owner to decide whether
to keep coin-entry tournaments in markets where reviewers treat this as
simulated gambling (see SPEC economy notes, ADR-022).

### App Store (age rating questionnaire)

- Simulated gambling: **None**. Contests: yes (tournaments, no prizes of
  value). Unrestricted web access: no. Gambling with real money: no.
- Messaging / chat and user-generated content: **yes** (clan chat). App
  Review guideline 1.2 needs: a way to report content and users (in the
  player menu), blocking (yes), moderation with action on reports (admin
  panel, ADR-042), and a published contact (support e-mail, see §8).
- Expected rating: 4+ (or 9+ if the chat answer raises it), plus the
  "In-App Purchases" notice. The final age is what the questionnaire
  computes; do not pick a higher age to "be safe" without the owner.
- Kids category: **no** (online chat with strangers).

---

## 7. Data safety (Google Play) and privacy nutrition label (App Store)

Derived from `apps/api/database/migrations` and the client (no analytics,
ads or crash SDK in `apps/client/pubspec.yaml` today). Re-check before
submitting: Phase 7 observability may add server-side error reporting, and
push (FCM) is disabled until keys exist (ADR-041).

### What the server stores

| Data | Where | Why | Required? | Retention |
|---|---|---|---|---|
| Nickname, avatar, country (self-chosen), locale | `users` | Profile, leaderboards | Nickname yes (guests get "Qonaq…"), others optional | Until the account is deleted |
| E-mail address | `users.email`, `login_codes` (code hash, 10 min) | Sign-in, account recovery | Optional (guests have none) | Until deleted |
| Apple / Google subject id | `users.apple_sub` / `google_sub` | Sign-in (disabled until keys, ADR-030) | Optional | Until deleted |
| Install device id (random, created by the app) | `users.device_id` | Guest account per install (ADR-020) | Guests | Until deleted |
| IP address (last, raw) and hashed IP / device sightings | `users.last_ip`, `user_sightings` | Fraud prevention, multi-account detection (ADR-042, QUESTIONS #42) | Automatic | Sightings 90 days; last IP until the next sign-in or deletion |
| Match history, game records, server dice seeds, ratings, seasons, tournaments | `game_matches`, `ratings`, `season_*`, `tournament_*` | Gameplay, fair-dice proof, anti-cheat | Automatic when playing online | Until deleted (see note) |
| Progress, missions, achievements, puzzle attempts | `users`, `user_missions`, `user_achievements`, `puzzle_attempts` | Gameplay | Automatic | Until deleted |
| Wallet, purchases, inventory, loadouts | `wallets`, `wallet_transactions`, `user_items`, `loadouts` | In-app purchases (Yaqut), earned coins | Automatic | Until deleted |
| Friends, blocks, challenges | `friendships`, `blocks`, `challenges` | Social features | Optional | Until deleted |
| Clan membership and chat messages | `clan_members`, `clan_messages` | Clan chat | Optional | Until deleted |
| Reports (reason, optional note, match id) | `reports` | Safety / moderation | Optional | Kept; reporter link removed on deletion |
| Inbox notifications, notification settings | `notifications`, `notification_settings` | In-app inbox | Automatic | Inbox rows 60 days |
| Push token (FCM), platform, locale | `device_tokens` | Push (only when enabled) | Optional (OS permission) | Until sign-out, deletion or token expiry |
| Moderation state (ban, mute, cooldown, flags) | `users`, `cheat_flags`, `admin_actions` | Safety / fair play | Automatic | Kept for audit |

On the phone only (not collected): offline games and replays (Drift
database), settings, the API token and device id (keychain / keystore).

Note for the owner: deleting an account removes the user row and its
cascades, but `game_matches` keeps the player's **name string** in their
opponents' history (the user id is nulled). Either disclose that in the
privacy policy or ask for an API change to anonymise names on deletion.

### Google Play data safety form

- Collects data: **yes**. Shares data with third parties: **no** (hosting,
  e-mail delivery and FCM are service providers, which Play does not count
  as sharing). Data is encrypted in transit: **yes** (HTTPS / WSS in
  production; confirm TLS on the deployed hosts). Users can request
  deletion: **yes** (in-app "Delete account", plus a web deletion page
  that Play requires; see §8).

| Play category → type | Collected | Purpose | Optional |
|---|---|---|---|
| Personal info → Name (nickname) | Yes | App functionality, Account management | No |
| Personal info → Email address | Yes | Account management | Yes |
| Personal info → User IDs | Yes | App functionality, Account management | No |
| Personal info → Other info (self-chosen country) | Yes | App functionality | Yes |
| Financial info → Purchase history | Yes | App functionality | Yes (only if buying) |
| Messages → Other in-app messages (clan chat, report notes) | Yes | App functionality, Fraud prevention / security | Yes |
| App activity → Other actions (matches, ratings, progress) | Yes | App functionality, Fraud prevention / security | No |
| App activity → Other user-generated content (clan names, descriptions) | Yes | App functionality | Yes |
| Device or other IDs (install id, hashed device sighting, FCM token) | Yes | App functionality, Fraud prevention / security | No |
| Location | No | The IP address is stored for fraud prevention only, never to derive location (state this in the privacy policy) | — |
| App info and performance (crash logs, diagnostics) | No today | Revisit if client crash reporting is added | — |
| Advertising ID, contacts, photos, files, health, web history | No | | — |

### App Store privacy nutrition label

- Data used to track you: **none** (no ads, no cross-app tracking; no ATT prompt needed).
- Data linked to you:
  - Contact Info → Email Address (App Functionality)
  - User Content → Other User Content (clan chat, clan text, reports) and
    Gameplay Content (matches, records) (App Functionality)
  - Identifiers → User ID, Device ID (App Functionality)
  - Purchases → Purchase History (App Functionality)
  - Other Data → country, nickname (App Functionality)
- Data not linked to you: none.
- Not collected: location, contacts, health, financial info other than
  purchase history, browsing, search history, diagnostics (today), usage
  data for analytics.
- Account deletion is in the app (App Review guideline 5.1.1(v)).

---

## 8. What the owner must provide

- [ ] **Final app name** in all four languages, trademark-checked (§1).
- [ ] **Developer accounts**: individual Google Play Console and Apple
      Developer Program accounts in the owner's name (owner's choice,
      docs/LAUNCH.md); Google requires a 14-day closed test with 12+
      testers before production for new personal accounts.
- [ ] **Final bundle id / application id** (now `com.nardarena.app`);
      it cannot change after the first upload.
- [ ] **Privacy policy URL** (public, all four languages if possible) that
      covers the table in §7, including IP / device sightings (QUESTIONS
      #42) and the deleted-account name note.
- [x] **Account deletion web page** (required by Google Play in
      addition to in-app deletion): built into the API at
      `https://<api-host>/delete-account` (QUESTIONS #45; e-mail code →
      same 30-day grace, never creates an account; `?lang=az|en|ru|tr`).
      Guests delete in the app. Owner: give Play the URL once the API host
      is live.
- [ ] **Support e-mail** for the stores, the banned screen and the
      deletion page (`kSupportEmail` in
      `apps/client/lib/moderation/moderation.dart` and `SUPPORT_EMAIL` /
      `nard.support_email` in the API; both default to
      `support@nardarena.app`, QUESTIONS #41), and optionally a support / marketing website.
- [ ] **App icon** (1024×1024, no transparency for iOS; adaptive icon
      foreground + background for Android), **feature graphic**
      (1024×500), optional promo video.
- [ ] **Screenshots** per §5, or approval for us to capture them from the
      emulator.
- [ ] **Store pricing and Yaqut product ids** (`config/iap.php`), tax and
      banking forms in both consoles, and the paid-apps agreement (Apple).
- [ ] **Sign-in keys** if Apple / Google sign-in ship (ADR-030); offering
      Google sign-in on iOS requires Sign in with Apple too (guideline 4.8).
- [ ] **Firebase project + APNs key** if push ships at launch (ADR-041).
- [ ] **Content rating contact e-mail** and answers sign-off (§6),
      especially coin-entry tournaments.
- [ ] **Target countries** (Azerbaijan, Turkey, CIS first per SPEC) and
      whether to exclude any market for regulatory reasons.
- [ ] **Copyright line** ("© 2026 …", the owner's name for an individual
      account) for the App Store.
