import 'package:flutter/material.dart';

/// مقياس موحّد على مقاس تصميم 375×812.
/// الحد الأدنى/الأقصى يمنع اختلاف الشكل بين جوال صغير وكبير.
class AppScale {
  static const designWidth = 375.0;
  static const designHeight = 812.0;
  static const minScale = 0.88;
  static const maxScale = 1.00;
  static const compact = 0.90;
  static const productCardAspect = 0.56;
  static const homeGridCrossAxisCount = 2;
  /// نسبة عرض/ارتفاع كارد الشبكة — أقل = حاوية الصورة أطول (النص ثابت)
  static const homeGridCardAspect = 0.86;
  static const homeGridRowGap = 14;
  /// ── الصورة فقط داخل كارد الصفحة الرئيسية (لا تغيّر حجم الكارد) ──
  /// عرض الصورة كنسبة من حاوية الصورة: 1.0 = 100%
  static const homeProductImageWidthFactor = 1.0;
  /// فراغ أعلى الصورة داخل الحاوية
  static const homeProductImageTopGap = 6;
  /// فراغ أسفل الصورة داخل الحاوية
  static const homeProductImageBottomGap = 6;
  /// فراغ جانبي خفيف (إن كان العرض 100%)
  static const homeProductImageSideGap = 4;
  static const bannerAspect = 351 / 236;

  final double scale;
  final Size size;

  const AppScale._(this.scale, this.size);

  factory AppScale.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return AppScale._(
      (size.width / designWidth).clamp(minScale, maxScale),
      size,
    );
  }

  double s(num value) => value * scale * compact;

  double get width => size.width;

  double get pagePad => s(16);

  double get searchH => s(42).clamp(40.0, 46.0);

  double get logoRow => s(58).clamp(52.0, 64.0);

  double get bannerBlend => s(4);

  double get bannerHeight =>
      ((width - s(28)) / bannerAspect).clamp(s(188), s(220));

  /// عرض بطاقة المنتج: نفس النسبة تقريباً من الشاشة على كل الجوالات.
  double get productCardWidth => (width * 0.36).clamp(s(128), s(146));

  double get productCardHeight => productCardWidth / productCardAspect;

  double get homeGridMainAxisSpacing => s(homeGridRowGap);

  double get categoryItemWidth => s(84);

  double get categoryCircle => s(46);

  double get categoryCircleSelected => s(62);

  double get categoryRing => s(2);

  /// تكبير محتوى الصورة داخل الدائرة دون تكبير الإطار.
  double get categoryImageZoom => 1.48;

  double get categoryStripHeight =>
      categoryCircleSelected + categoryRing * 2 + s(8) + s(12) * 2 + s(6);
}
