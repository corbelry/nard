<?php

// Push notifications (spec §8.11, ADR-041). Sending is disabled until the
// owner adds Firebase credentials: with no project id or service-account
// file, the NullPushSender logs and drops every push (the inbox still
// fills). iOS goes through FCM as well (APNs key uploaded to Firebase).
return [
    'fcm' => [
        'project_id' => env('FCM_PROJECT_ID'),
        // Path to the Firebase service-account JSON (never committed).
        'credentials' => env('FCM_CREDENTIALS'),
        'timeout' => 10,
    ],

    // Default quiet hours (16.1): pushes inside them are dropped.
    'quiet_hours' => ['enabled' => true, 'start' => '23:00', 'end' => '08:00'],

    // Inbox rows older than this are pruned daily.
    'retention_days' => 60,

    // Notification type → settings category (16.1). Types without a
    // category always reach the inbox and never push.
    'types' => [
        'friend_request' => 'friend_requests',
        'friend_accepted' => 'friend_requests',
        'challenge' => 'game_invites',
        'clan_invite' => 'clan',
        'clan_joined' => 'clan',
        'clan_war' => 'clan_war',
        'tournament_reminder' => 'tournament_start',
        'tournament_started' => 'tournament_start',
        'tournament_round' => 'tournament_round',
        'tournament_eliminated' => 'tournament_round',
        'tournament_won' => 'tournament_round',
        'tournament_finished' => 'tournament_round',
        'season_end' => 'rewards',
        // Earned with the app open (match end screen): inbox only.
        'level_up' => null,
        // Admin warning (ADR-042): inbox only.
        'moderation_warning' => null,
    ],

    'categories' => [
        'game_invites', 'tournament_start', 'tournament_round',
        'friend_requests', 'clan', 'clan_war', 'rewards',
    ],

    // Tournament start reminder lead time (16.1 "15 dəqiqə əvvəl").
    'tournament_reminder_minutes' => 15,
];
