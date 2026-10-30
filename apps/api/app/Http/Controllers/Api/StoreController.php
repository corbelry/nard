<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Item;
use App\Models\Loadout;
use App\Models\User;
use App\Services\InsufficientFunds;
use App\Services\Settings;
use App\Services\StoreService;
use App\Services\WalletService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use InvalidArgumentException;

/** Catalog, inventory, purchases and loadouts (spec §8.6–8.7). */
class StoreController extends Controller
{
    public function __construct(private StoreService $store, private WalletService $wallet) {}

    public function catalog(): JsonResponse
    {
        $items = Item::query()->where('available', true)->orderBy('category')->orderBy('sort')->get();

        return response()->json(['items' => $items->map(fn (Item $i) => $i->toApi())->all()]);
    }

    /**
     * 7.3 offers: a featured item (discounted, rotates every 2 days) and three
     * daily picks per player (deterministic per day), all from the catalog.
     */
    public function offers(Request $request): JsonResponse
    {
        $user = $this->user($request);
        $now = now()->utc();
        $owned = $this->store->owned($user);
        $buyable = Item::query()->where('available', true)->where('is_default', false)
            ->where(fn ($q) => $q->whereNotNull('price_coins')->orWhereNotNull('price_gems'))
            ->orderBy('id')->get()
            ->filter(fn (Item $i) => ! in_array($i->id, $owned, true))->values();
        $featuredConfig = app(Settings::class)->featuredOffer();
        $featured = $featuredConfig === null ? null : Item::query()->where('available', true)->find($featuredConfig['item']);
        $epochDays = intdiv($now->getTimestamp(), 86400);
        $picks = [];
        if ($buyable->isNotEmpty()) {
            $seed = crc32($user->id.':'.$now->toDateString());
            for ($i = 0; $i < min(3, $buyable->count()); $i++) {
                /** @var Item $item */
                $item = $buyable->get(($seed + $i * 7) % $buyable->count());
                if (! in_array($item->id, array_column($picks, 'id'), true)) {
                    $picks[] = $item->toApi();
                }
            }
        }

        return response()->json([
            'featured' => $featured instanceof Item && ! in_array($featured->id, $owned, true) ? [
                'item' => $featured->toApi(),
                'oldPrice' => $featuredConfig['oldPrice'] ?? null,
                'endsAt' => $now->copy()->startOfDay()->addDays(2 - $epochDays % 2)->toIso8601String(),
            ] : null,
            'daily' => $picks,
            'refreshAt' => $now->copy()->addDay()->startOfDay()->toIso8601String(),
        ]);
    }

    public function inventory(Request $request): JsonResponse
    {
        $user = $this->user($request);

        return response()->json([
            'wallet' => $this->wallet->balances($user),
            'owned' => $this->store->owned($user),
            'loadouts' => Loadout::query()->where('user_id', $user->id)->orderBy('id')->get()
                ->map(fn (Loadout $l) => $l->toApi())->all(),
        ]);
    }

    public function purchase(Request $request): JsonResponse
    {
        $data = $request->validate([
            'itemId' => ['required', 'string', 'max:64'],
            'currency' => ['required', 'in:coins,gems'],
            'idempotencyKey' => ['required', 'string', 'min:8', 'max:64'],
        ]);
        $user = $this->user($request);
        $item = Item::query()->whereKey((string) $data['itemId'])->first();
        if ($item === null) {
            return response()->json(['code' => 'not_found'], 404);
        }
        try {
            $wallet = $this->store->purchase($user, $item, $data['currency'], "purchase:{$user->id}:{$data['idempotencyKey']}");
        } catch (InsufficientFunds) {
            return response()->json(['code' => 'insufficient_funds'], 422);
        } catch (InvalidArgumentException $e) {
            return response()->json(['code' => $e->getMessage()], 422);
        }

        return response()->json(['wallet' => $wallet, 'owned' => $this->store->owned($user)]);
    }

    public function saveLoadout(Request $request, ?int $id = null): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'min:1', 'max:24'],
            'slots' => ['present', 'array'],
        ]);
        $user = $this->user($request);
        try {
            $slots = $this->store->validSlots($user, $data['slots']);
        } catch (InvalidArgumentException $e) {
            return response()->json(['code' => $e->getMessage()], 422);
        }
        if ($id === null) {
            if (Loadout::query()->where('user_id', $user->id)->count() >= (int) config('economy.max_loadouts')) {
                return response()->json(['code' => 'too_many_loadouts'], 422);
            }
            $loadout = new Loadout;
            $loadout->user_id = $user->id;
        } else {
            $loadout = Loadout::query()->where('user_id', $user->id)->find($id);
            if ($loadout === null) {
                return response()->json(['code' => 'not_found'], 404);
            }
        }
        $loadout->fill(['name' => $data['name'], 'slots' => $slots])->save();
        if (! Loadout::query()->where('user_id', $user->id)->where('active', true)->exists()) {
            $this->store->activate($user, $loadout);
        }

        return response()->json(['loadout' => $loadout->fresh()?->toApi()], $id === null ? 201 : 200);
    }

    public function deleteLoadout(Request $request, int $id): JsonResponse
    {
        $user = $this->user($request);
        $deleted = Loadout::query()->where('user_id', $user->id)->where('id', $id)->delete();

        return $deleted > 0 ? response()->json(['ok' => true]) : response()->json(['code' => 'not_found'], 404);
    }

    public function activate(Request $request, int $id): JsonResponse
    {
        $user = $this->user($request);
        $loadout = Loadout::query()->where('user_id', $user->id)->find($id);
        if ($loadout === null) {
            return response()->json(['code' => 'not_found'], 404);
        }
        $this->store->activate($user, $loadout);

        return response()->json(['loadout' => $loadout->toApi()]);
    }

    private function user(Request $request): User
    {
        /** @var User $user */
        $user = $request->user();

        return $user;
    }
}
