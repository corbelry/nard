<?php

namespace App\Services;

use App\Models\Item;
use App\Models\Rating;
use App\Models\Season;
use App\Models\User;
use Illuminate\Database\Query\Builder;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

/**
 * Season lifecycle (spec §8.2, ADR-039): the running season, the end of a
 * season (final ranks, season-end rewards by tier, soft rating reset) and
 * the next one; season summaries (7.2) and leaderboards (6.5).
 */
class SeasonService
{
    public function __construct(private WalletService $wallet, private Notifier $notifier) {}

    /** The running season; season 1 is created when there is none. */
    public function current(?Carbon $now = null): Season
    {
        $now ??= now();
        $active = Season::query()->where('status', 'active')->orderByDesc('number')->first();
        if ($active !== null) {
            return $active;
        }
        $last = Season::query()->orderByDesc('number')->first();

        return $last === null
            ? $this->create(1, $now->copy()->utc()->startOfDay(), $now)
            : $this->create($last->number + 1, $last->ends_at, $now);
    }

    /** The season that counts activity at [now] (null between end and roll). */
    public function active(?Carbon $now = null): ?Season
    {
        $now ??= now();

        return Season::query()->where('status', 'active')
            ->where('starts_at', '<=', $now)->where('ends_at', '>', $now)
            ->orderByDesc('number')->first();
    }

    private function create(int $number, Carbon $startsAt, Carbon $now): Season
    {
        $days = (int) config('seasons.length_days');
        $endsAt = $startsAt->copy()->addDays($days);
        if ($endsAt->lte($now)) {
            // The roll ran late: the new season still gets its full length.
            $endsAt = $now->copy()->utc()->startOfDay()->addDays($days);
        }
        /** @var array<int, array<string, string>> $names */
        $names = config('seasons.names');

        return Season::query()->createOrFirst(['number' => $number], [
            'name' => $names[($number - 1) % count($names)],
            'starts_at' => $startsAt,
            'ends_at' => $endsAt,
            'status' => 'active',
            // Fixed for the whole season (prizes are shown up front, §8.7).
            'rules' => ['pass' => config('seasons.pass'), 'end_rewards' => config('seasons.end_rewards')],
        ]);
    }

    /**
     * Ends every season that is due and starts the next one (daily
     * `seasons:roll`). Returns how many seasons were ended.
     */
    public function roll(?Carbon $now = null): int
    {
        $now ??= now();
        $ended = 0;
        while (($due = Season::query()->where('status', 'active')->where('ends_at', '<=', $now)->orderBy('number')->first()) !== null) {
            $this->finish($due, $now);
            $ended++;
        }
        $this->current($now);

        return $ended;
    }

    /**
     * Admin: ends the running [season] now (final ranks, rewards, soft
     * reset) and starts the next one. False when it is not active.
     */
    public function endEarly(Season $season, ?Carbon $now = null): bool
    {
        $now ??= now();
        if ($season->status !== 'active') {
            return false;
        }
        if ($season->ends_at->gt($now)) {
            $season->forceFill(['ends_at' => $now])->save();
        }

        return $this->roll($now) > 0;
    }

    private function finish(Season $season, Carbon $now): void
    {
        DB::transaction(function () use ($season, $now): void {
            $locked = Season::query()->lockForUpdate()->find($season->id);
            if ($locked === null || $locked->status !== 'active') {
                return;
            }
            $this->snapshot($locked);
            $this->grantEndRewards($locked);
            $this->softReset();
            $locked->forceFill(['status' => 'finished', 'finished_at' => $now])->save();
            $this->create($locked->number + 1, $locked->ends_at, $now);
        });
    }

