<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Season;
use App\Models\User;
use App\Services\InsufficientFunds;
use App\Services\SeasonPassService;
use App\Services\SeasonService;
use App\Services\WalletService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use InvalidArgumentException;

/** Seasons, season pass (7.1), summary (7.2) and leaderboards (6.5); docs/api/seasons.md. */
class SeasonController extends Controller
{
    public function __construct(
        private SeasonService $seasons,
        private SeasonPassService $pass,
        private WalletService $wallet,
    ) {}

    public function show(Request $request): JsonResponse
    {
        return response()->json($this->pass->view($this->user($request)));
    }

    public function index(): JsonResponse
    {
        $this->seasons->current();

        return response()->json([
            'seasons' => Season::query()->orderByDesc('number')->get()->map(fn (Season $s) => $s->toApi())->all(),
        ]);
    }

    public function premium(Request $request): JsonResponse
    {
        $data = $request->validate(['idempotencyKey' => ['required', 'string', 'min:8', 'max:64']]);
        $user = $this->user($request);
        try {
            $this->pass->buyPremium($user, (string) $data['idempotencyKey']);
        } catch (InsufficientFunds) {
            return response()->json(['code' => 'insufficient_funds'], 422);
        } catch (InvalidArgumentException $e) {
            return response()->json(['code' => $e->getMessage()], 422);
        }

        return response()->json([...$this->pass->view($user), 'wallet' => $this->wallet->balances($user)]);
    }

    public function claim(Request $request): JsonResponse
    {
        $data = $request->validate([
            'level' => ['required', 'integer', 'min:1', 'max:1000'],
            'track' => ['required', 'in:free,premium'],
        ]);
        $user = $this->user($request);
        try {
            $this->pass->claim($user, (int) $data['level'], (string) $data['track']);
        } catch (InvalidArgumentException $e) {
            return response()->json(['code' => $e->getMessage()], 422);
        }

        return response()->json([...$this->pass->view($user), 'wallet' => $this->wallet->balances($user)]);
    }

    public function claimAll(Request $request): JsonResponse
    {
        $user = $this->user($request);
        $claimed = $this->pass->claimAll($user);

        return response()->json(['claimed' => $claimed, ...$this->pass->view($user), 'wallet' => $this->wallet->balances($user)]);
    }

    public function summary(Request $request, ?int $number = null): JsonResponse
    {
        $summary = $this->seasons->summary($this->user($request), $number);

        return $summary === null ? response()->json(['code' => 'not_found'], 404) : response()->json($summary);
    }

    public function leaderboard(Request $request): JsonResponse
    {
        $data = $request->validate([
            'variant' => ['required', 'in:'.implode(',', (array) config('nard.variants'))],
            'scope' => ['sometimes', 'in:global,country,friends,clan'],
            'season' => ['sometimes', 'integer', 'min:1'],
        ]);
        $past = null;
        if (isset($data['season'])) {
            $season = Season::query()->where('number', (int) $data['season'])->first();
            if ($season === null) {
                return response()->json(['code' => 'not_found'], 404);
            }
            // The running season ranks live ratings.
            $past = $season->status === 'finished' ? $season : null;
        }

        return response()->json($this->seasons->leaderboard(
            $this->user($request), (string) $data['variant'], (string) ($data['scope'] ?? 'global'), $past,
        ));
    }

    private function user(Request $request): User
    {
        /** @var User $user */
        $user = $request->user();

        return $user;
    }
}
