<?php

namespace Database\Seeders;

use App\Enums\PagePlacement;
use App\Models\Page;
use Illuminate\Database\Seeder;

class ContentPageSeeder extends Seeder
{
    public function run(): void
    {
        $pages = [
            [
                'slug' => 'privacy-policy',
                'title' => 'سياسة الخصوصية',
                'button_label' => 'سياسة الخصوصية',
                'placement' => PagePlacement::ProfileFooter,
                'content' => "<h2>سياسة الخصوصية</h2>\n<p>نحن نحترم خصوصيتك. توضّح هذه الصفحة كيف نجمع ونستخدم بياناتك عند استخدام تطبيق AIMstore.</p>\n<p>يمكنك تعديل هذا النص من لوحة التحكم.</p>",
                'sort_order' => 0,
                'is_active' => true,
            ],
            [
                'slug' => 'terms-of-use',
                'title' => 'شروط الاستخدام',
                'button_label' => 'شروط الاستخدام',
                'placement' => PagePlacement::AuthTerms,
                'content' => "<h2>شروط الاستخدام</h2>\n<p>باستخدامك لتطبيق AIMstore فإنك توافق على الالتزام بهذه الشروط.</p>\n<p>يمكنك تعديل هذا النص من لوحة التحكم.</p>",
                'sort_order' => 0,
                'is_active' => true,
            ],
        ];

        foreach ($pages as $page) {
            Page::query()->updateOrCreate(
                ['slug' => $page['slug']],
                $page,
            );
        }
    }
}
