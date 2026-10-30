# WebSocket protocol (v1, draft)

Every frame is a JSON object:

```json
{ "v": 1, "type": "game.move", "id": "c-42", "ts": 1767225600000, "payload": {} }
```

| Field | Meaning |
|---|---|
| `v` | Protocol version (`protocolVersion` in `nard_protocol`). |
| `type` | One of the message types below. Unknown types are rejected. |
| `id` | Sender-generated id (1–64 chars); replies echo it. |
| `ts` | Sender clock, ms since epoch. |
| `payload` | Type-specific object. |

Payload models: `packages/nard_protocol/lib/src/messages.dart` (every
`fromJson` validates and throws `ProtocolException`).

## Flow

```
client                                   game_server
  auth {ticket, features?}           →     (ticket from the API, signed)
                                     ←     hello {userId, features?}
                                     ←     game.state (if a match is running: reconnect)
  queue.join {variant, matchLength, mode, timeControl?}  →
                                     ←     match.found {matchId, you, white, black, clock}
  game.seed {clientSeed}             →     (FD-02; both seeds before the opening)
                                     ←     game.state {seq, record, match, pending, clock, commitment, …}
                                     ←     game.state {seq, delta: {from, actions}, …} (ADR-048)
  game.sync {matchId}                →     after a delta gap: full game.state again
  game.roll {}                       →     server rolls with FairDice, broadcasts game.state
  game.move {from, to}               →     validated with TurnPlanner; error {rejection} if refused
  game.undo {}  /  game.confirmTurn {} →   pending moves are server state; confirm applies PlayTurn
  cube.offer / cube.take / cube.drop {} →
  game.resign {kind}                 →     accepted at once (ADR-031)
                                     ←     game.timeout {loser} when a reserve runs out
  queue.leave {}, ping/pong
```

## Payloads

| Type | Direction | Payload |
|---|---|---|
| `auth` | C→S | `{ticket, features?: ["stateDelta"]}` (optional features, ADR-048; unknown names are ignored) |
| `hello` | S→C | `{userId, features?}`: the announced features the server enabled |
| `queue.join` | C→S | `{variant: shortNard\|longNard, matchLength: 1\|3\|5\|7, mode: casual\|ranked, timeControl?: blitz\|rapid\|classic}` (`tournament` is refused; `timeControl` absent = `rapid`; one queue per variant/length/mode/timeControl, ADR-044) |
| `match.found` | S→C | `{matchId, variant, matchLength, mode: casual\|ranked\|tournament, you: white\|black, white: Player, black: Player, clock: {reserveMs, delayMs}, tournamentId?, round?}`; Player = `{userId, name, rating?, country?, bot}` |
| `tournament.readyState` | S→C | `{matchId, tournamentId, round, you, white: Player, black: Player, ready: {white, black}, deadline}`: an assigned tournament match waiting for its players |
| `tournament.ready` | C→S | `{matchId}` ("Hazıram"; connecting also counts as present) |
| `tournament.walkover` | S→C | `{matchId, tournamentId, winner?}`: decided without play after the no-show time (no `winner`: nobody came) |
| `game.seed` | C→S | `{clientSeed}` (≤ 64 chars) |
| `game.state` | S→C | `{seq, matchId, gameIndex, record: GameRecord JSON, match: MatchState JSON, pending: [{from, to, die, hit}], clock: {whiteMs, blackMs, delayMs, running?, sentAt}, commitment, serverSeed? (after the game), clientSeeds, opponentConnected, reconnectDeadline?}` |
| `game.state` (delta) | S→C | `{seq, matchId, gameIndex, delta: {from, actions: [GameAction JSON]}, match?, pending, clock, serverSeed?, clientSeeds?, opponentConnected, reconnectDeadline?}`: only to `stateDelta` connections (ADR-048) |
| `game.sync` | C→S | `{matchId}`: resend the full `game.state` of the match played or watched; `error {not_in_match}` otherwise |
| `game.move` | C→S | `{from: 1..25, to: 0..24}` (mover's numbering, 25 = bar, 0 = off) |
| `game.resign` | C→S | `{kind: single\|gammon\|backgammon}` |
| `error` | S→C | `{code, message, rejection?}`; codes: `bad_request`, `unauthorized`, `not_in_match`, `not_your_turn`, `illegal_move`, `illegal_action`, `rate_limited`, `not_implemented`, `queue_cooldown`, `banned` |

A full `game.state` carries the whole `record`; clients replay it with
`nard_core` and drop any state whose `seq` is not newer than the last one.

### `game.state` deltas (ADR-048)

A client that sends `auth.features: ["stateDelta"]` gets full states only
when it has no base: the first state on a socket (match start, reconnect),
`spectate.join`, a new game of the match, and `game.sync`. Every other
`game.state` is a delta against the previous state sent on that socket:

- `delta.from` = how many record actions the client already holds;
  `delta.actions` = the actions after them (often none: a move of the turn
  being built, a clock or connection change);
- no `record` and no `commitment` (fixed for the game);
- `match` and `clientSeeds` only when they changed since that state;
- every other field is complete (`pending`, `clock`, `serverSeed`, …).

The client applies a delta only when `matchId` and `gameIndex` equal its
state's and its record has exactly `from` actions; otherwise it sends
`game.sync {matchId}` once and ignores deltas until a full state arrives
(`GameStateSync` in `nard_protocol`). The rebuilt record is identical to
the full one, so fair-dice checks, replays and the result screen work
unchanged. Clients that announce nothing (older apps) always get full
states. In the load test a full state averaged 5.1 KB (up to 17 KB) and a
delta 372 bytes (docs/LOAD_TEST.md).

## Time controls (ADR-044)

| `timeControl` | Clock (`reserveMs` + `delayMs`) |
|---|---|
| `blitz` | 1 min + 8 s (60 000 + 8 000) |
| `rapid` (default) | 3 min + 12 s (180 000 + 12 000) |
| `classic` | 5 min + 15 s (300 000 + 15 000) |

`room.create {variant, matchLength, timeControl?}` takes the same optional
field (default `rapid`); the guest (`room.join {code}`) always plays the
host room's clock. The API's friend challenge carries it for display only
(docs/api/social.md). Tournament matches play `rapid`. Unknown values are
refused with `bad_request`. `match.found.clock` carries the values.

## Tickets

The API issues a short-lived ticket per WebSocket session:
`base64url(json) "." base64url(HMAC-SHA256(GAME_TICKET_SECRET, base64url(json)))`
(unpadded base64url), JSON `{sub, name, country?, ratings: {shortNard?,
longNard?}, cosmetics?, muted?, queueCooldownUntil?, exp}` (`exp` and
`queueCooldownUntil` in seconds). The game server verifies it in
constant time (`apps/game_server/lib/src/ticket.dart`). Moderation
(ADR-042): banned accounts get no ticket; `muted: true` → the server drops
the player's `chat.emote` silently; `queueCooldownUntil` (abandonment
penalty) → `queue.join` is refused with `queue_cooldown` (message = the end
time) until then; private rooms and tournament matches stay open. One live connection
per user; a newer connection replaces the old one (reconnect).

