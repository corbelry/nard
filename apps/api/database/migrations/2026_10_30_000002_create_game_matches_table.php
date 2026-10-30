<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Finished online matches reported by the game server (MatchResult).
        Schema::create('game_matches', function (Blueprint $table) {
            $table->string('id', 64)->primary();
            $table->string('variant', 16);
            $table->unsignedTinyInteger('match_length');
            $table->string('mode', 8);
            $table->foreignId('white_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('black_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('white_name', 64);
            $table->string('black_name', 64);
            $table->boolean('white_bot')->default(false);
            $table->boolean('black_bot')->default(false);
            $table->string('winner', 5);
            $table->unsignedSmallInteger('white_score');
            $table->unsignedSmallInteger('black_score');
            $table->string('reason', 16);
            $table->integer('white_rating_before')->nullable();
            $table->integer('white_rating_after')->nullable();
            $table->integer('black_rating_before')->nullable();
            $table->integer('black_rating_after')->nullable();
            // Game records with revealed fair-dice seeds (docs/FAIRNESS.md).
            $table->json('games');
            $table->timestamp('started_at');
            $table->timestamp('ended_at');
            $table->timestamps();
            $table->index(['white_user_id', 'ended_at']);
            $table->index(['black_user_id', 'ended_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('game_matches');
    }
};
