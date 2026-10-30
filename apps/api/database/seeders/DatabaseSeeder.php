<?php

namespace Database\Seeders;

use App\Services\SeasonService;
use App\Services\TournamentService;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /** Reference data only; safe to run on every deploy. */
    public function run(): void
    {
        $this->call(ItemCatalogSeeder::class);
        $this->call(PuzzleSeeder::class);
        // Season 1 when there is none (afterwards `seasons:roll` starts each one).
        app(SeasonService::class)->current(now());
        // The next scheduled championships (idempotent; also run hourly).
        app(TournamentService::class)->schedule(now());
    }
}
