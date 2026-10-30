# Clans API (Phase 5)

All under `/api/v1`, bearer token. Errors: `{code}` — 422 refused, 403
`not_member` / `forbidden`, 404 `not_found`, 429 `rate_limited`; bad input
422 `{message, errors}`. Numbers: `apps/api/config/clans.php`.

Shapes
- ClanSummary `{id, name, tag, emblem{shape,symbol,color,pattern}, level, xp, memberCount, maxMembers, rating|null, language, joinPolicy, minRating|null}`
- Message `{id, kind:text|system, author{id,name,avatar}|null, text|null, event|null, data|null, createdAt}`;
  events `created, joined, left, kicked, promoted, demoted` `{userId,name[,role]}`, `leader`, `renamed{name,tag}`,
  `donated{userId,name,amount}`, `chest_full{target}`, `war_started{clanId,name,tag}`, `war_win{userId,name,points}`, `war_ended{result,mine,theirs}`

Clans
- `GET /clans?q=&language=&policy=&maxMinRating=` → `{clans:[ClanSummary]}` (q 2–24: name contains / tag prefix; top 30 by level, xp)
- `GET /clans/tag-available?tag=` → `{tag, valid, available}`
- `GET /clans/leaderboard` → `{entries:[{rank, clan, points}], me:{rank, points, clan{id,tag,emblem}}|null}` (top 50 by XP)
- `POST /clans {name, tag, emblem, language, joinPolicy, minRating?, description?, idempotencyKey}` → 201 `{clan, wallet}`; errors `already_in_clan, insufficient_funds, name_taken, tag_taken` (3 000 coins)
- `GET /clans/{id}` → `{clan(+description), xpNext, onlineCount, createdAt, myStatus:none|pending|invited|member, myRole, requirementsMet{rating}, chest{week,coins,target,myDonated}|null, members:[{user:publicCard, role, joinedAt, weeklyDonated}]}`
- `PATCH /clans/{id}` (create fields; `idempotencyKey` when name/tag change — 1 000 coins, leader) → `{clan, wallet}`
- `DELETE /clans/{id}` disband (leader)

Membership
- `POST /clans/{id}/join` → `{status: joined|requested}`; errors `invite_only, rating_too_low, clan_full, already_in_clan`; `DELETE /clans/{id}/join` cancels a request
- `POST /clans/{id}/leave` → `{status: left|disbanded}` | `transfer_first`
- `GET /clans/{id}/requests` → `{requests:[{id, user, createdAt}]}`; `POST /clans/{id}/requests/{rid}/accept`; `DELETE /clans/{id}/requests/{rid}`
- `POST /clans/{id}/invites {userId}` → 201 `{id}`; errors `self, already_in_clan, blocked, clan_full`
- `GET /me/clan-invites` → `{invites:[{id, clan, invitedBy, expiresAt}]}`; `POST /me/clan-invites/{id}/accept` → `{clan}`; `DELETE /me/clan-invites/{id}`
- `POST /clans/{id}/members/{userId}/role {role}` (`leader` transfers); `DELETE /clans/{id}/members/{userId}` kick

Chat, chest, war
- `GET /clans/{id}/messages?after=` → `{messages}` (latest 50 after id, oldest first); `POST /clans/{id}/messages {text}` → 201 `{message}` (≤300, 10/min); `DELETE /clans/{id}/messages/{mid}`
- `POST /clans/{id}/donate {coins, idempotencyKey}` → `{donated, chest, clan{level,xp,xpNext}, wallet}`; errors `chest_full, insufficient_funds`
- `GET /clans/{id}/war` → `{war: null | {id, week, status:live|finished, startsAt, endsAt, clan, opponent|null, score{mine,theirs}, matchesCounted, maxMatches, pointsPerWin, result, matches:[{matchId, winner, loser, score, won, createdAt}]}}`

Elsewhere: `publicCard.clan = {id, tag, emblem}|null`; `/me` `user.clan = {id, tag, emblem, name, role}|null`.
Weekly `clans:pair-wars` (Mon 00:05 UTC) closes last week's wars and pairs clans.
