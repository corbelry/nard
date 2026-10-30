<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;

/** Friends and blocks (spec §8.5). */
class SocialService
{
    public function isBlockedEitherWay(int $a, int $b): bool
    {
        return DB::table('blocks')
            ->where(fn ($q) => $q->where(['blocker_id' => $a, 'blocked_id' => $b]))
            ->orWhere(fn ($q) => $q->where(['blocker_id' => $b, 'blocked_id' => $a]))
            ->exists();
    }

    /** The friendship row between [a] and [b]. */
    public function between(int $a, int $b): ?\stdClass
    {
        /** @var \stdClass|null */
        return DB::table('friendships')
            ->where(fn ($q) => $q->where(['requester_id' => $a, 'addressee_id' => $b]))
            ->orWhere(fn ($q) => $q->where(['requester_id' => $b, 'addressee_id' => $a]))
            ->first();
    }

    /**
     * Sends a request, or accepts the other side's pending one.
     *
     * @return string 'requested' | 'accepted'
     */
    public function request(User $from, User $to): string
    {
        if ($from->id === $to->id) {
            throw new InvalidArgumentException('self');
        }
        if ($this->isBlockedEitherWay($from->id, $to->id)) {
            throw new InvalidArgumentException('blocked');
        }
        $row = $this->between($from->id, $to->id);
        if ($row !== null) {
            if ($row->status === 'accepted') {
                throw new InvalidArgumentException('already_friends');
            }
            if ((int) $row->requester_id === $to->id) {
                $this->accept($from, (int) $row->id);

                return 'accepted';
            }
            throw new InvalidArgumentException('already_requested');
        }
        if ($this->friendCount($from) >= (int) config('social.max_friends')) {
            throw new InvalidArgumentException('too_many_friends');
        }
        DB::table('friendships')->insert([
            'requester_id' => $from->id,
            'addressee_id' => $to->id,
            'status' => 'pending',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return 'requested';
    }

    public function accept(User $user, int $requestId): bool
    {
        return DB::table('friendships')
            ->where(['id' => $requestId, 'addressee_id' => $user->id, 'status' => 'pending'])
            ->update(['status' => 'accepted', 'accepted_at' => now(), 'updated_at' => now()]) > 0;
    }

    /** Declines an incoming or cancels an outgoing request. */
    public function dismiss(User $user, int $requestId): bool
    {
        return DB::table('friendships')
            ->where(['id' => $requestId, 'status' => 'pending'])
            ->where(fn ($q) => $q->where('addressee_id', $user->id)->orWhere('requester_id', $user->id))
            ->delete() > 0;
    }

    public function unfriend(User $user, int $otherId): bool
    {
        return DB::table('friendships')
            ->where(fn ($q) => $q->where(['requester_id' => $user->id, 'addressee_id' => $otherId]))
            ->orWhere(fn ($q) => $q->where(['requester_id' => $otherId, 'addressee_id' => $user->id]))
            ->delete() > 0;
    }

    public function friendCount(User $user): int
    {
        return DB::table('friendships')->where('status', 'accepted')
            ->where(fn ($q) => $q->where('requester_id', $user->id)->orWhere('addressee_id', $user->id))
            ->count();
    }

    /** @return array{friends: array<int, mixed>, incoming: array<int, mixed>, outgoing: array<int, mixed>} */
    public function overview(User $user): array
    {
        $rows = DB::table('friendships')
            ->where(fn ($q) => $q->where('requester_id', $user->id)->orWhere('addressee_id', $user->id))
            ->get();
        $ids = $rows->map(fn ($r) => (int) $r->requester_id === $user->id ? (int) $r->addressee_id : (int) $r->requester_id)->all();
        $users = User::query()->whereIn('id', $ids)->get()->keyBy('id');
        $out = ['friends' => [], 'incoming' => [], 'outgoing' => []];
        foreach ($rows as $r) {
            $otherId = (int) $r->requester_id === $user->id ? (int) $r->addressee_id : (int) $r->requester_id;
            $other = $users->get($otherId);
            if ($other === null) {
                continue;
            }
            $entry = ['requestId' => (int) $r->id, 'user' => $other->publicCard()];
            if ($r->status === 'accepted') {
                $out['friends'][] = $entry;
            } elseif ((int) $r->requester_id === $user->id) {
                $out['outgoing'][] = $entry;
            } else {
                $out['incoming'][] = $entry;
            }
        }
        usort($out['friends'], fn ($a, $b) => [! $a['user']['online'], $a['user']['name']] <=> [! $b['user']['online'], $b['user']['name']]);

        return $out;
    }

    public function block(User $user, User $other): void
    {
        if ($user->id === $other->id) {
            throw new InvalidArgumentException('self');
        }
        DB::table('blocks')->insertOrIgnore([
            'blocker_id' => $user->id, 'blocked_id' => $other->id,
            'created_at' => now(), 'updated_at' => now(),
        ]);
        // Blocking ends the friendship and any pending request.
        $this->unfriend($user, $other->id);
    }
}
