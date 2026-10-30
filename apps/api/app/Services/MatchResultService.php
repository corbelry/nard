<?php

namespace App\Services;

use App\Models\GameMatch;
use App\Models\Tournament;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

/**
 * Stores a MatchResult and applies rating changes (ranked, humans only);
 * tournament results advance their bracket (unrated).
 */
class MatchResultService
{
    public function __construct(
        private ProgressionService $progression,
        private ClanService $clans,
        private TournamentService $tournaments,
    ) {}

    /**
     * Idempotent: a repeated report returns the stored match unchanged.
     *
     * @param  array<string, mixed>  $r  validated MatchResult
     */
    public function ingest(array $r): GameMatch
    {
        return DB::transaction(function () use ($r): GameMatch {
            $existing = GameMatch::query()->lockForUpdate()->whereKey((string) $r['matchId'])->first();
            if ($existing !== null) {
                return $existing;
            }
            /** @var array<string, mixed> $white */
            $white = $r['white'];
            /** @var array<string, mixed> $black */
            $black = $r['black'];
            $whiteUser = self::user($white);
            $blackUser = self::user($black);
            $match = new GameMatch([
                'id' => $r['matchId'],
                'variant' => $r['variant'],
                'match_length' => $r['matchLength'],
                'mode' => $r['mode'],
                'tournament_id' => self::tournamentId($r),
                'white_user_id' => $whiteUser?->id,
                'black_user_id' => $blackUser?->id,
                'white_name' => $white['name'],
                'black_name' => $black['name'],
                'white_bot' => (bool) ($white['bot'] ?? false),
                'black_bot' => (bool) ($black['bot'] ?? false),
                'winner' => $r['winner'],
                'white_score' => $r['whiteScore'],
                'black_score' => $r['blackScore'],
                'reason' => $r['reason'],
                'games' => $r['games'],
                'started_at' => Carbon::createFromTimestampMs((int) $r['startedAt']),
                'ended_at' => Carbon::createFromTimestampMs((int) $r['endedAt']),
            ]);
            // Bots and casual games never change ratings (spec §7.4, §8.10).
            if ($r['mode'] === 'ranked' && $whiteUser !== null && $blackUser !== null) {
                $variant = (string) $r['variant'];
                $length = (int) $r['matchLength'];
                $w = $whiteUser->ratingFor($variant);
                $b = $blackUser->ratingFor($variant);
                $whiteWon = $r['winner'] === 'white';
                [$winRating, $loseRating] = $whiteWon ? [$w, $b] : [$b, $w];
                [$up, $down] = RatingService::changes(
                    $winRating->rating, $loseRating->rating, $length,
                    $winRating->experience, $loseRating->experience,
                );
                $match->white_rating_before = $w->rating;
                $match->black_rating_before = $b->rating;
                foreach ([[$winRating, $up, true], [$loseRating, $down, false]] as [$rating, $delta, $won]) {
                    $rating->rating += $delta;
                    $rating->peak = max($rating->peak, $rating->rating);
                    $rating->experience += $length;
                    $rating->matches += 1;
                    $rating->wins += $won ? 1 : 0;
                    $rating->season_matches += 1;
                    $rating->season_wins += $won ? 1 : 0;
                    $rating->save();
                }
                $match->white_rating_after = $w->rating;
                $match->black_rating_after = $b->rating;
            }
            $match->save();
            // New matches only: rewards are granted exactly once. A walkover
            // was not played: no rewards, no clan XP.
            if ($match->reason !== 'walkover') {
                $this->progression->onMatch($match);
                $this->clans->onMatch($match);
            }
            if ($r['mode'] === 'tournament' && isset($r['tournamentId'])) {
                $this->tournaments->onMatch($match, (string) $r['tournamentId']);
            }

            return $match;
        });
    }

    /** @param array<string, mixed> $r */
    private static function tournamentId(array $r): ?int
    {
        $id = $r['tournamentId'] ?? null;
        if ($r['mode'] !== 'tournament' || ! is_string($id) || ! ctype_digit($id)) {
            return null;
        }

        return Tournament::query()->whereKey((int) $id)->exists() ? (int) $id : null;
    }

    /** @param array<string, mixed> $player */
    private static function user(array $player): ?User
    {
        if ((bool) ($player['bot'] ?? false)) {
            return null;
        }

        return User::query()->find((int) $player['userId']);
    }
}
