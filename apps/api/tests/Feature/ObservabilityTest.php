<?php

namespace Tests\Feature;

use App\Logging\JsonLineFormatter;
use App\Logging\SentryHandler;
use App\Models\CheatFlag;
use App\Models\GameMatch;
use App\Models\Report;
use App\Models\User;
use DateTimeImmutable;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Client\Request as ClientRequest;
use Illuminate\Log\Logger;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Redis;
use Illuminate\Support\Str;
use Monolog\Handler\StreamHandler;
use Monolog\Level;
use Monolog\LogRecord;
use RuntimeException;
use Tests\TestCase;

/** Metrics, readiness and structured logs (ADR-043). */
class ObservabilityTest extends TestCase
{
    use RefreshDatabase;

    private function match(string $mode, string $endedAt): void
    {
        $white = User::factory()->create();
        $black = User::factory()->create();
        GameMatch::query()->create([
            'id' => (string) Str::uuid(), 'variant' => 'shortNard', 'match_length' => 1, 'mode' => $mode,
            'white_user_id' => $white->id, 'black_user_id' => $black->id,
            'white_name' => $white->name, 'black_name' => $black->name,
            'winner' => 'white', 'white_score' => 1, 'black_score' => 0, 'reason' => 'completed', 'games' => [],
            'started_at' => now()->parse($endedAt)->subMinutes(10), 'ended_at' => now()->parse($endedAt),
        ]);
    }

    /** @return array<string, float> sample (name plus labels) → value */
    private function scrape(): array
    {
        $res = $this->withToken('metrics-token-for-tests')->get('/api/v1/internal/metrics')->assertOk();
        $this->assertStringStartsWith('text/plain; version=0.0.4', (string) $res->headers->get('Content-Type'));
        $samples = [];
        foreach (explode("\n", trim((string) $res->getContent())) as $line) {
            if ($line !== '' && $line[0] !== '#') {
                $at = (int) strrpos($line, ' ');
                $samples[substr($line, 0, $at)] = (float) substr($line, $at + 1);
            }
        }

        return $samples;
    }

    public function test_metrics_need_the_bearer_token_and_are_off_without_one(): void
    {
        config(['observability.metrics_token' => '']);
        $this->get('/api/v1/internal/metrics')->assertNotFound();
        config(['observability.metrics_token' => 'metrics-token-for-tests']);
        $this->get('/api/v1/internal/metrics')->assertUnauthorized();
        $this->withToken('wrong')->get('/api/v1/internal/metrics')->assertUnauthorized();
        $this->withToken('metrics-token-for-tests')->get('/api/v1/internal/metrics')->assertOk();
    }

    public function test_metrics_expose_users_matches_queues_reports_and_flags(): void
    {
        config(['observability.metrics_token' => 'metrics-token-for-tests']);
        $this->match('ranked', '-2 hours');
        $this->match('ranked', '-23 hours');
        $this->match('casual', '-1 hour');
        $this->match('casual', '-25 hours');
        User::query()->update(['is_guest' => false]);
        User::factory()->count(2)->create(['is_guest' => true]);
        DB::table('jobs')->insert([
            ['queue' => 'default', 'payload' => '{}', 'attempts' => 0, 'available_at' => time(), 'created_at' => time()],
            ['queue' => 'push', 'payload' => '{}', 'attempts' => 0, 'available_at' => time(), 'created_at' => time()],
        ]);
        DB::table('failed_jobs')->insert([
            'uuid' => (string) Str::uuid(), 'connection' => 'database', 'queue' => 'default',
            'payload' => '{}', 'exception' => 'boom', 'failed_at' => now(),
        ]);
        [$a, $b] = User::query()->orderBy('id')->take(2)->get()->all();
        Report::query()->create(['reporter_id' => $a->id, 'reported_id' => $b->id, 'reason' => 'abuse']);
        Report::query()->create(['reporter_id' => $a->id, 'reported_id' => $b->id, 'reason' => 'spam', 'status' => 'actioned']);
        CheatFlag::query()->create(['user_id' => $a->id, 'kind' => 'engine', 'score' => 1, 'details' => []]);
        CheatFlag::query()->create(['user_id' => $b->id, 'kind' => 'engine', 'score' => 1, 'details' => [], 'status' => 'dismissed']);

        $m = $this->scrape();
        $this->assertSame(8.0, $m['nard_api_users{kind="member"}']);
        $this->assertSame(2.0, $m['nard_api_users{kind="guest"}']);
        $this->assertSame(2.0, $m['nard_api_matches_last_24h{mode="ranked"}']);
        $this->assertSame(1.0, $m['nard_api_matches_last_24h{mode="casual"}']);
        $this->assertSame(0.0, $m['nard_api_matches_last_24h{mode="tournament"}']);
        $this->assertSame(1.0, $m['nard_api_queue_jobs{queue="default"}']);
        $this->assertSame(1.0, $m['nard_api_queue_jobs{queue="push"}']);
        $this->assertSame(1.0, $m['nard_api_failed_jobs']);
        $this->assertSame(1.0, $m['nard_api_reports_open']);
        $this->assertSame(1.0, $m['nard_api_cheat_flags_open{kind="engine"}']);
        $this->assertSame(0.0, $m['nard_api_cheat_flags_open{kind="abandonment"}']);
    }

