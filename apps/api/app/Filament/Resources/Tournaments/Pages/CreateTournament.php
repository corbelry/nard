<?php

namespace App\Filament\Resources\Tournaments\Pages;

use App\Filament\Resources\Tournaments\TournamentResource;
use App\Filament\Support\Admin;
use App\Services\ModerationService;
use App\Services\PairingEngine;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Validation\ValidationException;

/** A public scheduled tournament; `tournaments:tick` starts it at starts_at. */
class CreateTournament extends CreateRecord
{
    protected static string $resource = TournamentResource::class;

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $prizes = [];
        foreach ((array) ($data['prizes'] ?? []) as $p) {
            $p = (array) $p;
            $from = (int) $p['from'];
            $to = (int) $p['to'];
            if ($to < $from || $to > (int) $data['size']) {
                throw ValidationException::withMessages(['data.prizes' => 'Each prize needs from ≤ to ≤ size.']);
            }
            $prizes[] = ['from' => $from, 'to' => $to, 'coins' => (int) $p['coins'], 'items' => array_values(array_map('strval', (array) ($p['items'] ?? [])))];
        }
        if ((int) $data['min_players'] > (int) $data['size']) {
            throw ValidationException::withMessages(['data.min_players' => 'At most the size.']);
        }

        return [
            ...$data,
            'name' => array_filter((array) $data['name'], fn ($v) => is_string($v) && $v !== ''),
            'kind' => 'scheduled',
            'status' => 'registering',
            'is_private' => false,
            'prizes' => $prizes,
            'prize_fund' => PairingEngine::fund($prizes),
            'swiss_rounds' => $data['format'] === 'swiss' ? (int) $data['swiss_rounds'] : null,
        ];
    }

    protected function afterCreate(): void
    {
        app(ModerationService::class)->audit(Admin::user(), 'tournament_create', $this->getRecord(), null);
    }
}
