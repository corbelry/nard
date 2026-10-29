<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Data-driven cosmetics (spec §8.6): new items ship without app updates.
        Schema::create('items', function (Blueprint $table) {
            $table->string('id', 64)->primary();
            $table->string('category', 24)->index();
            $table->string('rarity', 16);
            $table->unsignedInteger('price_coins')->nullable();
            $table->unsignedInteger('price_gems')->nullable();
            // Owned by everyone from the start.
            $table->boolean('is_default')->default(false);
            $table->boolean('available')->default(true);
            $table->json('data');
            $table->string('asset_url')->nullable();
            $table->unsignedInteger('asset_version')->default(1);
            $table->unsignedInteger('sort')->default(0);
            $table->timestamps();
        });

        Schema::create('user_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('item_id', 64);
            $table->foreign('item_id')->references('id')->on('items');
            $table->string('source', 16);
            $table->timestamps();
            $table->unique(['user_id', 'item_id']);
        });

        Schema::create('loadouts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('name', 24);
            // category => item id
            $table->json('slots');
            $table->boolean('active')->default(false);
            $table->timestamps();
        });

        // Balances, kept equal to the ledger sum inside each transaction.
        Schema::create('wallets', function (Blueprint $table) {
            $table->foreignId('user_id')->primary()->constrained()->cascadeOnDelete();
            $table->unsignedBigInteger('coins')->default(0);
            $table->unsignedBigInteger('gems')->default(0);
            $table->timestamps();
        });

        // Append-only ledger (spec §9): every balance change is a row.
        Schema::create('wallet_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('currency', 8);
            $table->bigInteger('amount');
            $table->unsignedBigInteger('balance_after');
            $table->string('reason', 24);
            $table->string('reference', 64)->nullable();
            $table->string('idempotency_key', 96)->unique();
            $table->timestamp('created_at')->useCurrent();
            $table->index(['user_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('wallet_transactions');
        Schema::dropIfExists('wallets');
        Schema::dropIfExists('loadouts');
        Schema::dropIfExists('user_items');
        Schema::dropIfExists('items');
    }
};
