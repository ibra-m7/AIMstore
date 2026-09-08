import 'package:flutter/widgets.dart';

/// فهارس تبويبات [MainScreen].
abstract final class MainShellTabs {
  static const int home = 0;
  static const int categories = 1;
  static const int cart = 2;
  static const int profile = 3;
}

/// يوفّر إجراءات الصدفة الرئيسية للتبويبات داخل [MainScreen]
/// حتى تتمكن الشاشات الفرعية (مثل المحادثة) من فتح السلة بنفس منطق الرجوع والتبويب.
class MainShellScope extends InheritedWidget {
  const MainShellScope({
    super.key,
    required this.openCheckout,
    required this.selectTab,
    required super.child,
  });

  final Future<void> Function() openCheckout;
  final void Function(int index) selectTab;

  static MainShellScope read(BuildContext context) {
    final scope = context
        .getElementForInheritedWidgetOfExactType<MainShellScope>()
        ?.widget;
    assert(
      scope is MainShellScope,
      'MainShellScope غير موجود — استخدمه فقط داخل MainScreen',
    );
    return scope! as MainShellScope;
  }

  @override
  bool updateShouldNotify(MainShellScope oldWidget) => false;
}

/// جسر للوصول إلى تبويبات الرئيسية من الشيتات والمسارات المنبثقة.
class MainShellNavigation {
  MainShellNavigation._();

  static void Function(int index)? _selectTab;

  static void attach(void Function(int index) selectTab) {
    _selectTab = selectTab;
  }

  static void detach() {
    _selectTab = null;
  }

  static void selectTab(int index) {
    _selectTab?.call(index);
  }

  /// يغلق الشاشة/الشيت الحالي ثم يفتح تبويباً في الرئيسية.
  static void popAndSelectTab(BuildContext context, int index) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    selectTab(index);
  }

  /// يختار التبويب من السياق الحالي أو عبر الجسر العام.
  static void goToTab(BuildContext context, int index) {
    final scope = context
        .getElementForInheritedWidgetOfExactType<MainShellScope>()
        ?.widget;
    if (scope is MainShellScope) {
      scope.selectTab(index);
      return;
    }
    selectTab(index);
  }
}
