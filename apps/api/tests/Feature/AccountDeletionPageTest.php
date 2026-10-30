<?php

namespace Tests\Feature;

use App\Mail\LoginCodeMail;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Mail;
use Tests\TestCase;

/** Web account-deletion page for Google Play (QUESTIONS #45). */
class AccountDeletionPageTest extends TestCase
{
    use RefreshDatabase;

    private function codeFor(string $email, string $lang = 'en'): string
    {
        Mail::fake();
        $this->post('/delete-account/code', ['email' => $email, 'lang' => $lang])
            ->assertOk()
            ->assertSee(__('deletion.code_label', [], $lang));
        $code = '';
        Mail::assertSent(LoginCodeMail::class, function (LoginCodeMail $mail) use (&$code, $email) {
            $code = $mail->code;

            return $mail->hasTo(strtolower($email)) && $mail->purpose === 'deletion';
        });

        return $code;
    }

    public function test_the_page_is_localised(): void
    {
        // ?lang=, else the browser language, else Azerbaijani.
        $this->withHeader('Accept-Language', 'tr-TR,tr;q=0.9')->get('/delete-account')
            ->assertOk()->assertSee(__('deletion.title', [], 'tr'));
        $this->get('/delete-account?lang=ru')->assertOk()->assertSee(__('deletion.title', [], 'ru'));
        $this->get('/delete-account?lang=xx')->assertOk()->assertSee(__('deletion.title', [], 'az'));
    }

    public function test_an_unknown_email_gets_the_same_answer_and_no_mail(): void
    {
        Mail::fake();
        $this->post('/delete-account/code', ['email' => 'nobody@example.com', 'lang' => 'en'])
            ->assertOk()
            ->assertSee(__('deletion.code_label', [], 'en'));
        Mail::assertNothingSent();
        $this->assertDatabaseCount('users', 0);
    }

    public function test_the_code_schedules_deletion_and_signs_out_everywhere(): void
    {
        $user = User::factory()->create(['email' => 'elvin@example.com', 'is_guest' => false]);
        $user->createToken('app');
        $code = $this->codeFor('Elvin@Example.com');
        $wrong = $code === '000000' ? '111111' : '000000';

        $this->post('/delete-account/confirm', ['email' => 'elvin@example.com', 'code' => $wrong, 'lang' => 'en'])
            ->assertOk()
            ->assertSee(__('deletion.code_invalid', [], 'en'));
        $this->post('/delete-account/confirm', ['email' => 'elvin@example.com', 'code' => $wrong, 'lang' => 'ru'])
            ->assertSee(__('deletion.code_invalid', [], 'ru'));
        $this->assertNull($user->fresh()?->deletion_requested_at);

        $this->post('/delete-account/confirm', ['email' => 'elvin@example.com', 'code' => $code, 'lang' => 'en'])
            ->assertOk()
            ->assertSee(__('deletion.done_title', [], 'en'));
        $fresh = $user->fresh();
        $this->assertNotNull($fresh?->deletion_requested_at);
        $this->assertSame(0, $fresh->tokens()->count());
        // The code is used up.
        $this->post('/delete-account/confirm', ['email' => 'elvin@example.com', 'code' => $code, 'lang' => 'en'])
            ->assertOk()
            ->assertSee(__('deletion.code_expired', [], 'en'));
    }

    public function test_bad_input_is_shown_on_the_form(): void
    {
        $this->post('/delete-account/code', ['email' => 'not-an-email'])
            ->assertRedirect()
            ->assertSessionHasErrors('email');
    }
}
