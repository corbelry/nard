<?php

namespace App\Filament\Resources\Items;

use App\Filament\Resources\Items\Pages\CreateItem;
use App\Filament\Resources\Items\Pages\EditItem;
use App\Filament\Resources\Items\Pages\ListItems;
use App\Models\Item;
use BackedEnum;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;
use UnitEnum;

/**
 * Data-driven cosmetics (spec §8.6): price, availability and the data
 * JSON. Prices are hard currency or coins only; nothing here sells coins
 * (ADR-022).
 */
class ItemResource extends Resource
{
    protected static ?string $model = Item::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedSwatch;

    protected static string|UnitEnum|null $navigationGroup = 'Economy';

    protected static ?int $navigationSort = 1;

    public static function canDelete(Model $record): bool
    {
        return false;
    }

    public static function canDeleteAny(): bool
    {
        return false;
    }

    /** @return array<string, string> */
    private static function options(string $key): array
    {
        $values = array_map('strval', (array) config($key));

        return array_combine($values, $values);
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->columns(3)->components([
            TextInput::make('id')->required()->maxLength(64)->regex('/^[a-z_]+\.[a-z0-9_]+$/')
                ->unique(ignoreRecord: true)->disabledOn('edit'),
            Select::make('category')->required()->options(self::options('economy.item_categories'))->disabledOn('edit'),
            Select::make('rarity')->required()->options(self::options('economy.rarities')),
            TextInput::make('price_coins')->integer()->minValue(1)->helperText('Empty = not sold for coins'),
            TextInput::make('price_gems')->label('Price (Yaqut)')->integer()->minValue(1)->helperText('Empty = not sold for Yaqut'),
            TextInput::make('sort')->integer()->minValue(0)->default(0),
            Toggle::make('available')->default(true)->helperText('Shown in the store'),
            Toggle::make('is_default')->label('Owned by everyone'),
            TextInput::make('asset_url')->url()->maxLength(255),
            TextInput::make('asset_version')->integer()->minValue(1)->default(1),
            Textarea::make('data')->label('Data (JSON)')->required()->rows(12)->columnSpanFull()
                ->rule('json')
                ->formatStateUsing(fn ($state): string => is_string($state) ? $state
                    : (string) json_encode($state ?? new \stdClass, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES))
                ->dehydrateStateUsing(fn ($state): mixed => json_decode((string) $state, true)),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->defaultSort('sort')
            ->columns([
                TextColumn::make('id')->searchable(),
                TextColumn::make('category')->badge(),
                TextColumn::make('rarity'),
                TextColumn::make('price_coins')->placeholder('-')->sortable(),
                TextColumn::make('price_gems')->label('Yaqut')->placeholder('-')->sortable(),
                IconColumn::make('available')->boolean(),
                IconColumn::make('is_default')->boolean()->label('Default'),
                TextColumn::make('owners')->state(fn (Item $record): int => (int) $record->getConnection()->table('user_items')->where('item_id', $record->id)->count()),
            ])
            ->filters([
                SelectFilter::make('category')->options(self::options('economy.item_categories')),
                TernaryFilter::make('available'),
            ])
            ->recordActions([EditAction::make()]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ListItems::route('/'),
            'create' => CreateItem::route('/create'),
            'edit' => EditItem::route('/{record}/edit'),
        ];
    }
}
