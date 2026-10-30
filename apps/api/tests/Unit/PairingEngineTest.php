<?php

namespace Tests\Unit;

use App\Services\PairingEngine;
use PHPUnit\Framework\TestCase;

class PairingEngineTest extends TestCase
{
    public function test_knockout_seeding_keeps_top_seeds_apart(): void
    {
        $this->assertSame([1, 8, 4, 5, 2, 7, 3, 6], PairingEngine::bracketOrder(8));
        $this->assertSame(
            [[1, 4], [2, 3]],
            PairingEngine::knockoutFirstRound([1, 2, 3, 4]),
        );
        $this->assertSame(1, PairingEngine::knockoutRounds(2));
        $this->assertSame(3, PairingEngine::knockoutRounds(5));
        $this->assertSame(6, PairingEngine::knockoutRounds(64));
    }

    public function test_knockout_byes_go_to_the_top_seeds(): void
    {
        // 5 players → bracket of 8: seeds 1, 2 and 3 get byes.
        $this->assertSame(
            [[11, null], [14, 15], [12, null], [13, null]],
            PairingEngine::knockoutFirstRound([11, 12, 13, 14, 15]),
        );
        $this->assertSame([[1, 2], [3, null]], PairingEngine::knockoutNext([1, 2, 3, null]));
    }

    public function test_knockout_places(): void
    {
        $this->assertSame(1, PairingEngine::knockoutPlace(3, null));
        $this->assertSame(2, PairingEngine::knockoutPlace(3, 3));
        $this->assertSame(3, PairingEngine::knockoutPlace(3, 2));
        $this->assertSame(5, PairingEngine::knockoutPlace(3, 1));
        $this->assertSame(33, PairingEngine::knockoutPlace(6, 1));
    }

    public function test_swiss_pairs_by_score_and_avoids_rematches(): void
    {
        // Round 1: by rating.
        $this->assertSame(
            [[1, 2], [3, 4]],
            PairingEngine::swiss([1 => 0, 2 => 0, 3 => 0, 4 => 0], [1 => 1900, 2 => 1800, 3 => 1700, 4 => 1600], [], []),
        );
        // Round 2: the winners met already, so 1–3 and 2–4.
        $this->assertSame(
            [[1, 3], [2, 4]],
            PairingEngine::swiss(
                [1 => 1, 2 => 0, 3 => 1, 4 => 0],
                [1 => 1900, 2 => 1800, 3 => 1700, 4 => 1600],
                [1 => [2], 2 => [1], 3 => [4], 4 => [3]],
                [],
            ),
        );
        // Everyone has met: rematches in order rather than no pairing.
        $this->assertSame(
            [[1, 2]],
            PairingEngine::swiss([1 => 1, 2 => 0], [], [1 => [2], 2 => [1]], []),
        );
    }

    public function test_swiss_bye_goes_to_the_lowest_player_without_one(): void
    {
        $points = [1 => 2, 2 => 1, 3 => 1, 4 => 0, 5 => 0];
        $pairs = PairingEngine::swiss($points, [1 => 5, 2 => 4, 3 => 3, 4 => 2, 5 => 1], [], [5]);
        $this->assertSame([4, null], $pairs[count($pairs) - 1]);
        $this->assertSame([[1, 2], [3, 5]], array_slice($pairs, 0, 2));
    }

    public function test_buchholz_sums_opponents_points_and_breaks_ties(): void
    {
        $points = [1 => 2, 2 => 2, 3 => 1, 4 => 1, 5 => 0];
        $opponents = [1 => [3, 5], 2 => [4, 1], 3 => [1, 4], 4 => [2, 3], 5 => [1]];
        $buchholz = PairingEngine::buchholz($points, $opponents);
        $this->assertSame([1 => 1, 2 => 3, 3 => 3, 4 => 3, 5 => 2], $buchholz);
        // Same points: higher Buchholz first; then rating.
        $this->assertSame([2, 1, 4, 3, 5], PairingEngine::rank($points, $buchholz, [3 => 1500, 4 => 1600]));
    }

    public function test_round_robin_meets_everyone_once(): void
    {
        foreach ([4, 5, 6] as $n) {
            $ids = range(1, $n);
            $rounds = PairingEngine::roundRobin($ids);
            $this->assertCount($n % 2 === 0 ? $n - 1 : $n, $rounds);
            $met = [];
            $byes = [];
            foreach ($rounds as $pairs) {
                $seen = [];
                foreach ($pairs as [$a, $b]) {
                    $this->assertNotNull($a);
                    $seen[] = $a;
                    if ($b === null) {
                        $byes[] = $a;

                        continue;
                    }
                    $seen[] = $b;
                    $key = min($a, $b).'-'.max($a, $b);
                    $this->assertArrayNotHasKey($key, $met, "rematch $key");
                    $met[$key] = true;
                }
                sort($seen);
                $this->assertSame($ids, $seen, 'everyone once per round');
            }
            $this->assertCount(intdiv($n * ($n - 1), 2), $met);
            // Odd fields: everyone sits out exactly once.
            $this->assertSame($n % 2 === 0 ? [] : $ids, (function () use ($byes) {
                sort($byes);

                return $byes;
            })());
        }
    }

    public function test_sit_and_go_split_pays_the_whole_fund(): void
    {
        // 16 × 500 entries − 10 % = 7 200 (21.1).
        $prizes = PairingEngine::splitFund(7200, [[1, 1, 40], [2, 2, 24], [3, 4, 10], [5, 8, 4]]);
        $this->assertSame([2880, 1728, 720, 288], array_column($prizes, 'coins'));
        $this->assertSame(7200, PairingEngine::fund($prizes));
        $odd = PairingEngine::splitFund(14400 + 7, [[1, 1, 34], [2, 2, 20], [3, 4, 9], [5, 8, 4], [9, 16, 1.5]]);
        $this->assertSame(14407, PairingEngine::fund($odd));
        $this->assertSame(1296, PairingEngine::prizeFor($odd, 4)['coins'] ?? null);
        $this->assertNull(PairingEngine::prizeFor($odd, 17));
    }
}
