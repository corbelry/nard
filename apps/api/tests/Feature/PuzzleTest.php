<?php

namespace Tests\Feature;

use App\Models\Puzzle;
use App\Models\User;
use App\Services\PuzzleService;
use Database\Seeders\PuzzleSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Illuminate\Testing\TestResponse;
use Symfony\Component\HttpFoundation\Response;
use Tests\TestCase;

class PuzzleTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(PuzzleSeeder::class);
        Carbon::setTestNow('2026-11-04 12:00:00');
    }

    /**
     * @param  array<string, mixed>  $board
     * @return TestResponse<Response>
     */
    private function attempt(User $user, string $id, int $attempt, array $board): TestResponse
    {
        return $this->actingAs($user)->postJson("/api/v1/puzzles/$id/attempt", ['attempt' => $attempt, 'board' => $board, 'moves' => '24/18 13/9']);
    }

    /**
     * The solution's board with keys as strings and in another order, as a
     * client would send it.
     *
     * @return array<string, mixed>
     */
    private function solved(Puzzle $p): array
    {
        return array_map(fn ($side) => array_reverse(array_combine(array_map('strval', array_keys($side)), $side), true), $p->result_board);
    }

    public function test_the_seeded_puzzles_are_consistent(): void
    {
        $this->assertSame(30, Puzzle::query()->count());
        foreach (Puzzle::query()->get() as $p) {
            $this->assertContains($p->variant, ['shortNard', 'longNard']);
            $this->assertNotNull(PuzzleService::normalize($p->board), $p->id);
            $this->assertNotSame(PuzzleService::normalize($p->board), PuzzleService::normalize($p->result_board), $p->id);
            $this->assertCount(2, $p->dice);
        }
    }

    public function test_next_picks_the_closest_rating_and_hides_the_solution(): void
    {
        $user = User::factory()->create();
        $json = $this->actingAs($user)->getJson('/api/v1/puzzles/next')->assertOk()
            ->assertJsonPath('rating', 1500)->assertJsonPath('solved', 0)->assertJsonPath('total', 30)
            ->assertJsonPath('puzzle.attemptsUsed', 0)->json('puzzle');
        $closest = Puzzle::query()->orderByRaw('ABS(rating - 1500)')->orderBy('id')->firstOrFail();
        $this->assertSame($closest->id, $json['id']);
        $this->assertArrayNotHasKey('solution', $json);
        $this->assertArrayNotHasKey('result_board', $json);
        $this->assertArrayHasKey('board', $json);
        $long = $this->actingAs($user)->getJson('/api/v1/puzzles/next?variant=longNard')->assertOk()->json('puzzle');
        $this->assertSame('longNard', $long['variant']);
    }

    public function test_wrong_then_right_on_the_second_attempt(): void
    {
        $user = User::factory()->create();
        $p = Puzzle::query()->findOrFail('sn-001');
        $this->attempt($user, $p->id, 1, $p->board)->assertOk()
            ->assertJsonPath('correct', false)->assertJsonPath('finished', false)
            ->assertJsonPath('attemptsLeft', 1)->assertJsonPath('ratingDelta', -8)
            ->assertJsonPath('rating', 1492)->assertJsonPath('solution', null);
        // A retried request returns the recorded result.
        $this->attempt($user, $p->id, 1, $this->solved($p))->assertOk()->assertJsonPath('correct', false)->assertJsonPath('rating', 1492);
        // The unfinished puzzle comes back first.
        $this->actingAs($user)->getJson('/api/v1/puzzles/next')->assertJsonPath('puzzle.id', 'sn-001')->assertJsonPath('puzzle.attemptsUsed', 1);
        $this->attempt($user, $p->id, 2, $this->solved($p))->assertOk()
            ->assertJsonPath('correct', true)->assertJsonPath('finished', true)
            ->assertJsonPath('ratingDelta', 6)->assertJsonPath('rating', 1498)
            ->assertJsonPath('solution.moves', $p->solution)
            ->assertJsonPath('solution.secondBest.moves', $p->second_best['moves'] ?? null);
        $this->attempt($user, $p->id, 3, $p->board)->assertStatus(422);
        $this->assertNotSame('sn-001', $this->actingAs($user)->getJson('/api/v1/puzzles/next')->json('puzzle.id'));
    }

    public function test_first_try_scores_more_and_a_finished_puzzle_refuses_attempts(): void
    {
        $user = User::factory()->create();
        $p = Puzzle::query()->findOrFail('ln-002');
        $this->attempt($user, $p->id, 2, $this->solved($p))->assertStatus(422)->assertJsonPath('code', 'bad_attempt');
        $this->attempt($user, $p->id, 1, $this->solved($p))->assertOk()
            ->assertJsonPath('correct', true)->assertJsonPath('ratingDelta', 12)->assertJsonPath('rating', 1512);
        $this->attempt($user, $p->id, 2, $p->board)->assertStatus(422)->assertJsonPath('code', 'finished');
        $this->assertSame(1512, $user->refresh()->puzzle_rating);
    }

    public function test_two_wrong_attempts_finish_the_puzzle_and_reveal_the_solution(): void
    {
        $user = User::factory()->create();
        $p = Puzzle::query()->findOrFail('sn-002');
        $this->attempt($user, $p->id, 1, $p->board)->assertOk();
        $this->attempt($user, $p->id, 2, $p->board)->assertOk()
            ->assertJsonPath('finished', true)->assertJsonPath('attemptsLeft', 0)
            ->assertJsonPath('ratingDelta', -4)->assertJsonPath('rating', 1488)
            ->assertJsonPath('solution.moves', $p->solution);
    }

    public function test_reveal_counts_as_a_failed_attempt(): void
    {
        $user = User::factory()->create();
        $p = Puzzle::query()->findOrFail('sn-003');
        $this->actingAs($user)->postJson("/api/v1/puzzles/{$p->id}/reveal")->assertOk()
            ->assertJsonPath('finished', true)->assertJsonPath('ratingDelta', -8)
            ->assertJsonPath('solution.moves', $p->solution);
        // Revealing again costs nothing.
        $this->actingAs($user)->postJson("/api/v1/puzzles/{$p->id}/reveal")->assertOk()->assertJsonPath('rating', 1492);
        $this->attempt($user, $p->id, 2, $this->solved($p))->assertStatus(422)->assertJsonPath('code', 'finished');
        $this->actingAs($user)->postJson('/api/v1/puzzles/nope-1/reveal')->assertNotFound();
    }

    public function test_bad_boards_are_refused(): void
    {
        $user = User::factory()->create();
        $this->attempt($user, 'sn-001', 1, ['white' => ['24' => 16], 'black' => []])->assertStatus(422)->assertJsonPath('code', 'bad_board');
        $this->attempt($user, 'sn-001', 1, ['white' => ['26' => 1], 'black' => []])->assertStatus(422)->assertJsonPath('code', 'bad_board');
        $this->attempt($user, 'sn-001', 1, ['white' => []])->assertStatus(422);
        $this->attempt($user, 'zz-999', 1, ['white' => [], 'black' => []])->assertNotFound();
    }

    public function test_solved_puzzles_advance_the_daily_mission(): void
    {
        $user = User::factory()->create();
        foreach (['sn-004', 'sn-005'] as $id) {
            $p = Puzzle::query()->findOrFail($id);
            $this->attempt($user, $id, 1, $this->solved($p))->assertOk()->assertJsonPath('correct', true);
        }
        /** @var array<int, array<string, mixed>> $list */
        $list = $this->actingAs($user)->getJson('/api/v1/me/progress')->json('progress.missions');
        $missions = array_column($list, null, 'id');
        $this->assertSame(2, $missions['daily_puzzle_2']['progress']);
        $this->assertTrue($missions['daily_puzzle_2']['completed']);
        $this->actingAs($user)->postJson('/api/v1/me/missions/daily_puzzle_2/claim')->assertOk()->assertJsonPath('wallet.coins', 30);
        $this->actingAs($user)->getJson('/api/v1/puzzles/next')->assertJsonPath('solved', 2);
    }

    public function test_the_daily_puzzle_is_the_same_for_everyone_on_a_day(): void
    {
        $a = User::factory()->create();
        $b = User::factory()->create();
        $first = $this->actingAs($a)->getJson('/api/v1/puzzles/daily')->assertOk()->assertJsonPath('date', '2026-11-04')->json('puzzle.id');
        $this->assertSame($first, $this->actingAs($b)->getJson('/api/v1/puzzles/daily')->json('puzzle.id'));
        $ids = [];
        for ($d = 0; $d < 10; $d++) {
            $ids[] = app(PuzzleService::class)->daily(Carbon::parse('2026-11-04')->addDays($d))?->id;
        }
        $this->assertGreaterThan(1, count(array_unique($ids)));
    }
}
