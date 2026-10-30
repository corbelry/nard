<?php

namespace Tests\Feature;

use App\Jobs\SendDataExport;
use App\Mail\DataExportMail;
use App\Models\User;
use App\Services\AccountExport;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Queue;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;
use ZipArchive;

/** 15.2 data export: an e-mailed ZIP (QUESTIONS #17). */
class DataExportTest extends TestCase
{
    use RefreshDatabase;

    public function test_guests_must_link_an_email_first(): void
    {
        Queue::fake();
        Sanctum::actingAs(User::factory()->create(['email' => null, 'is_guest' => true]));
        $this->postJson('/api/v1/me/export')->assertStatus(409)->assertJson(['code' => 'email_required']);
        Queue::assertNothingPushed();
    }

    public function test_the_export_is_queued_for_the_account_email(): void
    {
        Queue::fake();
        $user = User::factory()->create(['email' => 'aysel@example.com', 'is_guest' => false]);
        Sanctum::actingAs($user);
        $this->postJson('/api/v1/me/export')->assertStatus(202)->assertJson(['email' => 'aysel@example.com']);
        Queue::assertPushed(SendDataExport::class, fn (SendDataExport $job) => $job->userId === $user->id);
    }

    public function test_the_zip_holds_the_players_data_without_secrets(): void
    {
        Mail::fake();
        $user = User::factory()->create(['email' => 'aysel@example.com', 'is_guest' => false, 'locale' => 'tr']);
        DB::table('wallet_transactions')->insert([
            'user_id' => $user->id, 'currency' => 'coins', 'amount' => 300, 'balance_after' => 300,
            'reason' => 'clan_chest', 'idempotency_key' => 'k1', 'created_at' => now(),
        ]);
        DB::table('wallet_transactions')->insert([
            'user_id' => $user->id, 'currency' => 'coins', 'amount' => 50, 'balance_after' => 350,
            'reason' => 'admin_grant', 'reference' => 'admin:77', 'idempotency_key' => 'k2', 'created_at' => now(),
        ]);
        $other = User::factory()->create();
        DB::table('reports')->insert([
            'reporter_id' => $user->id, 'reported_id' => $other->id, 'reason' => 'cheating', 'status' => 'closed',
            'action' => 'banned', 'handled_by' => $other->id, 'handled_at' => now(), 'created_at' => now(), 'updated_at' => now(),
        ]);
        DB::table('device_tokens')->insert([
            'user_id' => $user->id, 'platform' => 'android', 'token' => 'secret-fcm', 'token_hash' => hash('sha256', 'secret-fcm'),
            'created_at' => now(), 'updated_at' => now(),
        ]);

        (new SendDataExport($user->id))->handle(app(AccountExport::class));

        $zip = '';
        Mail::assertSent(DataExportMail::class, function (DataExportMail $mail) use (&$zip) {
            $zip = $mail->zip;

            return $mail->hasTo('aysel@example.com') && $mail->locale === 'tr';
        });
        $path = tempnam(sys_get_temp_dir(), 'export');
        file_put_contents($path, $zip);
        $archive = new ZipArchive;
        $this->assertTrue($archive->open($path));
        $profile = json_decode((string) $archive->getFromName('profile.json'), true);
        $this->assertSame('aysel@example.com', $profile['email']);
        $wallet = json_decode((string) $archive->getFromName('wallet_transactions.json'), true);
        $this->assertSame('clan_chest', $wallet[0]['reason']);
        $this->assertNotFalse($archive->getFromName('matches.json'));
        $all = '';
        for ($i = 0; $i < $archive->numFiles; $i++) {
            $all .= $archive->getFromIndex($i);
        }
        $archive->close();
        unlink($path);
        $this->assertStringNotContainsString('secret-fcm', $all);
        $this->assertStringNotContainsString('token_hash', $all);
        $this->assertStringNotContainsString('idempotency_key', $all);
        // Moderation outcomes and admin ids stay internal (security review).
        $this->assertStringNotContainsString('handled_by', $all);
        $this->assertStringNotContainsString('"action"', $all);
        $this->assertStringNotContainsString('admin:77', $all);
    }

    public function test_a_deleted_account_gets_no_mail(): void
    {
        Mail::fake();
        (new SendDataExport(999))->handle(app(AccountExport::class));
        Mail::assertNothingSent();
    }
}
