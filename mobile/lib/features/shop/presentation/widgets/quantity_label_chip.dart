import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/product.dart';

/// وصف الكمية الظاهر من لوحة التحكم — نص فقط بدون خلفية.
class QuantityLabelChip extends StatelessWidget {
  final Product product;
  final double fontSize;
  final bool compact;

  const QuantityLabelChip({
    super.key,
    required this.product,
    this.fontSize = 11,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = product.quantityLabel.trim();
    if (label.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.productMeta.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w300,
          height: 1.2,
        ),
      ),
    );
  }
}
