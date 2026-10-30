<?php

return [
    // Shared with the game server, which verifies tickets (docs/PROTOCOL.md).
    'ticket_secret' => env('GAME_TICKET_SECRET', ''),
    'ticket_ttl' => 300,

    // 15.3: an account is deleted this many days after the request.
    'deletion_grace_days' => 30,

    // Where the API pushes tournament pairings (signed with the same secret).
    'game_server_url' => env('GAME_SERVER_URL', ''),

    // Proxies whose X-Forwarded-For is trusted ("*" = the immediate peer,
    // or a comma-separated IP/CIDR list); the ingress in Kubernetes.
    'trusted_proxies' => env('TRUSTED_PROXIES', ''),

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
