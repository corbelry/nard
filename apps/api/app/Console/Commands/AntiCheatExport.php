<?php

namespace App\Console\Commands;

use App\Services\AntiCheatService;
use Illuminate\Console\Command;

/** Writes recent ranked matches as JSON lines for move_quality.dart. */
class AntiCheatExport extends Command
{
    protected $signature = 'anticheat:export {path : Output file, or - for stdout}';

    protected $description = 'Export recent ranked matches (JSON lines) for the move-quality tool';

    public function handle(AntiCheatService $scanner): int
    {
        $path = (string) $this->argument('path');
        $out = $path === '-' ? fopen('php://stdout', 'w') : fopen($path, 'w');
        if ($out === false) {
            $this->error("Cannot write $path");

            return self::FAILURE;
        }
        $count = $scanner->exportMatches($out, now());
        fclose($out);
        if ($path !== '-') {
            $this->info("Exported $count match(es) to $path");
        }

        return self::SUCCESS;
    }
}
