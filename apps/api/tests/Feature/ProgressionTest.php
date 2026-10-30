<?php

namespace Tests\Feature;

use App\Models\GameMatch;
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
    private function report(User $white, ?User $black, string $id, string $winner = 'white', string $kind = 'single', string $mode = 'casual', string $variant = 'shortNard'): TestResponse
    {
        $body = (string) json_encode([
            'matchId' => $id, 'variant' => $variant, 'matchLength' => 1, 'mode' => $mode,
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
        // 1-point casual: win 150/5 + mars bonus 20; loss 40/5.
        $this->assertSame(50, $wallet->balances($a)['coins']);
        $this->assertSame(8, $wallet->balances($b)['coins']);
        $this->assertSame(26, $a->refresh()->xp);
        $this->assertSame(1, $a->refresh()->mars_total);
    }

    public function test_missions_count_events_from_the_game_records(): void
    {
        $a = User::factory()->create();
        $this->report($a, null, 'b1', variant: 'longNard')->assertCreated();
        $progress = $this->actingAs($a)->getJson('/api/v1/me/progress')->assertOk()->json('progress');
        $missions = array_column($progress['missions'], null, 'id');
        $this->assertTrue($missions['daily_long_play_1']['completed']);
        $this->assertSame(0, $missions['daily_ranked_win_3']['progress']);
        $this->assertSame(1, $missions['weekly_play_15']['progress']);
        $this->assertContains('first_win', $progress['achievements']);
        $this->assertSame(12, app(WalletService::class)->balances($a)['coins']);
        $this->actingAs($a)->postJson('/api/v1/me/missions/daily_long_play_1/claim')->assertOk()
            ->assertJsonPath('wallet.coins', 42);
        $this->actingAs($a)->postJson('/api/v1/me/missions/daily_long_play_1/claim')->assertStatus(422);
        $this->actingAs($a)->postJson('/api/v1/me/missions/daily_doubles_3/claim')->assertStatus(422);
        $this->actingAs($a)->postJson('/api/v1/me/missions/nope/claim')->assertStatus(422);
    }

    public function test_doubles_and_cube_takes_are_read_from_actions(): void
    {
        $match = new GameMatch([
            'variant' => 'shortNard', 'mode' => 'ranked', 'match_length' => 3,
            'games' => [[
                'winner' => 'black', 'kind' => 'single',
                'record' => ['actions' => [
                    ['type' => 'roll', 'by' => 'black', 'd1' => 4, 'd2' => 4],
                    ['type' => 'roll', 'by' => 'white', 'd1' => 6, 'd2' => 6],
                    ['type' => 'roll', 'by' => 'black', 'd1' => 1, 'd2' => 2],
                    ['type' => 'take', 'by' => 'black'],
                ]],
            ]],
        ]);
        $events = ProgressionService::events($match, 'black', true, false);
        $this->assertSame(1, $events['doubles']);
        $this->assertSame(1, $events['cube_take_win']);
        $this->assertSame(1, $events['ranked_win']);
        $this->assertSame(0, ProgressionService::events($match, 'white', false, false)['cube_take_win']);
    }

    public function test_levels_need_more_xp_each_time_and_pay_coins(): void
    {
        $this->assertSame(350, ProgressionService::xpForLevel(1));
        $this->assertSame(1500, ProgressionService::xpForLevel(24));
        $a = User::factory()->create();
        app(ProgressionService::class)->addXp($a, 760);
        $this->assertSame(3, $a->level);
        $this->assertSame(400, app(WalletService::class)->balances($a)['coins']);
        $p = $this->actingAs($a)->getJson('/api/v1/me/progress')->json('progress');
        $this->assertSame(10, $p['xp']);
        $this->assertSame(450, $p['xpForNext']);
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
