<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * @property int $id
 * @property int $user_id
 * @property string $variant
 * @property int $rating
 * @property int $peak
 * @property int $experience
 * @property int $matches
 * @property int $wins
 */
#[Fillable(['variant', 'rating', 'peak', 'experience', 'matches', 'wins'])]
class Rating extends Model
{
    /** Visible tiers (spec §8.2): lower bound => tier. */
    public const TIERS = [
        0 => 'bronze',
        1300 => 'silver',
        1500 => 'gold',
        1700 => 'platinum',
        1900 => 'diamond',
        2100 => 'master',
        2300 => 'grandmaster',
    ];

    public static function tier(int $rating): string
    {
        $tier = 'bronze';
        foreach (self::TIERS as $min => $name) {
            if ($rating >= $min) {
                $tier = $name;
            }
        }

        return $tier;
    }

    /** @return BelongsTo<User, $this> */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
