<?php

namespace App\Filament\Resources\CheatFlags\Pages;

use App\Filament\Resources\CheatFlags\CheatFlagResource;
use Filament\Resources\Pages\ViewRecord;

class ViewCheatFlag extends ViewRecord
{
    protected static string $resource = CheatFlagResource::class;

    protected function getHeaderActions(): array
    {
        return [CheatFlagResource::reviewAction()];
    }
}
