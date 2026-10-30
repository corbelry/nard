<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Puzzle;
use App\Models\User;
use App\Services\PuzzleException;
use App\Services\PuzzleService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/** Practice puzzles (13.x); docs/api/seasons.md. */
class PuzzleController extends Controller
{
    public function __construct(private PuzzleService $puzzles) {}

    public function next(Request $request): JsonResponse
    {
        $data = $request->validate(['variant' => ['sometimes', 'in:'.implode(',', (array) config('nard.variants'))]]);
        $user = $this->user($request);

        return response()->json($this->payload($user, $this->puzzles->next($user, $data['variant'] ?? null)));
    }

    public function daily(Request $request): JsonResponse
    {
        $user = $this->user($request);

        return response()->json([
            ...$this->payload($user, $this->puzzles->daily(now())),
            'date' => now()->utc()->toDateString(),
        ]);
    }

    public function attempt(Request $request, string $id): JsonResponse
    {
        $data = $request->validate([
            'attempt' => ['required', 'integer', 'min:1', 'max:'.(int) config('puzzles.max_attempts')],
            'board' => ['required', 'array'],
            'board.white' => ['present', 'array'],
            'board.black' => ['present', 'array'],
            'moves' => ['sometimes', 'nullable', 'string', 'max:64'],
        ]);
        $puzzle = Puzzle::query()->find($id);
        if ($puzzle === null) {
            return response()->json(['code' => 'not_found'], 404);
        }
        try {
            $result = $this->puzzles->attempt($this->user($request), $puzzle, (int) $data['attempt'], $data['board'], $data['moves'] ?? null);
        } catch (PuzzleException $e) {
            return response()->json(['code' => $e->getMessage()], 422);
        }

        return response()->json($result);
    }

    public function reveal(Request $request, string $id): JsonResponse
    {
        $puzzle = Puzzle::query()->find($id);
        if ($puzzle === null) {
            return response()->json(['code' => 'not_found'], 404);
        }

        return response()->json($this->puzzles->reveal($this->user($request), $puzzle));
    }

    /** @return array<string, mixed> */
    private function payload(User $user, ?Puzzle $puzzle): array
    {
        return [
            'puzzle' => $puzzle === null ? null : [...$puzzle->toApi(), ...$this->puzzles->state($user, $puzzle)],
            'rating' => (int) User::query()->whereKey($user->id)->value('puzzle_rating'),
            'solved' => DB::table('puzzle_attempts')->where(['user_id' => $user->id, 'correct' => true])->count(),
            'total' => Puzzle::query()->where('enabled', true)->count(),
        ];
    }

    private function user(Request $request): User
    {
        /** @var User $user */
        $user = $request->user();

        return $user;
    }
}
