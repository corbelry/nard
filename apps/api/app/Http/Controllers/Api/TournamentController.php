<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Tournament;
use App\Models\TournamentEntry;
use App\Models\User;
use App\Services\TournamentException;
use App\Services\TournamentService;
use App\Services\WalletService;
use Closure;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Validation\Rule;

/** Tournaments (spec §8.3; design 4.1–4.5, 21.x, 22.x; docs/api/tournaments.md). */
class TournamentController extends Controller
{
    public function __construct(private TournamentService $tournaments, private WalletService $wallet) {}

    /** 4.1: live | upcoming | mine | finished, by variant, free only. */
    public function index(Request $request): JsonResponse
    {
        $data = $request->validate([
            'tab' => ['sometimes', 'in:live,upcoming,mine,finished'],
            'variant' => ['sometimes', 'in:shortNard,longNard'],
            'free' => ['sometimes', 'boolean'],
        ]);
        $user = $this->user($request);
        $mine = TournamentEntry::query()->where('user_id', $user->id)->pluck('tournament_id')->all();
        $query = Tournament::query()->withCount('entries');
        // Private tournaments only show up for their organiser and entrants.
        $visible = fn ($q) => $q->where('is_private', false)->orWhereIn('id', $mine)->orWhere('created_by', $user->id);
        switch ($data['tab'] ?? 'live') {
            case 'live':
                $query->where('status', 'running')->where($visible)->orderBy('started_at');
                break;
            case 'upcoming':
                // Sit-and-go tables are listed by GET /tournaments/sng.
                $query->where('status', 'registering')->where('kind', 'scheduled')->orderBy('starts_at');
                break;
            case 'mine':
                $query->whereIn('status', ['registering', 'running'])
                    ->where(fn ($q) => $q->whereIn('id', $mine)->orWhere('created_by', $user->id))
                    ->orderByRaw("case when status = 'running' then 0 else 1 end")->orderBy('starts_at');
                break;
            default:
                $query->where('status', 'finished')->where($visible)
                    ->where('finished_at', '>=', now()->subDays(14))->orderByDesc('finished_at');
        }
        if (isset($data['variant'])) {
            $query->where('variant', $data['variant']);
        }
        if ((bool) ($data['free'] ?? false)) {
            $query->where('entry_coins', 0);
        }
        $list = $query->orderBy('id')->limit(50)->get();
        $entries = TournamentEntry::query()->where('user_id', $user->id)->whereIn('tournament_id', $list->pluck('id'))
            ->get()->keyBy('tournament_id');

        return response()->json([
            'tournaments' => $list->map(fn (Tournament $t) => $this->tournaments->summary($t, $entries->get($t->id)))->values()->all(),
        ]);
    }

    /** 4.2–4.4: detail with bracket / standings. */
    public function show(Request $request, int $id): JsonResponse
    {
        return $this->run(fn () => response()->json([
            'tournament' => $this->tournaments->detail($this->visible($request, $id), $this->user($request)),
        ]));
    }

    public function register(Request $request, int $id): JsonResponse
    {
        $data = $request->validate([
            'idempotencyKey' => ['nullable', 'string', 'min:8', 'max:64'],
            'code' => ['nullable', 'string', 'max:16'],
        ]);

        return $this->run(function () use ($request, $id, $data): JsonResponse {
            $user = $this->user($request);
            $tournament = $this->find($id);
            $code = isset($data['code']) ? TournamentService::normalizeCode((string) $data['code']) : null;
            $this->tournaments->register($tournament, $user, $data['idempotencyKey'] ?? null, $code);

            return $this->withWallet($tournament->refresh(), $user, 201);
        });
    }

    public function unregister(Request $request, int $id): JsonResponse
    {
        return $this->run(function () use ($request, $id): JsonResponse {
            $user = $this->user($request);
            $tournament = $this->find($id);
            $this->tournaments->unregister($tournament, $user);

            return $this->withWallet($tournament->refresh(), $user);
        });
    }

    /** 21.1: the open table per size. */
    public function sitAndGo(Request $request): JsonResponse
    {
        $user = $this->user($request);
        /** @var array<int, int> $sizes */
        $sizes = config('tournaments.sng.sizes');
        $tables = [];
        foreach ($sizes as $size) {
            $open = Tournament::query()->withCount('entries')
                ->where(['kind' => 'sit_and_go', 'status' => 'registering', 'size' => $size])->orderBy('id')->get();
            $mine = $open->first(fn (Tournament $t) => $this->tournaments->entryOf($t, $user) !== null);
            $table = $mine ?? $open->first();
            $fee = (int) config('tournaments.sng.entry_coins');
            $fund = intdiv($size * $fee * (100 - (int) config('tournaments.sng.rake_percent')), 100);
            $tables[] = [
                'size' => $size,
                'variant' => config('tournaments.sng.variant'),
                'matchLength' => config('tournaments.sng.match_length'),
                'clock' => config('tournaments.clock'),
                'entry' => ['kind' => 'coins', 'coins' => $fee],
                'prizeFund' => $fund,
                'prizes' => $table?->prizes,
                'tournamentId' => $table === null ? null : (string) $table->id,
                'joined' => $table === null ? 0 : (int) $table->entries_count,
                'expiresAt' => $table?->expires_at?->toIso8601String(),
                'registered' => $mine !== null,
            ];
        }

        return response()->json(['tables' => $tables]);
    }

