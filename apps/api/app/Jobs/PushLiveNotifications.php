<?php

namespace App\Jobs;

use App\Services\GameServerClient;
use App\Services\Notifier;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\DB;

/**
 * Sends just-written inbox rows to the players' open sockets through the
 * game server (`POST /internal/notify`, ADR-049). Best effort, one try:
 * a player who misses it reads the row from the inbox (poll, resume).
 */
class PushLiveNotifications implements ShouldQueue
{
    use Queueable;

    public int $tries = 1;

    /** Rows per request (schema/notify.schema.json allows 500). */
    public const CHUNK = 200;

    /** @param list<int> $notificationIds */
    public function __construct(public array $notificationIds) {}

    public function handle(GameServerClient $gameServer, Notifier $notifier): void
    {
        foreach (array_chunk($this->notificationIds, self::CHUNK) as $ids) {
            $rows = DB::table('notifications')->whereIn('id', $ids)->whereNull('read_at')->orderBy('id')->get();
            if ($rows->isEmpty()) {
                continue;
            }
            $notifications = $notifier->present($rows);
            $items = [];
            foreach ($rows->values() as $i => $row) {
                $items[] = ['userId' => (string) $row->user_id, 'notification' => $notifications[$i]];
            }
            $gameServer->pushNotifications($items);
        }
    }
}
