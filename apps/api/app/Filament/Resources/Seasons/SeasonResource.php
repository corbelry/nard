<?php

namespace App\Filament\Resources\Seasons;

use App\Filament\Resources\Seasons\Pages\ListSeasons;
use App\Filament\Support\Admin;
use App\Models\Season;
use App\Services\ModerationService;
use App\Services\SeasonService;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;
use UnitEnum;

/** Seasons (ADR-039): view, end the running one early via SeasonService. */
class SeasonResource extends Resource
{
    protected static ?string $model = Season::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedCalendarDays;

    protected static string|UnitEnum|null $navigationGroup = 'Competition';

    protected static ?int $navigationSort = 2;

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
            ->defaultSort('number', 'desc')
            ->columns([
                TextColumn::make('number')->sortable(),
                TextColumn::make('title')->state(fn (Season $record): string => (string) ($record->name['en'] ?? reset($record->name))),
                TextColumn::make('status')->badge()->color(fn (string $state): string => $state === 'active' ? 'success' : 'gray'),
                TextColumn::make('starts_at')->dateTime(),
                TextColumn::make('ends_at')->dateTime(),
                TextColumn::make('finished_at')->dateTime()->placeholder('-'),
                TextColumn::make('results')->state(fn (Season $record): int => (int) $record->getConnection()->table('season_results')->where('season_id', $record->id)->count()),
            ])
            ->recordActions([
                Action::make('endNow')->label('End now')->color('danger')->icon('heroicon-o-stop-circle')
                    ->visible(fn (Season $record): bool => $record->status === 'active')
                    ->requiresConfirmation()
                    ->modalDescription('Snapshots final ranks, grants season-end rewards, soft-resets ratings and starts the next season. This cannot be undone.')
                    ->action(function (Season $record): void {
                        app(SeasonService::class)->endEarly($record);
                        app(ModerationService::class)->audit(Admin::user(), 'season_end', $record, null);
                        Notification::make()->title("Season {$record->number} ended")->success()->send();
                    }),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ListSeasons::route('/'),
        ];
    }
}
