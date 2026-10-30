<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;

/** Runtime settings edited in the admin panel; config holds the defaults. */
class Settings
{
    public function get(string $key, mixed $default = null): mixed
    {
        $value = DB::table('app_settings')->where('key', $key)->value('value');

        return $value === null ? $default : json_decode((string) $value, true);
    }

    public function put(string $key, mixed $value): void
    {
        DB::table('app_settings')->updateOrInsert(
            ['key' => $key],
            ['value' => json_encode($value), 'updated_at' => now(), 'created_at' => now()],
        );
    }

    /**
     * The featured store offer (7.3): admin override, else config.
     *
     * @return array{item: string, oldPrice: array<string, int>|null}|null
     */
    public function featuredOffer(): ?array
    {
        $value = $this->get('featured', config('economy.featured'));
        if (! is_array($value) || ! isset($value['item']) || ! is_string($value['item']) || $value['item'] === '') {
            return null;
        }
        $old = $value['oldPrice'] ?? null;

        return ['item' => $value['item'], 'oldPrice' => is_array($old) && $old !== [] ? array_map('intval', $old) : null];
    }
}
