<?php

namespace App\Console\Commands;

use App\Services\AntiCheatService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Process;

/**
 * Daily fair-play scan (spec §8.14, ADR-042). The engine check needs the
 * Dart move-quality tool: pass its output with --engine=<file>, or set
 * MOVE_QUALITY_CMD so the scan exports recent ranked matches and pipes
 * them through it (docs/api/admin.md).
 */
class AntiCheatScan extends Command
{
    protected $signature = 'anticheat:scan
        {--engine= : JSON lines from move_quality.dart to import instead of running the tool}
        {--skip-engine : Run only the rules that need no move analysis}';

    protected $description = 'Flag engine assistance, multi-accounting, abandonment and report spikes for admin review';

    public function handle(AntiCheatService $scanner): int
    {
        $now = now();
        $this->info('reports: '.$scanner->scanReports($now).' new flag(s)');
        $this->info('abandonment: '.$scanner->scanAbandonment($now).' new flag(s)');
        $this->info('multi_account: '.$scanner->scanMultiAccounts($now).' new flag(s)');
        if ($this->option('skip-engine')) {
            return self::SUCCESS;
        }
        $lines = $this->engineLines($scanner);
        if ($lines === null) {
            $this->warn('engine: skipped (no --engine file and MOVE_QUALITY_CMD is not set)');

            return self::SUCCESS;
        }
        if ($lines === false) {
            return self::FAILURE;
        }
        $this->info('engine: '.$scanner->scanEngine($lines, $now).' new flag(s)');

        return self::SUCCESS;
    }

    /** @return array<int, string>|false|null null = not available, false = failed */
    private function engineLines(AntiCheatService $scanner): array|false|null
    {
        $file = $this->option('engine');
        if (is_string($file) && $file !== '') {
            if (! is_readable($file)) {
                $this->error("engine: cannot read $file");

                return false;
            }

            return file($file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) ?: [];
        }
        $command = config('fairplay.engine.command');
        if (! is_string($command) || $command === '') {
            return null;
        }
        $input = tmpfile();
        if ($input === false) {
            return false;
        }
        $exported = $scanner->exportMatches($input, now());
        rewind($input);
        $result = Process::timeout((int) config('fairplay.engine.timeout'))->input($input)->run($command);
        fclose($input);
        if ($result->failed()) {
            $this->error('engine: move-quality tool failed: '.trim($result->errorOutput()));

            return false;
        }
        $this->line("engine: analysed $exported match(es)");

        return preg_split('/\R/', trim($result->output()), -1, PREG_SPLIT_NO_EMPTY) ?: [];
    }
}
