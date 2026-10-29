<?php

// Placeholder numbers until the owner confirms them (docs/QUESTIONS.md).
return [
    // Per finished online match and per player: [coins, xp].
    'match' => [
        'ranked' => ['win' => [60, 40], 'loss' => [15, 15]],
        'casual' => ['win' => [30, 25], 'loss' => [10, 10]],
        'bot' => ['win' => [15, 15], 'loss' => [5, 5]],
    ],
    // Mars / koks bonus for the winner.
    'gammon_bonus' => [10, 5],

    // XP needed to go from level n to n+1: base + step * (n - 1).
    'level_xp' => ['base' => 100, 'step' => 50],
    // Coins on reaching a level: per_level * level.
    'level_up_coins' => 20,

    // Login streak rewards for days 1..7, then the cycle repeats.
    'streak_coins' => [20, 30, 40, 50, 60, 80, 150],

    // Missions: event => counted per finished match.
    'missions' => [
        'daily' => [
            'daily_play_3' => ['event' => 'play', 'target' => 3, 'coins' => 50, 'xp' => 30],
            'daily_win_2' => ['event' => 'win', 'target' => 2, 'coins' => 80, 'xp' => 40],
            'daily_mars_1' => ['event' => 'mars', 'target' => 1, 'coins' => 100, 'xp' => 50],
        ],
        'weekly' => [
            'weekly_play_15' => ['event' => 'play', 'target' => 15, 'coins' => 300, 'xp' => 150],
            'weekly_ranked_win_5' => ['event' => 'ranked_win', 'target' => 5, 'coins' => 400, 'xp' => 200],
        ],
    ],

    // Achievements: id => [event, target, title item granted or null].
    'achievements' => [
        'first_win' => ['event' => 'win', 'target' => 1, 'title' => null],
        'wins_10' => ['event' => 'win', 'target' => 10, 'title' => 'title.regular'],
        'wins_100' => ['event' => 'win', 'target' => 100, 'title' => 'title.veteran'],
        'mars_10' => ['event' => 'mars', 'target' => 10, 'title' => 'title.mars_master'],
        'ranked_wins_25' => ['event' => 'ranked_win', 'target' => 25, 'title' => 'title.contender'],
    ],
];
