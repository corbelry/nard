<?php

namespace App\Services;

use RuntimeException;

/** A clan action was refused; the message is the API error code. */
class ClanException extends RuntimeException
{
    /** @param array<string, mixed> $extra */
    public function __construct(string $code, public readonly int $status = 422, public readonly array $extra = [])
    {
        parent::__construct($code);
    }
}
