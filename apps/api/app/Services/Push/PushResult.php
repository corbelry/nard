<?php

namespace App\Services\Push;

enum PushResult
{
    case Sent;
    // The token is gone (app removed, token rotated): forget it.
    case InvalidToken;
    case Failed;
    case Skipped;
}
