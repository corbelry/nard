# Seasons, season pass, leaderboards and puzzles API (Phase 6)

All under `/api/v1`, bearer token. Errors: `{code}` — 422 refused, 404
`not_found`, 429 `rate_limited`; bad input 422 `{message, errors}`. Numbers:
`apps/api/config/seasons.php`, `config/puzzles.php`. Decisions: ADR-039.

Shapes
- Season `{id, number, name{az,en}, status:active|finished, startsAt, endsAt, secondsLeft}`
- PassReward `{level, track:free|premium, kind:coins|gems|item, amount|null, itemId|null, claimed, claimable}`
  (levels without a reward on a track are absent)
- Board `{white:{point:count}, black:{point:count}}` — each side in **its own numbering** (1..24, 25 = bar,
  borne-off checkers omitted), i.e. nard_core `BoardState.fromPoints`
- Puzzle `{id, variant, phase:opening|middle|bearoff, difficulty:easy|medium|hard, rating, side:white|black, dice[d1,d2], board:Board, attemptsUsed, finished, correct}`
- AttemptResult `{puzzleId, attempt, correct, finished, attemptsLeft, ratingDelta, rating, solution:{moves, board:Board, secondBest{moves, loss}|null}|null}`
  (`solution` only once the puzzle is finished)

Seasons (~6 weeks, end at 00:00 UTC; daily `seasons:roll` at 00:05 UTC)
- `GET /season` → `{season:Season, pass:{levels 50, xpPerLevel 1000, xp, level, levelXp, premium, premiumPrice{gems 950}, rewards:[PassReward]}, endRewards:[{tier, minRating, coins, itemId|null}], currentTier, myTarget:{tier, minRating, pointsLeft}|null}`
  (`currentTier`/`myTarget` use the best current rating over both variants)
- `GET /seasons` → `{seasons:[Season]}` newest first (leaderboard season picker)
- `POST /season/pass/premium {idempotencyKey}` → GET /season body + `wallet`; 950 Yaqut once per season (retry with the
  same key = 200, no charge); errors `insufficient_funds, already_owned`. Premium rewards of levels already reached become claimable.
- `POST /season/pass/claim {level, track}` → GET /season body + `wallet`; errors `no_reward, not_reached, premium_required, already_claimed`
- `POST /season/pass/claim-all` → `{claimed:n}` + GET /season body + `wallet` ("Hamısını al")
- `GET /season/summary/{number?}` (7.2; default = latest finished season) → `{season:Season, results:[{variant, rank, countryRank|null, tier, rating, ratingDelta, matches, wins, winRate}], reward:{tier, coins, itemId|null}|null, ratings:{variant: rating}}`;
  404 when there is no finished season with that number. The reward is **granted when the season ends** (no claim call);
  "Mükafatları al" only acknowledges. `ratings` are the live ratings (after the soft reset).
- `GET /me/progress` → `progress.season = {season, level, xp, premium}|null` (Home card)

Season XP = every player XP grant while the season runs (match rewards and mission claims, one hook in
`ProgressionService::addXp`; match results are idempotent so nothing counts twice). Pass level = ⌊xp / 1000⌋, max 50.

Season end: final ranks per variant for players with ≥ `min_matches` (5) ranked matches in the season (global + country
rank) → one reward per player by the best final tier over both variants (coins, plus a frame from Almaz up) → soft reset
`rating = 1500 + (rating − 1500) × 0.5` (peak kept) → next season. Notifications (docs/api/notifications.md, live over the
socket, ADR-049): `season_end {season, tier, coins, itemId, rank, variant}` to each rewarded player (rank of the variant
that gave the tier) and `season_started {season, name, endsAt}` to everyone who played a match in the ended season.

Leaderboards (6.5)
- `GET /leaderboard?variant=shortNard|longNard&scope=global|country|friends|clan&season=` →
  `{variant, scope, season, minMatches, entries:[{rank, user{id,name,country,avatar}, rating, tier}], me:{rank|null, rating|null, tier|null, matches|null, user}}`
  - top 100 by rating (ties: lower user id first); ranks are within the scope
  - current season: live ratings of players with ≥ `min_matches` rated matches; `season=N` of a finished season: its frozen results
  - `country` = my profile country (none → empty); `friends` = me + accepted friends; `clan` = my clan's members (no clan → empty)
  - `me.rank` is null when I am not listed (too few matches / not in scope); 404 for an unknown season

Puzzles (13.x; two attempts; puzzle rating starts at 1500, separate from game rating)
- `GET /puzzles/next?variant=` → `{puzzle:Puzzle|null, rating, solved, total}`: my unfinished puzzle first, else the unseen
  puzzle closest to my puzzle rating; `null` when none is left
- `GET /puzzles/daily` → same + `date` (UTC; one puzzle for everyone per day)
- `POST /puzzles/{id}/attempt {attempt:1|2, board:Board, moves?}` → AttemptResult. `board` is the position **after** the
  player's moves; any move order reaching the solution's position is correct (`moves` is stored for review only).
  Rating: correct +12 / +6 (1st / 2nd attempt), wrong −8 / −4. Replaying a recorded attempt returns its stored result
  (offline sync is safe). Errors `bad_board, bad_attempt` (not the next attempt), `finished`.
- `POST /puzzles/{id}/reveal` → AttemptResult ("Həllə bax"): an unfinished puzzle counts as the next attempt, failed.
- A solved puzzle advances the daily mission `daily_puzzle_2` (event `puzzle_solved`, ×2 → 30 coins, 15 XP).

Puzzles are generated by `packages/nard_ai/tool/gen_puzzles.dart` (heuristic self-play; the 2-ply best turn beats the
second best by ≥ 0.06 equity) into `apps/api/database/seeders/data/puzzles.json`, loaded by `PuzzleSeeder`.
