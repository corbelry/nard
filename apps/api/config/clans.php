<?php

// Clans (spec §8.4). Numbers from the design (docs/design-notes/social.md
// §6 and §11); awaiting the owner's confirmation.
return [
    // Coins, debited through WalletService (coins are earn-only, ADR-022).
    'create_price' => 3000,
    // Changing name and/or tag later (leader only).
    'rename_price' => 1000,

    'max_members' => 50,

    'name' => ['min' => 3, 'max' => 24],
    // 3–5 letters A–Z, stored uppercase (19.1).
    'tag_pattern' => '/^[A-Z]{3,5}$/',
    'description_max' => 200,
    'languages' => ['az', 'en', 'ru', 'tr'],
    'join_policies' => ['open', 'request', 'invite'],
    // null = anyone ("Hamı"); else checked against the player's best rating.
    'min_rating' => ['min' => 0, 'max' => 2400],

    // Emblem catalogue (5.3 / 19.1). The client owns the drawing data.
    'emblem' => [
        'shapes' => ['shield', 'hexagon', 'octagon', 'circle', 'diamond', 'banner', 'star', 'arch'],
        'colors' => ['garnet', 'indigo', 'emerald', 'brass', 'purple', 'slate', 'ivory', 'blue', 'walnut'],
        'symbols' => ['diamond', 'diamond_dot', 'circle', 'square', 'initials'],
        'patterns' => ['none', 'lattice'],
    ],

    // Roles, highest first.
    'roles' => ['leader', 'co_leader', 'elder', 'member'],

    'invite_ttl_days' => 7,

    'chat' => [
        'max_length' => 300,
        // Messages per GET.
        'page' => 50,
        // Messages per member per minute.
        'per_minute' => 10,
    ],

    // Weekly shared chest (5.4): coin donations, Monday–Sunday UTC. Member
    // rewards for a full chest are an open question: none are paid yet.
    'chest' => [
        'weekly_target' => 10000,
        'min_donation' => 10,
    ],

    // Clan XP sources.
    'xp' => [
        // A member wins an online match against a human from another clan.
        'online_win' => 10,
        // 1 XP per this many donated coins.
        'coins_per_xp' => 10,
        // The weekly chest reaches its target.
        'chest_full' => 500,
        // The clan wins its weekly war.
        'war_win' => 1000,
    ],

    // Total clan XP needed to reach level n (index 0 = level 1).
    'levels' => [0, 1000, 2500, 4500, 7000, 10000, 14000, 19000, 25000, 32000, 40000, 50000, 62000, 76000, 92000],

    // Weekly wars (5.6), Monday–Sunday UTC, paired by `clans:pair-wars`.
    'war' => [
        // A member's online win against a member of the opposing clan.
        'points_per_win' => 3,
        // Counted matches per war (5.6 "25 matçdan").
        'max_matches' => 25,
        // Eligibility: members, and someone seen within this many days.
        'min_members' => 2,
        'active_days' => 7,
        // Pairing skips neighbours further apart than this many levels.
        'max_level_gap' => 3,
    ],
];
