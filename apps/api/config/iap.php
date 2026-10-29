<?php

return [
    // Server-side receipt validation (spec §8.7) stays off until the owner
    // has Google Play / App Store accounts (like ADR-030).
    'enabled' => (bool) env('IAP_ENABLED', false),

    // Local development only: receipts starting with "test-" are accepted.
    // Ignored outside APP_ENV=local/testing.
    'fake' => (bool) env('IAP_FAKE', false),

    // Yaqut packs (ADR-023, ADR-025: one-off purchases, no subscription).
    // Store product id => gems granted. Prices live in the stores.
    'products' => [
        'yaqut_80' => 80,
        'yaqut_500' => 500,
        'yaqut_1200' => 1200,
        'yaqut_2600' => 2600,
    ],
];
