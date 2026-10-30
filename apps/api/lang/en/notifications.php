<?php

// Push copy (docs/design-notes/notifications.md §5).
return [
    'friend_request' => ['title' => 'Friend request', 'body' => ':name sent you a friend request'],
    'friend_accepted' => ['title' => 'New friend', 'body' => ':name accepted your friend request'],
    'challenge' => ['title' => 'Game invite', 'body' => ':name invites you to play · :variant, :points points, :time'],
    'clan_invite' => ['title' => 'Clan invite', 'body' => ':name invites you to the clan :clan [:tag]'],
    'clan_joined' => ['title' => 'You joined a clan', 'body' => 'Welcome to :clan [:tag]!'],
    'clan_war' => ['title' => 'Clan war started', 'body' => "This week's opponent: :opponent [:tag]. Every win scores for your clan."],
    'tournament_reminder' => ['title' => 'Tournament starting', 'body' => ':tournament starts in :minutes minutes.'],
    'tournament_started' => ['title' => 'Tournament started', 'body' => ':tournament has started. Your first match is ready.'],
    'tournament_round' => ['title' => 'Round ready', 'body' => ':tournament · Round :round. Opponent: :opponent.'],
    'tournament_eliminated' => ['title' => 'Your tournament run is over', 'body' => ':tournament · Round :round, place :place. Good luck in the next one!'],
    'tournament_won' => ['title' => 'Champion!', 'body' => 'You won :tournament. Your prize is in your account.'],
    'tournament_finished' => ['title' => 'Tournament over', 'body' => ':tournament · Your place: :place.'],
    'season_end' => ['title' => 'Season :season is over', 'body' => 'Your tier: :tier, rank #:rank. Reward: :coins coins.'],
    'tournament_cancelled' => ['title' => 'Tournament cancelled', 'body' => ':tournament was cancelled.', 'body_refund' => ':tournament was cancelled. :refund coins were refunded.'],
    'season_started' => ['title' => 'Season :season has begun', 'body' => 'A new season pass and new rewards are waiting.'],
    'level_up' => ['title' => 'Level up', 'body' => 'Level :level!'],
    'moderation_warning' => ['title' => 'Warning from the moderators', 'body' => 'Please follow the fair-play rules. Reason: :reason'],
    'variants' => ['shortNard' => 'Short Nard', 'longNard' => 'Long Nard'],
    'times' => ['blitz' => 'Blitz 1+8s', 'rapid' => 'Rapid 3+12s', 'classic' => 'Classic 5+15s'],
    'tiers' => [
        'bronze' => 'Bronze', 'silver' => 'Silver', 'gold' => 'Gold', 'platinum' => 'Platinum',
        'diamond' => 'Diamond', 'master' => 'Master', 'grandmaster' => 'Grandmaster',
    ],
];
