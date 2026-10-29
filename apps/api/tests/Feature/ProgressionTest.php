<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\ProgressionService;
use App\Services\WalletService;
use Database\Seeders\ItemCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Illuminate\Testing\TestResponse;
use Symfony\Component\HttpFoundation\Response;
use Tests\TestCase;

class ProgressionTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(ItemCatalogSeeder::class);
        Carbon::setTestNow('2026-11-02 12:00:00');
    }

    /** @return TestResponse<Response> */
    private function report(User $white, ?User $black, string $id, string $winner = 'white', string $kind = 'single', string $mode = 'casual'): TestResponse
    {
        $body = (string) json_encode([
            'matchId' => $id, 'variant' => 'shortNard', 'matchLength' => 1, 'mode' => $mode,
            'white' => ['userId' => (string) $white->id, 'name' => 'W', 'bot' => false],
            'black' => $black === null ? ['userId' => 'bot-1', 'name' => 'Bot', 'bot' => true]
                : ['userId' => (string) $black->id, 'name' => 'B', 'bot' => false],
            'winner' => $winner, 'whiteScore' => $winner === 'white' ? 1 : 0, 'blackScore' => $winner === 'black' ? 1 : 0,
            'reason' => 'completed',
            'games' => [['record' => [], 'winner' => $winner, 'kind' => $kind]],
            'startedAt' => 1767225600000, 'endedAt' => 1767226600000,
        ]);

        return $this->call('POST', '/api/v1/internal/match-results', [], [], [], [
            'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'application/json',
            'HTTP_X_NARD_SIGNATURE' => hash_hmac('sha256', $body, 'test-secret-test-secret-test-secret!'),
        ], $body);
    }

    public function test_matches_reward_coins_and_xp_once(): void
    {
        $a = User::factory()->create();
        $b = User::factory()->create();
        $this->report($a, $b, 'm1', 'white', 'gammon')->assertCreated();
        $this->report($a, $b, 'm1', 'white', 'gammon')->assertCreated();
        $wallet = app(WalletService::class);
        // casual win 30 + mars bonus 10; loser 10.
        $this->assertSame(40, $wallet->balances($a)['coins']);
        $this->assertSame(10, $wallet->balances($b)['coins']);
        $this->assertSame(30, $a->refresh()->xp);
        $this->assertSame(1, $a->refresh()->mars_total);
    }

    public function test_bot_games_pay_less_and_missions_advance(): void
    {
        $a = User::factory()->create();
        foreach (['b1', 'b2', 'b3'] as $id) {
            $this->report($a, null, $id)->assertCreated();
        }
        $progress = $this->actingAs($a)->getJson('/api/v1/me/progress')->assertOk()->json('progress');
        $missions = array_column($progress['missions'], null, 'id');
        $this->assertTrue($missions['daily_play_3']['completed']);
        $this->assertSame(2, $missions['daily_win_2']['progress']);
        $this->assertSame(3, $missions['weekly_play_15']['progress']);
        $this->assertContains('first_win', $progress['achievements']);
        $coins = app(WalletService::class)->balances($a)['coins'];
        $this->assertSame(45, $coins); // 3 × bot win 15
        $this->actingAs($a)->postJson('/api/v1/me/missions/daily_play_3/claim')->assertOk()
            ->assertJsonPath('wallet.coins', 95);
        $this->actingAs($a)->postJson('/api/v1/me/missions/daily_play_3/claim')->assertStatus(422);
        $this->actingAs($a)->postJson('/api/v1/me/missions/daily_mars_1/claim')->assertStatus(422);
        $this->actingAs($a)->postJson('/api/v1/me/missions/nope/claim')->assertStatus(422);
    }

    public function test_levels_need_more_xp_each_time_and_pay_coins(): void
    {
        $this->assertSame(100, ProgressionService::xpForLevel(1));
        $this->assertSame(150, ProgressionService::xpForLevel(2));
        $a = User::factory()->create();
        app(ProgressionService::class)->addXp($a, 260);
        $this->assertSame(3, $a->level);
        // Level 2: 40 coins, level 3: 60 coins.
        $this->assertSame(100, app(WalletService::class)->balances($a)['coins']);
        $p = $this->actingAs($a)->getJson('/api/v1/me/progress')->json('progress');
        $this->assertSame(10, $p['xp']);
        $this->assertSame(200, $p['xpForNext']);
    }

    public function test_login_streak_grows_daily_and_resets_after_a_gap(): void
    {
        $a = User::factory()->create();
        $this->actingAs($a)->postJson('/api/v1/me/checkin')->assertOk()->assertJsonPath('coins', 20)->assertJsonPath('streak', 1);
        $this->actingAs($a)->postJson('/api/v1/me/checkin')->assertOk()->assertJsonPath('coins', 0);
        Carbon::setTestNow('2026-11-03 09:00:00');
        $this->actingAs($a)->postJson('/api/v1/me/checkin')->assertOk()->assertJsonPath('coins', 30)->assertJsonPath('streak', 2);
        Carbon::setTestNow('2026-11-05 09:00:00');
        $this->actingAs($a)->postJson('/api/v1/me/checkin')->assertOk()->assertJsonPath('streak', 1);
        $this->assertSame(2, $a->refresh()->best_streak);
    }

    public function test_titles_come_from_achievements(): void
    {
        $a = User::factory()->create(['wins_total' => 9]);
        $this->actingAs($a)->putJson('/api/v1/me/title', ['itemId' => 'title.regular'])->assertStatus(422);
        $this->report($a, null, 'w10')->assertCreated();
        $this->actingAs($a)->putJson('/api/v1/me/title', ['itemId' => 'title.regular'])->assertOk()->assertJsonPath('title', 'title.regular');
        $this->actingAs($a)->putJson('/api/v1/me/title', ['itemId' => 'board.walnut'])->assertStatus(422);
        $this->actingAs($a)->putJson('/api/v1/me/title', ['itemId' => null])->assertOk();
    }
}
