import 'package:flutter/material.dart';

import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_gift_summary.dart';
import 'celebrate_anchors.dart';

/// إطار صندوق هدية واقعي أعلى صورة الكارد مع صورة منتج الهدية بالداخل.
class ProductGiftBadge extends StatefulWidget {
  final ProductGiftSummary gift;
  final double size;
  final Object? positionAnchor;

  const ProductGiftBadge({
    super.key,
    required this.gift,
    this.size = 26,
    this.positionAnchor,
  });

  static const _goldHi = Color(0xFFFFF3C4);
  static const _gold = Color(0xFFE8C547);
  static const _goldMid = Color(0xFFD4AF37);
  static const _goldLo = Color(0xFFB8860B);
  static const _goldDeep = Color(0xFF8B6914);
  static const _boxFace = Color(0xFFFFF9EE);
  static const _boxShade = Color(0xFFE9D8B4);

  @override
  State<ProductGiftBadge> createState() => _ProductGiftBadgeState();
}

class _ProductGiftBadgeState extends State<ProductGiftBadge>
    with SingleTickerProviderStateMixin {
  final GlobalKey _measureKey = GlobalKey();
  late final AnimationController _controller;
  late final Animation<double> _float;
  late final Animation<double> _scale;
  late final Animation<double> _bowWiggle;
  late final Animation<double> _lidLift;
  late final Animation<double> _sparkle;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _float = Tween<double>(begin: 0, end: -2.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scale = Tween<double>(begin: 1, end: 1.045).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _bowWiggle = Tween<double>(begin: -0.07, end: 0.07).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.85, curve: Curves.easeInOut),
      ),
    );
    _lidLift = Tween<double>(begin: 0, end: -0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
      ),
    );
    _sparkle = Tween<double>(begin: 0.15, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _bindPosition());
  }

  @override
  void didUpdateWidget(covariant ProductGiftBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.positionAnchor != widget.positionAnchor) {
      if (oldWidget.positionAnchor != null) {
        CelebratePositions.unbind(oldWidget.positionAnchor!);
      }
      _bindPosition();
    }
  }

  void _bindPosition() {
    final anchor = widget.positionAnchor;
    if (anchor == null || !mounted) return;
    CelebratePositions.bind(anchor, _center);
  }

  Offset? _center() {
    final box = _measureKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }

  @override
  void dispose() {
    if (widget.positionAnchor != null) {
      CelebratePositions.unbind(widget.positionAnchor!);
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final bodyW = s;
    final bodyH = s * 0.7;
    final lidW = s * 1.12;
    final lidH = s * 0.22;
    final bowH = s * 0.2;
    final bodyTop = bowH + lidH - 1.5;

    return RepaintBoundary(
      key: _measureKey,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Transform.translate(
            offset: Offset(0, _float.value),
            child: Transform.scale(
              scale: _scale.value,
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: lidW,
                height: bowH + lidH + bodyH,
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: bodyTop,
                      child: _GiftBoxBody(
                        width: bodyW,
                        height: bodyH,
                        imageUrl: widget.gift.displayImage,
                      ),
                    ),
                    Positioned(
                      top: bowH + lidH - 2.5,
                      left: (lidW - bodyW) / 2,
                      child: _GiftRibbonCross(
                        width: bodyW,
                        shimmer: _sparkle.value,
                      ),
                    ),
                    Positioned(
                      top: bowH - 0.5 + _lidLift.value,
                      child: _GiftBoxLid(width: lidW, height: lidH),
                    ),
                    Positioned(
                      top: 0,
                      child: Transform.rotate(
                        angle: _bowWiggle.value,
                        child: _GiftBow(size: s * 0.44),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GiftBoxLid extends StatelessWidget {
  final double width;
  final double height;

  const _GiftBoxLid({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3.5),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ProductGiftBadge._goldHi,
            ProductGiftBadge._gold,
            ProductGiftBadge._goldMid,
          ],
          stops: [0.0, 0.45, 1.0],
        ),
        border: Border.all(color: ProductGiftBadge._goldLo, width: 0.7),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 2.5,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 1,
            left: 3,
            right: 3,
            height: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          Positioned(
            left: width / 2 - 1.2,
            top: 1,
            bottom: 1,
            width: 2.4,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    ProductGiftBadge._goldDeep,
                    ProductGiftBadge._goldHi,
                    ProductGiftBadge._goldDeep,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 1.5,
            child: ColoredBox(
              color: ProductGiftBadge._goldDeep.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _GiftBoxBody extends StatelessWidget {
  final double width;
  final double height;
  final String imageUrl;

  const _GiftBoxBody({
    required this.width,
    required this.height,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    const inset = 1.1;
    const outerRadius = 4.0;
    const innerRadius = 2.6;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: ProductGiftBadge._boxFace,
        borderRadius: BorderRadius.circular(outerRadius),
        border: Border.all(color: ProductGiftBadge._goldMid, width: 0.75),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 3,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(inset),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(innerRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              AppNetworkImage(
                imageUrl,
                fit: BoxFit.cover,
                error: _fallback(),
              )
            else
              _fallback(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: (height - inset * 2) * 0.16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.07),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ProductGiftBadge._boxFace,
            ProductGiftBadge._boxShade,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.card_giftcard_rounded,
          size: 11,
          color: ProductGiftBadge._goldLo,
        ),
      ),
    );
  }
}

class _GiftRibbonCross extends StatelessWidget {
  final double width;
  final double shimmer;

  const _GiftRibbonCross({
    required this.width,
    this.shimmer = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final glow = 0.25 + shimmer * 0.35;

    return SizedBox(
      width: width,
      height: 3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ProductGiftBadge._goldDeep.withValues(alpha: 0.85),
                    ProductGiftBadge._goldHi.withValues(alpha: 0.75 + glow * 0.25),
                    ProductGiftBadge._goldDeep.withValues(alpha: 0.85),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: ProductGiftBadge._goldHi.withValues(alpha: glow * 0.45),
                    blurRadius: 2.5,
                    spreadRadius: 0.2,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -1,
            bottom: -1,
            width: 2.6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    ProductGiftBadge._goldDeep,
                    ProductGiftBadge._goldHi.withValues(alpha: 0.8 + glow * 0.2),
                    ProductGiftBadge._gold,
                    ProductGiftBadge._goldHi.withValues(alpha: 0.8 + glow * 0.2),
                    ProductGiftBadge._goldDeep,
                  ],
                  stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GiftBow extends StatelessWidget {
  final double size;

  const _GiftBow({required this.size});

  @override
  Widget build(BuildContext context) {
    final loop = size * 0.42;
    return SizedBox(
      width: size,
      height: loop * 0.95,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: size * 0.02,
            child: Transform.rotate(
              angle: -0.5,
              child: _bowLoop(loop),
            ),
          ),
          Positioned(
            right: size * 0.02,
            child: Transform.rotate(
              angle: 0.5,
              child: _bowLoop(loop),
            ),
          ),
          Container(
            width: loop * 0.36,
            height: loop * 0.5,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ProductGiftBadge._gold,
                  ProductGiftBadge._goldDeep,
                ],
              ),
              borderRadius: BorderRadius.circular(2.5),
              border: Border.all(
                color: ProductGiftBadge._goldLo.withValues(alpha: 0.7),
                width: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bowLoop(double loop) {
    return Container(
      width: loop,
      height: loop * 0.68,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ProductGiftBadge._goldHi,
            ProductGiftBadge._gold,
            ProductGiftBadge._goldLo,
          ],
        ),
        borderRadius: BorderRadius.circular(loop),
        boxShadow: [
          BoxShadow(
            color: ProductGiftBadge._goldDeep.withValues(alpha: 0.28),
            blurRadius: 1.5,
            offset: const Offset(0, 0.8),
          ),
        ],
      ),
    );
  }
}

/// شريط رفيع: «معه منتج هدية» — بين صورة الكارد واسم المنتج.
class ProductGiftCardStrip extends StatelessWidget {
  final bool fullWidth;
  final bool embedded;
  final double height;
  final double fontSize;
  final double iconSize;
  final double horizontalPadding;
  final BorderRadius? borderRadius;
  /// نسبة من عرض الشريط لزوايا علوية خفيفة (مثلاً 0.05 = 5%).
  final double? cornerRadiusPercent;

  const ProductGiftCardStrip({
    super.key,
    this.fullWidth = false,
    this.embedded = false,
    this.height = stripHeight,
    this.fontSize = 8,
    this.iconSize = 12,
    this.horizontalPadding = 6,
    this.borderRadius,
    this.cornerRadiusPercent,
  });

  static const double stripHeight = 13;

  static const _goldHi = Color(0xFFFFF3C4);
  static const _gold = Color(0xFFE8C547);
  static const _goldMid = Color(0xFFD4AF37);
  static const _goldDeep = Color(0xFFB8860B);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedBorderRadius = this.borderRadius ?? _resolveBorderRadius(
          embedded: embedded,
          fullWidth: fullWidth,
          width: constraints.maxWidth,
        );

        return SizedBox(
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: resolvedBorderRadius,
              gradient: const LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [_goldDeep, _goldMid, _gold, _goldHi],
                stops: [0.0, 0.32, 0.68, 1.0],
              ),
              boxShadow: embedded
                  ? const []
                  : [
                      BoxShadow(
                        color: _goldMid.withValues(alpha: 0.45),
                        blurRadius: 6,
                        spreadRadius: 0.2,
                        offset: Offset(0, 1),
                      ),
                    ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'معه منتج هدية',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1,
                        shadows: [
                          Shadow(
                            color: _goldDeep.withValues(alpha: 0.55),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.west_rounded,
                    size: iconSize,
                    color: _goldDeep,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  BorderRadius _resolveBorderRadius({
    required bool embedded,
    required bool fullWidth,
    required double width,
  }) {
    if (cornerRadiusPercent != null && embedded && width > 0) {
      final radius = width * cornerRadiusPercent!;
      return BorderRadius.vertical(top: Radius.circular(radius));
    }
    if (embedded) return BorderRadius.zero;
    if (fullWidth) {
      return const BorderRadius.vertical(top: Radius.circular(6));
    }
    return BorderRadius.circular(6);
  }
}

/// كارد أفقي لعرض الهدية في التفاصيل أو المعاينة.
class ProductGiftDetailCard extends StatelessWidget {
  final ProductGiftSummary gift;

  const ProductGiftDetailCard({super.key, required this.gift});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFF8E7),
            const Color(0xFFFFF3D6).withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8C547).withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 62,
            height: 62,
            child: AppNetworkImage(
              gift.displayImage,
              fit: BoxFit.contain,
              alignment: Alignment.center,
              error: const Icon(
                Icons.card_giftcard,
                color: Color(0xFFD4A017),
                size: 34,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'منتج هدية لخاطر عيونك',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB8860B),
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  gift.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  ProductGiftCardStrip._goldDeep,
                  ProductGiftCardStrip._gold,
                  ProductGiftCardStrip._goldMid,
                ],
                stops: [0.0, 0.45, 1.0],
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: ProductGiftCardStrip._goldMid.withValues(alpha: 0.18),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Text(
              'مجاناً',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                height: 1.1,
                shadows: [
                  Shadow(
                    color: Color(0x66000000),
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension ProductGiftX on Product {
  bool get showsGiftBadge => hasGiftProduct;
}
