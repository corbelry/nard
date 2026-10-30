<?php

namespace App\Services\Push;

/** A localized push for one device token. */
final readonly class PushMessage
{
    /** @param array<string, string> $data string values only (FCM data payload) */
    public function __construct(
        public string $token,
        public string $platform,
        public string $title,
        public string $body,
        public array $data = [],
    ) {}
}
