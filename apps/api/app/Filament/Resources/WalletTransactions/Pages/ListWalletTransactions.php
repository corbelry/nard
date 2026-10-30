<?php

namespace App\Filament\Resources\WalletTransactions\Pages;

use App\Filament\Resources\WalletTransactions\WalletTransactionResource;
use App\Filament\Support\Admin;
use App\Models\User;
use App\Services\ModerationService;
use Filament\Actions\Action;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ListRecords;

class ListWalletTransactions extends ListRecords
{
    protected static string $resource = WalletTransactionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Action::make('grant')->label('Admin grant')->icon('heroicon-o-gift')
                ->modalDescription('Support compensation. Ledger reason "admin"; a note is required. Never sold or tied to money (ADR-022).')
                ->schema([
                    Select::make('user_id')->label('Player')->required()->searchable()
                        ->getSearchResultsUsing(fn (string $search): array => User::query()
                            ->where('name', 'like', "%$search%")->orWhere('email', 'like', "%$search%")
                            ->orWhere('id', ctype_digit($search) ? (int) $search : 0)
                            ->limit(20)->get()->mapWithKeys(fn (User $u) => [$u->id => "{$u->name} (#{$u->id})"])->all())
                        ->getOptionLabelUsing(fn ($value): ?string => User::query()->whereKey(is_numeric($value) ? (int) $value : 0)->first()?->name),
                    Select::make('currency')->options(['coins' => 'Coins', 'gems' => 'Yaqut'])->required()->default('coins'),
                    TextInput::make('amount')->integer()->required()->minValue(1)->maxValue((int) config('fairplay.max_grant')),
                    Textarea::make('note')->required()->maxLength(500),
                ])
                ->action(function (array $data): void {
                    $user = User::query()->findOrFail((int) $data['user_id']);
                    $balance = app(ModerationService::class)->grant($user, (string) $data['currency'], (int) $data['amount'], (string) $data['note'], Admin::user());
                    Notification::make()->title("Granted to {$user->name}; new balance $balance")->success()->send();
                }),
        ];
    }
}
