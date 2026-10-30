<?php

namespace App\Logging;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use Monolog\Handler\AbstractProcessingHandler;
use Monolog\Level;
use Monolog\LogRecord;
use Throwable;

/**
 * Sends error-level log records to a Sentry-compatible `store` endpoint
 * when `SENTRY_DSN` is set (ADR-043); without a DSN it does nothing. Uses
 * the HTTP client instead of the Sentry SDK and never throws, so a broken
 * reporter cannot break the request that logged the error.
 */
class SentryHandler extends AbstractProcessingHandler
{
    private ?string $endpoint = null;

    private string $key = '';

    public function __construct(
        ?string $dsn = null,
        private readonly string $environment = 'production',
        private readonly string $release = 'api',
        int|string|Level $level = Level::Error,
    ) {
        parent::__construct($level, true);
        $parts = parse_url(trim((string) $dsn));
        if (is_array($parts) && isset($parts['scheme'], $parts['host'], $parts['user'], $parts['path'])) {
            $segments = array_values(array_filter(explode('/', $parts['path']), fn (string $s): bool => $s !== ''));
            $project = array_pop($segments);
            if ($project !== null) {
                $port = isset($parts['port']) ? ':'.$parts['port'] : '';
                $prefix = $segments === [] ? '' : '/'.implode('/', $segments);
                $this->endpoint = "{$parts['scheme']}://{$parts['host']}{$port}{$prefix}/api/{$project}/store/";
                $this->key = $parts['user'];
            }
        }
    }

    public function enabled(): bool
    {
        return $this->endpoint !== null;
    }

    protected function write(LogRecord $record): void
    {
        if ($this->endpoint === null) {
            return;
        }
        $exception = $record->context['exception'] ?? null;
        $extra = array_diff_key($record->context, ['exception' => true]);
        $event = [
            'event_id' => str_replace('-', '', (string) Str::uuid()),
            'timestamp' => $record->datetime->getTimestamp(),
            'platform' => 'php',
            'level' => $record->level->isHigherThan(Level::Error) ? 'fatal' : 'error',
            'logger' => $record->channel,
            'environment' => $this->environment,
            'release' => $this->release,
            'message' => ['formatted' => $record->message],
            'extra' => array_map(fn (mixed $v): mixed => is_scalar($v) || $v === null ? $v : json_encode($v), $extra),
        ];
        if ($exception instanceof Throwable) {
            $event['exception'] = ['values' => [[
                'type' => $exception::class,
                'value' => $exception->getMessage(),
            ]]];
            $event['extra']['trace'] = $exception->getTraceAsString();
        }
        try {
            Http::timeout(2)->withHeaders([
                'X-Sentry-Auth' => "Sentry sentry_version=7, sentry_client=nard-api/1.0, sentry_key={$this->key}",
            ])->post($this->endpoint, $event);
        } catch (Throwable) {
            // Reporting must never fail the request.
        }
    }
}
