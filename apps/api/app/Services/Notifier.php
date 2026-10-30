<?php

namespace App\Services;

use App\Jobs\PushLiveNotifications;
use App\Jobs\SendPushNotification;
use App\Models\User;
use App\Services\Push\PushSender;
use Illuminate\Database\Query\Builder;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * Notifications (spec §8.11, ADR-041): every event lands in the player's
 * inbox (16.2); a push is queued when the category is on (16.1), push is
 * on, it is not quiet hours, the player has a device and FCM is
 * configured. Senders blocked either way never reach the player; a dedupe
 * key keeps one row per event.
 */
class Notifier
{
    public function __construct(private PushSender $push) {}

    /**
     * Records [type] for [to]; returns the new row id, or null when it was
     * dropped (blocked sender, self, duplicate).
     *
     * @param  array<string, mixed>  $data
     */
    public function notify(User|int $to, string $type, array $data = [], ?string $dedupe = null, ?int $from = null): ?int
    {
        $id = $this->record($to, $type, $data, $dedupe, $from);
        if ($id !== null) {
            $this->live([$id]);
        }

        return $id;
    }

    /**
     * Stores the row and queues its push; no live delivery yet.
     *
     * @param  array<string, mixed>  $data
     */
    private function record(User|int $to, string $type, array $data, ?string $dedupe, ?int $from): ?int
    {
        $toId = $to instanceof User ? $to->id : $to;
        if ($from !== null && ($from === $toId || $this->blocked($toId, $from))) {
            return null;
        }
        $row = [
            'user_id' => $toId,
            'type' => $type,
            'from_user_id' => $from,
            'data' => json_encode((object) $data),
            'dedupe_key' => $dedupe,
            'created_at' => now(),
        ];
        if ($dedupe === null) {
            $id = DB::table('notifications')->insertGetId($row);
        } else {
            if (DB::table('notifications')->insertOrIgnore($row) === 0) {
                return null;
            }
            $id = (int) DB::table('notifications')->where(['user_id' => $toId, 'dedupe_key' => $dedupe])->value('id');
        }
        $this->queuePush($toId, $id, $type);

        return $id;
    }

    /**
     * The same event for several players (a clan, a tournament field).
     *
     * @param  iterable<int>  $userIds
     * @param  array<string, mixed>  $data
     */
    public function notifyMany(iterable $userIds, string $type, array $data, string $dedupe): int
    {
        $ids = [];
        foreach ($userIds as $userId) {
            $id = $this->record((int) $userId, $type, $data, $dedupe, null);
            if ($id !== null) {
                $ids[] = $id;
            }
        }
        $this->live($ids);

        return count($ids);
    }

    /**
     * Live delivery (ADR-049): after the surrounding transaction commits, the
     * rows go to the players' open sockets through the game server (queued,
     * so a slow game server never delays the action). Nothing is queued
     * without a configured game server.
     *
     * @param  list<int>  $ids
     */
    private function live(array $ids): void
    {
        if ($ids === [] || ! GameServerClient::configured()) {
            return;
        }
        PushLiveNotifications::dispatch($ids)->afterCommit();
    }

    private function blocked(int $a, int $b): bool
    {
        return DB::table('blocks')
            ->where(fn ($q) => $q->where(['blocker_id' => $a, 'blocked_id' => $b]))
            ->orWhere(fn ($q) => $q->where(['blocker_id' => $b, 'blocked_id' => $a]))
            ->exists();
    }

    public static function category(string $type): ?string
    {
        $category = config("push.types.$type");

        return is_string($category) ? $category : null;
    }

    private function queuePush(int $userId, int $notificationId, string $type): void
    {
        if (! $this->wantsPush($userId, $type, now())) {
            return;
        }
        if (! DB::table('device_tokens')->where('user_id', $userId)->exists()) {
            return;
        }
        if (! $this->push->enabled()) {
            Log::info('push disabled: not queued', ['notification' => $notificationId, 'type' => $type]);

            return;
        }
        SendPushNotification::dispatch($notificationId)->afterCommit();
    }

    /** Category on, push on and outside quiet hours (player's local time). */
    public function wantsPush(int $userId, string $type, Carbon $now): bool
    {
        $category = self::category($type);
        if ($category === null) {
            return false;
        }
        $s = $this->settingsRow($userId);
        if (! $s['push'] || in_array($category, $s['muted'], true)) {
            return false;
        }

        return ! ($s['quiet_enabled'] && self::inQuietHours($s['quiet_start'], $s['quiet_end'], $s['utc_offset'], $now));
    }

    /** [start] inclusive, [end] exclusive, "HH:MM"; may wrap past midnight. */
    public static function inQuietHours(string $start, string $end, int $utcOffset, Carbon $now): bool
    {
        $local = $now->copy()->utc()->addMinutes($utcOffset)->format('H:i');
        if ($start === $end) {
            return false;
        }

        return $start < $end
            ? $local >= $start && $local < $end
            : $local >= $start || $local < $end;
    }

