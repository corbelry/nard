<?php

namespace App\Services;

use App\Models\GameMatch;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

/**
 * Coins, XP, levels, missions, login streak and achievements (spec §8.8,
 * ADR-017). Online matches only; numbers come from config/progression.php.
 */
class ProgressionService
{
    public function __construct(private WalletService $wallet, private SeasonPassService $pass, private Notifier $notifier) {}

    public static function xpForLevel(int $level): int
    {
        return (int) config('progression.level_xp.base') + (int) config('progression.level_xp.step') * ($level - 1);
    }

    /** Rewards both human players of a newly stored match. */
    public function onMatch(GameMatch $match): void
    {
        foreach (['white', 'black'] as $side) {
            $userId = $side === 'white' ? $match->white_user_id : $match->black_user_id;
            $user = $userId === null ? null : User::query()->find($userId);
            if ($user === null) {
                continue;
            }
            $vsBot = $side === 'white' ? $match->black_bot : $match->white_bot;
            $won = $match->winner === $side;
            $events = self::events($match, $side, $won, $vsBot);
            $mode = $vsBot ? 'bot' : $match->mode;
            /** @var array{0: int, 1: int} $reward */
            $reward = config("progression.match.$mode.".($won ? 'win' : 'loss'));
            $scale = $match->match_length / (int) config('progression.match_reference_length');
            $coins = max(1, (int) round($reward[0] * $scale));
            $xp = max(1, (int) round($reward[1] * $scale));
            if ($won && $events['mars'] > 0) {
                /** @var array{0: int, 1: int} $bonus */
                $bonus = config('progression.gammon_bonus');
                $coins += $bonus[0];
                $xp += $bonus[1];
            }
            $this->wallet->credit($user, 'coins', $coins, 'match_reward', "match:{$match->id}:{$user->id}", $match->id);
            $this->addXp($user, $xp);
            $user->forceFill([
                'games_total' => $user->games_total + 1,
                'wins_total' => $user->wins_total + $events['win'],
                'mars_total' => $user->mars_total + $events['mars'],
                'ranked_wins_total' => $user->ranked_wins_total + $events['ranked_win'],
            ])->save();
            // Missions follow the day the result arrives (what the player sees).
            $this->advanceMissions($user, $events, now());
            $this->unlockAchievements($user);
        }
    }

    /**
     * What this match counts for missions and achievements, read from the
     * game records (`GameRecord` JSON).
     *
     * @return array<string, int>
     */
    public static function events(GameMatch $match, string $side, bool $won, bool $vsBot): array
    {
        $mars = 0;
        $doubles = 0;
        $cubeTakeWin = 0;
        foreach ($match->games as $game) {
            $gameWon = ($game['winner'] ?? null) === $side;
            if ($gameWon && in_array($game['kind'] ?? null, ['gammon', 'backgammon'], true)) {
                $mars++;
            }
            $took = false;
            /** @var array<int, array<string, mixed>> $actions */
            $actions = $game['record']['actions'] ?? [];
            foreach ($actions as $action) {
                if (($action['by'] ?? null) !== $side) {
                    continue;
                }
                if (($action['type'] ?? null) === 'roll' && ($action['d1'] ?? 0) === ($action['d2'] ?? -1)) {
                    $doubles++;
                }
                if (($action['type'] ?? null) === 'take') {
                    $took = true;
                }
            }
            if ($took && $gameWon) {
                $cubeTakeWin++;
            }
        }

        return [
            'play' => 1,
            'win' => $won ? 1 : 0,
            'ranked_win' => $won && $match->mode === 'ranked' && ! $vsBot ? 1 : 0,
            'mars' => $mars,
            'doubles' => $doubles,
            'cube_take_win' => $cubeTakeWin,
            'long_play' => $match->variant === 'longNard' ? 1 : 0,
        ];
    }

