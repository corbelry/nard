<?php

namespace Tests\Feature;

use App\Models\Tournament;
use Illuminate\Support\Facades\Http;
use Tests\TournamentTestCase;

class SitAndGoAndPrivateTest extends TournamentTestCase
{
    public function test_a_full_sit_and_go_starts_at_once_and_pushes_round_one(): void
    {
        $players = [];
        for ($i = 0; $i < 8; $i++) {
            $players[] = $user = $this->player(600, 1500 + $i * 10);
            $res = $this->actingAs($user)->postJson('/api/v1/tournaments/sng/8/join', ['idempotencyKey' => "sng-key-$i"])
                ->assertCreated()
                ->assertJsonPath('wallet.coins', 100)
                ->assertJsonPath('tournament.kind', 'sit_and_go')
                // 8 × 500 − 10 % = 3 600, fixed before joining.
                ->assertJsonPath('tournament.prizeFund', 3600);
            if ($i === 0) {
                $this->actingAs($user)->getJson('/api/v1/tournaments/sng')->assertOk()
                    ->assertJsonPath('tables.0.size', 8)
                    ->assertJsonPath('tables.0.joined', 1)
                    ->assertJsonPath('tables.0.registered', true)
                    ->assertJsonPath('tables.0.expiresAt', now()->addMinutes(10)->toIso8601String())
                    ->assertJsonPath('tables.1.joined', 0);
                // Joining again keeps the seat and charges nothing.
                $this->actingAs($user)->postJson('/api/v1/tournaments/sng/8/join', ['idempotencyKey' => 'sng-key-again'])
                    ->assertCreated()->assertJsonPath('wallet.coins', 100);
            }
            $this->assertSame($i < 7 ? 'registering' : 'running', $res->json('tournament.status'));
        }
        $t = Tournament::query()->sole();
        $this->assertSame(3, $t->total_rounds);
        $round = $this->pairings($t, 1);
        $this->assertCount(4, $round);
        $this->assertTrue($round->every(fn ($p) => $p->status === 'pushed'));
        $this->assertPushed(...$round->pluck('match_id')->all());
        // Seed 1 (highest rating) meets seed 8.
        $first = $round->firstOrFail();
        $this->assertSame([$players[7]->id, $players[0]->id], [$first->white_user_id, $first->black_user_id]);
        Http::assertSent(fn ($r) => $r['noShowSeconds'] === 60 && $r['matchLength'] === 3 && ! isset($r['white']['rating']));
        $this->actingAs($players[0])->postJson('/api/v1/tournaments/sng/16/join')->assertUnprocessable();
        $this->actingAs($players[0])->postJson('/api/v1/tournaments/sng/12/join', ['idempotencyKey' => 'sng-key-12'])->assertNotFound();
    }

    public function test_an_unfilled_sit_and_go_is_cancelled_with_a_full_refund(): void
    {
        $users = [$this->player(500), $this->player(800)];
        foreach ($users as $i => $user) {
            $this->actingAs($user)->postJson('/api/v1/tournaments/sng/16/join', ['idempotencyKey' => "sng-key-$i"])->assertCreated();
        }
        $this->assertSame(0, $this->coins($users[0]));
        $this->travel(9)->minutes();
        $this->command('tournaments:tick');
        $this->assertSame('registering', Tournament::query()->sole()->status);
        $this->travel(1)->minutes();
        $this->command('tournaments:tick');
        $t = Tournament::query()->sole();
        $this->assertSame(['cancelled', 'not_filled'], [$t->status, $t->cancel_reason]);
        $this->assertSame([500, 800], [$this->coins($users[0]), $this->coins($users[1])]);
        // The next join opens a new table.
        $this->actingAs($users[0])->postJson('/api/v1/tournaments/sng/16/join', ['idempotencyKey' => 'sng-key-new'])->assertCreated()
            ->assertJsonPath('tournament.status', 'registering');
        $this->assertSame(2, Tournament::query()->count());
    }

