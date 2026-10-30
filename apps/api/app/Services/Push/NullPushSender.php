<?php

namespace App\Services\Push;

use Illuminate\Support\Facades\Log;

/** Used until FCM credentials exist (config/push.php): logs and drops. */
final class NullPushSender implements PushSender
{
    public function enabled(): bool
    {
        return false;
    }

    public function send(PushMessage $message): PushResult
    {
        Log::info('push disabled: not sent', ['platform' => $message->platform, 'type' => $message->data['type'] ?? null]);

        return PushResult::Skipped;
    }
}
