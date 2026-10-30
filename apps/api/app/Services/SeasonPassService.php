<?php

namespace App\Services;

use App\Models\Item;
use App\Models\Rating;
use App\Models\Season;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;

/**
 * Season pass (7.1, ADR-039): season XP is the player XP earned while the
 * season runs (matches and missions, via ProgressionService::addXp); free
 * and premium tracks; premium is a one-off Yaqut purchase per season
 * (ADR-025). Free-track coins use the ledger reason `season`; premium-track
 * rewards use `season_premium`, which the ledger refuses for coins, so a
 * paid track can never grant coins (ADR-022).
 */
class SeasonPassService
{
    public function __construct(private SeasonService $seasons, private WalletService $wallet) {}

    /** Adds [xp] to the running season's pass (no-op between seasons). */
    public function addXp(User $user, int $xp, ?Carbon $now = null): void
    {
        $season = $this->seasons->active($now);
        if ($season === null || $xp <= 0) {
            return;
        }
        $this->row($season, $user);
        DB::table('season_passes')->where(['season_id' => $season->id, 'user_id' => $user->id])
            ->increment('xp', $xp, ['updated_at' => now()]);
    }

    /** @return array{xp: int, premium: bool, premium_key: string|null, claimed: array<int, string>} */
    private function state(Season $season, User $user, bool $lock = false): array
    {
        $query = DB::table('season_passes')->where(['season_id' => $season->id, 'user_id' => $user->id]);
        $row = ($lock ? $query->lockForUpdate() : $query)->first();
        /** @var array<int, string> $claimed */
        $claimed = $row === null ? [] : (array) json_decode((string) $row->claimed, true);

        return [
            'xp' => (int) ($row->xp ?? 0),
            'premium' => (bool) ($row->premium ?? false),
            'premium_key' => $row->premium_key ?? null,
            'claimed' => $claimed,
        ];
    }

    private function row(Season $season, User $user): void
    {
        DB::table('season_passes')->insertOrIgnore([
            'season_id' => $season->id, 'user_id' => $user->id, 'xp' => 0, 'premium' => false,
            'claimed' => '[]', 'created_at' => now(), 'updated_at' => now(),
        ]);
    }

    public static function level(Season $season, int $xp): int
    {
        $pass = $season->rules['pass'];

        return min($pass['levels'], intdiv($xp, $pass['xp_per_level']));
    }

    /** @return array<string, mixed>|null the reward of [level] on [track] */
    public static function reward(Season $season, int $level, string $track): ?array
    {
        if (! in_array($track, ['free', 'premium'], true)) {
            return null;
        }
        /** @var array<string, mixed>|null $reward */
        $reward = $season->rules['pass'][$track][$level] ?? null;

        return $reward;
    }

    /**
     * GET /season: the season, my pass with both tracks and claim states,
     * season-end rewards and my next tier target.
     *
     * @return array<string, mixed>
     */
    public function view(User $user, ?Carbon $now = null): array
    {
        $now ??= now();
        $season = $this->seasons->current($now);
        $state = $this->state($season, $user);
        $pass = $season->rules['pass'];
        $level = self::level($season, $state['xp']);
        $rewards = [];
        foreach (['free', 'premium'] as $track) {
            foreach ($pass[$track] as $l => $reward) {
                $claimed = in_array("$track:$l", $state['claimed'], true);
                $rewards[] = [
                    'level' => (int) $l,
                    'track' => $track,
                    'kind' => $reward['kind'],
                    'amount' => $reward['amount'] ?? null,
                    'itemId' => $reward['item'] ?? null,
                    'claimed' => $claimed,
                    'claimable' => ! $claimed && $level >= (int) $l && ($track === 'free' || $state['premium']),
                ];
            }
        }
        usort($rewards, fn ($a, $b) => [$a['level'], $a['track']] <=> [$b['level'], $b['track']]);
        $best = $user->bestRating();
        $target = null;
        foreach (Rating::TIERS as $min => $tier) {
            if ($min > $best) {
                $target = ['tier' => $tier, 'minRating' => $min, 'pointsLeft' => $min - $best];
                break;
            }
        }
        $endRewards = [];
        foreach ($season->rules['end_rewards'] as $tier => $r) {
            $endRewards[] = [
                'tier' => $tier,
                'minRating' => (int) array_search($tier, Rating::TIERS, true),
                'coins' => $r['coins'],
                'itemId' => $r['item'],
            ];
        }

        return [
            'season' => $season->toApi($now),
            'pass' => [
                'levels' => $pass['levels'],
                'xpPerLevel' => $pass['xp_per_level'],
                'xp' => $state['xp'],
                'level' => $level,
                'levelXp' => $level >= $pass['levels'] ? $pass['xp_per_level'] : $state['xp'] % $pass['xp_per_level'],
                'premium' => $state['premium'],
                'premiumPrice' => ['gems' => $pass['premium_gems']],
                'rewards' => $rewards,
            ],
            'endRewards' => $endRewards,
            'currentTier' => Rating::tier($best),
            'myTarget' => $target,
        ];
    }

