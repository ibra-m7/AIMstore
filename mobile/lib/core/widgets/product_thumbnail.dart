import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_scale.dart';
import '../theme/app_theme.dart';
import 'app_network_image.dart';

/// صورة منتج موحّدة للبطاقات: تملأ الحاوية بأقصى حجم بدون قص.
class ProductThumbnail extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;
  final double aspectRatio;
  final double? inset;
  /// فراغ علوي داخل الحاوية (إن وُجد يُستخدم بدل [inset] من الأعلى).
  final double? insetTop;
  /// فراغ سفلي داخل الحاوية (إن وُجد يُستخدم بدل [inset] من الأسفل).
  final double? insetBottom;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final bool expand;
  final Alignment alignment;
  final Widget? overlay;

  const ProductThumbnail({
    super.key,
    required this.imageUrl,
    this.heroTag,
    this.aspectRatio = 1,
    this.inset,
    this.insetTop,
    this.insetBottom,
    this.backgroundColor = AppTheme.productImageWell,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.expand = true,
    this.alignment = Alignment.center,
    this.overlay,
  });

  Widget _networkImage(Color wellColor, {double? width, double? height}) {
    return AppNetworkImage(
      imageUrl,
      fit: BoxFit.contain,
      alignment: alignment,
      width: width,
      height: height,
      placeholder: Shimmer.fromColors(
        baseColor: const Color(0xFFEEEEEE),
        highlightColor: const Color(0xFFFAFAFA),
        child: Container(color: wellColor),
      ),
      error: ColoredBox(
        color: wellColor,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: AppTheme.mutedText,
          size: 28,
        ),
      ),
    );
  }

  Widget _imageContent(AppScale scale, Color wellColor) {
    final base = inset ?? 8;
    final top = insetTop ?? base;
    final bottom = insetBottom ?? base;
    final left = base;
    final right = base;

    // نفرض أبعاد الحاوية على الصورة حتى تتمدد لأقصى عرض/ارتفاع بدون قص.
    final image = LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        if (!w.isFinite || !h.isFinite || w <= 0 || h <= 0) {
          return _networkImage(wellColor);
        }
        return SizedBox(
          width: w,
          height: h,
          child: _networkImage(wellColor, width: w, height: h),
        );
      },
    );

    final padded = (left > 0 || top > 0 || right > 0 || bottom > 0)
        ? Padding(
            padding: EdgeInsets.fromLTRB(
              scale.s(left),
              scale.s(top),
              scale.s(right),
              scale.s(bottom),
            ),
            child: image,
          )
        : image;

    if (heroTag == null) return padded;
    return Hero(tag: heroTag!, child: padded);
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    final wellColor = backgroundColor;

    final content = overlay == null
        ? _imageContent(scale, wellColor)
        : Stack(
            fit: StackFit.expand,
            children: [
              _imageContent(scale, wellColor),
              overlay!,
            ],
          );

    final imageBox = ClipRRect(
      borderRadius: borderRadius,
      child: ColoredBox(
        color: wellColor,
        child: content,
      ),
    );

    if (!expand) {
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: imageBox,
      );
    }

    return SizedBox.expand(child: imageBox);
  }
}
