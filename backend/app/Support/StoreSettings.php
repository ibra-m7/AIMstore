<?php

namespace App\Support;

use App\Enums\PaymentMethod;
use App\Models\Setting;
use App\Models\StorePaymentMethod;
use App\Services\Admin\SearchDiscoveryService;
use App\Services\Admin\SearchPlaceholderService;
use App\Services\Admin\SearchSmartSuggestionService;
use App\Support\HomeFeedRealtime;
use App\Support\Media;

final class StoreSettings
{
    public static function shippingFee(): float
    {
        return (float) Setting::getValue(Constants::SETTING_SHIPPING_FEE, Constants::SHIPPING_FEE);
    }

    public static function freeShippingThreshold(): float
    {
        return (float) Setting::getValue(
            Constants::SETTING_FREE_SHIPPING_THRESHOLD,
            Constants::FREE_SHIPPING_THRESHOLD,
        );
    }

    public static function currency(): string
    {
        return AppStrings::CURRENCY;
    }

    public static function bankIban(): string
    {
        return (string) Setting::getValue(Constants::SETTING_BANK_IBAN, '');
    }

    public static function bankName(): string
    {
        return (string) Setting::getValue(Constants::SETTING_BANK_NAME, 'بنك اليمن');
    }

    public static function marketingSoldCount(): int
    {
        return max(0, (int) Setting::getValue(Constants::SETTING_MARKETING_SOLD_COUNT, 0));
    }

    /**
     * When enabled, «يُشترى معه» is filled by the affinity engine for all products.
     * Manual complementary selections always show regardless of this flag.
     */
    public static function autoProductRecommendations(): bool
    {
        return filter_var(
            Setting::getValue(Constants::SETTING_AUTO_PRODUCT_RECOMMENDATIONS, '0'),
            FILTER_VALIDATE_BOOLEAN
        );
    }

    public static function marketingSoldScope(): string
    {
        $scope = (string) Setting::getValue(Constants::SETTING_MARKETING_SOLD_SCOPE, 'all');

        return $scope === 'selected' ? 'selected' : 'all';
    }

    /**
     * @return list<int>|null null = لم يُحفظ بعد (يُعامل ككل المنتجات)
     */
    public static function marketingSoldProductIds(): ?array
    {
        $raw = Setting::getValue(Constants::SETTING_MARKETING_SOLD_PRODUCT_IDS, null);
        if ($raw === null || $raw === '') {
            return null;
        }

        $ids = json_decode((string) $raw, true);
        if (! is_array($ids)) {
            return null;
        }

        return array_values(array_unique(array_map('intval', $ids)));
    }

    public static function marketingSoldCountFor(mixed $product): int
    {
        $count = self::marketingSoldCount();
        if ($count <= 0) {
            return 0;
        }

        if (self::marketingSoldScope() !== 'selected') {
            return $count;
        }

        $ids = self::marketingSoldProductIds() ?? [];
        $productId = is_object($product) ? (int) ($product->id ?? 0) : (int) $product;

        return in_array($productId, $ids, true) ? $count : 0;
    }

    public static function fallbackProductImageUrl(): string
    {
        $value = trim((string) Setting::getValue(Constants::SETTING_FALLBACK_PRODUCT_IMAGE, ''));
        if ($value === '') {
            return '';
        }

        if (str_starts_with($value, 'http://') || str_starts_with($value, 'https://')) {
            return $value;
        }

        if (! str_starts_with($value, 'data:') && Media::isMissingLocal($value)) {
            return '';
        }

        return Media::absoluteUrl('media/fallback-product').'?v='.substr(sha1($value), 0, 10);
    }

    public static function homeLogoUrl(): string
    {
        $value = trim((string) Setting::getValue(Constants::SETTING_HOME_LOGO, ''));
        if ($value === '') {
            $public = public_path('images/home_logo.png');
            if (is_file($public)) {
                return Media::absoluteUrl('media/home-logo').'?v='.substr(sha1((string) filemtime($public)), 0, 10);
            }

            return '';
        }

        if (str_starts_with($value, 'http://') || str_starts_with($value, 'https://')) {
            return $value;
        }

        if (! str_starts_with($value, 'data:') && Media::isMissingLocal($value)) {
            $public = public_path('images/home_logo.png');
            if (is_file($public)) {
                return Media::absoluteUrl('media/home-logo').'?v='.substr(sha1((string) filemtime($public)), 0, 10);
            }

            return '';
        }

        return Media::absoluteUrl('media/home-logo').'?v='.substr(sha1($value), 0, 10);
    }

    public static function messageUsPhone(): string
    {
        return trim((string) Setting::getValue(Constants::SETTING_MESSAGE_US_PHONE, ''));
    }

