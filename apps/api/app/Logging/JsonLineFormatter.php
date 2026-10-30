<?php

namespace App\Logging;

use DateTimeZone;
use Monolog\Formatter\NormalizerFormatter;
use Monolog\LogRecord;

/**
 * One JSON object per line for container logs (ADR-043), in the same shape
 * as the game server: `level`, `ts` (UTC, ms), `msg`, `channel`, then the
 * record's context and extra fields at the top level. Exceptions in the
 * context are normalized (class, message, file, trace).
 */
class JsonLineFormatter extends NormalizerFormatter
{
    private const RESERVED = ['level', 'ts', 'msg', 'channel'];

    public function format(LogRecord $record): string
    {
        $fields = [];
        foreach ([$record->extra, $record->context] as $part) {
            $normalized = $this->normalize($part);
            if (is_array($normalized)) {
                $fields = array_merge($fields, $normalized);
            }
        }
        $fields = array_diff_key($fields, array_flip(self::RESERVED));
        $line = [
            'level' => $record->level->toPsrLogLevel(),
            'ts' => $record->datetime->setTimezone(new DateTimeZone('UTC'))->format('Y-m-d\TH:i:s.v\Z'),
            'msg' => $record->message,
            'channel' => $record->channel,
        ] + $fields;

        return $this->toJson($line, true)."\n";
    }
}
