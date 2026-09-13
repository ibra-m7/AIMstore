<?php

namespace Database\Seeders;

use App\Enums\UserRole;
use App\Models\User;
use Illuminate\Database\Seeder;

class AdminUserSeeder extends Seeder
{
    public function run(): void
    {
        $admin = User::query()->firstOrNew(['email' => 'admin@aimstore.test']);

        $admin->forceFill([
            'name' => 'مدير النظام',
            'password' => 'password',
            'role' => UserRole::Admin,
            'locale' => 'ar',
            'email_verified_at' => now(),
        ])->save();
    }
}