    // ---- settings (16.1) -----------------------------------------------------

    /** @return array{push: bool, quiet_enabled: bool, quiet_start: string, quiet_end: string, utc_offset: int, muted: list<string>} */
    private function settingsRow(int $userId): array
    {
        $row = DB::table('notification_settings')->where('user_id', $userId)->first();
        if ($row === null) {
            return [
                'push' => true,
                'quiet_enabled' => (bool) config('push.quiet_hours.enabled'),
                'quiet_start' => (string) config('push.quiet_hours.start'),
                'quiet_end' => (string) config('push.quiet_hours.end'),
                'utc_offset' => 0,
                'muted' => [],
            ];
        }
        $muted = json_decode((string) $row->muted, true);

        return [
            'push' => (bool) $row->push,
            'quiet_enabled' => (bool) $row->quiet_enabled,
            'quiet_start' => (string) $row->quiet_start,
            'quiet_end' => (string) $row->quiet_end,
            'utc_offset' => (int) $row->utc_offset,
            'muted' => is_array($muted) ? array_values(array_filter($muted, 'is_string')) : [],
        ];
    }

    /** @return array<string, mixed> */
    public function settings(int $userId): array
    {
        $s = $this->settingsRow($userId);
        /** @var list<string> $categories */
        $categories = config('push.categories');

        return [
            'push' => $s['push'],
            'quietHours' => ['enabled' => $s['quiet_enabled'], 'start' => $s['quiet_start'], 'end' => $s['quiet_end']],
            'categories' => collect($categories)->mapWithKeys(fn (string $c) => [$c => ! in_array($c, $s['muted'], true)])->all(),
            'pushAvailable' => $this->push->enabled(),
        ];
    }

    /**
     * @param  array{push?: bool, quietHours?: array{enabled?: bool, start?: string, end?: string}, categories?: array<string, bool>, utcOffset?: int}  $input
     * @return array<string, mixed>
     */
    public function updateSettings(int $userId, array $input): array
    {
        $s = $this->settingsRow($userId);
        if (array_key_exists('push', $input)) {
            $s['push'] = (bool) $input['push'];
        }
        $quiet = $input['quietHours'] ?? [];
        foreach (['enabled' => 'quiet_enabled', 'start' => 'quiet_start', 'end' => 'quiet_end'] as $key => $column) {
            if (array_key_exists($key, $quiet)) {
                $s[$column] = $quiet[$key];
            }
        }
        if (array_key_exists('utcOffset', $input)) {
            $s['utc_offset'] = (int) $input['utcOffset'];
        }
        $muted = collect($s['muted']);
        foreach ($input['categories'] ?? [] as $category => $on) {
            $muted = $on ? $muted->reject(fn ($m) => $m === $category) : $muted->push($category);
        }
        $s['muted'] = $muted->unique()->values()->all();
        DB::table('notification_settings')->updateOrInsert(['user_id' => $userId], [
            'push' => $s['push'],
            'quiet_enabled' => (bool) $s['quiet_enabled'],
            'quiet_start' => $s['quiet_start'],
            'quiet_end' => $s['quiet_end'],
            'utc_offset' => $s['utc_offset'],
            'muted' => json_encode($s['muted']),
            'updated_at' => now(),
            'created_at' => now(),
        ]);

        return $this->settings($userId);
    }

    // ---- devices -------------------------------------------------------------

    /** Upserts by token: a token moves to the account signed in last. */
    public function registerDevice(User $user, string $platform, string $token, ?string $locale, ?int $utcOffset): void
    {
        $hash = hash('sha256', $token);
        $existing = DB::table('device_tokens')->where('token_hash', $hash)->first();
        $fields = ['user_id' => $user->id, 'platform' => $platform, 'token' => $token, 'locale' => $locale, 'updated_at' => now()];
        if ($existing === null) {
            DB::table('device_tokens')->insert([...$fields, 'token_hash' => $hash, 'created_at' => now()]);
        } else {
            DB::table('device_tokens')->where('id', $existing->id)->update($fields);
        }
        if ($utcOffset !== null) {
            $this->updateSettings($user->id, ['utcOffset' => $utcOffset]);
        }
    }

    public function unregisterDevice(User $user, string $token): bool
    {
        return DB::table('device_tokens')->where(['user_id' => $user->id, 'token_hash' => hash('sha256', $token)])->delete() > 0;
    }

    // ---- inbox (16.2) --------------------------------------------------------

