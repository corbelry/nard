<?php

namespace Tests\Feature;

use App\Mail\LoginCodeMail;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Mail;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_accounts_are_bound_to_the_device(): void
    {
        $first = $this->postJson('/api/v1/auth/guest', ['deviceId' => 'device-0001', 'locale' => 'en'])
            ->assertOk()
            ->assertJsonPath('user.guest', true)
            ->json();
        $this->assertStringStartsWith('Player', $first['user']['name']);
        $again = $this->postJson('/api/v1/auth/guest', ['deviceId' => 'device-0001'])->assertOk()->json();
        $this->assertSame($first['user']['id'], $again['user']['id']);
        $this->postJson('/api/v1/auth/guest', ['deviceId' => 'short'])->assertUnprocessable();
    }

    private function requestCode(string $email): string
    {
        Mail::fake();
        $this->postJson('/api/v1/auth/email/start', ['email' => $email, 'locale' => 'az'])->assertStatus(202);
        $code = '';
        Mail::assertSent(LoginCodeMail::class, function (LoginCodeMail $mail) use (&$code, $email) {
            $code = $mail->code;

            return $mail->hasTo(strtolower($email));
        });

        return $code;
    }

    public function test_email_codes_sign_in_and_expire_after_attempts(): void
    {
        $code = $this->requestCode('Elvin@Example.com');
        $this->assertMatchesRegularExpression('/^\d{6}$/', $code);
        $wrong = $code === '000000' ? '111111' : '000000';
        $this->postJson('/api/v1/auth/email/verify', ['email' => 'elvin@example.com', 'code' => $wrong])
            ->assertStatus(422)->assertJsonPath('code', 'code_invalid');
        $this->postJson('/api/v1/auth/email/verify', ['email' => 'elvin@example.com', 'code' => $code])
            ->assertOk()->assertJsonPath('user.email', 'elvin@example.com')->assertJsonPath('user.guest', false);
        // A used code cannot be reused.
        $this->postJson('/api/v1/auth/email/verify', ['email' => 'elvin@example.com', 'code' => $code])
            ->assertStatus(422)->assertJsonPath('code', 'code_expired');

        $code = $this->requestCode('elvin@example.com');
        for ($i = 0; $i < 5; $i++) {
            $this->postJson('/api/v1/auth/email/verify', ['email' => 'elvin@example.com', 'code' => $code === '000000' ? '111111' : '000000']);
        }
        $this->postJson('/api/v1/auth/email/verify', ['email' => 'elvin@example.com', 'code' => $code])
            ->assertStatus(422)->assertJsonPath('code', 'code_expired');
        $this->assertSame(1, User::query()->where('email', 'elvin@example.com')->count());
    }

    public function test_a_guest_upgrades_to_email_and_keeps_its_account(): void
    {
        $guest = $this->postJson('/api/v1/auth/guest', ['deviceId' => 'device-0002'])->json();
        $code = $this->requestCode('nigar@example.com');
        $res = $this->withToken($guest['token'])
            ->postJson('/api/v1/auth/email/verify', ['email' => 'nigar@example.com', 'code' => $code])
            ->assertOk()->json();
        $this->assertSame($guest['user']['id'], $res['user']['id']);
        $this->assertFalse($res['user']['guest']);
    }

    public function test_apple_and_google_are_disabled_until_configured(): void
    {
        $this->postJson('/api/v1/auth/apple')->assertStatus(503)->assertJsonPath('code', 'provider_disabled');
        config(['nard.providers.google' => true]);
        $this->postJson('/api/v1/auth/google')->assertStatus(501);
    }

    public function test_logout_revokes_the_token(): void
    {
        $guest = $this->postJson('/api/v1/auth/guest', ['deviceId' => 'device-0003'])->json();
        $this->withToken($guest['token'])->postJson('/api/v1/auth/logout')->assertOk();
        $this->app['auth']->forgetGuards();
        $this->withToken($guest['token'])->getJson('/api/v1/me')->assertUnauthorized();
    }
}
