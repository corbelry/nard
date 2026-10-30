<?php

namespace App\Filament\Resources\GameMatches;

use App\Filament\Resources\GameMatches\Pages\ListGameMatches;
use App\Filament\Resources\GameMatches\Pages\ViewGameMatch;
use App\Filament\Resources\Users\UserResource;
use App\Models\GameMatch;
use BackedEnum;
use Filament\Actions\ViewAction;
use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Components\ViewEntry;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;
use UnitEnum;

/** Finished matches with their game records and revealed dice seeds (read-only). */
class GameMatchResource extends Resource
{
    protected static ?string $model = GameMatch::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedPuzzlePiece;

    protected static string|UnitEnum|null $navigationGroup = 'Players';

    protected static ?string $navigationLabel = 'Matches';

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

    public static function infolist(Schema $schema): Schema
    {
        $player = fn (string $side) => TextEntry::make("{$side}_name")->label(ucfirst($side))
            ->url(fn (GameMatch $record): ?string => $record->{"{$side}_user_id"} === null ? null
                : UserResource::getUrl('view', ['record' => $record->{"{$side}_user_id"}]))
            ->suffix(fn (GameMatch $record): string => $record->{"{$side}_bot"} ? ' (bot)' : '');

        return $schema->components([
            Section::make('Match')->columns(4)->schema([
                TextEntry::make('id'),
                TextEntry::make('mode')->badge(),
                TextEntry::make('variant'),
                TextEntry::make('match_length'),
                $player('white'),
                $player('black'),
                TextEntry::make('winner')->badge(),
                TextEntry::make('score')->state(fn (GameMatch $record): string => "{$record->white_score} – {$record->black_score}"),
                TextEntry::make('reason'),
                TextEntry::make('tournament_id')->placeholder('-'),
                TextEntry::make('started_at')->dateTime(),
                TextEntry::make('ended_at')->dateTime(),
                TextEntry::make('white_rating')->state(fn (GameMatch $record): string => $record->white_rating_before === null ? '-' : "{$record->white_rating_before} → {$record->white_rating_after}"),
                TextEntry::make('black_rating')->state(fn (GameMatch $record): string => $record->black_rating_before === null ? '-' : "{$record->black_rating_before} → {$record->black_rating_after}"),
            ]),
            Section::make('Games (records, server seeds, commitments, client seeds)')->collapsible()->schema([
                ViewEntry::make('games')->view('filament.json-entry')->hiddenLabel(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->defaultSort('ended_at', 'desc')
            ->columns([
                TextColumn::make('id')->searchable()->limit(12),
                TextColumn::make('ended_at')->dateTime()->sortable(),
                TextColumn::make('mode')->badge(),
                TextColumn::make('variant'),
                TextColumn::make('white_name')->label('White')->searchable(),
                TextColumn::make('black_name')->label('Black')->searchable(),
                TextColumn::make('score')->state(fn (GameMatch $record): string => "{$record->white_score} – {$record->black_score}"),
                TextColumn::make('winner'),
                TextColumn::make('reason')->badge(),
            ])
            ->filters([
                SelectFilter::make('mode')->options(['ranked' => 'ranked', 'casual' => 'casual', 'tournament' => 'tournament']),
                SelectFilter::make('reason')->options(array_combine(
                    ['completed', 'resigned', 'timeout', 'abandoned', 'walkover'],
                    ['completed', 'resigned', 'timeout', 'abandoned', 'walkover'],
                )),
            ])
            ->recordActions([ViewAction::make()]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ListGameMatches::route('/'),
            'view' => ViewGameMatch::route('/{record}'),
        ];
    }
}
