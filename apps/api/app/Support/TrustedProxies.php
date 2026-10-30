<?php

namespace App\Support;

/**
 * Parses `TRUSTED_PROXIES` (ADR-043). Behind the Kubernetes ingress every
 * request arrives from the ingress pod, so without trusting it the per-IP
 * rate limits (guest sign-up, e-mail codes) would be shared by all players.
 * `*` trusts the immediate peer (safe when only the ingress can reach the
 * pods); otherwise a comma-separated list of IPs/CIDRs. Empty: trust none.
 */
final class TrustedProxies
{
    /** @return '*'|list<string>|null */
    public static function parse(?string $value): string|array|null
    {
        $value = trim((string) $value);
        if ($value === '') {
            return null;
        }
        if ($value === '*') {
            return '*';
        }
        $list = array_values(array_filter(array_map('trim', explode(',', $value)), fn (string $p): bool => $p !== ''));

        return $list === [] ? null : $list;
    }
}
