<?php

namespace App\Filament\Pages;

use App\Filament\Support\Admin;
use App\Models\Item;
use App\Services\ModerationService;
use App\Services\Settings;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Filament\Schemas\Components\Actions;
use Filament\Schemas\Components\EmbeddedSchema;
use Filament\Schemas\Components\Form;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use UnitEnum;

/**
 * The featured store offer (7.3): which item and the struck-through old
 * price. Stored in app_settings; config('economy.featured') is the default.
 *
 * @property-read Schema $form
 */
class FeaturedOffer extends Page
{
    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedStar;

    protected static string|UnitEnum|null $navigationGroup = 'Economy';

    protected static ?int $navigationSort = 2;

    protected static ?string $title = 'Featured offer';

    /** @var array<string, mixed>|null */
    public ?array $data = [];

    public function mount(): void
    {
        $offer = app(Settings::class)->featuredOffer();
        $this->form->fill([
            'item' => $offer['item'] ?? null,
            'old_gems' => $offer['oldPrice']['gems'] ?? null,
            'old_coins' => $offer['oldPrice']['coins'] ?? null,
        ]);
    }

    public function form(Schema $schema): Schema
    {
        return $schema->statePath('data')->columns(3)->components([
            Select::make('item')->label('Item')->searchable()->required()
                ->options(fn (): array => Item::query()->where('is_default', false)
                    ->where(fn ($q) => $q->whereNotNull('price_coins')->orWhereNotNull('price_gems'))
                    ->orderBy('id')->pluck('id', 'id')->all()),
            TextInput::make('old_gems')->label('Old price (Yaqut)')->integer()->minValue(1),
            TextInput::make('old_coins')->label('Old price (coins)')->integer()->minValue(1),
        ]);
    }

    public function content(Schema $schema): Schema
    {
        return $schema->components([
            Form::make([EmbeddedSchema::make('form')])
                ->id('form')
                ->livewireSubmitHandler('save')
                ->footer([Actions::make([Action::make('save')->submit('save')])]),
        ]);
    }

    public function save(): void
    {
        $data = $this->form->getState();
        $old = array_filter([
            'gems' => isset($data['old_gems']) && $data['old_gems'] !== '' ? (int) $data['old_gems'] : null,
            'coins' => isset($data['old_coins']) && $data['old_coins'] !== '' ? (int) $data['old_coins'] : null,
        ], fn ($v) => $v !== null);
        $value = ['item' => (string) $data['item'], 'oldPrice' => $old === [] ? null : $old];
        app(Settings::class)->put('featured', $value);
        app(ModerationService::class)->audit(Admin::user(), 'featured_offer', 'setting:featured', null, $value);
        Notification::make()->title('Featured offer saved')->success()->send();
    }
}
