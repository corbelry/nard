# Social API: friends and challenges (Phase 5)

All under `/api/v1`, bearer token. Errors: `{code}`; bad input 422
`{message, errors}`. Screens: `docs/design-notes/social.md` (6.1–6.3);
decisions: ADR-037, time controls ADR-044.

Shapes
- PublicUser `{id, name, country, avatar, level, title, online, ratings{variant: rating}, clan{id, name, tag}|null}`
- Challenge `{id, from: PublicUser, code, variant: shortNard|longNard, matchLength: 1|3|5|7, timeControl: blitz|rapid|classic, expiresAt}`

Endpoints
- `GET /friends` → `{friends, incoming, outgoing: [{requestId, user: PublicUser}], friendCode, challenges: [Challenge]}` — friends sorted online first, then by name; `challenges` = unexpired ones sent to me, newest first.
- `POST /friends/requests {code | userId}` → 201 `{status: requested|accepted, user}`; 404 `not_found`, 422 `self|blocked|already_friends|already_requested|too_many_friends`.
- `POST /friends/requests/{id}/accept`, `DELETE /friends/requests/{id}`, `DELETE /friends/{userId}` → `{ok}` | 404.
- `POST /challenges {userId, code [A-Z2-9]{6}, variant, matchLength, timeControl?}` → 201 `{id}` — offers my private room (6.3) to a friend; 422 `not_friends`. `timeControl` is the room's clock (the host's `room.create`); absent = `rapid` (older clients), anything else than `blitz|rapid|classic` is a validation error. A new challenge to the same friend replaces the previous one; valid 10 minutes. The friend gets a `challenge` notification (docs/api/notifications.md) with the same fields.
- `GET /users/search?q` (≥ 3 chars) → `{users: [PublicUser]}`.
- `GET /blocks` → `{users}`; `POST|DELETE /blocks/{userId}` → `{ok}`.
- `POST /reports {userId, reason, matchId?, note?}` → 201 `{reference "R-000123"}`; 429 `rate_limited`.

The room itself (code, clock, pairing) lives on the game server
(`room.create {variant, matchLength, timeControl?}` / `room.join {code}`,
docs/PROTOCOL.md); the API only relays the offer. The guest always plays
the clock of the host's room.
