<?php

namespace App\Support;

final class AdminPermissions
{
    public const DASHBOARD = 'dashboard';

    public const STOREFRONT = 'storefront';

    public const CATALOG = 'catalog';

    public const PROMO = 'promo';

    public const OPERATIONS = 'operations';

    public const REPORTS = 'reports';

    public const DELIVERY = 'delivery';

    public const PAYMENTS = 'payments';

    public const SEARCH = 'search';

    public const NOTIFICATIONS = 'notifications';

    public const AI = 'ai';

    public const SETTINGS = 'settings';

    public const TEAM = 'team';

    /**
     * @return array<string, array{label: string, description: string, icon: string}>
     */
    public static function catalog(): array
    {
        return [
            self::DASHBOARD => [
                'label' => 'لوحة الرئيسية',
                'description' => 'عرض ملخص المتجر والإحصائيات.',
                'icon' => 'bi-speedometer2',
            ],
            self::STOREFRONT => [
                'label' => 'واجهة التطبيق',
                'description' => 'أقسام الرئيسية، البنرات، الصفحات، والشاشات.',
                'icon' => 'bi-phone',
            ],
            self::CATALOG => [
                'label' => 'الكتالوج',
                'description' => 'المنتجات والأقسام.',
                'icon' => 'bi-box-seam',
            ],
            self::PROMO => [
                'label' => 'التسعير والترويج',
                'description' => 'خصومات المنتجات والكوبونات.',
                'icon' => 'bi-percent',
            ],
            self::OPERATIONS => [
                'label' => 'العمليات',
                'description' => 'الطلبات، العملاء، الموصلون، والتقييمات.',
                'icon' => 'bi-bag-check',
            ],
            self::REPORTS => [
                'label' => 'التقارير',
                'description' => 'تقارير المبيعات والطلبات والمخزون والتصدير.',
                'icon' => 'bi-bar-chart-line',
            ],
            self::DELIVERY => [
                'label' => 'التوصيل',
                'description' => 'مناطق ورسوم وسياسة التوصيل.',
                'icon' => 'bi-truck',
            ],
            self::PAYMENTS => [
                'label' => 'طرق الدفع',
                'description' => 'إدارة وسائل الدفع في المتجر.',
                'icon' => 'bi-credit-card',
            ],
            self::SEARCH => [
                'label' => 'صفحة البحث',
                'description' => 'عبارات البحث والاقتراحات.',
                'icon' => 'bi-search',
            ],
            self::NOTIFICATIONS => [
                'label' => 'الإشعارات',
                'description' => 'حملات الإشعارات للعملاء.',
                'icon' => 'bi-bell',
            ],
            self::AI => [
                'label' => 'المساعد الذكي',
                'description' => 'إعدادات وتدريب المساعد.',
                'icon' => 'bi-stars',
            ],
            self::SETTINGS => [
                'label' => 'إعدادات المتجر',
                'description' => 'اسم المتجر، العملة، والهوية.',
                'icon' => 'bi-sliders',
            ],
            self::TEAM => [
                'label' => 'حسابات الفريق',
                'description' => 'إضافة وتعديل حسابات الموظفين وصلاحياتهم.',
                'icon' => 'bi-people',
            ],
        ];
    }

    /**
     * @return list<string>
     */
    public static function keys(): array
    {
        return array_keys(self::catalog());
    }

    /**
     * @return list<string>
     */
    public static function assignableKeys(): array
    {
        return array_values(array_filter(
            self::keys(),
            static fn (string $key): bool => $key !== self::TEAM,
        ));
    }

    public static function forRoute(?string $routeName): ?string
    {
        if ($routeName === null || $routeName === '') {
            return null;
        }

        if (str_starts_with($routeName, 'admin.profile.')
            || $routeName === 'admin.logout'
            || $routeName === 'admin.live'
            || $routeName === 'admin.live.read'
            || $routeName === 'admin.search'
        ) {
            return null;
        }

        return match (true) {
            $routeName === 'admin.dashboard' => self::DASHBOARD,
            str_starts_with($routeName, 'admin.home-sections.')
                || str_starts_with($routeName, 'admin.banners.')
                || str_starts_with($routeName, 'admin.dynamic-pages.')
                || str_starts_with($routeName, 'admin.pages.')
                || str_starts_with($routeName, 'admin.splash-screens.')
                || str_starts_with($routeName, 'admin.onboarding.')
                || str_starts_with($routeName, 'admin.bundles.') => self::STOREFRONT,
            str_starts_with($routeName, 'admin.products.')
                || str_starts_with($routeName, 'admin.categories.')
                || str_starts_with($routeName, 'admin.display-sections.') => self::CATALOG,
            str_starts_with($routeName, 'admin.offers.')
                || str_starts_with($routeName, 'admin.coupons.') => self::PROMO,
            str_starts_with($routeName, 'admin.orders.')
                || str_starts_with($routeName, 'admin.customers.')
                || str_starts_with($routeName, 'admin.couriers.')
                || str_starts_with($routeName, 'admin.reviews.') => self::OPERATIONS,
            str_starts_with($routeName, 'admin.reports.') => self::REPORTS,
            str_starts_with($routeName, 'admin.delivery.') => self::DELIVERY,
            str_starts_with($routeName, 'admin.payment-methods.') => self::PAYMENTS,
            str_starts_with($routeName, 'admin.search-placeholders.')
                || str_starts_with($routeName, 'admin.search-smart.')
                || str_starts_with($routeName, 'admin.search-trending.') => self::SEARCH,
            str_starts_with($routeName, 'admin.notifications.') => self::NOTIFICATIONS,
            str_starts_with($routeName, 'admin.ai.') => self::AI,
            str_starts_with($routeName, 'admin.settings.') => self::SETTINGS,
            str_starts_with($routeName, 'admin.staff.') => self::TEAM,
            default => self::DASHBOARD,
        };
    }

    public static function forMenuRoute(string $routeName): ?string
    {
        return self::forRoute($routeName);
    }
}
