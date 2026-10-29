<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /** Reference data only; safe to run on every deploy. */
    public function run(): void
    {
        $this->call(ItemCatalogSeeder::class);
    }
}
