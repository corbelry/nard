<?php

// Push copy (docs/design-notes/notifications.md §5).
return [
    'friend_request' => ['title' => 'Arkadaşlık isteği', 'body' => ':name sana arkadaşlık isteği gönderdi'],
    'friend_accepted' => ['title' => 'Yeni arkadaş', 'body' => ':name arkadaşlık isteğini kabul etti'],
    'challenge' => ['title' => 'Oyun daveti', 'body' => ':name seni oyuna çağırıyor · :variant, :points sayı'],
    'clan_invite' => ['title' => 'Klan daveti', 'body' => ':name seni :clan [:tag] klanına davet ediyor'],
    'clan_joined' => ['title' => 'Klana katıldın', 'body' => ':clan [:tag] klanına hoş geldin!'],
    'clan_war' => ['title' => 'Klan savaşı başladı', 'body' => 'Haftanın rakibi: :opponent [:tag]. Her galibiyet klana puan kazandırır.'],
    'tournament_reminder' => ['title' => 'Turnuva başlıyor', 'body' => ':tournament :minutes dakika sonra başlıyor.'],
    'tournament_started' => ['title' => 'Turnuva başladı', 'body' => ':tournament başladı. İlk maçın hazır.'],
    'tournament_round' => ['title' => 'Tur hazır', 'body' => ':tournament · Tur :round. Rakip: :opponent.'],
    'tournament_eliminated' => ['title' => 'Turnuva senin için bitti', 'body' => ':tournament · Tur :round. Bir sonrakinde bol şans!'],
    'tournament_won' => ['title' => 'Şampiyon!', 'body' => ':tournament şampiyonu sensin. Ödülün hesabında.'],
    'tournament_finished' => ['title' => 'Turnuva bitti', 'body' => ':tournament · Sıran: :place.'],
    'season_end' => ['title' => 'Sezon :season bitti', 'body' => 'Ligin: :tier. Sonuçlarına ve ödülüne bak.'],
    'level_up' => ['title' => 'Yeni seviye', 'body' => 'Seviye :level!'],
    'variants' => ['shortNard' => 'Tavla', 'longNard' => 'Uzun tavla'],
    'tiers' => [
        'bronze' => 'Bronz', 'silver' => 'Gümüş', 'gold' => 'Altın', 'platinum' => 'Platin',
        'diamond' => 'Elmas', 'master' => 'Usta', 'grandmaster' => 'Büyük Usta',
    ],
];
