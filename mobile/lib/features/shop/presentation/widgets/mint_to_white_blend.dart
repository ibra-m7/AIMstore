import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// جسر تدرج من لون التطبيق إلى الأبيض — بعد الهيدر في الرئيسية والأقسام.
class MintToWhiteBlend extends StatelessWidget {
  final double height;
  final BorderRadiusGeometry? borderRadius;

  /// تدرج أقوى (mint → أبيض) لشريط الانتقال تحت البانر.
  final bool strong;

  const MintToWhiteBlend({
    super.key,
    required this.height,
    this.borderRadius,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    if (height <= 0) return const SizedBox.shrink();

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: strong
              ? const [
                  AppTheme.primaryLight,
                  AppTheme.background,
                  Colors.white,
                ]
              : const [AppTheme.background, Colors.white],
          stops: strong ? const [0.0, 0.45, 1.0] : null,
        ),
      ),
    );
  }
}