    /** @return array<int, int> players blocked by [userId] or blocking them */
    private function blockedIds(int $userId): array
    {
        return DB::table('blocks')->where('blocker_id', $userId)->pluck('blocked_id')
            ->merge(DB::table('blocks')->where('blocked_id', $userId)->pluck('blocker_id'))
            ->map(fn ($id) => (int) $id)->unique()->values()->all();
    }

    /** @return Builder */
    private function visible(int $userId)
    {
        $blocked = $this->blockedIds($userId);

        return DB::table('notifications')->where('user_id', $userId)
            ->when($blocked !== [], fn ($q) => $q->where(fn ($q) => $q->whereNull('from_user_id')->orWhereNotIn('from_user_id', $blocked)));
    }

    /**
     * The newest [limit] rows, or only those after id [after] (polling).
     *
     * @return array<int, array<string, mixed>>
     */
    public function inbox(User $user, ?int $after, int $limit = 50): array
    {
        $rows = $this->visible($user->id)
            ->when($after !== null, fn ($q) => $q->where('id', '>', $after))
            ->orderByDesc('id')->limit($limit)->get();

        return $this->present($rows);
    }

    /**
     * Notification objects (docs/api/notifications.md) for rows, in order.
     *
     * @param  Collection<int, \stdClass>  $rows
     * @return array<int, array<string, mixed>>
     */
    public function present(Collection $rows): array
    {
        $users = User::query()->whereIn('id', $rows->pluck('from_user_id')->filter()->unique())->get()->keyBy('id');

        return $rows->map(function (\stdClass $r) use ($users): array {
            $from = $r->from_user_id === null ? null : $users->get((int) $r->from_user_id);
            $data = json_decode((string) $r->data, true);

            return [
                'id' => (int) $r->id,
                'type' => (string) $r->type,
                'category' => self::category((string) $r->type),
                'data' => is_array($data) && $data !== [] ? $data : new \stdClass,
                'from' => $from === null ? null : [
                    'id' => (string) $from->id,
                    'name' => $from->name,
                    'avatar' => $from->avatar,
                    'country' => $from->country,
                ],
                'read' => $r->read_at !== null,
                'createdAt' => Carbon::parse((string) $r->created_at)->toIso8601String(),
            ];
        })->values()->all();
    }

    public function unread(User $user): int
    {
        return $this->visible($user->id)->whereNull('read_at')->count();
    }

    /** @param array<int, int>|null $ids null = all */
    public function markRead(User $user, ?array $ids): void
    {
        DB::table('notifications')->where('user_id', $user->id)->whereNull('read_at')
            ->when($ids !== null, fn ($q) => $q->whereIn('id', $ids))
            ->update(['read_at' => now()]);
    }

    public function delete(User $user, int $id): bool
    {
        return DB::table('notifications')->where(['user_id' => $user->id, 'id' => $id])->delete() > 0;
    }

    public function prune(Carbon $now): int
    {
        return DB::table('notifications')->where('created_at', '<', $now->copy()->subDays((int) config('push.retention_days')))->delete();
    }

    // ---- push copy -------------------------------------------------------------

    /**
     * Localized push title and body for a row (lang/{locale}/notifications.php).
     *
     * @return array{0: string, 1: string}
     */
    public function copy(\stdClass $row, string $locale): array
    {
        $data = json_decode((string) $row->data, true);
        $data = is_array($data) ? $data : [];
        $from = $row->from_user_id === null ? null : User::query()->find((int) $row->from_user_id);
        $tournament = $data['tournament'] ?? null;
        $text = fn (string $key): string => is_scalar($data[$key] ?? null) ? (string) $data[$key] : '';
        $replace = [
            'name' => $from === null ? '' : $from->name,
            'tournament' => is_array($tournament) ? (string) ($tournament[$locale] ?? $tournament['en'] ?? reset($tournament)) : '',
            'variant' => __('notifications.variants.'.$text('variant'), [], $locale),
            'tier' => __('notifications.tiers.'.$text('tier'), [], $locale),
            // Challenges from before ADR-044 rooms were rapid.
            'time' => __('notifications.times.'.($text('timeControl') ?: 'rapid'), [], $locale),
        ];
        foreach (['points' => 'matchLength', 'clan' => 'clan', 'tag' => 'tag', 'opponent' => 'opponent', 'round' => 'round',
            'place' => 'place', 'season' => 'season', 'level' => 'level', 'minutes' => 'minutes', 'reason' => 'reason',
            'rank' => 'rank', 'coins' => 'coins', 'refund' => 'refund'] as $placeholder => $key) {
            $replace[$placeholder] = $text($key);
        }
        $type = (string) $row->type;
        // A cancelled paid tournament says how many coins came back.
        $body = $type === 'tournament_cancelled' && (int) $text('refund') > 0 ? 'body_refund' : 'body';

        return [
            __("notifications.$type.title", $replace, $locale),
            __("notifications.$type.$body", $replace, $locale),
        ];
    }
}
