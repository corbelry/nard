<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/** Accepts only requests signed by the game server (HMAC-SHA256 of the body). */
class VerifyGameServerSignature
{
    public function handle(Request $request, Closure $next): Response
    {
        $secret = (string) config('nard.ticket_secret');
        $signature = (string) $request->header('X-Nard-Signature', '');
        $expected = hash_hmac('sha256', $request->getContent(), $secret);
        if (strlen($secret) < 32 || ! hash_equals($expected, $signature)) {
            return response()->json(['code' => 'bad_signature'], 401);
        }

        return $next($request);
    }
}
