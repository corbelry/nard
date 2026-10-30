<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Carbon;

/**
 * A weekly war between two clans (5.6).
 *
 * @property int $id
 * @property string $week
 * @property int|null $clan_a_id
 * @property int|null $clan_b_id
 * @property int $score_a
 * @property int $score_b
 * @property int $matches_counted
 * @property string $status
 * @property int|null $winner_clan_id
 * @property Carbon $starts_at
 * @property Carbon $ends_at
 */
class ClanWar extends Model
{
    protected $guarded = [];

    protected $attributes = ['score_a' => 0, 'score_b' => 0, 'matches_counted' => 0];

    /** @return array<string, string> */
    protected function casts(): array
    {
        return [
            'starts_at' => 'datetime',
            'ends_at' => 'datetime',
            'score_a' => 'integer',
            'score_b' => 'integer',
            'matches_counted' => 'integer',
        ];
    }
}
