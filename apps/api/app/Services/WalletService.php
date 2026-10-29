<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;

/**
 * The only way to change balances (spec §9): every change is an
 * append-only ledger row written in the same DB transaction as the cached
 * balance, keyed by an idempotency key so retries never double-apply.
 */
class WalletService
{
    /** @return array{coins: int, gems: int} */
    public function balances(User $user): array
    {
        $row = DB::table('wallets')->where('user_id', $user->id)->first();

        return ['coins' => (int) ($row->coins ?? 0), 'gems' => (int) ($row->gems ?? 0)];
    }

    public function credit(User $user, string $currency, int $amount, string $reason, string $key, ?string $reference = null): int
    {
        /** @var array<int, string> $allowed */
        $allowed = config("economy.credit_reasons.$currency", []);
        if (! in_array($reason, $allowed, true)) {
            // e.g. coins for money (ADR-022).
            throw new InvalidArgumentException("$reason may not credit $currency");
        }

        return $this->apply($user, $currency, $amount, $reason, $key, $reference);
    }

    public function debit(User $user, string $currency, int $amount, string $reason, string $key, ?string $reference = null): int
    {
        return $this->apply($user, $currency, -$amount, $reason, $key, $reference);
    }

    /** Applies a signed change; returns the new balance. */
    private function apply(User $user, string $currency, int $amount, string $reason, string $key, ?string $reference): int
    {
        if (! in_array($currency, ['coins', 'gems'], true) || $amount === 0) {
            throw new InvalidArgumentException('Bad currency or amount');
        }

        return DB::transaction(function () use ($user, $currency, $amount, $reason, $key, $reference): int {
            $done = DB::table('wallet_transactions')->where('idempotency_key', $key)->first();
            if ($done !== null) {
                return (int) $done->balance_after;
            }
            DB::table('wallets')->insertOrIgnore(['user_id' => $user->id, 'created_at' => now(), 'updated_at' => now()]);
            $wallet = DB::table('wallets')->where('user_id', $user->id)->lockForUpdate()->first();
            $balance = (int) ($wallet->{$currency} ?? 0) + $amount;
            if ($balance < 0) {
                throw new InsufficientFunds("Not enough $currency");
            }
            DB::table('wallets')->where('user_id', $user->id)->update([$currency => $balance, 'updated_at' => now()]);
            DB::table('wallet_transactions')->insert([
                'user_id' => $user->id,
                'currency' => $currency,
                'amount' => $amount,
                'balance_after' => $balance,
                'reason' => $reason,
                'reference' => $reference,
                'idempotency_key' => $key,
                'created_at' => now(),
            ]);

            return $balance;
        });
    }
}
