<?php

namespace Tests\Feature;

use App\Jobs\PushLiveNotifications;
use App\Models\User;
use App\Services\Notifier;
use App\Services\SeasonService;
use Database\Seeders\ItemCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Queue;
use Mockery;
use Tests\TestCase;

/** Inbox rows reach open sockets through the game server (ADR-049). */
class LiveNotificationTest extends TestCase
{
    use RefreshDatabase;

    private const SECRET = 'test-secret-test-secret-test-secret!';

    protected function setUp(): void
    {
        parent::setUp();
        config(['nard.game_server_url' => 'http://game.test', 'nard.ticket_secret' => self::SECRET]);
    }

    private function notifier(): Notifier
    {
        return app(Notifier::class);
    }

    /** @return list<array{userId: string, notification: array<string, mixed>}> */
    private function pushed(): array
    {
        $items = [];
        foreach (Http::recorded() as [$request]) {
            /** @var Request $request */
            if ($request->url() === 'http://game.test/internal/notify') {
                /** @var array{notifications: list<array{userId: string, notification: array<string, mixed>}>} $body */
                $body = json_decode($request->body(), true);
                array_push($items, ...$body['notifications']);
            }
        }

        return $items;
    }

    public function test_a_new_row_is_pushed_signed_as_the_inbox_shows_it(): void
    {
        Http::fake(['game.test/*' => Http::response(['delivered' => 1])]);
        $a = User::factory()->create();
        $b = User::factory()->create();
        $this->actingAs($a)->postJson('/api/v1/friends/requests', ['userId' => (string) $b->id])->assertCreated();

        $inbox = $this->actingAs($b)->getJson('/api/v1/notifications')->json('notifications');
        $this->assertSame([['userId' => (string) $b->id, 'notification' => $inbox[0]]], $this->pushed());
        $this->assertSame('friend_request', $inbox[0]['type']);
        $this->assertSame($a->name, $inbox[0]['from']['name']);
        Http::assertSent(fn (Request $r) => $r->url() === 'http://game.test/internal/notify'
            && $r->hasHeader('X-Nard-Signature', hash_hmac('sha256', $r->body(), self::SECRET)));
    }

    public function test_rows_are_pushed_after_the_commit_and_never_for_a_rollback(): void
    {
        Http::fake(['game.test/*' => Http::response(['delivered' => 1])]);
        $u = User::factory()->create();
        DB::transaction(function () use ($u): void {
            $this->notifier()->notify($u, 'level_up', ['level' => 2, 'coins' => 50], 'level_up:2');
            $this->assertSame([], $this->pushed(), 'not before the commit');
        });
        $this->assertCount(1, $this->pushed());

        try {
            DB::transaction(function () use ($u): void {
                $this->notifier()->notify($u, 'level_up', ['level' => 3, 'coins' => 50], 'level_up:3');
                throw new \RuntimeException('rolled back');
            });
        } catch (\RuntimeException) {
        }
        $this->assertCount(1, $this->pushed());
        $this->assertSame(1, DB::table('notifications')->count());
    }

    public function test_one_event_for_many_players_is_one_request_and_duplicates_are_not_resent(): void
    {
        Http::fake(['game.test/*' => Http::response(['delivered' => 3])]);
        $users = User::factory()->count(3)->create();
        $ids = $users->pluck('id')->map(fn ($id) => (int) $id);
        $this->assertSame(3, $this->notifier()->notifyMany($ids, 'clan_war', ['opponent' => 'X'], 'clan_war:1'));
        $this->assertSame(0, $this->notifier()->notifyMany($ids, 'clan_war', ['opponent' => 'X'], 'clan_war:1'));
        Http::assertSentCount(1);
        $this->assertSame($ids->map(fn ($id) => (string) $id)->all(), array_column($this->pushed(), 'userId'));
    }

