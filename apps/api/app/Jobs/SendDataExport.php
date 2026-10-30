<?php

namespace App\Jobs;

use App\Mail\DataExportMail;
use App\Models\User;
use App\Services\AccountExport;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Mail;

/** 15.2: mails the player's data as a ZIP to their account e-mail (#17). */
class SendDataExport implements ShouldQueue
{
    use Queueable;

    public int $tries = 3;

    public function __construct(public int $userId) {}

    public function handle(AccountExport $export): void
    {
        $user = User::query()->find($this->userId);
        if ($user === null || $user->email === null) {
            return;
        }
        Mail::to($user->email)->locale($user->locale)->send(new DataExportMail($export->zip($user)));
    }
}
