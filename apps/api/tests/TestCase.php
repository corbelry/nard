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
