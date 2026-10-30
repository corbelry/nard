<?php

use App\Http\Controllers\ReadinessController;
use App\Http\Middleware\TrustProxies;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Middleware\TrustProxies as BaseTrustProxies;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
        // Readiness probe without the web middleware (sessions use the
        // database, which is what this checks).
        then: function (): void {
            Route::get('/readyz', ReadinessController::class);
        },
    )
    ->withMiddleware(function (Middleware $middleware): void {
        // Behind the ingress: take the client IP from X-Forwarded-For so
        // rate limits are per player, not per ingress pod (ADR-043).
        $middleware->replace(BaseTrustProxies::class, TrustProxies::class);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*') || $request->expectsJson(),
        );
    })->create();
