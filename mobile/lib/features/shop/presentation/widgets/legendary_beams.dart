import 'dart:math' as math;

import 'package:flutter/material.dart';

/// أشعة دوّارة خلف أقسام العروض — نفس فكرة «عروض أسطورية».
class LegendaryBeams extends StatefulWidget {
  /// موضع مركز الدوران عمودياً (0 = أعلى، 1 = أسفل).
  final double hubYFactor;

  /// عدد الدورات الكاملة لكل دورة حركة (1 = مثل عقرب الساعة).
  final double turnsPerCycle;

  /// مضاعف عرض الأشعة (1 = افتراضي، أعلى = عصا أعرض).
  final double beamWidthScale;

  final Duration duration;

  const LegendaryBeams({
    super.key,
    this.hubYFactor = 0.92,
    this.turnsPerCycle = 0.35,
    this.beamWidthScale = 1.0,
    this.duration = const Duration(seconds: 18),
  });

  @override
  State<LegendaryBeams> createState() => _LegendaryBeamsState();
}

class _LegendaryBeamsState extends State<LegendaryBeams>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _spin,
        builder: (context, child) {
          return CustomPaint(
            painter: LegendaryBeamsPainter(
              turn: _spin.value,
              hubYFactor: widget.hubYFactor,
              turnsPerCycle: widget.turnsPerCycle,
              beamWidthScale: widget.beamWidthScale,
            ),
            child: child,
          );
        },
        child: const SizedBox.expand(),
      ),
    );
  }
}

class LegendaryBeamsPainter extends CustomPainter {
  final double turn;
  final double hubYFactor;
  final double turnsPerCycle;
  final double beamWidthScale;

  const LegendaryBeamsPainter({
    required this.turn,
    this.hubYFactor = 0.92,
    this.turnsPerCycle = 0.35,
    this.beamWidthScale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final hub = Offset(size.width * 0.5, size.height * hubYFactor);
    final reach = size.longestSide * 1.25;
    final scale = beamWidthScale.clamp(0.5, 4.0);

    canvas.save();
    canvas.translate(hub.dx, hub.dy);
    canvas.rotate(turn * math.pi * 2 * turnsPerCycle);

    const rays = 14;
    for (var i = 0; i < rays; i++) {
      final angle = (i / rays) * math.pi * 2;
      canvas.save();
      canvas.rotate(angle);
      final half = (i.isEven ? 20.0 : 11.0) * scale;
      final path = Path()
        ..moveTo(-half * 0.12, 8)
        ..lineTo(-half, -reach)
        ..lineTo(half, -reach)
        ..lineTo(half * 0.12, 8)
        ..close();
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: i.isEven
              ? const [Color(0x66003399), Color(0x24F6C177), Color(0x00003399)]
              : const [Color(0x4DF6C177), Color(0x1A003399), Color(0x00FFFFFF)],
        ).createShader(Rect.fromLTWH(-half, -reach, half * 2, reach + 8));
      canvas.drawPath(path, paint);
      canvas.restore();
    }
    canvas.restore();

    final glow = Paint()
      ..shader = RadialGradient(
        colors: const [Color(0x73003399), Color(0x28F6C177), Color(0x00000000)],
        stops: const [0, 0.45, 1],
      ).createShader(Rect.fromCircle(center: hub, radius: 92));
    canvas.drawCircle(hub, 92, glow);
  }

  @override
  bool shouldRepaint(covariant LegendaryBeamsPainter oldDelegate) =>
      oldDelegate.turn != turn ||
      oldDelegate.hubYFactor != hubYFactor ||
      oldDelegate.turnsPerCycle != turnsPerCycle ||
      oldDelegate.beamWidthScale != beamWidthScale;
}
