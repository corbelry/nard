<?php

namespace App\Console\Commands;

use App\Services\SeasonService;
use Illuminate\Console\Command;

/** Daily: ends a due season (final ranks, rewards, soft reset) and starts the next. */
class SeasonsRoll extends Command
{
    protected $signature = 'seasons:roll';

    protected $description = 'End the current season when due (snapshot ranks, grant season-end rewards, soft-reset ratings) and start the next one';

    public function handle(SeasonService $seasons): int
    {
        $ended = $seasons->roll(now());
        $current = $seasons->current(now());
        $this->info("Ended $ended season(s); season {$current->number} runs until {$current->ends_at->toIso8601String()}.");

        return self::SUCCESS;
    }
}
