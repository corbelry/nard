<?php

namespace Tests\Feature;

use App\Filament\Resources\Reports\Pages\ListReports;
use App\Filament\Resources\Users\Pages\ViewUser;
use App\Models\CheatFlag;
use App\Models\GameMatch;
use App\Models\Report;
use App\Models\User;
use App\Services\SeasonService;
use Database\Seeders\ItemCatalogSeeder;
use Database\Seeders\PuzzleSeeder;
use Filament\Actions\Testing\TestAction;
use Filament\Auth\Pages\Login;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Livewire\Livewire;
use Tests\TestCase;

/** Filament admin panel at /admin (spec §8.13, ADR-042). */
class AdminPanelTest extends TestCase
{
    use RefreshDatabase;

    private function admin(): User
    {
        $admin = User::factory()->create(['name' => 'Mod']);
        // Admins have set up an authenticator app (MFA is required).
        $admin->forceFill(['is_admin' => true, 'app_authentication_secret' => 'JBSWY3DPEHPK3PXP'])->save();

        return $admin;
    }

    public function test_only_admins_reach_the_panel(): void
    {
        $this->get('/admin/login')->assertOk()->assertSee('Sign in');
        $this->get('/admin')->assertRedirect('/admin/login');
        $player = User::factory()->create();
        $this->actingAs($player)->get('/admin')->assertForbidden();
        $this->actingAs($player)->get('/admin/users')->assertForbidden();
        // A mobile bearer token does not open the panel.
        $token = $player->createToken('guest')->plainTextToken;
        $this->app['auth']->forgetGuards();
        $this->withToken($token)->get('/admin/users')->assertRedirect('/admin/login');

        // An admin without an authenticator app must set one up first.
        $fresh = User::factory()->create();
        $fresh->forceFill(['is_admin' => true])->save();
        $this->actingAs($fresh)->get('/admin')->assertRedirectContains('/admin/multi-factor-authentication');
        $this->actingAs($fresh)->get('/admin/multi-factor-authentication/set-up')->assertOk();

        $admin = $this->admin();
        $this->actingAs($admin)->get('/admin')->assertOk();
        $this->assertNotSame('JBSWY3DPEHPK3PXP', $admin->getRawOriginal('app_authentication_secret'));
        $admin->forceFill(['banned_at' => now()])->save();
        $this->actingAs($admin)->get('/admin')->assertForbidden();
    }

    public function test_the_panel_login_accepts_admins_only(): void
    {
        $this->runCommand('admin:create', ['email' => 'mod@example.com', '--password' => 'long-enough-password'])->assertSuccessful();
        $player = User::factory()->create(['email' => 'player@example.com', 'password' => 'long-enough-password']);
        Livewire::test(Login::class)
            ->fillForm(['email' => 'player@example.com', 'password' => 'long-enough-password'])
            ->call('authenticate')
            ->assertHasFormErrors(['email']);
        $this->assertGuest('web');
        Livewire::test(Login::class)
            ->fillForm(['email' => 'mod@example.com', 'password' => 'wrong-password-123'])
            ->call('authenticate')
            ->assertHasFormErrors(['email']);
        Livewire::test(Login::class)
            ->fillForm(['email' => 'mod@example.com', 'password' => 'long-enough-password'])
            ->call('authenticate')
            ->assertHasNoFormErrors();
        $this->assertAuthenticatedAs(User::query()->where('email', 'mod@example.com')->sole(), 'web');
        $this->assertNotSame($player->id, auth('web')->id());
    }

