<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * One match of a round. A bye has one player (white) and is finished at
 * once; an empty knockout slot has none.
 *
 * @property int $id
 * @property int $tournament_id
 * @property int $round
 * @property int $slot
 * @property string $match_id
 * @property int|null $white_user_id
 * @property int|null $black_user_id
 * @property string $status
 * @property string|null $result
 * @property int|null $winner_user_id
 * @property bool $walkover
 * @property bool $bye
 * @property int|null $white_score
 * @property int|null $black_score
 * @property Carbon|null $pushed_at
 * @property Carbon|null $finished_at
 * @property-read Tournament $tournament
 * @property-read User|null $white
 * @property-read User|null $black
 */
class TournamentPairing extends Model
{
    protected $guarded = [];

    protected $attributes = [
        'walkover' => false,
        'bye' => false,
    ];

    /** @return array<string, string> */
    protected function casts(): array
    {
        return [
            'tournament_id' => 'integer',
            'round' => 'integer',
            'slot' => 'integer',
            'white_user_id' => 'integer',
            'black_user_id' => 'integer',
            'winner_user_id' => 'integer',
            'walkover' => 'boolean',
            'bye' => 'boolean',
            'pushed_at' => 'datetime',
            'finished_at' => 'datetime',
        ];
    }

    /** @return BelongsTo<Tournament, $this> */
    public function tournament(): BelongsTo
    {
        return $this->belongsTo(Tournament::class);
    }

    /** @return BelongsTo<User, $this> */
    public function white(): BelongsTo
    {
        return $this->belongsTo(User::class, 'white_user_id');
    }

    /** @return BelongsTo<User, $this> */
    public function black(): BelongsTo
    {
        return $this->belongsTo(User::class, 'black_user_id');
    }

    public function involves(int $userId): bool
    {
        return $this->white_user_id === $userId || $this->black_user_id === $userId;
    }
}
