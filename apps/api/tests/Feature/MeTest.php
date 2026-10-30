<?php

namespace Tests\Feature;

use App\Models\GameMatch;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MeTest extends TestCase
{
    use RefreshDatabase;

    /** @return array{0: string, 1: string} token and user id */
    private function guest(): array
    {
        $res = $this->postJson('/api/v1/auth/guest', ['deviceId' => 'device-1000'])->json();

        return [$res['token'], $res['user']['id']];
    }

    public function test_profile_can_be_read_and_edited(): void
    {
        [$token] = $this->guest();
        $this->withToken($token)->getJson('/api/v1/me')->assertOk()->assertJsonPath('user.guest', true);
        $this->withToken($token)->patchJson('/api/v1/me', ['name' => 'Elvin_88', 'country' => 'az', 'locale' => 'ru'])
            ->assertOk()->assertJsonPath('user.name', 'Elvin_88')->assertJsonPath('user.country', 'AZ');
        $this->withToken($token)->patchJson('/api/v1/me', ['name' => 'a b'])->assertUnprocessable();
        $this->withToken($token)->patchJson('/api/v1/me', ['locale' => 'de'])->assertUnprocessable();
        $this->app['auth']->forgetGuards();
        $this->withoutToken()->getJson('/api/v1/me')->assertUnauthorized();
    }

    public function test_game_tickets_are_signed_for_the_game_server(): void
    {
        [$token, $id] = $this->guest();
        $res = $this->withToken($token)->postJson('/api/v1/game/ticket')->assertOk()->json();
        [$body, $sig] = explode('.', $res['ticket']);
        $expected = rtrim(strtr(base64_encode(hash_hmac('sha256', $body, 'test-secret-test-secret-test-secret!', true)), '+/', '-_'), '=');
        $this->assertSame($expected, $sig);
        $payload = json_decode((string) base64_decode(strtr($body, '-_', '+/')), true);
        $this->assertSame($id, $payload['sub']);
        $this->assertGreaterThan(time(), $payload['exp']);
    }

    public function test_account_export_and_deletion(): void
    {
        [$token, $id] = $this->guest();
        $this->withToken($token)->getJson('/api/v1/me/export')->assertOk()
            ->assertJsonPath('user.id', $id)->assertJsonPath('matches', []);
        $this->withToken($token)->deleteJson('/api/v1/me')->assertOk()->assertJsonStructure(['deletesAt']);
        // 30-day grace: the account still exists, tokens are gone.
        $this->assertNotNull(User::query()->findOrFail((int) $id)->deletion_requested_at);
        // Signing in again cancels the deletion.
        $this->app['auth']->forgetGuards();
        $this->withoutToken()->postJson('/api/v1/auth/guest', ['deviceId' => 'device-1000'])->assertOk();
        $this->assertNull(User::query()->findOrFail((int) $id)->deletion_requested_at);
        // After the grace period the purge deletes it.
        User::query()->whereKey((int) $id)->update(['deletion_requested_at' => now()->subDays(31)]);
        $this->runCommand('accounts:purge')->assertSuccessful();
        $this->assertNull(User::query()->find((int) $id));
    }

    public function test_deleted_accounts_disappear_from_opponents_history(): void
    {
        $a = User::factory()->create(['name' => 'Elvin', 'locale' => 'en']);
        $b = User::factory()->create(['name' => 'Nigar']);
        GameMatch::query()->create([
            'id' => 'm-del', 'variant' => 'shortNard', 'match_length' => 1, 'mode' => 'casual',
            'white_user_id' => $a->id, 'black_user_id' => $b->id, 'white_name' => 'Elvin', 'black_name' => 'Nigar',
            'winner' => 'white', 'white_score' => 1, 'black_score' => 0, 'reason' => 'completed',
            'games' => [], 'started_at' => now(), 'ended_at' => now(),
        ]);
        $b->delete();
        $this->assertSame('', GameMatch::query()->findOrFail('m-del')->black_name);
        $this->actingAs($a)->getJson('/api/v1/me/matches')->assertOk()
            ->assertJsonPath('matches.0.black.name', 'Deleted player');
    }
}
