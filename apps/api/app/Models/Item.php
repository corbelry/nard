<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * A cosmetic (spec §8.6).
 *
 * @property string $id
 * @property string $category
 * @property string $rarity
 * @property int|null $price_coins
 * @property int|null $price_gems
 * @property bool $is_default
 * @property bool $available
 * @property array<string, mixed> $data
 * @property string|null $asset_url
 * @property int $asset_version
 * @property int $sort
 */
class Item extends Model
{
    public $incrementing = false;

    protected $keyType = 'string';

    protected $guarded = [];

    /** @return array<string, string> */
    protected function casts(): array
    {
        return [
            'is_default' => 'boolean',
            'available' => 'boolean',
            'data' => 'array',
        ];
    }

    /** @return array<string, mixed> */
    public function toApi(): array
    {
        return [
            'id' => $this->id,
            'category' => $this->category,
            'rarity' => $this->rarity,
            'price' => array_filter(['coins' => $this->price_coins, 'gems' => $this->price_gems], fn ($v) => $v !== null),
            'default' => $this->is_default,
            'data' => $this->data,
            'asset' => $this->asset_url === null ? null : ['url' => $this->asset_url, 'version' => $this->asset_version],
        ];
    }
}
