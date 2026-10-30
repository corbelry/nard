<?php

namespace App\Jobs;

use App\Models\User;
use App\Services\LoginCodes;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;

/**
 * Web deletion page (QUESTIONS #45): mails a deletion code when a
 * non-guest account uses the address. Queued for every address, so the
 * page answers known and unknown addresses equally fast.
 */
class SendDeletionCode implements ShouldQueue
{
    use Queueable;

    public function __construct(public string $email, public string $locale) {}

    public function handle(LoginCodes $codes): void
    {
        $user = User::query()->firstWhere('email', $this->email);
        if ($user !== null && $user->deletion_requested_at === null) {
            $codes->issue($this->email, $this->locale, 'deletion');
        }
    }
}
