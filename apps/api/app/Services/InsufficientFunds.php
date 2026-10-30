<?php

namespace App\Services;

use RuntimeException;

/** A debit would make a balance negative. */
class InsufficientFunds extends RuntimeException {}
