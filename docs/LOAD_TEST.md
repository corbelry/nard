# Load test — game server (Phase 7, ADR-043)

Tool: `apps/game_server/tool/load_test.dart`. It runs against a live stack
(the docker compose one by default) and measures what spec §11 asks for:
the move round trip, from sending an intent to receiving the authoritative
`game.state` that applies it.

```
docker compose -f infra/docker-compose.yml up --build -d
cd apps/game_server
dart run tool/load_test.dart --matches 100 --duration 180 --think 500
#   --api http://localhost:18000  --ws ws://localhost:18080/ws
#   --metrics http://localhost:18080/metrics  --ramp 10  --workers 8
#   --accounts .dart_tool/load_test_accounts.json  --json out.json
```

## What it does

1. **Accounts.** It needs 2 × M guest accounts and creates them through
   `POST /api/v1/auth/guest`. Tokens are cached in `--accounts`, so later
   runs reuse them. That endpoint allows 20 sign-ups per minute per IP, and
   the tool waits whenever it gets a 429. For the one-time creation of 400
   local accounts we flushed the local Redis cache db (`redis-cli -n 1
   FLUSHDB` in a loop) so the limiter reset. This is a local-only shortcut.
2. **Tickets.** Each client gets a game ticket (`POST /api/v1/game/ticket`)
   and connects to `/ws`. Connections are spread over `--ramp` seconds.
3. **Play.** Every client queues for casual Short Nard (match length 1). As
   soon as a match ends it waits 0.5–1.5 s and queues again, which keeps
   about M matches running until `--duration` is over. Clients still in a
   match then finish it. Each client plays like a human: after every
   `game.state` that needs it to act, it waits `--think` ± 50 %. It then
   rolls, or plays the easy heuristic bot's turn and confirms it, or takes a
   cube.
4. **Measure.**
   - Move round trip: from the `game.roll` or `game.confirmTurn` send to
     the first `game.state` that shows it applied.
   - `ping`/`pong` round trip, every 5 s per client.
   - Matches found and completed, error messages by code, and stalled
     clients (no state for 90 s).
   - The server's `/metrics`, sampled every 5 s: memory, rooms,
     connections, matches, results reported or failed to the API, and
     message rates.
5. **Client cost.** Clients are spread over `--workers` isolates, so bot
   moves and JSON parsing on the load generator do not inflate the
   latencies.

The process exits non-zero when no match completes, a client stalls, or
the server counts an internal error. CI runs it as a two-match smoke test.

## Results (2026-11-07)

**Machine.** A laptop with an Intel i7-1360P (12 cores, 16 threads) and
38 GB RAM, Linux 6.8 and Docker 29.9. The whole compose stack (game server
in AOT binary + `scratch` image, API on PHP's built-in server, MySQL 8.4,
Redis 7.4) and the load generator share this machine. Everything goes over
loopback, so these numbers show server-side cost, not network latency.

Settings for every run: Short Nard, casual, match length 1, 180 s of load,
500 ms ± 250 ms think time, 10 s ramp. The game server was restarted
before each run.

| Concurrent matches (clients) | 20 (40) | 100 (200) | 200 (400) |
|---|---|---|---|
| Matches completed / started | 62 / 62 | 307 / 307 | 617 / 617 |
| Errors / stalled clients | 0 / 0 | 0 / 0 | 0 / 0 |
| **Move round trip p50 / p95 / p99** | 2 / 9 / 13 ms | 2 / 11 / 21 ms | 3 / 18 / 28 ms |
| Move round trip max | 25 ms | 155 ms | 64 ms |
| Ping round trip p50 / p95 / p99 | 1 / 2 / 6 ms | 1 / 6 / 14 ms | 1 / 14 / 25 ms |
| Room handle time p99 (histogram bucket) | ≤ 2.5 ms | ≤ 2.5 ms | ≤ 2.5 ms |
| Server messages in / out per s | 62 / 122 | 289 / 564 | 547 / 1067 |
| Game server peak RSS | 53 MB | 52 MB | 53 MB |
| Results reported to the API / failed | 61 / 0 ¹ | 306 / 0 ¹ | 616 / 0 ¹ |
| Match duration p50 / p95 | 64 / 93 s | 64 / 102 s | 63 / 93 s |
| Data to clients | 162 MB | 792 MB | 1.5 GB |

