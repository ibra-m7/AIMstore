<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('home_sections', function (Blueprint $table) {
            $table->unsignedTinyInteger('title_font_size')->default(18)->after('emphasize_subtitle');
            $table->unsignedTinyInteger('subtitle_font_size')->default(10)->after('title_font_size');
            $table->unsignedSmallInteger('card_width')->default(118)->after('subtitle_font_size');
            $table->unsignedSmallInteger('row_height')->nullable()->after('card_width');
            $table->unsignedTinyInteger('item_spacing')->default(8)->after('row_height');
            $table->unsignedTinyInteger('padding_top')->default(14)->after('item_spacing');
            $table->unsignedTinyInteger('padding_bottom')->default(12)->after('padding_top');
        });
    }

    public function down(): void
    {
        Schema::table('home_sections', function (Blueprint $table) {
            $table->dropColumn([
                'title_font_size',
                'subtitle_font_size',
                'card_width',
                'row_height',
                'item_spacing',
                'padding_top',
                'padding_bottom',
            ]);
        });
    }
};
