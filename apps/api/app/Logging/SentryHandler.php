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

    private int $window = 0;

    private int $sent = 0;

    public function __construct(
        ?string $dsn = null,
        private readonly string $environment = 'production',
        private readonly string $release = 'api',
        int|string|Level $level = Level::Error,
        private readonly int $perMinute = 30,
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
        if ($this->endpoint === null || ! $this->allow($record->datetime->getTimestamp())) {
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
            'message' => ['formatted' => self::redact($record->message)],
            'extra' => array_map(
                fn (mixed $v): mixed => is_string($v) ? self::redact($v) : (is_scalar($v) || $v === null ? $v : self::redact((string) json_encode($v))),
                $extra,
            ),
        ];
        if ($exception instanceof Throwable) {
            $event['exception'] = ['values' => [[
                'type' => $exception::class,
                'value' => self::redact($exception->getMessage()),
            ]]];
            $event['extra']['trace'] = self::redact($exception->getTraceAsString());
        }
        try {
            Http::timeout(2)->withHeaders([
                'X-Sentry-Auth' => "Sentry sentry_version=7, sentry_client=nard-api/1.0, sentry_key={$this->key}",
            ])->post($this->endpoint, $event);
        } catch (Throwable) {
            // Reporting must never fail the request.
        }
    }

    /** At most [perMinute] events per minute from this process. */
    private function allow(int $now): bool
    {
        $minute = intdiv($now, 60);
        if ($minute !== $this->window) {
            $this->window = $minute;
            $this->sent = 0;
        }

        return ++$this->sent <= $this->perMinute;
    }

    /** Masks e-mails and IP addresses (e.g. SQL bindings in a QueryException). */
    private static function redact(string $text): string
    {
        $text = (string) preg_replace('/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/i', '[email]', $text);
        $text = (string) preg_replace('/\b(?:\d{1,3}\.){3}\d{1,3}\b/', '[ip]', $text);

        return (string) preg_replace('/\b(?:[0-9a-f]{1,4}:){2,7}[0-9a-f]{0,4}\b/i', '[ip]', $text);
    }
}
