<?php

// Moderation and fair-play signals (spec §8.13, §8.14, ADR-042). The
// anti-cheat thresholds are first guesses: calibrate them on real data
// before acting on flags automatically (only abandonment acts on its own).
return [
    // Admin coin/gem grants above this need splitting (typo guard).
    'max_grant' => 100_000,

    // Mute presets offered in the admin panel, in hours.
    'mute_hours' => [1, 24, 72, 168],

    // `anticheat:scan` runs daily (routes/console.php).
    'engine' => [
        // Move-quality CLI reading match JSON lines on stdin
        // (packages/nard_ai/tool/move_quality.dart). Unset: the engine
        // check runs only with `--engine=<results file>`.
        'command' => env('MOVE_QUALITY_CMD'),
        'timeout' => 1800,
        // Ranked matches from the last N days are analysed.
        'days' => 30,
        'max_matches' => 5000,
        'min_matches' => 10,
        'min_decisions' => 150,
        // Expected agreement with HeuristicBot(hard) by rating band
        // [lower bound, agreement]; flag at expected + margin.
        'bands' => [[0, 0.55], [1400, 0.60], [1600, 0.65], [1800, 0.70], [2000, 0.75]],
        'margin' => 0.15,
    ],

    // Accounts sharing an IP or device that meet in ranked play. Sign-in
    // sightings (hashed IP / device id) are kept this long.
    'multi_account' => [
        'days' => 30,
        'retention_days' => 90,
        'min_ranked_matches' => 2,
    ],

    // Losses by abandonment or timeout → a matchmaking cooldown.
    'abandonment' => [
        'days' => 14,
        'min_matches' => 10,
        'rate' => 0.3,
        'cooldown_hours' => 24,
    ],

    // Many distinct reporters within the window.
    'reports' => [
        'days' => 7,
        'distinct_reporters' => 5,
    ],
];
