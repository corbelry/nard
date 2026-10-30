<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;

/** Deletes accounts whose 30-day deletion grace has passed (15.3). */
class AccountsPurge extends Command
{
    protected $signature = 'accounts:purge';

    protected $description = 'Delete accounts whose deletion request is older than the grace period';

    public function handle(): int
    {
        $days = (int) config('nard.deletion_grace_days');
        $count = 0;
        User::query()->whereNotNull('deletion_requested_at')
            ->where('deletion_requested_at', '<=', now()->subDays($days))
            ->each(function (User $user) use (&$count): void {
                $user->delete();
                $count++;
            });
        $this->info("Deleted $count account(s).");

        return self::SUCCESS;
    }
}
