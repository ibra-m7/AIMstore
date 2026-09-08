import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// أرقام «5» تتطاير باستمرار من وسط الشعار حتى تُغلق الشاشة.
class FiveConfetti extends StatefulWidget {
  const FiveConfetti({super.key});

  @override
  State<FiveConfetti> createState() => _FiveConfettiState();
}

class _FiveConfettiState extends State<FiveConfetti>
    with SingleTickerProviderStateMixin {
  static const _palette = <Color>[
    AppTheme.primary,
    AppTheme.primaryDark,
    Color(0xFF2E9B57),
    Color(0xFF3DDC97),
    Color(0xFFF4C95D),
    Color(0xFFFFD166),
    Color(0xFFFF8A65),
    Color(0xFFE07A5F),
    Color(0xFF7EC8E3),
    Color(0xFFE8A0BF),
  ];

  late final AnimationController _ticker;
  late final List<_FiveParticle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = _spawn(48);
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  List<_FiveParticle> _spawn(int count) {
    final rng = math.Random(5);
    return List<_FiveParticle>.generate(count, (i) {
      final angle = (i / count) * math.pi * 2 + rng.nextDouble() * 0.35;
      final speed = 0.38 + rng.nextDouble() * 0.55;
      final size = 15.0 + rng.nextDouble() * 18.0;
      final color = _palette[i % _palette.length];
      final painter = TextPainter(
        text: TextSpan(
          text: '5',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: size,
            fontWeight: FontWeight.w900,
            color: color.withValues(alpha: 0.84 + rng.nextDouble() * 0.16),
            height: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      return _FiveParticle(
        painter: painter,
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed * 0.92,
        sway: 6 + rng.nextDouble() * 14,
        wave: rng.nextDouble() * math.pi * 2,
        spin: (rng.nextDouble() - 0.5) * 7.2,
        phase: rng.nextDouble(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ticker,
        builder: (_, _) => CustomPaint(
          painter: _FiveConfettiPainter(
            particles: _particles,
            t: _ticker.value,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _FiveParticle {
  final TextPainter painter;
  final double vx;
  final double vy;
  final double sway;
  final double wave;
  final double spin;
  final double phase;

  const _FiveParticle({
    required this.painter,
    required this.vx,
    required this.vy,
    required this.sway,
    required this.wave,
    required this.spin,
    required this.phase,
  });
}

class _FiveConfettiPainter extends CustomPainter {
  final List<_FiveParticle> particles;
  final double t;

  const _FiveConfettiPainter({
    required this.particles,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final cx = size.width * 0.5;
    final cy = size.height * 0.42;
    final travel = size.shortestSide * 0.72;

    for (final p in particles) {
      var local = t + p.phase;
      local -= local.floorToDouble();
      if (local <= 0.012) continue;

      final grow = Curves.easeOutCubic.transform(local);
      final x = cx +
          (p.vx * travel * grow) +
          math.sin((local * 6) + p.wave) * p.sway * local;
      final y = cy +
          (p.vy * travel * grow) +
          (local * local * travel * 0.12);

      final fadeIn = (local / 0.08).clamp(0.0, 1.0);
      final fadeOut = local > 0.72 ? (1.0 - ((local - 0.72) / 0.28)) : 1.0;
      final opacity = (fadeIn * fadeOut).clamp(0.0, 1.0);
      if (opacity <= 0.03) continue;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spin * local);
      canvas.scale((0.78 + 0.32 * (1 - local * 0.45)) * (0.55 + 0.45 * opacity));
      if (opacity < 0.99) {
        canvas.saveLayer(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.painter.width + 4,
            height: p.painter.height + 4,
          ),
          Paint()..color = Color.fromRGBO(255, 255, 255, opacity),
        );
      }
      p.painter.paint(
        canvas,
        Offset(-p.painter.width / 2, -p.painter.height / 2),
      );
      if (opacity < 0.99) {
        canvas.restore();
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FiveConfettiPainter oldDelegate) =>
      oldDelegate.t != t;
}
