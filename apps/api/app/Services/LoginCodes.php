<?php

namespace App\Services;

use App\Mail\LoginCodeMail;
use App\Models\LoginCode;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;

/** One-time e-mail codes for signing in and for the web deletion page. */
class LoginCodes
{
    /** Replaces any open code for [email] and mails a new one. */
    public function issue(string $email, string $locale, string $purpose = 'sign_in'): void
    {
        $code = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        $ttl = (int) config('nard.login_code_ttl');
        DB::transaction(function () use ($email, $code, $ttl): void {
            LoginCode::query()->where('email', $email)->delete();
            LoginCode::query()->create([
                'email' => $email,
                'code_hash' => Hash::make($code),
                'expires_at' => now()->addSeconds($ttl),
            ]);
        });
        Mail::to($email)->locale($locale)->send(new LoginCodeMail($code, intdiv($ttl, 60), $purpose));
    }

    /**
     * Uses up the code when it matches.
     *
     * @return 'code_expired'|'code_invalid'|null null when the code is right
     */
    public function check(string $email, string $code): ?string
    {
        $login = LoginCode::query()->where('email', $email)->latest('id')->first();
        if ($login === null || $login->expires_at->isPast()
            || $login->attempts >= (int) config('nard.login_code_attempts')) {
            return 'code_expired';
        }
        if (! Hash::check($code, $login->code_hash)) {
            $login->increment('attempts');

            return 'code_invalid';
        }
        $login->delete();

        return null;
    }
}
