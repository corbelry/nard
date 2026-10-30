<?php

namespace App\Filament\Resources\Puzzles;

use App\Filament\Resources\Puzzles\Pages\EditPuzzle;
use App\Filament\Resources\Puzzles\Pages\ListPuzzles;
use App\Filament\Support\Admin;
use App\Models\Puzzle;
use App\Services\ModerationService;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;
use UnitEnum;

/**
 * Practice puzzles (ADR-039): list, edit rating/phase, disable. Positions
 * and solutions come from tool/gen_puzzles.dart and are not edited here.
 */
class PuzzleResource extends Resource
{
    protected static ?string $model = Puzzle::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedLightBulb;

    protected static string|UnitEnum|null $navigationGroup = 'Competition';

    protected static ?int $navigationSort = 4;

    public static function canCreate(): bool
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

    public static function form(Schema $schema): Schema
    {
        return $schema->columns(3)->components([
            TextInput::make('rating')->integer()->required()->minValue(500)->maxValue(3000),
            Select::make('phase')->required()->options(['opening' => 'opening', 'middle' => 'middle', 'bearoff' => 'bearoff']),
            Toggle::make('enabled'),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->defaultSort('id')
            ->columns([
                TextColumn::make('id')->searchable(),
                TextColumn::make('variant'),
                TextColumn::make('side'),
                TextColumn::make('rating')->sortable(),
                TextColumn::make('phase'),
                TextColumn::make('solution')->limit(30),
                TextColumn::make('attempts')->state(fn (Puzzle $record): int => (int) $record->getConnection()->table('puzzle_attempts')->where('puzzle_id', $record->id)->count()),
                IconColumn::make('enabled')->boolean(),
            ])
            ->filters([TernaryFilter::make('enabled')])
            ->recordActions([
                EditAction::make(),
                Action::make('toggle')
                    ->label(fn (Puzzle $record): string => $record->enabled ? 'Disable' : 'Enable')
                    ->icon(fn (Puzzle $record): string => $record->enabled ? 'heroicon-o-eye-slash' : 'heroicon-o-eye')
                    ->requiresConfirmation()
                    ->action(function (Puzzle $record): void {
                        $record->forceFill(['enabled' => ! $record->enabled])->save();
                        app(ModerationService::class)->audit(Admin::user(), $record->enabled ? 'puzzle_enable' : 'puzzle_disable', $record, null);
                    }),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ListPuzzles::route('/'),
            'edit' => EditPuzzle::route('/{record}/edit'),
        ];
    }
}
