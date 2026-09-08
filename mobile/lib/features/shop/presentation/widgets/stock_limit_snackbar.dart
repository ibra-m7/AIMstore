import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

/// رسالة عند محاولة تجاوز المخزون — فوق شريط التنقل مباشرة.
void showProductUnavailableSnackBar(BuildContext context) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();

  final bottomPad = MediaQuery.viewPaddingOf(context).bottom;
  // أقرب للأسفل فوق شريط التنقل.
  final marginBottom = bottomPad + 56;

  messenger.showSnackBar(
    SnackBar(
      content: const Text(
        AppStrings.productNoLongerAvailable,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          height: 1.15,
        ),
      ),
      backgroundColor: const Color(0xFFE53935),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: EdgeInsets.fromLTRB(12, 0, 12, marginBottom),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      duration: const Duration(seconds: 2),
    ),
  );
}
