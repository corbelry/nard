<?php

namespace App\Filament\Resources\Users\Pages;

use App\Filament\Resources\Users\UserResource;
use App\Filament\Support\Admin;
use App\Models\User;
use App\Services\ModerationService;
use Filament\Actions\Action;
use Filament\Actions\ActionGroup;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ViewRecord;
use Illuminate\Support\Carbon;

/** Moderation actions on one player; each is audited (ModerationService). */
class ViewUser extends ViewRecord
{
    protected static string $resource = UserResource::class;

    private function player(): User
    {
        /** @var User $user */
        $user = $this->getRecord();

        return $user;
    }

    protected function getHeaderActions(): array
    {
        return [
            Action::make('ban')->color('danger')->icon('heroicon-o-no-symbol')
                ->visible(fn (): bool => ! $this->player()->isBanned())
                ->schema([
                    Toggle::make('permanent')->live()->default(false),
                    DateTimePicker::make('until')->required(fn ($get): bool => ! $get('permanent'))
                        ->hidden(fn ($get): bool => (bool) $get('permanent'))->after('now'),
                    Textarea::make('reason')->required()->maxLength(500),
                ])
                ->action(function (array $data): void {
                    $until = $data['permanent'] ? null : Carbon::parse((string) $data['until']);
                    app(ModerationService::class)->ban($this->player(), $until, (string) $data['reason'], Admin::user());
                    Notification::make()->title('Player banned')->success()->send();
                }),
            Action::make('unban')->color('gray')->icon('heroicon-o-check-circle')
                ->visible(fn (): bool => $this->player()->isBanned())
                ->schema([Textarea::make('note')->maxLength(500)])
                ->action(function (array $data): void {
                    app(ModerationService::class)->unban($this->player(), $data['note'] ?? null, Admin::user());
                    Notification::make()->title('Ban lifted')->success()->send();
                }),
            ActionGroup::make([
                Action::make('mute')->label('Mute chat & emotes')->icon('heroicon-o-speaker-x-mark')
                    ->visible(fn (): bool => ! $this->player()->isMuted())
                    ->schema([
                        Select::make('hours')->label('Duration')->required()->default(24)
                            ->options(collect((array) config('fairplay.mute_hours'))->mapWithKeys(fn ($h) => [(int) $h => "$h h"])->all()),
                        Textarea::make('reason')->required()->maxLength(500),
                    ])
                    ->action(function (array $data): void {
                        app(ModerationService::class)->mute($this->player(), now()->addHours((int) $data['hours']), (string) $data['reason'], Admin::user());
                        Notification::make()->title('Player muted')->success()->send();
                    }),
                Action::make('unmute')->icon('heroicon-o-speaker-wave')
                    ->visible(fn (): bool => $this->player()->isMuted())
                    ->requiresConfirmation()
                    ->action(fn () => app(ModerationService::class)->unmute($this->player(), Admin::user())),
                Action::make('clearCooldown')->label('Clear matchmaking cooldown')->icon('heroicon-o-clock')
                    ->visible(fn (): bool => $this->player()->queueCooldownUntil() !== null)
                    ->requiresConfirmation()
                    ->action(fn () => app(ModerationService::class)->clearCooldown($this->player(), Admin::user())),
                Action::make('warn')->icon('heroicon-o-exclamation-triangle')
                    ->schema([Textarea::make('reason')->required()->maxLength(300)])
                    ->action(function (array $data): void {
                        app(ModerationService::class)->warn($this->player(), (string) $data['reason'], Admin::user());
                        Notification::make()->title('Warning sent to the inbox')->success()->send();
                    }),
                Action::make('resetName')->label('Reset nickname')->icon('heroicon-o-identification')
                    ->requiresConfirmation()
                    ->modalDescription('Replaces the nickname with a generated guest name.')
                    ->action(function (): void {
                        $name = app(ModerationService::class)->resetName($this->player(), Admin::user());
                        Notification::make()->title("Nickname reset to $name")->success()->send();
                    }),
                Action::make('grant')->label('Admin grant')->icon('heroicon-o-gift')
                    ->modalDescription('Support compensation. Ledger reason "admin"; never sold or tied to money (ADR-022).')
                    ->schema([
                        Select::make('currency')->options(['coins' => 'Coins', 'gems' => 'Yaqut'])->required()->default('coins'),
                        TextInput::make('amount')->integer()->required()->minValue(1)->maxValue((int) config('fairplay.max_grant')),
                        Textarea::make('note')->required()->maxLength(500),
                    ])
                    ->action(function (array $data): void {
                        $balance = app(ModerationService::class)->grant($this->player(), (string) $data['currency'], (int) $data['amount'], (string) $data['note'], Admin::user());
                        Notification::make()->title("Granted; new balance $balance")->success()->send();
                    }),
            ])->label('More')->button(),
        ];
    }
}
