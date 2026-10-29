<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Carbon;

/**
 * A finished online match (MatchResult from the game server).
 *
 * @property string $id
 * @property string $variant
 * @property int $match_length
 * @property string $mode
 * @property int|null $white_user_id
 * @property int|null $black_user_id
 * @property string $white_name
 * @property string $black_name
 * @property bool $white_bot
 * @property bool $black_bot
 * @property string $winner
 * @property int $white_score
 * @property int $black_score
 * @property string $reason
 * @property int|null $white_rating_before
 * @property int|null $white_rating_after
 * @property int|null $black_rating_before
 * @property int|null $black_rating_after
 * @property array<int, array<string, mixed>> $games
 * @property Carbon $started_at
 * @property Carbon $ended_at
 */
class GameMatch extends Model
{
    public $incrementing = false;

    protected $keyType = 'string';

    protected $guarded = [];

    /** @return array<string, string> */
    protected function casts(): array
    {
        return [
            'white_bot' => 'boolean',
            'black_bot' => 'boolean',
            'games' => 'array',
            'started_at' => 'datetime',
            'ended_at' => 'datetime',
        ];
    }

    /** @return array<string, mixed> */
    public function summary(?int $forUserId = null, bool $withGames = false): array
    {
        $data = [
            'id' => $this->id,
            'variant' => $this->variant,
            'matchLength' => $this->match_length,
            'mode' => $this->mode,
            'white' => ['name' => $this->white_name, 'bot' => $this->white_bot, 'ratingBefore' => $this->white_rating_before, 'ratingAfter' => $this->white_rating_after],
            'black' => ['name' => $this->black_name, 'bot' => $this->black_bot, 'ratingBefore' => $this->black_rating_before, 'ratingAfter' => $this->black_rating_after],
            'winner' => $this->winner,
            'whiteScore' => $this->white_score,
            'blackScore' => $this->black_score,
            'reason' => $this->reason,
            'endedAt' => $this->ended_at->toIso8601String(),
        ];
        if ($forUserId !== null) {
            $data['you'] = $this->white_user_id === $forUserId ? 'white' : 'black';
        }
        if ($withGames) {
            $data['games'] = $this->games;
        }

        return $data;
    }
}
