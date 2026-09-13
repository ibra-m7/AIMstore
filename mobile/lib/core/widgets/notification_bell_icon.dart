import 'dart:math' as math;

import 'package:flutter/material.dart';

/// جرس إشعارات معدني مرسوم — أقرب لجرس حقيقي مع لمعة وحافة ولسان.
class NotificationBellIcon extends StatelessWidget {
  const NotificationBellIcon({
    super.key,
    this.size = 26,
    this.active = false,
    this.light = const Color(0xFF6B8FD9),
    this.mid = const Color(0xFF003399),
    this.deep = const Color(0xFF002266),
  });

  final double size;
  final bool active;
  final Color light;
  final Color mid;
  final Color deep;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _NotificationBellPainter(
          active: active,
          light: light,
          mid: mid,
          deep: deep,
        ),
      ),
    );
  }
}

class _NotificationBellPainter extends CustomPainter {
  _NotificationBellPainter({
    required this.active,
    required this.light,
    required this.mid,
    required this.deep,
  });

  final bool active;
  final Color light;
  final Color mid;
  final Color deep;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    // ظل ناعم تحت الجرس لإحساس العمق.
    final shadowPaint = Paint()
      ..color = deep.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.2);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, h * 0.92),
        width: w * 0.42,
        height: h * 0.08,
      ),
      shadowPaint,
    );

    // حلقة التعليق العلوية.
    final loopRect = Rect.fromCenter(
      center: Offset(cx, h * 0.13),
      width: w * 0.28,
      height: h * 0.22,
    );
    final loopPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.6, w * 0.07)
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [light, mid, deep],
      ).createShader(loopRect);
    canvas.drawArc(loopRect, math.pi * 1.05, math.pi * 1.05, false, loopPaint);

    // جسم الجرس.
    final bodyPath = Path()
      ..moveTo(cx - w * 0.18, h * 0.22)
      ..cubicTo(
        cx - w * 0.34,
        h * 0.28,
        cx - w * 0.42,
        h * 0.48,
        cx - w * 0.40,
        h * 0.68,
      )
      ..quadraticBezierTo(cx - w * 0.42, h * 0.76, cx - w * 0.38, h * 0.78)
      ..lineTo(cx + w * 0.38, h * 0.78)
      ..quadraticBezierTo(cx + w * 0.42, h * 0.76, cx + w * 0.40, h * 0.68)
      ..cubicTo(
        cx + w * 0.42,
        h * 0.48,
        cx + w * 0.34,
        h * 0.28,
        cx + w * 0.18,
        h * 0.22,
      )
      ..quadraticBezierTo(cx, h * 0.18, cx - w * 0.18, h * 0.22)
      ..close();

    final bodyBounds = bodyPath.getBounds();
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          light,
          mid,
          deep,
          Color.lerp(deep, const Color(0xFF7A5A08), 0.35)!,
        ],
        stops: const [0.0, 0.38, 0.72, 1.0],
      ).createShader(bodyBounds);
    canvas.drawPath(bodyPath, bodyPaint);

    // لمعة معدنية على الجهة اليسرى.
    final highlightPath = Path()
      ..moveTo(cx - w * 0.12, h * 0.26)
      ..cubicTo(
        cx - w * 0.26,
        h * 0.32,
        cx - w * 0.30,
        h * 0.48,
        cx - w * 0.28,
        h * 0.64,
      )
      ..quadraticBezierTo(cx - w * 0.22, h * 0.58, cx - w * 0.18, h * 0.42)
      ..quadraticBezierTo(cx - w * 0.14, h * 0.30, cx - w * 0.12, h * 0.26)
      ..close();
    canvas.drawPath(
      highlightPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.55),
            Colors.white.withValues(alpha: 0.08),
          ],
        ).createShader(highlightPath.getBounds()),
    );

    // شفة الجرس السفلية (حافة بارزة).
    final rimRect = Rect.fromLTRB(
      cx - w * 0.40,
      h * 0.74,
      cx + w * 0.40,
      h * 0.84,
    );
    final rimPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(mid, light, 0.35)!,
          deep,
          Color.lerp(deep, const Color(0xFF6E5208), 0.4)!,
        ],
      ).createShader(rimRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rimRect, Radius.circular(w * 0.08)),
      rimPaint,
    );

    // خط لمعة على الحافة.
    canvas.drawLine(
      Offset(cx - w * 0.30, h * 0.765),
      Offset(cx + w * 0.18, h * 0.765),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = math.max(1.0, w * 0.035)
        ..strokeCap = StrokeCap.round,
    );

    // لسان الجرس.
    final clapperCenter = Offset(cx, h * (active ? 0.90 : 0.88));
    final clapperR = w * (active ? 0.085 : 0.075);
    canvas.drawCircle(
      clapperCenter,
      clapperR,
      Paint()
        ..shader = RadialGradient(
          colors: [light, mid, deep],
          stops: const [0.15, 0.55, 1.0],
        ).createShader(
          Rect.fromCircle(center: clapperCenter, radius: clapperR),
        ),
    );
    canvas.drawCircle(
      Offset(
        clapperCenter.dx - clapperR * 0.28,
        clapperCenter.dy - clapperR * 0.28,
      ),
      clapperR * 0.28,
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );

    // عند وجود إشعار: نقطة نبض خفيفة أعلى يمين الجرس.
    if (active) {
      final spark = Offset(cx + w * 0.28, h * 0.30);
      canvas.drawCircle(
        spark,
        w * 0.055,
        Paint()..color = const Color(0xFFE31E24),
      );
      canvas.drawCircle(
        spark,
        w * 0.09,
        Paint()
          ..color = const Color(0xFFE31E24).withValues(alpha: 0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NotificationBellPainter oldDelegate) {
    return oldDelegate.active != active ||
        oldDelegate.light != light ||
        oldDelegate.mid != mid ||
        oldDelegate.deep != deep;
  }
}
