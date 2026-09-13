<?php

namespace App\Enums;

enum PagePlacement: string
{
    case ProfileFooter = 'profile_footer';
    case ProfileMenu = 'profile_menu';
    case Settings = 'settings';
    case AuthTerms = 'auth_terms';

    public function label(): string
    {
        return match ($this) {
            self::ProfileFooter => 'تذييل صفحة حسابي',
            self::ProfileMenu => 'صف داخل قائمة حسابي',
            self::Settings => 'صف داخل شاشة الإعدادات',
            self::AuthTerms => 'رابط شروط الاستخدام عند التسجيل/الدخول',
        };
    }

    /**
     * @return list<string>
     */
    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }
}
