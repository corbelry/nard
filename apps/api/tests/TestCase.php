<?php

namespace Tests;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Foundation\Testing\TestCase as BaseTestCase;
use Illuminate\Testing\PendingCommand;

abstract class TestCase extends BaseTestCase
{
    /**
     * `artisan()` typed for static analysis (it never returns an int here).
     *
     * @param  array<string, mixed>  $parameters
     */
    protected function runCommand(string $command, array $parameters = []): PendingCommand
    {
        $pending = $this->artisan($command, $parameters);
        $this->assertInstanceOf(PendingCommand::class, $pending);

        return $pending;
    }

    /**
     * assertSame that ignores the key order of associative arrays at every
     * level (MySQL normalizes the key order of JSON columns; lists keep
     * their order).
     */
    protected function assertSameIgnoringKeyOrder(mixed $expected, mixed $actual, string $message = ''): void
    {
        $this->assertSame(self::sortKeys($expected), self::sortKeys($actual), $message);
    }

    private static function sortKeys(mixed $value): mixed
    {
        if (! is_array($value)) {
            return $value;
        }
        $value = array_map(self::sortKeys(...), $value);
        if (! array_is_list($value)) {
            ksort($value);
        }

        return $value;
    }

    /**
     * The model re-read from the database (it must still exist).
     *
     * @template T of Model
     *
     * @param  T  $model
     * @return T
     */
    protected function reload(Model $model): Model
    {
        $fresh = $model->fresh();
        $this->assertNotNull($fresh);

        return $fresh;
    }
}
