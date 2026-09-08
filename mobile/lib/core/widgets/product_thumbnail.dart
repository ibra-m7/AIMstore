import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_scale.dart';
import '../theme/app_theme.dart';
import 'app_network_image.dart';

/// صورة منتج موحّدة للبطاقات: تملأ الحاوية، بدون قص، مع خلفية محايدة.
class ProductThumbnail extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;
  final double aspectRatio;
  final double? inset;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final bool expand;
  final Widget? overlay;

  const ProductThumbnail({
    super.key,
    required this.imageUrl,
    this.heroTag,
    this.aspectRatio = 1,
    this.inset,
    this.backgroundColor = AppTheme.productImageWell,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.expand = true,
    this.overlay,
  });

  Widget _imageContent(AppScale scale, Color wellColor) {
    final child = Padding(
      padding: EdgeInsets.all(scale.s(inset ?? 8)),
      child: AppNetworkImage(
        imageUrl,
        fit: BoxFit.contain,
        alignment: Alignment.center,
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
      ),
    );

    if (heroTag == null) {
      return child;
    }

    return Hero(tag: heroTag!, child: child);
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
