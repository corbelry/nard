<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Clan wars run Monday–Sunday UTC (spec §8.4).
Schedule::command('clans:pair-wars')->weeklyOn(1, '00:05')->timezone('UTC')->withoutOverlapping();

// Tournaments (docs/api/tournaments.md): start due ones, cancel unfilled
// sit-and-go tables, push pairings to the game server; keep the scheduled
// championships created ahead.
Schedule::command('tournaments:tick')->everyMinute()->withoutOverlapping();
Schedule::command('tournaments:schedule')->hourly()->withoutOverlapping();
