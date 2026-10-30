<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Clan wars run Monday–Sunday UTC (spec §8.4).
Schedule::command('clans:pair-wars')->weeklyOn(1, '00:05')->timezone('UTC')->withoutOverlapping();
