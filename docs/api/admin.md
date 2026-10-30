# Admin panel and fair play (Phase 7)

Decisions: ADR-042. Spec: §8.13 (admin), §8.14 (anti-cheat). Config:
`apps/api/config/fairplay.php`.

## Admin panel (Filament 5)

- URL: `/admin` on the API host (local: <http://localhost:18000/admin>).
- Login: Filament's own e-mail + password session (`web` guard). Only users
  with `users.is_admin = true` that are not banned get in
  (`User::canAccessPanel`); mobile bearer tokens never open the panel.
- Create an admin (promotes an existing account with that e-mail, or
  creates one; prints a generated password when `--password` is omitted):

  ```sh
  # local stack
  docker compose -f infra/docker-compose.yml exec api \
    php artisan admin:create you@example.com --password='at-least-12-chars'
  ```

- Every write is audited in `admin_actions` (System → Audit log).

| Section | Resource | What admins can do |
|---|---|---|
| Players | Users | search (id, name, e-mail, friend code), profile, ratings, wallet balance, ledger / reports / flags tabs (read-only); ban (until or permanent, reason), unban, mute chat + emotes (1 h – 7 d), clear matchmaking cooldown, warn (inbox message), reset nickname, admin grant |
| Players | Reports | queue filtered to `open`; dismiss → `reviewed`; warn / mute / ban → `actioned` |
| Players | Matches | list and view finished matches with game records, server seeds, commitments, client seeds |
| Fair play | Flags | `anticheat:scan` output; review as reviewed / dismissed / actioned with a note |
| Competition | Tournaments | list all; create public scheduled tournaments (started by `tournaments:tick`); cancel while registering → `cancelReason: admin`, every entry fee refunded (TournamentService) |
| Competition | Seasons | view; "End now" runs the normal season end early (ranks, rewards, soft reset, next season) |
| Competition | Clans | view; rename (no charge; name rules apply); disband |
| Competition | Puzzles | list, edit rating / phase, enable / disable (disabled puzzles are not served) |
| Economy | Items | create / edit price, availability, sort, asset and the data JSON |
| Economy | Featured offer | the 7.3 featured item and its struck-through old price (`app_settings.featured`, default `economy.featured`) |
| Economy | Ledger | read-only `wallet_transactions`; "Admin grant" credits coins or Yaqut with ledger reason `admin` and a mandatory note — never tied to money (ADR-022) |
| System | Audit log | read-only `admin_actions` |

## Enforcement (API and game server)

- Banned: every authenticated API call → `403 {code: "banned", until: ISO-8601|null}`
  (`null` = permanent); sign-in (guest / e-mail) answers the same and
  issues no token; `TicketSigner` refuses (no game-server ticket).
- Muted: `POST /clans/{id}/messages` → `403 {code: "muted", until}`; the
  ticket carries `muted: true` and the game server drops the player's emotes.
- Matchmaking cooldown (abandonment): `POST /game/ticket` returns
  `queueCooldownUntil` (ISO-8601|null) and the ticket carries it (epoch
  seconds); the game server answers `queue.join` with error
  `queue_cooldown` until then. Private rooms and tournaments stay open.
- Live sessions (ADR-045): ban, unban, mute, unmute, clear cooldown and the
  scan's abandonment cooldown push the player's whole state
  (`{userId, banned, muted, queueCooldownUntil}`) to the game server's
  signed `POST /internal/moderation` (`GameServerClient::pushModeration`,
  after the transaction commits). A ban closes the open socket (the match
  continues as a disconnect), a mute drops emotes at once, a cooldown
  refuses `queue.join` and leaves the queue. Best effort: if the game server
  is unreachable the action still succeeds (logged warning) and the next
  ticket carries the state. Needs `GAME_SERVER_URL`.

## Fair-play scan

`php artisan anticheat:scan` runs daily at 04:00 UTC (scheduler) and writes
`cheat_flags` (one per player and kind within a rule's window: an open flag
is refreshed, a reviewed one is not raised again).

| Kind | Rule (defaults in `config/fairplay.php`) | Automatic action |
|---|---|---|
| `reports` | ≥ 5 distinct reporters in 7 days | none |
| `abandonment` | ≥ 10 matches in 14 days and ≥ 30 % lost by `abandoned` / `timeout` (walkovers ignored) | 24 h matchmaking cooldown |
| `multi_account` | accounts that signed in from the same IP or device (hashed sightings, 30 days; kept 90 days) and met ≥ 2 times in ranked | none |
| `engine` | ≥ 10 ranked matches and ≥ 150 decisions; agreement with `HeuristicBot(hard)` ≥ the rating band's expected agreement + 0.15 | none |

The engine check needs the Dart move-quality tool
(`packages/nard_ai/tool/move_quality.dart`), because the rules engine and
bots are Dart. Two ways to run it:

```sh
# 1. By hand / from a separate job with Dart installed
php artisan anticheat:export matches.jsonl            # ranked human matches, last 30 days
(cd packages/nard_ai && dart run tool/move_quality.dart < matches.jsonl > quality.jsonl)
php artisan anticheat:scan --engine=quality.jsonl

# 2. Automatically: give the API host the tool and set MOVE_QUALITY_CMD,
#    e.g. a compiled binary (dart compile exe tool/move_quality.dart -o move_quality)
MOVE_QUALITY_CMD=/usr/local/bin/move_quality
```

Without either, the scan logs "engine: skipped" and runs the other rules.
`--skip-engine` runs only the other rules.

Formats (JSON lines):

- export → tool: `{matchId, variant, white: {userId}, black: {userId}, games: [{record, serverSeed, …}]}`
- tool → scan: `{userId, matches, games, decisions, agreement, avgLoss}`;
  a decision is a turn with more than one distinct resulting position;
  agreement = share of decisions where the played position equals the
  bot's choice; avgLoss = mean `score(bot) − score(played)` of the heuristic
  evaluator (≥ 0).
