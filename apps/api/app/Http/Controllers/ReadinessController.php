<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Redis;
use Throwable;

/**
 * `GET /readyz` (ADR-043): 200 when every configured dependency answers,
 * 503 otherwise. Registered outside the web/api middleware groups so a
 * database outage cannot fail it through the session middleware first.
 * Liveness stays Laravel's `/up`.
 */
class ReadinessController extends Controller
{
    public function __invoke(): JsonResponse
    {
        $checks = [];
        foreach ((array) config('observability.readiness_checks') as $name) {
            try {
                match ($name) {
                    'database' => DB::select('select 1'),
                    'redis' => Redis::connection()->ping(),
                    default => throw new \InvalidArgumentException("Unknown readiness check $name"),
                };
                $checks[$name] = 'ok';
            } catch (Throwable $e) {
                $checks[$name] = 'fail';
                Log::warning('readiness check failed', ['check' => $name, 'error' => $e->getMessage()]);
            }
        }
        $ready = ! in_array('fail', $checks, true);

        return response()->json(['status' => $ready ? 'ready' : 'not_ready', 'checks' => $checks], $ready ? 200 : 503);
    }
}
