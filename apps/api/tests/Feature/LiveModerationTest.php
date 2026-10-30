<?php

namespace Tests\Feature;

use App\Models\AdminAction;
use App\Models\GameMatch;
use App\Models\Report;
use App\Models\User;
use App\Services\ModerationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use Tests\TestCase;

/** Moderation reaches live game-server sessions (ADR-045). */
class LiveModerationTest extends TestCase
{
    use RefreshDatabase;

    private const SECRET = 'test-secret-test-secret-test-secret!';

    protected function setUp(): void
    {
        parent::setUp();
        config(['nard.game_server_url' => 'http://game.test', 'nard.ticket_secret' => self::SECRET]);
    }

    private function moderation(): ModerationService
    {
        return app(ModerationService::class);
    }

    /** @return list<array<string, mixed>> */
    private function pushes(): array
    {
        $pushes = [];
        foreach (Http::recorded() as [$request]) {
            /** @var Request $request */
            if ($request->url() === 'http://game.test/internal/moderation') {
                /** @var array<string, mixed> $body */
                $body = (array) json_decode($request->body(), true);
                $pushes[] = $body;
            }
        }

        return $pushes;
    }

    public function test_every_moderation_change_pushes_the_whole_state_signed(): void
    {
        Http::fake(['game.test/*' => Http::response(['connected' => true])]);
        $user = User::factory()->create();
        $id = (string) $user->id;

        $this->moderation()->mute($user, now()->addHour(), 'spam', null);
        $this->moderation()->ban($user, null, 'cheating', null);
        $this->moderation()->unban($user, 'appeal', null);
        $this->moderation()->unmute($user, null);
        $user->forceFill(['queue_cooldown_until' => now()->addHours(24)])->save();
        $this->moderation()->clearCooldown($user, null);

        $this->assertSame([
            ['userId' => $id, 'banned' => false, 'muted' => true, 'queueCooldownUntil' => null],
            ['userId' => $id, 'banned' => true, 'muted' => true, 'queueCooldownUntil' => null],
            ['userId' => $id, 'banned' => false, 'muted' => true, 'queueCooldownUntil' => null],
            ['userId' => $id, 'banned' => false, 'muted' => false, 'queueCooldownUntil' => null],
            ['userId' => $id, 'banned' => false, 'muted' => false, 'queueCooldownUntil' => null],
        ], $this->pushes());
        Http::assertSent(fn (Request $r) => $r->hasHeader('X-Nard-Signature', hash_hmac('sha256', $r->body(), self::SECRET))
            && $r->method() === 'POST');
        // Warnings and other writes do not touch live sessions.
        $this->moderation()->warn($user, 'be nice', null);
        $this->assertCount(5, $this->pushes());
    }

    public function test_handled_reports_push_after_the_transaction(): void
    {
        Http::fake(['game.test/*' => Http::response(['connected' => false])]);
        [$reporter, $target] = User::factory()->count(2)->create()->all();
        $report = Report::query()->create(['reporter_id' => $reporter->id, 'reported_id' => $target->id, 'reason' => 'abuse']);

        $this->moderation()->handleReport($report, 'ban', 'abusive chat', 48, null);

        $push = $this->pushes()[0] ?? null;
        $this->assertNotNull($push);
        $this->assertSame([(string) $target->id, true], [$push['userId'], $push['banned']]);
    }

    public function test_an_unreachable_game_server_never_fails_the_admin_action(): void
    {
        Http::fake(fn () => throw new ConnectionException('Connection refused'));
        $user = User::factory()->create();

        $this->moderation()->ban($user, null, 'cheating', null);
        $this->moderation()->mute($user, now()->addHour(), 'spam', null);

        $this->assertTrue($this->reload($user)->isBanned());
        $this->assertTrue($this->reload($user)->isMuted());
        $this->assertSame(['ban', 'mute'], AdminAction::query()->orderBy('id')->pluck('action')->all());

        // A refusal (e.g. a bad signature) is logged, not thrown.
        Http::fake(['game.test/*' => Http::response(['code' => 'bad_signature'], 401)]);
        $this->moderation()->unmute($user, null);
        $this->assertFalse($this->reload($user)->isMuted());
    }

    public function test_nothing_is_sent_without_a_game_server_url(): void
    {
        Http::fake();
        config(['nard.game_server_url' => '']);
        $this->moderation()->ban(User::factory()->create(), null, 'cheating', null);
        Http::assertNothingSent();
    }

    public function test_the_abandonment_cooldown_reaches_the_live_session(): void
    {
        Http::fake(['game.test/*' => Http::response(['connected' => true])]);
        [$quitter, $fair] = User::factory()->count(2)->create()->all();
        for ($i = 0; $i < 10; $i++) {
            GameMatch::query()->create([
                'id' => (string) Str::uuid(), 'variant' => 'shortNard', 'match_length' => 1, 'mode' => 'ranked',
                'white_user_id' => $quitter->id, 'black_user_id' => $fair->id,
                'white_name' => $quitter->name, 'black_name' => $fair->name,
                'winner' => 'black', 'white_score' => 0, 'black_score' => 1,
                'reason' => $i < 4 ? 'abandoned' : 'completed', 'games' => [],
                'started_at' => now()->subMinutes(10), 'ended_at' => now(),
            ]);
        }

        $this->runCommand('anticheat:scan', ['--skip-engine' => true])->assertSuccessful();

        $until = $this->reload($quitter)->queue_cooldown_until;
        $this->assertNotNull($until);
        $this->assertSame([
            ['userId' => (string) $quitter->id, 'banned' => false, 'muted' => false, 'queueCooldownUntil' => $until->getTimestamp()],
        ], $this->pushes());
    }

    public function test_the_abandonment_scan_survives_an_unreachable_game_server(): void
    {
        Http::fake(fn () => throw new ConnectionException('Connection refused'));
        [$quitter, $fair] = User::factory()->count(2)->create()->all();
        for ($i = 0; $i < 10; $i++) {
            GameMatch::query()->create([
                'id' => (string) Str::uuid(), 'variant' => 'shortNard', 'match_length' => 1, 'mode' => 'ranked',
                'white_user_id' => $quitter->id, 'black_user_id' => $fair->id,
                'white_name' => $quitter->name, 'black_name' => $fair->name,
                'winner' => 'black', 'white_score' => 0, 'black_score' => 1,
                'reason' => 'abandoned', 'games' => [],
                'started_at' => now()->subMinutes(10), 'ended_at' => now(),
            ]);
        }

        $this->runCommand('anticheat:scan', ['--skip-engine' => true])
            ->expectsOutputToContain('abandonment: 1 new flag(s)')->assertSuccessful();
        $this->assertNotNull($this->reload($quitter)->queue_cooldown_until);
    }
}