    /**
     * Unlocks the premium track of the running season for Yaqut. A retry
     * with the same key is a no-op; a second purchase is refused.
     *
     * @throws InsufficientFunds
     * @throws InvalidArgumentException already_owned
     */
    public function buyPremium(User $user, string $key, ?Carbon $now = null): void
    {
        $season = $this->seasons->current($now);
        DB::transaction(function () use ($season, $user, $key): void {
            $this->row($season, $user);
            $state = $this->state($season, $user, lock: true);
            if ($state['premium']) {
                if ($state['premium_key'] === $key) {
                    return;
                }
                throw new InvalidArgumentException('already_owned');
            }
            // One ledger key per season and player: never charged twice.
            $this->wallet->debit($user, 'gems', $season->rules['pass']['premium_gems'], 'season_pass',
                "season-premium:{$season->id}:{$user->id}", "season:{$season->number}");
            DB::table('season_passes')->where(['season_id' => $season->id, 'user_id' => $user->id])
                ->update(['premium' => true, 'premium_at' => now(), 'premium_key' => $key, 'updated_at' => now()]);
        });
    }

    /**
     * Claims one reached reward of the running season.
     *
     * @throws InvalidArgumentException no_reward|not_reached|premium_required|already_claimed
     */
    public function claim(User $user, int $level, string $track, ?Carbon $now = null): void
    {
        $season = $this->seasons->current($now);
        $reward = self::reward($season, $level, $track);
        if ($reward === null) {
            throw new InvalidArgumentException('no_reward');
        }
        DB::transaction(function () use ($season, $user, $level, $track, $reward): void {
            $this->row($season, $user);
            $state = $this->state($season, $user, lock: true);
            if (self::level($season, $state['xp']) < $level) {
                throw new InvalidArgumentException('not_reached');
            }
            if ($track === 'premium' && ! $state['premium']) {
                throw new InvalidArgumentException('premium_required');
            }
            if (in_array("$track:$level", $state['claimed'], true)) {
                throw new InvalidArgumentException('already_claimed');
            }
            $this->grant($season, $user, $level, $track, $reward);
            DB::table('season_passes')->where(['season_id' => $season->id, 'user_id' => $user->id])
                ->update(['claimed' => json_encode([...$state['claimed'], "$track:$level"]), 'updated_at' => now()]);
        });
    }

    /** "Hamısını al": claims every claimable reward; returns how many. */
    public function claimAll(User $user, ?Carbon $now = null): int
    {
        $count = 0;
        foreach ($this->view($user, $now)['pass']['rewards'] as $r) {
            if ($r['claimable']) {
                $this->claim($user, $r['level'], $r['track'], $now);
                $count++;
            }
        }

        return $count;
    }

    /** @param array<string, mixed> $reward */
    private function grant(Season $season, User $user, int $level, string $track, array $reward): void
    {
        $key = "season-pass:{$season->id}:{$user->id}:$track:$level";
        // Premium rewards use a reason the ledger refuses for coins (ADR-022).
        $reason = $track === 'premium' ? 'season_premium' : 'season';
        $ref = "season:{$season->number}";
        match ($reward['kind']) {
            'coins' => $this->wallet->credit($user, 'coins', (int) $reward['amount'], $reason, $key, $ref),
            'gems' => $this->wallet->credit($user, 'gems', (int) $reward['amount'], $reason, $key, $ref),
            'item' => Item::query()->whereKey((string) $reward['item'])->exists()
                ? DB::table('user_items')->insertOrIgnore([
                    'user_id' => $user->id, 'item_id' => (string) $reward['item'], 'source' => 'season',
                    'created_at' => now(), 'updated_at' => now(),
                ]) : 0,
            default => throw new InvalidArgumentException('no_reward'),
        };
    }

    /** @return array{season: int, level: int, xp: int, premium: bool}|null for /me/progress (Home card) */
    public function brief(User $user, ?Carbon $now = null): ?array
    {
        $season = $this->seasons->active($now);
        if ($season === null) {
            return null;
        }
        $state = $this->state($season, $user);

        return [
            'season' => $season->number,
            'level' => self::level($season, $state['xp']),
            'xp' => $state['xp'],
            'premium' => $state['premium'],
        ];
    }
}
