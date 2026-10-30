<?php

namespace App\Http\Middleware;

use App\Support\TrustedProxies;
use Illuminate\Http\Middleware\TrustProxies as Middleware;

/** Trusted proxies from `nard.trusted_proxies` (TRUSTED_PROXIES, ADR-043). */
class TrustProxies extends Middleware
{
    /** @return array<int, string>|string|null */
    protected function proxies()
    {
        return parent::proxies() ?? TrustedProxies::parse((string) config('nard.trusted_proxies'));
    }
}
