<?php

namespace App\Services;

use App\Models\Puzzle;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

/**
 * Practice puzzles, "find the best move" (spec §8.8, design 13.x, ADR-039).
 * An attempt is checked by the POSITION it produces: the client sends the
 * board after its moves and any move order reaching the stored result board
 * is correct. Two attempts per puzzle; the solution is revealed only once
 * the puzzle is finished (solved, out of attempts, or revealed).
 */
class PuzzleService
{
    public function __construct(private ProgressionService $progression) {}

    /**
     * My unfinished puzzle if any, else the unseen puzzle closest to my
     * puzzle rating.
     */
    public function next(User $user, ?string $variant): ?Puzzle
    {
        foreach ($this->states($user) as $puzzleId => $state) {
            if (! $state['finished']) {
                $puzzle = Puzzle::query()->find($puzzleId);
                if ($puzzle !== null && $puzzle->enabled && ($variant === null || $puzzle->variant === $variant)) {
                    return $puzzle;
                }
            }
        }

        return Puzzle::query()->where('enabled', true)
            ->whereNotIn('id', DB::table('puzzle_attempts')->where('user_id', $user->id)->select('puzzle_id'))
            ->when($variant !== null, fn ($q) => $q->where('variant', $variant))
            ->orderByRaw('ABS(rating - ?)', [$user->puzzle_rating])->orderBy('id')
            ->first();
    }

    /** The same puzzle for everyone on a UTC day. */
    public function daily(Carbon $day): ?Puzzle
    {
        $ids = Puzzle::query()->where('enabled', true)->orderBy('id')->pluck('id');
        if ($ids->isEmpty()) {
            return null;
        }

        return Puzzle::query()->whereKey((string) $ids[crc32($day->copy()->utc()->toDateString()) % $ids->count()])->first();
    }

    /** @return array{attemptsUsed: int, finished: bool, correct: bool} */
    public function state(User $user, Puzzle $puzzle): array
    {
        return $this->states($user, $puzzle->id)[$puzzle->id] ?? ['attemptsUsed' => 0, 'finished' => false, 'correct' => false];
    }

    /** @return array<string, array{attemptsUsed: int, finished: bool, correct: bool}> */
    private function states(User $user, ?string $puzzleId = null): array
    {
        $max = (int) config('puzzles.max_attempts');
        $rows = DB::table('puzzle_attempts')->where('user_id', $user->id)
            ->when($puzzleId !== null, fn ($q) => $q->where('puzzle_id', $puzzleId))
            ->orderBy('id')->get(['puzzle_id', 'attempt', 'correct', 'revealed']);
        $states = [];
        foreach ($rows as $r) {
            $s = $states[$r->puzzle_id] ?? ['attemptsUsed' => 0, 'finished' => false, 'correct' => false];
            $s['attemptsUsed'] = max($s['attemptsUsed'], (int) $r->attempt);
            $s['correct'] = $s['correct'] || (bool) $r->correct;
            $s['finished'] = $s['correct'] || (bool) $r->revealed || $s['attemptsUsed'] >= $max;
            $states[(string) $r->puzzle_id] = $s;
        }

        return $states;
    }

    /**
     * Checks attempt [attempt] (1-based) with the board after the player's
     * moves. Replaying a recorded attempt returns its stored result.
     *
     * @param  array<string, mixed>  $board
     * @return array<string, mixed>
     *
     * @throws PuzzleException finished|bad_attempt|bad_board
     */
    public function attempt(User $user, Puzzle $puzzle, int $attempt, array $board, ?string $moves): array
    {
        $normalized = self::normalize($board);
        if ($normalized === null) {
            throw new PuzzleException('bad_board');
        }

        return DB::transaction(function () use ($user, $puzzle, $attempt, $normalized, $moves): array {
            User::query()->whereKey($user->id)->lockForUpdate()->first();
            $done = $this->recorded($user, $puzzle, $attempt);
            if ($done !== null) {
                return $done;
            }
            $state = $this->state($user, $puzzle);
            if ($state['finished']) {
                throw new PuzzleException('finished');
            }
            if ($attempt !== $state['attemptsUsed'] + 1) {
                throw new PuzzleException('bad_attempt');
            }
            $correct = $normalized === self::normalize($puzzle->result_board);
            $this->record($user, $puzzle, $attempt, $correct, false, $moves);
            if ($correct) {
                $this->progression->onPuzzleSolved($user, now());
            }

            return $this->recorded($user, $puzzle, $attempt) ?? [];
        });
    }