    /**
     * The single entry point for player XP (matches, missions); the same XP
     * also fills the running season pass (ADR-039).
     */
    public function addXp(User $user, int $xp): void
    {
        $this->pass->addXp($user, $xp);
        $user->xp += $xp;
        $level = $user->level;
        $spent = $this->xpBefore($level);
        while ($user->xp - $spent >= self::xpForLevel($level)) {
            $spent += self::xpForLevel($level);
            $level++;
            $this->wallet->credit($user, 'coins', (int) config('progression.level_up_coins'), 'level_up', "level:{$user->id}:$level");
            $this->notifier->notify($user, 'level_up', ['level' => $level, 'coins' => (int) config('progression.level_up_coins')], "level_up:$level");
        }
        $user->level = $level;
        $user->save();
    }

    /** Total XP needed to reach [level]. */
    private function xpBefore(int $level): int
    {
        $total = 0;
        for ($l = 1; $l < $level; $l++) {
            $total += self::xpForLevel($l);
        }

        return $total;
    }

    /** @return array{daily: string, weekly: string} */
    public static function periods(Carbon $at): array
    {
        return ['daily' => $at->toDateString(), 'weekly' => $at->format('o-\WW')];
    }

    /** A practice puzzle solved (13.2): counts for the puzzle mission. */
    public function onPuzzleSolved(User $user, Carbon $at): void
    {
        $this->advanceMissions($user, ['puzzle_solved' => 1], $at);
    }

    /** @param array<string, int> $events */
    private function advanceMissions(User $user, array $events, Carbon $at): void
    {
        foreach (self::periods($at) as $kind => $period) {
            /** @var array<string, array{event: string, target: int}> $missions */
            $missions = config("progression.missions.$kind");
            foreach ($missions as $id => $mission) {
                $add = $events[$mission['event']] ?? 0;
                if ($add === 0) {
                    continue;
                }
                DB::table('user_missions')->insertOrIgnore([
                    'user_id' => $user->id, 'mission_id' => $id, 'period' => $period,
                    'progress' => 0, 'created_at' => now(), 'updated_at' => now(),
                ]);
                $row = DB::table('user_missions')->where(['user_id' => $user->id, 'mission_id' => $id, 'period' => $period])->first();
                if ($row === null || $row->completed_at !== null) {
                    continue;
                }
                $progress = min($mission['target'], (int) $row->progress + $add);
                DB::table('user_missions')->where('id', $row->id)->update([
                    'progress' => $progress,
                    'completed_at' => $progress >= $mission['target'] ? now() : null,
                    'updated_at' => now(),
                ]);
            }
        }
    }

    public function unlockAchievements(User $user): void
    {
        $counters = [
            'play' => $user->games_total,
            'win' => $user->wins_total,
            'mars' => $user->mars_total,
            'ranked_win' => $user->ranked_wins_total,
            'streak' => $user->best_streak,
        ];
        /** @var array<string, array{event: string, target: int, title: string|null}> $all */
        $all = config('progression.achievements');
        foreach ($all as $id => $a) {
            if (($counters[$a['event']] ?? 0) < $a['target']) {
                continue;
            }
            $new = DB::table('user_achievements')->insertOrIgnore([
                'user_id' => $user->id, 'achievement_id' => $id, 'unlocked_at' => now(),
            ]);
            if ($new > 0 && $a['title'] !== null) {
                DB::table('user_items')->insertOrIgnore([
                    'user_id' => $user->id, 'item_id' => $a['title'], 'source' => 'achievement',
                    'created_at' => now(), 'updated_at' => now(),
                ]);
            }
        }
    }

    /** Claims a completed mission of the current period. */
    public function claim(User $user, string $missionId, Carbon $now): bool
    {
        foreach (self::periods($now) as $kind => $period) {
            /** @var array{coins: int, xp: int}|null $mission */
            $mission = config("progression.missions.$kind.$missionId");
            if ($mission === null) {
                continue;
            }
            $claimed = DB::table('user_missions')
                ->where(['user_id' => $user->id, 'mission_id' => $missionId, 'period' => $period])
                ->whereNotNull('completed_at')->whereNull('claimed_at')
                ->update(['claimed_at' => now()]);
            if ($claimed === 0) {
                return false;
            }
            $this->wallet->credit($user, 'coins', $mission['coins'], 'mission', "mission:{$user->id}:$missionId:$period");
            $this->addXp($user, $mission['xp']);
            if ($kind === 'daily') {
                $this->dailyBonus($user, $period);
            }

            return true;
        }

        return false;
    }

