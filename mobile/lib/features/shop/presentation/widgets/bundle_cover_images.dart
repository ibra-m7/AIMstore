import 'package:flutter/material.dart';

import '../../../../core/widgets/app_network_image.dart';
import '../../data/models/bundle_model.dart';

/// صورة غلاف سلة التوفير — صورة الغلاف، أو تكديس صور المنتجات إن لم تُضف صورة.
class BundleCoverImages extends StatelessWidget {
  final BundleModel bundle;

  const BundleCoverImages({super.key, required this.bundle});

  @override
  Widget build(BuildContext context) {
    final cover = bundle.imageUrl?.trim() ?? '';
    final products = bundle.productPreviewUrls;
    final collage = _collage(products);

    if (cover.isEmpty) return collage;

    return SizedBox.expand(
      child: AppNetworkImage(
        cover,
        fit: BoxFit.contain,
        error: collage,
      ),
    );
  }

  Widget _collage(List<String> urls) {
    if (urls.isEmpty) {
      return const SizedBox.expand(
        child: AppNetworkImage('', fit: BoxFit.contain),
      );
    }
    if (urls.length == 1) {
      return SizedBox.expand(
        child: AppNetworkImage(urls.first, fit: BoxFit.contain),
      );
    }

    final shown = urls.take(3).toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite ? constraints.maxWidth : 118.0;
        final h = constraints.maxHeight.isFinite ? constraints.maxHeight : 82.0;
        final thumb = (w < h ? w : h) * (shown.length == 2 ? 0.62 : 0.52);

        final offsets = shown.length == 2
            ? <Offset>[
                Offset(-w * 0.12, h * 0.04),
                Offset(w * 0.12, -h * 0.04),
              ]
            : <Offset>[
                Offset.zero,
                Offset(-w * 0.16, h * 0.08),
                Offset(w * 0.16, -h * 0.08),
              ];

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < shown.length; i++)
                Transform.translate(
                  offset: offsets[i],
                  child: SizedBox(
                    width: thumb,
                    height: thumb,
                    child: AppNetworkImage(shown[i], fit: BoxFit.contain),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
