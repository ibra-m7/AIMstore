<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (! Schema::hasColumn('users', 'notifications_orders_enabled')) {
                $table->boolean('notifications_orders_enabled')->default(true)->after('notifications_enabled');
            }
            if (! Schema::hasColumn('users', 'notifications_offers_enabled')) {
                $table->boolean('notifications_offers_enabled')->default(true)->after('notifications_orders_enabled');
            }
            if (! Schema::hasColumn('users', 'notifications_general_enabled')) {
                $table->boolean('notifications_general_enabled')->default(true)->after('notifications_offers_enabled');
            }
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $cols = collect([
                'notifications_orders_enabled',
                'notifications_offers_enabled',
                'notifications_general_enabled',
            ])->filter(fn (string $col) => Schema::hasColumn('users', $col))->all();

            if ($cols !== []) {
                $table->dropColumn($cols);
            }
        });
    }
};
