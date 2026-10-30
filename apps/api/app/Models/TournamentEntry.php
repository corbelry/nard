<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * A registration (and later the standing) of one player.
 *
 * @property int $id
 * @property int $tournament_id
 * @property int $user_id
 * @property int $rating
 * @property int|null $seed
 * @property int $entry_coins
 * @property string|null $entry_key
 * @property int $points
 * @property int $wins
 * @property int $losses
 * @property int $buchholz
 * @property bool $had_bye
 * @property int|null $eliminated_round
 * @property int|null $place
 * @property bool $refunded
 * @property-read User $user
 */
class TournamentEntry extends Model
{
    protected $guarded = [];

    protected $attributes = [
        'entry_coins' => 0,
        'points' => 0,
        'wins' => 0,
        'losses' => 0,
        'buchholz' => 0,
        'had_bye' => false,
        'refunded' => false,
    ];

    /** @return array<string, string> */
    protected function casts(): array
    {
        return [
            'tournament_id' => 'integer',
            'user_id' => 'integer',
            'eliminated_round' => 'integer',
            'place' => 'integer',
            'had_bye' => 'boolean',
            'refunded' => 'boolean',
        ];
    }

    /** @return BelongsTo<User, $this> */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
