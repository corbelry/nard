<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * A fair-play signal for review (spec §8.14, `anticheat:scan`).
 *
 * @property int $id
 * @property int $user_id
 * @property string $kind engine|multi_account|abandonment|reports
 * @property float $score
 * @property array<string, mixed> $details
 * @property string $status open|reviewed|dismissed|actioned
 * @property int|null $reviewed_by
 * @property Carbon|null $reviewed_at
 * @property string|null $review_note
 * @property Carbon|null $created_at
 * @property-read User $user
 */
class CheatFlag extends Model
{
    public const KINDS = ['engine', 'multi_account', 'abandonment', 'reports'];

    public const STATUSES = ['open', 'reviewed', 'dismissed', 'actioned'];

    protected $guarded = [];

    /** @return array<string, string> */
    protected function casts(): array
    {
        return [
            'score' => 'float',
            'details' => 'array',
            'reviewed_at' => 'datetime',
        ];
    }

    /** @return BelongsTo<User, $this> */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /** @return BelongsTo<User, $this> */
    public function reviewer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reviewed_by');
    }
}