    public function test_private_tournaments_are_free_invite_only_and_run_by_the_organiser(): void
    {
        $owner = $this->player(1000);
        $friend = $this->player(1000);
        $stranger = $this->player();
        $res = $this->actingAs($owner)->postJson('/api/v1/tournaments/private', [
            'name' => '  Cümə   axşamı  ', 'size' => 4, 'variant' => 'longNard', 'matchLength' => 5,
            // Fees are not accepted: private tournaments are free (QUESTIONS #34).
            'entryCoins' => 500,
        ])->assertCreated()
            ->assertJsonPath('tournament.name', ['default' => 'Cümə axşamı'])
            ->assertJsonPath('tournament.entry', ['kind' => 'invite', 'coins' => 0])
            ->assertJsonPath('tournament.myStatus', 'registered')
            ->assertJsonPath('tournament.organizerId', (string) $owner->id)
            ->assertJsonPath('tournament.rated', false);
        $id = (int) $res->json('tournament.id');
        $code = (string) $res->json('tournament.inviteCode');
        $this->assertMatchesRegularExpression('/^[A-Z2-9]{6}$/', $code);
        $this->assertSame(1000, $this->coins($owner));
        $this->actingAs($owner)->postJson('/api/v1/tournaments/private', ['name' => 'X', 'size' => 5, 'variant' => 'shortNard', 'matchLength' => 2])
            ->assertJsonValidationErrors(['name', 'size', 'matchLength']);

        // Invisible and closed without the code.
        $this->actingAs($stranger)->getJson("/api/v1/tournaments/$id")->assertNotFound();
        $this->actingAs($stranger)->postJson("/api/v1/tournaments/$id/register")->assertStatus(422)->assertJsonPath('code', 'invite_required');
        $this->actingAs($stranger)->getJson('/api/v1/tournaments?tab=mine')->assertOk()->assertJsonPath('tournaments', []);
        $this->actingAs($friend)->postJson('/api/v1/tournaments/join-by-code', ['code' => 'ZZZZZZ'])->assertNotFound();
        $dashed = strtolower(substr($code, 0, 3).'-'.substr($code, 3));
        $this->actingAs($friend)->postJson('/api/v1/tournaments/join-by-code', ['code' => $dashed])->assertOk()
            ->assertJsonPath('tournament.myStatus', 'registered')
            ->assertJsonPath('tournament.entrants', 2)
            ->assertJsonPath('tournament.inviteCode', $code);
        $this->assertSame(1000, $this->coins($friend));
        $this->actingAs($stranger)->postJson("/api/v1/tournaments/$id/register", ['code' => $code])->assertCreated();

        // Only the organiser starts, kicks or cancels.
        $this->actingAs($friend)->postJson("/api/v1/tournaments/$id/start")->assertForbidden();
        $this->actingAs($owner)->deleteJson("/api/v1/tournaments/$id/entrants/{$stranger->id}")->assertOk();
        $this->actingAs($owner)->deleteJson("/api/v1/tournaments/$id/entrants/{$owner->id}")->assertStatus(422)->assertJsonPath('code', 'self');
        $this->actingAs($owner)->postJson("/api/v1/tournaments/$id/start")->assertOk()
            ->assertJsonPath('tournament.status', 'running')
            ->assertJsonPath('tournament.totalRounds', 1)
            ->assertJsonPath('tournament.rounds.0.stage', 'final')
            ->assertJsonPath('tournament.myNextMatch.status', 'ready');
        $this->assertPushed("t$id-1-0");
        $this->actingAs($owner)->deleteJson("/api/v1/tournaments/$id")->assertStatus(422)->assertJsonPath('code', 'closed');
    }

    public function test_private_limits_cancel_and_expiry(): void
    {
        $owner = $this->player();
        $body = ['name' => 'Dostlar', 'size' => 8, 'variant' => 'shortNard', 'matchLength' => 3];
        $ids = [];
        for ($i = 0; $i < 3; $i++) {
            $ids[] = (int) $this->actingAs($owner)->postJson('/api/v1/tournaments/private', $body)->assertCreated()->json('tournament.id');
        }
        $this->actingAs($owner)->postJson('/api/v1/tournaments/private', $body)->assertStatus(422)->assertJsonPath('code', 'too_many_open');
        $this->actingAs($owner)->postJson("/api/v1/tournaments/{$ids[0]}/start")->assertStatus(422)->assertJsonPath('code', 'not_enough_players');
        $this->actingAs($owner)->deleteJson("/api/v1/tournaments/{$ids[0]}")->assertOk();
        // A scheduled start: started (or cancelled) by the tick.
        $scheduled = $this->actingAs($owner)->postJson('/api/v1/tournaments/private', [...$body, 'startsAt' => now()->addMinutes(30)->toIso8601String()])
            ->assertCreated()->assertJsonPath('tournament.expiresAt', null);
        $this->travel(25)->hours();
        $this->command('tournaments:tick');
        $statuses = Tournament::query()->orderBy('id')->pluck('cancel_reason')->all();
        $this->assertSame(['organizer', 'expired', 'expired', 'not_enough_players'], $statuses);
        $this->assertSame((string) Tournament::query()->latest('id')->value('id'), $scheduled->json('tournament.id'));
    }
}
