<?php

namespace Tests\Feature;

use App\Models\CheatFlag;
use App\Models\GameMatch;
use App\Models\User;
use App\Services\AntiCheatService;
use App\Services\ModerationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Process\PendingProcess;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Process;
use Illuminate\Support\Str;
use Tests\TestCase;

/** Fair-play signals from `anticheat:scan` (spec §8.14, ADR-042). */
class AntiCheatTest extends TestCase
{
    use RefreshDatabase;

    /** @param array<int, array<string, mixed>> $games */
    private function match(User $white, User $black, string $winner, string $reason = 'completed', string $mode = 'ranked', array $games = [], ?string $endedAt = null): GameMatch
    {
        $ended = $endedAt === null ? now() : now()->parse($endedAt);

        return GameMatch::query()->create([
            'id' => (string) Str::uuid(), 'variant' => 'shortNard', 'match_length' => 1, 'mode' => $mode,
            'white_user_id' => $white->id, 'black_user_id' => $black->id,
            'white_name' => $white->name, 'black_name' => $black->name,
            'winner' => $winner, 'white_score' => $winner === 'white' ? 1 : 0, 'black_score' => $winner === 'black' ? 1 : 0,
            'reason' => $reason, 'games' => $games,
            'started_at' => $ended->copy()->subMinutes(10), 'ended_at' => $ended,
        ]);
    }

    /** The fixture with {A}..{D} replaced by real user ids, as a temp file. */
    private function engineFixture(User $a, User $b, User $c, User $d): string
    {
        $text = strtr((string) file_get_contents(base_path('tests/Fixtures/move_quality.jsonl')), [
            '{A}' => (string) $a->id, '{B}' => (string) $b->id, '{C}' => (string) $c->id, '{D}' => (string) $d->id,
        ]);
        $path = (string) tempnam(sys_get_temp_dir(), 'mq');
        file_put_contents($path, $text);

        return $path;
    }

    public function test_engine_agreement_far_above_the_rating_band_is_flagged(): void
    {
        [$a, $b, $c, $d] = User::factory()->count(4)->create()->all();
        $d->ratingFor('shortNard')->update(['rating' => 2100]);
        $path = $this->engineFixture($a, $b, $c, $d);

        $this->runCommand('anticheat:scan', ['--engine' => $path])->expectsOutputToContain('engine: 1 new flag(s)')->assertSuccessful();
        $flag = CheatFlag::query()->sole();
        $this->assertSame([$a->id, 'engine', 'open'], [$flag->user_id, $flag->kind, $flag->status]);
        $this->assertSame(0.92, $flag->details['agreement']);
        $this->assertSame(0.6, $flag->details['expected']);
        $this->assertSame(420, $flag->details['decisions']);
        $this->assertEqualsWithDelta(0.32, $flag->score, 0.0001);
        // B is within the band, C has too few games, D (2100) is strong enough.
        // A second run refreshes the open flag instead of adding one.
        $this->runCommand('anticheat:scan', ['--engine' => $path])->expectsOutputToContain('engine: 0 new flag(s)')->assertSuccessful();
        $this->assertSame(1, CheatFlag::query()->count());
        $this->runCommand('anticheat:scan', ['--engine' => '/nope.jsonl'])->assertFailed();
        unlink($path);
    }

    public function test_the_scan_pipes_exported_matches_through_the_move_quality_tool(): void
    {
        [$a, $b, $c, $d] = User::factory()->count(4)->create()->all();
        $d->ratingFor('shortNard')->update(['rating' => 2100]);
        $this->match($a, $b, 'white', games: [['record' => ['version' => 1, 'actions' => []], 'serverSeed' => 's']]);
        $this->match($a, $b, 'white', mode: 'casual');
        $path = $this->engineFixture($a, $b, $c, $d);
        config(['fairplay.engine.command' => 'move-quality']);
        Process::fake(['*' => Process::result(output: (string) file_get_contents($path))]);

        $this->runCommand('anticheat:scan')->expectsOutputToContain('analysed 1 match(es)')->expectsOutputToContain('engine: 1 new flag(s)')->assertSuccessful();
        Process::assertRan(fn (PendingProcess $process): bool => $process->command === 'move-quality');
        $this->assertSame([$a->id], CheatFlag::query()->where('kind', 'engine')->pluck('user_id')->all());

        // Without the tool the engine check is skipped, the others still run.
        config(['fairplay.engine.command' => null]);
        $this->runCommand('anticheat:scan')->expectsOutputToContain('engine: skipped')->assertSuccessful();
        unlink($path);
    }