The ticket is checked once; later changes reach a live session through
the API's moderation push (ADR-045, see API contract): a ban sends
`error {code: banned}` and closes the socket with `4008 banned`, a mute or
cooldown applies to the open session at once (a queued player gets
`queue_cooldown` and leaves the queue). Sessions are not closed when the
ticket's `exp` passes.

## Connection limits (ADR-045)

Defaults, configurable on the game server by env (`WsLimits`):

- `auth` must succeed within 10 s, else close `4008 auth_timeout`.
- Frames over 16 KiB close the socket with `4009 frame_too_large`.
- 20 messages/s per connection, burst 40: excess messages get
  `error {code: rate_limited}` (once per run) and are dropped; more than 40
  refused in a row close the socket with `4008 rate_limited`.
- At most 20 concurrent sockets per client address (HTTP 429 on the
  upgrade).
- The server sends WebSocket pings every 30 s; dead peers are dropped.

Close codes (`CloseCode`): `4008` policy (reason `banned`, `auth_timeout`,
`rate_limited`), `4009` frame too large.

## API contract

The game server reports finished matches as `MatchResult`
(`schema/match_result.schema.json`, exported by
`dart run tool/export_schema.dart` in `packages/nard_protocol`).
Tournament matches (`docs/api/tournaments.md`): the API pushes pairings to
`POST /internal/tournament-matches` (`schema/tournament_match.schema.json`,
signed like results); results carry `mode: tournament` and `tournamentId`
(`reason: walkover` when one player never came); when neither came the game
server posts `TournamentNoShow` (`schema/tournament_no_show.schema.json`).
Results also carry an optional `timeControl` (ADR-044); the API currently
ignores it (ratings are shared across controls).
Moderation (ADR-045): the API posts `ModerationPayload`
(`schema/moderation.schema.json`, `{userId, banned, muted,
queueCooldownUntil: epoch s|null}`, signed the same way) to
`POST /internal/moderation`; the game server answers
`200 {userId, connected}`, `401 {code: bad_signature}` or `400`.
