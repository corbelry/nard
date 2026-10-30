<?php

namespace App\Filament\Resources\Reports;

use App\Filament\Resources\Reports\Pages\ListReports;
use App\Filament\Resources\Users\UserResource;
use App\Filament\Support\Admin;
use App\Models\Report;
use App\Services\ModerationService;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Actions\ActionGroup;
use Filament\Forms\Components\Field;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Component;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;
use UnitEnum;

/** Moderation queue (14.2): dismiss / warn / mute / ban, each audited. */
class ReportResource extends Resource
{
    protected static ?string $model = Report::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedFlag;

    protected static string|UnitEnum|null $navigationGroup = 'Players';

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

    public static function getNavigationBadge(): ?string
    {
        $open = Report::query()->where('status', 'open')->count();

        return $open > 0 ? (string) $open : null;
    }

    public static function table(Table $table): Table
    {
        return $table
            ->defaultSort('id', 'desc')
            ->columns([
                TextColumn::make('id')->formatStateUsing(fn (int $state): string => sprintf('R-%06d', $state))->searchable(),
                TextColumn::make('created_at')->dateTime()->sortable(),
                TextColumn::make('reported.name')->label('Reported')->searchable()
                    ->url(fn (Report $record): string => UserResource::getUrl('view', ['record' => $record->reported_id])),
                TextColumn::make('reporter.name')->label('Reporter')->placeholder('deleted')
                    ->url(fn (Report $record): ?string => $record->reporter_id === null ? null : UserResource::getUrl('view', ['record' => $record->reporter_id])),
                TextColumn::make('reason')->badge(),
                TextColumn::make('note')->limit(80)->wrap()->placeholder('-'),
                TextColumn::make('match_id')->placeholder('-')->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('status')->badge()->color(fn (string $state): string => match ($state) {
                    'open' => 'warning', 'actioned' => 'danger', default => 'gray',
                }),
                TextColumn::make('action')->placeholder('-'),
                TextColumn::make('handler.name')->label('Handled by')->placeholder('-')->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('status')->options(array_combine(Report::STATUSES, Report::STATUSES))->default('open'),
                SelectFilter::make('reason')->options(fn (): array => array_combine((array) config('social.report_reasons'), (array) config('social.report_reasons'))),
            ])
            ->recordActions([
                ActionGroup::make([
                    self::handle('dismiss', 'Dismiss', 'heroicon-o-x-mark', []),
                    self::handle('warn', 'Warn', 'heroicon-o-exclamation-triangle', [
                        Textarea::make('note')->label('Message reason')->maxLength(300),
                    ]),
                    self::handle('mute', 'Mute', 'heroicon-o-speaker-x-mark', [
                        Select::make('hours')->label('Duration')->required()->default(24)
                            ->options(collect((array) config('fairplay.mute_hours'))->mapWithKeys(fn ($h) => [(int) $h => "$h h"])->all()),
                        Textarea::make('note')->maxLength(500),
                    ]),
                    self::handle('ban', 'Ban', 'heroicon-o-no-symbol', [
                        Toggle::make('permanent')->live()->default(false),
                        Select::make('hours')->label('Duration')->default(168)
                            ->options([24 => '1 day', 72 => '3 days', 168 => '7 days', 720 => '30 days'])
                            ->required(fn ($get): bool => ! $get('permanent'))->hidden(fn ($get): bool => (bool) $get('permanent')),
                        Textarea::make('note')->label('Ban reason')->required()->maxLength(500),
                    ])->color('danger'),
                ])->visible(fn (Report $record): bool => $record->status === 'open'),
            ]);
    }

    /** @param array<int, Component|Field> $schema */
    private static function handle(string $action, string $label, string $icon, array $schema): Action
    {
        return Action::make($action)->label($label)->icon($icon)
            ->requiresConfirmation($schema === [])
            ->schema($schema)
            ->action(function (Report $record, array $data) use ($action): void {
                $hours = ($data['permanent'] ?? false) ? null : (isset($data['hours']) ? (int) $data['hours'] : null);
                if ($action === 'mute') {
                    $hours ??= 24;
                }
                app(ModerationService::class)->handleReport($record, $action, $data['note'] ?? null, $hours, Admin::user());
                Notification::make()->title('Report closed: '.$action)->success()->send();
            });
    }

    public static function getPages(): array
    {
        return [
            'index' => ListReports::route('/'),
        ];
    }
}
