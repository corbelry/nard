<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\RatingService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Testing\TestResponse;
use Symfony\Component\HttpFoundation\Response;
use Tests\TestCase;

class MatchResultTest extends TestCase
{
    use RefreshDatabase;

    /**
     * @param  array<string, mixed>  $result
     * @return TestResponse<Response>
     */
    private function report(array $result, ?string $secret = null): TestResponse
    {
        $body = (string) json_encode($result);
        $sig = hash_hmac('sha256', $body, $secret ?? 'test-secret-test-secret-test-secret!');

        return $this->call('POST', '/api/v1/internal/match-results', [], [], [], [
            'CONTENT_TYPE' => 'application/json',
            'HTTP_ACCEPT' => 'application/json',
            'HTTP_X_NARD_SIGNATURE' => $sig,
        ], $body);
    }

    /** @return array<string, mixed> */
    private function payload(User $white, ?User $black, string $mode = 'ranked', string $id = 'm1'): array
    {
        return [
            'matchId' => $id,
            'variant' => 'shortNard',
            'matchLength' => 5,
            'mode' => $mode,
            'white' => ['userId' => (string) $white->id, 'name' => $white->name, 'bot' => false],
            'black' => $black === null
                ? ['userId' => 'bot-1', 'name' => 'Bot', 'bot' => true]
                : ['userId' => (string) $black->id, 'name' => $black->name, 'bot' => false],
            'winner' => 'white',
            'whiteScore' => 5,
            'blackScore' => 2,
            'reason' => 'completed',
            'games' => [['record' => ['version' => 1], 'serverSeed' => 'abc']],
            'startedAt' => 1767225600000,
            'endedAt' => 1767226600000,
        ];
    }

    public function test_results_must_be_signed_by_the_game_server(): void
    {
        $a = User::factory()->create();
        $this->report($this->payload($a, null), 'wrong-secret-wrong-secret-wrong-secret')->assertUnauthorized();
        $bad = $this->payload($a, null);
        $bad['matchLength'] = 4;
        $this->report($bad)->assertUnprocessable();
    }

    public function test_ranked_results_move_ratings_once(): void
    {
        $a = User::factory()->create();
        $b = User::factory()->create();
        $this->report($this->payload($a, $b))->assertCreated();
        // FIBS: equal ratings, 5-point match, new players (factor 5).
        $delta = (int) round(4 * sqrt(5) * 0.5 * 5);
        $this->assertSame(1500 + $delta, $a->ratingFor('shortNard')->rating);
        $this->assertSame(1500 - $delta, $b->ratingFor('shortNard')->rating);
        $this->report($this->payload($a, $b))->assertCreated();
        $this->assertSame(1500 + $delta, $a->ratingFor('shortNard')->fresh()?->rating);

        $token = $a->createToken('t')->plainTextToken;
        $list = $this->withToken($token)->getJson('/api/v1/me/matches')->assertOk()->json('matches');
        $this->assertCount(1, $list);
        $this->assertSame('white', $list[0]['you']);
        $this->assertSame(1500 + $delta, $list[0]['white']['ratingAfter']);
        $this->withToken($token)->getJson('/api/v1/me/matches/m1')->assertOk()
            ->assertJsonPath('match.games.0.serverSeed', 'abc');
        $this->withToken($token)->getJson('/api/v1/me/matches/none')->assertNotFound();
    }

    public function test_casual_and_bot_games_never_change_ratings(): void
    {
        $a = User::factory()->create();
        $b = User::factory()->create();
        $this->report($this->payload($a, $b, 'casual', 'c1'))->assertCreated();
        $this->report($this->payload($a, null, 'ranked', 'c2'))->assertCreated();
        $this->assertSame(1500, $a->ratingFor('shortNard')->rating);
        $this->assertSame(0, $a->ratingFor('shortNard')->matches);
    }

    public function test_fibs_probability_and_experience(): void
    {
        $this->assertEqualsWithDelta(0.5, RatingService::winProbability(1500, 1500, 7), 1e-9);
        $this->assertGreaterThan(0.5, RatingService::winProbability(1700, 1500, 1));
        $this->assertSame(5.0, RatingService::experienceFactor(0));
        $this->assertSame(1.0, RatingService::experienceFactor(1000));
        [$up, $down] = RatingService::changes(1500, 1500, 1, 1000, 1000);
        $this->assertSame(2, $up);
        $this->assertSame(-2, $down);
    }
}
