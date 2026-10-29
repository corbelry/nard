<?php

namespace App\Services;

/**
 * Elo with match-length weighting, after the FIBS formula (spec §8.2):
 * P(A) = 1 / (10^((Rb − Ra)·√n / 2000) + 1); a player's change is
 * ±4·√n·(1 − P(winner)), multiplied by an experience factor
 * max(1, 5 − experience / 100) so new players move faster.
 */
class RatingService
{
    public static function winProbability(float $ra, float $rb, int $length): float
    {
        return 1 / (10 ** (($rb - $ra) * sqrt($length) / 2000) + 1);
    }

    public static function experienceFactor(int $experience): float
    {
        return max(1.0, 5 - $experience / 100);
    }

    /**
     * Rating changes for both players after a match of [length] points.
     *
     * @return array{0: int, 1: int} [winner change, loser change]
     */
    public static function changes(int $winner, int $loser, int $length, int $winnerExp, int $loserExp): array
    {
        $k = 4 * sqrt($length) * (1 - self::winProbability($winner, $loser, $length));

        return [
            (int) round($k * self::experienceFactor($winnerExp)),
            -(int) round($k * self::experienceFactor($loserExp)),
        ];
    }
}
