<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Clan;
use App\Models\ClanMember;
use App\Models\ClanMessage;
use App\Models\User;
use App\Services\ClanException;
use App\Services\ClanService;
use App\Services\WalletService;
use Closure;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

/** Clans (spec §8.4; design 5.1–5.7, 19.1–19.2). */
class ClanController extends Controller
{
    public function __construct(private ClanService $clans, private WalletService $wallet) {}

    /** 5.1 search: name or tag, language, join policy, minimum I meet. */
    public function index(Request $request): JsonResponse
    {
        $data = $request->validate([
            'q' => ['nullable', 'string', 'min:2', 'max:24'],
            'language' => ['nullable', Rule::in($this->config('clans.languages'))],
            'policy' => ['nullable', Rule::in($this->config('clans.join_policies'))],
            'maxMinRating' => ['nullable', 'integer', 'min:0'],
        ]);
        $query = Clan::query()->withCount('members');
        if (isset($data['q'])) {
            $q = str_replace(['%', '_'], ['\\%', '\\_'], (string) $data['q']);
            $query->where(fn ($w) => $w->where('name', 'like', "%$q%")->orWhere('tag', 'like', strtoupper($q).'%'));
        }
        if (isset($data['language'])) {
            $query->where('language', $data['language']);
        }
        if (isset($data['policy'])) {
            $query->where('join_policy', $data['policy']);
        }
        if (isset($data['maxMinRating'])) {
            $query->where(fn ($w) => $w->whereNull('min_rating')->orWhere('min_rating', '<=', (int) $data['maxMinRating']));
        }
        $clans = $query->orderByDesc('level')->orderByDesc('xp')->orderBy('id')->limit(30)->get();
        $ratings = $this->clans->ratings($clans->pluck('id')->all());

        return response()->json(['clans' => $clans->map(fn (Clan $c) => $c->summary($ratings[$c->id] ?? null))->all()]);
    }

    /** 19.1 "Boşdur" / "Tutulub". */
    public function tagAvailable(Request $request): JsonResponse
    {
        $data = $request->validate(['tag' => ['required', 'string', 'max:16']]);
        $tag = strtoupper(trim((string) $data['tag']));
        $valid = preg_match($this->pattern(), $tag) === 1;

        return response()->json(['tag' => $tag, 'valid' => $valid, 'available' => $valid && $this->clans->tagFree($tag)]);
    }

    /** 5.7: clans by clan XP. */
    public function leaderboard(Request $request): JsonResponse
    {
        $clans = Clan::query()->withCount('members')->orderByDesc('xp')->orderBy('id')->limit(50)->get();
        $entries = $clans->values()->map(fn (Clan $c, int $i) => ['rank' => $i + 1, 'clan' => $c->summary(), 'points' => $c->xp])->all();
        $mine = $this->clans->memberOf($this->user($request))?->clan;
        $me = null;
        if ($mine !== null) {
            $ahead = Clan::query()->where('xp', '>', $mine->xp)
                ->orWhere(fn ($q) => $q->where('xp', $mine->xp)->where('id', '<', $mine->id))->count();
            $me = ['rank' => $ahead + 1, 'points' => $mine->xp, 'clan' => $mine->badge()];
        }

        return response()->json(['entries' => $entries, 'me' => $me]);
    }

    /** 5.2 profile (+ members for 5.5, chest for members). */
    public function show(Request $request, int $id): JsonResponse
    {
        return $this->run(function () use ($request, $id): JsonResponse {
            $user = $this->user($request);
            $clan = $this->clan($id);
            $members = ClanMember::query()->with('user')->where('clan_id', $clan->id)->get()
                ->sortBy([fn (ClanMember $a, ClanMember $b) => $b->rankValue() <=> $a->rankValue(), ['joined_at', 'asc']])
                ->values();
            $clan->members_count = $members->count();
            $mine = $members->firstWhere('user_id', $user->id);

            return response()->json(['clan' => [
                ...$clan->summary($this->clans->ratings([$clan->id])[$clan->id] ?? null),
                'description' => $clan->description,
                'xpNext' => Clan::xpForNext($clan->level),
                'onlineCount' => $members->filter(fn (ClanMember $m) => $m->user->isOnline())->count(),
                'createdAt' => $clan->created_at?->toIso8601String(),
                'myStatus' => $mine !== null ? 'member' : $this->clans->statusOf($clan, $user),
                'myRole' => $mine?->role,
                'requirementsMet' => ['rating' => $clan->min_rating === null || $user->bestRating() >= $clan->min_rating],
                'chest' => $mine === null ? null : $this->clans->chest($clan, $mine),
                'members' => $members->map(fn (ClanMember $m) => [
                    'user' => $m->user->publicCard(),
                    'role' => $m->role,
                    'joinedAt' => $m->joined_at->toIso8601String(),
                    'weeklyDonated' => $m->donatedThisWeek(),
                ])->all(),
            ]], 200);
        });
    }

