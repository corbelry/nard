<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * Audit log row: one admin write (spec §8.13).
 *
 * @property int $id
 * @property int|null $admin_id
 * @property string $action
 * @property string|null $subject e.g. "user:12"
 * @property string|null $note
 * @property array<string, mixed>|null $data
 * @property Carbon|null $created_at
 * @property-read User|null $admin
 */
class AdminAction extends Model
{
    public const UPDATED_AT = null;

    protected $guarded = [];

    /** @return array<string, string> */
    protected function casts(): array
    {
        return ['data' => 'array'];
    }

    /** @return BelongsTo<User, $this> */
    public function admin(): BelongsTo
    {
        return $this->belongsTo(User::class, 'admin_id');
    }
}