    public function test_readiness_checks_the_database_and_redis(): void
    {
        Redis::shouldReceive('connection->ping')->once()->andReturn(true);
        $this->get('/readyz')->assertOk()
            ->assertExactJson(['status' => 'ready', 'checks' => ['database' => 'ok', 'redis' => 'ok']]);

        Redis::shouldReceive('connection->ping')->once()->andThrow(new RuntimeException('Connection refused'));
        $this->get('/readyz')->assertStatus(503)
            ->assertExactJson(['status' => 'not_ready', 'checks' => ['database' => 'ok', 'redis' => 'fail']]);

        // An unreachable database; the default connection is restored so
        // RefreshDatabase rolls back the real one.
        $default = config('database.default');
        config(['observability.readiness_checks' => ['database'], 'database.connections.broken' => [
            'driver' => 'sqlite', 'database' => '/nonexistent/dir/db.sqlite',
        ], 'database.default' => 'broken']);
        try {
            $this->get('/readyz')->assertStatus(503)->assertJsonPath('checks.database', 'fail');
        } finally {
            config(['database.default' => $default]);
        }
    }

    public function test_liveness_stays_up(): void
    {
        $this->get('/up')->assertOk();
    }

    /** @param array<string, mixed> $context */
    private function record(Level $level, string $message, array $context = []): LogRecord
    {
        return new LogRecord(new DateTimeImmutable('2026-11-07 14:00:00.123', new \DateTimeZone('Asia/Baku')), 'production', $level, $message, $context);
    }

    public function test_json_log_lines_have_level_ts_msg_and_fields(): void
    {
        $line = (new JsonLineFormatter)->format($this->record(Level::Warning, 'result rejected', [
            'matchId' => 'm1', 'msg' => 'ignored', 'exception' => new RuntimeException('boom'),
        ]));
        $this->assertStringEndsWith("\n", $line);
        $this->assertStringNotContainsString("\n", rtrim($line));
        $json = json_decode($line, true);
        $this->assertIsArray($json);
        $this->assertSame(['level', 'ts', 'msg', 'channel', 'matchId', 'exception'], array_keys($json));
        $this->assertSame(['warning', '2026-11-07T10:00:00.123Z', 'result rejected', 'production', 'm1'],
            [$json['level'], $json['ts'], $json['msg'], $json['channel'], $json['matchId']]);
        $this->assertSame(RuntimeException::class, $json['exception']['class']);
    }

    public function test_the_json_channel_writes_through_the_formatter(): void
    {
        $logger = logger()->channel('json');
        $this->assertInstanceOf(Logger::class, $logger);
        $monolog = $logger->getLogger();
        $this->assertInstanceOf(\Monolog\Logger::class, $monolog);
        $handler = $monolog->getHandlers()[0];
        $this->assertInstanceOf(StreamHandler::class, $handler);
        $this->assertInstanceOf(JsonLineFormatter::class, $handler->getFormatter());
    }

    public function test_sentry_handler_posts_errors_only_when_a_dsn_is_set(): void
    {
        Http::fake(['*' => Http::response('{}')]);
        $off = new SentryHandler(null);
        $this->assertFalse($off->enabled());
        $off->handle($this->record(Level::Error, 'ignored'));
        Http::assertNothingSent();

        $on = new SentryHandler('https://pubkey@o1.ingest.example.com/42', 'staging');
        $this->assertTrue($on->enabled());
        $on->handle($this->record(Level::Info, 'below the level'));
        $on->handle($this->record(Level::Error, 'payment webhook failed', ['exception' => new RuntimeException('boom'), 'orderId' => 7]));
        Http::assertSentCount(1);
        Http::assertSent(function (ClientRequest $req): bool {
            $body = $req->data();

            return $req->url() === 'https://o1.ingest.example.com/api/42/store/'
                && str_contains($req->header('X-Sentry-Auth')[0] ?? '', 'sentry_key=pubkey')
                && $body['environment'] === 'staging'
                && $body['exception']['values'][0]['type'] === RuntimeException::class
                && $body['extra']['orderId'] === 7;
        });

        // A broken endpoint never throws into the caller.
        Http::fake(fn () => throw new RuntimeException('network down'));
        $on->handle($this->record(Level::Critical, 'still fine'));
        $this->assertFalse((new SentryHandler('not a dsn'))->enabled());
    }
}
