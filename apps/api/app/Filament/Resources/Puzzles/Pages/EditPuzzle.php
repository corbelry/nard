<?php

namespace App\Filament\Resources\Puzzles\Pages;

use App\Filament\Resources\Puzzles\PuzzleResource;
use App\Filament\Support\Admin;
use App\Services\ModerationService;
use Filament\Resources\Pages\EditRecord;

class EditPuzzle extends EditRecord
{
    protected static string $resource = PuzzleResource::class;

    protected function afterSave(): void
    {
        app(ModerationService::class)->audit(Admin::user(), 'puzzle_edit', $this->getRecord(), null, $this->getRecord()->getChanges());
    }
}
