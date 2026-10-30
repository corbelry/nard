<?php

namespace App\Providers;

use App\Services\Push\FcmPushSender;
use App\Services\Push\NullPushSender;
use App\Services\Push\PushSender;
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
        //
    }
}
