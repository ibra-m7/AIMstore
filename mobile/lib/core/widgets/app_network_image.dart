import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../config/env_config.dart';
import '../theme/app_theme.dart';
import 'brand_logo.dart';

/// صورة من الشبكة مع كاش على القرص وذاكرة مضغوطة للتمرير السلس.
class AppNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final Alignment alignment;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? error;

  /// من إعدادات المتجر: تظهر إذا المنتج بلا صورة أو رابط صورته فشل.
  static String fallbackUrl = '';

  /// روابط فشل تحميلها (404 وغيرها) — لا تُطلب مجدداً أثناء الجلسة.
  static final LinkedHashSet<String> _deadUrls = LinkedHashSet<String>();
  static const _deadLimit = 400;

  const AppNetworkImage(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.placeholder,
    this.error,
  });

  static const headers = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36',
    'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
  };

  /// Unsplash يحتاج ترويسة متصفح. تخزين Laravel المحلي يرفضها أحياناً بـ 403.
  static Map<String, String>? headersFor(String url) {
    final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
    if (host.contains('unsplash.com') || host.contains('wsrv.nl')) {
      return headers;
    }
    return null;
  }

  static bool isDead(String url) {
    final resolved = resolveUrl(url.trim());
    return resolved.isNotEmpty && _deadUrls.contains(resolved);
  }

  static void _markDead(String url) {
    final value = url.trim();
    if (value.isEmpty || _deadUrls.contains(value)) return;
    if (_deadUrls.length >= _deadLimit) {
      _deadUrls.remove(_deadUrls.first);
    }
    _deadUrls.add(value);
  }

  /// يحوّل روابط التخزين النسبية والقديمة إلى أصل الـ API الحالي.
  static String resolveUrl(String raw) {
    final url = raw.trim();
    if (url.isEmpty || url.startsWith('data:') || url.startsWith('blob:')) {
      return url;
    }

    final origin = Uri.tryParse(EnvConfig.apiOrigin);
    final uri = Uri.tryParse(url);

    if (uri == null || !uri.hasScheme) {
      return _joinOrigin(origin, url);
    }

    final host = uri.host.toLowerCase();
    if (host == 'images.unsplash.com' || host == 'unsplash.com') {
      return Uri.https('wsrv.nl', '/', {
        'url': url,
        'w': '1200',
        'q': '82',
        'output': 'jpg',
      }).toString();
    }

    if (_isAppMedia(uri) && origin != null && origin.host.isNotEmpty) {
      if (!_sameOrigin(uri, origin) || _shouldRewriteMediaHost(host)) {
        return _rewriteToCurrentOrigin(uri, origin);
      }
    } else if (_shouldRewriteMediaHost(host)) {
      return _rewriteToCurrentOrigin(uri, origin);
    }

    return url;
  }

  static bool _isAppMedia(Uri uri) {
    final path = uri.path;
    return path.contains('/storage/') ||
        path.startsWith('/media/') ||
        path.contains('/media/fallback') ||
        path.contains('/media/home-logo');
  }

  static bool _shouldRewriteMediaHost(String host) {
    if (host.contains('onrender.com')) return true;
    const legacy = {
      '16.171.249.18',
      '16.16.172.215',
      '172.20.2.192',
      '172.20.2.95',
      '172.20.2.63',
      '172.20.2.66',
      '192.168.134.66',
    };
    return legacy.contains(host);
  }

  static bool _sameOrigin(Uri uri, Uri origin) {
    if (uri.host.toLowerCase() != origin.host.toLowerCase()) return false;
    if (uri.scheme != origin.scheme) return false;
    return _effectivePort(uri) == _effectivePort(origin);
  }

  static int _effectivePort(Uri uri) {
    if (uri.hasPort) return uri.port;
    return uri.scheme == 'https' ? 443 : 80;
  }

  static String _joinOrigin(Uri? origin, String path) {
    if (origin == null || origin.host.isEmpty) return path;
    final parsed = Uri.tryParse(path.startsWith('/') ? path : '/$path');
    return origin.replace(
      path: parsed?.path ?? path,
      query: (parsed?.query.isEmpty ?? true) ? null : parsed!.query,
    ).toString();
  }

  static String _rewriteToCurrentOrigin(Uri uri, Uri? origin) {
    if (origin == null || origin.host.isEmpty) {
      return uri.toString();
    }

    return Uri(
      scheme: origin.scheme,
      host: origin.host,
      port: origin.hasPort ? origin.port : null,
      path: uri.path,
      query: uri.query.isEmpty ? null : uri.query,
    ).toString();
  }

  int? get _memCacheWidth {
    if (width == null) return 400;
    final dpr = WidgetsBinding.instance.platformDispatcher.views.isEmpty
        ? 2.0
        : WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    return (width! * dpr).round().clamp(48, 800);
  }

  @override
  Widget build(BuildContext context) {
    final primary = url.trim();
    final fallback = fallbackUrl.trim();
    final first = primary.isNotEmpty ? primary : fallback;
    if (first.isEmpty) {
      return _localFallback();
    }

    final storeFallback = fallback.isNotEmpty && fallback != first
        ? fallback
        : null;

    return _network(
      first,
      onError: storeFallback == null
          ? _localFallback
          : () => _network(storeFallback, onError: _localFallback),
    );
  }

  Widget _localFallback() {
    return SizedBox(
      width: width,
      height: height,
      child: ColoredBox(
        color: AppTheme.primarySurface,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Image.asset(
            BrandLogoMark.assetPath,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) =>
                error ?? _defaultError(width, height),
          ),
        ),
      ),
    );
  }

  Widget _network(
    String raw, {
    Widget Function()? onError,
  }) {
    final resolved = resolveUrl(raw);
    if (resolved.isEmpty || _deadUrls.contains(resolved)) {
      return onError?.call() ?? error ?? _localFallback();
    }
    return CachedNetworkImage(
      imageUrl: resolved,
      httpHeaders: headersFor(resolved),
      fit: fit,
      alignment: alignment,
      width: width,
      height: height,
      fadeInDuration: const Duration(milliseconds: 80),
      memCacheWidth: _memCacheWidth,
      maxWidthDiskCache: 800,
      maxHeightDiskCache: 800,
      filterQuality: FilterQuality.low,
      errorListener: (_) {},
      placeholder: (_, _) => placeholder ?? _defaultPlaceholder(width, height),
      errorWidget: (_, failedUrl, _) {
        _markDead(resolved);
        _markDead(failedUrl);
        return onError?.call() ?? error ?? _defaultError(width, height);
      },
    );
  }

  static Widget _defaultPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: AppTheme.primarySurface,
    );
  }

  static Widget _defaultError(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: AppTheme.primarySurface,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppTheme.mutedText,
        size: (width != null && width < 48) ? 18 : 28,
      ),
    );
  }
}
