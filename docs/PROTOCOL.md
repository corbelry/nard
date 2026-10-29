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
  auth {ticket}                      →     (ticket from the API, signed)
                                     ←     game.state (if a match is running: reconnect)
  queue.join {variant, matchLength, mode}  →
                                     ←     match.found {matchId, you, white, black, clock}
  game.seed {clientSeed}             →     (FD-02; both seeds before the opening)
                                     ←     game.state {seq, record, match, pending, clock, commitment, …}
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
| `auth` | C→S | `{ticket}` |
| `queue.join` | C→S | `{variant: shortNard\|longNard, matchLength: 1\|3\|5\|7, mode: casual\|ranked}` |
| `match.found` | S→C | `{matchId, variant, matchLength, mode, you: white\|black, white: Player, black: Player, clock: {reserveMs, delayMs}}`; Player = `{userId, name, rating?, country?, bot}` |
| `game.seed` | C→S | `{clientSeed}` (≤ 64 chars) |
| `game.state` | S→C | `{seq, matchId, gameIndex, record: GameRecord JSON, match: MatchState JSON, pending: [{from, to, die, hit}], clock: {whiteMs, blackMs, delayMs, running?, sentAt}, commitment, serverSeed? (after the game), clientSeeds, opponentConnected, reconnectDeadline?}` |
| `game.move` | C→S | `{from: 1..25, to: 0..24}` (mover's numbering, 25 = bar, 0 = off) |
| `game.resign` | C→S | `{kind: single\|gammon\|backgammon}` |
| `error` | S→C | `{code, message, rejection?}`; codes: `bad_request`, `unauthorized`, `not_in_match`, `not_your_turn`, `illegal_move`, `illegal_action`, `rate_limited`, `not_implemented` |

`game.state` is always the full state; clients replay `record` with
`nard_core` and drop any state whose `seq` is not newer than the last one.

## Tickets

The API issues a short-lived ticket per WebSocket session:
`base64url(json) "." base64url(HMAC-SHA256(GAME_TICKET_SECRET, base64url(json)))`
(unpadded base64url), JSON `{sub, name, country?, ratings: {shortNard?,
longNard?}, exp}` (`exp` in seconds). The game server verifies it in
constant time (`apps/game_server/lib/src/ticket.dart`). One live connection
per user; a newer connection replaces the old one (reconnect).

## API contract

The game server reports finished matches as `MatchResult`
(`schema/match_result.schema.json`, exported by
`dart run tool/export_schema.dart` in `packages/nard_protocol`).
