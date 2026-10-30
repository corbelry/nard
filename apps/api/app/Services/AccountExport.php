<?php

namespace App\Services;

use App\Models\GameMatch;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use RuntimeException;
use ZipArchive;

/**
 * 15.2: everything stored about a player, as a ZIP of JSON files (one per
 * table, QUESTIONS #17). Secrets (push tokens, hashes, idempotency keys)
 * are left out; fraud signals (cheat flags) stay internal.
 */
class AccountExport
{
    /** Table → the columns that point at the player. */
    private const TABLES = [
        'ratings' => ['user_id'],
        'wallets' => ['user_id'],
        'wallet_transactions' => ['user_id'],
        'user_items' => ['user_id'],
        'loadouts' => ['user_id'],
        'user_missions' => ['user_id'],
        'user_achievements' => ['user_id'],
        'puzzle_attempts' => ['user_id'],
        'friendships' => ['requester_id', 'addressee_id'],
        'blocks' => ['blocker_id'],
        'challenges' => ['from_user_id', 'to_user_id'],
        'reports' => ['reporter_id'],
        'clan_members' => ['user_id'],
        'clan_join_requests' => ['user_id'],
        'clan_invites' => ['user_id'],
        'clan_messages' => ['user_id'],
        'tournament_entries' => ['user_id'],
        'season_passes' => ['user_id'],
        'season_results' => ['user_id'],
        'season_rewards' => ['user_id'],
        'notifications' => ['user_id'],
        'notification_settings' => ['user_id'],
        'device_tokens' => ['user_id'],
        'user_sightings' => ['user_id'],
    ];

    private const SECRET = '/(^|_)(token|hash)$|^idempotency_key$|password|secret/';

    /** @return array<string, mixed> file name (without .json) → content */
    public function collect(User $user): array
    {
        $files = [
            'profile' => [
                ...$user->profile(),
                'createdAt' => $user->created_at?->toIso8601String(),
                'lastIp' => $user->last_ip,
            ],
            'matches' => GameMatch::query()
                ->where(fn ($q) => $q->where('white_user_id', $user->id)->orWhere('black_user_id', $user->id))
                ->orderByDesc('ended_at')->get()
                ->map(fn (GameMatch $m) => $m->summary($user->id, true))->all(),
        ];
        foreach (self::TABLES as $table => $columns) {
            $files[$table] = DB::table($table)
                ->where(function ($q) use ($columns, $user): void {
                    foreach ($columns as $column) {
                        $q->orWhere($column, $user->id);
                    }
                })
                ->get()
                ->map(fn (object $row) => array_filter(
                    (array) $row,
                    fn (string $key) => preg_match(self::SECRET, $key) !== 1,
                    ARRAY_FILTER_USE_KEY,
                ))->all();
        }

        return $files;
    }

    /** The ZIP bytes. */
    public function zip(User $user): string
    {
        $path = tempnam(sys_get_temp_dir(), 'nard-export');
        if ($path === false) {
            throw new RuntimeException('No temp file for the export');
        }
        try {
            $zip = new ZipArchive;
            $zip->open($path, ZipArchive::OVERWRITE);
            foreach ($this->collect($user) as $name => $content) {
                $zip->addFromString(
                    "$name.json",
                    (string) json_encode($content, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES),
                );
            }
            $zip->close();

            return (string) file_get_contents($path);
        } finally {
            @unlink($path);
        }
    }
}
