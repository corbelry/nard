<?php

namespace App\Services;

use App\Models\CheatFlag;
use App\Models\GameMatch;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

/**
 * Fair-play signals (spec §8.14, ADR-042), run daily by `anticheat:scan`.
 * Each rule writes cheat_flags for admin review; only abandonment acts on
 * its own (a matchmaking cooldown). One flag per player and kind within a
 * rule's window: an open flag is refreshed, a reviewed one is left alone.
 *
 *  - engine: agreement with HeuristicBot(hard) far above the rating band
 *    (scored by the Dart move-quality tool, imported here);
 *  - multi_account: accounts sharing an IP or device meeting in ranked;
 *  - abandonment: many losses by abandonment/timeout;
 *  - reports: many distinct reporters.
 */
class AntiCheatService
{
    public function __construct(private ModerationService $moderation) {}

    /** Stores where an account signs in from (hashed; only equality matters). */
    public function recordSignIn(User $user, ?string $ip, ?string $deviceId): void
    {
        $now = now();
        $user->forceFill(['last_ip' => $ip, 'last_login_at' => $now])->saveQuietly();
        $rows = [];
        foreach (['ip' => $ip, 'device' => $deviceId] as $kind => $value) {
            if ($value !== null && $value !== '') {
                $rows[] = [
                    'user_id' => $user->id, 'kind' => $kind, 'value_hash' => hash('sha256', "$kind:$value"),
                    'first_seen_at' => $now, 'last_seen_at' => $now,
                ];
            }
        }
        if ($rows !== []) {
            DB::table('user_sightings')->upsert($rows, ['user_id', 'kind', 'value_hash'], ['last_seen_at']);
        }
    }

    // ---- engine assistance ---------------------------------------------------------

    /**
     * Ranked human matches for the move-quality tool, one JSON object per
     * line: {matchId, variant, white: {userId}, black: {userId}, games}.
     *
     * @param  resource  $out
     */
    public function exportMatches($out, Carbon $now): int
    {
        $c = config('fairplay.engine');
        $count = 0;
        GameMatch::query()
            ->where('mode', 'ranked')->where('white_bot', false)->where('black_bot', false)
            ->whereNotNull('white_user_id')->whereNotNull('black_user_id')
            ->where('ended_at', '>=', $now->copy()->subDays((int) $c['days']))
            ->orderByDesc('ended_at')->limit((int) $c['max_matches'])
            ->get()
            ->each(function (GameMatch $m) use ($out, &$count): void {
                fwrite($out, json_encode([
                    'matchId' => $m->id,
                    'variant' => $m->variant,
                    'white' => ['userId' => (string) $m->white_user_id],
                    'black' => ['userId' => (string) $m->black_user_id],
                    'games' => $m->games,
                ], JSON_UNESCAPED_UNICODE)."\n");
                $count++;
            });

        return $count;
    }

    /**
     * Imports the tool's per-player lines {userId, matches, games,
     * decisions, agreement, avgLoss} and flags players whose agreement is
     * far above what their rating band plays.
     *
     * @param  iterable<string>  $lines
     */
    public function scanEngine(iterable $lines, Carbon $now): int
    {
        $c = config('fairplay.engine');
        $flagged = 0;
        foreach ($lines as $line) {
            $row = json_decode(trim($line), true);
            if (! is_array($row) || ! isset($row['userId'], $row['agreement'], $row['decisions'], $row['matches'])) {
                continue;
            }
            if ((int) $row['matches'] < (int) $c['min_matches'] || (int) $row['decisions'] < (int) $c['min_decisions']) {
                continue;
            }
            $user = User::query()->find((int) $row['userId']);
            if ($user === null) {
                continue;
            }
            $rating = $user->bestRating();
            $expected = self::expectedAgreement($rating);
            $agreement = (float) $row['agreement'];
            if ($agreement < $expected + (float) $c['margin']) {
                continue;
            }
            $flagged += (int) $this->flag($user->id, 'engine', $agreement - $expected, [
                'agreement' => round($agreement, 4),
                'expected' => $expected,
                'avgLoss' => isset($row['avgLoss']) ? round((float) $row['avgLoss'], 5) : null,
                'decisions' => (int) $row['decisions'],
                'matches' => (int) $row['matches'],
                'games' => (int) ($row['games'] ?? 0),
                'rating' => $rating,
            ], (int) $c['days'], $now);
        }

        return $flagged;
    }

