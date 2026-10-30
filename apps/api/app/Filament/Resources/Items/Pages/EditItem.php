<?php

namespace App\Filament\Resources\Items\Pages;

use App\Filament\Resources\Items\ItemResource;
use App\Filament\Support\Admin;
use App\Services\ModerationService;
use Filament\Resources\Pages\EditRecord;

class EditItem extends EditRecord
{
    protected static string $resource = ItemResource::class;

    protected function afterSave(): void
    {
        $changes = $this->getRecord()->getChanges();
        unset($changes['updated_at']);
        app(ModerationService::class)->audit(Admin::user(), 'item_edit', $this->getRecord(), null, $changes);
    }
}
