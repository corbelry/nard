<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

/**
 * Promotes (or creates) an admin for the Filament panel at /admin. The
 * panel uses its own e-mail + password session login, separate from the
 * mobile bearer tokens (ADR-042).
 */
class AdminCreate extends Command
{
    protected $signature = 'admin:create
        {email : Admin e-mail (an existing account is promoted)}
        {--password= : Panel password (generated and printed when omitted)}
        {--name=Admin : Nickname for a new account}';

    protected $description = 'Create or promote a Filament admin user';

    public function handle(): int
    {
        $email = mb_strtolower((string) $this->argument('email'));
        if (Validator::make(['email' => $email], ['email' => 'required|email:rfc|max:255'])->fails()) {
            $this->error('Invalid e-mail address.');

            return self::FAILURE;
        }
        $password = $this->option('password');
        $generated = ! is_string($password) || $password === '';
        $password = $generated ? Str::password(20) : (string) $password;
        if (strlen($password) < 12) {
            $this->error('The password needs at least 12 characters.');

            return self::FAILURE;
        }
        $user = User::query()->firstWhere('email', $email);
        $created = $user === null;
        $user ??= new User(['name' => (string) $this->option('name'), 'email' => $email, 'is_guest' => false]);
        $user->forceFill([
            'is_admin' => true,
            'password' => $password,
            'email_verified_at' => $user->email_verified_at ?? now(),
        ])->save();
        $this->info(($created ? 'Created' : 'Promoted')." admin {$email} (user {$user->id}). Log in at /admin.");
        if ($generated) {
            $this->line("Password: $password");
        }

        return self::SUCCESS;
    }
}
