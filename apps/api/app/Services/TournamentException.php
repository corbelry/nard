<?php

namespace App\Services;

use RuntimeException;

/** A tournament action was refused; the message is the API error code. */
class TournamentException extends RuntimeException
{
    public function __construct(string $code, public readonly int $status = 422)
    {
        parent::__construct($code);
    }
}
