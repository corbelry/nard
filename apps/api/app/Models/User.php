<?php

namespace App\Models;

use App\Services\ClanService;
use Database\Factories\UserFactory;
use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Carbon;
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
 * @property int $games_total
 * @property Carbon|null $deletion_requested_at
 * @property string|null $friend_code
 * @property Carbon|null $last_seen_at
 * @property int $puzzle_rating
 * @property bool $is_admin
 * @property Carbon|null $banned_at
 * @property Carbon|null $banned_until
 * @property string|null $ban_reason
 * @property Carbon|null $muted_until
 * @property Carbon|null $queue_cooldown_until
 * @property string|null $last_ip
 * @property Carbon|null $last_login_at
 * @property Carbon|null $created_at
 * @property-read ClanMember|null $clanMembership
 */
#[Fillable(['name', 'email', 'password', 'device_id', 'country', 'avatar', 'locale', 'is_guest'])]
#[Hidden(['password', 'remember_token', 'device_id', 'apple_sub', 'google_sub', 'last_ip', 'ban_reason'])]
class User extends Authenticatable implements FilamentUser
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
        'games_total' => 0,
        'puzzle_rating' => 1500,
        'is_admin' => false,
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
            'last_seen_at' => 'datetime',
            'deletion_requested_at' => 'datetime',
            'is_admin' => 'boolean',
            'banned_at' => 'datetime',
            'banned_until' => 'datetime',
            'muted_until' => 'datetime',
            'queue_cooldown_until' => 'datetime',
            'last_login_at' => 'datetime',
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (User $user): void {
            $user->friend_code ??= self::newFriendCode();
        });
        // A leader's clan gets a new leader (or is disbanded) first.
        static::deleting(function (User $user): void {
            app(ClanService::class)->onUserDeleted($user);
            // Opponents' history keeps the match but not the name (QUESTIONS #44).
            GameMatch::query()->where('white_user_id', $user->id)->update(['white_name' => GameMatch::DELETED_NAME]);
            GameMatch::query()->where('black_user_id', $user->id)->update(['black_name' => GameMatch::DELETED_NAME]);
        });
    }

    /** 8 characters without look-alikes (0/O, 1/I/L). */
    public static function newFriendCode(): string
    {
        $alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
        do {
            $code = '';
            for ($i = 0; $i < 8; $i++) {
                $code .= $alphabet[random_int(0, strlen($alphabet) - 1)];
            }
        } while (self::query()->where('friend_code', $code)->exists());

        return $code;
    }

    /** Only admins reach the Filament panel (its own session login, ADR-042). */
    public function canAccessPanel(Panel $panel): bool
    {
        return $this->is_admin && ! $this->isBanned();
    }

    /**
     * Starts the deletion grace (QUESTIONS #18) and signs out every device;
     * returns when `accounts:purge` deletes the account.
     */
    public function requestDeletion(): Carbon
    {
        $this->forceFill(['deletion_requested_at' => now()])->save();
        $this->tokens()->delete();

        return now()->addDays((int) config('nard.deletion_grace_days'));
    }

    /** Banned while banned_at is set and the ban is permanent or not over. */
    public function isBanned(): bool
    {
        return $this->banned_at !== null && ($this->banned_until === null || $this->banned_until->isFuture());
    }

    public function isMuted(): bool
    {
        return $this->muted_until !== null && $this->muted_until->isFuture();
    }

    public function queueCooldownUntil(): ?Carbon
    {
        return $this->queue_cooldown_until !== null && $this->queue_cooldown_until->isFuture()
            ? $this->queue_cooldown_until : null;
    }

    /** @return HasMany<WalletTransaction, $this> */
    public function walletTransactions(): HasMany
    {
        return $this->hasMany(WalletTransaction::class);
    }

    /** @return HasMany<CheatFlag, $this> */
    public function cheatFlags(): HasMany
    {
        return $this->hasMany(CheatFlag::class);
    }

    /** @return HasMany<Report, $this> */
    public function reportsAgainst(): HasMany
    {
        return $this->hasMany(Report::class, 'reported_id');
    }

    public function isOnline(): bool
    {
        return $this->last_seen_at !== null
            && $this->last_seen_at->gt(now()->subSeconds((int) config('social.online_window')));
    }

    /**
     * Public card shown to other players.
     *
     * @return array<string, mixed>
     */
    public function publicCard(): array
    {
        return [
            'id' => (string) $this->id,
            'name' => $this->name,
            'country' => $this->country,
            'avatar' => $this->avatar,
            'level' => $this->level,
            'title' => $this->title_item_id,
            'online' => $this->isOnline(),
            'ratings' => $this->ratings()->get()->mapWithKeys(fn (Rating $r) => [$r->variant => $r->rating])->all(),
            'clan' => $this->currentClanMember()?->clan->badge(),
        ];
    }

    /** @return HasOne<ClanMember, $this> */
    public function clanMembership(): HasOne
    {
        return $this->hasOne(ClanMember::class);
    }

    /** Read fresh: membership changes within a request. */
    public function currentClanMember(): ?ClanMember
    {
        return $this->clanMembership()->with('clan')->first();
    }

    /** Highest current rating over the variants (initial rating if none). */
    public function bestRating(): int
    {
        $best = $this->ratings()->max('rating');

        return $best === null ? (int) config('nard.rating.initial') : (int) $best;
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
                'season_start_rating' => config('nard.rating.initial'),
                'season_matches' => 0,
                'season_wins' => 0,
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
            'friendCode' => $this->friend_code,
            'clan' => ($m = $this->currentClanMember()) === null ? null : [
                ...$m->clan->badge(),
                'name' => $m->clan->name,
                'role' => $m->role,
            ],
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
