<?php

namespace App\Support;

use App\Models\Setting;

final class Phone
{
    public static function countryCode(): string
    {
        return (string) config('whatsapp.country_code', '967');
    }

    /**
     * القائمة الكاملة المدعومة في النظام (كتالوج ثابت).
     * اليمن أولاً كافتراضي للواجهة.
     *
     * @return list<string>
     */
    public static function catalogCountryCodes(): array
    {
        return ['967', '966', '971', '965', '973', '974', '968'];
    }

    /**
     * الدول المسموح ظهورها في تسجيل الدخول والتحقق.
     *
     * @return list<string>
     */
    public static function allowedCountryCodes(): array
    {
        $raw = Setting::getValue(Constants::SETTING_PHONE_ALLOWED_COUNTRIES);
        $codes = [];

        if (is_string($raw) && $raw !== '') {
            $decoded = json_decode($raw, true);
            if (is_array($decoded)) {
                $codes = $decoded;
            }
        } elseif (is_array($raw)) {
            $codes = $raw;
        }

        $catalog = self::catalogCountryCodes();
        $allowed = [];
        foreach ($codes as $code) {
            $code = (string) $code;
            if (in_array($code, $catalog, true) && ! in_array($code, $allowed, true)) {
                $allowed[] = $code;
            }
        }

        return $allowed !== [] ? $allowed : $catalog;
    }

    public static function isAllowedCountry(string $e164): bool
    {
        foreach (self::allowedCountryCodes() as $cc) {
            if (str_starts_with($e164, $cc)) {
                return true;
            }
        }

        return false;
    }

    public static function digits(string $raw): string
    {
        $mapped = strtr($raw, [
            '٠' => '0', '١' => '1', '٢' => '2', '٣' => '3', '٤' => '4',
            '٥' => '5', '٦' => '6', '٧' => '7', '٨' => '8', '٩' => '9',
            '۰' => '0', '۱' => '1', '۲' => '2', '۳' => '3', '۴' => '4',
            '۵' => '5', '۶' => '6', '۷' => '7', '۸' => '8', '۹' => '9',
        ]);

        return (string) preg_replace('/\D+/', '', $mapped);
    }

    public static function normalize(?string $raw): ?string
    {
        if ($raw === null || trim($raw) === '') {
            return null;
        }

        $digits = self::digits($raw);
        $cc = self::countryCode();

        if (str_starts_with($digits, '00'.$cc)) {
            $digits = substr($digits, 2);
        }

        if (str_starts_with($digits, $cc) && strlen($digits) === strlen($cc) + 9) {
            $national = substr($digits, strlen($cc));

            return self::isValidNational($national) ? $digits : null;
        }

        if (str_starts_with($digits, '0') && strlen($digits) === 10) {
            $digits = substr($digits, 1);
        }

        if (self::isValidNational($digits)) {
            return $cc.$digits;
        }

        if (self::isValidYemenNational($digits)) {
            return '967'.$digits;
        }

        return self::normalizeGcc($raw);
    }

    public static function normalizeGcc(?string $raw): ?string
    {
        if ($raw === null || trim($raw) === '') {
            return null;
        }

        $digits = self::digits($raw);
        if (str_starts_with($digits, '00')) {
            $digits = substr($digits, 2);
        }

        foreach (self::allowedCountryCodes() as $cc) {
            if (! str_starts_with($digits, $cc)) {
                continue;
            }

            $national = substr($digits, strlen($cc));
            if (self::isValidNationalForCountry($cc, $national)) {
                return $cc.$national;
            }

            return null;
        }

        if (str_starts_with($digits, '0') && strlen($digits) === 10) {
            $digits = substr($digits, 1);
        }

        $default = self::defaultAllowedCountryCode();
        if (self::isValidNationalForCountry($default, $digits)) {
            return $default.$digits;
        }

        return null;
    }

    public static function isValidYemenNational(string $national): bool
    {
        return (bool) preg_match('/^7\d{8}$/', $national);
    }

    /**
     * @return list<string>
     */
    public static function loginLookupCandidates(?string $raw): array
    {
        if ($raw === null || trim($raw) === '') {
            return [];
        }

        $candidates = [];
        $normalized = self::normalizeGcc($raw) ?? self::normalize($raw);
        if ($normalized !== null) {
            $candidates[] = $normalized;
        }

        $digits = self::digits($raw);
        if (str_starts_with($digits, '0') && strlen($digits) === 10) {
            $digits = substr($digits, 1);
        }

        if (strlen($digits) === 9) {
            foreach (self::allowedCountryCodes() as $cc) {
                if (self::isValidNationalForCountry($cc, $digits)) {
                    $candidates[] = $cc.$digits;
                }
            }
        }

        foreach (self::allowedCountryCodes() as $cc) {
            if (str_starts_with($digits, $cc)) {
                $candidates[] = $digits;
            }
        }

        return array_values(array_unique(array_filter($candidates)));
    }

    public static function companyE164(): ?string
    {
        return self::normalizeGcc((string) config('whatsapp.from_number'))
            ?? self::normalize((string) config('whatsapp.from_number'));
    }

    public static function companyNational(): ?string
    {
        $e164 = self::companyE164();

        return $e164 ? self::national($e164) : null;
    }

