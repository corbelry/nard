<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\SocialService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;

/** Friends (6.1/6.2), search, blocks and reports (14.x). */
class SocialController extends Controller
{
    public function __construct(private SocialService $social) {}

    public function friends(Request $request): JsonResponse
    {
        $user = $this->user($request);
        if ($user->friend_code === null) {
            $user->forceFill(['friend_code' => User::newFriendCode()])->save();
        }

        return response()->json([...$this->social->overview($user), 'friendCode' => $user->friend_code]);
    }

    public function request(Request $request): JsonResponse
    {
        $data = $request->validate([
            'code' => ['required_without:userId', 'nullable', 'string', 'size:8'],
            'userId' => ['required_without:code', 'nullable', 'string', 'max:20'],
        ]);
        $user = $this->user($request);
        $target = isset($data['code'])
            ? User::query()->where('friend_code', strtoupper((string) $data['code']))->first()
            : User::query()->whereKey((int) $data['userId'])->first();
        if ($target === null) {
            return response()->json(['code' => 'not_found'], 404);
        }
        try {
            $result = $this->social->request($user, $target);
        } catch (InvalidArgumentException $e) {
            return response()->json(['code' => $e->getMessage()], 422);
        }

        return response()->json(['status' => $result, 'user' => $target->publicCard()], 201);
    }

    public function accept(Request $request, int $id): JsonResponse
    {
        return $this->social->accept($this->user($request), $id)
            ? response()->json(['ok' => true])
            : response()->json(['code' => 'not_found'], 404);
    }

    public function dismiss(Request $request, int $id): JsonResponse
    {
        return $this->social->dismiss($this->user($request), $id)
            ? response()->json(['ok' => true])
            : response()->json(['code' => 'not_found'], 404);
    }

    public function unfriend(Request $request, int $userId): JsonResponse
    {
        return $this->social->unfriend($this->user($request), $userId)
            ? response()->json(['ok' => true])
            : response()->json(['code' => 'not_found'], 404);
    }

    public function search(Request $request): JsonResponse
    {
        $data = $request->validate(['q' => ['required', 'string', 'min:3', 'max:20']]);
        $user = $this->user($request);
        $blocked = DB::table('blocks')->where('blocker_id', $user->id)->pluck('blocked_id')
            ->merge(DB::table('blocks')->where('blocked_id', $user->id)->pluck('blocker_id'))->all();
        $q = str_replace(['%', '_'], ['\\%', '\\_'], $data['q']);
        $users = User::query()->where('name', 'like', $q.'%')->where('id', '!=', $user->id)
            ->whereNotIn('id', $blocked)->orderBy('name')->limit(20)->get();

        return response()->json(['users' => $users->map(fn (User $u) => $u->publicCard())->all()]);
    }

    public function blocks(Request $request): JsonResponse
    {
        $ids = DB::table('blocks')->where('blocker_id', $this->user($request)->id)->pluck('blocked_id');

        return response()->json(['users' => User::query()->whereIn('id', $ids)->get()->map(fn (User $u) => $u->publicCard())->all()]);
    }

    public function block(Request $request, int $userId): JsonResponse
    {
        $other = User::query()->whereKey($userId)->first();
        if ($other === null) {
            return response()->json(['code' => 'not_found'], 404);
        }
        try {
            $this->social->block($this->user($request), $other);
        } catch (InvalidArgumentException $e) {
            return response()->json(['code' => $e->getMessage()], 422);
        }

        return response()->json(['ok' => true]);
    }

    public function unblock(Request $request, int $userId): JsonResponse
    {
        DB::table('blocks')->where(['blocker_id' => $this->user($request)->id, 'blocked_id' => $userId])->delete();

        return response()->json(['ok' => true]);
    }

    public function report(Request $request): JsonResponse
    {
        /** @var array<int, string> $reasons */
        $reasons = config('social.report_reasons');
        $data = $request->validate([
            'userId' => ['required', 'string', 'max:20'],
            'reason' => ['required', 'string', 'in:'.implode(',', $reasons)],
            'matchId' => ['nullable', 'string', 'max:64'],
            'note' => ['nullable', 'string', 'max:500'],
        ]);
        $user = $this->user($request);
        $target = User::query()->whereKey((int) $data['userId'])->first();
        if ($target === null || $target->id === $user->id) {
            return response()->json(['code' => 'not_found'], 404);
        }
        $today = DB::table('reports')->where('reporter_id', $user->id)->where('created_at', '>=', now()->subDay())->count();
        if ($today >= (int) config('social.reports_per_day')) {
            return response()->json(['code' => 'rate_limited'], 429);
        }
        $id = DB::table('reports')->insertGetId([
            'reporter_id' => $user->id,
            'reported_id' => $target->id,
            'reason' => $data['reason'],
            'match_id' => $data['matchId'] ?? null,
            'note' => $data['note'] ?? null,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // 14.4 shows a reference number.
        return response()->json(['reference' => sprintf('R-%06d', $id)], 201);
    }

    private function user(Request $request): User
    {
        /** @var User $user */
        $user = $request->user();

        return $user;
    }
}