    public function store(Request $request): JsonResponse
    {
        $this->normalize($request);
        $data = $request->validate([
            ...$this->rules(true),
            'idempotencyKey' => ['required', 'string', 'min:8', 'max:64'],
        ]);

        return $this->run(function () use ($request, $data): JsonResponse {
            /** @var array<string, string> $emblem */
            $emblem = $data['emblem'];
            $clan = $this->clans->create($this->user($request), [
                'name' => (string) $data['name'],
                'tag' => (string) $data['tag'],
                'emblem' => $emblem,
                'description' => isset($data['description']) ? (string) $data['description'] : null,
                'language' => (string) $data['language'],
                'minRating' => isset($data['minRating']) ? (int) $data['minRating'] : null,
                'joinPolicy' => (string) $data['joinPolicy'],
            ], (string) $data['idempotencyKey']);

            return response()->json([
                'clan' => $clan->summary(),
                'wallet' => $this->wallet->balances($this->user($request)),
            ], 201);
        });
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $this->normalize($request);
        $data = $request->validate([
            ...$this->rules(false),
            'idempotencyKey' => ['nullable', 'string', 'min:8', 'max:64'],
        ]);

        return $this->run(function () use ($request, $id, $data): JsonResponse {
            $key = isset($data['idempotencyKey']) ? (string) $data['idempotencyKey'] : null;
            $clan = $this->clans->update($this->clan($id), $this->user($request), $data, $key);

            return response()->json([
                'clan' => [...$clan->summary(), 'description' => $clan->description],
                'wallet' => $this->wallet->balances($this->user($request)),
            ]);
        });
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        return $this->run(function () use ($request, $id): JsonResponse {
            $this->clans->disband($this->clan($id), $this->user($request));

            return response()->json(['ok' => true]);
        });
    }

    public function join(Request $request, int $id): JsonResponse
    {
        return $this->run(fn () => response()->json([
            'status' => $this->clans->join($this->clan($id), $this->user($request)),
        ]));
    }

    public function cancelJoin(Request $request, int $id): JsonResponse
    {
        return $this->run(fn () => $this->clans->cancelRequest($this->clan($id), $this->user($request))
            ? response()->json(['ok' => true])
            : response()->json(['code' => 'not_found'], 404));
    }

    public function leave(Request $request, int $id): JsonResponse
    {
        return $this->run(fn () => response()->json([
            'status' => $this->clans->leave($this->clan($id), $this->user($request)),
        ]));
    }

    public function requests(Request $request, int $id): JsonResponse
    {
        return $this->run(fn () => response()->json([
            'requests' => $this->clans->requests($this->clan($id), $this->user($request)),
        ]));
    }

    public function acceptRequest(Request $request, int $id, int $requestId): JsonResponse
    {
        return $this->run(function () use ($request, $id, $requestId): JsonResponse {
            $this->clans->acceptRequest($this->clan($id), $this->user($request), $requestId);

            return response()->json(['ok' => true]);
        });
    }

    public function declineRequest(Request $request, int $id, int $requestId): JsonResponse
    {
        return $this->run(function () use ($request, $id, $requestId): JsonResponse {
            $this->clans->declineRequest($this->clan($id), $this->user($request), $requestId);

            return response()->json(['ok' => true]);
        });
    }

    public function invite(Request $request, int $id): JsonResponse
    {
        $data = $request->validate(['userId' => ['required', 'string', 'max:20']]);

        return $this->run(fn () => response()->json([
            'id' => $this->clans->invite($this->clan($id), $this->user($request), (int) $data['userId']),
        ], 201));
    }

    public function myInvites(Request $request): JsonResponse
    {
        return response()->json(['invites' => $this->clans->myInvites($this->user($request))]);
    }

    public function acceptInvite(Request $request, int $inviteId): JsonResponse
    {
        return $this->run(fn () => response()->json([
            'clan' => $this->clans->acceptInvite($this->user($request), $inviteId)->summary(),
        ]));
    }

    public function declineInvite(Request $request, int $inviteId): JsonResponse
    {
        return $this->run(function () use ($request, $inviteId): JsonResponse {
            $this->clans->declineInvite($this->user($request), $inviteId);

            return response()->json(['ok' => true]);
        });
    }

    public function role(Request $request, int $id, int $userId): JsonResponse
    {
        $data = $request->validate(['role' => ['required', Rule::in($this->config('clans.roles'))]]);

        return $this->run(function () use ($request, $id, $userId, $data): JsonResponse {
            $this->clans->setRole($this->clan($id), $this->user($request), $userId, (string) $data['role']);

            return response()->json(['ok' => true]);
        });
    }

    public function kick(Request $request, int $id, int $userId): JsonResponse
    {
        return $this->run(function () use ($request, $id, $userId): JsonResponse {
            $this->clans->kick($this->clan($id), $this->user($request), $userId);

            return response()->json(['ok' => true]);
        });
    }