    public static function expectedAgreement(int $rating): float
    {
        $expected = 0.0;
        /** @var array<int, array{0: int, 1: float}> $bands */
        $bands = config('fairplay.engine.bands');
        foreach ($bands as [$from, $agreement]) {
            if ($rating >= $from) {
                $expected = (float) $agreement;
            }
        }

        return $expected;
    }

    // ---- multi-accounting ---------------------------------------------------------------

    /** Accounts sharing an IP or device that played each other in ranked. */
    public function scanMultiAccounts(Carbon $now): int
    {
        $c = config('fairplay.multi_account');
        $since = $now->copy()->subDays((int) $c['days']);
        $pairs = [];
        $shared = DB::table('user_sightings as a')
            ->join('user_sightings as b', function ($join): void {
                $join->on('a.kind', '=', 'b.kind')->on('a.value_hash', '=', 'b.value_hash')->on('a.user_id', '<', 'b.user_id');
            })
            ->where('a.last_seen_at', '>=', $since)->where('b.last_seen_at', '>=', $since)
            ->select(['a.user_id as u1', 'b.user_id as u2', 'a.kind'])->distinct()->get();
        foreach ($shared as $row) {
            $pairs["{$row->u1}:{$row->u2}"][] = (string) $row->kind;
        }
        $partners = [];
        foreach ($pairs as $key => $kinds) {
            [$a, $b] = array_map('intval', explode(':', $key));
            $matches = GameMatch::query()->where('mode', 'ranked')->where('ended_at', '>=', $since)
                ->where(fn ($q) => $q->where(['white_user_id' => $a, 'black_user_id' => $b])
                    ->orWhere(fn ($q) => $q->where(['white_user_id' => $b, 'black_user_id' => $a])))
                ->get(['white_user_id', 'winner']);
            if ($matches->count() < (int) $c['min_ranked_matches']) {
                continue;
            }
            $winsA = $matches->filter(fn (GameMatch $m) => ($m->winner === 'white') === ($m->white_user_id === $a))->count();
            $kinds = array_values(array_unique($kinds));
            $weight = in_array('device', $kinds, true) ? 2 : 1;
            foreach ([[$a, $b, $winsA], [$b, $a, $matches->count() - $winsA]] as [$me, $other, $wins]) {
                $partners[$me][] = ['userId' => $other, 'shared' => $kinds, 'rankedMatches' => $matches->count(), 'wins' => $wins, 'weight' => $weight];
            }
        }
        DB::table('user_sightings')->where('last_seen_at', '<', $now->copy()->subDays((int) $c['retention_days']))->delete();
        $flagged = 0;
        foreach ($partners as $userId => $list) {
            $score = array_sum(array_map(fn (array $p) => $p['rankedMatches'] * $p['weight'], $list));
            $flagged += (int) $this->flag($userId, 'multi_account', $score, [
                'partners' => array_map(fn (array $p) => array_diff_key($p, ['weight' => 0]), $list),
            ], (int) $c['days'], $now);
        }

        return $flagged;
    }

    // ---- abandonment ----------------------------------------------------------------------