    public static function isValidNational(string $national): bool
    {
        return (bool) preg_match('/^5\d{8}$/', $national);
    }

    public static function national(string $e164): string
    {
        foreach (self::catalogCountryCodes() as $cc) {
            if (str_starts_with($e164, $cc)) {
                return substr($e164, strlen($cc));
            }
        }

        return $e164;
    }

    public static function display(string $e164): string
    {
        return '0'.self::national($e164);
    }

    public static function skipsOtp(?string $e164): bool
    {
        $normalized = self::normalizeGcc($e164);
        if ($normalized === null) {
            return false;
        }

        return in_array($normalized, StoreSettings::otpBypassPhones(), true);
    }

    /**
     * @return array{country_code: string, national: string}|null
     */
    public static function splitGcc(?string $e164): ?array
    {
        if ($e164 === null || trim($e164) === '') {
            return null;
        }

        $digits = self::digits($e164);
        foreach (self::catalogCountryCodes() as $cc) {
            if (! str_starts_with($digits, $cc)) {
                continue;
            }

            return [
                'country_code' => $cc,
                'national' => substr($digits, strlen($cc)),
            ];
        }

        return null;
    }

    public static function combineGcc(string $countryCode, ?string $national): ?string
    {
        if (! in_array($countryCode, self::catalogCountryCodes(), true)) {
            return null;
        }

        $digits = self::digits((string) $national);
        if ($digits === '') {
            return null;
        }

        if (str_starts_with($digits, '0')) {
            $digits = substr($digits, 1);
        }

        if (! self::isValidNationalForCountry($countryCode, $digits)) {
            return null;
        }

        return $countryCode.$digits;
    }

    /**
     * @return array<string, array{flag: string, name: string, dial: string}>
     */
    public static function countryCatalog(): array
    {
        return [
            '967' => ['flag' => '🇾🇪', 'name' => 'اليمن', 'dial' => '+967'],
            '966' => ['flag' => '🇸🇦', 'name' => 'السعودية', 'dial' => '+966'],
            '971' => ['flag' => '🇦🇪', 'name' => 'الإمارات', 'dial' => '+971'],
            '965' => ['flag' => '🇰🇼', 'name' => 'الكويت', 'dial' => '+965'],
            '973' => ['flag' => '🇧🇭', 'name' => 'البحرين', 'dial' => '+973'],
            '974' => ['flag' => '🇶🇦', 'name' => 'قطر', 'dial' => '+974'],
            '968' => ['flag' => '🇴🇲', 'name' => 'عُمان', 'dial' => '+968'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public static function countryOptions(): array
    {
        $options = [];
        foreach (self::countryCatalog() as $code => $item) {
            $options[$code] = $item['name'].' '.$item['dial'];
        }

        return $options;
    }

    public static function nationalPlaceholder(string $countryCode): string
    {
        return match ($countryCode) {
            '966', '971' => '5XXXXXXXX',
            '967' => '7XXXXXXXX',
            '965' => '5XXXXXXX',
            '973', '974' => '3XXXXXXX',
            '968' => '7XXXXXXX',
            default => 'XXXXXXXX',
        };
    }

    public static function maxNationalLength(string $countryCode): int
    {
        return match ($countryCode) {
            '965', '973', '974', '968' => 8,
            default => 9,
        };
    }

    public static function isValidNationalForCountry(string $cc, string $national): bool
    {
        return match ($cc) {
            '966', '971' => (bool) preg_match('/^5\d{8}$/', $national),
            '967' => self::isValidYemenNational($national),
            '965' => (bool) preg_match('/^[569]\d{7}$/', $national),
            '973' => (bool) preg_match('/^[36]\d{7}$/', $national),
            '974' => (bool) preg_match('/^[3567]\d{7}$/', $national),
            '968' => (bool) preg_match('/^[79]\d{7}$/', $national),
            default => false,
        };
    }

    public static function defaultAllowedCountryCode(): string
    {
        $configured = self::countryCode();
        $allowed = self::allowedCountryCodes();
        if (in_array($configured, $allowed, true)) {
            return $configured;
        }

        return $allowed[0] ?? '967';
    }

    /**
     * @return list<array{code: string, flag: string, name: string, dial: string, placeholder: string, max_national_length: int}>
     */
    public static function countryCatalogForApi(): array
    {
        $catalog = self::countryCatalog();
        $items = [];

        foreach (self::allowedCountryCodes() as $code) {
            $meta = $catalog[$code] ?? null;
            if ($meta === null) {
                continue;
            }
            $items[] = [
                'code' => $code,
                'flag' => $meta['flag'],
                'name' => $meta['name'],
                'dial' => $meta['dial'],
                'placeholder' => self::nationalPlaceholder($code),
                'max_national_length' => self::maxNationalLength($code),
            ];
        }

        return $items;
    }

    /**
     * @return array{default_country_code: string, countries: list<array{code: string, flag: string, name: string, dial: string, placeholder: string, max_national_length: int}>}
     */
    public static function startupPhonePayload(): array
    {
        return [
            'default_country_code' => self::defaultAllowedCountryCode(),
            'countries' => self::countryCatalogForApi(),
        ];
    }
}
