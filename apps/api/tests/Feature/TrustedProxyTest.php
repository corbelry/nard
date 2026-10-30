<?php

namespace Tests\Feature;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Tests\TestCase;

/** TRUSTED_PROXIES: per-player IPs behind the ingress (ADR-043). */
class TrustedProxyTest extends TestCase
{
    protected function tearDown(): void
    {
        Request::setTrustedProxies([], Request::HEADER_X_FORWARDED_FOR);
        parent::tearDown();
    }

    public function test_the_client_ip_comes_from_a_trusted_ingress_only(): void
    {
        Route::get('/_ip', fn (Request $r) => response()->json(['ip' => $r->ip()]));
        $headers = ['X-Forwarded-For' => '203.0.113.9'];
        $server = ['REMOTE_ADDR' => '10.4.0.7'];

        config(['nard.trusted_proxies' => '']);
        $this->withServerVariables($server)->getJson('/_ip', $headers)->assertJsonPath('ip', '10.4.0.7');

        config(['nard.trusted_proxies' => '10.0.0.0/8']);
        $this->withServerVariables($server)->getJson('/_ip', $headers)->assertJsonPath('ip', '203.0.113.9');

        config(['nard.trusted_proxies' => '*']);
        $this->withServerVariables($server)->getJson('/_ip', $headers)->assertJsonPath('ip', '203.0.113.9');
    }
}
