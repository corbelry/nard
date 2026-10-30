<?php

namespace Tests\Unit;

use App\Support\TrustedProxies;
use PHPUnit\Framework\TestCase;

class TrustedProxiesTest extends TestCase
{
    public function test_parses_the_environment_value(): void
    {
        $this->assertNull(TrustedProxies::parse(null));
        $this->assertNull(TrustedProxies::parse(' '));
        $this->assertNull(TrustedProxies::parse(' , '));
        $this->assertSame('*', TrustedProxies::parse('*'));
        $this->assertSame(['10.0.0.0/8', '192.168.1.5'], TrustedProxies::parse('10.0.0.0/8, 192.168.1.5,'));
    }
}