    /**
     * "Həllə bax": shows the solution; an unfinished puzzle counts as a
     * failed attempt.
     *
     * @return array<string, mixed>
     */
    public function reveal(User $user, Puzzle $puzzle): array
    {
        return DB::transaction(function () use ($user, $puzzle): array {
            User::query()->whereKey($user->id)->lockForUpdate()->first();
            $state = $this->state($user, $puzzle);
            $attempt = $state['attemptsUsed'];
            if (! $state['finished']) {
                $attempt++;
                $this->record($user, $puzzle, $attempt, false, true, null);
            }

            return $this->recorded($user, $puzzle, $attempt) ?? [];
        });
    }

    private function record(User $user, Puzzle $puzzle, int $attempt, bool $correct, bool $revealed, ?string $moves): void
    {
        /** @var array<int, int> $deltas */
        $deltas = config($correct ? 'puzzles.correct' : 'puzzles.wrong');
        $delta = $deltas[$attempt] ?? 0;
        $user->puzzle_rating = (int) DB::table('users')->where('id', $user->id)->value('puzzle_rating') + $delta;
        DB::table('users')->where('id', $user->id)->update(['puzzle_rating' => $user->puzzle_rating]);
        DB::table('puzzle_attempts')->insert([
            'user_id' => $user->id, 'puzzle_id' => $puzzle->id, 'attempt' => $attempt,
            'correct' => $correct, 'revealed' => $revealed, 'moves' => $moves === null ? null : mb_substr($moves, 0, 64),
            'rating_delta' => $delta, 'rating_after' => $user->puzzle_rating, 'created_at' => now(),
        ]);
    }

    /** @return array<string, mixed>|null the stored result of [attempt] */
    private function recorded(User $user, Puzzle $puzzle, int $attempt): ?array
    {
        $row = DB::table('puzzle_attempts')->where(['user_id' => $user->id, 'puzzle_id' => $puzzle->id, 'attempt' => $attempt])->first();
        if ($row === null) {
            return null;
        }
        $state = $this->state($user, $puzzle);
        $max = (int) config('puzzles.max_attempts');
        $finished = (bool) $row->correct || (bool) $row->revealed || $attempt >= $max;

        return [
            'puzzleId' => $puzzle->id,
            'attempt' => $attempt,
            'correct' => (bool) $row->correct,
            'finished' => $finished,
            'attemptsLeft' => $finished ? 0 : $max - $attempt,
            'ratingDelta' => (int) $row->rating_delta,
            'rating' => (int) $row->rating_after,
            'solution' => $finished || $state['finished'] ? [
                'moves' => $puzzle->solution,
                'board' => Puzzle::boardJson($puzzle->result_board),
                'secondBest' => $puzzle->second_best,
            ] : null,
        ];
    }

    /**
     * Canonical `{white: [point => count], black: …}` (1..25, zero counts
     * dropped, sorted), or null when malformed.
     *
     * @param  array<string, mixed>  $board
     * @return array{white: array<int, int>, black: array<int, int>}|null
     */
    public static function normalize(array $board): ?array
    {
        $out = ['white' => [], 'black' => []];
        foreach (['white', 'black'] as $side) {
            $points = $board[$side] ?? null;
            if (! is_array($points)) {
                return null;
            }
            $total = 0;
            foreach ($points as $point => $count) {
                $p = filter_var($point, FILTER_VALIDATE_INT);
                if ($p === false || $p < 1 || $p > 25 || ! is_int($count) || $count < 0 || $count > 15) {
                    return null;
                }
                $total += $count;
                if ($count > 0) {
                    $out[$side][$p] = $count;
                }
            }
            if ($total > 15) {
                return null;
            }
            ksort($out[$side]);
        }

        return $out;
    }
}
