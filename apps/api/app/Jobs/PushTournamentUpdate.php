<?php

namespace App\Jobs;

use App\Services\GameServerClient;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\DB;

/**
 * Tells a tournament's connected entrants that it changed, so open
 * bracket / standings / sit-and-go screens refetch at once
 * (`POST /internal/tournament-updated`, ADR-049). Best effort, one try:
 * the screens still poll.
 */
class PushTournamentUpdate implements ShouldQueue
{
    use Queueable;

    public int $tries = 1;

    public function __construct(public int $tournamentId) {}

    public function handle(GameServerClient $gameServer): void
    {
        $userIds = DB::table('tournament_entries')->where('tournament_id', $this->tournamentId)
            ->orderBy('user_id')->pluck('user_id')->map(fn ($id) => (string) $id)->values()->all();
        if ($userIds === []) {
            return;
        }
        foreach (array_chunk($userIds, 1000) as $chunk) {
            $gameServer->pushTournamentUpdate((string) $this->tournamentId, $chunk);
        }
    }
}
