<?php

return [
    'currencies' => ['coins', 'gems'],

    // Reasons that may credit each currency. Coins are earn-only: no reason
    // tied to money may grant them (ADR-022). `season` = free pass track and
    // season-end rewards; `season_premium` = the paid premium track, never
    // allowed for coins (ADR-039).
    'credit_reasons' => [
        'coins' => ['match_reward', 'mission', 'achievement', 'streak', 'level_up', 'tournament', 'season', 'refund', 'admin'],
        'gems' => ['iap', 'season', 'season_premium', 'refund', 'admin'],
    ],

    'item_categories' => [
        'board', 'checkers', 'dice', 'dice_cup', 'table', 'cube',
        'sound_pack', 'emote_pack', 'avatar_frame', 'title', 'win_effect',
    ],

    'rarities' => ['common', 'rare', 'epic', 'legendary', 'seasonal', 'tournament'],

    'max_loadouts' => 5,

    // 7.3 featured offer ("Kral dəsti" in the design: 1 800, was 2 400).
    'featured' => ['item' => 'board.marble_royale', 'oldPrice' => ['gems' => 2400]],
];
