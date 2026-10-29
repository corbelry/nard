<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\InsufficientFunds;
use App\Services\WalletService;
use Database\Seeders\ItemCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;
use Tests\TestCase;

class StoreTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(ItemCatalogSeeder::class);
    }

    public function test_the_catalog_lists_the_design_board_sets(): void
    {
        $user = User::factory()->create();
        $items = $this->actingAs($user)->getJson('/api/v1/catalog')->assertOk()->json('items');
        $boards = array_values(array_filter($items, fn ($i) => $i['category'] === 'board'));
        $this->assertCount(6, $boards);
        $this->assertSame('board.walnut', $boards[0]['id']);
        $this->assertTrue($boards[0]['default']);
    }

    public function test_coins_are_earn_only_adr_022(): void
    {
        $user = User::factory()->create();
        $wallet = app(WalletService::class);
        $this->assertSame(100, $wallet->credit($user, 'coins', 100, 'match_reward', 'k1'));
        $this->expectException(InvalidArgumentException::class);
        $wallet->credit($user, 'coins', 100, 'iap', 'k2');
    }

    public function test_the_ledger_is_idempotent_and_never_negative(): void
    {
        $user = User::factory()->create();
        $wallet = app(WalletService::class);
        $wallet->credit($user, 'gems', 50, 'iap', 'receipt-1');
        $wallet->credit($user, 'gems', 50, 'iap', 'receipt-1');
        $this->assertSame(['coins' => 0, 'gems' => 50], $wallet->balances($user));
        $this->assertSame(1, DB::table('wallet_transactions')->count());
        $this->expectException(InsufficientFunds::class);
        $wallet->debit($user, 'gems', 51, 'purchase', 'p-1');
    }

    public function test_buying_an_item_debits_once_and_grants_it(): void
    {
        $user = User::factory()->create();
        app(WalletService::class)->credit($user, 'coins', 2500, 'match_reward', 'seed');
        $body = ['itemId' => 'board.minimal_pro', 'currency' => 'coins', 'idempotencyKey' => 'buy-0001'];
        $this->actingAs($user)->postJson('/api/v1/store/purchase', $body)->assertOk()
            ->assertJsonPath('wallet.coins', 500);
        // A retried request with the same key changes nothing.
        $this->actingAs($user)->postJson('/api/v1/store/purchase', $body)->assertOk()
            ->assertJsonPath('wallet.coins', 500);
        $inv = $this->actingAs($user)->getJson('/api/v1/me/inventory')->assertOk()->json();
        $this->assertContains('board.minimal_pro', $inv['owned']);
        $this->assertContains('board.walnut', $inv['owned']);
        $this->actingAs($user)->postJson('/api/v1/store/purchase', [...$body, 'idempotencyKey' => 'buy-0002'])
            ->assertStatus(422)->assertJsonPath('code', 'already_owned');
        $this->actingAs($user)->postJson('/api/v1/store/purchase', ['itemId' => 'board.marble_royale', 'currency' => 'gems', 'idempotencyKey' => 'buy-0003'])
            ->assertStatus(422)->assertJsonPath('code', 'insufficient_funds');
        $this->actingAs($user)->postJson('/api/v1/store/purchase', ['itemId' => 'board.walnut', 'currency' => 'coins', 'idempotencyKey' => 'buy-0004'])
            ->assertStatus(422)->assertJsonPath('code', 'not_for_sale');
        $this->actingAs($user)->postJson('/api/v1/store/purchase', ['itemId' => 'nope', 'currency' => 'coins', 'idempotencyKey' => 'buy-0005'])
            ->assertNotFound();
    }

    public function test_loadouts_only_hold_owned_items_of_the_right_category(): void
    {
        $user = User::factory()->create();
        $created = $this->actingAs($user)->postJson('/api/v1/me/loadouts', [
            'name' => 'Classic',
            'slots' => ['board' => 'board.walnut', 'checkers' => 'checkers.classic'],
        ])->assertCreated()->json('loadout');
        $this->assertTrue($created['active']);
        $this->actingAs($user)->postJson('/api/v1/me/loadouts', ['name' => 'Night', 'slots' => ['board' => 'board.baku_night']])
            ->assertStatus(422)->assertJsonPath('code', 'not_owned');
        $this->actingAs($user)->postJson('/api/v1/me/loadouts', ['name' => 'Bad', 'slots' => ['dice' => 'board.walnut']])
            ->assertStatus(422)->assertJsonPath('code', 'wrong_category');
        $second = $this->actingAs($user)->postJson('/api/v1/me/loadouts', ['name' => 'Two', 'slots' => []])
            ->assertCreated()->json('loadout');
        $this->assertFalse($second['active']);
        $this->actingAs($user)->postJson("/api/v1/me/loadouts/{$second['id']}/activate")->assertOk();
        $this->actingAs($user)->putJson("/api/v1/me/loadouts/{$second['id']}", ['name' => 'Renamed', 'slots' => ['dice' => 'dice.ivory']])
            ->assertOk()->assertJsonPath('loadout.name', 'Renamed');
        $loadouts = $this->actingAs($user)->getJson('/api/v1/me/inventory')->json('loadouts');
        $this->assertFalse($loadouts[0]['active']);
        $this->assertTrue($loadouts[1]['active']);
        $this->actingAs($user)->deleteJson("/api/v1/me/loadouts/{$created['id']}")->assertOk();
        $this->actingAs($user)->deleteJson('/api/v1/me/loadouts/999')->assertNotFound();
        $this->actingAs($user)->postJson('/api/v1/me/loadouts/999/activate')->assertNotFound();
    }
}
