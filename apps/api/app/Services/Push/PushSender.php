<?php

namespace App\Services\Push;

/** Delivers one push to one device (ADR-041). */
interface PushSender
{
    /** False while push is not configured: nothing is queued or sent. */
    public function enabled(): bool;

    public function send(PushMessage $message): PushResult;
}
