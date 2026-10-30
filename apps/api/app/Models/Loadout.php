<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

/**
 * @property int $id
 * @property int $user_id
 * @property string $name
 * @property array<string, string> $slots
 * @property bool $active
 */
#[Fillable(['name', 'slots', 'active'])]
class Loadout extends Model
{
    /** @return array<string, string> */
    protected function casts(): array
    {
        return ['slots' => 'array', 'active' => 'boolean'];
    }

    /** @return array<string, mixed> */
    public function toApi(): array
    {
        return ['id' => $this->id, 'name' => $this->name, 'slots' => (object) $this->slots, 'active' => $this->active];
    }
}