    public function test_every_admin_page_renders(): void
    {
        $this->seed(ItemCatalogSeeder::class);
        $this->seed(PuzzleSeeder::class);
        app(SeasonService::class)->current();
        $admin = $this->admin();
        $player = User::factory()->create();
        $match = GameMatch::query()->create([
            'id' => 'm-admin-1', 'variant' => 'shortNard', 'match_length' => 1, 'mode' => 'ranked',
            'white_user_id' => $player->id, 'black_user_id' => $admin->id, 'white_name' => $player->name, 'black_name' => 'Mod',
            'winner' => 'white', 'white_score' => 1, 'black_score' => 0, 'reason' => 'completed',
            'games' => [['record' => ['version' => 1], 'serverSeed' => 'seed-abc', 'commitment' => 'c0ffee']],
            'started_at' => now()->subMinutes(5), 'ended_at' => now(),
        ]);
        Report::query()->create(['reporter_id' => $admin->id, 'reported_id' => $player->id, 'reason' => 'abuse', 'status' => 'open']);
        $flag = CheatFlag::query()->create(['user_id' => $player->id, 'kind' => 'reports', 'score' => 5, 'details' => ['reporters' => 5], 'status' => 'open']);
        $this->actingAs($admin);
        foreach ([
            '/admin', '/admin/users', "/admin/users/{$player->id}", '/admin/reports', '/admin/cheat-flags',
            "/admin/cheat-flags/{$flag->id}", '/admin/game-matches', "/admin/game-matches/{$match->id}",
            '/admin/tournaments', '/admin/tournaments/create', '/admin/seasons', '/admin/clans', '/admin/puzzles',
            '/admin/puzzles/sn-001/edit', '/admin/items', '/admin/items/create', '/admin/items/board.dark/edit',
            '/admin/featured-offer', '/admin/wallet-transactions', '/admin/admin-actions',
        ] as $url) {
            $this->get($url)->assertOk();
        }
        $this->get("/admin/game-matches/{$match->id}")->assertSee('seed-abc');
        // Read-only resources have no edit pages.
        $this->get("/admin/users/{$player->id}/edit")->assertNotFound();
    }

    public function test_admin_grant_action_credits_with_the_admin_reason_and_requires_a_note(): void
    {
        $admin = $this->admin();
        $player = User::factory()->create();
        $this->actingAs($admin);
        Livewire::test(ViewUser::class, ['record' => $player->id])
            ->callAction('grant', ['currency' => 'coins', 'amount' => 300, 'note' => ''])
            ->assertHasActionErrors(['note' => 'required']);
        $this->assertSame(0, DB::table('wallet_transactions')->count());
        Livewire::test(ViewUser::class, ['record' => $player->id])
            ->callAction('grant', ['currency' => 'coins', 'amount' => 300, 'note' => 'Server outage'])
            ->assertHasNoActionErrors();
        $row = DB::table('wallet_transactions')->sole();
        $this->assertSame([$player->id, 'coins', 300, 'admin'], [(int) $row->user_id, $row->currency, (int) $row->amount, $row->reason]);
    }

    public function test_ban_from_the_report_queue(): void
    {
        $admin = $this->admin();
        $player = User::factory()->create();
        $report = Report::query()->create(['reporter_id' => $admin->id, 'reported_id' => $player->id, 'reason' => 'cheating', 'status' => 'open']);
        $this->actingAs($admin);
        Livewire::test(ListReports::class)
            ->callAction(TestAction::make('ban')->table($report), ['permanent' => true, 'note' => 'Confirmed engine use'])
            ->assertHasNoActionErrors();
        $this->assertTrue($this->reload($player)->isBanned());
        $this->assertSame(['actioned', 'ban'], [$this->reload($report)->status, $this->reload($report)->action]);
        $this->actingAs($this->reload($player))->getJson('/api/v1/me')->assertForbidden();
    }

    public function test_admin_create_command_creates_or_promotes(): void
    {
        $this->runCommand('admin:create', ['email' => 'Boss@Example.com', '--password' => 'correct-horse-battery'])
            ->expectsOutputToContain('Created admin boss@example.com')->assertSuccessful();
        $boss = User::query()->where('email', 'boss@example.com')->sole();
        $this->assertTrue($boss->is_admin);
        $this->assertFalse($boss->is_guest);
        $this->assertTrue(Hash::check('correct-horse-battery', (string) $boss->getAuthPassword()));

        $player = User::factory()->create(['email' => 'player@example.com']);
        $this->runCommand('admin:create', ['email' => 'player@example.com'])
            ->expectsOutputToContain('Promoted admin')->expectsOutputToContain('Password:')->assertSuccessful();
        $this->assertTrue($this->reload($player)->is_admin);
        $this->runCommand('admin:create', ['email' => 'nope'])->assertFailed();
        $this->runCommand('admin:create', ['email' => 'x@example.com', '--password' => 'short'])->assertFailed();
    }
}
