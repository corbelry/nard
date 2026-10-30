<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\ProgressionService;
use App\Services\StoreService;
use App\Services\WalletService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/** Level/XP, missions (12.1), streak (12.2), achievements and titles (8.2). */
class ProgressController extends Controller
{
    public function __construct(private ProgressionService $progression) {}

    public function show(Request $request): JsonResponse
    {
        return response()->json(['progress' => $this->progression->summary($this->user($request), now())]);
    }

    public function checkIn(Request $request, WalletService $wallet): JsonResponse
    {
        $user = $this->user($request);
        $coins = $this->progression->checkIn($user, now());

        return response()->json([
            'coins' => $coins,
            'streak' => $user->login_streak,
            'wallet' => $wallet->balances($user),
        ]);
    }

    public function claim(Request $request, string $id, WalletService $wallet): JsonResponse
    {
        $user = $this->user($request);
        if (! $this->progression->claim($user, $id, now())) {
            return response()->json(['code' => 'not_claimable'], 422);
        }

        return response()->json([
            'progress' => $this->progression->summary($user, now()),
            'wallet' => $wallet->balances($user),
        ]);
    }

    public function title(Request $request, StoreService $store): JsonResponse
    {
        $data = $request->validate(['itemId' => ['nullable', 'string', 'max:64']]);
        $user = $this->user($request);
        $itemId = $data['itemId'] ?? null;
        if ($itemId !== null && (! str_starts_with($itemId, 'title.') || ! $store->owns($user, $itemId))) {
            return response()->json(['code' => 'not_owned'], 422);
        }
        $user->forceFill(['title_item_id' => $itemId])->save();

        return response()->json(['title' => $itemId]);
    }

    private function user(Request $request): User
    {
        /** @var User $user */
        $user = $request->user();

        return $user;
    }
}
