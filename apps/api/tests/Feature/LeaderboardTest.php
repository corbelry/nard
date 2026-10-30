<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\SeasonService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class LeaderboardTest extends TestCase
{
    use RefreshDatabase;

    private User $me;

    private User $friend;

    protected function setUp(): void
    {
        parent::setUp();
        Carbon::setTestNow('2026-11-04 12:00:00');
        config(['seasons.min_matches' => 1]);
        $this->me = $this->player('Me', 'AZ', 1600);
        $this->friend = $this->player('Friend', 'TR', 1700);
        $this->player('Local', 'AZ', 1950);
        $this->player('Unranked', 'AZ', 2400, matches: 0);
        $this->player('LongOnly', 'TR', 2000, 'longNard');
        DB::table('friendships')->insert([
            'requester_id' => $this->me->id, 'addressee_id' => $this->friend->id, 'status' => 'accepted',
            'accepted_at' => now(), 'created_at' => now(), 'updated_at' => now(),
        ]);
    }

    private function player(string $name, string $country, int $rating, string $variant = 'shortNard', int $matches = 3): User
    {
        $user = User::factory()->create(['name' => $name, 'country' => $country]);
        $user->ratingFor($variant)->forceFill(['rating' => $rating, 'matches' => $matches, 'season_matches' => $matches])->save();

        return $user;
    }

    /** @return array<string, mixed> */
    private function board(string $query): array
    {
        return $this->actingAs($this->me)->getJson('/api/v1/leaderboard?'.$query)->assertOk()->json();
    }

    public function test_global_ranks_by_rating_with_tiers_and_my_row(): void
    {
        $lb = $this->board('variant=shortNard');
        $this->assertSame('global', $lb['scope']);
        $this->assertSame(1, $lb['season']);
        $this->assertSame(['Local', 'Friend', 'Me'], array_column(array_column($lb['entries'], 'user'), 'name'));
        $this->assertSame([1, 2, 3], array_column($lb['entries'], 'rank'));
        $this->assertSame('diamond', $lb['entries'][0]['tier']);
        $this->assertSame(['rank' => 3, 'rating' => 1600, 'tier' => 'gold'], array_intersect_key($lb['me'], ['rank' => 1, 'rating' => 1, 'tier' => 1]));
        $this->assertSame(['LongOnly'], array_column(array_column($this->board('variant=longNard')['entries'], 'user'), 'name'));
    }

    public function test_country_friends_and_clan_scopes(): void
    {
        $country = $this->board('variant=shortNard&scope=country');
        $this->assertSame(['Local', 'Me'], array_column(array_column($country['entries'], 'user'), 'name'));
        $this->assertSame(2, $country['me']['rank']);

        $friends = $this->board('variant=shortNard&scope=friends');
        $this->assertSame(['Friend', 'Me'], array_column(array_column($friends['entries'], 'user'), 'name'));
        $this->assertSame(2, $friends['me']['rank']);

        $clan = $this->board('variant=shortNard&scope=clan');
        $this->assertSame([], $clan['entries']);
        $this->assertNull($clan['me']['rank']);
        $this->assertSame(1600, $clan['me']['rating']);
    }

    public function test_unranked_players_get_my_row_without_a_rank_and_bad_input_is_refused(): void
    {
        $this->me->ratingFor('shortNard')->forceFill(['matches' => 0])->save();
        $lb = $this->board('variant=shortNard');
        $this->assertNull($lb['me']['rank']);
        $this->assertSame(0, $lb['me']['matches']);
        $this->actingAs($this->me)->getJson('/api/v1/leaderboard')->assertStatus(422);
        $this->actingAs($this->me)->getJson('/api/v1/leaderboard?variant=shortNard&scope=world')->assertStatus(422);
        $this->actingAs($this->me)->getJson('/api/v1/leaderboard?variant=shortNard&season=9')->assertNotFound();
    }

    public function test_a_finished_season_shows_its_frozen_table(): void
    {
        $seasons = app(SeasonService::class);
        $seasons->current();
        Carbon::setTestNow('2026-12-16 00:05:00');
        $seasons->roll();
        // After the soft reset live ratings changed; season 1 stays as it ended.
        $past = $this->board('variant=shortNard&season=1');
        $this->assertSame(1, $past['season']);
        $this->assertSame([1950, 1700, 1600], array_column($past['entries'], 'rating'));
        $this->assertSame(3, $past['me']['rank']);
        $live = $this->board('variant=shortNard');
        $this->assertSame(2, $live['season']);
        $this->assertSame([1725, 1600, 1550], array_column($live['entries'], 'rating'));
    }
}
