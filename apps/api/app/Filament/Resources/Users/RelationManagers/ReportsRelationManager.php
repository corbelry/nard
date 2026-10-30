<?php

namespace App\Filament\Resources\Users\RelationManagers;

use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

/** Reports against the player (handled in the Reports queue). */
class ReportsRelationManager extends RelationManager
{
    protected static string $relationship = 'reportsAgainst';

    protected static ?string $title = 'Reports against';

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
                TextColumn::make('reporter.name')->placeholder('deleted'),
                TextColumn::make('reason')->badge(),
                TextColumn::make('note')->limit(60)->placeholder('-'),
                TextColumn::make('status')->badge(),
                TextColumn::make('action')->placeholder('-'),
            ]);
    }
}
