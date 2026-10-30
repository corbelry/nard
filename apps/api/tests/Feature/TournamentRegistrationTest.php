<?php

namespace Tests\Feature;

use App\Models\Tournament;
use Tests\TournamentTestCase;

class TournamentRegistrationTest extends TournamentTestCase
{
    public function test_coin_entry_is_debited_once_and_refunded_on_leaving(): void
    {
        $t = $this->tournament(['entry_coins' => 500, 'prizes' => [['from' => 1, 'to' => 1, 'coins' => 1000, 'items' => []]], 'prize_fund' => 1000]);
        $a = $this->player(1200);
        $url = "/api/v1/tournaments/{$t->id}/register";
        $this->actingAs($a)->postJson($url)->assertStatus(422)->assertJsonPath('code', 'idempotency_key_required');
        $this->actingAs($a)->postJson($url, ['idempotencyKey' => 'entry-key-1'])->assertCreated()
            ->assertJsonPath('wallet.coins', 700)
            ->assertJsonPath('tournament.myStatus', 'registered')
            ->assertJsonPath('tournament.entrants', 1)
            ->assertJsonPath('tournament.entry', ['kind' => 'coins', 'coins' => 500])
            ->assertJsonPath('tournament.rated', false);
        // A retried request is not charged twice; a second registration is refused.
        $this->actingAs($a)->postJson($url, ['idempotencyKey' => 'entry-key-1'])->assertCreated()->assertJsonPath('wallet.coins', 700);
        $this->actingAs($a)->postJson($url, ['idempotencyKey' => 'entry-key-2'])->assertStatus(422)->assertJsonPath('code', 'already_registered');
        $this->actingAs($a)->deleteJson($url)->assertOk()
            ->assertJsonPath('wallet.coins', 1200)
            ->assertJsonPath('tournament.myStatus', 'none');
        $this->actingAs($a)->deleteJson($url)->assertStatus(422)->assertJsonPath('code', 'not_registered');
        // The paid-and-refunded key cannot buy a free entry.
        $this->actingAs($a)->postJson($url, ['idempotencyKey' => 'entry-key-1'])->assertStatus(422)->assertJsonPath('code', 'idempotency_key_reused');
        $this->actingAs($a)->postJson($url, ['idempotencyKey' => 'entry-key-3'])->assertCreated()->assertJsonPath('wallet.coins', 700);

        $poor = $this->player(100);
        $this->actingAs($poor)->postJson($url, ['idempotencyKey' => 'entry-key-4'])->assertStatus(422)->assertJsonPath('code', 'insufficient_coins');
        $this->assertSame(100, $this->coins($poor));
    }

    public function test_rating_capacity_and_status_are_checked(): void
    {
        $t = $this->tournament(['size' => 2, 'min_rating' => 1600]);
        $url = "/api/v1/tournaments/{$t->id}/register";
        $this->actingAs($this->player(rating: 1599))->postJson($url)->assertStatus(422)->assertJsonPath('code', 'rating_too_low');
        $this->enter($t, [$this->player(rating: 1600), $this->player(rating: 1700)]);
        $this->actingAs($this->player(rating: 1800))->postJson($url)->assertStatus(422)->assertJsonPath('code', 'full');
        $t->update(['status' => 'running']);
        $this->actingAs($this->player(rating: 1800))->postJson($url)->assertStatus(422)->assertJsonPath('code', 'closed');
        $this->actingAs($this->player())->postJson('/api/v1/tournaments/999/register')->assertNotFound();
    }

    public function test_cancelled_tournaments_refund_every_entry(): void
    {
        // Below the minimum at the start time: cancelled by the tick.
        $t = $this->tournament(['entry_coins' => 300, 'min_players' => 4]);
        $users = [$this->player(500), $this->player(500)];
        $this->enter($t, $users);
        $this->assertSame(200, $this->coins($users[0]));
        $this->travel(61)->minutes();
        $this->command('tournaments:tick');
        $t->refresh();
        $this->assertSame('cancelled', $t->status);
        $this->assertSame('not_enough_players', $t->cancel_reason);
        foreach ($users as $user) {
            $this->assertSame(500, $this->coins($user));
        }
        // Refunds happen once.
        $this->command('tournaments:tick');
        $this->assertSame(500, $this->coins($users[0]));
    }

    public function test_list_tabs_filters_and_detail(): void
    {
        $me = $this->player();
        $open = $this->tournament(['variant' => 'longNard', 'format' => 'swiss']);
        $paid = $this->tournament(['entry_coins' => 100, 'starts_at' => now()->addHours(2)]);
        $live = $this->tournament(['status' => 'running', 'started_at' => now(), 'current_round' => 1, 'total_rounds' => 3]);
        $hidden = $this->tournament(['kind' => 'private', 'is_private' => true, 'invite_code' => 'ABC234', 'status' => 'running']);
        $this->enter($open, [$me]);

        $ids = fn (string $query) => array_column((array) $this->actingAs($me)->getJson("/api/v1/tournaments?$query")->assertOk()->json('tournaments'), 'id');
        $this->assertSame([(string) $open->id, (string) $paid->id], $ids('tab=upcoming'));
        $this->assertSame([(string) $open->id], $ids('tab=upcoming&free=1&variant=longNard'));
        $this->assertSame([(string) $live->id], $ids('tab=live'));
        $this->assertSame([(string) $open->id], $ids('tab=mine'));
        $this->assertSame([], $ids('tab=finished'));

        $this->actingAs($me)->getJson("/api/v1/tournaments/{$open->id}")->assertOk()
            ->assertJsonPath('tournament.type', 'swiss')
            ->assertJsonPath('tournament.myStatus', 'registered')
            ->assertJsonPath('tournament.entrantsList.0.user.id', (string) $me->id)
            ->assertJsonPath('tournament.standings.0.points', 0)
            ->assertJsonPath('tournament.clock', ['reserveMs' => 180000, 'delayMs' => 12000])
            ->assertJsonPath('tournament.inviteCode', null);
        $this->actingAs($me)->getJson("/api/v1/tournaments/{$hidden->id}")->assertNotFound();
        $this->assertSame(4, Tournament::query()->count());
    }
}
