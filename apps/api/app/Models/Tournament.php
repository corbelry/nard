<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Carbon;

/**
 * A tournament (spec §8.3): knockout, Swiss or round-robin; scheduled,
 * sit-and-go or private. Matches are always unrated (QUESTIONS #33).
 *
 * @property int $id
 * @property array<string, string> $name
 * @property string $format
 * @property string $kind
 * @property string $variant
 * @property int $match_length
 * @property int $size
 * @property int $min_players
 * @property int $entry_coins
 * @property int|null $min_rating
 * @property array<int, array{from: int, to: int, coins: int, items: array<int, string>}> $prizes
 * @property int $prize_fund
 * @property int|null $swiss_rounds
 * @property int|null $total_rounds
 * @property int $current_round
 * @property string $status
 * @property Carbon|null $starts_at
 * @property Carbon|null $expires_at
 * @property bool $is_private
 * @property string|null $invite_code
 * @property int|null $created_by
 * @property string|null $schedule_key
 * @property Carbon|null $started_at
 * @property Carbon|null $finished_at
 * @property string|null $cancel_reason
 * @property Carbon|null $created_at
 * @property int|null $entries_count
 */
class Tournament extends Model
{
    protected $guarded = [];

    protected $attributes = [
        'entry_coins' => 0,
        'prize_fund' => 0,
        'current_round' => 0,
        'is_private' => false,
    ];

    /** @return array<string, string> */
    protected function casts(): array
    {
        return [
            'name' => 'array',
            'prizes' => 'array',
            'is_private' => 'boolean',
            'created_by' => 'integer',
            'starts_at' => 'datetime',
            'expires_at' => 'datetime',
            'started_at' => 'datetime',
            'finished_at' => 'datetime',
        ];
    }

    /** @return HasMany<TournamentEntry, $this> */
    public function entries(): HasMany
    {
        return $this->hasMany(TournamentEntry::class);
    }

    /** @return HasMany<TournamentPairing, $this> */
    public function pairings(): HasMany
    {
        return $this->hasMany(TournamentPairing::class);
    }
}
