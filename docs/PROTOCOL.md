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

Message types (spec §7.2): `hello`, `auth`, `queue.join`, `queue.leave`,
`match.found`, `game.state`, `game.roll`, `game.move`, `game.undo`,
`game.confirmTurn`, `cube.offer`, `cube.take`, `cube.drop`, `game.resign`,
`game.timeout`, `chat.emote`, `spectate.join`, `ping`, `pong`, `error`.

Status: Phase 0 implements the envelope, validation and `ping`→`pong`; any
other valid type returns `error {code: not_implemented}`, malformed frames
return `error {code: bad_request}`. Payload schemas, `seq` ordering and the
JSON-schema export for PHP arrive in Phase 3.