¹ The last result was still in flight at the final scrape. No result was
rejected, lost or retried (counters and `result lost/rejected` log lines),
and the casual matches in MySQL match the server's `match ended` logs.

**Stress point: where one pod saturates.** Same 200 matches, but with a
100 ms ± 50 ms think time for 120 s. 669 of 669 matches completed with no
errors. The server took in 928 messages/s and sent out 1,850/s. Its CPU
reached about 110 % (`docker stats`): the one Dart isolate was full,
plus the VM's GC and I/O threads. Messages started to queue. Move round
trip p50 / p95 / p99 rose to 141 / 255 / 290 ms, and ping rose with it, so
the delay was queueing on the event loop, not slow rules. RSS stayed at
50 MB. So one pod handles roughly **900 intents per second**; above that,
latency breaks the target.

## Compared with spec §11

- **Move round trip p95 < 150 ms in-region: met with a wide margin.** The
  p95 was 9–18 ms and the p99 at most 28 ms at 200 concurrent matches. The
  server spends at most 2.5 ms on each intent at p99. On a real network the
  client↔region RTT (typically 20–60 ms) is added to this.
- **Memory is flat.** RSS stays around 52 MB from 20 to 200 matches. A room
  costs only a few KB beyond the baseline, and matches did not leak memory
  (RSS after the run was at or below the peak).
- **CPU is the limit of a single pod.** The Dart server runs on one
  isolate, so it uses one core. It saturates at about 900 incoming intents
  per second (see the stress point). At 200 matches with a 500 ms think
  time it used about 0.6 of a core.
- **Capacity estimate.** Each match sent about 2.7 intents/s with 500 ms
  think time; an intent is a roll, a move or a confirm. Real players think
  for seconds, not half a second. At a 3–5 s average think time a match
  sends roughly 0.3–0.45 intents/s. One pod would then saturate at about
  2,000–3,000 concurrent matches, and run comfortably (≤ 50 % CPU) at
  about 1,000–1,500 matches, which is 2,000–3,000 players. This is scaled
  from the measured rates, not measured directly.
- **50k CCU (spec §11) needs the multi-pod design** of spec §7.5: Redis
  queues, a `matchId` → pod registry and routing by match. A single pod
  also cannot use more than one core without moving rooms to isolates.
  ADR-032 keeps one pod until that work is done, and the Helm chart
  enforces it.
- The k6 suggestion in spec §11 (`tools/load/`) is replaced by this Dart
  tool. It reuses the protocol models and the bot and measures intent →
  state, which a generic WS tool cannot see (ADR-043).

## Findings

- **No failures** at any size: no protocol errors, no stalls, no internal
  errors, no lost results. The API (PHP's single-process built-in server in
  compose) kept up with about 2 results per second at 200 matches.
- **`game.state` is heavy.** Each frame carries the whole game record and
  averages about 4.7 KB, growing as the game goes on. At 200 matches that
  is about 5 MB/s (1.5 GB per 5 minutes) to clients. On mobile data this is
  the first optimisation to make: send only the new actions, or only the
  last turn, with the full record on (re)connect. JSON encoding of these
  frames is also most of the server's CPU. This is a protocol change, so
  it is carried over in `docs/ROADMAP.md`.
- **Guest sign-up is limited to 20/min per IP.** That is fine for players,
  but behind carrier-grade NAT many players share one IP. Before this
  phase the API also trusted no proxy, so behind the Kubernetes ingress
  *all* players would have shared one limit. Fixed with `TRUSTED_PROXIES`
  (ADR-043). The limit itself is in the rate-limit review (Phase 7
  hardening).
- **Load-tool bug found and fixed while testing:** a re-queue timer could
  write to a socket that was already closed.
- **Not measured yet:**
  - the API hot paths under load (sign-in, `/me`, store, leaderboards); a
    PHP-FPM or Octane production image is needed before those numbers mean
    anything;
  - reconnect storms;
  - a long run (hours) for slow memory growth.
