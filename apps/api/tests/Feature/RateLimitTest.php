<?php

namespace Tests\Feature;

use App\Mail\LoginCodeMail;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Mail;
use Illuminate\Testing\TestResponse;
use Symfony\Component\HttpFoundation\Response;
use Tests\TestCase;

/** Security review 2026-10-30: limits are per route and per e-mail. */
class RateLimitTest extends TestCase
{
    use RefreshDatabase;

    /** @return TestResponse<Response> */
    private function start(string $email, string $ip = '203.0.113.1'): TestResponse
    {
        return $this->withServerVariables(['REMOTE_ADDR' => $ip])
            ->postJson('/api/v1/auth/email/start', ['email' => $email]);
    }

    /** @return TestResponse<Response> */
    private function verify(string $email, string $code, string $ip = '203.0.113.1'): TestResponse
    {
        return $this->withServerVariables(['REMOTE_ADDR' => $ip])
            ->postJson('/api/v1/auth/email/verify', ['email' => $email, 'code' => $code]);
    }

    /** The last code mailed to [email]. */
    private function lastCode(string $email): string
    {
        $code = '';
        Mail::assertSent(LoginCodeMail::class, function (LoginCodeMail $mail) use (&$code, $email) {
            if ($mail->hasTo($email)) {
                $code = $mail->code;
            }

            return true;
        });

        return $code;
    }

    public function test_one_routes_limit_does_not_block_another(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('app')->plainTextToken;
        for ($i = 0; $i < 30; $i++) {
            $this->withToken($token)->getJson('/api/v1/clans')->assertOk();
        }
        $this->withToken($token)->postJson('/api/v1/game/ticket')->assertOk();
    }

    public function test_codes_per_email_are_capped_across_ips(): void
    {
        Mail::fake();
        for ($i = 1; $i <= 5; $i++) {
            $this->start('victim@example.com', "203.0.113.$i")->assertStatus(202);
        }
        $this->start('victim@example.com', '203.0.113.99')->assertStatus(429);
        // Another address is unaffected.
        $this->start('other@example.com', '203.0.113.99')->assertStatus(202);
    }

    public function test_ipv6_addresses_share_their_64_prefix(): void
    {
        Mail::fake();
        for ($i = 1; $i <= 5; $i++) {
            $this->start("p$i@example.com", "2001:db8:1:2::$i")->assertStatus(202);
        }
        $this->start('p6@example.com', '2001:db8:1:2::ffff')->assertStatus(429);
        $this->start('p6@example.com', '2001:db8:1:3::1')->assertStatus(202);
    }

    public function test_failed_guesses_per_email_lock_the_address_for_a_day(): void
    {
        Mail::fake();
        $limit = (int) config('nard.login_code_daily_failures');
        $guesses = 0;
        $ip = 0;
        while ($guesses < $limit) {
            $this->start('victim@example.com', '198.51.100.'.(++$ip))->assertStatus(202);
            $code = $this->lastCode('victim@example.com');
            $wrong = $code === '000000' ? '111111' : '000000';
            for ($i = 0; $i < 5 && $guesses < $limit; $i++, $guesses++) {
                $this->verify('victim@example.com', $wrong, '198.51.100.'.$ip)->assertStatus(422);
            }
        }
        $this->travel(61)->minutes();
        $this->start('victim@example.com', '198.51.100.200')->assertStatus(202);
        $right = $this->lastCode('victim@example.com');
        $this->verify('victim@example.com', $right, '198.51.100.200')
            ->assertStatus(422)->assertJson(['code' => 'code_expired']);
        $this->travel(1)->days();
        $this->start('victim@example.com', '198.51.100.201')->assertStatus(202);
        $this->verify('victim@example.com', $this->lastCode('victim@example.com'), '198.51.100.201')->assertOk();
    }

    public function test_deletion_codes_do_not_sign_in_or_replace_sign_in_codes(): void
    {
        Mail::fake();
        User::factory()->create(['email' => 'aysel@example.com', 'is_guest' => false]);
        $this->start('aysel@example.com')->assertStatus(202);
        $signIn = $this->lastCode('aysel@example.com');
        $this->post('/delete-account/code', ['email' => 'aysel@example.com', 'lang' => 'en'])->assertOk();
        $deletion = '';
        Mail::assertSent(LoginCodeMail::class, function (LoginCodeMail $mail) use (&$deletion) {
            if ($mail->purpose === 'deletion') {
                $deletion = $mail->code;
            }

            return true;
        });
        $this->assertNotSame('', $deletion);
        if ($deletion !== $signIn) {
            $this->verify('aysel@example.com', $deletion)->assertStatus(422);
        }
        $this->verify('aysel@example.com', $signIn)->assertOk();
    }
}
