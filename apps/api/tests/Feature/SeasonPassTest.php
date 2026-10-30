<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\ProgressionService;
use App\Services\SeasonPassService;
use App\Services\SeasonService;
use App\Services\StoreService;
use App\Services\WalletService;
use Database\Seeders\ItemCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;
use Tests\TestCase;

class SeasonPassTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(ItemCatalogSeeder::class);
        Carbon::setTestNow('2026-11-04 12:00:00');
        app(SeasonService::class)->current();
    }

    private function report(User $white, User $black, string $id): void
    {
        $body = (string) json_encode([
            'matchId' => $id, 'variant' => 'shortNard', 'matchLength' => 5, 'mode' => 'casual',
            'white' => ['userId' => (string) $white->id, 'name' => 'W', 'bot' => false],
            'black' => ['userId' => (string) $black->id, 'name' => 'B', 'bot' => false],
            'winner' => 'white', 'whiteScore' => 5, 'blackScore' => 0, 'reason' => 'completed',
            'games' => [['record' => [], 'winner' => 'white', 'kind' => 'single']],
            'startedAt' => 1767225600000, 'endedAt' => 1767226600000,
        ]);
        $this->call('POST', '/api/v1/internal/match-results', [], [], [], [
            'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'application/json',
            'HTTP_X_NARD_SIGNATURE' => hash_hmac('sha256', $body, 'test-secret-test-secret-test-secret!'),
        ], $body)->assertCreated();
    }

    public function test_match_xp_fills_the_pass_once(): void
    {
        $a = User::factory()->create();
        $b = User::factory()->create();
        $this->report($a, $b, 'm1');
        $this->report($a, $b, 'm1');
        // Casual 5-point win: 80 XP, loss 30 XP; a repeated report adds nothing.
        $this->actingAs($a)->getJson('/api/v1/season')->assertOk()
            ->assertJsonPath('season.number', 1)
            ->assertJsonPath('pass.xp', 80)
            ->assertJsonPath('pass.level', 0)
            ->assertJsonPath('pass.levelXp', 80)
            ->assertJsonPath('pass.levels', 50)
            ->assertJsonPath('pass.xpPerLevel', 1000)
            ->assertJsonPath('pass.premium', false)
            ->assertJsonPath('pass.premiumPrice.gems', 950);
        $this->assertSame(80, $a->refresh()->xp);
        $this->actingAs($b)->getJson('/api/v1/season')->assertJsonPath('pass.xp', 30);
        $this->actingAs($a)->getJson('/api/v1/me/progress')->assertOk()
            ->assertJsonPath('progress.season.level', 0)->assertJsonPath('progress.season.xp', 80);
    }

    public function test_mission_xp_counts_and_xp_after_the_season_end_does_not(): void
    {
        $a = User::factory()->create();
        app(ProgressionService::class)->addXp($a, 1200);
        $this->actingAs($a)->getJson('/api/v1/season')->assertJsonPath('pass.level', 1)->assertJsonPath('pass.levelXp', 200);
        Carbon::setTestNow('2026-12-16 00:01:00');
        app(ProgressionService::class)->addXp($a, 500);
        $this->assertSame(1200, (int) DB::table('season_passes')->where('user_id', $a->id)->value('xp'));
    }

    public function test_claims_are_once_per_level_and_track_and_premium_is_locked(): void
    {
        $a = User::factory()->create();
        $wallet = app(WalletService::class);
        app(SeasonPassService::class)->addXp($a, 3500);

        $this->actingAs($a)->postJson('/api/v1/season/pass/claim', ['level' => 1, 'track' => 'free'])->assertOk()
            ->assertJsonPath('wallet.coins', 200)
            ->assertJsonPath('pass.rewards.0.claimed', true);
        $this->actingAs($a)->postJson('/api/v1/season/pass/claim', ['level' => 1, 'track' => 'free'])
            ->assertStatus(422)->assertJsonPath('code', 'already_claimed');
        $this->actingAs($a)->postJson('/api/v1/season/pass/claim', ['level' => 4, 'track' => 'free'])
            ->assertStatus(422)->assertJsonPath('code', 'not_reached');
        $this->actingAs($a)->postJson('/api/v1/season/pass/claim', ['level' => 3, 'track' => 'premium'])
            ->assertStatus(422)->assertJsonPath('code', 'premium_required');
        $this->actingAs($a)->postJson('/api/v1/season/pass/claim', ['level' => 1, 'track' => 'premium'])
            ->assertStatus(422)->assertJsonPath('code', 'no_reward');
        $this->actingAs($a)->postJson('/api/v1/season/pass/claim', ['level' => 1, 'track' => 'gold'])->assertStatus(422);

        /** @var array<int, array<string, mixed>> $list */
        $list = $this->actingAs($a)->getJson('/api/v1/season')->json('pass.rewards');
        $rewards = [];
        foreach ($list as $r) {
            $rewards[$r['track'].':'.$r['level']] = $r;
        }
        $this->assertSame(['kind' => 'gems', 'amount' => 50, 'claimable' => false], array_intersect_key($rewards['premium:3'], ['kind' => 1, 'amount' => 1, 'claimable' => 1]));
        $this->assertSame(300, $rewards['free:3']['amount']);
        $this->assertArrayNotHasKey('premium:1', $rewards);

        // Claim all: free levels 2 and 3.
        $this->actingAs($a)->postJson('/api/v1/season/pass/claim-all')->assertOk()
            ->assertJsonPath('claimed', 2)->assertJsonPath('wallet.coins', 600);
        $this->assertSame(600, $wallet->balances($a)['coins']);
    }

    public function test_premium_is_bought_once_with_yaqut_and_unlocks_earned_rewards(): void
    {
        $a = User::factory()->create();
        $wallet = app(WalletService::class);
        app(SeasonPassService::class)->addXp($a, 30500);

        $this->actingAs($a)->postJson('/api/v1/season/pass/premium', ['idempotencyKey' => 'premium-key-1'])
            ->assertStatus(422)->assertJsonPath('code', 'insufficient_funds');
        $wallet->credit($a, 'gems', 1000, 'admin', 'test-gems');
        $this->actingAs($a)->postJson('/api/v1/season/pass/premium', ['idempotencyKey' => 'premium-key-1'])->assertOk()
            ->assertJsonPath('pass.premium', true)->assertJsonPath('wallet.gems', 50);
        $this->actingAs($a)->postJson('/api/v1/season/pass/premium', ['idempotencyKey' => 'premium-key-1'])->assertOk()
            ->assertJsonPath('wallet.gems', 50);
        $this->actingAs($a)->postJson('/api/v1/season/pass/premium', ['idempotencyKey' => 'premium-key-2'])
            ->assertStatus(422)->assertJsonPath('code', 'already_owned');
        $this->assertSame(50, $wallet->balances($a)['gems']);

        $this->actingAs($a)->postJson('/api/v1/season/pass/claim', ['level' => 3, 'track' => 'premium'])->assertOk()
            ->assertJsonPath('wallet.gems', 100)->assertJsonPath('wallet.coins', 0);
        $this->assertSame('season_premium', DB::table('wallet_transactions')->where('currency', 'gems')->orderByDesc('id')->value('reason'));
        $this->actingAs($a)->postJson('/api/v1/season/pass/claim', ['level' => 30, 'track' => 'premium'])->assertOk();
        $this->assertTrue(app(StoreService::class)->owns($a, 'board.caspian'));
        $this->actingAs($a)->postJson('/api/v1/season/pass/claim', ['level' => 30, 'track' => 'premium'])
            ->assertStatus(422)->assertJsonPath('code', 'already_claimed');
    }

    public function test_the_premium_track_can_never_grant_coins(): void
    {
        foreach ((array) config('seasons.pass.premium') as $reward) {
            $this->assertNotSame('coins', $reward['kind']);
        }
        $this->expectException(InvalidArgumentException::class);
        app(WalletService::class)->credit(User::factory()->create(), 'coins', 100, 'season_premium', 'x-premium-coins');
    }

    public function test_view_shows_season_end_rewards_and_my_target(): void
    {
        $a = User::factory()->create();
        $a->ratingFor('shortNard')->forceFill(['rating' => 1842])->save();
        $this->actingAs($a)->getJson('/api/v1/season')->assertOk()
            ->assertJsonPath('currentTier', 'platinum')
            ->assertJsonPath('myTarget.tier', 'diamond')
            ->assertJsonPath('myTarget.pointsLeft', 58)
            ->assertJsonPath('endRewards.4.tier', 'diamond')
            ->assertJsonPath('endRewards.4.minRating', 1900)
            ->assertJsonPath('endRewards.4.coins', 2000)
            ->assertJsonPath('endRewards.4.itemId', 'avatar_frame.season_diamond');
    }
}
