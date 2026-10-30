<?php

namespace App\Filament\Resources\GameMatches\Pages;

use App\Filament\Resources\GameMatches\GameMatchResource;
use Filament\Resources\Pages\ListRecords;

class ListGameMatches extends ListRecords
{
    protected static string $resource = GameMatchResource::class;
}
