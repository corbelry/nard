<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\Notifier;
use App\Services\TournamentService;
use Illuminate\Support\Facades\DB;
use Tests\TournamentTestCase;

/** Tournament events reach open sockets: rows and refreshes (ADR-049). */
class LiveTournamentTest extends TournamentTestCase
{
    /** @return list<string> tournament ids of the refresh pushes for [user] */
    private function refreshes(User $user): array
    {
        $ids = [];
        foreach ($this->posted('/internal/tournament-updated') as $push) {
            if (in_array((string) $user->id, (array) $push['userIds'], true)) {
                $ids[] = (string) $push['tournamentId'];
            }
        }

        return $ids;
    }

    /** @return list<string> notification types pushed live to [user] */
    private function liveTypes(User $user): array
    {
        $types = [];
        foreach ($this->posted('/internal/notify') as $push) {
            foreach ((array) $push['notifications'] as $item) {
                if ($item['userId'] === (string) $user->id) {
                    $types[] = $item['notification']['type'];
                }
            }
        }

        return $types;
    }

    public function test_entrants_get_a_refresh_for_entries_rounds_results_and_the_end(): void
    {
        $t = $this->tournament(['starts_at' => now()->addMinutes(5)]);
        $u = [$this->player(rating: 2000), $this->player(rating: 1900), $this->player(rating: 1800), $this->player(rating: 1700)];
        $this->enter($t, $u);
        // Each entry refreshes the entrants so far.
        $this->assertSame([(string) $t->id, (string) $t->id, (string) $t->id, (string) $t->id], $this->refreshes($u[0]));
        $this->assertSame([(string) $t->id], $this->refreshes($u[3]));

        $this->travel(5)->minutes();
        $this->command('tournaments:tick');
        $this->assertCount(2, $this->refreshes($u[3]));
        [$m1, $m2] = $this->pairings($t, 1)->all();
        $this->report($m1, 'white')->assertCreated();
        $this->report($m2, 'black')->assertCreated();
        $this->assertCount(4, $this->refreshes($u[3]), 'the loser still sees the bracket move');
        $this->report($this->pairings($t, 2)->sole(), 'white')->assertCreated();
        $this->assertCount(8, $this->refreshes($u[0]));
        $this->assertSame('finished', $t->refresh()->status);

        // The same events arrive live as rows: started, round 2, champion.
        $this->assertSame(['tournament_started', 'tournament_round', 'tournament_won'], $this->liveTypes($u[0]));
        $this->assertSame(['tournament_started', 'tournament_eliminated'], $this->liveTypes($u[3]));
    }

    public function test_eliminated_players_learn_their_place(): void
    {
        $t = $this->tournament(['starts_at' => now()]);
        $u = [$this->player(rating: 2000), $this->player(rating: 1900), $this->player(rating: 1800), $this->player(rating: 1700)];
        $this->enter($t, $u);
        $this->command('tournaments:tick');
        [$m1, $m2] = $this->pairings($t, 1)->all();
        $this->report($m1, 'white')->assertCreated();   // seed 4 out in the semi-final
        $this->report($m2, 'white')->assertCreated();   // seed 3 out
        $this->report($this->pairings($t, 2)->sole(), 'black')->assertCreated();   // seed 1 loses the final
        $place = fn (User $user): ?int => json_decode((string) DB::table('notifications')
            ->where(['user_id' => $user->id, 'type' => 'tournament_eliminated'])->value('data'), true)['place'] ?? null;
        $this->assertSame([2, 3, 3], [$place($u[0]), $place($u[2]), $place($u[3])]);
        $this->assertSame($u[1]->id, (int) $t->entries()->where('place', 1)->value('user_id'));
        $row = DB::table('notifications')->where(['user_id' => $u[3]->id, 'type' => 'tournament_eliminated'])->sole();
        $this->assertSame('Test Kuboku · Raund 1, yerin: 3. Növbəti turnirdə uğurlar!', app(Notifier::class)->copy($row, 'az')[1]);
    }

    public function test_a_cancelled_tournament_tells_every_entrant_what_was_refunded(): void
    {
        $t = $this->tournament(['starts_at' => now()->addMinutes(5), 'entry_coins' => 100, 'min_players' => 3]);
        $u = [$this->player(coins: 500), $this->player(coins: 500)];
        $this->enter($t, $u);
        $this->travel(5)->minutes();
        $this->command('tournaments:tick');
        $this->assertSame(['cancelled', 'not_enough_players'], [$t->refresh()->status, $t->cancel_reason]);

        foreach ($u as $user) {
            $this->assertSame(500, $this->coins($user));
            $data = json_decode((string) DB::table('notifications')
                ->where(['user_id' => $user->id, 'type' => 'tournament_cancelled'])->value('data'), true);
            $this->assertSame([(string) $t->id, 'not_enough_players', 100], [$data['tournamentId'], $data['reason'], $data['refund']]);
            $this->assertSame(['tournament_cancelled'], $this->liveTypes($user));
            $this->assertContains((string) $t->id, $this->refreshes($user));
        }
        $this->assertSame('tournament_start', Notifier::category('tournament_cancelled'));
        $row = DB::table('notifications')->where(['user_id' => $u[0]->id, 'type' => 'tournament_cancelled'])->sole();
        $this->assertSame(['Tournament cancelled', 'Test Cup was cancelled. 100 coins were refunded.'], app(Notifier::class)->copy($row, 'en'));
    }

    public function test_an_organiser_cancelling_a_free_private_tournament_is_not_told_about_it(): void
    {
        $organizer = $this->player();
        $guest = $this->player();
        $service = app(TournamentService::class);
        $t = $service->createPrivate($organizer, [
            'name' => 'Dostlar', 'variant' => 'shortNard', 'matchLength' => 3, 'size' => 4, 'startsAt' => null,
        ]);
        $service->register($t, $guest, null, $t->invite_code);
        $service->cancelByOrganizer($t, $organizer);

        $this->assertSame([], $this->liveTypes($organizer));
        $this->assertSame(['tournament_cancelled'], $this->liveTypes($guest));
        $row = DB::table('notifications')->where(['user_id' => $guest->id, 'type' => 'tournament_cancelled'])->sole();
        $this->assertSame(0, json_decode((string) $row->data, true)['refund']);
        $this->assertSame('Dostlar ləğv edildi.', app(Notifier::class)->copy($row, 'az')[1]);
    }
}
