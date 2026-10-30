<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/** Clans (spec §8.4, docs/design-notes/social.md §6). */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('clans', function (Blueprint $table) {
            $table->id();
            $table->string('name', 24)->unique();
            // Lower-cased name: uniqueness ignores case on every database.
            $table->string('name_key', 24)->unique();
            $table->string('tag', 5)->unique();
            // {shape, symbol, color, pattern} from config/clans.php.
            $table->json('emblem');
            $table->string('description', 200)->nullable();
            $table->string('language', 2)->index();
            $table->unsignedSmallInteger('min_rating')->nullable();
            $table->string('join_policy', 8);
            $table->unsignedBigInteger('xp')->default(0);
            $table->unsignedSmallInteger('level')->default(1);
            // Weekly chest: coins donated in chest_week (ISO "2026-W45").
            $table->unsignedInteger('chest_coins')->default(0);
            $table->string('chest_week', 8)->nullable();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->index(['xp', 'id']);
        });

        Schema::create('clan_members', function (Blueprint $table) {
            $table->id();
            $table->foreignId('clan_id')->constrained()->cascadeOnDelete();
            // One clan per player.
            $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            $table->string('role', 10);
            $table->timestamp('joined_at');
            // Coins donated in donated_week.
            $table->unsignedInteger('donated_coins')->default(0);
            $table->string('donated_week', 8)->nullable();
            $table->timestamps();
            $table->index(['clan_id', 'role']);
        });

        // Pending applications (join policy "request").
        Schema::create('clan_join_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('clan_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->timestamps();
            $table->unique(['clan_id', 'user_id']);
            $table->index('user_id');
        });

        Schema::create('clan_invites', function (Blueprint $table) {
            $table->id();
            $table->foreignId('clan_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('invited_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('expires_at');
            $table->timestamps();
            $table->unique(['clan_id', 'user_id']);
            $table->index('user_id');
        });

        // Clan chat (5.4). System rows carry an event id + data the client
        // localizes; soft-deleted rows are kept for moderation.
        Schema::create('clan_messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('clan_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->string('kind', 8);
            $table->string('body', 300)->nullable();
            $table->string('event', 16)->nullable();
            $table->json('data')->nullable();
            $table->foreignId('deleted_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->softDeletes();
            $table->index(['clan_id', 'id']);
        });

        // Weekly wars (5.6). Sides stay null when a clan is disbanded.
        Schema::create('clan_wars', function (Blueprint $table) {
            $table->id();
            $table->string('week', 8);
            $table->foreignId('clan_a_id')->nullable()->constrained('clans')->nullOnDelete();
            $table->foreignId('clan_b_id')->nullable()->constrained('clans')->nullOnDelete();
            $table->unsignedInteger('score_a')->default(0);
            $table->unsignedInteger('score_b')->default(0);
            $table->unsignedSmallInteger('matches_counted')->default(0);
            $table->string('status', 8);
            $table->foreignId('winner_clan_id')->nullable()->constrained('clans')->nullOnDelete();
            $table->timestamp('starts_at');
            $table->timestamp('ends_at');
            $table->timestamps();
            $table->unique(['week', 'clan_a_id']);
            $table->unique(['week', 'clan_b_id']);
            $table->index(['status', 'ends_at']);
        });

        Schema::create('clan_war_matches', function (Blueprint $table) {
            $table->id();
            $table->foreignId('clan_war_id')->constrained()->cascadeOnDelete();
            $table->string('match_id', 64)->unique();
            $table->foreignId('winner_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('loser_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('winner_clan_id')->nullable()->constrained('clans')->nullOnDelete();
            $table->unsignedSmallInteger('winner_score');
            $table->unsignedSmallInteger('loser_score');
            $table->timestamp('created_at')->useCurrent();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('clan_war_matches');
        Schema::dropIfExists('clan_wars');
        Schema::dropIfExists('clan_messages');
        Schema::dropIfExists('clan_invites');
        Schema::dropIfExists('clan_join_requests');
        Schema::dropIfExists('clan_members');
        Schema::dropIfExists('clans');
    }
};
