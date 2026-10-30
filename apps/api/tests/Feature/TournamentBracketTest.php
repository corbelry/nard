<?php

namespace Tests\Feature;

use App\Models\GameMatch;
use App\Models\Tournament;
use App\Models\TournamentEntry;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Tests\TournamentTestCase;

class TournamentBracketTest extends TournamentTestCase
{
    /**
     * @param  array<string, mixed>  $attributes
     * @return array{0: Tournament, 1: array<int, User>}
     */
    private function started(int $players, array $attributes = []): array
    {
        $t = $this->tournament($attributes);
        $users = [];
        for ($i = 0; $i < $players; $i++) {
            // Descending ratings: users[0] is seed 1.
            $users[] = $this->player(0, 2000 - $i * 50, $t->variant);
        }
        $this->enter($t, $users);
        $this->travel(61)->minutes();
        $this->command('tournaments:tick');

        return [$t->refresh(), $users];
    }

    private function place(Tournament $t, User $user): ?int
    {
        return TournamentEntry::query()->where(['tournament_id' => $t->id, 'user_id' => $user->id])->value('place');
    }

    public function test_knockout_advances_from_signed_results_and_pays_prizes_once(): void
    {
        [$t, $u] = $this->started(4, ['prizes' => [
            ['from' => 1, 'to' => 1, 'coins' => 5000, 'items' => ['title.friday_champion', 'board.xatam', 'missing.item']],
            ['from' => 2, 'to' => 2, 'coins' => 2000, 'items' => []],
            ['from' => 3, 'to' => 4, 'coins' => 700, 'items' => []],
        ], 'prize_fund' => 8400]);
        $this->assertSame(['running', 2, 1], [$t->status, $t->total_rounds, $t->current_round]);
        [$m1, $m2] = $this->pairings($t, 1)->all();
        // Seeds 1 v 4 and 2 v 3.
        $this->assertSame([$u[0]->id, $u[3]->id, $u[1]->id, $u[2]->id], [$m1->white_user_id, $m1->black_user_id, $m2->white_user_id, $m2->black_user_id]);
        $this->assertPushed($m1->match_id, $m2->match_id);

        // Results must be signed.
        $this->signed('/api/v1/internal/tournament-no-shows', '{}')->assertUnprocessable();
        $this->call('POST', '/api/v1/internal/tournament-no-shows', [], [], [], ['CONTENT_TYPE' => 'application/json'], '{}')->assertUnauthorized();

        $this->report($m1, 'black')->assertCreated()->assertJsonPath('white', null);
        $this->assertSame(1, $t->refresh()->current_round);
        // Seed 2 wins by walkover (the game server's no-show timer).
        $this->report($m2, 'white', 'walkover')->assertCreated();
        $t->refresh();
        $this->assertSame(2, $t->current_round);
        $final = $this->pairings($t, 2)->sole();
        $this->assertSame([$u[3]->id, $u[1]->id], [$final->white_user_id, $final->black_user_id]);
        $this->assertSame('pushed', $final->status);
        $this->assertPushed($final->match_id);

        // Tournament matches are unrated; walkovers pay no match rewards.
        $this->assertSame(2000 - 3 * 50, $u[3]->ratingFor('shortNard')->rating);
        $this->assertSame(0, $this->coins($u[1]));
        $this->assertSame('walkover', GameMatch::query()->findOrFail($m2->match_id)->reason);
        $this->assertSame($t->id, GameMatch::query()->findOrFail($m2->match_id)->tournament_id);

        $this->actingAs($u[1])->getJson("/api/v1/tournaments/{$t->id}")->assertOk()
            ->assertJsonPath('tournament.myStatus', 'playing')
            ->assertJsonPath('tournament.rounds.0.stage', '1/2')
            ->assertJsonPath('tournament.rounds.0.matches.1.status', 'walkover')
            ->assertJsonPath('tournament.rounds.0.matches.0.winnerId', (string) $u[3]->id)
            ->assertJsonPath('tournament.rounds.0.matches.0.score', [1, 3])
            ->assertJsonPath('tournament.rounds.1.stage', 'final')
            ->assertJsonPath('tournament.myNextMatch.matchId', $final->match_id)
            ->assertJsonPath('tournament.myNextMatch.opponent.id', (string) $u[3]->id);
        $this->actingAs($u[0])->getJson("/api/v1/tournaments/{$t->id}")->assertJsonPath('tournament.myStatus', 'eliminated');

        $this->report($final, 'white')->assertCreated();
        $t->refresh();
        $this->assertSame('finished', $t->status);
        $this->assertSame([1, 2, 3, 3], [$this->place($t, $u[3]), $this->place($t, $u[1]), $this->place($t, $u[0]), $this->place($t, $u[2])]);
        $this->assertSame([5000, 2000, 700, 700], array_map(fn (User $x) => $this->prizeCoins($x), [$u[3], $u[1], $u[0], $u[2]]));
        $items = DB::table('user_items')->where(['user_id' => $u[3]->id, 'source' => 'tournament'])->pluck('item_id')->sort()->values()->all();
        $this->assertSame(['board.xatam', 'title.friday_champion'], $items);

        // A repeated report changes nothing.
        $this->report($final, 'white')->assertCreated();
        $this->assertSame(5000, $this->prizeCoins($u[3]));
        $this->actingAs($u[3])->getJson('/api/v1/tournaments?tab=finished')->assertOk()
            ->assertJsonPath('tournaments.0.myStatus', 'champion')
            ->assertJsonPath('tournaments.0.myPlace', 1);
        $this->actingAs($u[3])->getJson('/api/v1/me/matches')->assertOk()->assertJsonPath('matches.0.tournamentId', (string) $t->id);
    }

