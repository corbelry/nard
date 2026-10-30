<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Carbon;

/**
 * A clan (spec §8.4).
 *
 * @property int $id
 * @property string $name
 * @property string $name_key
 * @property string $tag
 * @property array{shape: string, symbol: string, color: string, pattern: string} $emblem
 * @property string|null $description
 * @property string $language
 * @property int|null $min_rating
 * @property string $join_policy
 * @property int $xp
 * @property int $level
 * @property int $chest_coins
 * @property string|null $chest_week
 * @property int|null $created_by
 * @property Carbon|null $created_at
 * @property int|null $members_count
 */
class Clan extends Model
{
    protected $guarded = [];

    protected $attributes = ['xp' => 0, 'level' => 1, 'chest_coins' => 0];

    /** @return array<string, string> */
    protected function casts(): array
    {
        return ['emblem' => 'array', 'xp' => 'integer', 'level' => 'integer', 'chest_coins' => 'integer', 'min_rating' => 'integer'];
    }

    /** @return HasMany<ClanMember, $this> */
    public function members(): HasMany
    {
        return $this->hasMany(ClanMember::class);
    }

    /** Case-folded name for uniqueness ("İ", "I", "ı" and "i" fold alike). */
    public static function nameKey(string $name): string
    {
        return str_replace(["i\u{307}", 'ı'], 'i', mb_strtolower($name));
    }

    /** Monday–Sunday UTC week key, e.g. "2026-W45". */
    public static function week(?Carbon $at = null): string
    {
        return ($at ?? now())->copy()->utc()->format('o-\WW');
    }

    /** Coins in this week's chest. */
    public function chestThisWeek(): int
    {
        return $this->chest_week === self::week() ? $this->chest_coins : 0;
    }

    /** Level reached with [xp] (config/clans.php levels). */
    public static function levelFor(int $xp): int
    {
        /** @var array<int, int> $levels */
        $levels = config('clans.levels');
        $level = 0;
        foreach ($levels as $threshold) {
            if ($xp >= $threshold) {
                $level++;
            }
        }

        return max(1, $level);
    }

    /** Total XP needed for the next level, or null at the top. */
    public static function xpForNext(int $level): ?int
    {
        /** @var array<int, int> $levels */
        $levels = config('clans.levels');

        return $levels[$level] ?? null;
    }

    /**
     * Small reference shown on player cards.
     *
     * @return array<string, mixed>
     */
    public function badge(): array
    {
        return ['id' => (string) $this->id, 'tag' => $this->tag, 'emblem' => $this->emblem];
    }

    /** @return array<string, mixed> */
    public function summary(?int $rating = null): array
    {
        return [
            'id' => (string) $this->id,
            'name' => $this->name,
            'tag' => $this->tag,
            'emblem' => $this->emblem,
            'level' => $this->level,
            'xp' => $this->xp,
            'memberCount' => $this->members_count ?? $this->members()->count(),
            'maxMembers' => (int) config('clans.max_members'),
            'rating' => $rating,
            'language' => $this->language,
            'joinPolicy' => $this->join_policy,
            'minRating' => $this->min_rating,
        ];
    }
}
