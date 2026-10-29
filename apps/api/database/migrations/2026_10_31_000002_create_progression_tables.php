<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Level/XP and login streak (spec §8.8, ADR-017).
        Schema::table('users', function (Blueprint $table) {
            $table->unsignedBigInteger('xp')->default(0);
            $table->unsignedSmallInteger('level')->default(1);
            $table->unsignedSmallInteger('login_streak')->default(0);
            $table->unsignedSmallInteger('best_streak')->default(0);
            $table->date('last_checkin')->nullable();
            $table->string('title_item_id', 64)->nullable();
            // Lifetime counters for achievements.
            $table->unsignedInteger('wins_total')->default(0);
            $table->unsignedInteger('mars_total')->default(0);
            $table->unsignedInteger('ranked_wins_total')->default(0);
        });

        Schema::create('user_missions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('mission_id', 48);
            // e.g. 2026-10-31 (daily) or 2026-W44 (weekly)
            $table->string('period', 16);
            $table->unsignedInteger('progress')->default(0);
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('claimed_at')->nullable();
            $table->timestamps();
            $table->unique(['user_id', 'mission_id', 'period']);
        });

        Schema::create('user_achievements', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('achievement_id', 48);
            $table->timestamp('unlocked_at');
            $table->unique(['user_id', 'achievement_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_achievements');
        Schema::dropIfExists('user_missions');
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['xp', 'level', 'login_streak', 'best_streak', 'last_checkin', 'title_item_id', 'wins_total', 'mars_total', 'ranked_wins_total']);
        });
    }
};
