<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ClanController;
use App\Http\Controllers\Api\IapController;
use App\Http\Controllers\Api\MatchResultController;
use App\Http\Controllers\Api\MeController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\ProgressController;
use App\Http\Controllers\Api\PuzzleController;
use App\Http\Controllers\Api\SeasonController;
use App\Http\Controllers\Api\SocialController;
use App\Http\Controllers\Api\StoreController;
use App\Http\Controllers\Api\TournamentController;
use App\Http\Controllers\MetricsController;
use App\Http\Middleware\EnsureNotBanned;
use App\Http\Middleware\TouchLastSeen;
use App\Http\Middleware\VerifyGameServerSignature;
use App\Http\Middleware\VerifyMetricsToken;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function (): void {
    Route::middleware('throttle:20,1')->group(function (): void {
        Route::post('/auth/guest', [AuthController::class, 'guest']);
        Route::post('/auth/email/verify', [AuthController::class, 'emailVerify']);
        Route::post('/auth/{provider}', [AuthController::class, 'provider'])
            ->whereIn('provider', ['apple', 'google']);
    });
    Route::post('/auth/email/start', [AuthController::class, 'emailStart'])
        ->middleware('throttle:5,10');

    Route::middleware(['auth:sanctum', EnsureNotBanned::class, TouchLastSeen::class])->group(function (): void {
        Route::post('/auth/logout', [AuthController::class, 'logout']);
        Route::get('/me', [MeController::class, 'show']);
        Route::patch('/me', [MeController::class, 'update']);
        Route::delete('/me', [MeController::class, 'destroy']);
        Route::post('/me/export', [MeController::class, 'export'])->middleware('throttle:3,60');
        Route::get('/me/matches', [MeController::class, 'matches']);
        Route::get('/me/matches/{id}', [MeController::class, 'match']);
        Route::post('/game/ticket', [MeController::class, 'ticket'])->middleware('throttle:30,1');

        Route::get('/friends', [SocialController::class, 'friends']);
        Route::post('/friends/requests', [SocialController::class, 'request'])->middleware('throttle:30,1');
        Route::post('/friends/requests/{id}/accept', [SocialController::class, 'accept'])->whereNumber('id');
        Route::delete('/friends/requests/{id}', [SocialController::class, 'dismiss'])->whereNumber('id');
        Route::delete('/friends/{userId}', [SocialController::class, 'unfriend'])->whereNumber('userId');
        Route::post('/challenges', [SocialController::class, 'challenge'])->middleware('throttle:20,1');
        Route::get('/users/search', [SocialController::class, 'search'])->middleware('throttle:30,1');
        Route::get('/blocks', [SocialController::class, 'blocks']);
        Route::post('/blocks/{userId}', [SocialController::class, 'block'])->whereNumber('userId');
        Route::delete('/blocks/{userId}', [SocialController::class, 'unblock'])->whereNumber('userId');
        Route::post('/reports', [SocialController::class, 'report']);

        // Clans (spec §8.4).
        Route::get('/clans', [ClanController::class, 'index'])->middleware('throttle:60,1');
        Route::get('/clans/tag-available', [ClanController::class, 'tagAvailable'])->middleware('throttle:60,1');
        Route::get('/clans/leaderboard', [ClanController::class, 'leaderboard']);
        Route::post('/clans', [ClanController::class, 'store'])->middleware('throttle:10,1');
        Route::get('/me/clan-invites', [ClanController::class, 'myInvites']);
        Route::post('/me/clan-invites/{inviteId}/accept', [ClanController::class, 'acceptInvite'])->whereNumber('inviteId');
        Route::delete('/me/clan-invites/{inviteId}', [ClanController::class, 'declineInvite'])->whereNumber('inviteId');
        Route::prefix('/clans/{id}')->whereNumber('id')->group(function (): void {
            Route::get('/', [ClanController::class, 'show']);
            Route::patch('/', [ClanController::class, 'update'])->middleware('throttle:20,1');
            Route::delete('/', [ClanController::class, 'destroy']);
            Route::post('/join', [ClanController::class, 'join'])->middleware('throttle:20,1');
            Route::delete('/join', [ClanController::class, 'cancelJoin']);
            Route::post('/leave', [ClanController::class, 'leave']);
            Route::get('/requests', [ClanController::class, 'requests']);
            Route::post('/requests/{requestId}/accept', [ClanController::class, 'acceptRequest'])->whereNumber('requestId');
            Route::delete('/requests/{requestId}', [ClanController::class, 'declineRequest'])->whereNumber('requestId');
            Route::post('/invites', [ClanController::class, 'invite'])->middleware('throttle:30,1');
            Route::post('/members/{userId}/role', [ClanController::class, 'role'])->whereNumber('userId');
            Route::delete('/members/{userId}', [ClanController::class, 'kick'])->whereNumber('userId');
            Route::get('/messages', [ClanController::class, 'messages']);
            Route::post('/messages', [ClanController::class, 'post']);
            Route::delete('/messages/{messageId}', [ClanController::class, 'deleteMessage'])->whereNumber('messageId');
            Route::post('/donate', [ClanController::class, 'donate'])->middleware('throttle:30,1');
            Route::get('/war', [ClanController::class, 'war']);
        });

        // Tournaments (spec §8.3, docs/api/tournaments.md).
        Route::get('/tournaments', [TournamentController::class, 'index'])->middleware('throttle:60,1');
        Route::get('/tournaments/sng', [TournamentController::class, 'sitAndGo']);
        Route::post('/tournaments/sng/{size}/join', [TournamentController::class, 'joinSitAndGo'])
            ->whereNumber('size')->middleware('throttle:30,1');
        Route::post('/tournaments/private', [TournamentController::class, 'createPrivate'])->middleware('throttle:10,1');
        Route::post('/tournaments/join-by-code', [TournamentController::class, 'joinByCode'])->middleware('throttle:20,1');
        Route::prefix('/tournaments/{id}')->whereNumber('id')->group(function (): void {
            Route::get('/', [TournamentController::class, 'show']);
            Route::delete('/', [TournamentController::class, 'destroy']);
            Route::post('/register', [TournamentController::class, 'register'])->middleware('throttle:30,1');
            Route::delete('/register', [TournamentController::class, 'unregister']);
            Route::post('/start', [TournamentController::class, 'start']);
            Route::delete('/entrants/{userId}', [TournamentController::class, 'kick'])->whereNumber('userId');
        });

        // Seasons, season pass, leaderboards (docs/api/seasons.md).
        Route::get('/season', [SeasonController::class, 'show']);
        Route::get('/seasons', [SeasonController::class, 'index']);
        Route::get('/season/summary/{number?}', [SeasonController::class, 'summary'])->whereNumber('number');
        Route::post('/season/pass/premium', [SeasonController::class, 'premium'])->middleware('throttle:10,1');
        Route::post('/season/pass/claim', [SeasonController::class, 'claim'])->middleware('throttle:60,1');
        Route::post('/season/pass/claim-all', [SeasonController::class, 'claimAll'])->middleware('throttle:10,1');
        Route::get('/leaderboard', [SeasonController::class, 'leaderboard'])->middleware('throttle:60,1');

        // Practice puzzles (13.x).
        Route::get('/puzzles/next', [PuzzleController::class, 'next']);
        Route::get('/puzzles/daily', [PuzzleController::class, 'daily']);
        Route::post('/puzzles/{id}/attempt', [PuzzleController::class, 'attempt'])
            ->where('id', '[a-z0-9-]{1,16}')->middleware('throttle:60,1');
        Route::post('/puzzles/{id}/reveal', [PuzzleController::class, 'reveal'])->where('id', '[a-z0-9-]{1,16}');

        // Notifications (16.x, docs/api/notifications.md).
        Route::get('/notifications', [NotificationController::class, 'index'])->middleware('throttle:120,1');
        Route::post('/notifications/read', [NotificationController::class, 'read']);
        Route::delete('/notifications/{id}', [NotificationController::class, 'destroy'])->whereNumber('id');
        Route::get('/me/notification-settings', [NotificationController::class, 'settings']);
        Route::put('/me/notification-settings', [NotificationController::class, 'updateSettings']);
        Route::post('/me/devices', [NotificationController::class, 'registerDevice'])->middleware('throttle:20,1');
        Route::delete('/me/devices', [NotificationController::class, 'unregisterDevice']);

        Route::get('/me/progress', [ProgressController::class, 'show']);
        Route::post('/me/checkin', [ProgressController::class, 'checkIn']);
        Route::post('/me/missions/{id}/claim', [ProgressController::class, 'claim']);
        Route::put('/me/title', [ProgressController::class, 'title']);

        Route::get('/store/products', [IapController::class, 'products']);
        Route::post('/store/iap/{platform}', [IapController::class, 'redeem'])
            ->whereIn('platform', ['google', 'apple'])->middleware('throttle:20,1');

        Route::get('/catalog', [StoreController::class, 'catalog']);
        Route::get('/store/offers', [StoreController::class, 'offers']);
        Route::get('/me/inventory', [StoreController::class, 'inventory']);
        Route::post('/store/purchase', [StoreController::class, 'purchase'])->middleware('throttle:30,1');
        Route::post('/me/loadouts', [StoreController::class, 'saveLoadout']);
        Route::put('/me/loadouts/{id}', [StoreController::class, 'saveLoadout'])->whereNumber('id');
        Route::delete('/me/loadouts/{id}', [StoreController::class, 'deleteLoadout'])->whereNumber('id');
        Route::post('/me/loadouts/{id}/activate', [StoreController::class, 'activate'])->whereNumber('id');
    });

    Route::post('/internal/match-results', [MatchResultController::class, 'store'])
        ->middleware(VerifyGameServerSignature::class);
    Route::post('/internal/tournament-no-shows', [MatchResultController::class, 'noShow'])
        ->middleware(VerifyGameServerSignature::class);

    // Prometheus scrape (ADR-043): bearer METRICS_TOKEN, 404 when unset.
    Route::get('/internal/metrics', MetricsController::class)
        ->middleware([VerifyMetricsToken::class, 'throttle:60,1']);
});
