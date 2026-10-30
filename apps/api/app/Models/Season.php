<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Carbon;

/**
 * A ranked season (spec §8.2, ADR-039). `rules` is the pass and season-end
 * reward tables copied from config/seasons.php when the season started.
 *
 * @property int $id
 * @property int $number
 * @property array<string, string> $name
 * @property Carbon $starts_at
 * @property Carbon $ends_at
 * @property string $status active|finished
 * @property array{pass: array{levels: int, xp_per_level: int, premium_gems: int, free: array<int|string, array<string, mixed>>, premium: array<int|string, array<string, mixed>>}, end_rewards: array<string, array{coins: int, item: string|null}>} $rules
 * @property Carbon|null $finished_at
 */
class Season extends Model
{
    protected $guarded = [];

    /** @return array<string, string> */
    protected function casts(): array
    {
        return [
            'name' => 'array',
            'rules' => 'array',
            'starts_at' => 'datetime',
            'ends_at' => 'datetime',
            'finished_at' => 'datetime',
        ];
    }

    /** @return array<string, mixed> */
    public function toApi(?Carbon $now = null): array
    {
        $now ??= now();

        return [
            'id' => $this->id,
            'number' => $this->number,
            'name' => $this->name,
            'status' => $this->status,
            'startsAt' => $this->starts_at->toIso8601String(),
            'endsAt' => $this->ends_at->toIso8601String(),
            'secondsLeft' => max(0, (int) $now->diffInSeconds($this->ends_at, false)),
        ];
    }
}
