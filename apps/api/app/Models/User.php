<?php

namespace App\Models;

use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

/**
 * @property int $id
 * @property string $name
 * @property string|null $email
 * @property string|null $device_id
 * @property string|null $country
 * @property string|null $avatar
 * @property string $locale
 * @property bool $is_guest
 * @property int $xp
 * @property int $level
 * @property int $login_streak
 * @property int $best_streak
 * @property string|null $last_checkin
 * @property string|null $title_item_id
 * @property int $wins_total
 * @property int $mars_total
 * @property int $ranked_wins_total
 */
#[Fillable(['name', 'email', 'password', 'device_id', 'country', 'avatar', 'locale', 'is_guest'])]
#[Hidden(['password', 'remember_token', 'device_id', 'apple_sub', 'google_sub'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    /** Mirrors the column defaults so new models read them before a refresh. */
    protected $attributes = [
        'locale' => 'az',
        'is_guest' => true,
        'xp' => 0,
        'level' => 1,
        'login_streak' => 0,
        'best_streak' => 0,
        'wins_total' => 0,
        'mars_total' => 0,
        'ranked_wins_total' => 0,
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'is_guest' => 'boolean',
        ];
    }

    /** @return HasMany<Rating, $this> */
    public function ratings(): HasMany
    {
        return $this->hasMany(Rating::class);
    }

    /** The rating row for [variant], created at the initial rating. */
    public function ratingFor(string $variant): Rating
    {
        return $this->ratings()->firstOrCreate(
            ['variant' => $variant],
            [
                'rating' => config('nard.rating.initial'),
                'peak' => config('nard.rating.initial'),
                'experience' => 0,
                'matches' => 0,
                'wins' => 0,
            ],
        );
    }

    /** @return array<string, mixed> */
    public function profile(): array
    {
        return [
            'id' => (string) $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'country' => $this->country,
            'avatar' => $this->avatar,
            'locale' => $this->locale,
            'guest' => $this->is_guest,
            'ratings' => $this->ratings()->get()->mapWithKeys(fn (Rating $r) => [
                $r->variant => [
                    'rating' => $r->rating,
                    'peak' => $r->peak,
                    'matches' => $r->matches,
                    'wins' => $r->wins,
                    'tier' => Rating::tier($r->rating),
                ],
            ])->all(),
        ];
    }
}
