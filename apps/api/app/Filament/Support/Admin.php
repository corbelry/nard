<?php

namespace App\Filament\Support;

use App\Models\User;
use Illuminate\Support\Facades\Auth;

/** The signed-in panel admin (web guard). */
final class Admin
{
    public static function user(): ?User
    {
        $user = Auth::guard('web')->user();

        return $user instanceof User ? $user : null;
    }
}
