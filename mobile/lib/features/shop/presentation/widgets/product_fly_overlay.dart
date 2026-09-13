import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import 'celebrate_anchors.dart';

enum ProductFlyDirection { toCart, fromCart }

/// يشغّل طيران صورة المنتج من/إلى أيقونة السلة.
class ProductFlyController {
  ProductFlyController._();

  static void play({
    required BuildContext context,
    required String imageUrl,
    Object? productAnchor,
    Offset? fallbackStart,
    Offset? overrideEnd,
    VoidCallback? onComplete,
    bool pingDetailsCart = false,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final start = CelebratePositions.read(productAnchor) ?? fallbackStart;
    final end = overrideEnd ??
        CartNavAnchor.cartIconCenter() ??
        CartNavAnchor.cartCenter() ??
        fallbackBottomCartTarget(context);
    if (start == null) return;

    _insert(
      overlay: overlay,
      start: _jitter(start),
      end: end,
      imageUrl: imageUrl,
      direction: ProductFlyDirection.toCart,
      onDone: () {
        if (pingDetailsCart) {
          CartNavAnchor.pingDetails();
        } else {
          CartNavAnchor.ping();
        }
        onComplete?.call();
      },
    );

    HapticFeedback.lightImpact();
  }

  /// طيران عكسي: من السلة إلى صورة المنتج (هوية «رجوع/نقصان»).
  static void playReverse({
    required BuildContext context,
    required String imageUrl,
    Object? productAnchor,
    Offset? fallbackEnd,
    bool flyFromTopCart = false,
    GlobalKey? topCartKey,
    GlobalKey? boundsKey,
    bool releaseDetailsCart = false,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final points = resolveFlyPoints(
      context: context,
      reverse: true,
      productAnchor: productAnchor,
      fallbackProductPoint: fallbackEnd,
      preferTopCart: flyFromTopCart,
      topCartKey: topCartKey,
      boundsKey: boundsKey,
    );
    if (points == null) return;

    if (releaseDetailsCart) {
      CartNavAnchor.releaseDetails();
    }

    _insert(
      overlay: overlay,
      start: _jitter(points.start, amount: 8),
      end: points.end,
      imageUrl: imageUrl,
      direction: ProductFlyDirection.fromCart,
      onDone: () {},
    );

    HapticFeedback.selectionClick();
  }

  static void _insert({
    required OverlayState overlay,
    required Offset start,
    required Offset end,
    required String imageUrl,
    required ProductFlyDirection direction,
    required VoidCallback onDone,
  }) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _ProductFlyOverlay(
        start: start,
        end: end,
        imageUrl: imageUrl,
        direction: direction,
        onDone: () {
          entry.remove();
          onDone();
        },
      ),
    );
    overlay.insert(entry);
  }

  static Offset _jitter(Offset point, {double amount = 12}) {
    final rnd = math.Random();
    return point +
        Offset(
          (rnd.nextDouble() - 0.5) * amount,
          (rnd.nextDouble() - 0.5) * amount,
        );
  }
}

class _ProductFlyOverlay extends StatefulWidget {
  final Offset start;
  final Offset end;
  final String imageUrl;
  final ProductFlyDirection direction;
  final VoidCallback onDone;

  const _ProductFlyOverlay({
    required this.start,
    required this.end,
    required this.imageUrl,
    required this.direction,
    required this.onDone,
  });

  bool get _reverse => direction == ProductFlyDirection.fromCart;

  @override
  State<_ProductFlyOverlay> createState() => _ProductFlyOverlayState();
}

