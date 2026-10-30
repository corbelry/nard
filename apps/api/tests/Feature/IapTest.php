<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\WalletService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class IapTest extends TestCase
{
    use RefreshDatabase;

    public function test_real_receipts_wait_for_store_accounts(): void
    {
        $user = User::factory()->create();
        $this->actingAs($user)->getJson('/api/v1/store/products')->assertOk()
            ->assertJsonPath('enabled', false)->assertJsonPath('products.0.id', 'yaqut_500');
        $this->actingAs($user)->postJson('/api/v1/store/iap/google', ['productId' => 'yaqut_500', 'receipt' => 'token'])
            ->assertStatus(503)->assertJsonPath('code', 'iap_disabled');
        config(['iap.enabled' => true]);
        $this->actingAs($user)->postJson('/api/v1/store/iap/apple', ['productId' => 'yaqut_500', 'receipt' => 'token'])
            ->assertStatus(501);
        $this->actingAs($user)->postJson('/api/v1/store/iap/apple', ['productId' => 'nope', 'receipt' => 'token'])
            ->assertStatus(422);
    }

    public function test_fake_receipts_credit_yaqut_once_in_development(): void
    {
        config(['iap.fake' => true]);
        $user = User::factory()->create();
        $body = ['productId' => 'yaqut_500', 'receipt' => 'test-0001'];
        $this->actingAs($user)->postJson('/api/v1/store/iap/google', $body)->assertOk()->assertJsonPath('gems', 500);
        $this->actingAs($user)->postJson('/api/v1/store/iap/google', $body)->assertOk()->assertJsonPath('gems', 500);
        $this->assertSame(['coins' => 0, 'gems' => 500], app(WalletService::class)->balances($user));
    }
}
