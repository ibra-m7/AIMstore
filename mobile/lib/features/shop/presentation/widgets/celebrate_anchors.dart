import 'package:flutter/material.dart';

typedef CelebrateCenterGetter = Offset? Function();

/// تسجيل مواقع أنيميشن الطيران بدون مشاركة GlobalKey بين الويدجتات.
class CelebratePositions {
  CelebratePositions._();

  static final cartAnchor = Object();
  static final cartIconAnchor = Object();
  static final _getters = <Object, CelebrateCenterGetter>{};

  static void bind(Object anchor, CelebrateCenterGetter getter) {
    _getters[anchor] = getter;
  }

  static void unbind(Object anchor) {
    _getters.remove(anchor);
  }

  static Offset? read(Object? anchor) {
    if (anchor == null) return null;
    return _getters[anchor]?.call();
  }
}

class CartNavAnchor {
  CartNavAnchor._();

  static final bounce = ValueNotifier<int>(0);
  static final detailsBounce = ValueNotifier<int>(0);
  static final detailsCartAnchor = Object();

  /// حدود صفحة/شيت التفاصيل — لإبقاء الطيران داخل الإطار.
  static GlobalKey? detailsBoundsKey;

  static void ping() => bounce.value++;

  /// ارتداد أيقونة السلة أعلى يسار صفحة/شيت التفاصيل.
  static void pingDetails() => detailsBounce.value++;

  static final detailsRelease = ValueNotifier<int>(0);

  /// اهتزاز خفيف للسلة عند خروج منتج (رجوع).
  static void releaseDetails() => detailsRelease.value++;

  static Offset? cartCenter() =>
      CelebratePositions.read(CelebratePositions.cartAnchor);

  /// مركز أيقونة السلة فقط (بدون شارة العدد).
  static Offset? cartIconCenter() =>
      CelebratePositions.read(CelebratePositions.cartIconAnchor);

  static Offset? detailsCartCenter() =>
      CelebratePositions.read(detailsCartAnchor);
}

/// يقرأ مركز ويدجت عبر GlobalKey.
Offset? celebrateGlobalCenter(GlobalKey? key) {
  if (key == null) return null;
  final box = key.currentContext?.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return null;
  return box.localToGlobal(box.size.center(Offset.zero));
}

/// يقصّ نقطة الطيران داخل حدود ويدجت (مثلاً شيت التفاصيل).
Offset clampFlyPoint(Offset point, GlobalKey? boundsKey, {double margin = 12}) {
  if (boundsKey == null) return point;
  final box = boundsKey.currentContext?.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return point;
  final topLeft = box.localToGlobal(Offset.zero);
  final maxX = topLeft.dx + box.size.width - margin;
  final maxY = topLeft.dy + box.size.height - margin;
  return Offset(
    point.dx.clamp(topLeft.dx + margin, maxX),
    point.dy.clamp(topLeft.dy + margin, maxY),
  );
}

bool isPointInsideBounds(Offset point, GlobalKey? boundsKey, {double margin = 0}) {
  if (boundsKey == null) return true;
  final box = boundsKey.currentContext?.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return true;
  final topLeft = box.localToGlobal(Offset.zero);
  final rect = topLeft & box.size;
  return rect.deflate(margin).contains(point);
}

/// موقع تقريبي لأيقونة السلة أعلى يسار الشاشة/الشيت.
Offset fallbackTopCartTarget(BuildContext context, {GlobalKey? boundsKey}) {
  if (boundsKey != null) {
    final box = boundsKey.currentContext?.findRenderObject();
    if (box is RenderBox && box.hasSize) {
      final topLeft = box.localToGlobal(Offset.zero);
      return Offset(topLeft.dx + 28, topLeft.dy + 18);
    }
  }
  final pad = MediaQuery.paddingOf(context);
  return Offset(pad.left + 28, pad.top + 28);
}

/// يحدد وجهة الطيران — سلة أعلى يسار التفاصيل أو شريط التنقل السفلي.
Offset? resolveFlyEnd(
  BuildContext context, {
  bool preferTopCart = false,
  GlobalKey? topCartKey,
  GlobalKey? boundsKey,
}) {
  if (preferTopCart) {
    final bounds = boundsKey ?? CartNavAnchor.detailsBoundsKey;
    final raw = celebrateGlobalCenter(topCartKey) ??
        CartNavAnchor.detailsCartCenter() ??
        fallbackTopCartTarget(context, boundsKey: bounds);
    return clampFlyPoint(raw, bounds);
  }
  return CartNavAnchor.cartIconCenter() ?? CartNavAnchor.cartCenter();
}

/// موقع تقريبي لسلة الشريط السفلي.
Offset fallbackBottomCartTarget(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  final pad = MediaQuery.paddingOf(context);
  return Offset(size.width * 0.28, size.height - pad.bottom - 42);
}

/// نقطة fallback لصورة المنتج عند خروجها من الشاشة (شيت/صفحة تفاصيل).
Offset? fallbackProductFlyEnd(
  BuildContext context, {
  GlobalKey? boundsKey,
}) {
  if (boundsKey != null) {
    final box = boundsKey.currentContext?.findRenderObject();
    if (box is RenderBox && box.hasSize) {
      final topLeft = box.localToGlobal(Offset.zero);
      return Offset(
        topLeft.dx + box.size.width / 2,
        topLeft.dy + box.size.height - 72,
      );
    }
  }
  final size = MediaQuery.sizeOf(context);
  return Offset(size.width / 2, size.height * 0.72);
}

/// يحلّ نقاط انطلاق/وصول الطيران للإضافة أو الرجوع.
({Offset start, Offset end})? resolveFlyPoints({
  required BuildContext context,
  required bool reverse,
  Object? productAnchor,
  Offset? fallbackProductPoint,
  bool preferTopCart = false,
  GlobalKey? topCartKey,
  GlobalKey? boundsKey,
}) {
  final effectiveBounds = boundsKey ?? CartNavAnchor.detailsBoundsKey;
  final cartPoint = resolveFlyEnd(
        context,
        preferTopCart: preferTopCart,
        topCartKey: topCartKey,
        boundsKey: effectiveBounds,
      ) ??
      fallbackBottomCartTarget(context);

  var productPoint =
      CelebratePositions.read(productAnchor) ?? fallbackProductPoint;
  if (productPoint != null &&
      effectiveBounds != null &&
      !isPointInsideBounds(productPoint, effectiveBounds, margin: 20)) {
    productPoint = fallbackProductPoint;
  }

  if (reverse) {
    final end = productPoint ?? fallbackProductPoint;
    if (end == null) return null;
    return (start: cartPoint, end: end);
  }

  if (productPoint == null) return null;
  return (start: productPoint, end: cartPoint);
}

/// يربط مركز ويدجت فرعي لأنيميشن الطيران.
class CelebrateAnchor extends StatefulWidget {
  final Object anchor;
  final Widget child;

  const CelebrateAnchor({
    super.key,
    required this.anchor,
    required this.child,
  });

  @override
  State<CelebrateAnchor> createState() => _CelebrateAnchorState();
}

class _CelebrateAnchorState extends State<CelebrateAnchor> {
  final GlobalKey _measureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bindPosition());
  }

  @override
  void dispose() {
    CelebratePositions.unbind(widget.anchor);
    super.dispose();
  }

  void _bindPosition() {
    if (!mounted) return;
    CelebratePositions.bind(widget.anchor, _center);
  }

  Offset? _center() {
    final box = _measureKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _bindPosition());
    return KeyedSubtree(
      key: _measureKey,
      child: widget.child,
    );
  }
}
