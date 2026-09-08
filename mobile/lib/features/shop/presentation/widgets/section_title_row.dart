import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

/// عنوان قسم — عنوان + «عرض الكل ›» بدون خلفية.
class SectionTitleRow extends StatelessWidget {
  final String title;
  final String? emoji;
  final VoidCallback? onTap;
  final Color color;
  final EdgeInsetsGeometry padding;
  final bool showViewAllLabel;
  final double? titleFontSize;
  final FontWeight? titleFontWeight;

  const SectionTitleRow({
    super.key,
    required this.title,
    this.emoji,
    this.onTap,
    this.color = AppTheme.darkText,
    this.padding = const EdgeInsets.fromLTRB(16, 18, 16, 12),
    this.showViewAllLabel = false,
    this.titleFontSize,
    this.titleFontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final label = emoji != null && emoji!.trim().isNotEmpty
        ? '$title ${emoji!.trim()}'
        : title;

    return Padding(
      padding: padding,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: titleFontSize ?? AppTextStyles.sectionTitle.fontSize,
                  fontWeight:
                      titleFontWeight ?? AppTextStyles.sectionTitle.fontWeight,
                  color: color,
                ),
              ),
            ),
            if (onTap != null)
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chevron_left_rounded,
                      size: 16,
                      color: AppTheme.primary.withValues(alpha: 0.9),
                    ),
                    if (showViewAllLabel)
                      Text(
                        AppStrings.viewAll,
                        style: AppTextStyles.viewAll,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