    /** Final ranks per variant (global and within the player's country). */
    private function snapshot(Season $season): void
    {
        foreach ((array) config('nard.variants') as $variant) {
            $rows = DB::table('ratings')->join('users', 'users.id', '=', 'ratings.user_id')
                ->where('ratings.variant', $variant)
                ->where('ratings.season_matches', '>=', (int) config('seasons.min_matches'))
                ->orderByDesc('ratings.rating')->orderBy('ratings.user_id')
                ->select(['ratings.user_id', 'ratings.rating', 'ratings.season_start_rating', 'ratings.season_matches', 'ratings.season_wins', 'users.country'])
                ->get();
            $rank = 0;
            $countryRanks = [];
            $batch = [];
            foreach ($rows as $r) {
                $rank++;
                $country = $r->country === null ? null : (string) $r->country;
                if ($country !== null) {
                    $countryRanks[$country] = ($countryRanks[$country] ?? 0) + 1;
                }
                $batch[] = [
                    'season_id' => $season->id,
                    'user_id' => (int) $r->user_id,
                    'variant' => $variant,
                    'rank' => $rank,
                    'country_rank' => $country === null ? null : $countryRanks[$country],
                    'tier' => Rating::tier((int) $r->rating),
                    'rating' => (int) $r->rating,
                    'start_rating' => (int) $r->season_start_rating,
                    'matches' => (int) $r->season_matches,
                    'wins' => (int) $r->season_wins,
                    'created_at' => now(),
                    'updated_at' => now(),
                ];
                if (count($batch) === 500) {
                    DB::table('season_results')->insertOrIgnore($batch);
                    $batch = [];
                }
            }
            if ($batch !== []) {
                DB::table('season_results')->insertOrIgnore($batch);
            }
        }
    }

    /** One reward per ranked player, by the best final tier over the variants. */
    private function grantEndRewards(Season $season): void
    {
        $best = DB::table('season_results')->where('season_id', $season->id)
            ->groupBy('user_id')->selectRaw('user_id, MAX(rating) as best')->orderBy('user_id')->get();
        foreach ($best as $row) {
            $tier = Rating::tier((int) $row->best);
            $reward = $season->rules['end_rewards'][$tier] ?? null;
            $user = User::query()->find((int) $row->user_id);
            if ($reward === null || $user === null) {
                continue;
            }
            $item = $reward['item'] !== null && Item::query()->whereKey($reward['item'])->exists() ? $reward['item'] : null;
            $new = DB::table('season_rewards')->insertOrIgnore([
                'season_id' => $season->id, 'user_id' => $user->id, 'tier' => $tier,
                'coins' => $reward['coins'], 'item_id' => $item, 'created_at' => now(),
            ]);
            if ($new === 0) {
                continue;
            }
            $this->notifier->notify($user, 'season_end', [
                'season' => $season->number, 'tier' => $tier, 'coins' => $reward['coins'], 'itemId' => $item,
            ], "season_end:{$season->id}");
            if ($reward['coins'] > 0) {
                $this->wallet->credit($user, 'coins', $reward['coins'], 'season', "season-end:{$season->id}:{$user->id}", "season:{$season->number}");
            }
            if ($item !== null) {
                DB::table('user_items')->insertOrIgnore([
                    'user_id' => $user->id, 'item_id' => $item, 'source' => 'season',
                    'created_at' => now(), 'updated_at' => now(),
                ]);
            }
        }
    }

    /** rating = pivot + (rating − pivot) × factor; peaks are kept. */
    private function softReset(): void
    {
        $pivot = (int) config('seasons.soft_reset.pivot');
        $factor = (float) config('seasons.soft_reset.factor');
        DB::update('UPDATE ratings SET rating = ROUND(? + (rating - ?) * ?), updated_at = ?', [$pivot, $pivot, $factor, now()]);
        // Separate statement: MySQL would otherwise read the new rating.
        DB::table('ratings')->update([
            'season_start_rating' => DB::raw('rating'),
            'season_matches' => 0,
            'season_wins' => 0,
        ]);
    }

    /**
     * 7.2: my final ranks and reward for a finished season (the latest when
     * [number] is null); null when there is no such season.
     *
     * @return array<string, mixed>|null
     */
    public function summary(User $user, ?int $number): ?array
    {
        $query = Season::query()->where('status', 'finished');
        $season = $number === null ? $query->orderByDesc('number')->first() : $query->where('number', $number)->first();
        if ($season === null) {
            return null;
        }
        $results = DB::table('season_results')->where(['season_id' => $season->id, 'user_id' => $user->id])
            ->orderBy('variant')->get()
            ->map(fn ($r) => [
                'variant' => $r->variant,
                'rank' => (int) $r->rank,
                'countryRank' => $r->country_rank === null ? null : (int) $r->country_rank,
                'tier' => $r->tier,
                'rating' => (int) $r->rating,
                'ratingDelta' => (int) $r->rating - (int) $r->start_rating,
                'matches' => (int) $r->matches,
                'wins' => (int) $r->wins,
                'winRate' => (int) $r->matches === 0 ? 0 : (int) round((int) $r->wins * 100 / (int) $r->matches),
            ])->all();
        $reward = DB::table('season_rewards')->where(['season_id' => $season->id, 'user_id' => $user->id])->first();

        return [
            'season' => $season->toApi(),
            'results' => $results,
            // Granted when the season ended (no claim step).
            'reward' => $reward === null ? null : [
                'tier' => $reward->tier,
                'coins' => (int) $reward->coins,
                'itemId' => $reward->item_id,
            ],
            // Ratings now (after the soft reset when this is the latest season).
            'ratings' => $user->ratings()->get()->mapWithKeys(fn (Rating $r) => [$r->variant => $r->rating])->all(),
        ];
    }

