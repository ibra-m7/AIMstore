import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_scale.dart';
import '../../../../core/theme/app_theme.dart';

/// هيكل تحميل يطابق [ProductCard] (حاوية صورة بزوايا + نص شفاف).
class ProductCardShimmer extends StatelessWidget {
  final Color? imageWellColor;

  const ProductCardShimmer({
    super.key,
    Color? imageWellColor,
    Color? cardColor,
  }) : imageWellColor = imageWellColor ?? cardColor;

  static const Color baseColor = AppTheme.productImageWell;
  static const Color highlightColor = Color(0xFFFAFAFA);

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    final wellRadius = BorderRadius.circular(scale.s(8));
    final wellColor = imageWellColor ?? AppTheme.productImageWell;

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: wellColor,
                          borderRadius: wellRadius,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                              spreadRadius: -1,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: wellRadius,
                          child: Shimmer.fromColors(
                            baseColor: baseColor,
                            highlightColor: highlightColor,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: ColoredBox(color: wellColor),
                                      ),
                                      const PositionedDirectional(
                                        top: 6,
                                        end: 6,
                                        child: _Bone(
                                          width: 25,
                                          height: 25,
                                          radius: 13,
                                        ),
                                      ),
                                      PositionedDirectional(
                                        start: 6,
                                        bottom: 6,
                                        child: _Bone(
                                          width: 26,
                                          height: 26,
                                          radius: 8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: scale.s(5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.04),
                            Colors.black.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              scale.s(6),
              scale.s(1),
              scale.s(6),
              scale.s(2),
            ),
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: scale.s(12)),
                  SizedBox(height: scale.s(1)),
                  _Bone(
                    width: double.infinity,
                    height: scale.s(16),
                    radius: 4,
                  ),
                  SizedBox(height: scale.s(2)),
                  _Bone(
                    width: scale.s(72),
                    height: scale.s(12),
                    radius: 4,
                  ),
                  SizedBox(height: scale.s(2)),
                  SizedBox(
                    height: scale.s(28),
                    child: const Row(
                      children: [
                        _Bone(width: 58, height: 14, radius: 4),
                        Spacer(),
                        _Bone(width: 44, height: 16, radius: 6),
                      ],
                    ),
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

/// شبكة تحميل بنفس إعداد شبكة بطاقات المنتجات (عمودان).
class ProductShimmerGrid extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ProductShimmerGrid({
    super.key,
    this.itemCount = 9,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 110),
    this.shrinkWrap = false,
    this.physics,
  });

  static SliverGridDelegateWithFixedCrossAxisCount sliverDelegate(
    BuildContext context,
  ) {
    final scale = AppScale.of(context);
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: AppScale.homeGridCrossAxisCount,
      mainAxisSpacing: scale.homeGridMainAxisSpacing,
      crossAxisSpacing: scale.s(10),
      childAspectRatio: AppScale.homeGridCardAspect,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: itemCount,
      gridDelegate: sliverDelegate(context),
      itemBuilder: (_, _) => ProductCardShimmer(),
    );
  }
}

class ProductShimmerSliverGrid extends StatelessWidget {
  final int itemCount;
  final Color? imageWellColor;

  const ProductShimmerSliverGrid({
    super.key,
    this.itemCount = 9,
    Color? imageWellColor,
    Color? cardColor,
  }) : imageWellColor = imageWellColor ?? cardColor;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (_, _) => ProductCardShimmer(imageWellColor: imageWellColor),
        childCount: itemCount,
      ),
      gridDelegate: ProductShimmerGrid.sliverDelegate(context),
    );
  }
}

/// هيكل كارد القسم (صورة مربعة + تسمية) — يطابق [GroceriesCategoryCircleTile].
class CategoryCardShimmer extends StatelessWidget {
  const CategoryCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Shimmer.fromColors(
            baseColor: AppTheme.primarySurface,
            highlightColor: const Color(0xFFF5FFF9),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryLight,
                    AppTheme.primarySurface,
                    const Color(0xFFFAFEFC),
                  ],
                  stops: const [0.0, 0.42, 1.0],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Shimmer.fromColors(
          baseColor: AppTheme.primarySurface,
          highlightColor: const Color(0xFFF5FFF9),
          child: Center(
            child: Container(
              height: 10,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class CategoryShimmerSliverGrid extends StatelessWidget {
  final int itemCount;

  const CategoryShimmerSliverGrid({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (_, _) => const CategoryCardShimmer(),
        childCount: itemCount,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _Bone({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// هيكل تحميل يطابق [BundleCard].
class BundleCardShimmer extends StatelessWidget {
  final double width;

  const BundleCardShimmer({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);

    return SizedBox(
      width: width,
      child: Shimmer.fromColors(
        baseColor: ProductCardShimmer.baseColor,
        highlightColor: ProductCardShimmer.highlightColor,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: width * 0.62,
                color: AppTheme.productImageWell,
              ),
              Padding(
                padding: EdgeInsets.all(scale.s(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Bone(width: width * 0.7, height: scale.s(12), radius: 4),
                    SizedBox(height: scale.s(6)),
                    _Bone(width: width * 0.9, height: scale.s(10), radius: 4),
                    SizedBox(height: scale.s(10)),
                    _Bone(width: width * 0.5, height: scale.s(14), radius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
