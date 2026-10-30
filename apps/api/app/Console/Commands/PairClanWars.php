<?php

namespace App\Console\Commands;

use App\Services\ClanService;
use Illuminate\Console\Command;

/** Weekly: closes last week's clan wars and pairs clans for this week. */
class PairClanWars extends Command
{
    protected $signature = 'clans:pair-wars';

    protected $description = 'Close finished clan wars and pair active clans for the current week (Monday–Sunday UTC)';

    public function handle(ClanService $clans): int
    {
        $closed = $clans->closeWars(now());
        $paired = $clans->pairWars(now());
        $this->info("Closed $closed war(s), started $paired war(s).");

        return self::SUCCESS;
    }
}
