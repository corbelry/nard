<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\WalletService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/** Yaqut purchases: validates a store receipt and credits gems once. */
class IapController extends Controller
{
    public function products(): JsonResponse
    {
        /** @var array<string, int> $products */
        $products = config('iap.products');

        return response()->json([
            'enabled' => $this->fakeAllowed() || (bool) config('iap.enabled'),
            'products' => collect($products)->map(fn (int $gems, string $id) => ['id' => $id, 'gems' => $gems])->values()->all(),
        ]);
    }

    public function redeem(Request $request, string $platform, WalletService $wallet): JsonResponse
    {
        $data = $request->validate([
            'productId' => ['required', 'string', 'max:64'],
            'receipt' => ['required', 'string', 'max:20000'],
        ]);
        /** @var array<string, int> $products */
        $products = config('iap.products');
        $gems = $products[$data['productId']] ?? null;
        if ($gems === null) {
            return response()->json(['code' => 'unknown_product'], 422);
        }
        $fake = $this->fakeAllowed() && str_starts_with($data['receipt'], 'test-');
        if (! $fake) {
            if (! (bool) config('iap.enabled')) {
                return response()->json(['code' => 'iap_disabled'], 503);
            }

            // Google Play Developer API / App Store Server API verification
            // lands with the store accounts (ROADMAP: carried over).
            return response()->json(['code' => 'not_implemented'], 501);
        }
        /** @var User $user */
        $user = $request->user();
        // The receipt is the idempotency key: one credit per purchase.
        $balance = $wallet->credit($user, 'gems', $gems, 'iap', 'iap:'.$platform.':'.hash('sha256', $data['receipt']), $data['productId']);

        return response()->json(['gems' => $balance]);
    }

    private function fakeAllowed(): bool
    {
        return (bool) config('iap.fake') && app()->environment(['local', 'testing']);
    }
}
