<?php

namespace App\Http\Middleware;

use App\Models\User;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/** Banned players get 403 {code: banned, until} on every API call (ADR-042). */
class EnsureNotBanned
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        if ($user instanceof User && $user->isBanned()) {
            return response()->json([
                'code' => 'banned',
                // null = permanent.
                'until' => $user->banned_until?->toIso8601String(),
            ], 403);
        }

        return $next($request);
    }
}