    /**
     * 6.5: top N by rating within a scope, plus my row. The current season
     * ranks live ratings; a finished season ranks its frozen results.
     *
     * @return array<string, mixed>
     */
    public function leaderboard(User $me, string $variant, string $scope, ?Season $past): array
    {
        $min = (int) config('seasons.min_matches');
        $q = $past === null
            ? DB::table('ratings')->where('ratings.matches', '>=', $min)
            : DB::table('season_results as ratings')->where('ratings.season_id', $past->id);
        $q->join('users', 'users.id', '=', 'ratings.user_id')->where('ratings.variant', $variant);
        $this->scope($q, $me, $scope);

        $rows = (clone $q)->orderByDesc('ratings.rating')->orderBy('ratings.user_id')
            ->limit((int) config('seasons.leaderboard_size'))
            ->get(['ratings.user_id', 'ratings.rating', 'users.name', 'users.country', 'users.avatar']);
        $entries = [];
        foreach ($rows as $i => $r) {
            $entries[] = [
                'rank' => $i + 1,
                'user' => ['id' => (string) $r->user_id, 'name' => $r->name, 'country' => $r->country, 'avatar' => $r->avatar],
                'rating' => (int) $r->rating,
                'tier' => Rating::tier((int) $r->rating),
            ];
        }

        $mine = (clone $q)->where('ratings.user_id', $me->id)->value('ratings.rating');
        $rank = null;
        if ($mine !== null) {
            $rating = (int) $mine;
            $rank = (clone $q)->where(fn (Builder $w) => $w->where('ratings.rating', '>', $rating)
                ->orWhere(fn (Builder $t) => $t->where('ratings.rating', $rating)->where('ratings.user_id', '<', $me->id)))
                ->count() + 1;
        }
        // Not listed (fewer than the minimum matches, or not in the scope):
        // my live rating without a rank.
        $myRating = $mine !== null ? (int) $mine
            : ($past === null ? DB::table('ratings')->where(['user_id' => $me->id, 'variant' => $variant])->value('rating') : null);
        $matches = $past === null ? (int) DB::table('ratings')->where(['user_id' => $me->id, 'variant' => $variant])->value('matches') : null;

        return [
            'variant' => $variant,
            'scope' => $scope,
            'season' => ($past ?? $this->current())->number,
            'minMatches' => $min,
            'entries' => $entries,
            'me' => [
                'rank' => $rank,
                'rating' => $myRating === null ? null : (int) $myRating,
                'tier' => $myRating === null ? null : Rating::tier((int) $myRating),
                'matches' => $matches,
                'user' => ['id' => (string) $me->id, 'name' => $me->name, 'country' => $me->country, 'avatar' => $me->avatar],
            ],
        ];
    }

    private function scope(Builder $q, User $me, string $scope): void
    {
        match ($scope) {
            'country' => $me->country === null ? $q->whereRaw('1 = 0') : $q->where('users.country', $me->country),
            'friends' => $q->whereIn('ratings.user_id', [$me->id, ...$this->friendIds($me)]),
            'clan' => $q->whereIn('ratings.user_id', $this->clanMateIds($me)),
            default => $q,
        };
    }

    /** @return array<int, int> */
    private function friendIds(User $me): array
    {
        return DB::table('friendships')->where('status', 'accepted')
            ->where(fn (Builder $w) => $w->where('requester_id', $me->id)->orWhere('addressee_id', $me->id))
            ->get(['requester_id', 'addressee_id'])
            ->map(fn ($r) => (int) $r->requester_id === $me->id ? (int) $r->addressee_id : (int) $r->requester_id)
            ->all();
    }

    /** @return array<int, int> me and my clan's members (empty without a clan) */
    private function clanMateIds(User $me): array
    {
        $clanId = DB::table('clan_members')->where('user_id', $me->id)->value('clan_id');

        return $clanId === null ? [] : DB::table('clan_members')->where('clan_id', $clanId)->pluck('user_id')->map(fn ($id) => (int) $id)->all();
    }
}
