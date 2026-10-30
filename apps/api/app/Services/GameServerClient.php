<?php

namespace App\Services;

use App\Models\User;
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
        return $this->post('/internal/tournament-matches', $match, 5, 'tournament match', ['matchId' => $match['matchId'] ?? null]);
    }

    /**
     * Pushes the player's whole moderation state to their live session
     * (Moderation, packages/nard_protocol/schema/moderation.schema.json,
     * ADR-045). True when the game server took it; a failure is logged and
     * never thrown, so admin actions do not depend on the game server.
     */
    public function pushModeration(User $user): bool
    {
        return $this->post('/internal/moderation', [
            'userId' => (string) $user->id,
            'banned' => $user->isBanned(),
            'muted' => $user->isMuted(),
            'queueCooldownUntil' => $user->queueCooldownUntil()?->getTimestamp(),
        ], 3, 'moderation', ['userId' => $user->id]);
    }

    /**
     * @param  array<string, mixed>  $payload
     * @param  array<string, mixed>  $context
     */
    private function post(string $path, array $payload, int $timeout, string $what, array $context): bool
    {
        $base = rtrim((string) config('nard.game_server_url'), '/');
        $secret = (string) config('nard.ticket_secret');
        if ($base === '' || strlen($secret) < 32) {
            return false;
        }
        $body = (string) json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        try {
            $response = Http::timeout($timeout)->connectTimeout(min(2, $timeout))
                ->withHeaders(['X-Nard-Signature' => hash_hmac('sha256', $body, $secret), 'Accept' => 'application/json'])
                ->withBody($body, 'application/json')
                ->post($base.$path);
        } catch (ConnectionException $e) {
            Log::warning("$what push failed", $context + ['error' => $e->getMessage()]);

            return false;
        }
        if (! $response->successful()) {
            Log::warning("$what refused", $context + ['status' => $response->status()]);
        }

        return $response->successful();
    }
}
