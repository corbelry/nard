<?php

namespace App\Filament\Resources\Users\RelationManagers;

use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

/** Fair-play flags for the player (reviewed in Fair play → Flags). */
class CheatFlagsRelationManager extends RelationManager
{
    protected static string $relationship = 'cheatFlags';

    protected static ?string $title = 'Fair-play flags';

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
                TextColumn::make('kind')->badge(),
                TextColumn::make('score'),
                TextColumn::make('status')->badge(),
            ]);
    }
}
