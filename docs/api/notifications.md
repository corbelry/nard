# Notifications API (Phase 7)

All under `/api/v1`, bearer token. Errors: `{code}` — 404 `not_found`, 422
`unknown_category`; bad input 422 `{message, errors}`. Config:
`apps/api/config/push.php`; decisions: ADR-041; screens:
`docs/design-notes/notifications.md`.

Shapes
- Notification `{id, type, category|null, data, from{id,name,avatar,country}|null, read, createdAt}` — newest first.
- Settings `{push, quietHours{enabled, start "HH:MM", end "HH:MM"}, categories{game_invites, tournament_start, tournament_round, friend_requests, clan, clan_war, rewards: bool}, pushAvailable}`
  (`pushAvailable` = the server can send pushes, i.e. FCM is configured).

Types (`data` fields; category in brackets; push copy in `lang/{az,en,ru,tr}/notifications.php`)
- `friend_request {requestId}` [friend_requests], `from` = requester
- `friend_accepted {}` [friend_requests], `from` = the new friend
- `challenge {challengeId, code, variant, matchLength, timeControl, expiresAt}` [game_invites], `from` = challenger; one row per sender + room code; `timeControl` (`blitz|rapid|classic`, ADR-044) is missing on rows from before it (= `rapid`)
- `clan_invite {inviteId, clanId, clan, tag, expiresAt}` [clan], `from` = inviter
- `clan_joined {clanId, clan, tag}` [clan] — my join request was accepted
- `clan_war {clanId, warId, opponentId, opponent, tag}` [clan_war] — to every member of both clans
- `tournament_reminder {tournamentId, tournament{locale: name}, minutes, startsAt}` [tournament_start] — 15 min before (`push.tournament_reminder_minutes`)
- `tournament_started {tournamentId, tournament}` [tournament_start] — round 1 is ready
- `tournament_round {tournamentId, tournament, round, matchId, opponent}` [tournament_round] — rounds ≥ 2
- `tournament_eliminated {tournamentId, tournament, round, place}` [tournament_round] — knockout loss; `place` = final knockout place (missing on rows from before ADR-049)
- `tournament_won {tournamentId, tournament}` [tournament_round] — 1st place
- `tournament_finished {tournamentId, tournament, place}` [tournament_round] — Swiss / round-robin, places 2+
- `tournament_cancelled {tournamentId, tournament, reason, refund}` [tournament_start] — `reason` = `not_enough_players|not_filled|expired|organizer`, `refund` = coins returned (0 when free); not sent to an organiser who cancelled their own tournament
- `season_end {season, tier, coins, itemId|null, rank, variant}` [rewards] — `rank` (global) of the `variant` whose rating gave the tier (missing on rows from before ADR-049)
- `season_started {season, name{locale: name}, endsAt}` [rewards] — to everyone who played a match in the season that ended
- `level_up {level, coins}` [none: inbox only, never pushed]
- `moderation_warning {reason}` [none, inbox only] — sent by an admin (ADR-042); the client does not render it yet

Clients must ignore unknown types (render a generic row).

Inbox (16.2)
- `GET /notifications?after=&limit=` → `{notifications:[Notification], unread}` — latest `limit` (≤ 100, default 50); `after` = only ids above it (polling). Rows from players blocked either way are hidden.
- `POST /notifications/read {ids:[int]}` or `{all:true}` → `{unread}`
- `DELETE /notifications/{id}` → `{unread}` (after acting on a request / invite)

Settings (16.1)
- `GET /me/notification-settings` → `{settings}`; defaults: everything on, quiet hours 23:00–08:00
- `PUT /me/notification-settings {push?, quietHours?{enabled?, start?, end?}, categories?{key: bool}, utcOffset?}` → `{settings}` — partial; `utcOffset` = device minutes east of UTC (quiet hours are local)

Devices
- `POST /me/devices {platform: android|ios, token, locale?, utcOffset?}` → 201 — upsert by token (a token moves to the account that registers it last)
- `DELETE /me/devices {token}` (sign-out)

Delivery rules
- Every event is stored (dedupe key per player and event); pushes are queued
  (database queue, `SendPushNotification`, after commit) only when the type
  has a category that is on, `push` is on, it is outside quiet hours, the
  player has a device and FCM is configured. Otherwise the inbox is the only
  channel (a disabled sender logs `push disabled: not queued`).
- FCM HTTP v1 payload: `notification{title, body}` in the device's locale and
  `data{id, type, data}` (`data` = the row's JSON) for the deep link.
  Tokens FCM reports as unregistered (404) are deleted.
- Rows older than 60 days are pruned daily (`notifications:prune`).

Live delivery (ADR-049)
- Every new row is also queued (`PushLiveNotifications`, after commit, one
  batch per `notifyMany`) to the game server's signed `POST /internal/notify`,
  which sends it unchanged as S→C `notification` to the player's open socket.
  Best effort: one try, failures logged, never fail the action; nothing is
  queued without `GAME_SERVER_URL`. The 16.1 switches and quiet hours govern
  FCM pushes only, not this (the app is open).
- Tournament changes also send S→C `tournament.updated {tournamentId}` to the
  connected entrants (`POST /internal/tournament-updated`).
- The client keeps the socket open while foregrounded and signed in, adds
  the row to the inbox (bell count), shows a banner and refetches affected
  tournament / season data; it still polls when the socket is closed.
