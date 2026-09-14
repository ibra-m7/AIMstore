import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/product_promo_type.dart';

/// شارة ترويج فوق الكارد — ختم شوكي + نص خفيف.
class PromoBadge extends StatelessWidget {
  final Product product;
  final double fontSize;

  const PromoBadge({
    super.key,
    required this.product,
    this.fontSize = 8,
  });

  @override
  Widget build(BuildContext context) {
    final label = product.promoBadgeLabel;
    if (label == null) return const SizedBox.shrink();

    final isOffer = product.promoType == ProductPromoType.offer;
    final background = isOffer ? const Color(0xFFFF8A3D) : Colors.redAccent;
    final foreground = Colors.white;
    final sealSize = fontSize * 1.7;
    final labelSize = fontSize * 1.18;

    return Container(
      padding: const EdgeInsetsDirectional.only(
        start: 3,
        end: 6,
        top: 2,
        bottom: 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          _SpikyPercentSeal(
            size: sealSize,
            color: foreground,
            showPercent: !isOffer,
          ),
          const SizedBox(width: 3),
          _PromoLabel(
            label: label,
            isOffer: isOffer,
            color: foreground,
            fontSize: labelSize,
          ),
        ],
      ),
    );
  }
}

class _PromoLabel extends StatelessWidget {
  final String label;
  final bool isOffer;
  final Color color;
  final double fontSize;

  const _PromoLabel({
    required this.label,
    required this.isOffer,
    required this.color,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    if (isOffer || !label.startsWith('خصم')) {
      return Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          height: 1.1,
        ),
      );
    }

    final rest = label.substring('خصم'.length).trimLeft();
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'خصم',
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              height: 1.1,
            ),
          ),
          if (rest.isNotEmpty)
            TextSpan(
              text: ' $rest',
              style: TextStyle(
                color: color,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
            ),
        ],
      ),
    );
  }
}

class _SpikyPercentSeal extends StatelessWidget {
  final double size;
  final Color color;
  final bool showPercent;

  const _SpikyPercentSeal({
    required this.size,
    required this.color,
    this.showPercent = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SpikySealPainter(color: color),
        child: Center(
          child: Text(
            showPercent ? '%' : '★',
            style: TextStyle(
              color: color,
              fontSize: size * (showPercent ? 0.42 : 0.38),
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _SpikySealPainter extends CustomPainter {
  final Color color;

  const _SpikySealPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outer = size.shortestSide / 2;
    final inner = outer * 0.72;
    const spikes = 12;
    final path = Path();

    for (var i = 0; i < spikes * 2; i++) {
      final radius = i.isEven ? outer : inner;
      final angle = (i * math.pi / spikes) - (math.pi / 2);
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

    final fill = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, size.shortestSide * 0.07)
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _SpikySealPainter oldDelegate) =>
      oldDelegate.color != color;
}
