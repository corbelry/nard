<?php

// Aligned with the numbers in the design (docs/design-notes/store.md §10);
// awaiting the owner's confirmation (docs/QUESTIONS.md).
return [
    // Per finished online match and per player: [coins, xp] for a 5-point
    // match, scaled linearly by match length (1 point = 1/5).
    'match' => [
        'ranked' => ['win' => [250, 120], 'loss' => [60, 40]],
        'casual' => ['win' => [150, 80], 'loss' => [40, 30]],
        // Tournament matches pay like casual ones; walkovers pay nothing.
        'tournament' => ['win' => [150, 80], 'loss' => [40, 30]],
        'bot' => ['win' => [60, 40], 'loss' => [15, 15]],
    ],
    'match_reference_length' => 5,
    // Mars / koks bonus for the winner (flat).
    'gammon_bonus' => [20, 10],

    // XP from level n to n+1: base + step * (n - 1) → 1 500 at level 24.
    'level_xp' => ['base' => 350, 'step' => 50],
    // Coins on every level-up (12.3 shows +200).
    'level_up_coins' => 200,

    // Login streak, days 1..7, then the cycle repeats. Day 7 is the design's
    // "Sandıq": fixed, visible contents (no loot boxes, spec §8.7).
    'streak_coins' => [20, 30, 40, 50, 60, 80, 150],

    // Missions: event => counted per finished match (12.1). The design's
    // practice-puzzle mission waits for Phase 6 puzzles.
    'missions' => [
        'daily' => [
            'daily_doubles_3' => ['event' => 'doubles', 'target' => 3, 'coins' => 40, 'xp' => 20],
            'daily_ranked_win_3' => ['event' => 'ranked_win', 'target' => 3, 'coins' => 60, 'xp' => 30],
            'daily_cube_take_win_1' => ['event' => 'cube_take_win', 'target' => 1, 'coins' => 80, 'xp' => 40],
            'daily_long_play_1' => ['event' => 'long_play', 'target' => 1, 'coins' => 30, 'xp' => 15],
        ],
        'weekly' => [
            'weekly_ranked_win_5' => ['event' => 'ranked_win', 'target' => 5, 'coins' => 400, 'xp' => 200],
            'weekly_mars_3' => ['event' => 'mars', 'target' => 3, 'coins' => 300, 'xp' => 150],
            'weekly_play_15' => ['event' => 'play', 'target' => 15, 'coins' => 300, 'xp' => 150],
        ],
    ],
    // Completing every daily mission: the design's "Günlük sandıq", fixed.
    'daily_bonus_coins' => 100,

    // Achievements: id => [event counter, target, title item granted or null].
    'achievements' => [
        'first_win' => ['event' => 'win', 'target' => 1, 'title' => null],
        'wins_10' => ['event' => 'win', 'target' => 10, 'title' => 'title.regular'],
        'wins_100' => ['event' => 'win', 'target' => 100, 'title' => 'title.veteran'],
        'games_1000' => ['event' => 'play', 'target' => 1000, 'title' => null],
        'mars_10' => ['event' => 'mars', 'target' => 10, 'title' => 'title.mars_master'],
        'ranked_wins_25' => ['event' => 'ranked_win', 'target' => 25, 'title' => 'title.contender'],
        'streak_10' => ['event' => 'streak', 'target' => 10, 'title' => null],
    ],
];
