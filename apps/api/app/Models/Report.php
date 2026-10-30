<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * A player report (14.2), handled in the admin queue.
 *
 * @property int $id
 * @property int|null $reporter_id
 * @property int $reported_id
 * @property string $reason
 * @property string|null $match_id
 * @property string|null $note
 * @property string $status open|reviewed|actioned
 * @property string|null $action dismiss|warn|mute|ban
 * @property int|null $handled_by
 * @property Carbon|null $handled_at
 * @property Carbon|null $created_at
 * @property-read User|null $reporter
 * @property-read User $reported
 */
class Report extends Model
{
    public const STATUSES = ['open', 'reviewed', 'actioned'];

    protected $guarded = [];

    /** @return array<string, string> */
    protected function casts(): array
    {
        return ['handled_at' => 'datetime'];
    }

    /** @return BelongsTo<User, $this> */
    public function reporter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reporter_id');
    }

    /** @return BelongsTo<User, $this> */
    public function reported(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reported_id');
    }

    /** @return BelongsTo<User, $this> */
    public function handler(): BelongsTo
    {
        return $this->belongsTo(User::class, 'handled_by');
    }
}
