<?php

namespace App\Filament\Resources\Items\Pages;

use App\Filament\Resources\Items\ItemResource;
use App\Filament\Support\Admin;
use App\Services\ModerationService;
use Filament\Resources\Pages\CreateRecord;

class CreateItem extends CreateRecord
{
    protected static string $resource = ItemResource::class;

    protected function afterCreate(): void
    {
        app(ModerationService::class)->audit(Admin::user(), 'item_create', $this->getRecord(), null);
    }
}
