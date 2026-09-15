<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        $this->call([
            AdminUserSeeder::class,
            CatalogSeeder::class,
            ProductDetailsSeeder::class,
            CouponSeeder::class,
            // Policy/terms pages are optional — seed explicitly with:
            // php artisan db:seed --class=ContentPageSeeder
        ]);
    }
}
