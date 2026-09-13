<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->string('store_aisle', 80)->nullable()->after('quantity_label');
            $table->string('store_shelf', 80)->nullable()->after('store_aisle');
            $table->string('store_location_note', 255)->nullable()->after('store_shelf');
        });
    }

    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropColumn(['store_aisle', 'store_shelf', 'store_location_note']);
        });
    }
};
