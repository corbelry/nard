<?php

namespace App\Filament\Resources\Tournaments;

use App\Filament\Resources\Tournaments\Pages\CreateTournament;
use App\Filament\Resources\Tournaments\Pages\ListTournaments;
use App\Filament\Resources\Tournaments\Pages\ViewTournament;
use App\Filament\Support\Admin;
use App\Models\Tournament;
use App\Services\ModerationService;
use App\Services\TournamentService;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TagsInput;
use Filament\Forms\Components\TextInput;
use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Components\ViewEntry;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;
use UnitEnum;

/**
 * Tournaments (spec §8.3): list all, create public scheduled ones (started
 * by `tournaments:tick` at starts_at), cancel while registering with full
 * refunds through TournamentService.
 */
class TournamentResource extends Resource
{
    protected static ?string $model = Tournament::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedTrophy;

    protected static string|UnitEnum|null $navigationGroup = 'Competition';

    protected static ?int $navigationSort = 1;

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

    public static function title(Tournament $t): string
    {
        return (string) ($t->name['en'] ?? $t->name['az'] ?? $t->name['default'] ?? reset($t->name));
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->columns(2)->components([
            TextInput::make('name.az')->label('Name (az)')->required()->maxLength(40),
            TextInput::make('name.en')->label('Name (en)')->required()->maxLength(40),
            TextInput::make('name.ru')->label('Name (ru)')->maxLength(40),
            TextInput::make('name.tr')->label('Name (tr)')->maxLength(40),
            Select::make('format')->required()->live()
                ->options(array_combine((array) config('tournaments.formats'), (array) config('tournaments.formats'))),
            Select::make('variant')->required()->options(['shortNard' => 'Short Nard', 'longNard' => 'Long Nard']),
            Select::make('match_length')->required()->options([1 => '1', 3 => '3', 5 => '5', 7 => '7'])->default(3),
            Select::make('size')->required()->options([4 => '4', 8 => '8', 16 => '16', 32 => '32', 64 => '64', 128 => '128'])->default(32),
            TextInput::make('min_players')->integer()->required()->minValue(2)->default(4),
            TextInput::make('entry_coins')->label('Entry fee (coins)')->integer()->required()->minValue(0)->default(0),
            TextInput::make('min_rating')->integer()->minValue(0)->maxValue(3000),
            TextInput::make('swiss_rounds')->integer()->minValue(1)->maxValue(12)
                ->visible(fn ($get): bool => $get('format') === 'swiss')->required(fn ($get): bool => $get('format') === 'swiss'),
            DateTimePicker::make('starts_at')->label('Starts at (UTC)')->required()->seconds(false)->after('now')->timezone('UTC'),
            Repeater::make('prizes')->label('Prizes (house-funded coins and items)')->columnSpanFull()->columns(4)
                ->defaultItems(1)
                ->schema([
                    TextInput::make('from')->label('From place')->integer()->required()->minValue(1),
                    TextInput::make('to')->label('To place')->integer()->required()->minValue(1),
                    TextInput::make('coins')->integer()->required()->minValue(0),
                    TagsInput::make('items')->label('Item ids')->default([]),
                ]),
        ]);
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema->components([
            Section::make('Tournament')->columns(4)->schema([
                TextEntry::make('id'),
                TextEntry::make('title')->state(fn (Tournament $record): string => self::title($record)),
                TextEntry::make('kind')->badge(),
                TextEntry::make('status')->badge(),
                TextEntry::make('format'),
                TextEntry::make('variant'),
                TextEntry::make('match_length'),
                TextEntry::make('size'),
                TextEntry::make('min_players'),
                TextEntry::make('entries')->state(fn (Tournament $record): int => $record->entries()->count()),
                TextEntry::make('entry_coins'),
                TextEntry::make('prize_fund'),
                TextEntry::make('min_rating')->placeholder('-'),
                TextEntry::make('current_round'),
                TextEntry::make('total_rounds')->placeholder('-'),
                IconEntry::make('is_private')->boolean(),
                TextEntry::make('starts_at')->dateTime()->placeholder('-'),
                TextEntry::make('started_at')->dateTime()->placeholder('-'),
                TextEntry::make('finished_at')->dateTime()->placeholder('-'),
                TextEntry::make('cancel_reason')->placeholder('-'),
            ]),
            Section::make('Prizes')->collapsible()->schema([
                ViewEntry::make('prizes')->view('filament.json-entry')->hiddenLabel(),
            ]),
        ]);
    }

    public static function cancelAction(): Action
    {
        return Action::make('cancel')->label('Cancel & refund')->color('danger')->icon('heroicon-o-x-circle')
            ->visible(fn (Tournament $record): bool => $record->status === 'registering')
            ->requiresConfirmation()
            ->modalDescription('Cancels the tournament and refunds every entry fee to the ledger.')
            ->action(function (Tournament $record): void {
                app(TournamentService::class)->cancel($record, 'admin');
                app(ModerationService::class)->audit(Admin::user(), 'tournament_cancel', $record, null);
                Notification::make()->title('Tournament cancelled')->success()->send();
            });
    }

    public static function table(Table $table): Table
    {
        return $table
            ->defaultSort('id', 'desc')
            ->modifyQueryUsing(fn ($query) => $query->withCount('entries'))
            ->columns([
                TextColumn::make('id')->sortable(),
                TextColumn::make('title')->state(fn (Tournament $record): string => self::title($record)),
                TextColumn::make('kind')->badge(),
                TextColumn::make('format'),
                TextColumn::make('variant'),
                TextColumn::make('status')->badge()->color(fn (string $state): string => match ($state) {
                    'registering' => 'info', 'running' => 'warning', 'cancelled' => 'danger', default => 'gray',
                }),
                TextColumn::make('entries_count')->label('Entries')->state(fn (Tournament $record): string => ($record->entries_count ?? 0).' / '.$record->size),
                TextColumn::make('entry_coins')->label('Entry'),
                TextColumn::make('prize_fund'),
                TextColumn::make('starts_at')->dateTime()->sortable()->placeholder('-'),
            ])
            ->filters([
                SelectFilter::make('status')->options(array_combine(
                    ['registering', 'running', 'finished', 'cancelled'], ['registering', 'running', 'finished', 'cancelled'],
                )),
                SelectFilter::make('kind')->options(['scheduled' => 'scheduled', 'sit_and_go' => 'sit_and_go', 'private' => 'private']),
            ])
            ->recordActions([ViewAction::make(), self::cancelAction()]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ListTournaments::route('/'),
            'create' => CreateTournament::route('/create'),
            'view' => ViewTournament::route('/{record}'),
        ];
    }
}
