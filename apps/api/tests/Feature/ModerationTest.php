<?php

namespace Tests\Feature;

use App\Models\AdminAction;
use App\Models\Clan;
use App\Models\ClanMember;
use App\Models\Puzzle;
use App\Models\Report;
use App\Models\Season;
use App\Models\User;
use App\Services\AccountBanned;
use App\Services\ModerationService;
use App\Services\SeasonService;
use App\Services\Settings;
use App\Services\TicketSigner;
use App\Services\WalletService;
use Database\Seeders\ItemCatalogSeeder;
use Database\Seeders\PuzzleSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;
use Tests\TestCase;

/** Bans, mutes, reports, grants and the other admin writes (ADR-042). */
class ModerationTest extends TestCase
{
    use RefreshDatabase;

    private function admin(): User
    {
        return User::factory()->create(['name' => 'Mod'])->forceFill(['is_admin' => true]);
    }

    private function moderation(): ModerationService
    {
        return app(ModerationService::class);
    }

    /** @return array<string, mixed> */
    private static function ticketPayload(string $ticket): array
    {
        $body = explode('.', $ticket)[0];

        return (array) json_decode((string) base64_decode(strtr($body, '-_', '+/')), true);
    }

    public function test_banned_players_get_403_with_the_end_of_the_ban(): void
    {
        $user = User::factory()->create();
        $this->actingAs($user)->getJson('/api/v1/me')->assertOk();
        $until = now()->addDays(3)->startOfSecond();
        $this->moderation()->ban($user, $until, 'abuse', $this->admin());
        $this->actingAs($this->reload($user))->getJson('/api/v1/me')
            ->assertForbidden()->assertExactJson(['code' => 'banned', 'until' => $until->toIso8601String()]);
        $this->actingAs($this->reload($user))->postJson('/api/v1/game/ticket')->assertForbidden()->assertJsonPath('code', 'banned');
        // Permanent: until is null.
        $this->moderation()->ban($user, null, 'cheating', null);
        $this->actingAs($this->reload($user))->getJson('/api/v1/friends')
            ->assertForbidden()->assertExactJson(['code' => 'banned', 'until' => null]);
        // Lifted, or over: back in.
        $this->moderation()->unban($user, 'appeal accepted', null);
        $this->actingAs($this->reload($user))->getJson('/api/v1/me')->assertOk();
        $this->moderation()->ban($user, now()->addHour(), 'abuse', null);
        $this->travel(2)->hours();
        $this->actingAs($this->reload($user))->getJson('/api/v1/me')->assertOk();
        $this->assertSame(['ban', 'ban', 'unban', 'ban'], AdminAction::query()->orderBy('id')->pluck('action')->all());
    }

    public function test_banned_players_cannot_sign_in_or_get_a_game_ticket(): void
    {
        $user = User::factory()->create(['device_id' => 'device-12345']);
        $this->moderation()->ban($user, null, 'cheating', null);
        $this->postJson('/api/v1/auth/guest', ['deviceId' => 'device-12345'])
            ->assertForbidden()->assertJsonPath('code', 'banned');
        $this->assertSame(0, $user->tokens()->count());
        $this->expectException(AccountBanned::class);
        app(TicketSigner::class)->sign($this->reload($user), now()->getTimestamp());
    }

    public function test_muted_players_cannot_post_clan_chat_and_their_ticket_says_so(): void
    {
        $user = User::factory()->create();
        $clan = (new Clan)->forceFill([
            'name' => 'Odlar', 'name_key' => Clan::nameKey('Odlar'), 'tag' => 'ODL',
            'emblem' => ['shape' => 'shield', 'symbol' => 'star', 'color' => 'gold', 'pattern' => 'none'],
            'language' => 'az', 'join_policy' => 'open',
        ]);
        $clan->save();
        ClanMember::query()->create(['clan_id' => $clan->id, 'user_id' => $user->id, 'role' => 'leader', 'joined_at' => now()]);
        $this->actingAs($user)->postJson("/api/v1/clans/{$clan->id}/messages", ['text' => 'Salam'])->assertCreated();
        $ticket = $this->actingAs($user)->postJson('/api/v1/game/ticket')->assertOk()->json('ticket');
        $this->assertArrayNotHasKey('muted', self::ticketPayload($ticket));

        $until = now()->addDay()->startOfSecond();
        $this->moderation()->mute($user, $until, 'spam', null);
        $this->actingAs($this->reload($user))->postJson("/api/v1/clans/{$clan->id}/messages", ['text' => 'Salam'])
            ->assertForbidden()->assertJsonPath('code', 'muted')->assertJsonPath('until', $until->toIso8601String());
        $ticket = $this->actingAs($this->reload($user))->postJson('/api/v1/game/ticket')->assertOk()->json('ticket');
        $this->assertTrue(self::ticketPayload($ticket)['muted']);

        $this->moderation()->unmute($user, null);
        $this->actingAs($this->reload($user))->postJson("/api/v1/clans/{$clan->id}/messages", ['text' => 'Yenə'])->assertCreated();
    }

