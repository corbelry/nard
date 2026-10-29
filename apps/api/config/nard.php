<?php

return [
    // Shared with the game server, which verifies tickets (docs/PROTOCOL.md).
    'ticket_secret' => env('GAME_TICKET_SECRET', ''),
    'ticket_ttl' => 300,

    'login_code_ttl' => 600,
    'login_code_attempts' => 5,

    // Apple / Google sign-in stay off until the owner adds keys (ADR-030).
    'providers' => [
        'apple' => (bool) env('APPLE_SIGNIN_ENABLED', false),
        'google' => (bool) env('GOOGLE_SIGNIN_ENABLED', false),
    ],

    'rating' => [
        'initial' => 1500,
    ],

    'variants' => ['shortNard', 'longNard'],
];
