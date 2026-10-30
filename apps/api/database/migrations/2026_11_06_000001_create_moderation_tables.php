<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Admin panel and fair play (spec §8.13, §8.14, ADR-042): admin flag,
 * bans / chat mutes / matchmaking cooldowns, report handling, the audit
 * log, sign-in sightings (IP / device) and anti-cheat flags.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Filament access (its own session login, not the mobile tokens).
            $table->boolean('is_admin')->default(false);
            // Banned while banned_at is set and banned_until is null (permanent) or in the future.
            $table->timestamp('banned_at')->nullable();
            $table->timestamp('banned_until')->nullable();
            $table->string('ban_reason', 500)->nullable();
            // Clan chat and in-game emotes.
            $table->timestamp('muted_until')->nullable();
            // Public matchmaking queue (abandonment penalty, §8.14).
            $table->timestamp('queue_cooldown_until')->nullable();
            $table->string('last_ip', 45)->nullable();
            $table->timestamp('last_login_at')->nullable();
        });

        Schema::table('reports', function (Blueprint $table) {
            // dismiss | warn | mute | ban
            $table->string('action', 12)->nullable();
            $table->foreignId('handled_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('handled_at')->nullable();
            $table->index(['status', 'created_at']);
        });

        Schema::table('puzzles', function (Blueprint $table) {
            $table->boolean('enabled')->default(true);
        });

        // Runtime settings edited in the admin panel (e.g. the featured offer).
        Schema::create('app_settings', function (Blueprint $table) {
            $table->string('key', 64)->primary();
            $table->json('value');
            $table->timestamps();
        });

        // Audit log of every admin write (spec §8.13).
        Schema::create('admin_actions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('admin_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('action', 32);
            // What it was done to, e.g. "user:12", "tournament:4".
            $table->string('subject', 64)->nullable();
            $table->string('note', 500)->nullable();
            $table->json('data')->nullable();
            $table->timestamp('created_at')->nullable()->index();
        });

        // Where an account signs in from; values are hashed (only equality matters).
        Schema::create('user_sightings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            // ip | device
            $table->string('kind', 8);
            $table->string('value_hash', 64);
            $table->timestamp('first_seen_at');
            $table->timestamp('last_seen_at');
            $table->unique(['user_id', 'kind', 'value_hash']);
            $table->index(['kind', 'value_hash']);
        });

        // Fair-play signals for review (anticheat:scan).
        Schema::create('cheat_flags', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            // engine | multi_account | abandonment | reports
            $table->string('kind', 16);
            $table->decimal('score', 8, 3);
            $table->json('details');
            // open | reviewed | dismissed | actioned
            $table->string('status', 12)->default('open');
            $table->foreignId('reviewed_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('reviewed_at')->nullable();
            $table->string('review_note', 500)->nullable();
            $table->timestamps();
            $table->index(['user_id', 'kind']);
            $table->index(['status', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cheat_flags');
        Schema::dropIfExists('user_sightings');
        Schema::dropIfExists('admin_actions');
        Schema::dropIfExists('app_settings');
        Schema::table('puzzles', function (Blueprint $table) {
            $table->dropColumn('enabled');
        });
        Schema::table('reports', function (Blueprint $table) {
            $table->dropIndex(['status', 'created_at']);
            $table->dropConstrainedForeignId('handled_by');
            $table->dropColumn(['action', 'handled_at']);
        });
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'is_admin', 'banned_at', 'banned_until', 'ban_reason', 'muted_until',
                'queue_cooldown_until', 'last_ip', 'last_login_at',
            ]);
        });
    }
};
