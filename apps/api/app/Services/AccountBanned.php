<?php

namespace App\Services;

use RuntimeException;

/** A banned account asked for something it may not have (e.g. a game ticket). */
class AccountBanned extends RuntimeException {}