    /** Many abandonment/timeout losses → flag and a matchmaking cooldown. */
    public function scanAbandonment(Carbon $now): int
    {
        $c = config('fairplay.abandonment');
        $since = $now->copy()->subDays((int) $c['days']);
        $stats = [];
        foreach (['white', 'black'] as $side) {
            $rows = DB::table('game_matches')
                ->where('ended_at', '>=', $since)->where('reason', '!=', 'walkover')
                ->whereNotNull("{$side}_user_id")
                ->groupBy("{$side}_user_id")
                ->selectRaw("{$side}_user_id as uid, COUNT(*) as total, SUM(CASE WHEN winner != ? AND reason IN ('abandoned', 'timeout') THEN 1 ELSE 0 END) as quits", [$side])
                ->get();
            foreach ($rows as $r) {
                $uid = (int) $r->uid;
                $stats[$uid]['total'] = ($stats[$uid]['total'] ?? 0) + (int) $r->total;
                $stats[$uid]['quits'] = ($stats[$uid]['quits'] ?? 0) + (int) $r->quits;
            }
        }
        $flagged = 0;
        foreach ($stats as $userId => $s) {
            $rate = $s['quits'] / max(1, $s['total']);
            if ($s['total'] < (int) $c['min_matches'] || $rate < (float) $c['rate']) {
                continue;
            }
            $until = $now->copy()->addHours((int) $c['cooldown_hours']);
            $new = $this->flag($userId, 'abandonment', $rate, [
                'matches' => $s['total'], 'quits' => $s['quits'], 'rate' => round($rate, 3),
                'cooldownUntil' => $until->toIso8601String(),
            ], (int) $c['days'], $now);
            if ($new) {
                $user = User::query()->find($userId);
                if ($user !== null) {
                    $user->forceFill(['queue_cooldown_until' => $until])->saveQuietly();
                    $this->moderation->audit(null, 'auto_cooldown', $user, 'abandonment', ['until' => $until->toIso8601String()]);
                }
                $flagged++;
            }
        }

        return $flagged;
    }

    // ---- reports --------------------------------------------------------------------------

    /** Many distinct reporters within the window. */
    public function scanReports(Carbon $now): int
    {
        $c = config('fairplay.reports');
        $since = $now->copy()->subDays((int) $c['days']);
        $min = (int) $c['distinct_reporters'];
        $rows = DB::table('reports')->where('created_at', '>=', $since)->whereNotNull('reporter_id')
            ->groupBy('reported_id')
            ->selectRaw('reported_id, COUNT(DISTINCT reporter_id) as reporters')
            ->havingRaw('COUNT(DISTINCT reporter_id) >= ?', [$min])
            ->get();
        $flagged = 0;
        foreach ($rows as $r) {
            $reasons = DB::table('reports')->where('reported_id', $r->reported_id)->where('created_at', '>=', $since)
                ->groupBy('reason')->selectRaw('reason, COUNT(*) as n')->pluck('n', 'reason')
                ->map(fn ($n) => (int) $n)->all();
            $flagged += (int) $this->flag((int) $r->reported_id, 'reports', (float) $r->reporters, [
                'reporters' => (int) $r->reporters, 'reasons' => $reasons,
            ], (int) $c['days'], $now);
        }

        return $flagged;
    }

    /**
     * Creates a flag unless one of [kind] exists for the player within the
     * window (an open one is refreshed). Returns whether it is new.
     *
     * @param  array<string, mixed>  $details
     */
    private function flag(int $userId, string $kind, float $score, array $details, int $windowDays, Carbon $now): bool
    {
        $existing = CheatFlag::query()->where(['user_id' => $userId, 'kind' => $kind])
            ->where('created_at', '>=', $now->copy()->subDays($windowDays))->latest('id')->first();
        if ($existing !== null) {
            if ($existing->status === 'open') {
                $existing->forceFill(['score' => round($score, 3), 'details' => $details])->save();
            }

            return false;
        }
        CheatFlag::query()->create([
            'user_id' => $userId, 'kind' => $kind, 'score' => round($score, 3), 'details' => $details, 'status' => 'open',
        ]);

        return true;
    }
}
