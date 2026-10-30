<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Mail\LoginCodeMail;
use App\Models\LoginCode;
use App\Models\User;
use App\Services\AntiCheatService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\App;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;

/** Sign-in (ADR-020): guest device accounts, e-mail codes, Apple/Google. */
class AuthController extends Controller
{
    private const LOCALES = 'in:az,en,ru,tr';

    public function guest(Request $request): JsonResponse
    {
        $data = $request->validate([
            'deviceId' => ['required', 'string', 'min:8', 'max:64'],
            'locale' => ['nullable', 'string', self::LOCALES],
        ]);
        $locale = $data['locale'] ?? 'az';
        $user = User::query()->firstWhere('device_id', $data['deviceId']);
        if ($user === null) {
            App::setLocale($locale);
            $user = User::query()->create([
                'name' => __('nard.guest_name', ['n' => random_int(1000, 9999)]),
                'device_id' => $data['deviceId'],
                'locale' => $locale,
                'is_guest' => true,
            ]);
        }

        return $this->signedIn($user, 'guest', $request);
    }

    public function emailStart(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email:rfc', 'max:255'],
            'locale' => ['nullable', 'string', self::LOCALES],
        ]);
        $email = mb_strtolower($data['email']);
        $code = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        $ttl = (int) config('nard.login_code_ttl');
        DB::transaction(function () use ($email, $code, $ttl): void {
            LoginCode::query()->where('email', $email)->delete();
            LoginCode::query()->create([
                'email' => $email,
                'code_hash' => Hash::make($code),
                'expires_at' => now()->addSeconds($ttl),
            ]);
        });
        Mail::to($email)
            ->locale($data['locale'] ?? 'az')
            ->send(new LoginCodeMail($code, intdiv($ttl, 60)));

        // Same answer whether or not an account exists.
        return response()->json(['sent' => true], 202);
    }

    public function emailVerify(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email:rfc', 'max:255'],
            'code' => ['required', 'string', 'size:6'],
            'deviceId' => ['nullable', 'string', 'min:8', 'max:64'],
        ]);
        $email = mb_strtolower($data['email']);
        $login = LoginCode::query()->where('email', $email)->latest('id')->first();
        if ($login === null || $login->expires_at->isPast()
            || $login->attempts >= (int) config('nard.login_code_attempts')) {
            return response()->json(['code' => 'code_expired'], 422);
        }
        if (! Hash::check($data['code'], $login->code_hash)) {
            $login->increment('attempts');

            return response()->json(['code' => 'code_invalid'], 422);
        }
        $login->delete();

        $existing = User::query()->firstWhere('email', $email);
        /** @var User|null $current */
        $current = auth('sanctum')->user();
        if ($existing === null && $current !== null && $current->is_guest) {
            // Upgrade the signed-in guest, keeping its ratings and history.
            $current->forceFill([
                'email' => $email,
                'email_verified_at' => now(),
                'is_guest' => false,
            ])->save();

            return $this->signedIn($current, 'email', $request);
        }
        $user = $existing ?? User::query()->create([
            'name' => __('nard.guest_name', ['n' => random_int(1000, 9999)]),
            'email' => $email,
            'is_guest' => false,
        ]);
        $user->forceFill(['email_verified_at' => now()])->save();

        return $this->signedIn($user, 'email', $request);
    }

    /** Apple / Google sign-in: disabled until the owner adds keys (ADR-030). */
    public function provider(string $provider): JsonResponse
    {
        if (! (bool) config("nard.providers.$provider", false)) {
            return response()->json(['code' => 'provider_disabled'], 503);
        }

        // Token verification lands with the keys (ROADMAP: carried over).
        return response()->json(['code' => 'not_implemented'], 501);
    }

    public function logout(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        $user->currentAccessToken()->delete();

        return response()->json(['ok' => true]);
    }

    private function signedIn(User $user, string $method, Request $request): JsonResponse
    {
        // Multi-account signal (§8.14): where the account signs in from.
        $device = $request->input('deviceId', $request->header('X-Device-Id'));
        app(AntiCheatService::class)->recordSignIn($user, $request->ip(), is_string($device) ? $device : null);
        if ($user->deletion_requested_at !== null) {
            // Signing in during the grace period cancels the deletion.
            $user->forceFill(['deletion_requested_at' => null])->save();
        }
        if ($user->isBanned()) {
            return response()->json(['code' => 'banned', 'until' => $user->banned_until?->toIso8601String()], 403);
        }
        $token = $user->createToken($method)->plainTextToken;

        return response()->json(['token' => $token, 'user' => $user->profile()]);
    }
}
