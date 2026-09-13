import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/models/home_feed.dart';

enum PaymentKind { cash, wallet, card, other }

const yemenWalletIds = {
  'cash_wallet',
  'jeeb',
  'floosak',
  'onecash',
  'jawali',
  'banky',
  'easy',
  'mobile_money',
  'stc_pay',
  'stc',
  'wallet',
};

PaymentKind paymentKindFor(String id) {
  if (id == 'cash') return PaymentKind.cash;
  if (yemenWalletIds.contains(id)) return PaymentKind.wallet;
  if (id == 'mada' || id == 'card' || id == 'apple_pay') {
    return PaymentKind.card;
  }
  return PaymentKind.other;
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
    this.width = 64,
    this.height = 48,
    this.fit = BoxFit.contain,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  static String? bundledAsset(String id) {
    return switch (id) {
      'cash' => 'assets/images/payments/cash.png',
      'cash_wallet' => 'assets/images/payments/cash_wallet.png',
      'jeeb' => 'assets/images/payments/jeeb.png',
      'floosak' => 'assets/images/payments/floosak.png',
      'onecash' => 'assets/images/payments/onecash.png',
      'jawali' => 'assets/images/payments/jawali.png',
      'banky' => 'assets/images/payments/banky.png',
      'easy' => 'assets/images/payments/easy.png',
      'mobile_money' => 'assets/images/payments/mobile_money.png',
      'kuraimi' => 'assets/images/payments/kuraimi.png',
      'stc_pay' || 'stc' || 'wallet' => 'assets/images/payments/stc_pay.svg',
      'mada' => 'assets/images/payments/mada.svg',
      'card' => 'assets/images/payments/visa.svg',
      'apple_pay' => 'assets/images/payments/apple_pay.svg',
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    // الأيقونات المضمّنة تظهر فوراً بدون انتظار الشبكة.
    final bundled = bundledAsset(method.id);
    if (bundled != null) {
      return _bundled(bundled);
    }

    final url = method.iconUrl.trim();
    if (url.startsWith('http') || url.startsWith('https')) {
      final lower = url.toLowerCase();
      final isSvg = lower.endsWith('.svg') || lower.contains('image/svg');
      if (isSvg) {
        return _clip(
          SvgPicture.network(
            url,
            width: width,
            height: height,
            fit: fit,
            placeholderBuilder: (_) => _iconFallback(),
          ),
        );
      }
      return _clip(
        AppNetworkImage(
          url,
          width: width,
          height: height,
          fit: fit,
          error: _iconFallback(),
        ),
      );
    }

    return _iconFallback();
  }

  Widget _bundled(String asset) {
    final lower = asset.toLowerCase();
    if (lower.endsWith('.svg')) {
      return _clip(
        SvgPicture.asset(
          asset,
          width: width,
          height: height,
          fit: fit,
        ),
      );
    }

    final w = width;
    final h = height;
    return _clip(
      Image.asset(
        asset,
        width: w,
        height: h,
        fit: fit,
        // فك ترميز بحجم العرض فقط لتسريع الرسم
        cacheWidth: w == null ? null : (w * 3).round().clamp(64, 512),
        cacheHeight: h == null ? null : (h * 3).round().clamp(32, 256),
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _iconFallback(),
      ),
    );
  }

  Widget _clip(Widget child) {
    final radius = borderRadius;
    if (radius == null) return child;
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: child,
      ),
    );
  }

  Widget _iconFallback() {
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
