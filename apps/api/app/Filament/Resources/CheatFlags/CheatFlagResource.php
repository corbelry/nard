<?php

namespace App\Filament\Resources\CheatFlags;

use App\Filament\Resources\CheatFlags\Pages\ListCheatFlags;
use App\Filament\Resources\CheatFlags\Pages\ViewCheatFlag;
use App\Filament\Resources\Users\UserResource;
use App\Filament\Support\Admin;
use App\Models\CheatFlag;
use App\Services\ModerationService;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
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

/** Fair-play flags from `anticheat:scan` (spec §8.14), reviewed here. */
class CheatFlagResource extends Resource
{
    protected static ?string $model = CheatFlag::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedShieldExclamation;

    protected static string|UnitEnum|null $navigationGroup = 'Fair play';

    protected static ?string $navigationLabel = 'Flags';

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

    public static function getNavigationBadge(): ?string
    {
        $open = CheatFlag::query()->where('status', 'open')->count();

        return $open > 0 ? (string) $open : null;
    }

    public static function reviewAction(): Action
    {
        return Action::make('review')->icon('heroicon-o-check-badge')
            ->visible(fn (CheatFlag $record): bool => $record->status === 'open')
            ->schema([
                Select::make('status')->required()->default('reviewed')
                    ->options(['reviewed' => 'Reviewed (keep watching)', 'dismissed' => 'Dismissed (false positive)', 'actioned' => 'Actioned (player sanctioned)']),
                Textarea::make('note')->maxLength(500),
            ])
            ->action(function (CheatFlag $record, array $data): void {
                app(ModerationService::class)->reviewFlag($record, (string) $data['status'], $data['note'] ?? null, Admin::user());
                Notification::make()->title('Flag '.$data['status'])->success()->send();
            });
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema->components([
            Section::make('Flag')->columns(3)->schema([
                TextEntry::make('user.name')->label('Player')
                    ->url(fn (CheatFlag $record): string => UserResource::getUrl('view', ['record' => $record->user_id])),
                TextEntry::make('kind')->badge(),
                TextEntry::make('score'),
                TextEntry::make('status')->badge(),
                TextEntry::make('created_at')->dateTime(),
                TextEntry::make('updated_at')->dateTime(),
                TextEntry::make('reviewer.name')->label('Reviewed by')->placeholder('-'),
                TextEntry::make('reviewed_at')->dateTime()->placeholder('-'),
                TextEntry::make('review_note')->placeholder('-'),
            ]),
            Section::make('Details')->schema([
                ViewEntry::make('details')->view('filament.json-entry')->hiddenLabel(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->defaultSort('id', 'desc')
            ->columns([
                TextColumn::make('id'),
                TextColumn::make('created_at')->dateTime()->sortable(),
                TextColumn::make('user.name')->label('Player')->searchable()
                    ->url(fn (CheatFlag $record): string => UserResource::getUrl('view', ['record' => $record->user_id])),
                TextColumn::make('kind')->badge(),
                TextColumn::make('score')->sortable(),
                TextColumn::make('summary')->state(fn (CheatFlag $record): string => self::summary($record))->wrap(),
                TextColumn::make('status')->badge()->color(fn (string $state): string => match ($state) {
                    'open' => 'warning', 'actioned' => 'danger', default => 'gray',
                }),
            ])
            ->filters([
                SelectFilter::make('status')->options(array_combine(CheatFlag::STATUSES, CheatFlag::STATUSES))->default('open'),
                SelectFilter::make('kind')->options(array_combine(CheatFlag::KINDS, CheatFlag::KINDS)),
            ])
            ->recordActions([ViewAction::make(), self::reviewAction()]);
    }

    public static function summary(CheatFlag $flag): string
    {
        $d = $flag->details;
        $s = fn (string $key): string => is_scalar($d[$key] ?? null) ? (string) $d[$key] : '?';

        return match ($flag->kind) {
            'engine' => "agreement {$s('agreement')} vs {$s('expected')} expected at {$s('rating')} over {$s('decisions')} decisions",
            'multi_account' => count((array) ($d['partners'] ?? [])).' linked account(s)',
            'abandonment' => "{$s('quits')} of {$s('matches')} matches abandoned / timed out",
            'reports' => "{$s('reporters')} distinct reporters",
            default => '',
        };
    }

    public static function getPages(): array
    {
        return [
            'index' => ListCheatFlags::route('/'),
            'view' => ViewCheatFlag::route('/{record}'),
        ];
    }
}
