import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';

/// سعر بنمط كيو — من اليمين: 6,00 ثم ﷼ ثم السعر القديم.
/// الصف الداخلي LTR دائماً حتى لا يتداخل الرمز مع الهللات في RTL.
class PriceLine extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final Color color;
  final double priceSize;
  final double currencySize;
  final double? maxHeight;
  final AlignmentGeometry alignment;
  final bool swapPrices;

  const PriceLine({
    super.key,
    required this.price,
    this.originalPrice,
    this.color = const Color(0xFFE53935),
    this.priceSize = 14,
    this.currencySize = 0,
    this.maxHeight,
    this.alignment = AlignmentDirectional.centerStart,
    this.swapPrices = false,
  });

  bool get _hasDiscount =>
      originalPrice != null && originalPrice! > price;

  static const _originalColor = Color(0xFF757575);
  static const _priceFont = AppTextStyles.fontFamily;

  ({String integer, String fraction}) _splitPrice(double value) {
    final fixed = value.toStringAsFixed(2);
    final dot = fixed.indexOf('.');
    return (
      integer: fixed.substring(0, dot),
      fraction: fixed.substring(dot + 1),
    );
  }

  String _formatOriginal(double value) {
    if ((value * 100).round() % 100 == 0) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  ({
    double integer,
    double decimal,
    double currency,
    double original,
    double numberGap,
    double currencyGap,
    double originalGap,
  }) get _sizes {
    if (maxHeight != null) {
      final row = maxHeight!;
      final integer = row * 0.90;
      return (
        integer: integer,
        decimal: integer * 0.62,
        currency: currencySize > 0 ? currencySize : integer * 0.72,
        original: integer * 0.74,
        numberGap: 1,
        currencyGap: 4,
        originalGap: 8,
      );
    }

    final base = priceSize;
    final integer = base * 1.48;
    return (
      integer: integer,
      decimal: base * 0.72,
      currency: currencySize > 0 ? currencySize : integer * 0.72,
      original: base * 0.82,
      numberGap: 1,
      currencyGap: 4,
      originalGap: 8,
    );
  }

  TextStyle _priceStyle({
    required double size,
    FontWeight weight = FontWeight.w500,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: _priceFont,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1,
      letterSpacing: letterSpacing,
    );
  }

  /// 13,12 — Text.rich واحد حتى تبقى أرقام الجزء الصحيح متلاصقة والفاصلة واضحة.
  Widget _buildAmount() {
    final parts = _splitPrice(price);
    final sizes = _sizes;
    final integerStyle = _priceStyle(
      size: sizes.integer,
      weight: FontWeight.w500,
      letterSpacing: -0.8,
    );
    final decimalStyle = _priceStyle(
      size: sizes.decimal,
      weight: FontWeight.w400,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: parts.integer, style: integerStyle),
          TextSpan(text: ',', style: decimalStyle.copyWith(letterSpacing: 0)),
          TextSpan(text: parts.fraction, style: decimalStyle),
        ],
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      overflow: TextOverflow.clip,
      softWrap: false,
    );
  }

  Widget _buildCurrency({
    required double size,
    required Color textColor,
    TextDecoration? decoration,
  }) {
    return Text(
      AppStrings.currency,
      style: TextStyle(
        fontFamily: 'SaudiRiyal',
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: textColor,
        decoration: decoration,
        decorationColor: textColor,
        height: 1,
      ),
    );
  }

  Widget _buildOriginalPrice() {
    final text = _formatOriginal(originalPrice!);
    final size = _sizes.original;

    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildCurrency(
          size: size,
          textColor: _originalColor,
          decoration: TextDecoration.lineThrough,
        ),
        const SizedBox(width: 2),
        Text(
          text,
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontFamily: _priceFont,
            fontSize: size,
            color: _originalColor,
            decoration: TextDecoration.lineThrough,
            decorationColor: _originalColor,
            fontWeight: FontWeight.w400,
            height: 1,
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final sizes = _sizes;
    final amount = _buildAmount();
    final currency = _buildCurrency(size: sizes.currency, textColor: color);
    final original = _hasDiscount ? _buildOriginalPrice() : null;

    final current = Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          currency,
          SizedBox(width: sizes.currencyGap),
          amount,
        ],
      ),
    );

    if (original == null) return current;

    // نفس الصف: السعر الأصلي يساراً ثم السعر بعد الخصم (مثل السابق).
    final leading = swapPrices ? current : original;
    final trailing = swapPrices ? original : current;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading,
          SizedBox(width: sizes.originalGap),
          trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignment,
      child: _buildContent(),
    );

    if (maxHeight == null) {
      return Align(alignment: alignment, child: content);
    }

    return SizedBox(
      height: maxHeight,
      width: double.infinity,
      child: Align(
        alignment: alignment,
        child: content,
      ),
    );
  }
}
