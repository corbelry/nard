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
    public function sign(User $user, int $now): string
    {
        $secret = (string) config('nard.ticket_secret');
        if (strlen($secret) < 32) {
            throw new RuntimeException('GAME_TICKET_SECRET must be at least 32 characters.');
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
        $body = self::b64((string) json_encode($payload, JSON_UNESCAPED_UNICODE));

        return $body.'.'.self::b64(hash_hmac('sha256', $body, $secret, true));
    }

    public static function b64(string $bytes): string
    {
        return rtrim(strtr(base64_encode($bytes), '+/', '-_'), '=');
    }
}
