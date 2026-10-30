# Architecture

```
            ┌──────────────── Flutter client (Phase 2) ────────────────┐
            │ Flame board · Riverpod · Drift · nard_core · nard_ai     │
            └───────────────┬───────────────────────────┬──────────────┘
                     HTTPS (REST)                 WebSocket (JSON envelopes)
                            │                           │
              ┌─────────────▼───────┐       ┌───────────▼──────────────┐
              │ apps/api  Laravel   │◀─────▶│ apps/game_server  Dart   │
              │ auth, profiles,     │ Redis │ authoritative games,     │
              │ clans, store, admin │Streams│ nard_core validation,    │
              └──────┬──────────────┘       │ clocks, fair dice        │
                     │                      └───────────┬──────────────┘
                  MySQL 8                          Redis (queues, presence,
                                                   snapshots, pub/sub)
```

## Packages

| Path | Role | Status |
|---|---|---|
| `packages/nard_core` | Pure Dart rules engine: `BoardState`, `DiceRoll`/`DiceSource`, `RuleSet` (`ShortNardRules`, `LongNardRules`), `TurnPlanner` (move generation and validation), `DoublingCube`, `GameState` + `GameAction`, `MatchState`, `GameRecord`, `MoveNotation`, GNU BG `PositionId`/`MatchId`. No Flutter, no I/O. | Phase 1 ✔ |
| `packages/nard_ai` | Bots. `Bot` interface + `RandomBot`. Heuristic levels in Phase 2. | skeleton |
| `packages/nard_protocol` | WS `Envelope` `{v,type,id,ts,payload}` + message types. Payload models in Phase 3. | skeleton |
| `apps/game_server` | shelf server: `/healthz`, `/ws` (ping/pong). | skeleton |
| `apps/api` | Laravel 13 (see ADR-002); `/up` health. | skeleton |
| `infra/` | `docker-compose.yml` (MySQL, Redis, api, game_server). Helm/K8s later. | Phase 0 ✔ |

## Engine data flow

1. `GameState.newGame(rules, config)` → phase `opening`.
2. Server/client feeds actions: `OpeningRoll`, `RollDice(side, roll)`,
   `PlayTurn(side, moves)`, `OfferDouble`/`TakeDouble`/`DropDouble`,
   `OfferResignation`/`Accept…`/`Reject…`, `Forfeit`.
3. `apply` validates everything (phase, actor, legality) and returns a new
   immutable state; illegal input throws `IllegalActionException` or
   `IllegalMoveException`.
4. While a player builds a turn, the UI/server uses `state.planner`:
   `nextMoves(played)` for highlighting/undo, `resolve([(from,to)])` to map
   drag-and-drop intents onto legal moves (including bear-off dice choice).
5. The ordered action list is the `GameRecord` (JSON, versioned); replaying
   it re-validates the whole game — used for replays, sync and anti-cheat.
6. `MatchState.withResult` advances scores and the Crawford state;
   `MatchState.gameConfig()` produces the next game's `GameConfig`.

## Performance

Legal-turn generation on random positions (JIT, dev machine):
Short Nard p50 ≈ 21 µs, p95 ≈ 170 µs; Long Nard p50 ≈ 22 µs, p95 ≈ 90 µs.
A test guards the < 1 ms average.

## Local development

```
dart pub get                      # whole workspace
cd packages/nard_core && dart test
docker compose -f infra/docker-compose.yml up --build
# API: http://localhost:18000/up   game server: http://localhost:18080/healthz
```
