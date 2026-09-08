import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// أيقونة خصم على شكل ختم/قسيمة (% داخل دائرة مُشَوَّكة) — مثل تطبيق Qooo.
class CouponBadgeIcon extends StatelessWidget {
  final double size;
  final Color color;

  const CouponBadgeIcon({
    super.key,
    this.size = 18,
    this.color = AppTheme.primaryDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CouponBadgePainter(color: color),
        child: Center(
          child: Text(
            '%',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.5,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _CouponBadgePainter extends CustomPainter {
  final Color color;

  const _CouponBadgePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2;
    final innerR = outerR * 0.84;
    const lobes = 12;

    final path = Path();
    for (var i = 0; i < lobes * 2; i++) {
      final angle = (math.pi * 2 * i) / (lobes * 2) - math.pi / 2;
      final radius = i.isEven ? outerR : innerR;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _CouponBadgePainter oldDelegate) =>
      oldDelegate.color != color;
}
