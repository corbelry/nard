<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Friend challenges: a private-room code offered to a friend (6.1/6.3).
        Schema::create('challenges', function (Blueprint $table) {
            $table->id();
            $table->foreignId('from_user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('to_user_id')->constrained('users')->cascadeOnDelete();
            $table->string('code', 6);
            $table->string('variant', 16);
            $table->unsignedTinyInteger('match_length');
            $table->timestamp('expires_at');
            $table->timestamps();
            $table->index(['to_user_id', 'expires_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('challenges');
    }
};
