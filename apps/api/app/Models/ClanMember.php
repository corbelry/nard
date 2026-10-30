<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * @property int $id
 * @property int $clan_id
 * @property int $user_id
 * @property string $role
 * @property Carbon $joined_at
 * @property int $donated_coins
 * @property string|null $donated_week
 * @property-read Clan $clan
 * @property-read User $user
 */
class ClanMember extends Model
{
    protected $guarded = [];

    protected $attributes = ['donated_coins' => 0];

    /** @return array<string, string> */
    protected function casts(): array
    {
        return ['joined_at' => 'datetime', 'donated_coins' => 'integer'];
    }

    /** 3 = leader … 0 = member. */
    public static function rank(string $role): int
    {
        /** @var array<int, string> $roles */
        $roles = config('clans.roles');
        $index = array_search($role, $roles, true);

        return $index === false ? -1 : count($roles) - 1 - $index;
    }

    public function rankValue(): int
    {
        return self::rank($this->role);
    }

    public function donatedThisWeek(): int
    {
        return $this->donated_week === Clan::week() ? $this->donated_coins : 0;
    }

    /** @return BelongsTo<Clan, $this> */
    public function clan(): BelongsTo
    {
        return $this->belongsTo(Clan::class);
    }

    /** @return BelongsTo<User, $this> */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
