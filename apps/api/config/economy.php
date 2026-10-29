<?php

return [
    'currencies' => ['coins', 'gems'],

    // Reasons that may credit each currency. Coins are earn-only: no reason
    // tied to money may grant them (ADR-022).
    'credit_reasons' => [
        'coins' => ['match_reward', 'mission', 'achievement', 'streak', 'level_up', 'refund', 'admin'],
        'gems' => ['iap', 'refund', 'admin'],
    ],

    'item_categories' => [
        'board', 'checkers', 'dice', 'dice_cup', 'table', 'cube',
        'sound_pack', 'emote_pack', 'avatar_frame', 'title', 'win_effect',
    ],

    'rarities' => ['common', 'rare', 'epic', 'legendary', 'seasonal', 'tournament'],

    'max_loadouts' => 5,
];
