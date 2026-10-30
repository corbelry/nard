<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Carbon;

/**
 * @property int $id
 * @property string $email
 * @property string $code_hash
 * @property string $purpose sign_in | deletion
 * @property int $attempts
 * @property Carbon $expires_at
 */
#[Fillable(['email', 'purpose', 'code_hash', 'attempts', 'expires_at'])]
class LoginCode extends Model
{
    /** @return array<string, string> */
    protected function casts(): array
    {
        return ['expires_at' => 'datetime'];
    }
}
