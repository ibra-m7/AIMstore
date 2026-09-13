<?php

namespace App\Support;

/**
 * الهوية البصرية — مطابقة لـ mobile/lib/core/theme/app_theme.dart
 */
final class Theme
{
    public const PRIMARY = '#003399';

    public const PRIMARY_DARK = '#002266';

    public const PRIMARY_LIGHT = '#A8B8E0';

    public const PRIMARY_SURFACE = '#E8EEF8';

    public const BACKGROUND = '#F0F4FA';

    public const SURFACE = '#FFFFFF';

    public const SIDEBAR = '#001A4D';

    public const SIDEBAR_HOVER = '#002266';

    public const DARK_TEXT = '#0A1F4D';

    public const BODY_TEXT = '#1A2F5A';

    public const MUTED_TEXT = '#6B7A99';

    public const PRICE_RED = '#E31E24';

    public const DANGER = '#E31E24';

    public const ACCENT = '#E31E24';

    public const WARNING = '#F5A623';

    public const INFO = '#0288D1';

    public const RADIUS_SM = '12px';

    public const RADIUS_MD = '16px';

    public const RADIUS_LG = '20px';

    public const RADIUS_XL = '24px';

    public const RADIUS_PILL = '50px';

    public const FONT_FAMILY = '"SaudiRiyal", "Cairo", sans-serif';

    /**
     * @return array<string, string>
     */
    public static function cssVariables(): array
    {
        return [
            '--color-primary' => self::PRIMARY,
            '--color-primary-dark' => self::PRIMARY_DARK,
            '--color-primary-light' => self::PRIMARY_LIGHT,
            '--color-primary-surface' => self::PRIMARY_SURFACE,
            '--color-background' => self::BACKGROUND,
            '--color-surface' => self::SURFACE,
            '--color-sidebar' => self::SIDEBAR,
            '--color-sidebar-hover' => self::SIDEBAR_HOVER,
            '--color-dark-text' => self::DARK_TEXT,
            '--color-body-text' => self::BODY_TEXT,
            '--color-muted-text' => self::MUTED_TEXT,
            '--color-accent' => self::ACCENT,
            '--color-price' => self::PRICE_RED,
            '--color-danger' => self::DANGER,
            '--radius-sm' => self::RADIUS_SM,
            '--radius-md' => self::RADIUS_MD,
            '--radius-lg' => self::RADIUS_LG,
            '--radius-xl' => self::RADIUS_XL,
            '--radius-pill' => self::RADIUS_PILL,
            '--font-family' => self::FONT_FAMILY,
        ];
    }

    public static function cssVariablesString(): string
    {
        $pairs = [];

        foreach (self::cssVariables() as $name => $value) {
            $pairs[] = $name.': '.$value;
        }

        return implode('; ', $pairs);
    }
}
