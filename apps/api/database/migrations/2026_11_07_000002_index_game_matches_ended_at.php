<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// The metrics endpoint counts matches of the last 24 hours (ADR-043).
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('game_matches', function (Blueprint $table): void {
            $table->index('ended_at');
        });
    }

    public function down(): void
    {
        Schema::table('game_matches', function (Blueprint $table): void {
            $table->dropIndex(['ended_at']);
        });
    }
};
