<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Shared to add a friend (6.2); stable per account.
            $table->string('friend_code', 8)->nullable()->unique();
            $table->timestamp('last_seen_at')->nullable()->index();
        });

        // One row per pair: requester → addressee, pending or accepted.
        Schema::create('friendships', function (Blueprint $table) {
            $table->id();
            $table->foreignId('requester_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('addressee_id')->constrained('users')->cascadeOnDelete();
            $table->string('status', 8);
            $table->timestamp('accepted_at')->nullable();
            $table->timestamps();
            $table->unique(['requester_id', 'addressee_id']);
            $table->index(['addressee_id', 'status']);
        });

        Schema::create('blocks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('blocker_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('blocked_id')->constrained('users')->cascadeOnDelete();
            $table->timestamps();
            $table->unique(['blocker_id', 'blocked_id']);
        });

        // Moderation queue (14.2); handled in the admin panel (Phase 7).
        Schema::create('reports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('reporter_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('reported_id')->constrained('users')->cascadeOnDelete();
            $table->string('reason', 24);
            $table->string('match_id', 64)->nullable();
            $table->string('note', 500)->nullable();
            $table->string('status', 12)->default('open');
            $table->timestamps();
            $table->index(['reported_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('reports');
        Schema::dropIfExists('blocks');
        Schema::dropIfExists('friendships');
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['friend_code', 'last_seen_at']);
        });
    }
};
