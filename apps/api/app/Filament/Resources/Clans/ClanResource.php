<?php

namespace App\Filament\Resources\Clans;

use App\Filament\Resources\Clans\Pages\ListClans;
use App\Filament\Support\Admin;
use App\Models\Clan;
use App\Services\ClanException;
use App\Services\ModerationService;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Actions\ActionGroup;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;
use UnitEnum;

/** Clans (spec §8.4): view, rename an offensive name, disband. */
class ClanResource extends Resource
{
    protected static ?string $model = Clan::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedShieldCheck;

    protected static string|UnitEnum|null $navigationGroup = 'Competition';

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
        return $table
            ->defaultSort('id', 'desc')
            ->modifyQueryUsing(fn ($query) => $query->withCount('members'))
            ->columns([
                TextColumn::make('id')->sortable(),
                TextColumn::make('tag')->searchable()->badge(),
                TextColumn::make('name')->searchable(),
                TextColumn::make('members_count')->label('Members')->sortable(),
                TextColumn::make('level')->sortable(),
                TextColumn::make('xp')->sortable(),
                TextColumn::make('join_policy'),
                TextColumn::make('language'),
                TextColumn::make('description')->limit(60)->placeholder('-')->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('created_at')->dateTime()->sortable(),
            ])
            ->recordActions([
                ActionGroup::make([
                    Action::make('rename')->icon('heroicon-o-pencil')
                        ->schema([
                            TextInput::make('name')->required()
                                ->minLength((int) config('clans.name.min'))->maxLength((int) config('clans.name.max'))
                                ->regex('/^[\pL\pN][\pL\pN _\'.\-]*$/u'),
                        ])
                        ->action(function (Clan $record, array $data): void {
                            try {
                                app(ModerationService::class)->renameClan($record, trim((string) $data['name']), Admin::user());
                                Notification::make()->title('Clan renamed')->success()->send();
                            } catch (ClanException $e) {
                                Notification::make()->title('Not renamed: '.$e->getMessage())->danger()->send();
                            }
                        }),
                    Action::make('disband')->color('danger')->icon('heroicon-o-trash')
                        ->requiresConfirmation()
                        ->modalDescription('Deletes the clan, its members list, chat and chest. This cannot be undone.')
                        ->schema([Textarea::make('reason')->required()->maxLength(500)])
                        ->action(function (Clan $record, array $data): void {
                            app(ModerationService::class)->disbandClan($record, (string) $data['reason'], Admin::user());
                            Notification::make()->title('Clan disbanded')->success()->send();
                        }),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ListClans::route('/'),
        ];
    }
}