    public function test_byes_and_a_double_no_show(): void
    {
        [$t, $u] = $this->started(3);
        [$bye, $m] = $this->pairings($t, 1)->all();
        // Seed 1 has a bye; it is never pushed.
        $this->assertSame([true, 'finished', $u[0]->id, null], [$bye->bye, $bye->status, $bye->white_user_id, $bye->black_user_id]);
        $this->assertSame([$u[1]->id, $u[2]->id], [$m->white_user_id, $m->black_user_id]);
        $this->assertCount(1, $this->posted('/internal/tournament-matches'));

        // Nobody came: both are out and seed 1 takes the final by a bye.
        $this->noShow($m)->assertCreated();
        $this->noShow($m)->assertCreated();
        $t->refresh();
        $this->assertSame('finished', $t->status);
        $final = $this->pairings($t, 2)->sole();
        $this->assertSame([true, $u[0]->id], [$final->bye, $final->winner_user_id]);
        // Both lost their semi-final: shared third place.
        $this->assertSame([1, 3, 3], [$this->place($t, $u[0]), $this->place($t, $u[1]), $this->place($t, $u[2])]);
        $this->assertSame('none', $m->refresh()->result);
        $this->assertTrue($m->walkover);
    }

    public function test_unknown_or_foreign_results_are_ignored(): void
    {
        [$t, $u] = $this->started(2);
        $p = $this->pairings($t, 1)->sole();
        $other = $this->tournament();
        $body = (string) json_encode(['matchId' => $p->match_id, 'tournamentId' => (string) $other->id, 'endedAt' => 1]);
        $this->signed('/api/v1/internal/tournament-no-shows', $body)->assertCreated();
        $this->assertSame('pushed', $p->refresh()->status);
        // Mode tournament needs a tournament id.
        $this->signed('/api/v1/internal/match-results', (string) json_encode([
            'matchId' => 'x', 'variant' => 'shortNard', 'matchLength' => 3, 'mode' => 'tournament',
            'white' => ['userId' => '1', 'name' => 'W', 'bot' => false], 'black' => ['userId' => '2', 'name' => 'B', 'bot' => false],
            'winner' => 'white', 'whiteScore' => 3, 'blackScore' => 0, 'reason' => 'walkover', 'games' => [],
            'startedAt' => 1, 'endedAt' => 1,
        ]))->assertJsonValidationErrors(['tournamentId']);
        $this->report($p, 'black')->assertCreated();
        $this->assertSame('finished', $t->refresh()->status);
        $this->assertSame(1, $this->place($t, $u[1]));
    }

