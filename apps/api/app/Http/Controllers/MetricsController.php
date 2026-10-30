<?php

namespace App\Http\Controllers;

use App\Models\CheatFlag;
use App\Models\GameMatch;
use App\Models\Report;
use App\Models\User;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\DB;

/**
 * Prometheus text exposition of the API's key gauges (ADR-043). Request
 * rates and latencies come from the ingress; these are business and queue
 * health numbers read from the database at scrape time.
 */
class MetricsController extends Controller
{
    public function __invoke(): Response
    {
        $out = [];
        $gauge = function (string $name, string $help, array $samples) use (&$out): void {
            $out[] = "# HELP $name $help";
            $out[] = "# TYPE $name gauge";
            foreach ($samples as [$labels, $value]) {
                $out[] = $name.self::labels($labels).' '.$value;
            }
        };

        $users = User::query()->selectRaw('is_guest, count(*) as n')->groupBy('is_guest')->pluck('n', 'is_guest');
        $gauge('nard_api_users', 'Registered accounts, by kind.', [
            [['kind' => 'guest'], (int) ($users[1] ?? 0)],
            [['kind' => 'member'], (int) ($users[0] ?? 0)],
        ]);

        $matches = GameMatch::query()->where('ended_at', '>=', now()->subDay())
            ->selectRaw('mode, count(*) as n')->groupBy('mode')->pluck('n', 'mode');
        $gauge('nard_api_matches_last_24h', 'Matches that ended in the last 24 hours, by mode.',
            self::samples($matches, 'mode', ['casual', 'ranked', 'tournament']));

        $jobs = DB::table('jobs')->selectRaw('queue, count(*) as n')->groupBy('queue')->pluck('n', 'queue');
        $gauge('nard_api_queue_jobs', 'Jobs waiting in the database queue, by queue.',
            self::samples($jobs, 'queue', ['default']));

        $gauge('nard_api_failed_jobs', 'Jobs in the failed_jobs table.', [
            [[], DB::table('failed_jobs')->count()],
        ]);

        $gauge('nard_api_reports_open', 'Player reports waiting for a moderator.', [
            [[], Report::query()->where('status', 'open')->count()],
        ]);

        $flags = CheatFlag::query()->where('status', 'open')
            ->selectRaw('kind, count(*) as n')->groupBy('kind')->pluck('n', 'kind');
        $gauge('nard_api_cheat_flags_open', 'Open fair-play flags, by kind.',
            self::samples($flags, 'kind', ['engine', 'multi_account', 'abandonment', 'reports']));

        return response(implode("\n", $out)."\n", 200, ['Content-Type' => 'text/plain; version=0.0.4; charset=utf-8']);
    }

    /**
     * One sample per known label value (zero when absent) plus any others.
     *
     * @param  iterable<int|string, mixed>  $counts
     * @param  list<string>  $known
     * @return list<array{array<string, string>, int}>
     */
    private static function samples(iterable $counts, string $label, array $known): array
    {
        $values = array_fill_keys($known, 0);
        foreach ($counts as $key => $n) {
            $values[(string) $key] = (int) $n;
        }
        ksort($values);
        $samples = [];
        foreach ($values as $key => $n) {
            $samples[] = [[$label => (string) $key], $n];
        }

        return $samples;
    }

    /** @param array<string, string> $labels */
    private static function labels(array $labels): string
    {
        if ($labels === []) {
            return '';
        }
        $parts = [];
        foreach ($labels as $k => $v) {
            $parts[] = $k.'="'.addcslashes($v, "\\\"\n").'"';
        }

        return '{'.implode(',', $parts).'}';
    }
}