    public function joinSitAndGo(Request $request, int $size): JsonResponse
    {
        /** @var array<int, int> $sizes */
        $sizes = config('tournaments.sng.sizes');
        if (! in_array($size, $sizes, true)) {
            return response()->json(['code' => 'not_found'], 404);
        }
        $data = $request->validate(['idempotencyKey' => ['required', 'string', 'min:8', 'max:64']]);

        return $this->run(function () use ($request, $size, $data): JsonResponse {
            $user = $this->user($request);
            $table = $this->tournaments->joinSitAndGo($user, $size, (string) $data['idempotencyKey']);

            return $this->withWallet($table, $user, 201);
        });
    }

    /** 22.1: a private knockout; free entry only (QUESTIONS #34). */
    public function createPrivate(Request $request): JsonResponse
    {
        $name = trim((string) $request->input('name', ''));
        $request->merge(['name' => preg_replace('/\s+/u', ' ', $name) ?? $name]);
        $data = $request->validate([
            'name' => ['required', 'string', 'min:'.(int) config('tournaments.private.name.min'), 'max:'.(int) config('tournaments.private.name.max')],
            'size' => ['required', 'integer', Rule::in($this->ints('tournaments.private.sizes'))],
            'variant' => ['required', 'in:shortNard,longNard'],
            'matchLength' => ['required', 'integer', 'in:1,3,5,7'],
            'startsAt' => ['nullable', 'date', 'after:now', 'before:'.now()->addDays((int) config('tournaments.private.max_days_ahead'))->toIso8601String()],
        ]);

        return $this->run(function () use ($request, $data): JsonResponse {
            $user = $this->user($request);
            $tournament = $this->tournaments->createPrivate($user, [
                'name' => (string) $data['name'],
                'size' => (int) $data['size'],
                'variant' => (string) $data['variant'],
                'matchLength' => (int) $data['matchLength'],
                'startsAt' => isset($data['startsAt']) ? Carbon::parse((string) $data['startsAt'])->utc() : null,
            ]);

            return response()->json(['tournament' => $this->tournaments->detail($tournament, $user)], 201);
        });
    }

    /** 22.2: join by invite code. */
    public function joinByCode(Request $request): JsonResponse
    {
        $data = $request->validate(['code' => ['required', 'string', 'max:16']]);

        return $this->run(function () use ($request, $data): JsonResponse {
            $user = $this->user($request);
            $tournament = $this->tournaments->byCode((string) $data['code']);
            if ($this->tournaments->entryOf($tournament, $user) === null) {
                $this->tournaments->register($tournament, $user, null, TournamentService::normalizeCode((string) $data['code']));
            }

            return response()->json(['tournament' => $this->tournaments->detail($tournament->refresh(), $user)]);
        });
    }

    /** "İndi başlat" (organiser). */
    public function start(Request $request, int $id): JsonResponse
    {
        return $this->run(function () use ($request, $id): JsonResponse {
            $user = $this->user($request);
            $tournament = $this->find($id);
            $this->tournaments->startByOrganizer($tournament, $user);

            return response()->json(['tournament' => $this->tournaments->detail($tournament->refresh(), $user)]);
        });
    }

    /** Organiser cancels before the start. */
    public function destroy(Request $request, int $id): JsonResponse
    {
        return $this->run(function () use ($request, $id): JsonResponse {
            $this->tournaments->cancelByOrganizer($this->find($id), $this->user($request));

            return response()->json(['status' => 'cancelled']);
        });
    }

    public function kick(Request $request, int $id, int $userId): JsonResponse
    {
        return $this->run(function () use ($request, $id, $userId): JsonResponse {
            $this->tournaments->kick($this->find($id), $this->user($request), $userId);

            return response()->json(['status' => 'removed']);
        });
    }

    private function withWallet(Tournament $tournament, User $user, int $status = 200): JsonResponse
    {
        return response()->json([
            'tournament' => $this->tournaments->summary($tournament, $this->tournaments->entryOf($tournament, $user)),
            'wallet' => $this->wallet->balances($user),
        ], $status);
    }

    private function find(int $id): Tournament
    {
        return Tournament::query()->find($id) ?? throw new TournamentException('not_found', 404);
    }

    private function visible(Request $request, int $id): Tournament
    {
        $tournament = $this->find($id);
        if (! $this->tournaments->canSee($tournament, $this->user($request))) {
            throw new TournamentException('not_found', 404);
        }

        return $tournament;
    }

    /** @return array<int, int> */
    private function ints(string $key): array
    {
        /** @var array<int, int> */
        return config($key);
    }

    /** @param Closure(): JsonResponse $action */
    private function run(Closure $action): JsonResponse
    {
        try {
            return $action();
        } catch (TournamentException $e) {
            return response()->json(['code' => $e->getMessage()], $e->status);
        }
    }

    private function user(Request $request): User
    {
        /** @var User $user */
        $user = $request->user();

        return $user;
    }
}
