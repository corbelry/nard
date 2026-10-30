<?php

namespace Tests\Feature;

use App\Models\Clan;
use App\Models\ClanMember;
use App\Models\User;
use App\Services\WalletService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Routing\Middleware\ThrottleRequests;
use Illuminate\Support\Carbon;
use Tests\TestCase;

class ClanTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Carbon::setTestNow('2026-11-04 12:00:00');
    }

    private function coins(User $user, int $amount): void
    {
        app(WalletService::class)->credit($user, 'coins', $amount, 'admin', 'seed:'.$user->id.':'.uniqid('', true));
    }

    private function balance(User $user): int
    {
        return app(WalletService::class)->balances($user)['coins'];
    }

    /** @param array<string, mixed> $overrides */
    private function createClan(User $leader, array $overrides = [], int $coins = 3000): int
    {
        $this->coins($leader, $coins);

        return (int) $this->actingAs($leader)->postJson('/api/v1/clans', [
            'name' => 'Qızıl Zər '.$leader->id,
            'tag' => 'Q'.chr(65 + $leader->id % 26).'ZR',
            'emblem' => ['shape' => 'shield', 'symbol' => 'diamond', 'color' => 'garnet'],
            'language' => 'az',
            'joinPolicy' => 'open',
            'idempotencyKey' => 'create-'.$leader->id,
            ...$overrides,
        ])->assertCreated()->json('clan.id');
    }

    /** @param array<int, string> $roles userId => role, set directly */
    private function roles(int $clanId, array $roles): void
    {
        foreach ($roles as $userId => $role) {
            ClanMember::query()->updateOrCreate(['user_id' => $userId], ['clan_id' => $clanId, 'role' => $role, 'joined_at' => now()]);
        }
    }

    public function test_creating_a_clan_costs_coins_and_makes_the_creator_leader(): void
    {
        $leader = User::factory()->create(['name' => 'Rauf']);
        $this->coins($leader, 3450);
        $body = [
            'name' => '  Qızıl   Zər ', 'tag' => 'qzr', 'language' => 'az', 'joinPolicy' => 'request', 'minRating' => 1400,
            'emblem' => ['shape' => 'shield', 'symbol' => 'diamond', 'color' => 'garnet', 'pattern' => 'lattice'],
            'description' => 'Bakıdan ciddi nərd oyunçuları.', 'idempotencyKey' => 'create-key-1',
        ];
        $id = $this->actingAs($leader)->postJson('/api/v1/clans', $body)->assertCreated()
            ->assertJsonPath('clan.name', 'Qızıl Zər')->assertJsonPath('clan.tag', 'QZR')
            ->assertJsonPath('clan.memberCount', 1)->assertJsonPath('clan.maxMembers', 50)
            ->assertJsonPath('wallet.coins', 450)->json('clan.id');
        // A retried request returns the same clan without paying again.
        $this->actingAs($leader)->postJson('/api/v1/clans', $body)->assertCreated()->assertJsonPath('clan.id', $id);
        $this->assertSame(450, $this->balance($leader));
        $this->assertSame(1, Clan::query()->count());
        $this->actingAs($leader)->postJson('/api/v1/clans', [...$body, 'name' => 'Other', 'tag' => 'OTH', 'idempotencyKey' => 'create-key-2'])
            ->assertStatus(422)->assertJsonPath('code', 'already_in_clan');

        $this->actingAs($leader)->getJson('/api/v1/me')->assertJsonPath('user.clan.tag', 'QZR')
            ->assertJsonPath('user.clan.role', 'leader')->assertJsonPath('user.clan.name', 'Qızıl Zər');
        $card = $leader->publicCard();
        $this->assertSameIgnoringKeyOrder(['id' => $id, 'tag' => 'QZR', 'emblem' => $body['emblem']], $card['clan']);

        $other = User::factory()->create();
        $this->actingAs($other)->getJson("/api/v1/clans/$id")->assertOk()
            ->assertJsonPath('clan.myStatus', 'none')->assertJsonPath('clan.chest', null)
            ->assertJsonPath('clan.requirementsMet.rating', true)->assertJsonPath('clan.rating', 1500)
            ->assertJsonPath('clan.members.0.role', 'leader')->assertJsonPath('clan.members.0.user.name', 'Rauf');
        $this->actingAs($other)->getJson('/api/v1/clans?q=qz')->assertOk()->assertJsonPath('clans.0.id', $id);
        $this->actingAs($other)->getJson('/api/v1/clans?q=zər&language=az&policy=request&maxMinRating=1500')->assertJsonCount(1, 'clans');
        $this->actingAs($other)->getJson('/api/v1/clans?maxMinRating=1300')->assertJsonCount(0, 'clans');
        $this->actingAs($other)->getJson('/api/v1/clans?language=en')->assertJsonCount(0, 'clans');
    }

    public function test_create_needs_coins_and_a_valid_unique_name_and_tag(): void
    {
        // Many POSTs in a row: route throttling is not under test here.
        $this->withoutMiddleware(ThrottleRequests::class);
        $poor = User::factory()->create();
        $this->coins($poor, 2999);
        $body = [
            'name' => 'Şəki Ustaları', 'tag' => 'SKU', 'language' => 'az', 'joinPolicy' => 'open',
            'emblem' => ['shape' => 'hexagon', 'symbol' => 'circle', 'color' => 'emerald'], 'idempotencyKey' => 'create-poor',
        ];
        $this->actingAs($poor)->postJson('/api/v1/clans', $body)->assertStatus(422)->assertJsonPath('code', 'insufficient_funds');
        $this->assertSame(0, Clan::query()->count());
        $this->assertSame(2999, $this->balance($poor));

        foreach (['AB', 'ABCDEF', 'A65', 'ŞRV'] as $tag) {
            $this->actingAs($poor)->postJson('/api/v1/clans', [...$body, 'tag' => $tag])->assertJsonValidationErrors('tag');
        }
        $this->actingAs($poor)->postJson('/api/v1/clans', [...$body, 'name' => 'ab'])->assertJsonValidationErrors('name');
        $this->actingAs($poor)->postJson('/api/v1/clans', [...$body, 'name' => str_repeat('a', 25)])->assertJsonValidationErrors('name');
        $this->actingAs($poor)->postJson('/api/v1/clans', [...$body, 'emblem' => ['shape' => 'heart', 'symbol' => 'circle', 'color' => 'emerald']])
            ->assertJsonValidationErrors('emblem.shape');
        $this->actingAs($poor)->postJson('/api/v1/clans', [...$body, 'emblem' => ['shape' => 'star', 'symbol' => 'circle', 'color' => 'pink']])
            ->assertJsonValidationErrors('emblem.color');
        $this->actingAs($poor)->postJson('/api/v1/clans', [...$body, 'language' => 'de'])->assertJsonValidationErrors('language');
        $this->actingAs($poor)->postJson('/api/v1/clans', [...$body, 'description' => str_repeat('a', 201)])->assertJsonValidationErrors('description');

        $first = User::factory()->create();
        $this->createClan($first, ['name' => 'Şəki Ustaları', 'tag' => 'SKU']);
        $this->actingAs($poor)->getJson('/api/v1/clans/tag-available?tag=sku')->assertJsonPath('available', false)->assertJsonPath('valid', true);
        $this->actingAs($poor)->getJson('/api/v1/clans/tag-available?tag=xyz')->assertJsonPath('available', true)->assertJsonPath('tag', 'XYZ');
        $this->actingAs($poor)->getJson('/api/v1/clans/tag-available?tag=x1')->assertJsonPath('valid', false)->assertJsonPath('available', false);
        $second = User::factory()->create();
        $this->coins($second, 3000);
        $this->actingAs($second)->postJson('/api/v1/clans', [...$body, 'idempotencyKey' => 'create-2nd'])
            ->assertStatus(422)->assertJsonPath('code', 'name_taken');
        $this->actingAs($second)->postJson('/api/v1/clans', [...$body, 'name' => 'ŞƏKİ USTALARI', 'tag' => 'NEW', 'idempotencyKey' => 'create-2nd'])
            ->assertStatus(422)->assertJsonPath('code', 'name_taken');
        $this->actingAs($second)->postJson('/api/v1/clans', [...$body, 'name' => 'Other', 'idempotencyKey' => 'create-2nd'])
            ->assertStatus(422)->assertJsonPath('code', 'tag_taken');
        $this->assertSame(3000, $this->balance($second));
    }

    public function test_join_policies_and_minimum_rating(): void
    {
        $open = $this->createClan(User::factory()->create());
        $request = $this->createClan(User::factory()->create(), ['joinPolicy' => 'request']);
        $invite = $this->createClan(User::factory()->create(), ['joinPolicy' => 'invite']);
        $strict = $this->createClan(User::factory()->create(), ['minRating' => 1600]);

        $a = User::factory()->create();
        $this->actingAs($a)->postJson("/api/v1/clans/$invite/join")->assertStatus(422)->assertJsonPath('code', 'invite_only');
        $this->actingAs($a)->postJson("/api/v1/clans/$strict/join")->assertStatus(422)->assertJsonPath('code', 'rating_too_low');
        $this->actingAs($a)->getJson("/api/v1/clans/$strict")->assertJsonPath('clan.requirementsMet.rating', false);
        $this->actingAs($a)->postJson("/api/v1/clans/$request/join")->assertOk()->assertJsonPath('status', 'requested');
        $this->actingAs($a)->getJson("/api/v1/clans/$request")->assertJsonPath('clan.myStatus', 'pending');
        $this->actingAs($a)->deleteJson("/api/v1/clans/$request/join")->assertOk();
        $this->actingAs($a)->deleteJson("/api/v1/clans/$request/join")->assertNotFound();
        $this->actingAs($a)->postJson("/api/v1/clans/$request/join")->assertJsonPath('status', 'requested');
        $this->actingAs($a)->postJson("/api/v1/clans/$open/join")->assertOk()->assertJsonPath('status', 'joined');
        // Joining ends the other application.
        $this->assertDatabaseMissing('clan_join_requests', ['user_id' => $a->id]);
        $this->actingAs($a)->postJson("/api/v1/clans/$request/join")->assertStatus(422)->assertJsonPath('code', 'already_in_clan');
        $this->actingAs($a)->getJson("/api/v1/clans/$open")->assertJsonPath('clan.myStatus', 'member')
            ->assertJsonPath('clan.myRole', 'member')->assertJsonPath('clan.memberCount', 2);

        // The best rating over both variants counts.
        $b = User::factory()->create();
        $b->ratingFor('longNard')->forceFill(['rating' => 1650])->save();
        $this->actingAs($b)->postJson("/api/v1/clans/$strict/join")->assertJsonPath('status', 'joined');
        $this->actingAs($b)->getJson("/api/v1/clans/$strict")->assertJsonPath('clan.rating', 1575);
        $this->actingAs($b)->postJson('/api/v1/clans/999/join')->assertNotFound();
    }

    public function test_requests_and_invites_by_role(): void
    {
        $leader = User::factory()->create();
        $id = $this->createClan($leader, ['joinPolicy' => 'request']);
        [$co, $elder, $member] = [User::factory()->create(), User::factory()->create(), User::factory()->create()];
        $this->roles($id, [$co->id => 'co_leader', $elder->id => 'elder', $member->id => 'member']);

        [$x, $y] = [User::factory()->create(['name' => 'Xan']), User::factory()->create()];
        $this->actingAs($x)->postJson("/api/v1/clans/$id/join")->assertJsonPath('status', 'requested');
        $this->actingAs($y)->postJson("/api/v1/clans/$id/join")->assertJsonPath('status', 'requested');
        $this->actingAs($member)->getJson("/api/v1/clans/$id/requests")->assertForbidden()->assertJsonPath('code', 'forbidden');
        $this->actingAs($x)->getJson("/api/v1/clans/$id/requests")->assertForbidden()->assertJsonPath('code', 'not_member');
        $requests = $this->actingAs($elder)->getJson("/api/v1/clans/$id/requests")->assertOk()->json('requests');
        $this->assertSame('Xan', $requests[0]['user']['name']);
        // Elders accept but do not decline.
        $this->actingAs($elder)->deleteJson("/api/v1/clans/$id/requests/{$requests[1]['id']}")->assertForbidden();
        $this->actingAs($elder)->postJson("/api/v1/clans/$id/requests/{$requests[0]['id']}/accept")->assertOk();
        $this->actingAs($co)->deleteJson("/api/v1/clans/$id/requests/{$requests[1]['id']}")->assertOk();
        $this->actingAs($co)->deleteJson("/api/v1/clans/$id/requests/{$requests[1]['id']}")->assertNotFound();
        $this->assertSame($id, ClanMember::query()->where('user_id', $x->id)->value('clan_id'));
        $this->assertNull(ClanMember::query()->where('user_id', $y->id)->first());

        // Invites (elder+), listed under /me, accepted or declined.
        $this->actingAs($member)->postJson("/api/v1/clans/$id/invites", ['userId' => (string) $y->id])->assertForbidden();
        $this->actingAs($elder)->postJson("/api/v1/clans/$id/invites", ['userId' => (string) $x->id])
            ->assertStatus(422)->assertJsonPath('code', 'already_in_clan');
        $this->actingAs($elder)->postJson("/api/v1/clans/$id/invites", ['userId' => (string) $elder->id])->assertStatus(422)->assertJsonPath('code', 'self');
        $this->actingAs($elder)->postJson("/api/v1/clans/$id/invites", ['userId' => (string) $y->id])->assertCreated();
        $this->actingAs($y)->getJson("/api/v1/clans/$id")->assertJsonPath('clan.myStatus', 'invited');
        $invites = $this->actingAs($y)->getJson('/api/v1/me/clan-invites')->assertOk()->json('invites');
        $this->assertSame((string) $id, $invites[0]['clan']['id']);
        $this->assertSame((string) $elder->id, $invites[0]['invitedBy']['id']);
        $this->actingAs($x)->postJson("/api/v1/me/clan-invites/{$invites[0]['id']}/accept")->assertNotFound();
        $this->actingAs($y)->postJson("/api/v1/me/clan-invites/{$invites[0]['id']}/accept")->assertOk()->assertJsonPath('clan.id', (string) $id);
        $this->assertSame([], $this->actingAs($y)->getJson('/api/v1/me/clan-invites')->json('invites'));

        // An invite opens an invite-only clan; it can be declined; blocks stop it.
        $closed = $this->createClan(User::factory()->create(), ['joinPolicy' => 'invite', 'minRating' => 2000]);
        $z = User::factory()->create();
        $closedLeader = User::query()->whereKey(ClanMember::query()->where('clan_id', $closed)->value('user_id'))->firstOrFail();
        $this->actingAs($closedLeader)->postJson("/api/v1/clans/$closed/invites", ['userId' => (string) $z->id])->assertCreated();
        $inviteId = $this->actingAs($z)->getJson('/api/v1/me/clan-invites')->json('invites.0.id');
        $this->actingAs($z)->deleteJson("/api/v1/me/clan-invites/$inviteId")->assertOk();
        $this->actingAs($z)->postJson("/api/v1/clans/$closed/join")->assertStatus(422)->assertJsonPath('code', 'invite_only');
        $this->actingAs($closedLeader)->postJson("/api/v1/clans/$closed/invites", ['userId' => (string) $z->id])->assertCreated();
        $this->actingAs($z)->postJson("/api/v1/clans/$closed/join")->assertJsonPath('status', 'joined');
        $w = User::factory()->create();
        $this->actingAs($w)->postJson("/api/v1/blocks/{$closedLeader->id}")->assertOk();
        $this->actingAs($closedLeader)->postJson("/api/v1/clans/$closed/invites", ['userId' => (string) $w->id])
            ->assertStatus(422)->assertJsonPath('code', 'blocked');
    }

    public function test_role_permissions(): void
    {
        $leader = User::factory()->create();
        $id = $this->createClan($leader);
        [$co, $co2, $elder, $m1, $m2] = User::factory()->count(5)->create()->all();
        $this->roles($id, [$co->id => 'member', $co2->id => 'co_leader', $elder->id => 'member', $m1->id => 'member', $m2->id => 'member']);
        $role = fn (User $actor, User $target, string $role) => $this->actingAs($actor)
            ->postJson("/api/v1/clans/$id/members/{$target->id}/role", ['role' => $role]);
        $kick = fn (User $actor, User $target) => $this->actingAs($actor)->deleteJson("/api/v1/clans/$id/members/{$target->id}");

        $role($leader, $co, 'co_leader')->assertOk();
        $role($co, $elder, 'elder')->assertOk();
        $role($co, $m1, 'co_leader')->assertForbidden();
        $role($co, $co2, 'member')->assertForbidden();
        $role($co, $leader, 'member')->assertForbidden();
        $role($co, $m1, 'leader')->assertForbidden();
        $role($co, $co, 'member')->assertStatus(422)->assertJsonPath('code', 'self');
        $role($elder, $m1, 'elder')->assertForbidden();
        $role($m1, $m2, 'elder')->assertForbidden();
        $role($leader, $m1, 'boss')->assertJsonValidationErrors('role');
        $this->assertSame('elder', ClanMember::query()->where('user_id', $elder->id)->value('role'));

        $kick($m1, $m2)->assertForbidden();
        $kick($elder, $co)->assertForbidden();
        $role($co, $m1, 'elder')->assertOk();
        $kick($elder, $m1)->assertForbidden();
        $kick($elder, $m2)->assertOk();
        $kick($elder, $m2)->assertNotFound();
        $kick($co, $co2)->assertForbidden();
        $kick($co, $m1)->assertOk();
        $kick($leader, $co2)->assertOk();
        $role($leader, $elder, 'member')->assertOk();

        // Settings: co-leader edits all but name/tag; members nothing.
        $this->actingAs($co)->patchJson("/api/v1/clans/$id", ['description' => 'Hər cümə döyüş', 'joinPolicy' => 'invite', 'minRating' => 1500, 'emblem' => ['shape' => 'star', 'symbol' => 'square', 'color' => 'blue']])
            ->assertOk()->assertJsonPath('clan.description', 'Hər cümə döyüş')->assertJsonPath('clan.emblem.pattern', 'none');
        $this->actingAs($co)->patchJson("/api/v1/clans/$id", ['name' => 'Co Rename', 'idempotencyKey' => 'rename-co'])->assertForbidden();
        $this->actingAs($elder)->patchJson("/api/v1/clans/$id", ['description' => 'x'])->assertForbidden();
        $this->actingAs($co)->deleteJson("/api/v1/clans/$id")->assertForbidden();

        /** @var array<int, array<string, mixed>> $messages */
        $messages = $this->actingAs($leader)->getJson("/api/v1/clans/$id/messages")->json('messages');
        $events = array_values(array_filter(array_column($messages, 'event')));
        $this->assertSame(['created', 'promoted', 'promoted', 'promoted', 'kicked', 'kicked', 'kicked', 'demoted'], $events);
    }

    public function test_rename_transfer_leave_and_disband(): void
    {
        $leader = User::factory()->create();
        $id = $this->createClan($leader);
        $co = User::factory()->create();
        $this->roles($id, [$co->id => 'co_leader']);

        $this->actingAs($leader)->patchJson("/api/v1/clans/$id", ['name' => 'Yeni Ad'])->assertStatus(422)->assertJsonPath('code', 'idempotency_key_required');
        $this->actingAs($leader)->patchJson("/api/v1/clans/$id", ['name' => 'Yeni Ad', 'idempotencyKey' => 'rename-1'])
            ->assertStatus(422)->assertJsonPath('code', 'insufficient_funds');
        $this->coins($leader, 1500);
        $this->actingAs($leader)->patchJson("/api/v1/clans/$id", ['name' => 'Yeni Ad', 'tag' => 'yeni', 'idempotencyKey' => 'rename-1'])
            ->assertOk()->assertJsonPath('clan.name', 'Yeni Ad')->assertJsonPath('clan.tag', 'YENI')->assertJsonPath('wallet.coins', 500);
        $this->actingAs($leader)->patchJson("/api/v1/clans/$id", ['name' => 'Başqa Ad', 'idempotencyKey' => 'rename-1'])
            ->assertOk()->assertJsonPath('clan.name', 'Yeni Ad')->assertJsonPath('wallet.coins', 500);
        // Same name: free, no key needed.
        $this->actingAs($leader)->patchJson("/api/v1/clans/$id", ['name' => 'Yeni Ad', 'language' => 'tr'])->assertOk()->assertJsonPath('clan.language', 'tr');

        $this->actingAs($leader)->postJson("/api/v1/clans/$id/leave")->assertStatus(422)->assertJsonPath('code', 'transfer_first');
        $this->actingAs($leader)->postJson("/api/v1/clans/$id/members/{$co->id}/role", ['role' => 'leader'])->assertOk();
        $this->assertSame('co_leader', ClanMember::query()->where('user_id', $leader->id)->value('role'));
        $this->actingAs($leader)->postJson("/api/v1/clans/$id/leave")->assertOk()->assertJsonPath('status', 'left');
        $this->actingAs($leader)->postJson("/api/v1/clans/$id/leave")->assertForbidden();
        $this->actingAs($co)->postJson("/api/v1/clans/$id/leave")->assertOk()->assertJsonPath('status', 'disbanded');
        $this->actingAs($co)->getJson("/api/v1/clans/$id")->assertNotFound();

        // Disband by the leader; a deleted leader hands the clan on.
        $other = User::factory()->create();
        $id2 = $this->createClan($other);
        $m = User::factory()->create();
        $e = User::factory()->create();
        $this->roles($id2, [$m->id => 'member', $e->id => 'elder']);
        $other->delete();
        $this->assertSame('leader', ClanMember::query()->where('user_id', $e->id)->value('role'));
        $this->actingAs($m)->deleteJson("/api/v1/clans/$id2")->assertForbidden();
        $this->actingAs($e)->deleteJson("/api/v1/clans/$id2")->assertOk();
        $this->assertSame(0, ClanMember::query()->count());
    }

    public function test_member_cap(): void
    {
        config(['clans.max_members' => 3]);
        $leader = User::factory()->create();
        $id = $this->createClan($leader);
        [$a, $b, $c] = User::factory()->count(3)->create()->all();
        $this->actingAs($a)->postJson("/api/v1/clans/$id/join")->assertJsonPath('status', 'joined');
        $this->actingAs($b)->postJson("/api/v1/clans/$id/join")->assertJsonPath('status', 'joined');
        $this->actingAs($c)->postJson("/api/v1/clans/$id/join")->assertStatus(422)->assertJsonPath('code', 'clan_full');
        $this->actingAs($leader)->postJson("/api/v1/clans/$id/invites", ['userId' => (string) $c->id])->assertStatus(422)->assertJsonPath('code', 'clan_full');
        $this->actingAs($c)->getJson('/api/v1/clans')->assertJsonPath('clans.0.memberCount', 3)->assertJsonPath('clans.0.maxMembers', 3);
    }

    public function test_chat_moderation_and_rate_limit(): void
    {
        config(['clans.chat.per_minute' => 4]);
        $leader = User::factory()->create(['name' => 'Rauf']);
        $id = $this->createClan($leader);
        [$elder, $m1, $m2, $outsider] = User::factory()->count(4)->create()->all();
        $this->roles($id, [$elder->id => 'elder', $m1->id => 'member', $m2->id => 'member']);

        $first = $this->actingAs($m1)->postJson("/api/v1/clans/$id/messages", ['text' => '  Salam!  '])->assertCreated()
            ->assertJsonPath('message.text', 'Salam!')->assertJsonPath('message.author.id', (string) $m1->id)->json('message.id');
        $second = $this->actingAs($m2)->postJson("/api/v1/clans/$id/messages", ['text' => 'Sandığa 500 qoydum'])->assertCreated()->json('message.id');
        $this->actingAs($m1)->postJson("/api/v1/clans/$id/messages", ['text' => str_repeat('a', 301)])->assertJsonValidationErrors('text');
        $this->actingAs($m1)->postJson("/api/v1/clans/$id/messages", ['text' => '   '])->assertStatus(422);
        $this->actingAs($outsider)->postJson("/api/v1/clans/$id/messages", ['text' => 'hi'])->assertForbidden();
        $this->actingAs($outsider)->getJson("/api/v1/clans/$id/messages")->assertForbidden();

        $all = $this->actingAs($leader)->getJson("/api/v1/clans/$id/messages")->assertOk()->json('messages');
        $this->assertSame('system', $all[0]['kind']);
        $this->assertSame('created', $all[0]['event']);
        $this->assertSameIgnoringKeyOrder(['userId' => (string) $leader->id, 'name' => 'Rauf'], $all[0]['data']);
        $this->assertSame('Sandığa 500 qoydum', end($all)['text']);
        $after = $this->actingAs($leader)->getJson("/api/v1/clans/$id/messages?after=$first")->json('messages');
        $this->assertSame([$second], array_column($after, 'id'));

        // Moderation: members delete only their own; elders anyone's.
        $this->actingAs($m1)->deleteJson("/api/v1/clans/$id/messages/$second")->assertForbidden();
        $this->actingAs($elder)->deleteJson("/api/v1/clans/$id/messages/$second")->assertOk();
        $this->actingAs($m1)->deleteJson("/api/v1/clans/$id/messages/$first")->assertOk();
        $this->actingAs($m1)->deleteJson("/api/v1/clans/$id/messages/$first")->assertNotFound();
        $this->assertSame([], $this->actingAs($leader)->getJson("/api/v1/clans/$id/messages?after=".($first - 1))->json('messages'));
        $this->assertSoftDeleted('clan_messages', ['id' => $second, 'deleted_by' => $elder->id]);

        // A blocked player's messages are hidden from the blocker.
        $third = $this->actingAs($m2)->postJson("/api/v1/clans/$id/messages", ['text' => 'spam'])->json('message.id');
        $this->actingAs($m1)->postJson("/api/v1/blocks/{$m2->id}")->assertOk();
        $this->assertNotContains($third, array_column($this->actingAs($m1)->getJson("/api/v1/clans/$id/messages")->json('messages'), 'id'));
        $this->assertContains($third, array_column($this->actingAs($leader)->getJson("/api/v1/clans/$id/messages")->json('messages'), 'id'));

        // Rate limit: per member per minute.
        $this->actingAs($m2)->postJson("/api/v1/clans/$id/messages", ['text' => 'two'])->assertCreated();
        $this->actingAs($m2)->postJson("/api/v1/clans/$id/messages", ['text' => 'three'])->assertCreated();
        $this->actingAs($m2)->postJson("/api/v1/clans/$id/messages", ['text' => 'four'])->assertStatus(429)->assertJsonPath('code', 'rate_limited');
        $this->actingAs($elder)->postJson("/api/v1/clans/$id/messages", ['text' => 'ok'])->assertCreated();
    }

    public function test_donations_fill_the_weekly_chest_once_per_key(): void
    {
        $leader = User::factory()->create();
        $id = $this->createClan($leader);
        $m = User::factory()->create();
        $this->roles($id, [$m->id => 'member']);
        $this->coins($m, 12000);

        $donate = fn (User $u, int $coins, string $key) => $this->actingAs($u)
            ->postJson("/api/v1/clans/$id/donate", ['coins' => $coins, 'idempotencyKey' => $key]);
        $donate($m, 505, 'donation-1')->assertOk()->assertJsonPath('donated', 505)
            ->assertJsonPath('chest.coins', 505)->assertJsonPath('chest.target', 10000)->assertJsonPath('chest.myDonated', 505)
            ->assertJsonPath('wallet.coins', 11495)->assertJsonPath('clan.xp', 50);
        $donate($m, 505, 'donation-1')->assertOk()->assertJsonPath('chest.coins', 505)->assertJsonPath('wallet.coins', 11495);
        $donate($m, 5, 'donation-2')->assertJsonValidationErrors('coins');
        $donate(User::factory()->create(), 100, 'donation-x')->assertForbidden();
        $poor = User::factory()->create();
        $this->roles($id, [$poor->id => 'member']);
        $donate($poor, 100, 'donation-poor')->assertStatus(422)->assertJsonPath('code', 'insufficient_funds');

        // Capped at the target; a full chest grants clan XP once and pays
        // every donor of the week a fixed reward (300 coins, QUESTIONS #31).
        $leaderBefore = $this->balance($leader);
        $donate($m, 10000, 'donation-3')->assertOk()->assertJsonPath('donated', 9495)
            ->assertJsonPath('chest.coins', 10000)->assertJsonPath('wallet.coins', 2300)
            ->assertJsonPath('clan.xp', 1000 + 500)->assertJsonPath('clan.level', 2);
        $donate($m, 100, 'donation-4')->assertStatus(422)->assertJsonPath('code', 'chest_full');
        $this->assertSame(2300, $this->balance($m));
        $this->assertSame($leaderBefore, $this->balance($leader));
        /** @var array{chest: array{coins: int}, members: array<int, array{user: array{id: string}, weeklyDonated: int}>} $show */
        $show = $this->actingAs($m)->getJson("/api/v1/clans/$id")->json('clan');
        $this->assertSame(10000, $show['chest']['coins']);
        $mine = array_values(array_filter($show['members'], fn ($row) => $row['user']['id'] === (string) $m->id));
        $this->assertSame(10000, $mine[0]['weeklyDonated']);
        $this->assertSame(1, $this->actingAs($m)->getJson('/api/v1/clans/leaderboard')->json('me.rank'));

        // A new week starts an empty chest.
        Carbon::setTestNow('2026-11-09 00:01:00');
        $this->actingAs($m)->getJson("/api/v1/clans/$id")->assertJsonPath('clan.chest.coins', 0)->assertJsonPath('clan.chest.myDonated', 0);
        $donate($m, 100, 'donation-5')->assertOk()->assertJsonPath('chest.coins', 100)->assertJsonPath('chest.myDonated', 100);
    }
}
