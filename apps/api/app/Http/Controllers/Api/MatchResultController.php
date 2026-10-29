<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\MatchResultService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Internal: the game server reports finished matches (MatchResult,
 * packages/nard_protocol/schema/match_result.schema.json).
 */
class MatchResultController extends Controller
{
    public function store(Request $request, MatchResultService $service): JsonResponse
    {
        $player = ['required', 'array'];
        $data = $request->validate([
            'matchId' => ['required', 'string', 'max:64'],
            'variant' => ['required', 'in:shortNard,longNard'],
            'matchLength' => ['required', 'integer', 'in:1,3,5,7'],
            'mode' => ['required', 'in:casual,ranked'],
            'white' => $player,
            'white.userId' => ['required', 'string', 'max:64'],
            'white.name' => ['required', 'string', 'max:64'],
            'white.bot' => ['required', 'boolean'],
            'black' => $player,
            'black.userId' => ['required', 'string', 'max:64'],
            'black.name' => ['required', 'string', 'max:64'],
            'black.bot' => ['required', 'boolean'],
            'winner' => ['required', 'in:white,black'],
            'whiteScore' => ['required', 'integer', 'min:0'],
            'blackScore' => ['required', 'integer', 'min:0'],
            'reason' => ['required', 'in:completed,resigned,timeout,abandoned'],
            'games' => ['present', 'array'],
            'startedAt' => ['required', 'integer'],
            'endedAt' => ['required', 'integer'],
        ]);
        $match = $service->ingest($data);

        return response()->json([
            'id' => $match->id,
            'white' => $match->white_rating_after,
            'black' => $match->black_rating_after,
        ], 201);
    }
}
