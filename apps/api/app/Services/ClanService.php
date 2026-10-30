<?php

namespace App\Services;

use App\Models\Clan;
use App\Models\ClanMember;
use App\Models\ClanMessage;
use App\Models\ClanWar;
use App\Models\GameMatch;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Str;

/**
 * Clans (spec §8.4): membership and roles, chat, weekly chest, clan XP and
 * weekly wars. Numbers come from config/clans.php; coins move only through
 * WalletService.
 */
class ClanService
{
    public function __construct(private WalletService $wallet, private SocialService $social, private Notifier $notifier) {}

    public function memberOf(User $user): ?ClanMember
    {
        return ClanMember::query()->where('user_id', $user->id)->first();
    }

    /** The actor's membership in [clan] with at least [minRole]. */
    public function requireMember(Clan $clan, User $user, string $minRole = 'member'): ClanMember
    {
        $member = ClanMember::query()->where(['clan_id' => $clan->id, 'user_id' => $user->id])->first();
        if ($member === null) {
            throw new ClanException('not_member', 403);
        }
        if ($member->rankValue() < ClanMember::rank($minRole)) {
            throw new ClanException('forbidden', 403);
        }

        return $member;
    }

    // ---- create / settings ---------------------------------------------

    /**
     * Debits the create price; a retried [key] returns the same clan.
     *
     * @param  array{name: string, tag: string, emblem: array<string, string>, description: ?string, language: string, minRating: ?int, joinPolicy: string}  $data
     */
    public function create(User $user, array $data, string $key): Clan
    {
        $walletKey = "clan_create:{$user->id}:$key";

        return DB::transaction(function () use ($user, $data, $walletKey): Clan {
            $done = DB::table('wallet_transactions')->where('idempotency_key', $walletKey)->first();
            if ($done !== null) {
                $clan = Clan::query()->find((int) Str::after((string) $done->reference, 'clan:'));

                return $clan ?? throw new ClanException('not_found', 404);
            }
            if ($this->memberOf($user) !== null) {
                throw new ClanException('already_in_clan');
            }
            $this->assertNameFree($data['name']);
            $this->assertTagFree($data['tag']);
            $clan = Clan::query()->create([
                'name' => $data['name'],
                'name_key' => Clan::nameKey($data['name']),
                'tag' => $data['tag'],
                'emblem' => self::emblem($data['emblem']),
                'description' => $data['description'],
                'language' => $data['language'],
                'min_rating' => $data['minRating'],
                'join_policy' => $data['joinPolicy'],
                'created_by' => $user->id,
            ]);
            try {
                $this->wallet->debit($user, 'coins', (int) config('clans.create_price'), 'clan_create', $walletKey, "clan:{$clan->id}");
            } catch (InsufficientFunds) {
                throw new ClanException('insufficient_funds');
            }
            ClanMember::query()->create(['clan_id' => $clan->id, 'user_id' => $user->id, 'role' => 'leader', 'joined_at' => now()]);
            $this->clearPending($user);
            $this->system($clan->id, 'created', ['userId' => (string) $user->id, 'name' => $user->name]);

            return $clan;
        });
    }

