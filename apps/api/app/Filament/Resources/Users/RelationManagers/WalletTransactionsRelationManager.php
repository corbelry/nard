<?php

namespace App\Filament\Resources\Users\RelationManagers;

use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

/** The player's ledger, read-only (writes only through WalletService). */
class WalletTransactionsRelationManager extends RelationManager
{
    protected static string $relationship = 'walletTransactions';

    protected static ?string $title = 'Ledger';

    public function isReadOnly(): bool
    {
        return true;
    }

    public function table(Table $table): Table
    {
        return $table
            ->defaultSort('id', 'desc')
            ->columns([
                TextColumn::make('id'),
                TextColumn::make('created_at')->dateTime(),
                TextColumn::make('currency')->badge(),
                TextColumn::make('amount')->numeric()->color(fn (int $state): string => $state < 0 ? 'danger' : 'success'),
                TextColumn::make('balance_after')->numeric(),
                TextColumn::make('reason')->badge(),
                TextColumn::make('reference')->placeholder('-'),
            ])
            ->filters([
                SelectFilter::make('currency')->options(['coins' => 'Coins', 'gems' => 'Yaqut']),
            ]);
    }
}
