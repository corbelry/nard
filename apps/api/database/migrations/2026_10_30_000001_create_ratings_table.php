<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // One rating per user and variant (spec §8.2).
        Schema::create('ratings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('variant', 16);
            $table->integer('rating')->default(1500);
            $table->integer('peak')->default(1500);
            // FIBS experience: sum of ranked match lengths played.
            $table->unsignedInteger('experience')->default(0);
            $table->unsignedInteger('matches')->default(0);
            $table->unsignedInteger('wins')->default(0);
            $table->timestamps();
            $table->unique(['user_id', 'variant']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ratings');
    }
};
