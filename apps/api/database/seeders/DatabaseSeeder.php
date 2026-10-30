<?php

namespace Database\Seeders;

use App\Services\TournamentService;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /** Reference data only; safe to run on every deploy. */
    public function run(): void
    {
        $this->call(ItemCatalogSeeder::class);
        // The next scheduled championships (idempotent; also run hourly).
        app(TournamentService::class)->schedule(now());
    }
}
