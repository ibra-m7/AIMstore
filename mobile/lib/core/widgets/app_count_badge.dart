import 'package:flutter/material.dart';

/// عدّاد بدون خلفية — رقم أخضر غامق واضح (سلة، إشعارات، …).
abstract final class AppCountBadge {
  static const Color numberColor = Color(0xFF003399);

  static TextStyle textStyle({double fontSize = 10, Color? color}) => TextStyle(
        color: color ?? numberColor,
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        height: 1.05,
      );

  static String format(int count) => count > 99 ? '99+' : '$count';

  static Widget wrap({
    required Widget child,
    required int count,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    Offset offset = const Offset(4, -4),
  }) {
    if (count <= 0) return child;
    return Badge(
      isLabelVisible: true,
      backgroundColor: Colors.transparent,
      textColor: numberColor,
      padding: padding,
      offset: offset,
      label: Text(
        format(count),
        style: textStyle(),
      ),
      child: child,
    );
  }

  static Widget positioned({
    required int count,
    double top = 0,
    double end = 0,
    double fontSize = 10,
    Color? textColor,
    Key? key,
  }) {
    if (count <= 0) return const SizedBox.shrink();
    return PositionedDirectional(
      key: key,
      top: top,
      end: end,
      child: Text(
        format(count),
        style: textStyle(fontSize: fontSize, color: textColor),
      ),
    );
  }

  /// شارة عدّاد ثلاثية الأبعاد — للأزرار الداكنة (مثل «الانتقال للدفع»).
  static Widget pill3d({
    required int count,
    double fontSize = 11.5,
  }) {
    if (count <= 0) return const SizedBox.shrink();
    final text = format(count);
    final wide = count > 9;

    return Container(
      constraints: BoxConstraints(minWidth: wide ? 26 : 24),
      height: 24,
      padding: EdgeInsets.symmetric(horizontal: wide ? 7 : 0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.48),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.38),
            blurRadius: 7,
            spreadRadius: 0.4,
            offset: const Offset(0, -1),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        textDirection: TextDirection.ltr,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          height: 1,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.22),
              offset: const Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}
