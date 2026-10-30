<?php

// Tournaments (spec §8.3, docs/design-notes/tournaments.md, QUESTIONS #33–36).
// Tournament matches never change ratings; coins are earn-only (ADR-022):
// entry fees are ledger debits, prizes ledger credits ('tournament').
return [
    'formats' => ['knockout', 'swiss', 'round_robin'],

    // An absent player loses by walkover after this many seconds (owner,
    // QUESTIONS #35: 3 minutes).
    'no_show_seconds' => 180,
    // Pairings the game server has not reported on are pushed again (the
    // game server ignores matches it already knows).
    'repush_after_minutes' => 10,
    // Casual-style clock for every tournament match (QUESTIONS #20).
    'clock' => ['reserveMs' => 180_000, 'delayMs' => 12_000],

    // Sit-and-go (21.x): starts when full; 10 % of the entries is withheld
    // (coin sink); unfilled tables are cancelled with a full refund (#36).
    'sng' => [
        'sizes' => [8, 16, 32],
        'variant' => 'shortNard',
        'match_length' => 3,
        'entry_coins' => 500,
        'rake_percent' => 10,
        'fill_minutes' => 10,
        'name' => ['az' => 'Sit-and-go', 'en' => 'Sit-and-go'],
        // [from place, to place, percent of the fund for each place]; the
        // rounding remainder goes to the winner.
        'split' => [
            8 => [[1, 1, 50], [2, 2, 30], [3, 4, 10]],
            16 => [[1, 1, 40], [2, 2, 24], [3, 4, 10], [5, 8, 4]],
            32 => [[1, 1, 34], [2, 2, 20], [3, 4, 9], [5, 8, 4], [9, 16, 1.5]],
        ],
    ],

    // Private tournaments (22.x): knockout, free entry only (#34), unrated.
    'private' => [
        'sizes' => [4, 8, 16, 32],
        'min_players' => 2,
        // Open (registering) private tournaments one player may organise.
        'max_open' => 3,
        // Without a start time an unstarted tournament is cancelled after this.
        'expire_hours' => 24,
        'max_days_ahead' => 30,
        'name' => ['min' => 3, 'max' => 40],
    ],

    // Scheduled championships created by `tournaments:schedule` (times UTC;
    // 16:00 UTC = 20:00 Baku). Prizes are house-funded (#36): fixed and shown
    // before registration. Each prize row is [from, to, coins, item ids].
    'schedule' => [
        'daily_cup' => [
            'name' => ['az' => 'Gündəlik Kubok', 'en' => 'Daily Cup'],
            'format' => 'knockout',
            'variant' => 'shortNard',
            'match_length' => 3,
            'size' => 32,
            'min_players' => 4,
            'entry_coins' => 0,
            'every' => 'day',
            'at' => '16:00',
            'prizes' => [[1, 1, 3000, []], [2, 2, 1500, []], [3, 4, 750, []]],
        ],
        'friday_cup' => [
            'name' => ['az' => 'Bakı Cümə Kuboku', 'en' => 'Baku Friday Cup'],
            'format' => 'knockout',
            'variant' => 'shortNard',
            'match_length' => 5,
            'size' => 64,
            'min_players' => 8,
            'entry_coins' => 500,
            'every' => 'week',
            'day' => 5,
            'at' => '16:00',
            'prizes' => [
                [1, 1, 25000, ['title.friday_champion', 'board.xatam']],
                [2, 2, 12000, ['board.xatam']],
                [3, 4, 6500, ['board.xatam']],
            ],
        ],
        'long_league' => [
            'name' => ['az' => 'Uzun Nərd Liqası', 'en' => 'Long Nard League'],
            'format' => 'swiss',
            'variant' => 'longNard',
            'match_length' => 5,
            'size' => 128,
            'swiss_rounds' => 7,
            'min_players' => 8,
            'entry_coins' => 0,
            'every' => 'week',
            'day' => 7,
            'at' => '16:00',
            'prizes' => [[1, 1, 8000, ['title.league_champion']], [2, 2, 5000, []], [3, 3, 3000, []], [4, 8, 800, []]],
        ],
    ],
];