    /** 5.4 chat, polled: the latest page after [after], oldest first. */
    public function messages(Request $request, int $id): JsonResponse
    {
        $data = $request->validate(['after' => ['nullable', 'integer', 'min:0']]);

        return $this->run(function () use ($request, $id, $data): JsonResponse {
            $after = isset($data['after']) ? (int) $data['after'] : null;
            $messages = $this->clans->messages($this->clan($id), $this->user($request), $after);

            return response()->json(['messages' => array_map(fn (ClanMessage $m) => $m->toApi(), $messages)]);
        });
    }

    public function post(Request $request, int $id): JsonResponse
    {
        $data = $request->validate(['text' => ['required', 'string', 'max:'.(int) config('clans.chat.max_length')]]);
        $text = trim((string) $data['text']);
        if ($text === '') {
            return response()->json(['code' => 'empty'], 422);
        }

        return $this->run(fn () => response()->json([
            'message' => $this->clans->post($this->clan($id), $this->user($request), $text)->toApi(),
        ], 201));
    }

    public function deleteMessage(Request $request, int $id, int $messageId): JsonResponse
    {
        return $this->run(function () use ($request, $id, $messageId): JsonResponse {
            $this->clans->deleteMessage($this->clan($id), $this->user($request), $messageId);

            return response()->json(['ok' => true]);
        });
    }

    public function donate(Request $request, int $id): JsonResponse
    {
        $data = $request->validate([
            'coins' => ['required', 'integer', 'min:'.(int) config('clans.chest.min_donation'), 'max:'.(int) config('clans.chest.weekly_target')],
            'idempotencyKey' => ['required', 'string', 'min:8', 'max:64'],
        ]);

        return $this->run(function () use ($request, $id, $data): JsonResponse {
            $user = $this->user($request);
            $clan = $this->clan($id);
            $donated = $this->clans->donate($clan, $user, (int) $data['coins'], (string) $data['idempotencyKey']);
            $clan->refresh();

            return response()->json([
                'donated' => $donated,
                'chest' => $this->clans->chest($clan, $this->clans->memberOf($user)),
                'clan' => ['level' => $clan->level, 'xp' => $clan->xp, 'xpNext' => Clan::xpForNext($clan->level)],
                'wallet' => $this->wallet->balances($user),
            ]);
        });
    }

    /** 5.6: the clan's current (or last) war. */
    public function war(int $id): JsonResponse
    {
        return $this->run(fn () => response()->json(['war' => $this->clans->war($this->clan($id))]));
    }

    /** @return array<string, array<int, mixed>> */
    private function rules(bool $create): array
    {
        $req = $create ? 'required' : 'sometimes';

        return [
            'name' => [$req, 'string', 'min:'.(int) config('clans.name.min'), 'max:'.(int) config('clans.name.max'), 'regex:/^[\pL\pN][\pL\pN _\'.\-]*$/u'],
            'tag' => [$req, 'string', 'regex:'.$this->pattern()],
            'emblem' => [$req, 'array:shape,symbol,color,pattern'],
            'emblem.shape' => ['required_with:emblem', Rule::in($this->config('clans.emblem.shapes'))],
            'emblem.symbol' => ['required_with:emblem', Rule::in($this->config('clans.emblem.symbols'))],
            'emblem.color' => ['required_with:emblem', Rule::in($this->config('clans.emblem.colors'))],
            'emblem.pattern' => ['sometimes', Rule::in($this->config('clans.emblem.patterns'))],
            'description' => ['sometimes', 'nullable', 'string', 'max:'.(int) config('clans.description_max')],
            'language' => [$req, Rule::in($this->config('clans.languages'))],
            'minRating' => ['sometimes', 'nullable', 'integer', 'min:'.(int) config('clans.min_rating.min'), 'max:'.(int) config('clans.min_rating.max')],
            'joinPolicy' => [$req, Rule::in($this->config('clans.join_policies'))],
        ];
    }

    /** Trims/collapses the name and upper-cases the tag before validation. */
    private function normalize(Request $request): void
    {
        $name = $request->input('name');
        if (is_string($name)) {
            $request->merge(['name' => preg_replace('/\s+/u', ' ', trim($name)) ?? $name]);
        }
        $tag = $request->input('tag');
        if (is_string($tag)) {
            $request->merge(['tag' => strtoupper(trim($tag))]);
        }
        $description = $request->input('description');
        if (is_string($description)) {
            $request->merge(['description' => trim($description) === '' ? null : trim($description)]);
        }
    }

    private function pattern(): string
    {
        return (string) config('clans.tag_pattern');
    }

    /** @return array<int, string> */
    private function config(string $key): array
    {
        /** @var array<int, string> */
        return config($key);
    }

    private function clan(int $id): Clan
    {
        return Clan::query()->find($id) ?? throw new ClanException('not_found', 404);
    }

    /** @param Closure(): JsonResponse $action */
    private function run(Closure $action): JsonResponse
    {
        try {
            return $action();
        } catch (ClanException $e) {
            return response()->json(['code' => $e->getMessage(), ...$e->extra], $e->status);
        }
    }

    private function user(Request $request): User
    {
        /** @var User $user */
        $user = $request->user();

        return $user;
    }
}