    /**
     * Settings (co-leader+); name/tag only by the leader, for the rename
     * price, keyed by [key].
     *
     * @param  array<string, mixed>  $data  validated, API field names
     */
    public function update(Clan $clan, User $user, array $data, ?string $key): Clan
    {
        return DB::transaction(function () use ($clan, $user, $data, $key): Clan {
            $actor = $this->requireMember($clan, $user, 'co_leader');
            $name = isset($data['name']) && $data['name'] !== $clan->name ? (string) $data['name'] : null;
            $tag = isset($data['tag']) && $data['tag'] !== $clan->tag ? (string) $data['tag'] : null;
            if ($name !== null || $tag !== null) {
                if ($actor->role !== 'leader') {
                    throw new ClanException('forbidden', 403);
                }
                if ($key === null) {
                    throw new ClanException('idempotency_key_required');
                }
                $walletKey = "clan_rename:{$clan->id}:$key";
                // A retried rename is not charged or applied twice.
                if (! DB::table('wallet_transactions')->where('idempotency_key', $walletKey)->exists()) {
                    if ($name !== null) {
                        $this->assertNameFree($name, $clan->id);
                        $clan->name = $name;
                        $clan->name_key = Clan::nameKey($name);
                    }
                    if ($tag !== null) {
                        $this->assertTagFree($tag, $clan->id);
                        $clan->tag = $tag;
                    }
                    try {
                        $this->wallet->debit($user, 'coins', (int) config('clans.rename_price'), 'clan_rename', $walletKey, "clan:{$clan->id}");
                    } catch (InsufficientFunds) {
                        throw new ClanException('insufficient_funds');
                    }
                    $this->system($clan->id, 'renamed', ['name' => $clan->name, 'tag' => $clan->tag]);
                }
            }
            if (isset($data['emblem']) && is_array($data['emblem'])) {
                /** @var array<string, string> $emblem */
                $emblem = $data['emblem'];
                $clan->emblem = self::emblem($emblem);
            }
            foreach (['description' => 'description', 'language' => 'language', 'minRating' => 'min_rating', 'joinPolicy' => 'join_policy'] as $field => $column) {
                if (array_key_exists($field, $data)) {
                    $clan->{$column} = $data[$field];
                }
            }
            $clan->save();

            return $clan;
        });
    }

    /**
     * @param  array<string, string>  $emblem
     * @return array{shape: string, symbol: string, color: string, pattern: string}
     */
    private static function emblem(array $emblem): array
    {
        return [
            'shape' => $emblem['shape'],
            'symbol' => $emblem['symbol'],
            'color' => $emblem['color'],
            'pattern' => $emblem['pattern'] ?? 'none',
        ];
    }

    public function tagFree(string $tag): bool
    {
        return ! Clan::query()->where('tag', $tag)->exists();
    }

    private function assertNameFree(string $name, ?int $except = null): void
    {
        if (Clan::query()->where('name_key', Clan::nameKey($name))->when($except !== null, fn ($q) => $q->where('id', '!=', $except))->exists()) {
            throw new ClanException('name_taken');
        }
    }

    private function assertTagFree(string $tag, ?int $except = null): void
    {
        if (Clan::query()->where('tag', $tag)->when($except !== null, fn ($q) => $q->where('id', '!=', $except))->exists()) {
            throw new ClanException('tag_taken');
        }
    }

    public function disband(Clan $clan, User $user): void
    {
        $this->requireMember($clan, $user, 'leader');
        $clan->delete();
    }

    // ---- membership -----------------------------------------------------

    /** @return string 'joined' | 'requested' */
    public function join(Clan $clan, User $user): string
    {
        return DB::transaction(function () use ($clan, $user): string {
            $clan = $this->lock($clan->id);
            if ($this->memberOf($user) !== null) {
                throw new ClanException('already_in_clan');
            }
            // An invite lets the player in whatever the policy and minimum.
            if ($this->validInvite($clan->id, $user->id) !== null) {
                $this->addMember($clan, $user);

                return 'joined';
            }
            if ($clan->join_policy === 'invite') {
                throw new ClanException('invite_only');
            }
            if ($clan->min_rating !== null && $user->bestRating() < $clan->min_rating) {
                throw new ClanException('rating_too_low');
            }
            if ($this->isFull($clan)) {
                throw new ClanException('clan_full');
            }
            if ($clan->join_policy === 'open') {
                $this->addMember($clan, $user);

                return 'joined';
            }
            DB::table('clan_join_requests')->insertOrIgnore([
                'clan_id' => $clan->id, 'user_id' => $user->id, 'created_at' => now(), 'updated_at' => now(),
            ]);

            return 'requested';
        });
    }

    public function cancelRequest(Clan $clan, User $user): bool
    {
        return DB::table('clan_join_requests')->where(['clan_id' => $clan->id, 'user_id' => $user->id])->delete() > 0;
    }

    /** @return string 'left' | 'disbanded' */
    public function leave(Clan $clan, User $user): string
    {
        return DB::transaction(function () use ($clan, $user): string {
            $member = $this->requireMember($clan, $user);
            if ($member->role === 'leader') {
                if (ClanMember::query()->where('clan_id', $clan->id)->count() > 1) {
                    throw new ClanException('transfer_first');
                }
                $clan->delete();

                return 'disbanded';
            }
            $member->delete();
            $this->system($clan->id, 'left', ['userId' => (string) $user->id, 'name' => $user->name]);

            return 'left';
        });
    }