    public function test_export_writes_ranked_human_matches_as_json_lines(): void
    {
        [$a, $b] = User::factory()->count(2)->create()->all();
        $games = [['record' => ['version' => 1, 'variant' => 'shortNard', 'actions' => []], 'serverSeed' => 'abc']];
        $ranked = $this->match($a, $b, 'black', games: $games);
        $this->match($a, $b, 'white', mode: 'casual');
        $this->match($a, $b, 'white', endedAt: now()->subDays(40)->toDateTimeString());
        $path = (string) tempnam(sys_get_temp_dir(), 'mx');
        $this->runCommand('anticheat:export', ['path' => $path])->expectsOutputToContain('Exported 1 match(es)')->assertSuccessful();
        $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) ?: [];
        $this->assertCount(1, $lines);
        $this->assertSame([
            'matchId' => $ranked->id, 'variant' => 'shortNard',
            'white' => ['userId' => (string) $a->id], 'black' => ['userId' => (string) $b->id], 'games' => $games,
        ], json_decode($lines[0], true));
        unlink($path);
    }

    public function test_accounts_sharing_an_ip_or_device_that_meet_in_ranked_are_flagged(): void
    {
        $scanner = app(AntiCheatService::class);
        [$a, $b, $c, $d, $e] = User::factory()->count(5)->create()->all();
        $scanner->recordSignIn($a, '10.0.0.5', null);
        $scanner->recordSignIn($b, '10.0.0.5', 'phone-1');
        $scanner->recordSignIn($c, '10.9.9.9', 'tablet-7');
        $scanner->recordSignIn($d, '10.8.8.8', 'tablet-7');
        $scanner->recordSignIn($e, '10.0.0.5', null);
        // A and B: two ranked matches, B always loses (feeding).
        $this->match($a, $b, 'white');
        $this->match($b, $a, 'black');
        // C and D share a device but met only once in ranked; E never played A.
        $this->match($c, $d, 'white');
        $this->match($a, $e, 'white', mode: 'casual');

        $this->runCommand('anticheat:scan', ['--skip-engine' => true])->expectsOutputToContain('multi_account: 2 new flag(s)')->assertSuccessful();
        $flags = CheatFlag::query()->where('kind', 'multi_account')->orderBy('user_id')->get();
        $this->assertSame([$a->id, $b->id], $flags->pluck('user_id')->all());
        [$flagA, $flagB] = $flags->all();
        $this->assertSame([['userId' => $b->id, 'shared' => ['ip'], 'rankedMatches' => 2, 'wins' => 2]], $flagA->details['partners']);
        $this->assertSame(0, $flagB->details['partners'][0]['wins']);
        $this->assertSame(2.0, $flagA->score);
        $this->runCommand('anticheat:scan', ['--skip-engine' => true])->expectsOutputToContain('multi_account: 0 new flag(s)');
        // Old sightings are pruned.
        $this->travel(91)->days();
        $this->runCommand('anticheat:scan', ['--skip-engine' => true])->assertSuccessful();
        $this->assertSame(0, DB::table('user_sightings')->count());
    }

    public function test_sign_in_records_the_ip_and_device(): void
    {
        $this->postJson('/api/v1/auth/guest', ['deviceId' => 'device-abc-123'], ['REMOTE_ADDR' => '203.0.113.7'])->assertOk();
        $user = User::query()->where('device_id', 'device-abc-123')->sole();
        $this->assertSame('203.0.113.7', $user->last_ip);
        $this->assertNotNull($user->last_login_at);
        $this->assertSame(['device', 'ip'], DB::table('user_sightings')->where('user_id', $user->id)->orderBy('kind')->pluck('kind')->all());
        $this->assertSame(hash('sha256', 'ip:203.0.113.7'), DB::table('user_sightings')->where('kind', 'ip')->value('value_hash'));
    }

    public function test_frequent_abandonment_gives_a_matchmaking_cooldown(): void
    {
        [$quitter, $fair] = User::factory()->count(2)->create()->all();
        for ($i = 0; $i < 10; $i++) {
            // The quitter (white) abandons 3 and times out once; a walkover does not count.
            $reason = $i < 3 ? 'abandoned' : ($i === 3 ? 'timeout' : 'completed');
            $this->match($quitter, $fair, $i < 4 ? 'black' : ($i % 2 === 0 ? 'white' : 'black'), $reason);
        }
        $this->match($quitter, $fair, 'black', 'walkover', 'tournament');

        $this->runCommand('anticheat:scan', ['--skip-engine' => true])->expectsOutputToContain('abandonment: 1 new flag(s)')->assertSuccessful();
        $flag = CheatFlag::query()->where('kind', 'abandonment')->sole();
        $this->assertSame($quitter->id, $flag->user_id);
        $this->assertSame(['matches' => 10, 'quits' => 4, 'rate' => 0.4], array_intersect_key($flag->details, ['matches' => 0, 'quits' => 0, 'rate' => 0]));
        $until = $this->reload($quitter)->queue_cooldown_until;
        $this->assertNotNull($until);
        $this->assertEqualsWithDelta(now()->addHours(24)->getTimestamp(), $until->getTimestamp(), 5);

        // The ticket carries the cooldown for the game server's queue.
        $res = $this->actingAs($this->reload($quitter))->postJson('/api/v1/game/ticket')->assertOk();
        $this->assertSame($until->toIso8601String(), $res->json('queueCooldownUntil'));
        $payload = json_decode((string) base64_decode(strtr(explode('.', (string) $res->json('ticket'))[0], '-_', '+/')), true);
        $this->assertSame($until->getTimestamp(), $payload['queueCooldownUntil']);
        $this->assertNull($this->actingAs($fair)->postJson('/api/v1/game/ticket')->json('queueCooldownUntil'));

        // Re-scans do not extend it; it ends by itself.
        $this->travel(1)->hours();
        $this->runCommand('anticheat:scan', ['--skip-engine' => true])->expectsOutputToContain('abandonment: 0 new flag(s)');
        $this->assertSame($until->getTimestamp(), $this->reload($quitter)->queue_cooldown_until?->getTimestamp());
        $this->travel(24)->hours();
        $this->assertNull($this->reload($quitter)->queueCooldownUntil());
    }

    public function test_many_distinct_reporters_in_a_week_are_flagged(): void
    {
        [$target, $other] = User::factory()->count(2)->create()->all();
        $reporters = User::factory()->count(5)->create()->all();
        foreach ($reporters as $i => $r) {
            $this->actingAs($r)->postJson('/api/v1/reports', ['userId' => (string) $target->id, 'reason' => $i < 3 ? 'cheating' : 'abuse'])->assertCreated();
            if ($i < 4) {
                // Four distinct reporters (one twice) are not enough.
                $this->actingAs($r)->postJson('/api/v1/reports', ['userId' => (string) $other->id, 'reason' => 'abuse'])->assertCreated();
            }
        }
        $this->actingAs($reporters[0])->postJson('/api/v1/reports', ['userId' => (string) $other->id, 'reason' => 'name'])->assertCreated();
        // Old reports fall out of the window.
        DB::table('reports')->insert(['reporter_id' => $reporters[4]->id, 'reported_id' => $other->id, 'reason' => 'abuse', 'status' => 'open', 'created_at' => now()->subDays(8), 'updated_at' => now()->subDays(8)]);

        $this->runCommand('anticheat:scan', ['--skip-engine' => true])->expectsOutputToContain('reports: 1 new flag(s)')->assertSuccessful();
        $flag = CheatFlag::query()->where('kind', 'reports')->sole();
        $this->assertSame($target->id, $flag->user_id);
        $this->assertEquals(['reporters' => 5, 'reasons' => ['abuse' => 2, 'cheating' => 3]], $flag->details);

        // Reviewed flags are not raised again inside the window.
        app(ModerationService::class)->reviewFlag($flag, 'dismissed', 'brigading', null);
        $this->runCommand('anticheat:scan', ['--skip-engine' => true])->expectsOutputToContain('reports: 0 new flag(s)');
        $this->assertSame('dismissed', $this->reload($flag)->status);
        $this->assertSame(1, CheatFlag::query()->count());
    }
}
