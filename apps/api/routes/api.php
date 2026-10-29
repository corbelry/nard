<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\MatchResultController;
use App\Http\Controllers\Api\MeController;
use App\Http\Controllers\Api\StoreController;
use App\Http\Middleware\VerifyGameServerSignature;
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

    Route::middleware('auth:sanctum')->group(function (): void {
        Route::post('/auth/logout', [AuthController::class, 'logout']);
        Route::get('/me', [MeController::class, 'show']);
        Route::patch('/me', [MeController::class, 'update']);
        Route::delete('/me', [MeController::class, 'destroy']);
        Route::get('/me/export', [MeController::class, 'export']);
        Route::get('/me/matches', [MeController::class, 'matches']);
        Route::get('/me/matches/{id}', [MeController::class, 'match']);
        Route::post('/game/ticket', [MeController::class, 'ticket'])->middleware('throttle:30,1');

        Route::get('/catalog', [StoreController::class, 'catalog']);
        Route::get('/me/inventory', [StoreController::class, 'inventory']);
        Route::post('/store/purchase', [StoreController::class, 'purchase'])->middleware('throttle:30,1');
        Route::post('/me/loadouts', [StoreController::class, 'saveLoadout']);
        Route::put('/me/loadouts/{id}', [StoreController::class, 'saveLoadout'])->whereNumber('id');
        Route::delete('/me/loadouts/{id}', [StoreController::class, 'deleteLoadout'])->whereNumber('id');
        Route::post('/me/loadouts/{id}/activate', [StoreController::class, 'activate'])->whereNumber('id');
    });

    Route::post('/internal/match-results', [MatchResultController::class, 'store'])
        ->middleware(VerifyGameServerSignature::class);
});