    public function test_the_report_queue_closes_with_dismiss_warn_mute_or_ban(): void
    {
        $admin = $this->admin();
        $reporter = User::factory()->create();
        $target = User::factory()->create(['locale' => 'en']);
        $reports = [];
        foreach (['other', 'abuse', 'abuse', 'cheating'] as $reason) {
            $this->actingAs($reporter)->postJson('/api/v1/reports', ['userId' => (string) $target->id, 'reason' => $reason])->assertCreated();
            $reports[] = Report::query()->latest('id')->firstOrFail();
        }
        $this->moderation()->handleReport($reports[0], 'dismiss', null, null, $admin);
        $this->assertSame(['reviewed', 'dismiss', $admin->id], [$reports[0]->status, $reports[0]->action, $reports[0]->handled_by]);
        $this->assertFalse($this->reload($target)->isBanned());

        $this->moderation()->handleReport($reports[1], 'warn', 'Be kind in chat', null, $admin);
        $inbox = $this->actingAs($target)->getJson('/api/v1/notifications')->assertOk()->json('notifications');
        $this->assertSame('moderation_warning', $inbox[0]['type']);
        $this->assertSame('Be kind in chat', $inbox[0]['data']['reason']);

        $this->moderation()->handleReport($reports[2], 'mute', null, 24, $admin);
        $this->assertTrue($this->reload($target)->isMuted());

        $this->moderation()->handleReport($reports[3], 'ban', 'Engine use confirmed', null, $admin);
        $fresh = $this->reload($target);
        $this->assertTrue($fresh->isBanned());
        $this->assertNull($fresh->banned_until);
        $this->assertSame('Engine use confirmed', $fresh->ban_reason);
        $this->assertSame(['reviewed', 'actioned', 'actioned', 'actioned'], Report::query()->orderBy('id')->pluck('status')->all());
        $this->assertSame(4, AdminAction::query()->where('action', 'like', 'report_%')->count());
    }

    public function test_admin_grants_use_the_admin_ledger_reason_and_need_a_note(): void
    {
        $admin = $this->admin();
        $user = User::factory()->create();
        $balance = $this->moderation()->grant($user, 'coins', 750, 'Lost match compensation', $admin);
        $this->assertSame(750, $balance);
        $row = DB::table('wallet_transactions')->where('user_id', $user->id)->sole();
        $this->assertSame(['coins', 750, 'admin', "admin:{$admin->id}"], [$row->currency, (int) $row->amount, $row->reason, $row->reference]);
        $this->assertSame(750, app(WalletService::class)->balances($user)['coins']);
        $audit = AdminAction::query()->where('action', 'grant')->sole();
        $this->assertSame('Lost match compensation', $audit->note);
        $this->assertSame(['currency' => 'coins', 'amount' => 750], array_intersect_key((array) $audit->data, ['currency' => 0, 'amount' => 0]));

        foreach ([['coins', 10, '  '], ['coins', 0, 'x'], ['coins', 100_001, 'x'], ['gold', 10, 'x']] as [$currency, $amount, $note]) {
            try {
                $this->moderation()->grant($user, $currency, $amount, $note, $admin);
                $this->fail("$currency $amount '$note' should be refused");
            } catch (InvalidArgumentException) {
                // expected
            }
        }
        $this->assertSame(1, DB::table('wallet_transactions')->count());
    }

    public function test_nickname_reset_clan_rename_and_disband_are_audited(): void
    {
        $admin = $this->admin();
        $user = User::factory()->create(['name' => 'BadName', 'locale' => 'en']);
        $name = $this->moderation()->resetName($user, $admin);
        $this->assertNotSame('BadName', $name);
        $this->assertSame($name, $this->reload($user)->name);

        $clan = (new Clan)->forceFill([
            'name' => 'Rude', 'name_key' => Clan::nameKey('Rude'), 'tag' => 'RUD',
            'emblem' => ['shape' => 'shield', 'symbol' => 'star', 'color' => 'gold', 'pattern' => 'none'],
            'language' => 'az', 'join_policy' => 'open',
        ]);
        $clan->save();
        $this->moderation()->renameClan($clan, 'Clean Name', $admin);
        $this->assertSame('Clean Name', $this->reload($clan)->name);
        $this->moderation()->disbandClan($clan, 'offensive', $admin);
        $this->assertNull(Clan::query()->find($clan->id));
        $this->assertSame(['reset_name', 'clan_rename', 'clan_disband'], AdminAction::query()->orderBy('id')->pluck('action')->all());
    }

    public function test_a_season_can_be_ended_early(): void
    {
        $seasons = app(SeasonService::class);
        $season = $seasons->current();
        $this->assertTrue($seasons->endEarly($season));
        $this->assertSame('finished', $this->reload($season)->status);
        $next = Season::query()->where('status', 'active')->sole();
        $this->assertSame($season->number + 1, $next->number);
        $this->assertFalse($seasons->endEarly($this->reload($season)));
    }

    public function test_disabled_puzzles_are_not_served(): void
    {
        $this->seed(PuzzleSeeder::class);
        Puzzle::query()->where('id', '!=', 'sn-001')->update(['enabled' => false]);
        $user = User::factory()->create();
        $this->actingAs($user)->getJson('/api/v1/puzzles/next')->assertOk()->assertJsonPath('puzzle.id', 'sn-001');
        $this->actingAs($user)->getJson('/api/v1/puzzles/daily')->assertOk()->assertJsonPath('puzzle.id', 'sn-001');
    }

    public function test_the_featured_offer_comes_from_the_admin_setting(): void
    {
        $this->seed(ItemCatalogSeeder::class);
        $user = User::factory()->create();
        app(Settings::class)->put('featured', ['item' => 'board.dark', 'oldPrice' => ['coins' => 1200]]);
        $offers = $this->actingAs($user)->getJson('/api/v1/store/offers')->assertOk()->json();
        $this->assertSame('board.dark', $offers['featured']['item']['id']);
        $this->assertSame(['coins' => 1200], $offers['featured']['oldPrice']);
    }
}
