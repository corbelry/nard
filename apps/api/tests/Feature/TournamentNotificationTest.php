<?php

namespace Tests\Feature;

use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Tests\TournamentTestCase;

class TournamentNotificationTest extends TournamentTestCase
{
    /** @return array<mixed> notification types of a player, oldest first */
    private function types(int $userId): array
    {
        return DB::table('notifications')->where('user_id', $userId)->orderBy('id')->pluck('type')->all();
    }

    public function test_reminder_start_rounds_elimination_and_the_title(): void
    {
        $t = $this->tournament(['starts_at' => now()->addMinutes(40)]);
        $u = [$this->player(rating: 2000), $this->player(rating: 1900), $this->player(rating: 1800), $this->player(rating: 1700)];
        $this->enter($t, $u);

        $this->command('tournaments:tick');
        $this->assertSame([], $this->types($u[0]->id), 'not within 15 minutes yet');
        Carbon::setTestNow(now()->addMinutes(28));
        $this->command('tournaments:tick');
        $this->command('tournaments:tick');
        $this->assertSame(['tournament_reminder'], $this->types($u[0]->id));
        $data = json_decode((string) DB::table('notifications')->where('user_id', $u[0]->id)->value('data'), true);
        $this->assertSame([12, (string) $t->id, 'Test Cup'], [$data['minutes'], $data['tournamentId'], $data['tournament']['en']]);

        Carbon::setTestNow(now()->addMinutes(12));
        $this->command('tournaments:tick');
        $this->assertSame(['tournament_reminder', 'tournament_started'], $this->types($u[3]->id));

        [$m1, $m2] = $this->pairings($t, 1)->all();
        $this->report($m1, 'white')->assertCreated();   // seed 1 beats seed 4
        $this->report($m2, 'black')->assertCreated();   // seed 3 beats seed 2
        $this->assertSame(['tournament_reminder', 'tournament_started', 'tournament_eliminated'], $this->types($u[3]->id));
        $this->assertSame(['tournament_reminder', 'tournament_started', 'tournament_round'], $this->types($u[0]->id));
        $round = json_decode((string) DB::table('notifications')->where(['user_id' => $u[0]->id, 'type' => 'tournament_round'])->value('data'), true);
        $this->assertSame([2, $u[2]->name], [$round['round'], $round['opponent']]);

        $this->report($this->pairings($t, 2)->sole(), 'white')->assertCreated();
        $this->assertSame('tournament_won', $this->types($u[0]->id)[3] ?? null);
        $this->assertSame('tournament_eliminated', $this->types($u[2]->id)[3] ?? null);
        $this->assertSame(4, count($this->types($u[2]->id)));
    }
}
