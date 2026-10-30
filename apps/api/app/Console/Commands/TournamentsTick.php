<?php

namespace App\Console\Commands;

use App\Services\TournamentService;
use Illuminate\Console\Command;

/** Every minute: starts due tournaments, cancels expired registrations, pushes pairings. */
class TournamentsTick extends Command
{
    protected $signature = 'tournaments:tick';

    protected $description = 'Start due tournaments, cancel unfilled sit-and-go tables (refunds) and push pairings to the game server';

    public function handle(TournamentService $tournaments): int
    {
        $r = $tournaments->tick(now());
        $this->info("Started {$r['started']}, cancelled {$r['cancelled']}, pushed {$r['pushed']} pairing(s).");

        return self::SUCCESS;
    }
}
