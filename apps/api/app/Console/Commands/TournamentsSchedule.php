<?php

namespace App\Console\Commands;

use App\Services\TournamentService;
use Illuminate\Console\Command;

/** Creates the next scheduled daily/weekly championships (config/tournaments.php). */
class TournamentsSchedule extends Command
{
    protected $signature = 'tournaments:schedule';

    protected $description = 'Create the upcoming scheduled tournaments (idempotent)';

    public function handle(TournamentService $tournaments): int
    {
        $created = $tournaments->schedule(now());
        $this->info("Created $created tournament(s).");

        return self::SUCCESS;
    }
}
