<?php

namespace App\Services;

use App\Models\Rating;
use App\Models\User;
use RuntimeException;

/**
 * Signs game-server tickets (docs/PROTOCOL.md → Tickets):
 * base64url(json) "." base64url(HMAC-SHA256(secret, base64url(json))).
 */
class TicketSigner
{
    public function __construct(private StoreService $store) {}

    public function sign(User $user, int $now): string
    {
        $secret = (string) config('nard.ticket_secret');
        if (strlen($secret) < 32) {
            throw new RuntimeException('GAME_TICKET_SECRET must be at least 32 characters.');
        }
        // Banned players never reach the game server (ADR-042).
        if ($user->isBanned()) {
            throw new AccountBanned('banned');
        }
        $ratings = [];
        foreach ($user->ratings()->get() as $rating) {
            /** @var Rating $rating */
            $ratings[$rating->variant] = $rating->rating;
        }
        $payload = [
            'sub' => (string) $user->id,
            'name' => $user->name,
            'ratings' => (object) $ratings,
            'exp' => $now + (int) config('nard.ticket_ttl'),
        ];
        if ($user->country !== null) {
            $payload['country'] = $user->country;
        }
        // Muted players' emotes are dropped by the game server.
        if ($user->isMuted()) {
            $payload['muted'] = true;
        }
        // Abandonment penalty: the public queue refuses until then (§8.14).
        $cooldown = $user->queueCooldownUntil();
        if ($cooldown !== null) {
            $payload['queueCooldownUntil'] = $cooldown->getTimestamp();
        }
        // The opponent sees these if they allow it (spec §8.6).
        $equipped = $this->store->equipped($user);
        if ($equipped !== []) {
            $payload['cosmetics'] = $equipped;
        }
        $body = self::b64((string) json_encode($payload, JSON_UNESCAPED_UNICODE));

        return $body.'.'.self::b64(hash_hmac('sha256', $body, $secret, true));
    }

    public static function b64(string $bytes): string
    {
        return rtrim(strtr(base64_encode($bytes), '+/', '-_'), '=');
    }
}
