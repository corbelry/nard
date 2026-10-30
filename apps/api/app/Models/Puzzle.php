<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * A practice puzzle, "find the best move" (spec §8.8, design 13.x). Boards
 * are `{white: {point: count}, black: {point: count}}`, each side in its own
 * numbering (1..24, 25 = bar, borne-off checkers omitted), as
 * `BoardState.fromPoints` in nard_core.
 *
 * @property string $id
 * @property string $variant
 * @property string $side
 * @property array<int, int> $dice
 * @property array{white: array<string, int>, black: array<string, int>} $board
 * @property string $solution
 * @property array{white: array<string, int>, black: array<string, int>} $result_board
 * @property array{moves: string, loss: float}|null $second_best
 * @property int $rating
 * @property string $phase
 * @property bool $enabled disabled puzzles are no longer served (admin)
 */
class Puzzle extends Model
{
    public $incrementing = false;

    protected $keyType = 'string';

    protected $guarded = [];

    /** @return array<string, string> */
    protected function casts(): array
    {
        return [
            'dice' => 'array',
            'board' => 'array',
            'result_board' => 'array',
            'second_best' => 'array',
            'enabled' => 'boolean',
        ];
    }

    public function difficulty(): string
    {
        return $this->rating < 1400 ? 'easy' : ($this->rating < 1600 ? 'medium' : 'hard');
    }

    /**
     * The position to solve; the solution is never sent before the puzzle
     * is finished.
     *
     * @return array<string, mixed>
     */
    public function toApi(): array
    {
        return [
            'id' => $this->id,
            'variant' => $this->variant,
            'phase' => $this->phase,
            'difficulty' => $this->difficulty(),
            'rating' => $this->rating,
            'side' => $this->side,
            'dice' => $this->dice,
            'board' => self::boardJson($this->board),
        ];
    }

    /**
     * Keeps an empty side an object in JSON.
     *
     * @param  array<string, array<string, int>>  $board
     * @return array<string, mixed>
     */
    public static function boardJson(array $board): array
    {
        return array_map(fn ($side) => $side === [] ? (object) [] : $side, $board);
    }
}
