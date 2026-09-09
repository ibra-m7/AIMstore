import 'package:flutter/material.dart';
import 'app_text_styles.dart';

/// الهوية البصرية الكاملة للتطبيق — روعة الخمسة
///
/// مستوحى من تطبيق "كيو" مع لون العلامة الأخضر الفاتح #88D498
/// الخلفية: منت فاتح مريح للعين
/// الحواف: دائرية للغاية (pill-shaped) — 30.0 للبحث والأزرار، 25.0 للبطاقات
abstract final class AppTheme {
  // ── الألوان الأساسية (علامة روعة الخمسة) ──────────────────────────────────
  static const Color primary        = Color(0xFF88D498);
  static const Color primaryDark    = Color(0xFF5FAF72);
  static const Color primaryLight   = Color(0xFFC8ECD3);
  static const Color primarySurface = Color(0xFFE8F8EC);

  /// خلفية حاوية صورة المنتج في الكارد (رمادي فاتح محايد)
  static const Color productImageWell = Color(0xFFF5F5F5);

  /// خلفية الـ Scaffold
  static const Color background     = Color(0xFFF0FAF3);
  static const Color surface        = Color(0xFFFFFFFF); // سطح البطاقات أبيض نقي

  static const Color darkText       = Color(0xFF1B3A2D); // نص داكن مائل للأخضر
  static const Color bodyText       = Color(0xFF2D4A38); // نص المحتوى
  static const Color mutedText      = Color(0xFF6B8A76); // نص خافت
  static const Color badgeNumber    = Color(0xFF1A7A3C); // أرقام الـ Badge — أخضر غامق واضح
  static const Color cardShadow     = Color(0x14000000); // ظل البطاقات (8% أسود)

  // ── ألوان Toast الموحّد (خلفيات ناعمة + نص داكن) ─────────────────────────
  static const Color toastErrorBg     = Color(0xFFFFEBEE);
  static const Color toastErrorText   = Color(0xFFC62828);
  static const Color toastSuccessBg   = Color(0xFFE8F8ED);
  static const Color toastSuccessText = Color(0xFF2D6A4F);
  static const Color toastWarningBg   = Color(0xFFFFF8E1);
  static const Color toastWarningText = Color(0xFFE65100);
  static const Color toastInfoBg      = Color(0xFFF5F7F6);
  static const Color toastInfoText    = Color(0xFF1B3A2D);

  // ── نصف قطر الحواف (Extra Rounded — pill-shaped) ─────────────────────────
  static const double radiusPill = 50.0; // شريط البحث — بيضاوي تماماً
  static const double radiusXL   = 25.0; // بطاقات وأزرار رئيسية
  static const double radiusLg   = 20.0; // حوارات وـ BottomSheet
  static const double radiusMd   = 16.0; // حقول الإدخال والـ SnackBar
  static const double radiusSm   = 30.0; // Chips — pill-shaped

  // ═════════════════════════════════════════════════════════════════════════
  static ThemeData buildTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      onPrimary: Colors.white,
      secondary: primaryDark,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: darkText,
      surfaceContainerHighest: primarySurface,
      brightness: Brightness.light,
    );

    TextStyle? withSar(TextStyle? style) {
      if (style == null) return null;
      final fallbacks = [...?style.fontFamilyFallback];
      if (!fallbacks.contains('SaudiRiyal')) {
        fallbacks.add('SaudiRiyal');
      }
      return style.copyWith(fontFamilyFallback: fallbacks);
    }

    final textTheme = TextTheme(
      displayLarge: withSar(AppTextStyles.displayLarge),
      displayMedium: withSar(AppTextStyles.displayMedium),
      displaySmall: withSar(AppTextStyles.displaySmall),
      headlineLarge: withSar(AppTextStyles.headlineLarge),
      headlineMedium: withSar(AppTextStyles.headlineMedium),
      headlineSmall: withSar(AppTextStyles.headlineSmall),
      titleLarge: withSar(AppTextStyles.titleLarge),
      titleMedium: withSar(AppTextStyles.titleMedium),
      titleSmall: withSar(AppTextStyles.titleSmall),
      bodyLarge: withSar(AppTextStyles.bodyLarge),
      bodyMedium: withSar(AppTextStyles.bodyMedium),
      bodySmall: withSar(AppTextStyles.bodySmall),
      labelLarge: withSar(AppTextStyles.labelLarge),
      labelMedium: withSar(AppTextStyles.labelMedium),
      labelSmall: withSar(AppTextStyles.labelSmall),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: AppTextStyles.fontFamily,
      textTheme: textTheme,

      // ── AppBar — فاتح مع نص داكن (مقياس كيو) ──────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: darkText,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.appBarTitle,
        toolbarTextStyle: AppTextStyles.bodyMedium.copyWith(color: bodyText),
        iconTheme: const IconThemeData(color: darkText),
      ),

      // ── ElevatedButton ─────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 54),
          textStyle: AppTextStyles.buttonPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXL),
          ),
        ),
      ),

      // ── TextButton ──────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDark,
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: primaryDark,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXL),
          ),
        ),
      ),

      // ── OutlinedButton ──────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDark,
          side: const BorderSide(color: primary, width: 1.5),
          minimumSize: const Size(double.infinity, 54),
          textStyle: AppTextStyles.buttonSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXL),
          ),
        ),
      ),

      // ── Card — بيضاء نقية بظل ناعم بلا حدود (مثل الصورة المرجعية) ────
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shadowColor: cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),

      // ── Input Fields — pill-shaped كما في الصورة المرجعية ──────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusPill),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusPill),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusPill),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusPill),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusPill),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
        ),
        labelStyle: AppTextStyles.inputLabel,
        hintStyle: AppTextStyles.searchHint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),

      // ── SnackBar ────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: darkText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // ── Dialog ──────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        titleTextStyle: AppTextStyles.sectionTitle,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: mutedText),
      ),

      // ── BottomSheet ─────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: Colors.transparent,
        dragHandleSize: Size.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusLg),
          ),
        ),
        showDragHandle: false,
      ),

      // ── Chip — pill-shaped (مثل تصنيفات الصورة المرجعية) ────────────────
      chipTheme: ChipThemeData(
        backgroundColor: primarySurface,
        selectedColor: primary,
        checkmarkColor: Colors.white,
        labelStyle: AppTextStyles.labelLarge.copyWith(color: primaryDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          side: const BorderSide(color: primaryLight),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ── Bottom Navigation Bar — بيضاء مرتفعة قليلاً مع أيقونة وسطى بارزة
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primaryDark,
        unselectedItemColor: mutedText,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTextStyles.navLabelActive,
        unselectedLabelStyle: AppTextStyles.navLabel,
        elevation: 8,
      ),

      // ── FloatingActionButton ────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ── Badge — عدّاد بدون خلفية ───────────────────────────────────────
      badgeTheme: const BadgeThemeData(
        backgroundColor: Colors.transparent,
        textColor: badgeNumber,
        padding: EdgeInsets.zero,
        smallSize: 8,
        largeSize: 14,
      ),
      // ── Divider ─────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: primaryLight,
        thickness: 1,
        space: 1,
      ),

      // ── ListTile ────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
