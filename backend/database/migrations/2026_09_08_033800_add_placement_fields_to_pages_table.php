<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('pages', function (Blueprint $table) {
            $table->string('placement', 40)->default('profile_footer')->after('content');
            $table->string('button_label')->nullable()->after('placement');
            $table->unsignedInteger('sort_order')->default(0)->after('button_label');
            $table->index(['placement', 'is_active']);
        });
    }

    public function down(): void
    {
        Schema::table('pages', function (Blueprint $table) {
            $table->dropIndex(['placement', 'is_active']);
            $table->dropColumn(['placement', 'button_label', 'sort_order']);
        });
    }
};