    public function test_blocked_senders_and_missing_game_servers_push_nothing(): void
    {
        Http::fake();
        $a = User::factory()->create();
        $b = User::factory()->create();
        DB::table('blocks')->insert(['blocker_id' => $b->id, 'blocked_id' => $a->id, 'created_at' => now()]);
        $this->assertNull($this->notifier()->notify($b, 'friend_accepted', [], 'x', $a->id));
        Http::assertNothingSent();

        Queue::fake();
        config(['nard.game_server_url' => '']);
        $this->notifier()->notify($b, 'level_up', ['level' => 2, 'coins' => 50]);
        Queue::assertNotPushed(PushLiveNotifications::class);
        $this->assertSame(1, DB::table('notifications')->where('user_id', $b->id)->count());
    }

    public function test_a_game_server_failure_is_logged_and_never_fails_the_action(): void
    {
        Http::fake(fn () => throw new ConnectionException('Connection refused'));
        Log::spy();
        $a = User::factory()->create();
        $b = User::factory()->create();
        $this->actingAs($a)->postJson('/api/v1/friends/requests', ['userId' => (string) $b->id])->assertCreated();
        Log::getFacadeRoot()->shouldHaveReceived('warning')->with('notify push failed', Mockery::type('array'))->once();
        $this->assertSame(1, DB::table('notifications')->where('user_id', $b->id)->count());
    }

    public function test_season_end_carries_the_rank_and_the_next_season_is_announced(): void
    {
        Http::fake(['game.test/*' => Http::response(['delivered' => 0])]);
        $this->seed(ItemCatalogSeeder::class);
        Carbon::setTestNow('2026-11-04 12:00:00');
        config(['seasons.min_matches' => 2]);
        $seasons = app(SeasonService::class);
        $seasons->current();
        $rated = function (string $variant, int $rating, int $matches, ?User $u = null): User {
            $u ??= User::factory()->create();
            $u->ratingFor($variant)->forceFill(['rating' => $rating, 'season_matches' => $matches, 'season_start_rating' => 1500])->save();

            return $u;
        };
        $a = $rated('shortNard', 1950, 3);
        $b = $rated('shortNard', 1600, 2);
        $rated('longNard', 2150, 4, $b);
        $casual = $rated('shortNard', 1500, 1);     // played, not ranked
        $idle = User::factory()->create();          // never played

        Carbon::setTestNow('2026-12-16 00:05:00');
        $this->assertSame(1, $seasons->roll());

        /** @return array<string, mixed>|null */
        $data = fn (User $u, string $type): ?array => json_decode((string) DB::table('notifications')
            ->where(['user_id' => $u->id, 'type' => $type])->value('data'), true);
        $this->assertSame(['season' => 1, 'tier' => 'diamond', 'coins' => 2000, 'itemId' => 'avatar_frame.season_diamond',
            'rank' => 1, 'variant' => 'shortNard'], $data($a, 'season_end'));
        // b's best tier came from Long Nard, where b ranks first.
        $this->assertSame([1, 'longNard'], [$data($b, 'season_end')['rank'] ?? null, $data($b, 'season_end')['variant'] ?? null]);
        $this->assertNull($data($casual, 'season_end'));

        $started = $data($casual, 'season_started') ?? [];
        $this->assertSame(2, $started['season']);
        $this->assertSame('2027-01-27T00:00:00+00:00', $started['endsAt']);
        $this->assertArrayHasKey('az', $started['name']);
        $this->assertNotNull($data($a, 'season_started'));
        $this->assertNull($data($idle, 'season_started'));
        $this->assertSame(['rewards', 'rewards'], [Notifier::category('season_end'), Notifier::category('season_started')]);

        // Push copy carries the rank and reward.
        $row = DB::table('notifications')->where(['user_id' => $a->id, 'type' => 'season_end'])->sole();
        $this->assertSame(['Season 1 is over', 'Your tier: Diamond, rank #1. Reward: 2000 coins.'], $this->notifier()->copy($row, 'en'));
        $row = DB::table('notifications')->where(['user_id' => $a->id, 'type' => 'season_started'])->sole();
        $this->assertSame('Сезон 2 начался', $this->notifier()->copy($row, 'ru')[0]);
        $types = array_column(array_column($this->pushed(), 'notification'), 'type');
        $this->assertContains('season_started', $types);
        $this->assertContains('season_end', $types);
    }
}
