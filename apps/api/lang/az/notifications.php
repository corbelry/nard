<?php

// Push copy (docs/design-notes/notifications.md §5). Placeholders are
// filled by App\Services\Notifier::copy().
return [
    'friend_request' => ['title' => 'Dostluq sorğusu', 'body' => ':name dostluq sorğusu göndərdi'],
    'friend_accepted' => ['title' => 'Yeni dost', 'body' => ':name dostluq sorğunu qəbul etdi'],
    'challenge' => ['title' => 'Oyun dəvəti', 'body' => ':name səni oyuna çağırır · :variant, :points xal, :time'],
    'clan_invite' => ['title' => 'Klan dəvəti', 'body' => ':name səni :clan [:tag] klanına dəvət edir'],
    'clan_joined' => ['title' => 'Klana qəbul olundun', 'body' => ':clan [:tag] klanına xoş gəldin!'],
    'clan_war' => ['title' => 'Klan döyüşü başladı', 'body' => 'Həftənin rəqibi: :opponent [:tag]. Hər qələbə klana xal gətirir.'],
    'tournament_reminder' => ['title' => 'Turnir başlayır', 'body' => ':tournament :minutes dəqiqəyə başlayır.'],
    'tournament_started' => ['title' => 'Turnir başladı', 'body' => ':tournament başladı. İlk oyunun hazırdır.'],
    'tournament_round' => ['title' => 'Raund hazırdır', 'body' => ':tournament · Raund :round. Rəqib: :opponent.'],
    'tournament_eliminated' => ['title' => 'Turnirdə mübarizə bitdi', 'body' => ':tournament · Raund :round, yerin: :place. Növbəti turnirdə uğurlar!'],
    'tournament_won' => ['title' => 'Çempion!', 'body' => ':tournament qalibisən. Mükafatın hesabındadır.'],
    'tournament_finished' => ['title' => 'Turnir bitdi', 'body' => ':tournament · Yerin: :place.'],
    'season_end' => ['title' => 'Sezon :season bitdi', 'body' => 'Dərəcən: :tier, yerin: #:rank. Mükafat: :coins sikkə.'],
    'tournament_cancelled' => ['title' => 'Turnir ləğv edildi', 'body' => ':tournament ləğv edildi.', 'body_refund' => ':tournament ləğv edildi. :refund sikkə geri qaytarıldı.'],
    'season_started' => ['title' => 'Sezon :season başladı', 'body' => 'Yeni sezon keçidi və mükafatlar səni gözləyir.'],
    'level_up' => ['title' => 'Yeni səviyyə', 'body' => 'Səviyyə :level!'],
    'moderation_warning' => ['title' => 'Moderatorlardan xəbərdarlıq', 'body' => 'Zəhmət olmasa ədalətli oyun qaydalarına əməl edin. Səbəb: :reason'],
    'variants' => ['shortNard' => 'Qısa nərd', 'longNard' => 'Uzun nərd'],
    'times' => ['blitz' => 'Blits 1+8s', 'rapid' => 'Sürətli 3+12s', 'classic' => 'Klassik 5+15s'],
    'tiers' => [
        'bronze' => 'Bürünc', 'silver' => 'Gümüş', 'gold' => 'Qızıl', 'platinum' => 'Platin',
        'diamond' => 'Almaz', 'master' => 'Master', 'grandmaster' => 'Qrossmeyster',
    ],
];
