import 'package:flutter/foundation.dart';

/// جسر لتركيز قسم عرض داخل تبويب الأقسام (بدون فتح مسار جديد).
class CategoriesNav {
  CategoriesNav._();

  static final ValueNotifier<String?> pendingSectionId =
      ValueNotifier<String?>(null);

  static void focusSection(String sectionId) {
    final id = sectionId.trim();
    if (id.isEmpty) return;
    // إعادة تعيين ثم تعيين لضمان إشعار حتى لو نفس القيمة.
    pendingSectionId.value = null;
    pendingSectionId.value = id;
  }

  static void clear() {
    pendingSectionId.value = null;
  }
}
