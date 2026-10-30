<?php

// Seasons, season pass and leaderboards (spec §8.2, §8.7; design
// docs/design-notes/tournaments.md §9–§10, §17 #34–#43; ADR-039). Numbers
// follow the design and await the owner's confirmation (QUESTIONS #37).
// A new season copies `pass` and `end_rewards` into its row, so changing
// them here only affects seasons that have not started yet.

// Free track: coins on every level. The design's window (17: 200, 19: 300)
// sets the odd levels; even levels pay 100 and every 10th level 500.
$free = [];
for ($level = 1; $level <= 50; $level++) {
    $free[$level] = ['kind' => 'coins', 'amount' => match (true) {
        $level % 10 === 0 => 500,
        $level % 2 === 0 => 100,
        $level % 4 === 1 => 200,
        default => 300,
    }];
}

// Premium track: never coins (ADR-022, enforced by the ledger: premium
// rewards are credited with reason `season_premium`, which may not credit
// coins). Yaqut 50 on levels ending in 3 or 8 (design: 50 at 18, 500 in
// total) and the season's cosmetics every 10 levels; other levels are empty
// until more seasonal cosmetics ship (checkers/dice categories, ADR-034).
$premium = [];
for ($level = 3; $level <= 50; $level += 5) {
    $premium[$level] = ['kind' => 'gems', 'amount' => 50];
}
$premium[10] = ['kind' => 'item', 'item' => 'title.caspian_voyager'];
$premium[20] = ['kind' => 'item', 'item' => 'avatar_frame.caspian'];
// Caspian: level 30 as on the Locker / item detail ("Sezon · Səv. 30"); the
// pass mock's level 19 was a sample window (ADR-039, QUESTIONS #26).
$premium[30] = ['kind' => 'item', 'item' => 'board.caspian'];
// Marble Royale: "Sezon bileti · Premium · Səviyyə 40" (3.2).
$premium[40] = ['kind' => 'item', 'item' => 'board.marble_royale'];
$premium[50] = ['kind' => 'item', 'item' => 'avatar_frame.caspian_pearl'];
ksort($premium);

return [
    // ~6 weeks (spec §8.2); a season ends at midnight UTC.
    'length_days' => 42,

    // Season names, cycled by number (per-locale maps).
    'names' => [
        ['az' => 'Xəzər', 'en' => 'Caspian'],
        ['az' => 'Novruz', 'en' => 'Novruz'],
        ['az' => 'Qafqaz', 'en' => 'Caucasus'],
        ['az' => 'Şirvan', 'en' => 'Shirvan'],
    ],

    // Soft reset at season end: rating = pivot + (rating − pivot) × factor.
    // Peak ratings are kept.
    'soft_reset' => ['pivot' => 1500, 'factor' => 0.5],

    // Ranked matches needed for a final season rank and the season-end
    // reward (played in that season), and to appear on leaderboards
    // (lifetime, 6.5 "unranked players are not listed").
    'min_matches' => 5,

    'leaderboard_size' => 100,

    // Season-end rewards by the best final tier over both variants
    // (design 7.1: Almaz = frame + 2 000 coins). Items are granted if seeded.
    'end_rewards' => [
        'bronze' => ['coins' => 100, 'item' => null],
        'silver' => ['coins' => 300, 'item' => null],
        'gold' => ['coins' => 600, 'item' => null],
        'platinum' => ['coins' => 1000, 'item' => null],
        'diamond' => ['coins' => 2000, 'item' => 'avatar_frame.season_diamond'],
        'master' => ['coins' => 3000, 'item' => 'avatar_frame.season_master'],
        'grandmaster' => ['coins' => 5000, 'item' => 'avatar_frame.season_grandmaster'],
    ],

    'pass' => [
        'levels' => 50,
        'xp_per_level' => 1000,
        // One-off Yaqut purchase per season (ADR-025).
        'premium_gems' => 950,
        'free' => $free,
        'premium' => $premium,
    ],
];