    public static function showDiscountsAsBanner(): bool
    {
        $raw = Setting::getValue(Constants::SETTING_SHOW_DISCOUNTS_AS_BANNER, '1');

        return ! in_array((string) $raw, ['0', 'false', 'off', 'no'], true);
    }

    public static function showOffersAsBanner(): bool
    {
        $raw = Setting::getValue(Constants::SETTING_SHOW_OFFERS_AS_BANNER, '1');

        return ! in_array((string) $raw, ['0', 'false', 'off', 'no'], true);
    }

    /**
     * @return list<array{name: string, phone: string}>
     */
    public static function customerServiceNumbers(): array
    {
        $raw = Setting::getValue(Constants::SETTING_CUSTOMER_SERVICE_NUMBERS, '[]');
        $decoded = json_decode((string) $raw, true);
        if (! is_array($decoded)) {
            return [];
        }

        $items = [];
        foreach ($decoded as $row) {
            if (! is_array($row)) {
                continue;
            }
            $name = trim((string) ($row['name'] ?? ''));
            $phone = trim((string) ($row['phone'] ?? ''));
            if ($name === '' || $phone === '') {
                continue;
            }
            $items[] = [
                'name' => $name,
                'phone' => $phone,
            ];
        }

        return $items;
    }

    /**
     * @return list<string>
     */
    public static function otpBypassPhones(): array
    {
        $raw = Setting::getValue(Constants::SETTING_OTP_BYPASS_PHONES, '[]');
        $decoded = json_decode((string) $raw, true);
        if (! is_array($decoded)) {
            return [];
        }

        $phones = [];
        foreach ($decoded as $phone) {
            $value = trim((string) $phone);
            if ($value !== '') {
                $phones[] = $value;
            }
        }

        return array_values(array_unique($phones));
    }

    public static function payload(): array
    {
        return [
            'country' => 'YE',
            'country_name' => 'الجمهورية اليمنية',
            'currency' => self::currency(),
            'currency_code' => Constants::CURRENCY_CODE,
            'shipping_fee' => self::shippingFee(),
            'free_shipping_threshold' => self::freeShippingThreshold(),
            'delivery' => DeliverySettings::payload(),
            'phone_country_code' => Phone::countryCode(),
            'bank_iban' => self::bankIban(),
            'bank_name' => self::bankName(),
            'marketing_sold_count' => self::marketingSoldCount(),
            'fallback_product_image_url' => self::fallbackProductImageUrl(),
            'home_logo_url' => self::homeLogoUrl(),
            'message_us_phone' => self::messageUsPhone(),
            'customer_service_numbers' => self::customerServiceNumbers(),
            'show_discounts_as_banner' => self::showDiscountsAsBanner(),
            'show_offers_as_banner' => self::showOffersAsBanner(),
            'payment_methods' => self::checkoutPaymentMethods(),
            'search_placeholders' => SearchPlaceholderService::activePhrases(),
            'search_smart_suggestions' => SearchSmartSuggestionService::activePhrases(),
            'search_trending' => app(SearchDiscoveryService::class)->trendingTerms(),
            'realtime' => HomeFeedRealtime::clientConfig(),
        ];
    }

    /**
     * @return list<array{id: string, label: string, hint: string, icon: string, icon_url: string}>
     */
    public static function checkoutPaymentMethods(): array
    {
        $fromStore = StorePaymentMethod::query()
            ->active()
            ->ordered()
            ->get()
            ->map(fn (StorePaymentMethod $method) => $method->toCheckoutOption())
            ->values()
            ->all();

        if ($fromStore !== []) {
            return self::pinCashFirst($fromStore);
        }

        return self::pinCashFirst(
            collect(PaymentMethod::checkoutOptions())
                ->map(fn (PaymentMethod $method) => [
                    'id' => $method->value,
                    'label' => $method->label(),
                    'hint' => $method->hint(),
                    'icon' => 'bi-credit-card',
                    'icon_url' => '',
                ])
                ->values()
                ->all()
        );
    }

    /**
     * @param  list<array{id: string, label: string, hint: string, icon: string, icon_url: string}>  $methods
     * @return list<array{id: string, label: string, hint: string, icon: string, icon_url: string}>
     */
    private static function pinCashFirst(array $methods): array
    {
        $cash = collect($methods)->firstWhere('id', 'cash');
        $others = collect($methods)
            ->reject(fn (array $method) => ($method['id'] ?? '') === 'cash')
            ->values();

        return $cash !== null
            ? collect([$cash])->merge($others)->all()
            : $others->all();
    }

    /**
     * @return list<string>
     */
    public static function activePaymentSlugs(): array
    {
        return collect(self::checkoutPaymentMethods())
            ->pluck('id')
            ->filter()
            ->values()
            ->all();
    }
}
