<?php

namespace App\Services;

/**
 * Pure tournament maths (no I/O): knockout seeding with byes, Swiss pairing
 * with Buchholz, round-robin by the circle method, places and prize splits.
 * Players are integer ids; a null partner is a bye.
 */
final class PairingEngine
{
    /** Backtracking budget for Swiss pairing before allowing rematches. */
    private const SWISS_BUDGET = 200_000;

    /** Rounds a knockout of [players] needs (a final at least). */
    public static function knockoutRounds(int $players): int
    {
        return max(1, (int) ceil(log(max(2, $players), 2)));
    }

    /**
     * Seed numbers (1-based) in bracket slot order for a power-of-two
     * [size]: 1 v size, size/2 v size/2+1 … so that seeds 1 and 2 can only
     * meet in the final.
     *
     * @return list<int>
     */
    public static function bracketOrder(int $size): array
    {
        $order = [1];
        while (count($order) < $size) {
            $n = count($order) * 2;
            $next = [];
            foreach ($order as $seed) {
                $next[] = $seed;
                $next[] = $n + 1 - $seed;
            }
            $order = $next;
        }

        return $order;
    }

    /**
     * First knockout round: [seeded] best first, padded to a power of two
     * with byes, which go to the top seeds.
     *
     * @param  list<int>  $seeded
     * @return list<array{0: int|null, 1: int|null}>
     */
    public static function knockoutFirstRound(array $seeded): array
    {
        $size = 2 ** self::knockoutRounds(count($seeded));
        $order = self::bracketOrder($size);
        $pairs = [];
        for ($i = 0; $i < $size; $i += 2) {
            $pairs[] = [$seeded[$order[$i] - 1] ?? null, $seeded[$order[$i + 1] - 1] ?? null];
        }

        return $pairs;
    }

    /**
     * Next knockout round from the previous round's winners in slot order
     * (null: nobody advanced from that slot).
     *
     * @param  list<int|null>  $winners
     * @return list<array{0: int|null, 1: int|null}>
     */
    public static function knockoutNext(array $winners): array
    {
        $pairs = [];
        for ($i = 0; $i < count($winners); $i += 2) {
            $pairs[] = [$winners[$i], $winners[$i + 1] ?? null];
        }

        return $pairs;
    }

    /** Place of a knockout player who lost in [round] of [totalRounds] (null: champion). */
    public static function knockoutPlace(int $totalRounds, ?int $lostInRound): int
    {
        return $lostInRound === null ? 1 : 2 ** ($totalRounds - $lostInRound) + 1;
    }

    /**
     * Swiss pairing: players ordered by points then rating are paired top
     * down within the order, avoiding rematches (backtracking); with an odd
     * count the lowest-ranked player without a bye gets one.
     *
     * @param  array<int, int>  $points  id => points
     * @param  array<int, int>  $ratings  id => rating
     * @param  array<int, list<int>>  $opponents  id => previous opponents
     * @param  list<int>  $hadBye
     * @return list<array{0: int, 1: int|null}>
     */
    public static function swiss(array $points, array $ratings, array $opponents, array $hadBye): array
    {
        $ids = self::rank($points, [], $ratings);
        $bye = null;
        if (count($ids) % 2 === 1) {
            foreach (array_reverse($ids) as $id) {
                if (! in_array($id, $hadBye, true)) {
                    $bye = $id;
                    break;
                }
            }
            $bye ??= $ids[count($ids) - 1];
            $ids = array_values(array_filter($ids, fn (int $id) => $id !== $bye));
        }
        $budget = self::SWISS_BUDGET;
        $pairs = self::pairAvoidingRematches($ids, $opponents, $budget);
        if ($pairs === null) {
            // Every pairing repeats someone: pair in order.
            $pairs = [];
            for ($i = 0; $i < count($ids); $i += 2) {
                $pairs[] = [$ids[$i], $ids[$i + 1]];
            }
        }
        if ($bye !== null) {
            $pairs[] = [$bye, null];
        }

        return $pairs;
    }