    /** All daily missions claimed: the fixed "Günlük sandıq" bonus, once. */
    private function dailyBonus(User $user, string $period): void
    {
        /** @var array<string, mixed> $daily */
        $daily = config('progression.missions.daily');
        $claimed = DB::table('user_missions')->where(['user_id' => $user->id, 'period' => $period])
            ->whereIn('mission_id', array_keys($daily))->whereNotNull('claimed_at')->count();
        if ($claimed === count($daily)) {
            $this->wallet->credit($user, 'coins', (int) config('progression.daily_bonus_coins'), 'mission', "daily-bonus:{$user->id}:$period");
        }
    }

    /**
     * Daily check-in for the login streak; returns coins granted (0 if
     * already checked in today).
     */
    public function checkIn(User $user, Carbon $today): int
    {
        $last = $user->last_checkin === null ? null : Carbon::parse($user->last_checkin);
        if ($last !== null && $last->isSameDay($today)) {
            return 0;
        }
        $streak = $last !== null && $last->copy()->addDay()->isSameDay($today) ? $user->login_streak + 1 : 1;
        /** @var array<int, int> $rewards */
        $rewards = config('progression.streak_coins');
        $coins = $rewards[($streak - 1) % count($rewards)];
        $user->forceFill([
            'login_streak' => $streak,
            'best_streak' => max($user->best_streak, $streak),
            'last_checkin' => $today->toDateString(),
        ])->save();
        $this->wallet->credit($user, 'coins', $coins, 'streak', "streak:{$user->id}:{$today->toDateString()}");
        $this->unlockAchievements($user);

        return $coins;
    }

    /** @return array<string, mixed> */
    public function summary(User $user, Carbon $now): array
    {
        $spent = $this->xpBefore($user->level);
        $missions = [];
        foreach (self::periods($now) as $kind => $period) {
            /** @var array<string, array{event: string, target: int, coins: int, xp: int}> $defs */
            $defs = config("progression.missions.$kind");
            $rows = DB::table('user_missions')->where('user_id', $user->id)->where('period', $period)->get()->keyBy('mission_id');
            foreach ($defs as $id => $m) {
                $row = $rows->get($id);
                $missions[] = [
                    'id' => $id, 'kind' => $kind, 'event' => $m['event'], 'target' => $m['target'],
                    'progress' => (int) ($row->progress ?? 0), 'coins' => $m['coins'], 'xp' => $m['xp'],
                    'completed' => ($row->completed_at ?? null) !== null, 'claimed' => ($row->claimed_at ?? null) !== null,
                ];
            }
        }

        return [
            'level' => $user->level,
            'xp' => $user->xp - $spent,
            'xpForNext' => self::xpForLevel($user->level),
            'streak' => ['current' => $user->login_streak, 'best' => $user->best_streak, 'lastCheckin' => $user->last_checkin, 'rewards' => config('progression.streak_coins')],
            'missions' => $missions,
            'achievements' => DB::table('user_achievements')->where('user_id', $user->id)->pluck('achievement_id')->all(),
            'title' => $user->title_item_id,
            'dailyBonus' => (int) config('progression.daily_bonus_coins'),
            // Home season card (2.1): running season pass, null between seasons.
            'season' => $this->pass->brief($user, $now),
            // Missions reset at midnight UTC (daily) and Monday (weekly).
            'resetsAt' => [
                'daily' => $now->copy()->utc()->addDay()->startOfDay()->toIso8601String(),
                'weekly' => $now->copy()->utc()->addWeek()->startOfWeek()->toIso8601String(),
            ],
        ];
    }
}
