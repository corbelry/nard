<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Carbon;

/**
 * Clan chat row: a member's text or a system event the client localizes.
 *
 * @property int $id
 * @property int $clan_id
 * @property int|null $user_id
 * @property string $kind
 * @property string|null $body
 * @property string|null $event
 * @property array<string, mixed>|null $data
 * @property int|null $deleted_by
 * @property Carbon $created_at
 * @property-read User|null $user
 */
class ClanMessage extends Model
{
    use SoftDeletes;

    protected $guarded = [];

    /** @return array<string, string> */
    protected function casts(): array
    {
        return ['data' => 'array'];
    }

    /** @return BelongsTo<User, $this> */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /** @return array<string, mixed> */
    public function toApi(): array
    {
        return [
            'id' => $this->id,
            'kind' => $this->kind,
            'author' => $this->user === null ? null : [
                'id' => (string) $this->user->id,
                'name' => $this->user->name,
                'avatar' => $this->user->avatar,
            ],
            'text' => $this->body,
            'event' => $this->event,
            'data' => $this->data,
            'createdAt' => $this->created_at->toIso8601String(),
        ];
    }
}
