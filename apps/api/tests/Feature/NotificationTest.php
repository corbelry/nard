<?php

namespace Tests\Feature;

use App\Models\Clan;
use App\Models\ClanMember;
use App\Models\User;
use App\Services\Notifier;
use App\Services\ProgressionService;
use App\Services\Push\PushMessage;
use App\Services\Push\PushResult;
use App\Services\Push\PushSender;
use App\Services\SeasonService;
use Database\Seeders\ItemCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Mockery;
use Tests\TestCase;

/** Records pushes instead of sending them. */
class RecordingPushSender implements PushSender
{
    /** @var list<PushMessage> */
    public array $sent = [];

    public function enabled(): bool
    {
        return true;
    }

    public function send(PushMessage $message): PushResult
    {
        $this->sent[] = $message;

        return PushResult::Sent;
    }
}

class NotificationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Carbon::setTestNow('2026-11-05 12:00:00');
    }

    private function recorder(): RecordingPushSender
    {
        $sender = new RecordingPushSender;
        $this->app->instance(PushSender::class, $sender);

        return $sender;
    }

    private function device(User $user, string $token = 'device-token-0001', string $locale = 'az'): void
    {
        $this->actingAs($user)->postJson('/api/v1/me/devices', ['platform' => 'android', 'token' => $token, 'locale' => $locale])
            ->assertCreated();
    }

    /** @return array<int, array<string, mixed>> */
    private function inbox(User $user): array
    {
        /** @var array<int, array<string, mixed>> */
        return $this->actingAs($user)->getJson('/api/v1/notifications')->assertOk()->json('notifications');
    }

    private function befriend(User $a, User $b): void
    {
        DB::table('friendships')->insert([
            'requester_id' => $a->id, 'addressee_id' => $b->id, 'status' => 'accepted',
            'accepted_at' => now(), 'created_at' => now(), 'updated_at' => now(),
        ]);
    }

    public function test_friend_request_and_accept_reach_the_inbox_with_an_unread_count(): void
    {
        $a = User::factory()->create(['name' => 'Rauf']);
        $b = User::factory()->create(['name' => 'Nigar']);
        $this->actingAs($a)->postJson('/api/v1/friends/requests', ['userId' => (string) $b->id])->assertCreated();

        $res = $this->actingAs($b)->getJson('/api/v1/notifications')->assertOk();
        $res->assertJsonPath('unread', 1)
            ->assertJsonPath('notifications.0.type', 'friend_request')
            ->assertJsonPath('notifications.0.category', 'friend_requests')
            ->assertJsonPath('notifications.0.from.name', 'Rauf')
            ->assertJsonPath('notifications.0.read', false);
        $requestId = (int) $res->json('notifications.0.data.requestId');

        $this->actingAs($b)->postJson("/api/v1/friends/requests/$requestId/accept")->assertOk();
        $this->assertSame(['friend_accepted'], array_column($this->inbox($a), 'type'));
        $this->assertSame('Nigar', $this->inbox($a)[0]['from']['name']);
        // Polling: only rows after the newest id the client has.
        $this->actingAs($b)->getJson('/api/v1/notifications?after='.$res->json('notifications.0.id'))
            ->assertOk()->assertJsonCount(0, 'notifications');
    }

    public function test_challenges_notify_once_per_room_code(): void
    {
        $a = User::factory()->create();
        $b = User::factory()->create();
        $this->befriend($a, $b);
        $body = ['userId' => (string) $b->id, 'code' => 'NRD482', 'variant' => 'longNard', 'matchLength' => 5];
        $this->actingAs($a)->postJson('/api/v1/challenges', $body)->assertCreated();
        $this->actingAs($a)->postJson('/api/v1/challenges', $body)->assertCreated();
        $rows = $this->inbox($b);
        $this->assertCount(1, $rows);
        $this->assertSame('challenge', $rows[0]['type']);
        $this->assertSame(['NRD482', 'longNard', 5], [$rows[0]['data']['code'], $rows[0]['data']['variant'], $rows[0]['data']['matchLength']]);
        $this->actingAs($a)->postJson('/api/v1/challenges', [...$body, 'code' => 'XYZ234'])->assertCreated();
        $this->assertCount(2, $this->inbox($b));
    }

    public function test_challenge_rows_and_pushes_carry_the_time_control(): void
    {
        $push = $this->recorder();
        $a = User::factory()->create(['name' => 'Elvin']);
        $b = User::factory()->create();
        $this->befriend($a, $b);
        $this->device($b, locale: 'en');
        $body = ['userId' => (string) $b->id, 'code' => 'NRD482', 'variant' => 'longNard', 'matchLength' => 5, 'timeControl' => 'blitz'];
        $this->actingAs($a)->postJson('/api/v1/challenges', $body)->assertCreated();
        $this->assertSame('blitz', $this->inbox($b)[0]['data']['timeControl']);
        $this->assertSame('Elvin invites you to play · Long Nard, 5 points, Blitz 1+8s', $push->sent[0]->body);

        // Without a control the room is rapid.
        unset($body['timeControl']);
        $this->actingAs($a)->postJson('/api/v1/challenges', [...$body, 'code' => 'XYZ234'])->assertCreated();
        $this->assertSame('rapid', $this->inbox($b)[0]['data']['timeControl']);
    }

    public function test_blocked_senders_are_dropped_and_hidden(): void
    {
        $a = User::factory()->create();
        $b = User::factory()->create();
        $this->actingAs($a)->postJson('/api/v1/friends/requests', ['userId' => (string) $b->id])->assertCreated();
        $this->actingAs($b)->postJson("/api/v1/blocks/{$a->id}")->assertOk();
        $this->actingAs($b)->getJson('/api/v1/notifications')->assertOk()
            ->assertJsonPath('unread', 0)->assertJsonCount(0, 'notifications');
        // New events from a blocked player are not even recorded.
        $this->assertNull(app(Notifier::class)->notify($b, 'friend_accepted', [], null, $a->id));
        $this->assertNull(app(Notifier::class)->notify($b, 'friend_accepted', [], null, $b->id), 'never from oneself');
        // Unblocking shows the old row again.
        $this->actingAs($b)->deleteJson("/api/v1/blocks/{$a->id}")->assertOk();
        $this->assertCount(1, $this->inbox($b));
    }

    public function test_read_flags_and_delete(): void
    {
        $user = User::factory()->create();
        $n = app(Notifier::class);
        $ids = [
            $n->notify($user, 'level_up', ['level' => 2, 'coins' => 100], 'level_up:2'),
            $n->notify($user, 'level_up', ['level' => 3, 'coins' => 100], 'level_up:3'),
            $n->notify($user, 'level_up', ['level' => 4, 'coins' => 100], 'level_up:4'),
        ];
        $this->assertNull($n->notify($user, 'level_up', ['level' => 4], 'level_up:4'), 'deduped');
        $this->actingAs($user)->postJson('/api/v1/notifications/read', ['ids' => [$ids[0]]])->assertOk()->assertJsonPath('unread', 2);
        $read = array_column($this->inbox($user), 'read', 'id');
        $this->assertTrue($read[$ids[0]]);
        $this->assertFalse($read[$ids[1]]);
        $this->actingAs($user)->deleteJson("/api/v1/notifications/{$ids[1]}")->assertOk()->assertJsonPath('unread', 1);
        $this->actingAs($user)->deleteJson("/api/v1/notifications/{$ids[1]}")->assertNotFound();
        $this->actingAs($user)->postJson('/api/v1/notifications/read', ['all' => true])->assertOk()->assertJsonPath('unread', 0);
        // Another player's rows are untouched.
        $other = User::factory()->create();
        $this->actingAs($other)->deleteJson("/api/v1/notifications/{$ids[2]}")->assertNotFound();
        $this->actingAs($other)->postJson('/api/v1/notifications/read', [])->assertStatus(422);
        // Retention.
        Carbon::setTestNow(now()->addDays(61));
        $this->assertSame(0, Artisan::call('notifications:prune'));
        $this->assertSame(0, DB::table('notifications')->count());
    }

    public function test_settings_have_defaults_and_update_partially(): void
    {
        $user = User::factory()->create();
        $this->actingAs($user)->getJson('/api/v1/me/notification-settings')->assertOk()
            ->assertJsonPath('settings.push', true)
            ->assertJsonPath('settings.quietHours', ['enabled' => true, 'start' => '23:00', 'end' => '08:00'])
            ->assertJsonPath('settings.categories.game_invites', true)
            ->assertJsonPath('settings.categories.rewards', true)
            ->assertJsonPath('settings.pushAvailable', false);
        $this->actingAs($user)->putJson('/api/v1/me/notification-settings', [
            'categories' => ['clan_war' => false], 'quietHours' => ['start' => '22:30'], 'utcOffset' => 240,
        ])->assertOk()
            ->assertJsonPath('settings.categories.clan_war', false)
            ->assertJsonPath('settings.categories.clan', true)
            ->assertJsonPath('settings.quietHours.start', '22:30')
            ->assertJsonPath('settings.quietHours.end', '08:00');
        $this->actingAs($user)->putJson('/api/v1/me/notification-settings', ['push' => false, 'categories' => ['clan_war' => true]])
            ->assertOk()->assertJsonPath('settings.push', false)->assertJsonPath('settings.categories.clan_war', true);
        $this->assertSame(240, (int) DB::table('notification_settings')->where('user_id', $user->id)->value('utc_offset'));
        $this->actingAs($user)->putJson('/api/v1/me/notification-settings', ['categories' => ['marketing' => true]])
            ->assertStatus(422)->assertJsonPath('code', 'unknown_category');
        $this->actingAs($user)->putJson('/api/v1/me/notification-settings', ['quietHours' => ['end' => '25:00']])->assertStatus(422);
    }

    public function test_devices_register_move_between_accounts_and_unregister(): void
    {
        $a = User::factory()->create();
        $b = User::factory()->create();
        $this->device($a);
        $this->device($a);
        $this->assertSame(1, DB::table('device_tokens')->count());
        // Signing in as another account on the same phone moves the token.
        $this->actingAs($b)->postJson('/api/v1/me/devices', ['platform' => 'ios', 'token' => 'device-token-0001', 'locale' => 'ru', 'utcOffset' => 180])
            ->assertCreated();
        $row = DB::table('device_tokens')->sole();
        $this->assertSame([$b->id, 'ios', 'ru'], [(int) $row->user_id, $row->platform, $row->locale]);
        $this->assertSame(180, (int) DB::table('notification_settings')->where('user_id', $b->id)->value('utc_offset'));
        $this->actingAs($b)->postJson('/api/v1/me/devices', ['platform' => 'web', 'token' => 'device-token-0002'])->assertStatus(422);
        $this->actingAs($a)->deleteJson('/api/v1/me/devices', ['token' => 'device-token-0001'])->assertOk();
        $this->assertSame(1, DB::table('device_tokens')->count(), 'not a\'s token any more');
        $this->actingAs($b)->deleteJson('/api/v1/me/devices', ['token' => 'device-token-0001'])->assertOk();
        $this->assertSame(0, DB::table('device_tokens')->count());
    }

    public function test_preferences_and_quiet_hours_mute_pushes_but_not_the_inbox(): void
    {
        $push = $this->recorder();
        $a = User::factory()->create(['name' => 'Kerem_TR']);
        $b = User::factory()->create();
        $this->device($b, locale: 'tr');
        $n = app(Notifier::class);

        $n->notify($b, 'friend_accepted', [], null, $a->id);
        $this->assertCount(1, $push->sent);
        $this->assertSame('Yeni arkadaş', $push->sent[0]->title);
        $this->assertSame('Kerem_TR arkadaşlık isteğini kabul etti', $push->sent[0]->body);
        $this->assertSame('friend_accepted', $push->sent[0]->data['type']);

        // Category off.
        $this->actingAs($b)->putJson('/api/v1/me/notification-settings', ['categories' => ['friend_requests' => false]])->assertOk();
        $n->notify($b, 'friend_accepted', [], null, $a->id);
        $this->assertCount(1, $push->sent);
        // Master switch off.
        $this->actingAs($b)->putJson('/api/v1/me/notification-settings', ['push' => false, 'categories' => ['friend_requests' => true]])->assertOk();
        $n->notify($b, 'friend_accepted', [], null, $a->id);
        $this->assertCount(1, $push->sent);
        // Quiet hours in local time: 12:00 UTC is 23:30 at UTC+11:30.
        $this->actingAs($b)->putJson('/api/v1/me/notification-settings', ['push' => true, 'utcOffset' => 690])->assertOk();
        $n->notify($b, 'friend_accepted', [], null, $a->id);
        $this->assertCount(1, $push->sent);
        $this->actingAs($b)->putJson('/api/v1/me/notification-settings', ['quietHours' => ['enabled' => false]])->assertOk();
        $n->notify($b, 'friend_accepted', [], null, $a->id);
        $this->assertCount(2, $push->sent);
        // Level-up is inbox only.
        $n->notify($b, 'level_up', ['level' => 5, 'coins' => 100], 'level_up:5');
        $this->assertCount(2, $push->sent);
        $this->assertCount(6, $this->inbox($b));

        $this->assertTrue(Notifier::inQuietHours('23:00', '08:00', 0, Carbon::parse('2026-11-05 07:59')));
        $this->assertFalse(Notifier::inQuietHours('23:00', '08:00', 0, Carbon::parse('2026-11-05 08:00')));
        $this->assertTrue(Notifier::inQuietHours('13:00', '15:00', 60, Carbon::parse('2026-11-05 12:30')));
        $this->assertFalse(Notifier::inQuietHours('10:00', '10:00', 0, Carbon::parse('2026-11-05 10:00')));
    }

    public function test_push_is_a_logged_no_op_until_fcm_is_configured(): void
    {
        Http::fake();
        Log::spy();
        $a = User::factory()->create();
        $b = User::factory()->create();
        $this->device($b);
        $this->actingAs($a)->postJson('/api/v1/friends/requests', ['userId' => (string) $b->id])->assertCreated();
        Log::getFacadeRoot()->shouldHaveReceived('info')->with('push disabled: not queued', Mockery::type('array'))->once();
        Http::assertNothingSent();
        $this->assertSame(0, DB::table('jobs')->count());
        $this->assertCount(1, $this->inbox($b));
    }

    public function test_fcm_sends_http_v1_with_a_service_account_token_and_forgets_dead_tokens(): void
    {
        $key = openssl_pkey_new(['private_key_bits' => 2048, 'private_key_type' => OPENSSL_KEYTYPE_RSA]);
        $this->assertNotFalse($key);
        openssl_pkey_export($key, $pem);
        $path = tempnam(sys_get_temp_dir(), 'fcm');
        $this->assertIsString($path);
        file_put_contents($path, json_encode([
            'type' => 'service_account', 'client_email' => 'push@nard-test.iam.gserviceaccount.com',
            'private_key' => $pem, 'token_uri' => 'https://oauth2.googleapis.com/token',
        ]));
        config(['push.fcm.project_id' => 'nard-test', 'push.fcm.credentials' => $path]);
        $this->app->forgetInstance(PushSender::class);
        Http::fake([
            'oauth2.googleapis.com/*' => Http::response(['access_token' => 'ya29.test', 'expires_in' => 3600]),
            'fcm.googleapis.com/*' => Http::sequence()
                ->push(['name' => 'projects/nard-test/messages/1'])
                ->push(['error' => ['code' => 404, 'status' => 'NOT_FOUND', 'details' => [['errorCode' => 'UNREGISTERED']]]], 404),
        ]);
        $a = User::factory()->create(['name' => 'Elvin']);
        $b = User::factory()->create();
        $this->device($b, 'device-token-en-0001', 'en');
        $this->actingAs($b)->putJson('/api/v1/me/notification-settings', ['quietHours' => ['enabled' => false]])
            ->assertOk()->assertJsonPath('settings.pushAvailable', true);

        $this->actingAs($a)->postJson('/api/v1/friends/requests', ['userId' => (string) $b->id])->assertCreated();
        Http::assertSent(fn ($r) => $r->url() === 'https://oauth2.googleapis.com/token'
            && $r['grant_type'] === 'urn:ietf:params:oauth:grant-type:jwt-bearer' && substr_count((string) $r['assertion'], '.') === 2);
        Http::assertSent(fn ($r) => $r->url() === 'https://fcm.googleapis.com/v1/projects/nard-test/messages:send'
            && $r->hasHeader('Authorization', 'Bearer ya29.test')
            && $r['message']['token'] === 'device-token-en-0001'
            && $r['message']['notification'] === ['title' => 'Friend request', 'body' => 'Elvin sent you a friend request']
            && $r['message']['data']['type'] === 'friend_request');

        // FCM says the token is gone: it is forgotten.
        app(Notifier::class)->notify($b, 'friend_accepted', [], null, $a->id);
        $this->assertSame(0, DB::table('device_tokens')->count());
        @unlink($path);
    }

    public function test_clan_invite_join_acceptance_and_war_notify(): void
    {
        $clan = fn (string $tag, string $policy) => Clan::query()->create([
            'name' => "Clan $tag", 'name_key' => strtolower("clan $tag"), 'tag' => $tag, 'language' => 'az', 'join_policy' => $policy,
            'emblem' => ['shape' => 'shield', 'symbol' => 'initials', 'color' => 'indigo', 'pattern' => 'none'],
        ]);
        $a = $clan('AAA', 'request');
        $b = $clan('BBB', 'open');
        $leader = User::factory()->create(['last_seen_at' => now()]);
        $mate = User::factory()->create(['last_seen_at' => now()]);
        ClanMember::query()->create(['clan_id' => $a->id, 'user_id' => $leader->id, 'role' => 'leader', 'joined_at' => now()]);
        ClanMember::query()->create(['clan_id' => $b->id, 'user_id' => $mate->id, 'role' => 'leader', 'joined_at' => now()]);

        $invited = User::factory()->create();
        $this->actingAs($leader)->postJson("/api/v1/clans/{$a->id}/invites", ['userId' => (string) $invited->id])->assertCreated();
        $row = $this->inbox($invited)[0];
        $this->assertSame(['clan_invite', 'AAA', (string) $a->id], [$row['type'], $row['data']['tag'], $row['data']['clanId']]);

        $joiner = User::factory()->create(['last_seen_at' => now()]);
        $this->actingAs($joiner)->postJson("/api/v1/clans/{$a->id}/join")->assertOk();
        $requestId = $this->actingAs($leader)->getJson("/api/v1/clans/{$a->id}/requests")->json('requests.0.id');
        $this->actingAs($leader)->postJson("/api/v1/clans/{$a->id}/requests/$requestId/accept")->assertOk();
        $this->assertSame(['clan_joined'], array_column($this->inbox($joiner), 'type'));

        $other = User::factory()->create(['last_seen_at' => now()]);
        ClanMember::query()->create(['clan_id' => $b->id, 'user_id' => $other->id, 'role' => 'member', 'joined_at' => now()]);
        $this->assertSame(0, Artisan::call('clans:pair-wars'));
        $war = collect($this->inbox($leader))->firstWhere('type', 'clan_war');
        $this->assertNotNull($war);
        $this->assertSame(['BBB', (string) $a->id], [$war['data']['tag'], $war['data']['clanId']]);
        $this->assertSame('AAA', collect($this->inbox($other))->firstWhere('type', 'clan_war')['data']['tag'] ?? null);
        $this->assertSame(0, Artisan::call('clans:pair-wars'));
        $this->assertSame(4, DB::table('notifications')->where('type', 'clan_war')->count());
    }

    public function test_season_end_and_level_up_notify(): void
    {
        $this->seed(ItemCatalogSeeder::class);
        config(['seasons.min_matches' => 1]);
        $seasons = app(SeasonService::class);
        $seasons->current();
        $user = User::factory()->create();
        $user->ratingFor('shortNard')->forceFill(['rating' => 1950, 'season_matches' => 3])->save();
        Carbon::setTestNow('2026-12-17 00:05:00');
        $seasons->roll();
        $seasons->roll();
        $rows = $this->inbox($user);
        $this->assertSame(['season_end'], array_column($rows, 'type'));
        $this->assertSame([1, 'diamond'], [$rows[0]['data']['season'], $rows[0]['data']['tier']]);

        $fresh = User::factory()->create();
        app(ProgressionService::class)->addXp($fresh, ProgressionService::xpForLevel(1) + ProgressionService::xpForLevel(2));
        $this->assertSame([3, 2], array_column(array_column($this->inbox($fresh), 'data'), 'level'));
    }
}
