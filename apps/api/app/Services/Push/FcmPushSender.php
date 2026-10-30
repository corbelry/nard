<?php

namespace App\Services\Push;

use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use RuntimeException;

/**
 * Firebase Cloud Messaging HTTP v1. Android and iOS (APNs through FCM)
 * tokens both come from the Firebase SDK. Authenticates with a
 * service-account key: a signed JWT is exchanged for an OAuth access token,
 * cached for 50 minutes.
 */
final class FcmPushSender implements PushSender
{
    private const SCOPE = 'https://www.googleapis.com/auth/firebase.messaging';

    /** @param array{client_email: string, private_key: string, token_uri?: string} $account */
    public function __construct(
        private string $projectId,
        private array $account,
        private int $timeout = 10,
    ) {}

    /** The configured sender, or null while credentials are missing. */
    public static function fromConfig(): ?self
    {
        $project = config('push.fcm.project_id');
        $path = config('push.fcm.credentials');
        if (! is_string($project) || $project === '' || ! is_string($path) || $path === '' || ! is_readable($path)) {
            return null;
        }
        $json = json_decode((string) file_get_contents($path), true);
        if (! is_array($json) || ! is_string($json['client_email'] ?? null) || ! is_string($json['private_key'] ?? null)) {
            Log::warning('push: FCM credentials file is not a service-account key', ['path' => $path]);

            return null;
        }
        $account = ['client_email' => $json['client_email'], 'private_key' => $json['private_key']];
        if (is_string($json['token_uri'] ?? null)) {
            $account['token_uri'] = $json['token_uri'];
        }

        return new self($project, $account, (int) config('push.fcm.timeout', 10));
    }

    public function enabled(): bool
    {
        return true;
    }

    public function send(PushMessage $message): PushResult
    {
        $payload = [
            'token' => $message->token,
            'notification' => ['title' => $message->title, 'body' => $message->body],
            'data' => $message->data,
            'android' => ['priority' => 'high', 'notification' => ['channel_id' => 'default']],
            'apns' => ['payload' => ['aps' => ['sound' => 'default']]],
        ];
        try {
            $response = Http::withToken($this->accessToken())->timeout($this->timeout)
                ->post("https://fcm.googleapis.com/v1/projects/{$this->projectId}/messages:send", ['message' => $payload]);
        } catch (ConnectionException|RuntimeException $e) {
            Log::warning('push: FCM unreachable', ['error' => $e->getMessage()]);

            return PushResult::Failed;
        }
        if ($response->successful()) {
            return PushResult::Sent;
        }
        $codes = collect((array) $response->json('error.details', []))
            ->map(fn ($d) => is_array($d) ? ($d['errorCode'] ?? null) : null)->filter()->all();
        if ($response->status() === 404 || in_array('UNREGISTERED', $codes, true)) {
            return PushResult::InvalidToken;
        }
        Log::warning('push: FCM refused', ['status' => $response->status(), 'codes' => $codes]);

        return PushResult::Failed;
    }

    private function accessToken(): string
    {
        /** @var string */
        return Cache::remember('push:fcm:access-token:'.md5($this->account['client_email']), 3000, function (): string {
            $uri = $this->account['token_uri'] ?? 'https://oauth2.googleapis.com/token';
            $response = Http::asForm()->timeout($this->timeout)->post($uri, [
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $this->assertion($uri),
            ]);
            $token = $response->json('access_token');
            if (! $response->successful() || ! is_string($token)) {
                throw new RuntimeException('FCM token exchange failed: '.$response->status());
            }

            return $token;
        });
    }

    private function assertion(string $audience): string
    {
        $now = time();
        $segments = [
            self::base64(['alg' => 'RS256', 'typ' => 'JWT']),
            self::base64([
                'iss' => $this->account['client_email'],
                'scope' => self::SCOPE,
                'aud' => $audience,
                'iat' => $now,
                'exp' => $now + 3600,
            ]),
        ];
        $input = implode('.', $segments);
        $signature = '';
        if (! openssl_sign($input, $signature, $this->account['private_key'], OPENSSL_ALGO_SHA256)) {
            throw new RuntimeException('FCM key cannot sign');
        }

        return $input.'.'.rtrim(strtr(base64_encode($signature), '+/', '-_'), '=');
    }

    /** @param array<string, mixed> $json */
    private static function base64(array $json): string
    {
        return rtrim(strtr(base64_encode((string) json_encode($json)), '+/', '-_'), '=');
    }
}
