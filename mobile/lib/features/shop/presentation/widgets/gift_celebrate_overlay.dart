import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/app_network_image.dart';
import 'celebrate_anchors.dart';

/// يشغّل مفرقعات + سحب صورة الهدية من الصندوق إلى أيقونة السلة.
class GiftCelebrateController {
  GiftCelebrateController._();

  static void play({
    required BuildContext context,
    Object? giftAnchor,
    required String giftImageUrl,
    Offset? fallbackStart,
    Offset? overrideEnd,
    bool pingDetailsCart = false,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final start = CelebratePositions.read(giftAnchor) ?? fallbackStart;
    final end = overrideEnd ??
        CartNavAnchor.cartIconCenter() ??
        CartNavAnchor.cartCenter() ??
        _fallbackCartTarget(context);
    if (start == null) return;
    HapticFeedback.mediumImpact();

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _GiftCelebrateOverlay(
        start: start,
        end: end,
        giftImageUrl: giftImageUrl,
        onDone: () {
          entry.remove();
          if (pingDetailsCart) {
            CartNavAnchor.pingDetails();
          } else {
            CartNavAnchor.ping();
          }
        },
      ),
    );
    overlay.insert(entry);
  }

  static Offset _fallbackCartTarget(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    return Offset(size.width * 0.28, size.height - pad.bottom - 42);
  }
}

class _GiftCelebrateOverlay extends StatefulWidget {
  final Offset start;
  final Offset end;
  final String giftImageUrl;
  final VoidCallback onDone;

  const _GiftCelebrateOverlay({
    required this.start,
    required this.end,
    required this.giftImageUrl,
    required this.onDone,
  });

  @override
  State<_GiftCelebrateOverlay> createState() => _GiftCelebrateOverlayState();
}

class _GiftCelebrateOverlayState extends State<_GiftCelebrateOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_ConfettiPiece> _confetti;
  late final Animation<double> _fly;

  static const _gold = Color(0xFFE8C547);
  static const _green = Color(0xFF2E9B57);
  static const _coral = Color(0xFFFF8A65);
  static const _pink = Color(0xFFFFB4C2);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    );
    _fly = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.82, curve: Curves.easeInOutCubic),
    );
    _confetti = _spawnConfetti(widget.start);
    _controller.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_ConfettiPiece> _spawnConfetti(Offset origin) {
    final rnd = math.Random();
    const colors = [_gold, _green, _coral, _pink, Colors.white, Color(0xFFD4AF37)];
    return List.generate(38, (i) {
      final angle = rnd.nextDouble() * math.pi * 2;
      final speed = 70 + rnd.nextDouble() * 130;
      return _ConfettiPiece(
        origin: origin,
        velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed - 40),
        gravity: 220 + rnd.nextDouble() * 120,
        rotation: rnd.nextDouble() * math.pi,
        spin: (rnd.nextDouble() - 0.5) * 7,
        size: 3 + rnd.nextDouble() * 4.5,
        color: colors[rnd.nextInt(colors.length)],
        shape: rnd.nextBool(),
        delay: rnd.nextDouble() * 0.08,
      );
    });
  }

  Offset _flyOffset(double t) {
    final s = widget.start;
    final e = widget.end;
    final lift = math.min(s.dy, e.dy) - 90 - (s.dx - e.dx).abs() * 0.08;
    final c1 = Offset(s.dx, lift);
    final c2 = Offset(e.dx, lift * 0.92);
    return _cubicPoint(s, c1, c2, e, t);
  }

  double _flyScale(double t) => lerpDouble(1.0, 0.34, Curves.easeIn.transform(t))!;

  double _flyOpacity(double t) {
    if (t < 0.82) return 1;
    return (1 - (t - 0.82) / 0.18).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _fly.value;
          final pos = _flyOffset(t);
          final scale = _flyScale(t);
          final opacity = _flyOpacity(t);

          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _ConfettiPainter(
                  pieces: _confetti,
                  progress: _controller.value,
                ),
              ),
              if (t > 0)
                Positioned(
                  left: pos.dx - 16 * scale,
                  top: pos.dy - 16 * scale,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: _FlyingGiftThumb(imageUrl: widget.giftImageUrl),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  static Offset _cubicPoint(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final u = 1 - t;
    return Offset(
      u * u * u * p0.dx + 3 * u * u * t * p1.dx + 3 * u * t * t * p2.dx + t * t * t * p3.dx,
      u * u * u * p0.dy + 3 * u * u * t * p1.dy + 3 * u * t * t * p2.dy + t * t * t * p3.dy,
    );
  }
}

class _FlyingGiftThumb extends StatelessWidget {
  final String imageUrl;

  const _FlyingGiftThumb({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.45),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isNotEmpty
          ? AppNetworkImage(imageUrl, fit: BoxFit.cover)
          : const ColoredBox(
              color: Color(0xFFFFF8E7),
              child: Icon(Icons.card_giftcard_rounded, size: 16, color: Color(0xFFB8860B)),
            ),
    );
  }
}

class _ConfettiPiece {
  final Offset origin;
  final Offset velocity;
  final double gravity;
  final double rotation;
  final double spin;
  final double size;
  final Color color;
  final bool shape;
  final double delay;

  const _ConfettiPiece({
    required this.origin,
    required this.velocity,
    required this.gravity,
    required this.rotation,
    required this.spin,
    required this.size,
    required this.color,
    required this.shape,
    required this.delay,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> pieces;
  final double progress;

  const _ConfettiPainter({required this.pieces, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      final t = ((progress - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final pos = Offset(
        p.origin.dx + p.velocity.dx * t,
        p.origin.dy + p.velocity.dy * t + p.gravity * t * t,
      );
      final paint = Paint()
        ..color = p.color.withValues(alpha: (1 - t * 0.95).clamp(0.0, 1.0));

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.rotation + p.spin * t);
      if (p.shape) {
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.55), paint);
      } else {
        canvas.drawCircle(Offset.zero, p.size * 0.45, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
