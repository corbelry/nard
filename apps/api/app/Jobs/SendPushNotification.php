<?php

namespace App\Jobs;

use App\Models\User;
use App\Services\Notifier;
use App\Services\Push\PushMessage;
use App\Services\Push\PushResult;
use App\Services\Push\PushSender;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\DB;

/** Sends one inbox row as a push to each of the player's devices. */
class SendPushNotification implements ShouldQueue
{
    use Queueable;

    public int $tries = 1;

    public function __construct(public int $notificationId) {}

    public function handle(PushSender $sender, Notifier $notifier): void
    {
        $row = DB::table('notifications')->where('id', $this->notificationId)->first();
        $user = $row === null ? null : User::query()->find((int) $row->user_id);
        if ($row === null || $user === null || $row->read_at !== null) {
            return;
        }
        $tokens = DB::table('device_tokens')->where('user_id', $user->id)->get();
        foreach ($tokens as $t) {
            $locale = in_array($t->locale, ['az', 'en', 'ru', 'tr'], true) ? (string) $t->locale : $user->locale;
            [$title, $body] = $notifier->copy($row, $locale);
            $result = $sender->send(new PushMessage((string) $t->token, (string) $t->platform, $title, $body, [
                'id' => (string) $row->id,
                'type' => (string) $row->type,
                'data' => (string) $row->data,
            ]));
            if ($result === PushResult::InvalidToken) {
                DB::table('device_tokens')->where('id', $t->id)->delete();
            }
        }
    }
}
