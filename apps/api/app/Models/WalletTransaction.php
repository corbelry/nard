<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * Read-only view of the append-only ledger; writes go through WalletService.
 *
 * @property int $id
 * @property int $user_id
 * @property string $currency
 * @property int $amount
 * @property int $balance_after
 * @property string $reason
 * @property string|null $reference
 * @property string $idempotency_key
 * @property Carbon|null $created_at
 * @property-read User $user
 */
class WalletTransaction extends Model
{
    public const UPDATED_AT = null;

    protected $guarded = ['*'];

    /** @return BelongsTo<User, $this> */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