    /** @return array<int, array<string, mixed>> */
    public function requests(Clan $clan, User $user): array
    {
        $this->requireMember($clan, $user, 'elder');
        $rows = DB::table('clan_join_requests')->where('clan_id', $clan->id)->orderBy('id')->get();
        $users = User::query()->whereIn('id', $rows->pluck('user_id'))->get()->keyBy('id');

        return $rows->map(fn ($r) => [
            'id' => (int) $r->id,
            'user' => $users->get((int) $r->user_id)?->publicCard(),
            'createdAt' => Carbon::parse((string) $r->created_at)->toIso8601String(),
        ])->filter(fn ($r) => $r['user'] !== null)->values()->all();
    }

    public function acceptRequest(Clan $clan, User $user, int $requestId): void
    {
        DB::transaction(function () use ($clan, $user, $requestId): void {
            $this->requireMember($clan, $user, 'elder');
            $clan = $this->lock($clan->id);
            $row = DB::table('clan_join_requests')->where(['id' => $requestId, 'clan_id' => $clan->id])->first();
            $target = $row === null ? null : User::query()->find((int) $row->user_id);
            if ($row === null || $target === null) {
                throw new ClanException('not_found', 404);
            }
            if ($this->memberOf($target) !== null) {
                DB::table('clan_join_requests')->where('id', $requestId)->delete();
                throw new ClanException('already_in_clan');
            }
            $this->addMember($clan, $target);
            $this->notifier->notify($target, 'clan_joined', ['clanId' => (string) $clan->id, 'clan' => $clan->name, 'tag' => $clan->tag],
                "clan_joined:{$clan->id}:{$requestId}");
        });
    }

    public function declineRequest(Clan $clan, User $user, int $requestId): void
    {
        $this->requireMember($clan, $user, 'co_leader');
        if (DB::table('clan_join_requests')->where(['id' => $requestId, 'clan_id' => $clan->id])->delete() === 0) {
            throw new ClanException('not_found', 404);
        }
    }

