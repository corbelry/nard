# Tournaments API (Phase 6)

All under `/api/v1`, bearer token. Errors: `{code}` — 422 refused, 403
`forbidden`, 404 `not_found`, 429 `rate_limited`; bad input 422
`{message, errors}`. Numbers: `apps/api/config/tournaments.php`. Rules:
ADR-038 (tournament matches are unrated, private ones free, 3 min no-show (#35),
house-funded scheduled prizes, sit-and-go 10 % rake and 10 min fill time).

Shapes
- Prize `{from, to, coins, items:[itemId]}` — every place `from..to` gets `coins` and the items (titles are `title.*` items).
- Tournament (summary) `{id, name (locale map; private: {default}), type: knockout|swiss|round_robin, kind: scheduled|sit_and_go|private,
  status: registering|running|finished|cancelled, variant, matchLength, clock{reserveMs, delayMs}, size, minPlayers, entrants,
  entry{kind: free|coins|invite, coins}, minRating|null, rated:false, private, startsAt|null, expiresAt|null, startedAt|null, finishedAt|null,
  cancelReason: not_enough_players|not_filled|expired|organizer|admin|null, currentRound, totalRounds|null, prizes:[Prize], prizeFund, fairDice:true,
  myStatus: none|registered|playing|eliminated|champion|finished, myPlace|null}`
- UserLite `{id, name, country, avatar}`
- Match (bracket cell) `{slot, matchId, white:UserLite|null, black:UserLite|null, status: pending|ready|finished|walkover|bye, result: white|black|none|null, winnerId|null, score:[white, black]|null}`
  (`ready` = on the game server; `result: none` = nobody advanced: both absent, or an empty slot)
- Detail = summary + `{organizerId|null, inviteCode|null (organiser/entrants of a private one), entrantsList:[{user, seed, rating, place}],
  rounds:[{number, stage, status: running|finished, matches:[Match]}], standings:[{rank, user, wins, losses, points, buchholz}]|null (knockout: null),
  myNextMatch:{matchId, round, status, opponent:UserLite|null, noShowSeconds}|null}`; knockout `stage` = `final`, `1/2`, `1/4` … (matches in the round), else the round number.

List and detail
- `GET /tournaments?tab=live|upcoming|mine|finished&variant=shortNard|longNard&free=1` → `{tournaments:[Tournament]}` (50).
  live = running; upcoming = scheduled, registering, by start; mine = my registering/running (and private ones I organise), running first;
  finished = last 14 days. Private tournaments appear only for their organiser and entrants.
- `GET /tournaments/{id}` → `{tournament: Detail}` (4.2 detail, 4.3 bracket, 4.4 standings; a private one is 404 for others).

Registration
- `POST /tournaments/{id}/register {idempotencyKey? (8–64, required when entry.coins > 0), code?}` → 201 `{tournament, wallet}`;
  the entry fee is a ledger debit (`tournament_entry`); a retried key returns the same registration.
  Errors `closed, already_registered, invite_required, rating_too_low (variant rating < minRating), full, idempotency_key_required,
  idempotency_key_reused (that key paid an entry that was refunded), insufficient_coins`.
- `DELETE /tournaments/{id}/register` → `{tournament, wallet}`; before the start only, full refund (`refund` credit); errors `closed, not_registered`.
- Cancelled tournaments refund every paid entry once.

Sit-and-go (21.x) — knockout, Short Nard to 3, 500 coins, starts when full
- `GET /tournaments/sng` → `{tables:[{size: 8|16|32, variant, matchLength, clock, entry{kind:coins, coins}, prizeFund (size × 500 − 10 %), prizes|null, tournamentId|null, joined, expiresAt|null, registered}]}`
- `POST /tournaments/sng/{size}/join {idempotencyKey}` → 201 `{tournament, wallet}`; joins the open table (opens one, expiring in 10 min);
  already seated → that table, no charge; the last seat starts it at once (`status: running`). Leave with `DELETE /tournaments/{id}/register`.
  Unfilled after 10 min → `cancelled` / `not_filled`, full refund (21.4).
  Splits (% of the fund per place): 8 → 50/30/10+10; 16 → 40/24/10+10/4×4; 32 → 34/20/9+9/4×4/1.5×8 (rounding to 1st).

Private tournaments (22.x) — knockout, free, unrated, invite code
- `POST /tournaments/private {name (3–40), size: 4|8|16|32, variant, matchLength: 1|3|5|7, startsAt? (≤ 30 days)}` → 201 `{tournament: Detail}`
  (organiser registered; `inviteCode` 6 chars `[A-Z2-9]`, shown 3-3). No start time → cancelled (`expired`) after 24 h if not started.
  Max 3 open per organiser (`too_many_open`). Fee fields are ignored.
- `POST /tournaments/join-by-code {code}` (case, spaces and `-` ignored) → `{tournament: Detail}`; errors `not_found, closed, full`.
- `POST /tournaments/{id}/start` (organiser, ≥ 2 entrants) → `{tournament}`; errors `forbidden, closed, not_enough_players`.
- `DELETE /tournaments/{id}` (organiser, before start) → `{status: cancelled}`.
- `DELETE /tournaments/{id}/entrants/{userId}` (organiser, before start) → `{status: removed}`; errors `self, not_registered`.
- Not built: editing (PATCH), minimum rating, coin fees.

Formats
- Knockout: seeded by rating at the start (1 v N, seeds 1 and 2 meet only in the final), padded to a power of two; byes to the top seeds.
  Places: champion 1, finalist 2, semi-finalists 3, quarter-finalists 5 … (no third-place match).
- Swiss: rounds = `swissRounds` (default ⌈log₂ n⌉, at most n − 1); pairs top-down by points then rating, avoiding rematches; odd field → bye
  (1 point) to the lowest player without one. 1 point per win; standings points → Buchholz (sum of opponents' points, integer) → rating.
- Round-robin: circle method, everyone meets everyone once (odd field: one bye per round, no point); standings as Swiss.
- A walkover counts as a win; when both are absent nobody scores (knockout: both are out).

Scheduler (`routes/console.php`)
- `tournaments:tick` every minute: starts due tournaments (`startsAt` ≤ now; fewer than `minPlayers` → `not_enough_players`, refunded),
  cancels expired registrations, pushes pending pairings to the game server (and re-pushes ones without a result after 10 min).
- `tournaments:schedule` hourly (and in `db:seed`): creates the next daily cup (16:00 UTC, KO 32, free) for today/tomorrow,
  the Friday cup (KO 64, 500 coins, 25 000 / 12 000 / 6 500 + 6 500 + title + Xatam board) and the Sunday Long Nard league (Swiss 7 rounds).

Game server (internal, signed both ways: `X-Nard-Signature = hex(HMAC-SHA256(GAME_TICKET_SECRET, body))`)
- API → game server `POST {GAME_SERVER_URL}/internal/tournament-matches` TournamentMatch
  `{matchId "t{tournament}-{round}-{slot}", tournamentId, round, variant, matchLength, white: Player, black: Player, noShowSeconds: 180}`
  (`packages/nard_protocol/schema/tournament_match.schema.json`; Player has no rating) → 201 `assigned` | 200 `known` | 401 | 400.
- The game server starts the match once both players are connected (or sent `tournament.ready`), mode `tournament`, casual clock.
  One player present at the deadline → MatchResult `reason: walkover` (winner = present player, full length, no games);
  nobody → `POST /api/v1/internal/tournament-no-shows {matchId, tournamentId, endedAt}` (schema `tournament_no_show.schema.json`) → 201.
- Results: `POST /api/v1/internal/match-results` with `mode: tournament` and `tournamentId` (required then); stored once by `matchId`,
  never rated; walkovers give no match rewards or clan XP; the pairing is recorded and the next round is pushed / prizes paid
  (`tournament` coin credit keyed per tournament and user, items into `user_items` with `source: tournament`).

WebSocket (docs/PROTOCOL.md)
- S→C `tournament.readyState {matchId, tournamentId, round, you, white, black, ready{white, black}, deadline, noShowSeconds}` when assigned, on connect, on changes.
- C→S `tournament.ready {matchId}` (Hazıram); `error not_in_match` if it is not your assigned match.
- S→C `match.found` gains `tournamentId, round` (mode `tournament`); S→C `tournament.walkover {matchId, tournamentId, winner?}` (21.3).
- While a tournament match waits, `queue.join` / `room.*` are refused (`illegal_action`).

Elsewhere: `/me/matches` items gain `tournamentId|null`; game_matches `mode` may be `tournament`, `reason` may be `walkover`.
Live (ADR-049): entrants' sockets get S→C `tournament.updated {tournamentId}` after entries, leaving, the start, a cancellation
and every result (new rounds and the end included), and the inbox rows (started / round / eliminated with place / won /
finished / cancelled with refund) as `notification`; screens still poll `GET /tournaments/{id}` as the fallback and for
non-entrants. Cancellation (too few players, unfilled sit-and-go, expired, organiser) refunds every fee and sends
`tournament_cancelled {reason, refund}` (not to an organiser who cancelled their own tournament).
Not yet: Swiss top-8 playoff, longer finals, per-tournament clocks, trophies showcase, clan championships.
