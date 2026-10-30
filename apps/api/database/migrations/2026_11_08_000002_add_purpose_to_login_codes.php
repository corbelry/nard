<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// A deletion-page code never signs in, and issuing one leaves a pending
// sign-in code alone (security review 2026-10-30).
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('login_codes', function (Blueprint $table) {
            $table->string('purpose', 16)->default('sign_in')->after('email');
        });
    }

    public function down(): void
    {
        Schema::table('login_codes', function (Blueprint $table) {
            $table->dropColumn('purpose');
        });
    }
};
