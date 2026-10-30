<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/** Tournaments (spec §8.3, docs/api/tournaments.md). */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tournaments', function (Blueprint $table) {
            $table->id();
            // Locale map, e.g. {"az": "…", "en": "…"}; private ones {"default": "…"}.
            $table->json('name');
            // knockout | swiss | round_robin
            $table->string('format', 16);
            // scheduled | sit_and_go | private
            $table->string('kind', 16);
            $table->string('variant', 16);
            $table->unsignedTinyInteger('match_length');
            // Maximum entrants; min_players to start.
            $table->unsignedSmallInteger('size');
            $table->unsignedSmallInteger('min_players');
            $table->unsignedInteger('entry_coins')->default(0);
            $table->unsignedSmallInteger('min_rating')->nullable();
            // [{from, to, coins, items: [item ids]}], fixed before registration.
            $table->json('prizes');
            $table->unsignedInteger('prize_fund')->default(0);
            $table->unsignedTinyInteger('swiss_rounds')->nullable();
            $table->unsignedTinyInteger('total_rounds')->nullable();
            $table->unsignedTinyInteger('current_round')->default(0);
            // registering | running | finished | cancelled
            $table->string('status', 12)->index();
            $table->timestamp('starts_at')->nullable()->index();
            // Still registering at this time → cancelled (sit-and-go fill
            // timeout, private tournaments without a start time).
            $table->timestamp('expires_at')->nullable()->index();
            $table->boolean('is_private')->default(false);
            $table->string('invite_code', 6)->nullable()->unique();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            // e.g. "daily_cup:2026-11-03" (tournaments:schedule is idempotent).
            $table->string('schedule_key', 48)->nullable()->unique();
            $table->timestamp('started_at')->nullable();
            $table->timestamp('finished_at')->nullable();
            $table->string('cancel_reason', 24)->nullable();
            $table->timestamps();
            $table->index(['kind', 'status', 'size']);
        });

        Schema::create('tournament_entries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tournament_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            // Rating in the tournament's variant (snapshot at start; seeding).
            $table->unsignedSmallInteger('rating');
            $table->unsignedSmallInteger('seed')->nullable();
            // Coins debited for this registration (refunded on leave/cancel).
            $table->unsignedInteger('entry_coins')->default(0);
            $table->string('entry_key', 64)->nullable();
            $table->unsignedSmallInteger('points')->default(0);
            $table->unsignedSmallInteger('wins')->default(0);
            $table->unsignedSmallInteger('losses')->default(0);
            $table->unsignedSmallInteger('buchholz')->default(0);
            $table->boolean('had_bye')->default(false);
            $table->unsignedTinyInteger('eliminated_round')->nullable();
            $table->unsignedSmallInteger('place')->nullable();
            $table->boolean('refunded')->default(false);
            $table->timestamps();
            $table->unique(['tournament_id', 'user_id']);
            $table->index(['user_id', 'tournament_id']);
        });

        Schema::create('tournament_rounds', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tournament_id')->constrained()->cascadeOnDelete();
            $table->unsignedTinyInteger('number');
            // running | finished
            $table->string('status', 10);
            $table->timestamp('started_at')->nullable();
            $table->timestamp('finished_at')->nullable();
            $table->timestamps();
            $table->unique(['tournament_id', 'number']);
        });

        Schema::create('tournament_pairings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tournament_id')->constrained()->cascadeOnDelete();
            $table->unsignedTinyInteger('round');
            $table->unsignedSmallInteger('slot');
            // "t{tournament}-{round}-{slot}": the game server's match id.
            $table->string('match_id', 64)->unique();
            $table->foreignId('white_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('black_user_id')->nullable()->constrained('users')->nullOnDelete();
            // pending (to push) | pushed (on the game server) | finished
            $table->string('status', 10)->index();
            // white | black | none (nobody won: both absent, or an empty slot)
            $table->string('result', 5)->nullable();
            $table->foreignId('winner_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->boolean('walkover')->default(false);
            $table->boolean('bye')->default(false);
            $table->unsignedSmallInteger('white_score')->nullable();
            $table->unsignedSmallInteger('black_score')->nullable();
            $table->timestamp('pushed_at')->nullable();
            $table->timestamp('finished_at')->nullable();
            $table->timestamps();
            $table->unique(['tournament_id', 'round', 'slot']);
        });

        // "tournament" (10) and "walkover" need room; history shows the tournament.
        Schema::table('game_matches', function (Blueprint $table) {
            $table->string('mode', 16)->change();
            $table->foreignId('tournament_id')->nullable()->after('mode')->constrained()->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('game_matches', function (Blueprint $table) {
            $table->dropConstrainedForeignId('tournament_id');
            $table->string('mode', 8)->change();
        });
        Schema::dropIfExists('tournament_pairings');
        Schema::dropIfExists('tournament_rounds');
        Schema::dropIfExists('tournament_entries');
        Schema::dropIfExists('tournaments');
    }
};