    public function test_swiss_pairs_by_score_and_ranks_by_buchholz(): void
    {
        [$t, $u] = $this->started(4, ['format' => 'swiss', 'swiss_rounds' => 3, 'variant' => 'longNard',
            'prizes' => [['from' => 1, 'to' => 1, 'coins' => 900, 'items' => []]], 'prize_fund' => 900]);
        // 4 players: at most 3 rounds without rematches.
        $this->assertSame(3, $t->total_rounds);
        [$a, $b] = $this->pairings($t, 1)->all();
        $this->assertSame([$u[0]->id, $u[1]->id, $u[2]->id, $u[3]->id], [$a->white_user_id, $a->black_user_id, $b->white_user_id, $b->black_user_id]);
        $this->report($a, 'white');
        $this->report($b, 'black');
        // Round 2: 1-pointers meet (u0 v u3), 0-pointers meet (u1 v u2).
        [$c, $d] = $this->pairings($t, 2)->all();
        $this->assertSame([$u[0]->id, $u[3]->id, $u[1]->id, $u[2]->id], [$c->white_user_id, $c->black_user_id, $d->white_user_id, $d->black_user_id]);
        $this->report($c, 'black');
        $this->report($d, 'white');
        // Round 3: no rematches left but u0 v u2 and u3 v u1.
        $pairs = $this->pairings($t, 3)->map(fn ($p) => [$p->white_user_id, $p->black_user_id])->all();
        $this->assertSame([[$u[3]->id, $u[1]->id], [$u[0]->id, $u[2]->id]], $pairs);
        $standings = $this->actingAs($u[0])->getJson("/api/v1/tournaments/{$t->id}")->assertOk()->json('tournament.standings');
        $this->assertSame([2, 1, 1, 0], array_column($standings, 'points'));
        $this->assertSame((string) $u[3]->id, $standings[0]['user']['id']);
        // u0 (met u1: 1, u3: 2) and u1 (met u0: 1, u2: 0) both have 1 point.
        $this->assertSame([(string) $u[0]->id, 3], [$standings[1]['user']['id'], $standings[1]['buchholz']]);
        [$e, $f] = $this->pairings($t, 3)->all();
        $this->report($e, 'black');
        $this->report($f, 'white');
        $t->refresh();
        $this->assertSame('finished', $t->status);
        // u3 2, u0 2, u1 2, u2 0 points → Buchholz decides.
        $buchholz = TournamentEntry::query()->where('tournament_id', $t->id)->pluck('buchholz', 'user_id')->all();
        $this->assertSame([4, 4, 4, 6], [$buchholz[$u[0]->id], $buchholz[$u[1]->id], $buchholz[$u[3]->id], $buchholz[$u[2]->id]]);
        // Equal Buchholz: the higher rating first.
        $this->assertSame([1, 2, 3, 4], [$this->place($t, $u[0]), $this->place($t, $u[1]), $this->place($t, $u[3]), $this->place($t, $u[2])]);
        $this->assertSame(900, $this->prizeCoins($u[0]));
    }

    public function test_round_robin_plays_everyone_with_byes(): void
    {
        [$t, $u] = $this->started(3, ['format' => 'round_robin']);
        $this->assertSame(3, $t->total_rounds);
        $met = [];
        for ($round = 1; $round <= 3; $round++) {
            $this->assertSame($round, $t->refresh()->current_round);
            foreach ($this->pairings($t, $round) as $p) {
                if ($p->bye) {
                    continue;
                }
                $met[] = [min($p->white_user_id, $p->black_user_id), max($p->white_user_id, $p->black_user_id)];
                // The higher seed (lower id here) always wins.
                $this->report($p, $p->white_user_id < $p->black_user_id ? 'white' : 'black')->assertCreated();
            }
        }
        sort($met);
        $this->assertSame([[$u[0]->id, $u[1]->id], [$u[0]->id, $u[2]->id], [$u[1]->id, $u[2]->id]], $met);
        $this->assertSame('finished', $t->refresh()->status);
        $this->assertSame([1, 2, 3], array_map(fn (User $x) => $this->place($t, $x), $u));
        $this->assertSame([2, 1, 0], TournamentEntry::query()->where('tournament_id', $t->id)->orderBy('place')->pluck('points')->all());
    }
}
