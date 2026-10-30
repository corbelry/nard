<?php

namespace Tests\Feature;

use App\Models\Tournament;
use App\Models\TournamentPairing;
use Illuminate\Support\Facades\Http;
use Tests\TournamentTestCase;

class TournamentSchedulerTest extends TournamentTestCase
{
    public function test_schedule_creates_the_next_championships_once(): void
    {
        // Tuesday 2026-11-03 12:00 UTC.
        $this->command('tournaments:schedule');
        $this->command('tournaments:schedule');
        $keys = Tournament::query()->orderBy('starts_at')->get()
            ->mapWithKeys(fn (Tournament $t) => [(string) $t->schedule_key => $t->starts_at?->toDateTimeString()])->all();
        $this->assertSame([
            'daily_cup:2026-11-03' => '2026-11-03 16:00:00',
            'daily_cup:2026-11-04' => '2026-11-04 16:00:00',
            'friday_cup:2026-11-06' => '2026-11-06 16:00:00',
            'long_league:2026-11-08' => '2026-11-08 16:00:00',
        ], $keys);
        $friday = Tournament::query()->where('schedule_key', 'friday_cup:2026-11-06')->sole();
        // The design's 64-player prize table: 25 000 / 12 000 / 6 500 + 6 500.
        $this->assertSame(50000, $friday->prize_fund);
        $this->assertSame([500, 'knockout', 'scheduled'], [$friday->entry_coins, $friday->format, $friday->kind]);
        $league = Tournament::query()->where('schedule_key', 'long_league:2026-11-08')->sole();
        $this->assertSame(['swiss', 7, 'longNard'], [$league->format, $league->swiss_rounds, $league->variant]);

        // After today's cup: the day after tomorrow is added.
        $this->travel(5)->hours();
        $this->command('tournaments:schedule');
        $this->assertTrue(Tournament::query()->where('schedule_key', 'daily_cup:2026-11-05')->exists());
    }

    public function test_tick_starts_due_tournaments_and_retries_failed_pushes(): void
    {
        // Down for the start and the same tick's retry.
        $this->gameServerStatuses = [503, 503];
        $t = $this->tournament(['starts_at' => now()->addMinutes(5)]);
        $this->enter($t, [$this->player(), $this->player()]);
        $this->command('tournaments:tick');
        $this->assertSame('registering', $t->refresh()->status);
        $this->travel(5)->minutes();
        // Started; the game server was down, the pairing waits.
        $this->command('tournaments:tick');
        $p = TournamentPairing::query()->sole();
        $this->assertSame(['running', 'pending'], [$t->refresh()->status, $p->status]);
        Http::assertSentCount(2);
        $this->command('tournaments:tick');
        $this->assertSame('pushed', $p->refresh()->status);
        Http::assertSentCount(3);
        // Pushed again only when stale (the game server ignores known matches).
        $this->command('tournaments:tick');
        Http::assertSentCount(3);
        $this->travel(11)->minutes();
        $this->command('tournaments:tick');
        Http::assertSentCount(4);
    }

    public function test_without_a_game_server_url_pairings_stay_pending(): void
    {
        config(['nard.game_server_url' => '']);
        $t = $this->tournament(['starts_at' => now()]);
        $this->enter($t, [$this->player(), $this->player()]);
        $this->command('tournaments:tick');
        $this->assertSame('pending', TournamentPairing::query()->sole()->status);
        Http::assertNothingSent();
    }
}
