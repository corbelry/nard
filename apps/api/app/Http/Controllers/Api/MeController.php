<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\GameMatch;
use App\Models\User;
use App\Services\TicketSigner;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/** Profile, account & privacy (8.1, 15.1–15.3) and game tickets. */
class MeController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        return response()->json(['user' => $this->user($request)->profile()]);
    }

    public function update(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'min:3', 'max:20', 'regex:/^[\pL\pN_]+$/u'],
            'country' => ['sometimes', 'nullable', 'string', 'size:2', 'alpha'],
            'avatar' => ['sometimes', 'nullable', 'string', 'max:64'],
            'locale' => ['sometimes', 'string', 'in:az,en,ru,tr'],
        ]);
        if (isset($data['country'])) {
            $data['country'] = strtoupper($data['country']);
        }
        $user = $this->user($request);
        $user->fill($data)->save();

        return response()->json(['user' => $user->profile()]);
    }

    /** 15.3: deletes the account; finished matches keep anonymous names. */
    public function destroy(Request $request): JsonResponse
    {
        $user = $this->user($request);
        $user->tokens()->delete();
        $user->delete();

        return response()->json(['ok' => true]);
    }

    /** 15.2: everything stored about the player. */
    public function export(Request $request): JsonResponse
    {
        $user = $this->user($request);

        return response()->json([
            'user' => $user->profile(),
            'createdAt' => $user->created_at?->toIso8601String(),
            'matches' => $this->matchesOf($user)->get()
                ->map(fn (GameMatch $m) => $m->summary($user->id, true))->all(),
        ]);
    }

    public function matches(Request $request): JsonResponse
    {
        $user = $this->user($request);
        $limit = min(100, max(1, (int) $request->query('limit', '30')));

        return response()->json([
            'matches' => $this->matchesOf($user)->limit($limit)->get()
                ->map(fn (GameMatch $m) => $m->summary($user->id))->all(),
        ]);
    }

    public function match(Request $request, string $id): JsonResponse
    {
        $user = $this->user($request);
        $match = $this->matchesOf($user)->where('id', $id)->first();
        if ($match === null) {
            return response()->json(['code' => 'not_found'], 404);
        }

        return response()->json(['match' => $match->summary($user->id, true)]);
    }

    public function ticket(Request $request, TicketSigner $signer): JsonResponse
    {
        $now = now()->getTimestamp();

        return response()->json([
            'ticket' => $signer->sign($this->user($request), $now),
            'expiresAt' => $now + (int) config('nard.ticket_ttl'),
        ]);
    }

    /** @return Builder<GameMatch> */
    private function matchesOf(User $user): Builder
    {
        return GameMatch::query()
            ->where(fn ($q) => $q->where('white_user_id', $user->id)->orWhere('black_user_id', $user->id))
            ->orderByDesc('ended_at');
    }

    private function user(Request $request): User
    {
        /** @var User $user */
        $user = $request->user();

        return $user;
    }
}
