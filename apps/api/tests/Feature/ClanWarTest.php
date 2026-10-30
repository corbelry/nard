<?php

namespace Tests\Feature;

use App\Models\Clan;
use App\Models\ClanMember;
use App\Models\ClanMessage;
use App\Models\ClanWar;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Testing\TestResponse;
use Symfony\Component\HttpFoundation\Response;
use Tests\TestCase;

class ClanWarTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Carbon::setTestNow('2026-11-02 12:00:00');
    }

    /** @return TestResponse<Response> */
    private function report(User $white, ?User $black, string $id, string $winner = 'white'): TestResponse
    {
        $body = (string) json_encode([
            'matchId' => $id, 'variant' => 'shortNard', 'matchLength' => 5, 'mode' => 'casual',
            'white' => ['userId' => (string) $white->id, 'name' => 'W', 'bot' => false],
            'black' => $black === null ? ['userId' => 'bot-1', 'name' => 'Bot', 'bot' => true]
                : ['userId' => (string) $black->id, 'name' => 'B', 'bot' => false],
            'winner' => $winner, 'whiteScore' => $winner === 'white' ? 5 : 3, 'blackScore' => $winner === 'black' ? 5 : 3,
            'reason' => 'completed',
            'games' => [['record' => [], 'winner' => $winner, 'kind' => 'single']],
            'startedAt' => now()->subHour()->getTimestampMs(), 'endedAt' => now()->getTimestampMs(),
        ]);

        return $this->call('POST', '/api/v1/internal/match-results', [], [], [], [
            'CONTENT_TYPE' => 'application/json', 'HTTP_ACCEPT' => 'application/json',
            'HTTP_X_NARD_SIGNATURE' => hash_hmac('sha256', $body, 'test-secret-test-secret-test-secret!'),
        ], $body);
    }

    /**
     * A clan with [size] members seen now.
     *
     * @return array{0: Clan, 1: array<int, User>}
     */
    private function clan(string $tag, int $size, int $xp = 0): array
    {
        $clan = Clan::query()->create([
            'name' => "Clan $tag", 'name_key' => strtolower("clan $tag"), 'tag' => $tag, 'language' => 'az', 'join_policy' => 'open',
            'emblem' => ['shape' => 'shield', 'symbol' => 'initials', 'color' => 'indigo', 'pattern' => 'none'],
            'xp' => $xp, 'level' => Clan::levelFor($xp),
        ]);
        $users = User::factory()->count($size)->create(['last_seen_at' => now()])->all();
        foreach ($users as $i => $user) {
            ClanMember::query()->create(['clan_id' => $clan->id, 'user_id' => $user->id, 'role' => $i === 0 ? 'leader' : 'member', 'joined_at' => now()]);
        }

        return [$clan, $users];
    }

    public function test_wars_pair_similar_clans_and_count_reported_matches(): void
    {
        config(['clans.war.max_matches' => 3]);
        [$a, [$a1, $a2]] = $this->clan('AAA', 2, 2600);
        [$b, [$b1]] = $this->clan('BBB', 2, 1200);
        [$c] = $this->clan('CCC', 2, 92000);   // level 15: too far above
        [$d] = $this->clan('DDD', 1);          // too small
        [$e] = $this->clan('EEE', 2);
        ClanMember::query()->where('clan_id', $e->id)->with('user')->get()
            ->each(fn (ClanMember $m) => $m->user->forceFill(['last_seen_at' => now()->subDays(8)])->save());   // inactive

        $this->assertSame(0, Artisan::call('clans:pair-wars'));
        $war = ClanWar::query()->sole();
        $this->assertSame([$a->id, $b->id, '2026-W45', 'live'], [$war->clan_a_id, $war->clan_b_id, $war->week, $war->status]);
        $this->assertSame('2026-11-02 00:00:00', $war->starts_at->toDateTimeString());
        $this->assertSame('2026-11-08 23:59:59', $war->ends_at->toDateTimeString());
        // Re-running in the same week pairs nobody twice.
        $this->assertSame(0, Artisan::call('clans:pair-wars'));
        $this->assertSame(1, ClanWar::query()->count());
        $this->assertSame('war_started', ClanMessage::query()->where('clan_id', $b->id)->value('event'));
        $this->assertNull($this->getWar($c, $a1));
        $this->assertNull($this->getWar($d, $a1));

        // A war win: +3 points, clan XP for the online win, chat event.
        $this->report($a1, $b1, 'w1')->assertCreated();
        $this->report($a1, $b1, 'w1')->assertCreated();
        $this->report($b1, $a2, 'w2', 'black')->assertCreated();
        // Same-clan and bot games count for nothing.
        $this->report($a1, $a2, 'w3')->assertCreated();
        $this->report($a1, null, 'w4')->assertCreated();
        $this->report($a1, $b1, 'w5', 'black')->assertCreated();
        $this->report($a1, $b1, 'w6')->assertCreated();   // over the 3-match cap
        $view = $this->getWar($a, $b1);
        $this->assertNotNull($view);
        $this->assertSame(['mine' => 6, 'theirs' => 3], $view['score']);
        $this->assertSame(3, $view['matchesCounted']);
        $this->assertSame('live', $view['status']);
        $this->assertSame(['w1', 'w2', 'w5'], array_column($view['matches'], 'matchId'));
        $this->assertSame([true, true, false], array_column($view['matches'], 'won'));
        $this->assertSame([5, 3], $view['matches'][0]['score']);
        $this->assertSame((string) $b->id, $view['opponent']['id']);
        $this->assertSame(['mine' => 3, 'theirs' => 6], $this->getWar($b, $b1)['score'] ?? null);
        // Online wins over humans from other clans: a 3 (w1, w2, w6), b 1 (w5).
        $this->assertSame(2600 + 30, $a->refresh()->xp);
        $this->assertSame(1200 + 10, $b->refresh()->xp);
        $this->assertSame(['userId' => (string) $a1->id, 'name' => $a1->name, 'points' => 3],
            ClanMessage::query()->where(['clan_id' => $a->id, 'event' => 'war_win'])->orderBy('id')->firstOrFail()->data);

        // Next Monday: last week's war closes, the winner gets clan XP.
        Carbon::setTestNow('2026-11-09 00:05:00');
        foreach ([$a1, $b1] as $u) {
            $u->forceFill(['last_seen_at' => now()])->save();
        }
        $this->assertSame(0, Artisan::call('clans:pair-wars'));
        $war->refresh();
        $this->assertSame(['finished', $a->id], [$war->status, $war->winner_clan_id]);
        $this->assertSame(2630 + 1000, $a->refresh()->xp);
        $this->assertSame(1210, $b->refresh()->xp);
        $this->assertSame(['result' => 'lost', 'mine' => 3, 'theirs' => 6],
            ClanMessage::query()->where(['clan_id' => $b->id, 'event' => 'war_ended'])->firstOrFail()->data);
        // A finished war keeps scoring nothing.
        $this->report($a1, $b1, 'w7')->assertCreated();
        $this->assertSame(6, $war->refresh()->score_a);
        $this->assertSame('2026-W46', ClanWar::query()->orderByDesc('id')->firstOrFail()->week);
    }

    /** @return array<string, mixed>|null */
    private function getWar(Clan $clan, User $viewer): ?array
    {
        /** @var array<string, mixed>|null */
        return $this->actingAs($viewer)->getJson("/api/v1/clans/{$clan->id}/war")->assertOk()->json('war');
    }

    public function test_leaderboard_ranks_by_clan_xp(): void
    {
        [$a, [$a1]] = $this->clan('AAA', 1, 500);
        [$b] = $this->clan('BBB', 1, 900);
        $this->actingAs($a1)->getJson('/api/v1/clans/leaderboard')->assertOk()
            ->assertJsonPath('entries.0.clan.id', (string) $b->id)->assertJsonPath('entries.0.points', 900)
            ->assertJsonPath('entries.1.rank', 2)->assertJsonPath('me.rank', 2)->assertJsonPath('me.clan.tag', $a->tag);
    }
}
