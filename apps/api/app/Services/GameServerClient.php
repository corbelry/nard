<?php

namespace App\Services;

use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Signed internal HTTP to the game server (the reverse of match results):
 * `X-Nard-Signature: hex(HMAC-SHA256(GAME_TICKET_SECRET, body))`.
 */
class GameServerClient
{
    /**
     * Pushes a tournament pairing (TournamentMatch,
     * packages/nard_protocol/schema/tournament_match.schema.json). True when
     * the game server has it (new or already known).
     *
     * @param  array<string, mixed>  $match
     */
    public function pushTournamentMatch(array $match): bool
    {
        $base = rtrim((string) config('nard.game_server_url'), '/');
        $secret = (string) config('nard.ticket_secret');
        if ($base === '' || strlen($secret) < 32) {
            return false;
        }
        $body = (string) json_encode($match, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        try {
            $response = Http::timeout(5)
                ->withHeaders(['X-Nard-Signature' => hash_hmac('sha256', $body, $secret), 'Accept' => 'application/json'])
                ->withBody($body, 'application/json')
                ->post($base.'/internal/tournament-matches');
        } catch (ConnectionException $e) {
            Log::warning('tournament match push failed', ['matchId' => $match['matchId'] ?? null, 'error' => $e->getMessage()]);

            return false;
        }
        if (! $response->successful()) {
            Log::warning('tournament match refused', ['matchId' => $match['matchId'] ?? null, 'status' => $response->status()]);
        }

        return $response->successful();
    }
}
