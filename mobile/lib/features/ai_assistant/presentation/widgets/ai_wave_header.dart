import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// موجة بحرية متحركة — أعلى لوحة المساعد.
class AiWaveHeader extends StatefulWidget {
  final double height;
  final bool prominent;

  const AiWaveHeader({
    super.key,
    this.height = 32,
    this.prominent = true,
  });

  @override
  State<AiWaveHeader> createState() => _AiWaveHeaderState();
}

class _AiWaveHeaderState extends State<AiWaveHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _AiWavePainter(
              phase: _ctrl.value * math.pi * 2,
              prominent: widget.prominent,
            ),
          );
        },
      ),
    );
  }
}

class _AiWavePainter extends CustomPainter {
  final double phase;
  final bool prominent;

  _AiWavePainter({required this.phase, required this.prominent});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    _drawWave(
      canvas,
      size,
      amplitude: prominent ? 5.5 : 3.5,
      wavelength: size.width / 1.35,
      phase: phase,
      color: AppTheme.primary.withValues(alpha: prominent ? 0.16 : 0.10),
      baseline: size.height * 0.72,
    );
    _drawWave(
      canvas,
      size,
      amplitude: prominent ? 4 : 2.5,
      wavelength: size.width / 1.05,
      phase: phase + math.pi * 0.55,
      color: AppTheme.primaryLight.withValues(alpha: prominent ? 0.22 : 0.14),
      baseline: size.height * 0.58,
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size, {
    required double amplitude,
    required double wavelength,
    required double phase,
    required Color color,
    required double baseline,
  }) {
    final path = Path()..moveTo(0, baseline);
    const step = 6.0;
    for (var x = 0.0; x <= size.width; x += step) {
      final y = baseline +
          math.sin((x / wavelength) * math.pi * 2 + phase) * amplitude;
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _AiWavePainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.prominent != prominent;
}
