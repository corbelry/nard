<?php

namespace App\Services;

use App\Models\Item;
use App\Models\Loadout;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;

/** Inventory, purchases and loadouts. */
class StoreService
{
    public function __construct(private WalletService $wallet) {}

    /** @return array<int, string> owned item ids, defaults included */
    public function owned(User $user): array
    {
        $bought = DB::table('user_items')->where('user_id', $user->id)->pluck('item_id')->all();
        $defaults = Item::query()->where('is_default', true)->pluck('id')->all();

        return array_values(array_unique([...$defaults, ...$bought]));
    }

    public function owns(User $user, string $itemId): bool
    {
        return in_array($itemId, $this->owned($user), true);
    }

    /**
     * Buys [item] with [currency]; idempotent by [key].
     *
     * @return array{coins: int, gems: int}
     */
    public function purchase(User $user, Item $item, string $currency, string $key): array
    {
        $price = $currency === 'coins' ? $item->price_coins : $item->price_gems;
        if (! $item->available || $price === null || $item->is_default) {
            throw new InvalidArgumentException('not_for_sale');
        }
        DB::transaction(function () use ($user, $item, $currency, $price, $key): void {
            if (DB::table('wallet_transactions')->where('idempotency_key', $key)->exists()) {
                return;
            }
            if ($this->owns($user, $item->id)) {
                throw new InvalidArgumentException('already_owned');
            }
            $this->wallet->debit($user, $currency, $price, 'purchase', $key, $item->id);
            DB::table('user_items')->insert([
                'user_id' => $user->id,
                'item_id' => $item->id,
                'source' => 'purchase',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        });

        return $this->wallet->balances($user);
    }

    /**
     * Validates loadout slots: known categories, owned items of that category.
     *
     * @param  array<string, mixed>  $slots
     * @return array<string, string>
     */
    public function validSlots(User $user, array $slots): array
    {
        $owned = $this->owned($user);
        $clean = [];
        foreach ($slots as $category => $itemId) {
            if (! is_string($itemId) || ! in_array($itemId, $owned, true)) {
                throw new InvalidArgumentException('not_owned');
            }
            $item = Item::query()->whereKey($itemId)->first();
            if ($item === null || $item->category !== $category) {
                throw new InvalidArgumentException('wrong_category');
            }
            $clean[$category] = $itemId;
        }

        return $clean;
    }

    public function activate(User $user, Loadout $loadout): void
    {
        DB::transaction(function () use ($user, $loadout): void {
            Loadout::query()->where('user_id', $user->id)->update(['active' => false]);
            $loadout->forceFill(['active' => true])->save();
        });
    }

    /** @return array<string, string> the active loadout's slots, or empty */
    public function equipped(User $user): array
    {
        $active = Loadout::query()->where('user_id', $user->id)->where('active', true)->first();

        return $active === null ? [] : $active->slots;
    }
}