    public function invite(Clan $clan, User $user, int $targetId): int
    {
        $this->requireMember($clan, $user, 'elder');
        $target = User::query()->find($targetId);
        if ($target === null) {
            throw new ClanException('not_found', 404);
        }
        if ($target->id === $user->id) {
            throw new ClanException('self');
        }
        if ($this->memberOf($target) !== null) {
            throw new ClanException('already_in_clan');
        }
        if ($this->social->isBlockedEitherWay($user->id, $target->id)) {
            throw new ClanException('blocked');
        }
        if ($this->isFull($clan)) {
            throw new ClanException('clan_full');
        }
        DB::table('clan_invites')->where(['clan_id' => $clan->id, 'user_id' => $target->id])->delete();
        $expires = now()->addDays((int) config('clans.invite_ttl_days'));
        $id = DB::table('clan_invites')->insertGetId([
            'clan_id' => $clan->id,
            'user_id' => $target->id,
            'invited_by' => $user->id,
            'expires_at' => $expires,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
        // Re-invites by the same clan stack at most once a day.
        $this->notifier->notify($target, 'clan_invite', [
            'inviteId' => $id, 'clanId' => (string) $clan->id, 'clan' => $clan->name, 'tag' => $clan->tag,
            'expiresAt' => $expires->toIso8601String(),
        ], "clan_invite:{$clan->id}:{$expires->format('Y-m-d')}", $user->id);

        return $id;
    }

    /** @return array<int, array<string, mixed>> */
    public function myInvites(User $user): array
    {
        $rows = DB::table('clan_invites')->where('user_id', $user->id)->where('expires_at', '>', now())->orderByDesc('id')->get();
        $clans = Clan::query()->withCount('members')->whereIn('id', $rows->pluck('clan_id'))->get()->keyBy('id');
        $ratings = $this->ratings($clans->keys()->all());

        return $rows->map(function ($r) use ($clans, $ratings) {
            $clan = $clans->get((int) $r->clan_id);

            return $clan === null ? null : [
                'id' => (int) $r->id,
                'clan' => $clan->summary($ratings[$clan->id] ?? null),
                'invitedBy' => $r->invited_by === null ? null : User::query()->find((int) $r->invited_by)?->publicCard(),
                'expiresAt' => Carbon::parse((string) $r->expires_at)->toIso8601String(),
            ];
        })->filter()->values()->all();
    }

    public function acceptInvite(User $user, int $inviteId): Clan
    {
        return DB::transaction(function () use ($user, $inviteId): Clan {
            $row = DB::table('clan_invites')->where(['id' => $inviteId, 'user_id' => $user->id])->where('expires_at', '>', now())->first();
            if ($row === null) {
                throw new ClanException('not_found', 404);
            }
            if ($this->memberOf($user) !== null) {
                throw new ClanException('already_in_clan');
            }
            $clan = $this->lock((int) $row->clan_id);
            $this->addMember($clan, $user);

            return $clan;
        });
    }

    public function declineInvite(User $user, int $inviteId): void
    {
        if (DB::table('clan_invites')->where(['id' => $inviteId, 'user_id' => $user->id])->delete() === 0) {
            throw new ClanException('not_found', 404);
        }
    }

    /** Promote / demote; role "leader" transfers leadership (leader only). */
    public function setRole(Clan $clan, User $user, int $targetId, string $role): void
    {
        DB::transaction(function () use ($clan, $user, $targetId, $role): void {
            $actor = $this->requireMember($clan, $user, 'co_leader');
            $target = $this->targetMember($clan, $user, $targetId);
            if ($role === 'leader') {
                if ($actor->role !== 'leader') {
                    throw new ClanException('forbidden', 403);
                }
                $target->update(['role' => 'leader']);
                $actor->update(['role' => 'co_leader']);
                $this->system($clan->id, 'leader', ['userId' => (string) $target->user_id, 'name' => $target->user->name]);

                return;
            }
            // Only roles strictly below the actor, on members strictly below.
            if ($actor->rankValue() <= $target->rankValue() || $actor->rankValue() <= ClanMember::rank($role)) {
                throw new ClanException('forbidden', 403);
            }
            if ($target->role === $role) {
                return;
            }
            $promoted = ClanMember::rank($role) > $target->rankValue();
            $target->update(['role' => $role]);
            $this->system($clan->id, $promoted ? 'promoted' : 'demoted', [
                'userId' => (string) $target->user_id, 'name' => $target->user->name, 'role' => $role,
            ]);
        });
    }

    public function kick(Clan $clan, User $user, int $targetId): void
    {
        $actor = $this->requireMember($clan, $user, 'elder');
        $target = $this->targetMember($clan, $user, $targetId);
        if ($actor->rankValue() <= $target->rankValue()) {
            throw new ClanException('forbidden', 403);
        }
        $target->delete();
        $this->system($clan->id, 'kicked', ['userId' => (string) $target->user_id, 'name' => $target->user->name]);
    }

    private function targetMember(Clan $clan, User $actor, int $targetId): ClanMember
    {
        if ($targetId === $actor->id) {
            throw new ClanException('self');
        }
        $target = ClanMember::query()->with('user')->where(['clan_id' => $clan->id, 'user_id' => $targetId])->first();

        return $target ?? throw new ClanException('not_found', 404);
    }

    /** A deleted account hands leadership on, or disbands a clan of one. */
    public function onUserDeleted(User $user): void
    {
        $member = $this->memberOf($user);
        if ($member === null || $member->role !== 'leader') {
            return;
        }
        $next = ClanMember::query()->with('user')->where('clan_id', $member->clan_id)->where('id', '!=', $member->id)->get()
            ->sortBy([fn (ClanMember $a, ClanMember $b) => $b->rankValue() <=> $a->rankValue(), ['joined_at', 'asc']])
            ->first();
        if ($next === null) {
            Clan::query()->whereKey($member->clan_id)->delete();

            return;
        }
        $member->update(['role' => 'member']);
        $next->update(['role' => 'leader']);
        $this->system($member->clan_id, 'leader', ['userId' => (string) $next->user_id, 'name' => $next->user->name]);
    }

    private function addMember(Clan $clan, User $user): void
    {
        if ($this->isFull($clan)) {
            throw new ClanException('clan_full');
        }
        ClanMember::query()->create(['clan_id' => $clan->id, 'user_id' => $user->id, 'role' => 'member', 'joined_at' => now()]);
        $this->clearPending($user);
        $this->system($clan->id, 'joined', ['userId' => (string) $user->id, 'name' => $user->name]);
    }

    private function isFull(Clan $clan): bool
    {
        return ClanMember::query()->where('clan_id', $clan->id)->count() >= (int) config('clans.max_members');
    }

    /** One clan per player: other applications and invites end on joining. */
    private function clearPending(User $user): void
    {
        DB::table('clan_join_requests')->where('user_id', $user->id)->delete();
        DB::table('clan_invites')->where('user_id', $user->id)->delete();
    }

    private function validInvite(int $clanId, int $userId): ?\stdClass
    {
        /** @var \stdClass|null */
        return DB::table('clan_invites')->where(['clan_id' => $clanId, 'user_id' => $userId])->where('expires_at', '>', now())->first();
    }

    private function lock(int $clanId): Clan
    {
        return Clan::query()->lockForUpdate()->find($clanId) ?? throw new ClanException('not_found', 404);
    }

    /** none | pending | invited | member */
    public function statusOf(Clan $clan, User $user): string
    {
        if (ClanMember::query()->where(['clan_id' => $clan->id, 'user_id' => $user->id])->exists()) {
            return 'member';
        }
        if ($this->validInvite($clan->id, $user->id) !== null) {
            return 'invited';
        }

        return DB::table('clan_join_requests')->where(['clan_id' => $clan->id, 'user_id' => $user->id])->exists() ? 'pending' : 'none';
    }

    /**
     * Clan rating = average of the members' best ratings (initial rating
     * for players without one).
     *
     * @param  array<int, int>  $clanIds
     * @return array<int, int>
     */
    public function ratings(array $clanIds): array
    {
        if ($clanIds === []) {
            return [];
        }
        $initial = (int) config('nard.rating.initial');
        $rows = DB::table('clan_members')
            ->leftJoin('ratings', 'ratings.user_id', '=', 'clan_members.user_id')
            ->whereIn('clan_members.clan_id', $clanIds)
            ->groupBy('clan_members.clan_id', 'clan_members.user_id')
            ->select('clan_members.clan_id', DB::raw('MAX(ratings.rating) as best'))
            ->get();

        return $rows->groupBy('clan_id')
            ->map(fn ($members) => (int) round((float) $members->avg(fn ($m) => $m->best === null ? $initial : (int) $m->best)))
            ->mapWithKeys(fn ($avg, $clanId) => [(int) $clanId => $avg])
            ->all();
    }

    // ---- chat -----------------------------------------------------------

    /** @return array<int, ClanMessage> latest page after [after], oldest first */
    public function messages(Clan $clan, User $user, ?int $after): array
    {
        $this->requireMember($clan, $user);
        $blocked = DB::table('blocks')->where('blocker_id', $user->id)->pluck('blocked_id')->all();

        return ClanMessage::query()->with('user')->where('clan_id', $clan->id)
            ->when($after !== null, fn ($q) => $q->where('id', '>', $after))
            ->when($blocked !== [], fn ($q) => $q->where(fn ($q) => $q->whereNull('user_id')->orWhereNotIn('user_id', $blocked)))
            ->orderByDesc('id')->limit((int) config('clans.chat.page'))->get()
            ->reverse()->values()->all();
    }

    public function post(Clan $clan, User $user, string $text): ClanMessage
    {
        $this->requireMember($clan, $user);
        $key = "clan-chat:{$user->id}";
        if (RateLimiter::tooManyAttempts($key, (int) config('clans.chat.per_minute'))) {
            throw new ClanException('rate_limited', 429);
        }
        RateLimiter::hit($key, 60);
        $message = ClanMessage::query()->create(['clan_id' => $clan->id, 'user_id' => $user->id, 'kind' => 'text', 'body' => $text]);
        $message->setRelation('user', $user);

        return $message;
    }

    /** Own messages, or anyone's for elders and above (moderation). */
    public function deleteMessage(Clan $clan, User $user, int $messageId): void
    {
        $actor = $this->requireMember($clan, $user);
        $message = ClanMessage::query()->where(['id' => $messageId, 'clan_id' => $clan->id])->first();
        if ($message === null) {
            throw new ClanException('not_found', 404);
        }
        $own = $message->kind === 'text' && $message->user_id === $user->id;
        if (! $own && $actor->rankValue() < ClanMember::rank('elder')) {
            throw new ClanException('forbidden', 403);
        }
        $message->deleted_by = $user->id;
        $message->save();
        $message->delete();
    }

    /** @param array<string, mixed> $data */
    private function system(int $clanId, string $event, array $data): void
    {
        ClanMessage::query()->create(['clan_id' => $clanId, 'kind' => 'system', 'event' => $event, 'data' => $data]);
    }

    // ---- chest and XP ---------------------------------------------------

    /** @return array{week: string, coins: int, target: int, myDonated: int|null} */
    public function chest(Clan $clan, ?ClanMember $member): array
    {
        return [
            'week' => Clan::week(),
            'coins' => $clan->chestThisWeek(),
            'target' => (int) config('clans.chest.weekly_target'),
            'myDonated' => $member?->donatedThisWeek(),
        ];
    }

    /**
     * Moves coins into this week's chest (capped at the target). A retried
     * [key] changes nothing. Returns the coins actually donated.
     */
    public function donate(Clan $clan, User $user, int $coins, string $key): int
    {
        $walletKey = "clan_donation:{$user->id}:$key";

        return DB::transaction(function () use ($clan, $user, $coins, $walletKey): int {
            $member = $this->requireMember($clan, $user);
            $clan = $this->lock($clan->id);
            $done = DB::table('wallet_transactions')->where('idempotency_key', $walletKey)->first();
            if ($done !== null) {
                return (int) abs((int) $done->amount);
            }
            $week = Clan::week();
            if ($clan->chest_week !== $week) {
                $clan->chest_week = $week;
                $clan->chest_coins = 0;
            }
            $target = (int) config('clans.chest.weekly_target');
            $before = $clan->chest_coins;
            if ($before >= $target) {
                throw new ClanException('chest_full');
            }
            $amount = min($coins, $target - $before);
            try {
                $this->wallet->debit($user, 'coins', $amount, 'clan_donation', $walletKey, "clan:{$clan->id}");
            } catch (InsufficientFunds) {
                throw new ClanException('insufficient_funds');
            }
            $clan->chest_coins = $before + $amount;
            $clan->save();
            if ($member->donated_week !== $week) {
                $member->donated_week = $week;
                $member->donated_coins = 0;
            }
            $member->donated_coins += $amount;
            $member->save();
            // 1 XP per N coins in the weekly total (no rounding loss across gifts).
            $per = (int) config('clans.xp.coins_per_xp');
            $xp = intdiv($clan->chest_coins, $per) - intdiv($before, $per);
            $full = $clan->chest_coins >= $target;
            $this->addXp($clan, $xp + ($full ? (int) config('clans.xp.chest_full') : 0));
            $this->system($clan->id, 'donated', ['userId' => (string) $user->id, 'name' => $user->name, 'amount' => $amount]);
            if ($full) {
                $this->system($clan->id, 'chest_full', ['target' => $target]);
            }

            return $amount;
        });
    }

    /** Call inside a transaction with [clan] locked or freshly read. */
    public function addXp(Clan $clan, int $xp): void
    {
        if ($xp <= 0) {
            return;
        }
        $clan->xp += $xp;
        $clan->level = Clan::levelFor($clan->xp);
        $clan->save();
    }

    // ---- matches and wars -----------------------------------------------

    /**
     * A newly stored match (inside MatchResultService's transaction): clan
     * XP for a win over a human from another clan, and war points when the
     * two clans are at war.
     */
    public function onMatch(GameMatch $match): void
    {
        if ($match->white_bot || $match->black_bot || $match->white_user_id === null || $match->black_user_id === null) {
            return;
        }
        $whiteWon = $match->winner === 'white';
        $winnerId = $whiteWon ? $match->white_user_id : $match->black_user_id;
        $loserId = $whiteWon ? $match->black_user_id : $match->white_user_id;
        $winner = ClanMember::query()->with('user')->where('user_id', $winnerId)->first();
        $loser = ClanMember::query()->where('user_id', $loserId)->first();
        // Games inside one clan never count (no farming).
        if ($winner === null || ($loser !== null && $loser->clan_id === $winner->clan_id)) {
            return;
        }
        $clan = $this->lock($winner->clan_id);
        $this->addXp($clan, (int) config('clans.xp.online_win'));
        if ($loser === null) {
            return;
        }
        $war = ClanWar::query()->lockForUpdate()->where('status', 'live')
            ->where('starts_at', '<=', now())->where('ends_at', '>=', now())
            ->where(fn ($q) => $q->where(['clan_a_id' => $winner->clan_id, 'clan_b_id' => $loser->clan_id])
                ->orWhere(fn ($q) => $q->where(['clan_a_id' => $loser->clan_id, 'clan_b_id' => $winner->clan_id])))
            ->first();
        if ($war === null || $war->matches_counted >= (int) config('clans.war.max_matches')) {
            return;
        }
        $points = (int) config('clans.war.points_per_win');
        if ($war->clan_a_id === $winner->clan_id) {
            $war->score_a += $points;
        } else {
            $war->score_b += $points;
        }
        $war->matches_counted += 1;
        $war->save();
        DB::table('clan_war_matches')->insert([
            'clan_war_id' => $war->id,
            'match_id' => $match->id,
            'winner_user_id' => $winnerId,
            'loser_user_id' => $loserId,
            'winner_clan_id' => $winner->clan_id,
            'winner_score' => $whiteWon ? $match->white_score : $match->black_score,
            'loser_score' => $whiteWon ? $match->black_score : $match->white_score,
            'created_at' => now(),
        ]);
        $this->system($winner->clan_id, 'war_win', ['userId' => (string) $winnerId, 'name' => $winner->user->name, 'points' => $points]);
    }

    /** Pairs eligible clans of similar level for the week of [now]. */
    public function pairWars(Carbon $now): int
    {
        $now = $now->copy()->utc();
        $week = Clan::week($now);
        $busy = ClanWar::query()->where('week', $week)->get()
            ->flatMap(fn (ClanWar $w) => [$w->clan_a_id, $w->clan_b_id])->filter()->values()->all();
        $activeSince = $now->copy()->subDays((int) config('clans.war.active_days'));
        $clans = Clan::query()->withCount('members')->whereNotIn('id', $busy)
            ->whereHas('members.user', fn ($q) => $q->where('last_seen_at', '>=', $activeSince))
            ->orderByDesc('level')->orderByDesc('xp')->orderBy('id')->get()
            ->filter(fn (Clan $c) => (int) $c->members_count >= (int) config('clans.war.min_members'))
            ->values();
        $gap = (int) config('clans.war.max_level_gap');
        $paired = 0;
        $i = 0;
        while ($i + 1 < $clans->count()) {
            /** @var Clan $a */
            $a = $clans[$i];
            /** @var Clan $b */
            $b = $clans[$i + 1];
            if ($a->level - $b->level > $gap) {
                $i++;

                continue;
            }
            DB::transaction(function () use ($a, $b, $week, $now): void {
                $war = ClanWar::query()->create([
                    'week' => $week,
                    'clan_a_id' => $a->id,
                    'clan_b_id' => $b->id,
                    'status' => 'live',
                    'starts_at' => $now->copy()->startOfWeek(Carbon::MONDAY),
                    'ends_at' => $now->copy()->endOfWeek(Carbon::SUNDAY),
                ]);
                $this->system($a->id, 'war_started', ['clanId' => (string) $b->id, 'name' => $b->name, 'tag' => $b->tag]);
                $this->system($b->id, 'war_started', ['clanId' => (string) $a->id, 'name' => $a->name, 'tag' => $a->tag]);
                foreach ([[$a, $b], [$b, $a]] as [$mine, $theirs]) {
                    $this->notifier->notifyMany(
                        ClanMember::query()->where('clan_id', $mine->id)->pluck('user_id')->map(fn ($id) => (int) $id),
                        'clan_war',
                        ['clanId' => (string) $mine->id, 'warId' => $war->id, 'opponentId' => (string) $theirs->id, 'opponent' => $theirs->name, 'tag' => $theirs->tag],
                        "clan_war:{$war->id}",
                    );
                }
            });
            $paired++;
            $i += 2;
        }

        return $paired;
    }

    /** Finishes live wars that ended before [now]; the winner gets clan XP. */
    public function closeWars(Carbon $now): int
    {
        $ids = ClanWar::query()->where('status', 'live')->where('ends_at', '<', $now)->pluck('id');
        foreach ($ids as $id) {
            DB::transaction(function () use ($id): void {
                $war = ClanWar::query()->lockForUpdate()->find((int) $id);
                if ($war === null || $war->status !== 'live') {
                    return;
                }
                $winner = $war->score_a > $war->score_b ? $war->clan_a_id : ($war->score_b > $war->score_a ? $war->clan_b_id : null);
                $war->status = 'finished';
                $war->winner_clan_id = $winner;
                $war->save();
                if ($winner !== null && ($clan = Clan::query()->lockForUpdate()->find($winner)) !== null) {
                    $this->addXp($clan, (int) config('clans.xp.war_win'));
                }
                foreach ([[$war->clan_a_id, $war->score_a, $war->score_b], [$war->clan_b_id, $war->score_b, $war->score_a]] as [$clanId, $mine, $theirs]) {
                    if ($clanId !== null && Clan::query()->whereKey($clanId)->exists()) {
                        $result = $winner === null ? 'draw' : ($winner === $clanId ? 'won' : 'lost');
                        $this->system($clanId, 'war_ended', ['result' => $result, 'mine' => $mine, 'theirs' => $theirs]);
                    }
                }
            });
        }

        return $ids->count();
    }

    /**
     * The clan's latest war seen from its side, or null.
     *
     * @return array<string, mixed>|null
     */
    public function war(Clan $clan): ?array
    {
        $war = ClanWar::query()->where(fn ($q) => $q->where('clan_a_id', $clan->id)->orWhere('clan_b_id', $clan->id))
            ->orderByDesc('id')->first();
        if ($war === null) {
            return null;
        }
        $isA = $war->clan_a_id === $clan->id;
        $opponentId = $isA ? $war->clan_b_id : $war->clan_a_id;
        $opponent = $opponentId === null ? null : Clan::query()->withCount('members')->find($opponentId);
        $rows = DB::table('clan_war_matches')->where('clan_war_id', $war->id)->orderBy('id')->get();
        $users = User::query()->whereIn('id', $rows->pluck('winner_user_id')->merge($rows->pluck('loser_user_id'))->filter())->get()->keyBy('id');
        $player = fn ($id) => $id === null ? null : (($u = $users->get((int) $id)) === null ? null : ['id' => (string) $u->id, 'name' => $u->name, 'avatar' => $u->avatar]);

        return [
            'id' => $war->id,
            'week' => $war->week,
            'status' => $war->status,
            'startsAt' => $war->starts_at->toIso8601String(),
            'endsAt' => $war->ends_at->toIso8601String(),
            'clan' => $clan->summary(),
            'opponent' => $opponent?->summary(),
            'score' => ['mine' => $isA ? $war->score_a : $war->score_b, 'theirs' => $isA ? $war->score_b : $war->score_a],
            'matchesCounted' => $war->matches_counted,
            'maxMatches' => (int) config('clans.war.max_matches'),
            'pointsPerWin' => (int) config('clans.war.points_per_win'),
            'result' => $war->status !== 'finished' ? null
                : ($war->winner_clan_id === null ? 'draw' : ($war->winner_clan_id === $clan->id ? 'won' : 'lost')),
            'matches' => $rows->map(fn ($r) => [
                'matchId' => $r->match_id,
                'winner' => $player($r->winner_user_id),
                'loser' => $player($r->loser_user_id),
                'score' => [(int) $r->winner_score, (int) $r->loser_score],
                // From this clan's side.
                'won' => (int) $r->winner_clan_id === $clan->id,
                'createdAt' => Carbon::parse((string) $r->created_at)->toIso8601String(),
            ])->all(),
        ];
    }
}
