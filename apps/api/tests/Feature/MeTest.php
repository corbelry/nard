<?php

namespace Tests\Feature;

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
        $this->withToken($token)->deleteJson('/api/v1/me')->assertOk();
        $this->assertNull(User::query()->find((int) $id));
    }
}