    /**
     * @param  list<int>  $ids
     * @param  array<int, list<int>>  $opponents
     * @return list<array{0: int, 1: int}>|null
     */
    private static function pairAvoidingRematches(array $ids, array $opponents, int &$budget): ?array
    {
        if ($ids === []) {
            return [];
        }
        $first = $ids[0];
        $rest = array_slice($ids, 1);
        foreach ($rest as $i => $candidate) {
            if (--$budget < 0) {
                return null;
            }
            if (in_array($candidate, $opponents[$first] ?? [], true)) {
                continue;
            }
            $remaining = $rest;
            unset($remaining[$i]);
            $sub = self::pairAvoidingRematches(array_values($remaining), $opponents, $budget);
            if ($sub !== null) {
                return [[$first, $candidate], ...$sub];
            }
        }

        return null;
    }

    /**
     * Full Buchholz: the sum of the current points of everyone a player
     * met (byes add nothing). Integer, as points are whole wins.
     *
     * @param  array<int, int>  $points
     * @param  array<int, list<int>>  $opponents
     * @return array<int, int>
     */
    public static function buchholz(array $points, array $opponents): array
    {
        $result = [];
        foreach (array_keys($points) as $id) {
            $result[$id] = array_sum(array_map(fn (int $o) => $points[$o] ?? 0, $opponents[$id] ?? []));
        }

        return $result;
    }

    /**
     * Standings order: points, then Buchholz, then rating, then id.
     *
     * @param  array<int, int>  $points
     * @param  array<int, int>  $buchholz
     * @param  array<int, int>  $ratings
     * @return list<int>
     */
    public static function rank(array $points, array $buchholz, array $ratings): array
    {
        $ids = array_keys($points);
        usort($ids, fn (int $a, int $b) => [$points[$b], $buchholz[$b] ?? 0, $ratings[$b] ?? 0, $a]
            <=> [$points[$a], $buchholz[$a] ?? 0, $ratings[$a] ?? 0, $b]);

        return $ids;
    }

    /**
     * Round-robin schedule by the circle method: every player meets every
     * other once; with an odd count one player sits out (bye) each round.
     * Colours alternate between rounds.
     *
     * @param  list<int>  $ids
     * @return list<list<array{0: int|null, 1: int|null}>>
     */
    public static function roundRobin(array $ids): array
    {
        if (count($ids) % 2 === 1) {
            $ids[] = null;
        }
        $n = count($ids);
        $rounds = [];
        for ($r = 0; $r < $n - 1; $r++) {
            $pairs = [];
            for ($i = 0; $i < $n / 2; $i++) {
                $a = $ids[$i];
                $b = $ids[$n - 1 - $i];
                [$a, $b] = $r % 2 === 0 ? [$a, $b] : [$b, $a];
                // The bye (null) always sits on the black side.
                $pairs[] = $a === null ? [$b, null] : [$a, $b];
            }
            $rounds[] = $pairs;
            // Keep the first player fixed; rotate the others by one.
            $last = array_pop($ids);
            array_splice($ids, 1, 0, [$last]);
        }

        return $rounds;
    }

    /**
     * Splits a sit-and-go [fund] by [split] rows [from, to, percent per
     * place]; rounding leftovers go to first place.
     *
     * @param  array<int, array{0: int, 1: int, 2: int|float}>  $split
     * @return list<array{from: int, to: int, coins: int, items: list<string>}>
     */
    public static function splitFund(int $fund, array $split): array
    {
        $prizes = [];
        $paid = 0;
        foreach ($split as [$from, $to, $percent]) {
            $coins = (int) floor($fund * $percent / 100);
            $paid += $coins * ($to - $from + 1);
            $prizes[] = ['from' => $from, 'to' => $to, 'coins' => $coins, 'items' => []];
        }
        if ($prizes !== []) {
            $prizes[0]['coins'] += $fund - $paid;
        }

        return $prizes;
    }

    /**
     * The prize row covering [place], if any.
     *
     * @param  array<int, array{from: int, to: int, coins: int, items: array<int, string>}>  $prizes
     * @return array{from: int, to: int, coins: int, items: array<int, string>}|null
     */
    public static function prizeFor(array $prizes, int $place): ?array
    {
        foreach ($prizes as $prize) {
            if ($place >= $prize['from'] && $place <= $prize['to']) {
                return $prize;
            }
        }

        return null;
    }

    /**
     * Coins paid out by a prize table.
     *
     * @param  array<int, array{from: int, to: int, coins: int, items: array<int, string>}>  $prizes
     */
    public static function fund(array $prizes): int
    {
        return array_sum(array_map(fn (array $p) => $p['coins'] * ($p['to'] - $p['from'] + 1), $prizes));
    }
}
