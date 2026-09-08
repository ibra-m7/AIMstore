import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/product.dart';

/// شارة «4 حبات» — عدد الحبات داخل العبوة الواحدة (ليس كمية السلة).
class PackPiecesBadge extends StatelessWidget {
  final Product product;
  final double fontSize;
  final EdgeInsetsGeometry? padding;
  final bool compact;

  const PackPiecesBadge({
    super.key,
    required this.product,
    this.fontSize = 12,
    this.padding,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!product.hasPackPieces) return const SizedBox.shrink();

    final label = product.packDisplayLabel;
    if (label.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: compact ? 6 : 10,
            vertical: compact ? 2 : 4,
          ),
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
        border: Border.all(
          color: AppTheme.primaryLight.withValues(alpha: 0.65),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryDark,
          height: 1.2,
        ),
      ),
    );
  }
}

/// سطر توضيحي فوق السعر: «4 حبات بهذا السعر».
class PackPriceCaption extends StatelessWidget {
  final Product product;
  final double fontSize;
  final Color? color;
  final TextAlign? textAlign;

  const PackPriceCaption({
    super.key,
    required this.product,
    this.fontSize = 12,
    this.color,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    if (!product.hasPackPieces) return const SizedBox.shrink();

    return Text(
      product.packDisplayLabel,
      textAlign: textAlign,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color ?? AppTheme.mutedText,
        height: 1.2,
      ),
    );
  }
}
