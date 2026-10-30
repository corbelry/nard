<?php

namespace Tests\Feature;

use App\Models\Report;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SocialTest extends TestCase
{
    use RefreshDatabase;

    public function test_friend_requests_by_code_accept_and_list_with_presence(): void
    {
        $a = User::factory()->create(['name' => 'Elvin']);
        $b = User::factory()->create(['name' => 'Nigar']);
        $this->assertMatchesRegularExpression('/^[A-HJKMNP-Z2-9]{8}$/', (string) $b->friend_code);
        $req = $this->actingAs($a)->postJson('/api/v1/friends/requests', ['code' => strtolower((string) $b->friend_code)])
            ->assertCreated()->assertJsonPath('status', 'requested')->json();
        $this->actingAs($a)->postJson('/api/v1/friends/requests', ['userId' => (string) $b->id])
            ->assertStatus(422)->assertJsonPath('code', 'already_requested');
        $incoming = $this->actingAs($b)->getJson('/api/v1/friends')->assertOk()->json('incoming');
        $this->assertSame('Elvin', $incoming[0]['user']['name']);
        $this->actingAs($b)->postJson("/api/v1/friends/requests/{$incoming[0]['requestId']}/accept")->assertOk();
        $friends = $this->actingAs($a)->getJson('/api/v1/friends')->json('friends');
        $this->assertSame('Nigar', $friends[0]['user']['name']);
        // b made authenticated requests just now → online.
        $this->assertTrue($friends[0]['user']['online']);
        $this->actingAs($a)->postJson('/api/v1/friends/requests', ['userId' => (string) $b->id])
            ->assertStatus(422)->assertJsonPath('code', 'already_friends');
        $this->actingAs($a)->deleteJson("/api/v1/friends/{$b->id}")->assertOk();
        $this->assertSame([], $this->actingAs($a)->getJson('/api/v1/friends')->json('friends'));
        $this->assertSame('requested', $req['status']);
    }

    public function test_crossed_requests_become_a_friendship(): void
    {
        $a = User::factory()->create();
        $b = User::factory()->create();
        $this->actingAs($a)->postJson('/api/v1/friends/requests', ['userId' => (string) $b->id])->assertCreated();
        $this->actingAs($b)->postJson('/api/v1/friends/requests', ['userId' => (string) $a->id])
            ->assertCreated()->assertJsonPath('status', 'accepted');
        $this->actingAs($a)->postJson('/api/v1/friends/requests', ['userId' => (string) $a->id])
            ->assertStatus(422)->assertJsonPath('code', 'self');
        $this->actingAs($a)->postJson('/api/v1/friends/requests', ['code' => 'ZZZZZZZZ'])->assertNotFound();
    }

    public function test_requests_can_be_declined_or_cancelled(): void
    {
        $a = User::factory()->create();
        $b = User::factory()->create();
        $this->actingAs($a)->postJson('/api/v1/friends/requests', ['userId' => (string) $b->id]);
        $id = $this->actingAs($a)->getJson('/api/v1/friends')->json('outgoing.0.requestId');
        $this->actingAs($b)->deleteJson("/api/v1/friends/requests/$id")->assertOk();
        $this->actingAs($b)->deleteJson("/api/v1/friends/requests/$id")->assertNotFound();
        $this->actingAs($b)->postJson("/api/v1/friends/requests/$id/accept")->assertNotFound();
    }

    public function test_blocking_ends_friendship_hides_search_and_stops_requests(): void
    {
        $a = User::factory()->create(['name' => 'Elvin']);
        $b = User::factory()->create(['name' => 'Elnur']);
        $this->actingAs($a)->postJson('/api/v1/friends/requests', ['userId' => (string) $b->id]);
        $this->actingAs($a)->getJson('/api/v1/users/search?q=Eln')->assertOk()->assertJsonCount(1, 'users');
        $this->actingAs($b)->postJson("/api/v1/blocks/{$a->id}")->assertOk();
        $this->actingAs($a)->getJson('/api/v1/users/search?q=Eln')->assertJsonCount(0, 'users');
        $this->actingAs($a)->postJson('/api/v1/friends/requests', ['userId' => (string) $b->id])
            ->assertStatus(422)->assertJsonPath('code', 'blocked');
        $this->assertSame([], $this->actingAs($a)->getJson('/api/v1/friends')->json('outgoing'));
        $this->actingAs($b)->getJson('/api/v1/blocks')->assertJsonPath('users.0.name', 'Elvin');
        $this->actingAs($b)->deleteJson("/api/v1/blocks/{$a->id}")->assertOk();
        $this->actingAs($b)->postJson("/api/v1/blocks/{$b->id}")->assertStatus(422);
        $this->actingAs($b)->postJson('/api/v1/blocks/9999')->assertNotFound();
        $this->actingAs($a)->getJson('/api/v1/users/search?q=E')->assertUnprocessable();
    }

    public function test_reports_have_reasons_a_reference_and_a_daily_limit(): void
    {
        config(['social.reports_per_day' => 2]);
        $a = User::factory()->create();
        $b = User::factory()->create();
        $this->actingAs($a)->postJson('/api/v1/reports', ['userId' => (string) $b->id, 'reason' => 'abuse', 'matchId' => 'm1'])
            ->assertCreated()->assertJsonPath('reference', sprintf('R-%06d', Report::query()->sole()->id));
        $this->actingAs($a)->postJson('/api/v1/reports', ['userId' => (string) $b->id, 'reason' => 'spam'])->assertUnprocessable();
        $this->actingAs($a)->postJson('/api/v1/reports', ['userId' => (string) $b->id, 'reason' => 'name'])->assertCreated();
        $this->actingAs($a)->postJson('/api/v1/reports', ['userId' => (string) $b->id, 'reason' => 'other'])->assertStatus(429);
        $this->actingAs($a)->postJson('/api/v1/reports', ['userId' => (string) $a->id, 'reason' => 'other'])->assertNotFound();
    }

    public function test_friends_can_be_challenged_with_a_room_code(): void
    {
        $a = User::factory()->create(['name' => 'Elvin']);
        $b = User::factory()->create();
        $body = ['userId' => (string) $b->id, 'code' => 'AB23CD', 'variant' => 'longNard', 'matchLength' => 3];
        $this->actingAs($a)->postJson('/api/v1/challenges', $body)->assertStatus(422)->assertJsonPath('code', 'not_friends');
        $this->actingAs($a)->postJson('/api/v1/friends/requests', ['userId' => (string) $b->id]);
        $this->actingAs($b)->postJson('/api/v1/friends/requests', ['userId' => (string) $a->id]);
        $this->actingAs($a)->postJson('/api/v1/challenges', $body)->assertCreated();
        $challenges = $this->actingAs($b)->getJson('/api/v1/friends')->json('challenges');
        $this->assertSame('AB23CD', $challenges[0]['code']);
        $this->assertSame('Elvin', $challenges[0]['from']['name']);
        $this->travel(11)->minutes();
        $this->assertSame([], $this->actingAs($b)->getJson('/api/v1/friends')->json('challenges'));
    }

    public function test_challenges_carry_the_room_time_control(): void
    {
        $a = User::factory()->create();
        $b = User::factory()->create();
        $this->actingAs($a)->postJson('/api/v1/friends/requests', ['userId' => (string) $b->id]);
        $this->actingAs($b)->postJson('/api/v1/friends/requests', ['userId' => (string) $a->id]);
        $body = ['userId' => (string) $b->id, 'code' => 'AB23CD', 'variant' => 'shortNard', 'matchLength' => 1];

        // Older clients send no control: the room plays rapid (ADR-044).
        $this->actingAs($a)->postJson('/api/v1/challenges', $body)->assertCreated();
        $this->assertSame('rapid', $this->actingAs($b)->getJson('/api/v1/friends')->json('challenges.0.timeControl'));

        $this->actingAs($a)->postJson('/api/v1/challenges', [...$body, 'timeControl' => 'classic'])->assertCreated();
        $challenges = $this->actingAs($b)->getJson('/api/v1/friends')->json('challenges');
        $this->assertCount(1, $challenges);
        $this->assertSame('classic', $challenges[0]['timeControl']);

        $this->actingAs($a)->postJson('/api/v1/challenges', [...$body, 'timeControl' => 'daily'])
            ->assertUnprocessable()->assertJsonValidationErrors('timeControl');
    }
}
