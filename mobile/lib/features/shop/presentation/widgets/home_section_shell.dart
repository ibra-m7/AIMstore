import 'package:flutter/material.dart';

import '../../../../core/theme/home_section_gradient.dart';
import '../../../../core/widgets/app_network_image.dart';

class HomeSectionShell extends StatelessWidget {
  final List<Color> gradientColors;
  final String? backgroundImageUrl;
  final bool curveTop;
  final bool curveBottom;
  final Widget child;

  const HomeSectionShell({
    super.key,
    required this.gradientColors,
    this.backgroundImageUrl,
    this.curveTop = false,
    this.curveBottom = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = (backgroundImageUrl ?? '').trim();
    final gradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: gradientColors,
    );

    return ClipPath(
      clipper: _SectionWaveClipper(
        curveTop: curveTop,
        curveBottom: curveBottom,
      ),
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(gradient: gradient),
        child: imageUrl.isEmpty
            ? child
            : Stack(
                fit: StackFit.passthrough,
                children: [
                  Positioned.fill(
                    child: AppNetworkImage(
                      imageUrl,
                      fit: BoxFit.cover,
                      error: const SizedBox.shrink(),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.08),
                            Colors.black.withValues(alpha: 0.18),
                          ],
                        ),
                      ),
                    ),
                  ),
                  child,
                ],
              ),
      ),
    );
  }
}

class _SectionWaveClipper extends CustomClipper<Path> {
  final bool curveTop;
  final bool curveBottom;

  const _SectionWaveClipper({
    this.curveTop = false,
    this.curveBottom = true,
  });

  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height);
    if (curveBottom) {
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height + 18,
        size.width,
        size.height,
      );
    } else {
      path.lineTo(size.width, size.height);
    }
    path.lineTo(size.width, 0);
    if (curveTop) {
      path.quadraticBezierTo(size.width * 0.5, -18, 0, 0);
    } else {
      path.lineTo(0, 0);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _SectionWaveClipper old) =>
      old.curveTop != curveTop || old.curveBottom != curveBottom;
}

Color? homeSectionTextColor(String? hex, Color fallback) {
  return HomeSectionGradient.parseHex(hex) ?? fallback;
}
