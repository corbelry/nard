<?php

namespace App\Providers;

use App\Services\Push\FcmPushSender;
use App\Services\Push\NullPushSender;
use App\Services\Push\PushSender;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        // FCM once credentials exist (config/push.php), else log-and-drop.
        $this->app->singleton(PushSender::class, fn (): PushSender => FcmPushSender::fromConfig() ?? new NullPushSender);
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Sign-in limits (security review 2026-10-30). Each limiter keeps
        // its own counters; e-mail codes are also capped per address.
        RateLimiter::for('auth', fn (Request $r) => Limit::perMinute(20)->by(self::clientKey($r)));
        RateLimiter::for('email-start', fn (Request $r) => [
            Limit::perMinutes(10, 5)->by('ip:'.self::clientKey($r)),
            Limit::perHour((int) config('nard.login_code_hourly_issues'))
                ->by('email:'.mb_strtolower((string) $r->input('email'))),
        ]);
        RateLimiter::for('email-verify', fn (Request $r) => Limit::perMinute(20)->by(self::clientKey($r)));
    }

    /** The client IP; IPv6 by its /64, which one subscriber usually holds. */
    public static function clientKey(Request $request): string
    {
        $ip = (string) $request->ip();
        if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_IPV6) === false) {
            return $ip;
        }
        $packed = inet_pton($ip);

        return $packed === false ? $ip : bin2hex(substr($packed, 0, 8)).'::/64';
    }
}
