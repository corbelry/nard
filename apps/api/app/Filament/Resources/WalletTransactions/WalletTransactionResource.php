<?php

namespace App\Filament\Resources\WalletTransactions;

use App\Filament\Resources\Users\UserResource;
use App\Filament\Resources\WalletTransactions\Pages\ListWalletTransactions;
use App\Models\WalletTransaction;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;
use UnitEnum;

/**
 * The append-only ledger (spec §9), read-only. The only write here is the
 * audited "admin grant" (ledger reason 'admin'); nothing ties coins to
 * money (ADR-022).
 */
class WalletTransactionResource extends Resource
{
    protected static ?string $model = WalletTransaction::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedBanknotes;

    protected static string|UnitEnum|null $navigationGroup = 'Economy';

    protected static ?string $navigationLabel = 'Ledger';

    protected static ?int $navigationSort = 3;

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

    public static function table(Table $table): Table
    {
        $reasons = array_values(array_unique(array_merge(...array_values((array) config('economy.credit_reasons')))));
        $reasons = array_merge($reasons, ['purchase', 'tournament_entry', 'clan_create', 'clan_rename', 'clan_donation', 'season_pass']);
        $reasons = array_values(array_unique($reasons));

        return $table
            ->defaultSort('id', 'desc')
            ->columns([
                TextColumn::make('id'),
                TextColumn::make('created_at')->dateTime()->sortable(),
                TextColumn::make('user.name')->label('Player')
                    ->url(fn (WalletTransaction $record): string => UserResource::getUrl('view', ['record' => $record->user_id])),
                TextColumn::make('user_id')->label('Player id')->searchable()->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('currency')->badge(),
                TextColumn::make('amount')->numeric()->color(fn (int $state): string => $state < 0 ? 'danger' : 'success'),
                TextColumn::make('balance_after')->numeric(),
                TextColumn::make('reason')->badge(),
                TextColumn::make('reference')->searchable()->placeholder('-'),
                TextColumn::make('idempotency_key')->searchable()->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('currency')->options(['coins' => 'Coins', 'gems' => 'Yaqut']),
                SelectFilter::make('reason')->options(array_combine($reasons, $reasons)),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ListWalletTransactions::route('/'),
        ];
    }
}
