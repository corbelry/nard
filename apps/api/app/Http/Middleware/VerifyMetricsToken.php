<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Guards the Prometheus endpoint with `Authorization: Bearer <METRICS_TOKEN>`
 * (ADR-043). Without a configured token the endpoint does not exist.
 */
class VerifyMetricsToken
{
    public function handle(Request $request, Closure $next): Response
    {
        $token = (string) config('observability.metrics_token');
        if ($token === '') {
            abort(404);
        }
        if (! hash_equals($token, (string) $request->bearerToken())) {
            return response()->json(['code' => 'unauthorized'], 401);
        }

        return $next($request);
    }
}
