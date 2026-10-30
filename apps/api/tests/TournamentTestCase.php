<?php

namespace Tests;

use App\Models\Tournament;
use App\Models\TournamentPairing;
use App\Models\User;
use App\Services\WalletService;
use Database\Seeders\ItemCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Client\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Testing\TestResponse;
use Symfony\Component\HttpFoundation\Response;

/** Shared setup for tournament feature tests: a fake game server, signed reports. */
abstract class TournamentTestCase extends TestCase
{
    use RefreshDatabase;

    protected const SECRET = 'test-secret-test-secret-test-secret!';

    /** @var array<int, int> HTTP statuses the fake game server answers next (then 201). */
    protected array $gameServerStatuses = [];

    protected function setUp(): void
    {
        parent::setUp();
        Carbon::setTestNow('2026-11-03 12:00:00');
        config(['nard.game_server_url' => 'http://game.test']);
        Http::fake([
            'game.test/internal/tournament-matches' => fn () => Http::response(['status' => 'assigned'], array_shift($this->gameServerStatuses) ?? 201),
            // Live pushes (ADR-049).
            'game.test/*' => Http::response(['delivered' => 0]),
        ]);
        $this->seed(ItemCatalogSeeder::class);
    }

    protected function player(int $coins = 0, int $rating = 1500, string $variant = 'shortNard'): User
    {
        $user = User::factory()->create();
        if ($coins > 0) {
            app(WalletService::class)->credit($user, 'coins', $coins, 'admin', "seed:{$user->id}");
        }
        $r = $user->ratingFor($variant);
        $r->rating = $rating;
        $r->save();

        return $user;
    }

    /** @param array<string, mixed> $attributes */
    protected function tournament(array $attributes = []): Tournament
    {
        return Tournament::query()->create([
            'name' => ['az' => 'Test Kuboku', 'en' => 'Test Cup'],
            'format' => 'knockout',
            'kind' => 'scheduled',
            'variant' => 'shortNard',
            'match_length' => 3,
            'size' => 64,
            'min_players' => 2,
            'entry_coins' => 0,
            'prizes' => [],
            'prize_fund' => 0,
            'status' => 'registering',
            'starts_at' => now()->addHour(),
            ...$attributes,
        ]);
    }

    /** Runs an artisan command that must succeed. */
    protected function command(string $command): void
    {
        $this->assertSame(0, Artisan::call($command));
    }

    /**
     * Bodies the API posted to the game server's [path], oldest first.
     *
     * @return list<array<string, mixed>>
     */
    protected function posted(string $path): array
    {
        $bodies = [];
        foreach (Http::recorded() as [$request]) {
            /** @var Request $request */
            if ($request->url() === "http://game.test$path") {
                /** @var array<string, mixed> $body */
                $body = (array) json_decode($request->body(), true);
                $bodies[] = $body;
            }
        }

        return $bodies;
    }

    /** @param array<int, User> $users */
    protected function enter(Tournament $t, array $users): void
    {
        foreach ($users as $user) {
            $this->actingAs($user)->postJson("/api/v1/tournaments/{$t->id}/register", ['idempotencyKey' => "entry-key-{$user->id}"])
                ->assertCreated();
        }
    }

    /** @return Collection<int, TournamentPairing> */
    protected function pairings(Tournament $t, int $round): Collection
    {
        return TournamentPairing::query()->where(['tournament_id' => $t->id, 'round' => $round])->orderBy('slot')->get();
    }

    protected function coins(User $user): int
    {
        return (int) DB::table('wallets')->where('user_id', $user->id)->value('coins');
    }

    protected function prizeCoins(User $user): int
    {
        return (int) DB::table('wallet_transactions')->where(['user_id' => $user->id, 'reason' => 'tournament'])->sum('amount');
    }

    /** @return TestResponse<Response> */
    protected function signed(string $path, string $body): TestResponse
    {
        return $this->call('POST', $path, [], [], [], [
            'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'application/json',
            'HTTP_X_NARD_SIGNATURE' => hash_hmac('sha256', $body, self::SECRET),
        ], $body);
    }

    /**
     * The game server's MatchResult for a pairing.
     *
     * @return TestResponse<Response>
     */
    protected function report(TournamentPairing $p, string $winner = 'white', string $reason = 'completed'): TestResponse
    {
        $length = $p->tournament->match_length;
        $walkover = $reason === 'walkover';

        return $this->signed('/api/v1/internal/match-results', (string) json_encode([
            'matchId' => $p->match_id, 'variant' => $p->tournament->variant, 'matchLength' => $length,
            'mode' => 'tournament', 'tournamentId' => (string) $p->tournament_id,
            'white' => ['userId' => (string) $p->white_user_id, 'name' => 'W', 'bot' => false],
            'black' => ['userId' => (string) $p->black_user_id, 'name' => 'B', 'bot' => false],
            'winner' => $winner,
            'whiteScore' => $winner === 'white' ? $length : ($walkover ? 0 : 1),
            'blackScore' => $winner === 'black' ? $length : ($walkover ? 0 : 1),
            'reason' => $reason,
            'games' => $walkover ? [] : [['record' => [], 'winner' => $winner, 'kind' => 'single']],
            'startedAt' => now()->subMinutes(20)->getTimestampMs(), 'endedAt' => now()->getTimestampMs(),
        ]));
    }

    /** @return TestResponse<Response> */
    protected function noShow(TournamentPairing $p): TestResponse
    {
        return $this->signed('/api/v1/internal/tournament-no-shows', (string) json_encode([
            'matchId' => $p->match_id, 'tournamentId' => (string) $p->tournament_id, 'endedAt' => now()->getTimestampMs(),
        ]));
    }

    /** Pushes the game server received for these match ids. */
    protected function assertPushed(string ...$matchIds): void
    {
        foreach ($matchIds as $id) {
            Http::assertSent(fn (Request $r) => $r->url() === 'http://game.test/internal/tournament-matches'
                && $r['matchId'] === $id
                && $r->header('X-Nard-Signature')[0] === hash_hmac('sha256', $r->body(), self::SECRET));
        }
    }
}
