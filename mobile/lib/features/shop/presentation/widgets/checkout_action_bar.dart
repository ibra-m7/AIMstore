import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'price_line.dart';

/// شريط إجراء عائم (تنفيذ الطلب / الانتقال للدفع) — بدون سكشن خلفي.
class CheckoutActionBar extends StatelessWidget {
  final String label;
  final double total;
  final double? originalTotal;
  final double discount;
  final bool enabled;
  final bool loading;
  final bool glass;
  final VoidCallback? onTap;
  final Widget? leading;

  static const double radius = 14;
  static const double height = 46;

  const CheckoutActionBar({
    super.key,
    required this.label,
    required this.total,
    this.originalTotal,
    this.discount = 0,
    this.enabled = true,
    this.loading = false,
    this.glass = false,
    this.onTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final glassAlpha = glass ? 0.72 : 1.0;
    final borderRadius = BorderRadius.circular(radius);

    final showStrikePrice = discount > 0 &&
        originalTotal != null &&
        originalTotal! > total;

    Widget face = Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: enabled && !loading ? onTap : null,
        borderRadius: borderRadius,
        splashColor: Colors.white.withValues(alpha: 0.12),
        highlightColor: Colors.white.withValues(alpha: 0.08),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primary.withValues(alpha: glassAlpha),
                AppTheme.primaryDark.withValues(alpha: glassAlpha),
              ],
            ),
            border: glass
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.32),
                    width: 1,
                  )
                : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              if (!glass)
                ClipRRect(
                  borderRadius: borderRadius,
                  child: CustomPaint(
                    painter: const _RightWaveOverlayPainter(),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: loading
                    ? const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.4,
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          if (leading != null) ...[
                            leading!,
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (discount > 0 && !showStrikePrice) ...[
                            Text(
                              '- ${discount.toStringAsFixed(1)}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          PriceLine(
                            price: total,
                            originalPrice:
                                showStrikePrice ? originalTotal : null,
                            color: Colors.white,
                            priceSize: 15,
                            currencySize: 16,
                            alignment: AlignmentDirectional.centerEnd,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );

    if (glass) {
      face = ClipRRect(
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: face,
        ),
      );
    }

    return ColoredBox(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryDark.withValues(alpha: 0.38),
                  offset: const Offset(0, 3),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  offset: const Offset(0, 5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: borderRadius,
              clipBehavior: Clip.antiAlias,
              child: face,
            ),
          ),
        ),
      ),
    );
  }
}

class _RightWaveOverlayPainter extends CustomPainter {
  const _RightWaveOverlayPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final light = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(w, 0)
      ..lineTo(w * 0.62, 0)
      ..quadraticBezierTo(w * 0.48, h * 0.22, w * 0.64, h * 0.48)
      ..quadraticBezierTo(w * 0.78, h * 0.72, w * 0.62, h)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(path, light);

    final soft = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(w, h * 0.08)
      ..lineTo(w * 0.72, h * 0.08)
      ..quadraticBezierTo(w * 0.58, h * 0.38, w * 0.74, h * 0.58)
      ..quadraticBezierTo(w * 0.86, h * 0.78, w * 0.7, h * 0.92)
      ..lineTo(w, h * 0.92)
      ..close();
    canvas.drawPath(path2, soft);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
