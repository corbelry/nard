<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // The inbox (16.2). Not Laravel's database-notification table: rows
        // are typed events rendered by the client (docs/api/notifications.md).
        Schema::create('notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('type', 32);
            // The player who caused it (hidden while blocked either way).
            $table->foreignId('from_user_id')->nullable()->constrained('users')->cascadeOnDelete();
            $table->json('data');
            // One row per event per player, e.g. "tournament_round:9:2".
            $table->string('dedupe_key', 96)->nullable();
            $table->timestamp('read_at')->nullable();
            $table->timestamp('created_at')->nullable()->index();
            $table->unique(['user_id', 'dedupe_key']);
            $table->index(['user_id', 'read_at']);
        });

        // FCM registration tokens (iOS tokens are FCM tokens too).
        Schema::create('device_tokens', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('platform', 8);
            $table->string('token', 512);
            $table->string('token_hash', 64)->unique();
            $table->string('locale', 5)->nullable();
            $table->timestamps();
        });

        // 16.1; a missing row means the defaults (all on, quiet 23–08).
        Schema::create('notification_settings', function (Blueprint $table) {
            $table->foreignId('user_id')->primary()->constrained('users')->cascadeOnDelete();
            $table->boolean('push')->default(true);
            $table->boolean('quiet_enabled')->default(true);
            $table->string('quiet_start', 5)->default('23:00');
            $table->string('quiet_end', 5)->default('08:00');
            // Minutes east of UTC, sent by the client (quiet hours are local).
            $table->smallInteger('utc_offset')->default(0);
            // Categories turned off.
            $table->json('muted');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notification_settings');
        Schema::dropIfExists('device_tokens');
        Schema::dropIfExists('notifications');
    }
};
