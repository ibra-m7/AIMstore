import 'package:flutter/material.dart';

/// أنماط النصوص المركزية — Graphik Arabic (نفس عائلة كيو).
///
/// مقياس الأدوار (تصميم مرجعي ~375):
/// ┌──────────────────────────────────────────────────────┐
/// │  display*     → شاشات تعريف / هيرو (39–53) Bold     │
/// │  headline*    → عناوين صفحات (25–33) Bold           │
/// │  sectionTitle → عناوين أقسام (23) Bold              │
/// │  title*       → بطاقات / أوراق (17–20) Semibold     │
/// │  productTitle → اسم المنتج (17) Medium              │
/// │  productMeta  → وزن / تفاصيل (14) Light             │
/// │  body*        → محتوى (15–18) Regular               │
/// │  label*       → شيبس / تنقل (14–16) Medium–Bold     │
/// │  price*       → أسعار (14–22) Regular–Bold          │
/// └──────────────────────────────────────────────────────┘
abstract final class AppTextStyles {
  static const String fontFamily = 'GraphikArabic';

  static const Color _darkText = Color(0xFF1B3A2D);
  static const Color _bodyText = Color(0xFF2D4A38);
  static const Color _mutedText = Color(0xFF6B8A76);

  static TextStyle _style({
    required double fontSize,
    required FontWeight fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing ?? 0,
      decoration: decoration,
    );
  }

  // ── Display ──────────────────────────────────────────────────────

  static TextStyle get displayLarge => _style(
        fontSize: 53,
        fontWeight: FontWeight.w700,
        color: _darkText,
        height: 1.2,
      );

  static TextStyle get displayMedium => _style(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: _darkText,
        height: 1.22,
      );

  static TextStyle get displaySmall => _style(
        fontSize: 39,
        fontWeight: FontWeight.w700,
        color: _darkText,
        height: 1.25,
      );

  // ── Headline ─────────────────────────────────────────────────────

  static TextStyle get headlineLarge => _style(
        fontSize: 33,
        fontWeight: FontWeight.w700,
        color: _darkText,
        height: 1.28,
      );

  static TextStyle get headlineMedium => _style(
        fontSize: 29,
        fontWeight: FontWeight.w700,
        color: _darkText,
        height: 1.3,
      );

  /// عنوان صفحة — مثل «المقاضي»
  static TextStyle get headlineSmall => _style(
        fontSize: 25,
        fontWeight: FontWeight.w700,
        color: _darkText,
        height: 1.3,
      );

  // ── Title ────────────────────────────────────────────────────────

  static TextStyle get titleLarge => _style(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _darkText,
        height: 1.35,
      );

  static TextStyle get titleMedium => _style(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _darkText,
        height: 1.4,
      );

  static TextStyle get titleSmall => _style(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: _bodyText,
        height: 1.4,
      );

  // ── Body ─────────────────────────────────────────────────────────

  static TextStyle get bodyLarge => _style(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: _bodyText,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _style(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: _bodyText,
        height: 1.5,
      );

  static TextStyle get bodySmall => _style(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: _mutedText,
        height: 1.45,
      );

  // ── Label ────────────────────────────────────────────────────────

  static TextStyle get labelLarge => _style(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: _darkText,
        height: 1.35,
      );

  static TextStyle get labelMedium => _style(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: _bodyText,
        height: 1.35,
      );

  static TextStyle get labelSmall => _style(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _mutedText,
        height: 1.3,
      );

  // ── Specialized (Q-like roles) ───────────────────────────────────

  /// عنوان قسم — مثل «المنتجات الطازجة»
  static TextStyle get sectionTitle => _style(
        fontSize: 23,
        fontWeight: FontWeight.w700,
        color: _darkText,
        height: 1.3,
      );

  /// اسم المنتج في الكروت
  static TextStyle get productTitle => _style(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: _darkText,
        height: 1.35,
      );

  /// وزن / تفاصيل ثانوية تحت اسم المنتج
  static TextStyle get productMeta => _style(
        fontSize: 14,
        fontWeight: FontWeight.w300,
        color: _mutedText,
        height: 1.3,
      );

  static TextStyle get productDescription => _style(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: _bodyText,
        height: 1.55,
      );

  static TextStyle get price => _style(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFE53935),
        height: 1.15,
      );

  static TextStyle get priceStrikethrough => _style(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _mutedText,
        decoration: TextDecoration.lineThrough,
        height: 1.15,
      );

  static TextStyle get category => _style(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: _bodyText,
        height: 1.3,
      );

  static TextStyle get viewAll => _style(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF88D498),
        height: 1.2,
      );

  static TextStyle get navLabel => _style(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _mutedText,
        height: 1.2,
      );

  static TextStyle get navLabelActive => _style(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: _darkText,
        height: 1.2,
      );

  static TextStyle get searchHint => _style(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: _mutedText,
        height: 1.35,
      );

  static TextStyle get chatMessageSent => _style(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: Colors.white,
        height: 1.5,
      );

  static TextStyle get chatMessageReceived => _style(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: _darkText,
        height: 1.5,
      );

  static TextStyle get inputLabel => _style(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: _mutedText,
        height: 1.35,
      );

  static TextStyle get inputHint => _style(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: _mutedText.withAlpha(180),
        height: 1.35,
      );

  static TextStyle get buttonPrimary => _style(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );

  static TextStyle get buttonSecondary => _style(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF5FAF72),
      );

  static TextStyle get appBarTitle => _style(
        fontSize: 25,
        fontWeight: FontWeight.w700,
        color: _darkText,
        height: 1.25,
      );
}