class _ProductFlyOverlayState extends State<_ProductFlyOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _position;
  late final List<_SparkParticle> _particles;

  static const _thumbSize = 52.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget._reverse ? 780 : 700),
    );
    _position = CurvedAnimation(
      parent: _controller,
      curve: widget._reverse ? Curves.easeInOut : Curves.easeInOutCubic,
    );
    _particles = widget._reverse
        ? _spawnReturnParticles(widget.start)
        : _spawnParticles(widget.start);
    _controller.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_SparkParticle> _spawnParticles(Offset origin) {
    final rnd = math.Random();
    const colors = [
      AppTheme.primaryDark,
      AppTheme.primary,
      AppTheme.primaryLight,
      Colors.white,
      Color(0xFF6B7A99),
    ];
    return List.generate(8, (_) {
      final angle = rnd.nextDouble() * math.pi * 2;
      final speed = 40 + rnd.nextDouble() * 70;
      return _SparkParticle(
        origin: origin,
        velocity: Offset(
          math.cos(angle) * speed,
          math.sin(angle) * speed - 24,
        ),
        size: 2.5 + rnd.nextDouble() * 2.5,
        color: colors[rnd.nextInt(colors.length)],
        delay: rnd.nextDouble() * 0.06,
        gravity: 90,
      );
    });
  }

  List<_SparkParticle> _spawnReturnParticles(Offset origin) {
    final rnd = math.Random();
    const colors = [
      AppTheme.mutedText,
      Color(0xFFB0BFB5),
      Color(0xFF9AA89E),
      Color(0xFFD0D8D2),
      Color(0xFF8A9A90),
    ];
    return List.generate(5, (_) {
      final spread = (rnd.nextDouble() - 0.5) * 0.8;
      final speed = 24 + rnd.nextDouble() * 36;
      return _SparkParticle(
        origin: origin,
        velocity: Offset(spread * speed, speed * 0.65 + 18),
        size: 2.0 + rnd.nextDouble() * 2.0,
        color: colors[rnd.nextInt(colors.length)],
        delay: rnd.nextDouble() * 0.08,
        gravity: 110,
      );
    });
  }

  Offset _flyOffset(double t) {
    final s = widget.start;
    final e = widget.end;
    if (widget._reverse) {
      final sag = math.max(s.dy, e.dy) + 48 + (s.dx - e.dx).abs() * 0.05;
      final c1 = Offset(s.dx, sag);
      final c2 = Offset(e.dx, sag * 0.96);
      return _cubicPoint(s, c1, c2, e, t);
    }
    final lift = math.min(s.dy, e.dy) - 72 - (s.dx - e.dx).abs() * 0.07;
    final c1 = Offset(s.dx, lift);
    final c2 = Offset(e.dx, lift * 0.94);
    return _cubicPoint(s, c1, c2, e, t);
  }

  double _flyScale(double t) {
    if (widget._reverse) {
      return lerpDouble(0.30, 1.0, Curves.easeOut.transform(t))!;
    }
    return lerpDouble(1.0, 0.30, Curves.easeIn.transform(t))!;
  }

  double _flyOpacity(double t) {
    if (widget._reverse) {
      if (t < 0.10) return (t / 0.10).clamp(0.0, 1.0);
      if (t > 0.90) return (1 - (t - 0.90) / 0.10).clamp(0.0, 1.0);
      return 1;
    }
    if (t < 0.88) return 1;
    return (1 - (t - 0.88) / 0.12).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _position.value;
          final pos = _flyOffset(t);
          final scale = _flyScale(t);
          final opacity = _flyOpacity(t);
          final half = _thumbSize / 2 * scale;

          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _SparkPainter(
                  particles: _particles,
                  progress: _controller.value,
                ),
              ),
              if (t > 0)
                Positioned(
                  left: pos.dx - half,
                  top: pos.dy - half,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: _FlyingProductThumb(
                        imageUrl: widget.imageUrl,
                        muted: widget._reverse,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  static Offset _cubicPoint(
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3,
    double t,
  ) {
    final u = 1 - t;
    return Offset(
      u * u * u * p0.dx +
          3 * u * u * t * p1.dx +
          3 * u * t * t * p2.dx +
          t * t * t * p3.dx,
      u * u * u * p0.dy +
          3 * u * u * t * p1.dy +
          3 * u * t * t * p2.dy +
          t * t * t * p3.dy,
    );
  }
}

class _FlyingProductThumb extends StatelessWidget {
  final String imageUrl;
  final bool muted;

  const _FlyingProductThumb({
    required this.imageUrl,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget thumb = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 52,
        height: 52,
        child: imageUrl.isNotEmpty
            ? AppNetworkImage(imageUrl, fit: BoxFit.cover)
            : ColoredBox(
                color: Colors.transparent,
                child: Icon(
                  Icons.image_outlined,
                  size: 22,
                  color: AppTheme.primaryDark.withValues(alpha: 0.6),
                ),
              ),
      ),
    );

    if (muted) {
      thumb = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.55, 0.20, 0.15, 0, 8,
          0.15, 0.55, 0.15, 0, 8,
          0.15, 0.15, 0.55, 0, 8,
          0, 0, 0, 0.82, 0,
        ]),
        child: thumb,
      );
    }

    return thumb;
  }
}

class _SparkParticle {
  final Offset origin;
  final Offset velocity;
  final double size;
  final Color color;
  final double delay;
  final double gravity;

  const _SparkParticle({
    required this.origin,
    required this.velocity,
    required this.size,
    required this.color,
    required this.delay,
    this.gravity = 90,
  });
}

class _SparkPainter extends CustomPainter {
  final List<_SparkParticle> particles;
  final double progress;

  const _SparkPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = ((progress - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final pos = Offset(
        p.origin.dx + p.velocity.dx * t,
        p.origin.dy + p.velocity.dy * t + p.gravity * t * t,
      );
      final paint = Paint()
        ..color = p.color.withValues(alpha: (1 - t * 0.92).clamp(0.0, 1.0));
      canvas.drawCircle(pos, p.size * 0.45, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
