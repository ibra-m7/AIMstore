import 'package:flutter/material.dart';

import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/theme/app_scale.dart';
import '../../data/models/bundle_model.dart';

/// صورة غلاف سلة التوفير — صورة واحدة أو تكديس حتى 3 منتجات.
class BundleCoverImages extends StatelessWidget {
  final BundleModel bundle;
  final double? singleSize;
  final double? stackWidth;
  final double? stackHeight;
  final double? thumbSize;

  const BundleCoverImages({
    super.key,
    required this.bundle,
    this.singleSize,
    this.stackWidth,
    this.stackHeight,
    this.thumbSize,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    final urls = bundle.previewImageUrls;
    final one = singleSize ?? scale.s(96);
    final stackW = stackWidth ?? scale.s(118);
    final stackH = stackHeight ?? scale.s(82);
    final thumb = thumbSize ?? scale.s(58);

    if (urls.isEmpty) {
      return AppNetworkImage(
        '',
        width: one * 0.79,
        height: one * 0.79,
        fit: BoxFit.contain,
      );
    }
    if (urls.length == 1) {
      return AppNetworkImage(
        urls.first,
        width: one,
        height: one,
        fit: BoxFit.contain,
      );
    }

    final offsets = <Offset>[
      const Offset(0, 0),
      const Offset(-18, 7),
      const Offset(18, -7),
    ];

    return SizedBox(
      width: stackW,
      height: stackH,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < urls.length && i < 3; i++)
            Transform.translate(
              offset: offsets[i],
              child: _BundleCoverThumb(url: urls[i], size: thumb),
            ),
        ],
      ),
    );
  }
}

class _BundleCoverThumb extends StatelessWidget {
  final String url;
  final double size;

  const _BundleCoverThumb({required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: AppNetworkImage(url, fit: BoxFit.contain),
    );
  }
}
