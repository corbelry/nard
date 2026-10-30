<?php

// Push copy (docs/design-notes/notifications.md §5).
return [
    'friend_request' => ['title' => 'Заявка в друзья', 'body' => ':name отправил(а) вам заявку в друзья'],
    'friend_accepted' => ['title' => 'Новый друг', 'body' => ':name принял(а) вашу заявку в друзья'],
    'challenge' => ['title' => 'Приглашение в игру', 'body' => ':name зовёт вас сыграть · :variant, до :points очков, :time'],
    'clan_invite' => ['title' => 'Приглашение в клан', 'body' => ':name приглашает вас в клан :clan [:tag]'],
    'clan_joined' => ['title' => 'Вы в клане', 'body' => 'Добро пожаловать в :clan [:tag]!'],
    'clan_war' => ['title' => 'Война кланов началась', 'body' => 'Соперник недели: :opponent [:tag]. Каждая победа приносит очки клану.'],
    'tournament_reminder' => ['title' => 'Скоро турнир', 'body' => ':tournament начнётся через :minutes мин.'],
    'tournament_started' => ['title' => 'Турнир начался', 'body' => ':tournament начался. Ваш первый матч готов.'],
    'tournament_round' => ['title' => 'Раунд готов', 'body' => ':tournament · Раунд :round. Соперник: :opponent.'],
    'tournament_eliminated' => ['title' => 'Турнир для вас окончен', 'body' => ':tournament · Раунд :round. Удачи в следующем!'],
    'tournament_won' => ['title' => 'Чемпион!', 'body' => 'Вы выиграли :tournament. Приз уже на счёте.'],
    'tournament_finished' => ['title' => 'Турнир окончен', 'body' => ':tournament · Ваше место: :place.'],
    'season_end' => ['title' => 'Сезон :season завершён', 'body' => 'Ваша лига: :tier. Посмотрите итоги и награду.'],
    'level_up' => ['title' => 'Новый уровень', 'body' => 'Уровень :level!'],
    'moderation_warning' => ['title' => 'Предупреждение модераторов', 'body' => 'Пожалуйста, соблюдайте правила честной игры. Причина: :reason'],
    'variants' => ['shortNard' => 'Короткие нарды', 'longNard' => 'Длинные нарды'],
    'times' => ['blitz' => 'Блиц 1+8 с', 'rapid' => 'Рапид 3+12 с', 'classic' => 'Классика 5+15 с'],
    'tiers' => [
        'bronze' => 'Бронза', 'silver' => 'Серебро', 'gold' => 'Золото', 'platinum' => 'Платина',
        'diamond' => 'Алмаз', 'master' => 'Мастер', 'grandmaster' => 'Гроссмейстер',
    ],
];
