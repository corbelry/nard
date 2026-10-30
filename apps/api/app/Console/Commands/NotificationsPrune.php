<?php

namespace App\Console\Commands;

use App\Services\Notifier;
use Illuminate\Console\Command;

/** Daily: deletes inbox rows older than config('push.retention_days'). */
class NotificationsPrune extends Command
{
    protected $signature = 'notifications:prune';

    protected $description = 'Delete old inbox notifications';

    public function handle(Notifier $notifier): int
    {
        $this->info('Deleted '.$notifier->prune(now()).' notification(s).');

        return self::SUCCESS;
    }
}
