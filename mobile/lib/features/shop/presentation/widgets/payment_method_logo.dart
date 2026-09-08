import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/models/home_feed.dart';

enum PaymentKind { cash, stcPay, card, other }

PaymentKind paymentKindFor(String id) {
  switch (id) {
    case 'stc_pay':
    case 'stc':
    case 'wallet':
      return PaymentKind.stcPay;
    case 'mada':
    case 'card':
    case 'apple_pay':
      return PaymentKind.card;
    case 'cash':
      return PaymentKind.cash;
    default:
      return PaymentKind.other;
  }
}

class PaymentMethodLogo extends StatelessWidget {
  final PaymentOption method;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const PaymentMethodLogo({
    super.key,
    required this.method,
    this.width = 52,
    this.height = 32,
    this.fit = BoxFit.contain,
    this.borderRadius,
  });

  static String? bundledAsset(String id) {
    return switch (id) {
      'stc_pay' || 'stc' || 'wallet' => 'assets/images/payments/stc_pay.svg',
      'mada' => 'assets/images/payments/mada.svg',
      'card' => 'assets/images/payments/visa.svg',
      'apple_pay' => 'assets/images/payments/apple_pay.svg',
      'cash' => 'assets/images/payments/cash.svg',
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final url = method.iconUrl.trim();
    if (url.isEmpty) {
      return _bundledOrFallback();
    }

    final lower = url.toLowerCase();
    final isSvg = lower.endsWith('.svg') || lower.contains('image/svg');

    if (url.startsWith('http') || url.startsWith('https')) {
      if (isSvg) {
        return _clip(
          SvgPicture.network(
            url,
            width: width,
            height: height,
            fit: fit,
            placeholderBuilder: (_) => _bundledOrFallback(),
          ),
        );
      }
      return _clip(
        AppNetworkImage(
          url,
          width: width,
          height: height,
          fit: fit,
          error: _bundledOrFallback(),
        ),
      );
    }

    return _bundledOrFallback();
  }

  Widget _clip(Widget child) {
    final radius = borderRadius;
    if (radius == null) return child;
    return ClipRRect(borderRadius: radius, child: child);
  }

  Widget _bundledOrFallback() {
    final asset = bundledAsset(method.id);
    if (asset != null) {
      return _clip(
        SvgPicture.asset(
          asset,
          width: width,
          height: height,
          fit: fit,
        ),
      );
    }
    final iconSize = (height ?? 32) * 0.55;
    return ColoredBox(
      color: AppTheme.primarySurface,
      child: Center(
        child: Icon(
          Icons.payments_rounded,
          color: AppTheme.primaryDark,
          size: iconSize,
        ),
      ),
    );
  }
}
