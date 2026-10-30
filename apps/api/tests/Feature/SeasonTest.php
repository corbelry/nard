<?php

namespace Tests\Feature;

use App\Models\Season;
use App\Models\User;
use App\Services\SeasonService;
use App\Services\StoreService;
use App\Services\WalletService;
use Database\Seeders\ItemCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class SeasonTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(ItemCatalogSeeder::class);
        Carbon::setTestNow('2026-11-04 12:00:00');
        config(['seasons.min_matches' => 2]);
    }

    private function rated(?string $country, string $variant, int $rating, int $seasonMatches, int $seasonStart = 1500, ?User $user = null): User
    {
        $user ??= User::factory()->create(['country' => $country]);
        $user->ratingFor($variant)->forceFill([
            'rating' => $rating, 'peak' => max($rating, 1500) + 30, 'matches' => $seasonMatches + 10,
            'season_matches' => $seasonMatches, 'season_wins' => intdiv($seasonMatches, 2),
            'season_start_rating' => $seasonStart,
        ])->save();

        return $user;
    }

    public function test_season_one_is_created_with_a_six_week_length_and_a_rules_copy(): void
    {
        $season = app(SeasonService::class)->current();
        $this->assertSame(1, $season->number);
        $this->assertSame('2026-11-04 00:00:00', $season->starts_at->toDateTimeString());
        $this->assertSame('2026-12-16 00:00:00', $season->ends_at->toDateTimeString());
        $this->assertSame('Xəzər', $season->name['az']);
        $this->assertSame(950, $season->rules['pass']['premium_gems']);
        $this->assertSame(1, Season::query()->count());
        $this->assertSame($season->id, app(SeasonService::class)->current()->id);
    }

    public function test_roll_snapshots_ranks_grants_rewards_once_soft_resets_and_starts_the_next_season(): void
    {
        $seasons = app(SeasonService::class);
        $wallet = app(WalletService::class);
        $seasons->current();
        $a = $this->rated('AZ', 'shortNard', 1950, 3, 1800);
        $b = $this->rated('AZ', 'shortNard', 1600, 2);
        $this->rated(null, 'longNard', 2150, 4, 1500, $b);
        $c = $this->rated('TR', 'shortNard', 1400, 1);
        $d = $this->rated('TR', 'shortNard', 1975, 2);

        $this->assertSame(0, $seasons->roll(), 'not due yet');
        Carbon::setTestNow('2026-12-16 00:05:00');
        $this->assertSame(1, $seasons->roll());

        $result = fn (User $u, string $v): object => DB::table('season_results')->where(['user_id' => $u->id, 'variant' => $v])->sole();
        $this->assertSame(1, (int) $result($d, 'shortNard')->rank);
        $this->assertSame(2, (int) $result($a, 'shortNard')->rank);
        $this->assertSame(1, (int) $result($a, 'shortNard')->country_rank);
        $this->assertSame('diamond', $result($a, 'shortNard')->tier);
        $this->assertSame(3, (int) $result($b, 'shortNard')->rank);
        $this->assertSame(2, (int) $result($b, 'shortNard')->country_rank);
        $this->assertSame(1, (int) $result($b, 'longNard')->rank);
        $this->assertFalse(DB::table('season_results')->where('user_id', $c->id)->exists(), 'fewer than min_matches this season');

        // Rewards by the best final tier over both variants.
        $this->assertSame(2000, $wallet->balances($a)['coins']);
        $this->assertTrue(app(StoreService::class)->owns($a, 'avatar_frame.season_diamond'));
        $this->assertSame(3000, $wallet->balances($b)['coins']);
        $this->assertTrue(app(StoreService::class)->owns($b, 'avatar_frame.season_master'));
        $this->assertSame(0, $wallet->balances($c)['coins']);

        // Soft reset halfway to 1500, peak kept, season counters cleared.
        $ra = $a->ratingFor('shortNard')->refresh();
        $this->assertSame(1725, $ra->rating);
        $this->assertSame(1980, $ra->peak);
        $this->assertSame(1725, $ra->season_start_rating);
        $this->assertSame(0, $ra->season_matches);
        $this->assertSame(1450, $c->ratingFor('shortNard')->refresh()->rating);
        $this->assertSame(1825, $b->ratingFor('longNard')->refresh()->rating);

        $s1 = Season::query()->where('number', 1)->firstOrFail();
        $s2 = Season::query()->where('status', 'active')->firstOrFail();
        $this->assertSame('finished', $s1->status);
        $this->assertSame(2, $s2->number);
        $this->assertSame('2026-12-16 00:00:00', $s2->starts_at->toDateTimeString());
        $this->assertSame('2027-01-27 00:00:00', $s2->ends_at->toDateTimeString());

        // Running again changes nothing.
        $this->assertSame(0, $seasons->roll());
        $this->assertSame(0, Artisan::call('seasons:roll'));
        $this->assertSame(2000, $wallet->balances($a)['coins']);
        $this->assertSame(1, DB::table('season_rewards')->where('user_id', $a->id)->count());
        $this->assertSame(1725, $a->ratingFor('shortNard')->refresh()->rating);
    }

    public function test_summary_shows_my_final_ranks_and_reward(): void
    {
        $seasons = app(SeasonService::class);
        $seasons->current();
        $a = $this->rated('AZ', 'shortNard', 1950, 4, 1800);
        $this->actingAs($a)->getJson('/api/v1/season/summary')->assertNotFound();
        Carbon::setTestNow('2026-12-16 00:05:00');
        $seasons->roll();

        $this->actingAs($a)->getJson('/api/v1/season/summary')->assertOk()
            ->assertJsonPath('season.number', 1)
            ->assertJsonPath('results.0.variant', 'shortNard')
            ->assertJsonPath('results.0.rank', 1)
            ->assertJsonPath('results.0.countryRank', 1)
            ->assertJsonPath('results.0.tier', 'diamond')
            ->assertJsonPath('results.0.rating', 1950)
            ->assertJsonPath('results.0.ratingDelta', 150)
            ->assertJsonPath('results.0.winRate', 50)
            ->assertJsonPath('reward.tier', 'diamond')
            ->assertJsonPath('reward.coins', 2000)
            ->assertJsonPath('reward.itemId', 'avatar_frame.season_diamond')
            ->assertJsonPath('ratings.shortNard', 1725);
        $this->actingAs($a)->getJson('/api/v1/season/summary/1')->assertOk()->assertJsonPath('season.number', 1);
        $this->actingAs($a)->getJson('/api/v1/season/summary/2')->assertNotFound();
        $this->actingAs($a)->getJson('/api/v1/seasons')->assertOk()
            ->assertJsonPath('seasons.0.number', 2)->assertJsonPath('seasons.1.status', 'finished');
    }

    public function test_ranked_matches_count_towards_the_season(): void
    {
        $a = User::factory()->create();
        $b = User::factory()->create();
        $body = (string) json_encode([
            'matchId' => 'r1', 'variant' => 'shortNard', 'matchLength' => 3, 'mode' => 'ranked',
            'white' => ['userId' => (string) $a->id, 'name' => 'A', 'bot' => false],
            'black' => ['userId' => (string) $b->id, 'name' => 'B', 'bot' => false],
            'winner' => 'white', 'whiteScore' => 3, 'blackScore' => 0, 'reason' => 'completed',
            'games' => [['record' => [], 'winner' => 'white', 'kind' => 'single']],
            'startedAt' => 1767225600000, 'endedAt' => 1767226600000,
        ]);
        $this->call('POST', '/api/v1/internal/match-results', [], [], [], [
            'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'application/json',
            'HTTP_X_NARD_SIGNATURE' => hash_hmac('sha256', $body, 'test-secret-test-secret-test-secret!'),
        ], $body)->assertCreated();
        $ra = $a->ratingFor('shortNard')->refresh();
        $this->assertSame(1, $ra->season_matches);
        $this->assertSame(1, $ra->season_wins);
        $this->assertSame(0, $b->ratingFor('shortNard')->refresh()->season_wins);
    }
}
