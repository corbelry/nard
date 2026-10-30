<?php

namespace App\Filament\Resources\Users;

use App\Filament\Resources\Users\Pages\ListUsers;
use App\Filament\Resources\Users\Pages\ViewUser;
use App\Filament\Resources\Users\RelationManagers\CheatFlagsRelationManager;
use App\Filament\Resources\Users\RelationManagers\ReportsRelationManager;
use App\Filament\Resources\Users\RelationManagers\WalletTransactionsRelationManager;
use App\Models\Rating;
use App\Models\User;
use App\Services\WalletService;
use BackedEnum;
use Filament\Actions\ViewAction;
use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\RepeatableEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\Filter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use UnitEnum;

/** Players: search, profile, ratings, wallet, ledger and moderation (spec §8.13). */
class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedUsers;

    protected static string|UnitEnum|null $navigationGroup = 'Players';

    protected static ?int $navigationSort = 1;

    protected static ?string $recordTitleAttribute = 'name';

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit(Model $record): bool
    {
        return false;
    }

    public static function canDelete(Model $record): bool
    {
        return false;
    }

    public static function canDeleteAny(): bool
    {
        return false;
    }

    public static function status(User $user): string
    {
        return match (true) {
            $user->isBanned() => 'banned',
            $user->isMuted() => 'muted',
            $user->queueCooldownUntil() !== null => 'cooldown',
            default => 'ok',
        };
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema->components([
            Section::make('Profile')->columns(3)->schema([
                TextEntry::make('id'),
                TextEntry::make('name'),
                TextEntry::make('email')->placeholder('-'),
                TextEntry::make('friend_code')->placeholder('-'),
                TextEntry::make('country')->placeholder('-'),
                TextEntry::make('locale'),
                IconEntry::make('is_guest')->boolean(),
                IconEntry::make('is_admin')->boolean(),
                TextEntry::make('level'),
                TextEntry::make('xp'),
                TextEntry::make('games_total'),
                TextEntry::make('wins_total'),
                TextEntry::make('created_at')->dateTime(),
                TextEntry::make('last_seen_at')->dateTime()->placeholder('-'),
                TextEntry::make('last_login_at')->dateTime()->placeholder('-'),
                TextEntry::make('last_ip')->label('Last IP')->placeholder('-'),
            ]),
            Section::make('Wallet')->columns(2)->schema([
                TextEntry::make('coins')->state(fn (User $record): int => app(WalletService::class)->balances($record)['coins'])->numeric(),
                TextEntry::make('gems')->label('Yaqut')->state(fn (User $record): int => app(WalletService::class)->balances($record)['gems'])->numeric(),
            ]),
            Section::make('Ratings')->schema([
                RepeatableEntry::make('ratings')->columns(6)->schema([
                    TextEntry::make('variant'),
                    TextEntry::make('rating'),
                    TextEntry::make('tier')->state(fn (Rating $record): string => Rating::tier($record->rating)),
                    TextEntry::make('peak'),
                    TextEntry::make('matches'),
                    TextEntry::make('wins'),
                ])->placeholder('No rated games'),
            ]),
            Section::make('Moderation')->columns(3)->schema([
                TextEntry::make('status')->state(fn (User $record): string => self::status($record))->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'banned' => 'danger', 'muted', 'cooldown' => 'warning', default => 'success',
                    }),
                TextEntry::make('banned_at')->dateTime()->placeholder('-'),
                TextEntry::make('banned_until')->dateTime()
                    ->placeholder(fn (User $record): string => $record->banned_at !== null ? 'permanent' : '-'),
                TextEntry::make('ban_reason')->placeholder('-')->columnSpanFull(),
                TextEntry::make('muted_until')->dateTime()->placeholder('-'),
                TextEntry::make('queue_cooldown_until')->label('Matchmaking cooldown until')->dateTime()->placeholder('-'),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->defaultSort('id', 'desc')
            ->columns([
                TextColumn::make('id')->sortable()->searchable(),
                TextColumn::make('name')->searchable(),
                TextColumn::make('email')->searchable()->placeholder('-'),
                TextColumn::make('friend_code')->searchable()->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('country')->placeholder('-'),
                IconColumn::make('is_guest')->boolean()->label('Guest'),
                IconColumn::make('is_admin')->boolean()->label('Admin'),
                TextColumn::make('status')->state(fn (User $record): string => self::status($record))->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'banned' => 'danger', 'muted', 'cooldown' => 'warning', default => 'success',
                    }),
                TextColumn::make('last_seen_at')->dateTime()->sortable()->placeholder('-'),
                TextColumn::make('created_at')->dateTime()->sortable(),
            ])
            ->filters([
                Filter::make('banned')->query(fn (Builder $q) => $q->whereNotNull('banned_at')
                    ->where(fn (Builder $q) => $q->whereNull('banned_until')->orWhere('banned_until', '>', now()))),
                Filter::make('muted')->query(fn (Builder $q) => $q->where('muted_until', '>', now())),
                Filter::make('admins')->query(fn (Builder $q) => $q->where('is_admin', true)),
            ])
            ->recordActions([ViewAction::make()]);
    }

    public static function getRelations(): array
    {
        return [
            WalletTransactionsRelationManager::class,
            ReportsRelationManager::class,
            CheatFlagsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListUsers::route('/'),
            'view' => ViewUser::route('/{record}'),
        ];
    }
}
