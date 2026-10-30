<?php

namespace App\Services;

use RuntimeException;

/** A refused puzzle action; the message is the API error code. */
class PuzzleException extends RuntimeException {}
