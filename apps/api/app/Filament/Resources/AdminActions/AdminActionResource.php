<?php

namespace App\Filament\Resources\AdminActions;

use App\Filament\Resources\AdminActions\Pages\ListAdminActions;
use App\Models\AdminAction;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;
use UnitEnum;

/** Audit log of admin writes and automatic sanctions (read-only). */
class AdminActionResource extends Resource
{
    protected static ?string $model = AdminAction::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedClipboardDocumentList;

    protected static string|UnitEnum|null $navigationGroup = 'System';

    protected static ?string $navigationLabel = 'Audit log';

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
        return $table
            ->defaultSort('id', 'desc')
            ->columns([
                TextColumn::make('id'),
                TextColumn::make('created_at')->dateTime()->sortable(),
                TextColumn::make('admin.name')->label('Admin')->placeholder('system'),
                TextColumn::make('action')->badge()->searchable(),
                TextColumn::make('subject')->searchable(),
                TextColumn::make('note')->limit(80)->wrap()->placeholder('-'),
                TextColumn::make('data')->state(fn (AdminAction $record): string => $record->data === null ? '-' : (string) json_encode($record->data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES))->limit(80),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ListAdminActions::route('/'),
        ];
    }
}
