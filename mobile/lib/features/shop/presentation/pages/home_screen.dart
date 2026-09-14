import 'dart:async';
import 'dart:ui' show lerpDouble;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_scale.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_count_badge.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/notification_bell_icon.dart';
import '../../../../features/auth/data/services/auth_session.dart';
import '../../../../features/auth/presentation/manager/address_cubit.dart';
import '../../../../features/auth/presentation/pages/profile_screen.dart';
import '../../../../features/notifications/presentation/manager/notifications_cubit.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../features/ai_assistant/presentation/cubit/ai_controller_cubit.dart';
import '../../../../features/ai_assistant/presentation/widgets/ai_assistant_launch_sheet.dart';
import '../../../../features/notifications/data/services/push_service.dart';
import '../manager/cart_cubit.dart';
import '../../data/models/category_model.dart';
import '../../data/models/dynamic_page_model.dart';
import '../../data/models/home_feed.dart';
import '../../data/models/product_model.dart';
import 'custom_dynamic_page_screen.dart';
import 'home_section_browse_screen.dart';
import '../manager/catalog_cubit.dart';
import '../manager/favorite_cubit.dart';
import '../manager/orders_cubit.dart';
import '../widgets/header_search_bar.dart';
import '../widgets/main_bottom_nav_bar.dart';
import '../widgets/main_shell_scope.dart';
import '../widgets/price_line.dart';
import '../widgets/product_card.dart';
import '../widgets/auto_scroll_horizontal_list.dart';
import '../widgets/bundle_banner_section.dart';
import '../widgets/home_section_shell.dart';
import '../widgets/card_cart_control.dart';
import '../widgets/product_card_shimmer.dart';
import '../widgets/product_preview_sheet.dart';
import '../widgets/promo_badge.dart';
import '../widgets/scroll_refresh_shell.dart';
import 'categories_screen.dart';
import 'checkout_screen.dart';
import '../widgets/cart_sheet.dart';

// ── قص موجي لخلفيات الأقسام الترويجية (حافة علوية/سفلية ناعمة كمرجع كيو) ───
class _SectionWaveClipper extends CustomClipper<Path> {
  _SectionWaveClipper({this.curveTop = false, this.curveBottom = true});
  final bool curveTop;
  final bool curveBottom;
  static const double _amp = 16;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    if (curveTop) {
      path.moveTo(0, _amp);
      path.quadraticBezierTo(w / 2, 0, w, _amp);
    } else {
      path.moveTo(0, 0);
      path.lineTo(w, 0);
    }
    path.lineTo(w, curveBottom ? h - _amp : h);
    if (curveBottom) {
      path.quadraticBezierTo(w / 2, h, 0, h - _amp);
    } else {
      path.lineTo(0, h);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _SectionWaveClipper old) =>
      old.curveTop != curveTop || old.curveBottom != curveBottom;
}

const _homeAppBarColor = Color(0xFFFAFFFC);

class _HomeBrandMark extends StatelessWidget {
  const _HomeBrandMark();

  @override
  Widget build(BuildContext context) {
    final logoUrl = context.select(
      (CatalogCubit c) => c.state.store.homeLogoUrl,
    );
    return HomeBrandLogo(height: 34, networkUrl: logoUrl);
  }
}

const double _kHomeLogoRow = 58;
const double _kHomeSearchH = 42;
const double _kHomeBannerH = 236;
const double _kHomeBannerBlend = 14;

class _PromoSlide {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final ProductModel? product;
  final String? pageId;

  const _PromoSlide({
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.product,
    this.pageId,
  });

  @override
  bool operator ==(Object other) =>
      other is _PromoSlide &&
      other.imageUrl == imageUrl &&
      other.title == title &&
      other.product?.id == product?.id &&
      other.pageId == pageId;

  @override
  int get hashCode => Object.hash(imageUrl, title, product?.id, pageId);
}

void _openPromoSlide(BuildContext context, _PromoSlide slide) {
  final pageId = slide.pageId;
  if (pageId != null && pageId.isNotEmpty) {
    final initial = context.read<CatalogCubit>().state.pageById(pageId);
    Navigator.of(context).pushNamed(
      AppRouter.dynamicPage,
      arguments: DynamicPageArgs(pageId: pageId, initial: initial),
    );
    return;
  }
  if (slide.product != null) {
    showProductPreview(context, slide.product!);
  }
}

String _promoSlideTitle({
  required BannerModel banner,
  DynamicPageModel? page,
  ProductModel? product,
}) {
  if (banner.showTitle && banner.title.trim().isNotEmpty) {
    return banner.title.trim();
  }
  if (page != null && page.showTitle && page.title.trim().isNotEmpty) {
    return page.title.trim();
  }
  if (banner.showTitle && product != null) {
    return product.name.trim();
  }
  return '';
}

List<_PromoSlide> _promoSlidesFor(CatalogState catalog) {
  final slides = <_PromoSlide>[];
  for (final banner in catalog.banners) {
    final product = banner.linkType == 'product' && banner.linkId != null
        ? catalog.productsById[banner.linkId!]
        : null;
    DynamicPageModel? page;
    if (banner.linkType == 'page' && banner.linkId != null) {
      page = catalog.pageById(banner.linkId!);
    }
    final image = banner.imageUrl.trim().isNotEmpty
        ? banner.imageUrl
        : (page?.bannerImageUrl.isNotEmpty == true
              ? page!.bannerImageUrl
              : (product?.imageUrl ?? ''));
    if (image.isEmpty &&
        banner.title.trim().isEmpty &&
        product == null &&
        page == null) {
      continue;
    }
    slides.add(
      _PromoSlide(
        imageUrl: image,
        title: _promoSlideTitle(
          banner: banner,
          page: page,
          product: product,
        ),
        subtitle: banner.subtitle ?? product?.quantityLabel,
        product: product,
        pageId: page?.id ?? (banner.linkType == 'page' ? banner.linkId : null),
      ),
    );
  }
  if (slides.isNotEmpty) return slides;

  final promoProducts = <ProductModel>[
    if (catalog.store.showOffersAsBanner) ...catalog.offers,
    if (catalog.store.showDiscountsAsBanner)
      ...catalog.discounts.where(
        (product) => !catalog.offers.any((offer) => offer.id == product.id),
      ),
  ];
  return [
    for (final product in promoProducts.take(4))
      _PromoSlide(
        imageUrl: product.imageUrl,
        title: product.name,
        subtitle: product.quantityLabel,
        product: product,
      ),
  ];
}

class _HomeNotificationsButton extends StatefulWidget {
  const _HomeNotificationsButton();

  @override
  State<_HomeNotificationsButton> createState() =>
      _HomeNotificationsButtonState();
}

class _HomeNotificationsButtonState extends State<_HomeNotificationsButton>
    with SingleTickerProviderStateMixin {
  static const _bellLight = Color(0xFF6B8FD9);
  static const _bellMid = AppTheme.primary;
  static const _bellDeep = AppTheme.primaryDark;

  late final AnimationController _ringCtrl;
  late final Animation<double> _ringTurns;
  bool _hasUnread = false;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    );
    _ringTurns = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.07), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.07, end: -0.07), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.07, end: 0.05), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.05, end: -0.03), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.03, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _ringCtrl, curve: Curves.easeInOut));
    _ringCtrl.addStatusListener(_onRingStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final unread = context.read<NotificationsCubit>().state.unreadCount;
      _syncUnreadRing(unread > 0);
    });
  }

  @override
  void dispose() {
    _ringCtrl.removeStatusListener(_onRingStatus);
    _ringCtrl.dispose();
    super.dispose();
  }

  void _onRingStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted || !_hasUnread) {
      return;
    }
    Future<void>.delayed(const Duration(seconds: 4), () {
      if (!mounted || !_hasUnread || _ringCtrl.isAnimating) return;
      _ringCtrl.forward(from: 0);
    });
  }

  void _syncUnreadRing(bool hasUnread) {
    if (_hasUnread == hasUnread) return;
    _hasUnread = hasUnread;
    if (!hasUnread) {
      _ringCtrl.stop();
      _ringCtrl.value = 0;
      return;
    }
    if (!_ringCtrl.isAnimating) {
      Future<void>.delayed(const Duration(milliseconds: 600), () {
        if (!mounted || !_hasUnread) return;
        _ringCtrl.forward(from: 0);
      });
    }
  }

  Future<void> _ringOnce() async {
    if (_ringCtrl.isAnimating) return;
    await _ringCtrl.forward(from: 0);
    if (mounted) {
      _ringCtrl.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationsCubit, NotificationsState>(
      listenWhen: (prev, curr) =>
          (prev.unreadCount > 0) != (curr.unreadCount > 0),
      listener: (context, state) {
        _syncUnreadRing(state.unreadCount > 0);
      },
      child: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          final hasUnread = state.unreadCount > 0;

          return IconButton(
          tooltip: 'الإشعارات',
          onPressed: () async {
            unawaited(_ringOnce());
            unawaited(context.read<NotificationsCubit>().load(silent: true));
            Navigator.of(context).pushNamed(AppRouter.notifications);
          },
          icon: AppCountBadge.wrap(
            count: state.unreadCount,
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: hasUnread
                    ? [
                        BoxShadow(
                          color: AppTheme.accent.withValues(alpha: 0.28),
                          blurRadius: 14,
                          spreadRadius: 0.5,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: _bellDeep.withValues(alpha: 0.18),
                          blurRadius: 8,
                        ),
                      ],
              ),
              child: RotationTransition(
                alignment: const Alignment(0, -0.55),
                turns: _ringTurns,
                child: NotificationBellIcon(
                  size: 27,
                  active: hasUnread,
                  light: _bellLight,
                  mid: _bellMid,
                  deep: _bellDeep,
                ),
              ),
            ),
          ),
        );
        },
      ),
    );
  }
}

class _HomeMagicHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPad;
  final double bannerH;
  final double searchH;
  final double logoRow;
  final double bannerBlend;
  final double bannerFadeHeight;
  final VoidCallback onSearchTap;
  final List<_PromoSlide> slides;
  final bool loading;

  const _HomeMagicHeaderDelegate({
    required this.topPad,
    required this.bannerH,
    required this.searchH,
    required this.logoRow,
    required this.bannerBlend,
    required this.bannerFadeHeight,
    required this.onSearchTap,
    required this.slides,
    required this.loading,
  });

  bool get _hasBanner => loading || slides.isNotEmpty;

  double get _expandedTail =>
      8 +
      logoRow +
      10 +
      searchH +
      (_hasBanner ? 14 + bannerH + bannerBlend : 4);

  static double computeMaxExtent({
    required double topPad,
    required double bannerH,
    required double searchH,
    required double logoRow,
    required double bannerBlend,
    required bool hasBanner,
  }) {
    final expandedTail = 8 +
        logoRow +
        10 +
        searchH +
        (hasBanner ? 14 + bannerH + bannerBlend : 4);
    return topPad + expandedTail;
  }

  @override
  double get maxExtent => topPad + _expandedTail;

  @override
  double get minExtent =>
      _hasBanner ? bannerH + 2 : topPad + 22 + searchH;

  @override
  bool shouldRebuild(covariant _HomeMagicHeaderDelegate old) {
    return topPad != old.topPad ||
        bannerH != old.bannerH ||
        searchH != old.searchH ||
        logoRow != old.logoRow ||
        bannerBlend != old.bannerBlend ||
        bannerFadeHeight != old.bannerFadeHeight ||
        loading != old.loading ||
        slides != old.slides;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = (maxExtent - minExtent).clamp(1.0, 900.0);
        final t = (shrinkOffset / span).clamp(0.0, 1.0);
        final p = Curves.easeOutCubic.transform(t);
        final chrome = (1.0 - p * 1.25).clamp(0.0, 1.0);
        final logoOpacity = (1.0 - p * 1.15).clamp(0.0, 1.0);
        final barOpacity = (1.0 - p).clamp(0.0, 1.0);
        final bannerTop = lerpDouble(
          topPad + 8 + logoRow + 8 + searchH + 14,
          0,
          p,
        )!;
        final bannerInset = lerpDouble(14, 0, p)!;
        // نصف قطر خفيف في الوضع الموسّع، وأسفل خفيف عند الانكماش (وضع الـ AppBar).
        final bannerTopRadius = lerpDouble(10, 6, p)!;
        final bannerBottomRadius = lerpDouble(10, 6, p)!;
        final blendH = lerpDouble(bannerFadeHeight, 2, p)!;
        final blendOpacity = (1.0 - p).clamp(0.0, 1.0);
        final searchTop = lerpDouble(
          topPad + 8 + logoRow + 6,
          _hasBanner ? topPad + 8 : topPad + 22,
          p,
        )!;
        // مع بانر: تضييق من اليسار فوق الصورة. بدون بانر: عند التمرير مثل الأقسام (16).
        final searchLeft = _hasBanner
            ? lerpDouble(12, 56, p)!
            : lerpDouble(12, 16, p)!;
        final searchRight = _hasBanner
            ? 12.0
            : lerpDouble(12, 16, p)!;
        final logoScale = lerpDouble(1.0, 0.72, p)!;
        // بدون بانر: الوضع الموسّع كالسابق، والمنكمش بأسلوب الأقسام.
        final noBannerCollapsed = !_hasBanner && p > 0.35;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: (_hasBanner && p > 0.55)
              ? SystemUiOverlayStyle.light.copyWith(
                  statusBarColor: Colors.transparent,
                )
              : SystemUiOverlayStyle.dark.copyWith(
                  statusBarColor: Colors.transparent,
                ),
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: AppTheme.background.withValues(alpha: barOpacity),
                ),
                if (_hasBanner)
                  Positioned(
                    left: bannerInset,
                    right: bannerInset,
                    top: bannerTop,
                    height: bannerH,
                    child: RepaintBoundary(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(bannerTopRadius),
                          topRight: Radius.circular(bannerTopRadius),
                          bottomLeft: Radius.circular(bannerBottomRadius),
                          bottomRight: Radius.circular(bannerBottomRadius),
                        ),
                        child: loading
                            ? const _PromoShimmer(fill: true)
                            : _HomePromoSlider(
                                key: ValueKey(
                                  slides
                                      .map((s) => s.imageUrl)
                                      .join('|'),
                                ),
                                slides: slides,
                                contentOpacity: 1,
                                showDots: slides.length > 1,
                              ),
                      ),
                    ),
                  ),
                if (_hasBanner && blendOpacity > 0.02)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: bannerTop + bannerH,
                    height: blendH,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: blendOpacity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.background.withValues(alpha: 0),
                                AppTheme.background,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: topPad + 8 + logoRow + 8 + searchH,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: _hasBanner
                              ? [
                                  _homeAppBarColor.withValues(
                                    alpha: barOpacity,
                                  ),
                                  _homeAppBarColor.withValues(
                                    alpha: barOpacity * 0.85,
                                  ),
                                  _homeAppBarColor.withValues(alpha: 0),
                                ]
                              : [
                                  // بدون بانر: لون العلامة للتطبيق في الـ AppBar.
                                  Color.lerp(
                                    _homeAppBarColor.withValues(
                                      alpha: barOpacity,
                                    ),
                                    AppTheme.primarySurface,
                                    p,
                                  )!,
                                  Color.lerp(
                                    _homeAppBarColor.withValues(
                                      alpha: barOpacity * 0.85,
                                    ),
                                    AppTheme.primarySurface,
                                    p,
                                  )!,
                                  Color.lerp(
                                    _homeAppBarColor.withValues(alpha: 0),
                                    AppTheme.primarySurface.withValues(
                                      alpha: 0,
                                    ),
                                    p,
                                  )!,
                                ],
                        ),
                      ),
                    ),
                  ),
                ),
                // بدون بانر عند التمرير: خلفية AppBar بلون العلامة.
                if (!_hasBanner && p > 0.02)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: Curves.easeOut.transform(p),
                        child: const ColoredBox(color: AppTheme.primarySurface),
                      ),
                    ),
                  ),
                // بدون بانر: لا تدرّج سفلي حتى تلتصق «استكشف الأقسام» بالـ AppBar.
                Positioned(
                  top: topPad + 2,
                  left: 10,
                  right: 12,
                  height: logoRow,
                  child: IgnorePointer(
                    ignoring: chrome < 0.15,
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Opacity(
                          opacity: logoOpacity,
                          child: Transform.translate(
                            offset: Offset(0, -10 * p),
                            child: Transform.scale(
                              alignment: Alignment.centerRight,
                              scale: logoScale,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: _HomeBrandMark(),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Opacity(
                          opacity: chrome,
                          child: Transform.translate(
                            offset: Offset(0, -12 * p),
                            child: const _HomeNotificationsButton(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: searchTop,
                  left: searchLeft,
                  right: searchRight,
                  height: searchH,
                  child: HeaderSearchRow(
                    onSearchTap: onSearchTap,
                    onImage: _hasBanner && p > 0.4,
                    chromeVisibility: chrome,
                    // بدون بانر + تمرير: حقل صلب بنص التلميح الصغير القوي كما في الوضع الموسّع.
                    glassAmount: noBannerCollapsed
                        ? 0
                        : Curves.easeOut.transform(p),
                    searchBorderRadius: _hasBanner
                        ? lerpDouble(10, 8, p)!
                        : 10,
                    glassMode: HeaderSearchGlassMode.home,
                  ),
                ),
                if (_hasBanner && p > 0.35)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 8,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06 * p),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── قسم ترويجي بخلفية منحنية + قائمة منتجات أفقية (مرجع كيو) ─────────────────
class _CurvedProductCarouselSection extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// عند ضبطه يُستبدل ستايل [subtitle] الافتراضي (مثلاً سطر أساسي بلون الهوية).
  final TextStyle? subtitleStyle;

  /// يُرسَم قبل عنوان القسم في الصفّ (مثل أيقونة Lottie).
  final Widget? titleLeading;
  final List<ProductModel> products;
  final List<Color> gradientColors;
  final String? backgroundImageUrl;
  final Color? titleColor;
  final Color? subtitleColor;
  final bool curveTop;
  final bool curveBottom;
  final bool ticker;
  final VoidCallback? onViewAll;
  final double titleFontSize;
  final double subtitleFontSize;
  final double? cardWidth;
  final double? rowHeight;
  final double itemSpacing;
  final double paddingTop;
  final double paddingBottom;

  const _CurvedProductCarouselSection({
    required this.title,
    this.subtitle,
    this.subtitleStyle,
    this.titleLeading,
    required this.products,
    required this.gradientColors,
    this.backgroundImageUrl,
    this.titleColor,
    this.subtitleColor,
    this.curveTop = false,
    this.curveBottom = true,
    this.ticker = false,
    this.onViewAll,
    this.titleFontSize = HomeSectionModel.defaultTitleFontSize,
    this.subtitleFontSize = HomeSectionModel.defaultSubtitleFontSize,
    this.cardWidth,
    this.rowHeight,
    this.itemSpacing = HomeSectionModel.defaultItemSpacing,
    this.paddingTop = HomeSectionModel.defaultPaddingTop,
    this.paddingBottom = HomeSectionModel.defaultPaddingBottom,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    final scale = AppScale.of(context);
    final cardW = scale.s(cardWidth ?? HomeSectionModel.defaultCardWidth);
    final listH = rowHeight != null
        ? scale.s(rowHeight!)
        : cardW / AppScale.productCardAspect;
    final gap = scale.s(itemSpacing);
    final titleSize = scale.s(titleFontSize);
    final subtitleSize = scale.s(subtitleFontSize);

    return HomeSectionShell(
      gradientColors: gradientColors,
      backgroundImageUrl: backgroundImageUrl,
      curveTop: curveTop,
      curveBottom: curveBottom,
      child: Padding(
        padding: EdgeInsets.only(
          top: scale.s(paddingTop),
          bottom: scale.s(paddingBottom),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: scale.pagePad),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (titleLeading != null) ...[
                              titleLeading!,
                              SizedBox(width: scale.s(8)),
                            ],
                            Flexible(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.sectionTitle.copyWith(
                                      fontSize: titleSize,
                                      color: titleColor ?? AppTheme.primaryDark,
                                      height: 1.15,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                              start: titleLeading != null ? scale.s(46) : 0,
                            ),
                            child: Text(
                              subtitle!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: subtitleStyle?.copyWith(
                                    fontSize: subtitleSize,
                                  ) ??
                                  Theme.of(
                                    context,
                                  ).textTheme.labelSmall?.copyWith(
                                    fontSize: subtitleSize,
                                    color: subtitleColor ?? AppTheme.mutedText,
                                    fontWeight: FontWeight.w600,
                                    height: 1.25,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onViewAll,
                    style: TextButton.styleFrom(
                      foregroundColor: titleColor ?? AppTheme.primaryDark,
                      padding: const EdgeInsetsDirectional.only(start: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStrings.homeShowAll,
                            style: AppTextStyles.viewAll.copyWith(
                              color: AppTheme.primary,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 15,
                            color: AppTheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: scale.s(12)),
            SizedBox(
              height: listH,
              child: ticker
                  ? AutoScrollHorizontalList(
                      height: listH,
                      itemWidth: cardW,
                      gap: gap,
                      padding: EdgeInsets.symmetric(horizontal: scale.pagePad),
                      itemCount: products.length,
                      itemBuilder: (_, i) => ProductCard(
                        product: products[i],
                        heroTag: 'home_carousel_${title}_${i}_${products[i].id}',
                        compactFooter: true,
                        tightFooterTop: true,
                        densePriceArea: true,
                        imageAlignment: Alignment.center,
                        imageInset: 4,
                        imageInsetTop: 4,
                        imageInsetBottom: 4,
                        imageScale: 1.22,
                        cartButtonSize: 24,
                        cartButtonStartInset: 10,
                        cartButtonBottomInset: 16,
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      cacheExtent: 200,
                      padding: EdgeInsets.symmetric(
                        horizontal: scale.pagePad,
                      ),
                      itemCount: products.length,
                      separatorBuilder: (_, _) => SizedBox(width: gap),
                      itemBuilder: (_, i) => SizedBox(
                        width: cardW,
                        child: ProductCard(
                          product: products[i],
                          heroTag:
                              'home_carousel_${title}_${i}_${products[i].id}',
                          compactFooter: true,
                          tightFooterTop: true,
                          densePriceArea: true,
                          imageAlignment: Alignment.center,
                          imageInset: 4,
                          imageInsetTop: 4,
                          imageInsetBottom: 4,
                          imageScale: 1.22,
                          cartButtonSize: 24,
                          cartButtonStartInset: 10,
                          cartButtonBottomInset: 16,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeRestProductsDivider extends StatelessWidget {
  const _HomeRestProductsDivider();

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        scale.pagePad,
        scale.s(8),
        scale.pagePad,
        scale.s(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x00000000),
                    Color(0x33003399),
                    Color(0x66003399),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: scale.s(12)),
            child: Text(
              'منتجاتنا',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppTheme.darkText,
                fontSize: scale.s(12),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x66003399),
                    Color(0x33003399),
                    Color(0x00000000),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeScrollToTopButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onTap;

  const _HomeScrollToTopButton({
    required this.visible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        offset: visible ? Offset.zero : const Offset(0, 1.4),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: visible ? 1 : 0,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset + 32),
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryLight,
                      AppTheme.primarySurface,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x29002266),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(0, 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryDark,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -8),
                          child: const Icon(
                            Icons.keyboard_arrow_up_rounded,
                            color: AppTheme.primaryDark,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionFireIcon extends StatelessWidget {
  const _SectionFireIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: Lottie.asset(
        'assets/lottie/fire.json',
        fit: BoxFit.contain,
        repeat: true,
      ),
    );
  }
}

// ── شريط أقسام سريعة — دائرة ممتلئة بالصورة بدون تشويه ─────────────────────
class _ExploreCategoriesStrip extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final List<CategoryModel> categories;
  final VoidCallback? onViewAll;
  final bool compact;

  const _ExploreCategoriesStrip({
    required this.selectedId,
    required this.onSelect,
    required this.categories,
    this.onViewAll,
    this.compact = false,
  });

  static double _circleSelected(AppScale scale, {required bool compact}) =>
      compact ? scale.s(38) : scale.categoryCircleSelected;

  static double _circle(AppScale scale, {required bool compact}) =>
      compact ? scale.s(32) : scale.categoryCircle;

  static double _itemWidth(AppScale scale, {required bool compact}) =>
      compact ? scale.s(60) : scale.categoryItemWidth;

  static double _stripHeight(AppScale scale, {required bool compact}) {
    final selected = _circleSelected(scale, compact: compact);
    final ring = compact ? 1.5 : scale.categoryRing;
    final labelBlock = compact ? scale.s(22) : (scale.s(12) * 2 + scale.s(6));
    final gap = compact ? scale.s(4) : scale.s(8);
    return selected + ring * 2 + gap + labelBlock;
  }

  /// ارتفاع الشريط المثبّت — يتضمن فراغاً فوقه يفصل عن الـ AppBar.
  static double extentHeight(AppScale scale, {required bool compact}) {
    final topGap = compact ? scale.s(12) : 0.0;
    final titlePadTop = compact ? scale.s(10) : scale.s(6);
    final titlePadBottom = compact ? scale.s(10) : scale.s(8);
    final titleLine = compact ? 16.0 : 22.0;
    final bottomGap = compact ? scale.s(6) : scale.s(6);
    return topGap +
        titlePadTop +
        titleLine +
        titlePadBottom +
        _stripHeight(scale, compact: compact) +
        bottomGap;
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    final all = [
      const CategoryModel(
        id: '__all__',
        name: AppStrings.homeCategoryAll,
        iconUrl: '',
      ),
      ...categories,
    ];
    final topGap = compact ? scale.s(12) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (topGap > 0)
          ColoredBox(
            color: AppTheme.background,
            child: SizedBox(height: topGap, width: double.infinity),
          ),
        ColoredBox(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  scale.pagePad,
                  compact ? scale.s(10) : scale.s(6),
                  scale.pagePad,
                  compact ? scale.s(10) : scale.s(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.homeExploreSections,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.sectionTitle.copyWith(
                          fontSize: compact ? 13.5 : 19,
                          fontWeight:
                              compact ? FontWeight.w600 : FontWeight.w700,
                          height: 1.1,
                          color: AppTheme.darkText,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onViewAll,
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 4 : 8,
                          vertical: compact ? 0 : 4,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppStrings.viewAll,
                              style: AppTextStyles.viewAll.copyWith(
                                color: AppTheme.primary,
                                fontSize: compact ? 11 : 12.5,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: compact ? 13 : 15,
                              color: AppTheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: _stripHeight(scale, compact: compact),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  cacheExtent: 200,
                  padding: EdgeInsets.symmetric(horizontal: scale.pagePad),
                  itemCount: all.length,
                  separatorBuilder: (_, _) =>
                      SizedBox(width: compact ? scale.s(8) : scale.s(12)),
                  itemBuilder: (_, i) {
                    final cat = all[i];
                    final isAll = cat.id == '__all__';
                    final isSelected = isAll
                        ? selectedId == null
                        : selectedId == cat.id;
                    return _ExploreCategoryTile(
                      name: isAll
                          ? AppStrings.homeCategoryAll
                          : _shortCategoryLabel(cat.name),
                      imageUrl: isAll
                          ? ''
                          : (cat.displayImage.isNotEmpty
                                ? cat.displayImage
                                : cat.iconUrl),
                      isAll: isAll,
                      isSelected: isSelected,
                      compact: compact,
                      onTap: () => onSelect(isAll ? '__all__' : cat.id),
                    );
                  },
                ),
              ),
              SizedBox(height: compact ? scale.s(6) : scale.s(6)),
            ],
          ),
        ),
      ],
    );
  }

  static String _shortCategoryLabel(String name) {
    if (name.contains('منظفات')) return 'منظفات';
    if (name.contains('إلكترونيات')) return 'إلكترونيات';
    if (name.contains('غذائية')) return 'مواد غذائية';
    return name;
  }
}

class _ExploreCategoriesPinnedDelegate extends SliverPersistentHeaderDelegate {
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final List<CategoryModel> categories;
  final VoidCallback? onViewAll;
  final double height;

  _ExploreCategoriesPinnedDelegate({
    required this.selectedId,
    required this.onSelect,
    required this.categories,
    required this.onViewAll,
    required this.height,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: AppTheme.background,
      elevation: 0,
      child: SizedBox(
        height: height,
        child: _ExploreCategoriesStrip(
          selectedId: selectedId,
          onSelect: onSelect,
          categories: categories,
          onViewAll: onViewAll,
          compact: true,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ExploreCategoriesPinnedDelegate old) {
    return selectedId != old.selectedId ||
        height != old.height ||
        onSelect != old.onSelect ||
        onViewAll != old.onViewAll ||
        categories != old.categories;
  }
}

class _ExploreCategoryTile extends StatelessWidget {
  final String name;
  final String imageUrl;
  final bool isAll;
  final bool isSelected;
  final bool compact;
  final VoidCallback onTap;

  const _ExploreCategoryTile({
    required this.name,
    required this.imageUrl,
    required this.isAll,
    required this.isSelected,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    final size = isSelected
        ? _ExploreCategoriesStrip._circleSelected(scale, compact: compact)
        : _ExploreCategoriesStrip._circle(scale, compact: compact);
    final ring = compact ? 1.5 : scale.categoryRing;
    final itemW = _ExploreCategoriesStrip._itemWidth(scale, compact: compact);
    final iconSize = size * (isAll ? 0.42 : 0.38);
    final labelSize = compact ? scale.s(9.5) : scale.s(11);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: itemW,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: size + ring * 2,
              height: size + ring * 2,
              padding: EdgeInsets.all(ring),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primary
                      : const Color(0x22000000),
                  width: isSelected ? 1.6 : 1,
                ),
              ),
              child: ClipOval(
                child: ColoredBox(
                  color: AppTheme.primarySurface,
                  child: isAll
                      ? Icon(
                          Icons.apps_rounded,
                          color: AppTheme.primaryDark,
                          size: iconSize,
                        )
                      : AppNetworkImage(
                          imageUrl,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          width: size,
                          height: size,
                          error: ColoredBox(
                            color: AppTheme.primarySurface,
                            child: Icon(
                              Icons.category_rounded,
                              color: AppTheme.mutedText,
                              size: iconSize,
                            ),
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(height: compact ? scale.s(3) : scale.s(6)),
            Expanded(
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontSize: labelSize,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color:
                          isSelected ? AppTheme.primaryDark : AppTheme.darkText,
                      height: 1.1,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MainScreen — الـ Shell الرئيسي مع Bottom Navigation
// ══════════════════════════════════════════════════════════════════════════════
class MainScreen extends StatefulWidget {
  static const routeName = '/main';
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const Duration _tabAnimDuration = Duration(milliseconds: 280);
  static const Curve _tabAnimCurve = Curves.easeOutCubic;

  late int _currentIndex;
  late final PageController _pageController;
  final Set<int> _visitedTabs = {0};
  bool _aiSheetOpen = false;
  AiControllerCubit? _aiCubit;

  @override
  void initState() {
    super.initState();
    MainShellNavigation.attach(_goToTab);
    _currentIndex = widget.initialIndex.clamp(0, 3);
    _visitedTabs.add(_currentIndex);
    _pageController = PageController(initialPage: _currentIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Deferred secondary loads — after first Home frame.
      unawaited(context.read<AddressCubit>().load());
      unawaited(context.read<OrdersCubit>().load());
      unawaited(context.read<NotificationsCubit>().load(silent: true));
      unawaited(PushService.instance.sync());
      unawaited(
        precacheImage(const AssetImage('assets/images/cart.png'), context),
      );
      final catalog = context.read<CatalogCubit>().state;
      if (!catalog.loading && catalog.productsById.isNotEmpty) {
        context.read<FavoriteCubit>().retainExisting(
          catalog.productsById.keys.toSet(),
        );
      }
      final session = AuthSession.instance;
      if (session.offerLoginOnHome && !session.isLoggedIn) {
        session.offerLoginOnHome = false;
        Navigator.of(context).pushNamed(AppRouter.phoneLogin);
        return;
      }
      if (session.offerCompleteName && session.isLoggedIn) {
        session.offerCompleteName = false;
        Navigator.of(context).pushNamed(AppRouter.completeName);
      }
      if (session.welcomeAfterLogin) {
        session.welcomeAfterLogin = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              AppStrings.guestWelcomeSnack,
              textAlign: TextAlign.center,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    MainShellNavigation.detach();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openCartTab() async {
    await showCartSheet(context);
  }

  void _goToTab(int i) {
    if (i == 2) {
      unawaited(_openCartTab());
      return;
    }
    final idx = i.clamp(0, 3);
    setState(() {
      _currentIndex = idx;
      _visitedTabs.add(idx);
    });
    void animateIfNeeded() {
      if (!_pageController.hasClients) return;
      final cur = _pageController.page?.round() ?? _currentIndex;
      if (cur == idx) return;
      _pageController.animateToPage(
        idx,
        duration: _tabAnimDuration,
        curve: _tabAnimCurve,
      );
    }

    if (_pageController.hasClients) {
      animateIfNeeded();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => animateIfNeeded());
    }
  }

  void _closeAiSheet() {
    if (!_aiSheetOpen) return;
    setState(() => _aiSheetOpen = false);
  }

  Future<void> _toggleAiSheet() async {
    if (_aiSheetOpen) {
      _closeAiSheet();
      return;
    }

    _aiCubit ??= ServiceLocator.instance.createAiController(
      cartCubit: context.read<CartCubit>(),
      catalogCubit: context.read<CatalogCubit>(),
    );
    await _aiCubit!.initConversation();
    if (!mounted) return;

    // زر الناف يفتح اللوحة العائمة المصمّمة (وليس شاشة الملء الكامل).
    setState(() => _aiSheetOpen = true);
  }

  Widget _tabAt(int index) {
    if (!_visitedTabs.contains(index)) {
      return const SizedBox.shrink();
    }
    return switch (index) {
      0 => KeyedSubtree(
        key: const ValueKey<int>(0),
        child: _HomeTab(onOpenCart: _openCartTab),
      ),
      1 => const KeyedSubtree(key: ValueKey<int>(1), child: CategoriesScreen()),
      2 => const KeyedSubtree(key: ValueKey<int>(2), child: CartScreen()),
      _ => const KeyedSubtree(key: ValueKey<int>(3), child: _ProfileTab()),
    };
  }

  @override
  Widget build(BuildContext context) {
    // Lazy tabs: only mount a tab the first time the user opens it.
    final tabs = List<Widget>.generate(4, _tabAt);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocListener<CatalogCubit, CatalogState>(
        listenWhen: (prev, next) =>
            prev.loading && !next.loading && next.productsById.isNotEmpty,
        listener: (context, catalog) {
          context.read<FavoriteCubit>().retainExisting(
            catalog.productsById.keys.toSet(),
          );
        },
        child: MainShellScope(
          openCheckout: _openCartTab,
          selectTab: _goToTab,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
            child: Scaffold(
              extendBody: true,
              resizeToAvoidBottomInset: false,
              backgroundColor: AppTheme.background,
              body: Stack(
                fit: StackFit.expand,
                children: [
                  PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: tabs,
                  ),
                  if (_aiCubit != null)
                    AiMorphFloatingPanel(
                      isOpen: _aiSheetOpen,
                      cubit: _aiCubit!,
                      // طرف القوس أعمق داخل زر المساعد.
                      bottomOffset:
                          MediaQuery.paddingOf(context).bottom + 46,
                      onDismiss: _closeAiSheet,
                    ),
                ],
              ),
              bottomNavigationBar: MainBottomNavBar(
                currentTabIndex: _currentIndex,
                cartScreenActive: false,
                wrapAiCenterHero: false,
                isAiActive: _aiSheetOpen,
                onTabTap: _goToTab,
                onAiAssistantTap: _toggleAiSheet,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Home Tab
// ══════════════════════════════════════════════════════════════════════════════
class _HomeTab extends StatefulWidget {
  final VoidCallback onOpenCart;
  const _HomeTab({required this.onOpenCart});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  String? _selectedCategory;
  bool _didPrecache = false;
  String _precacheSig = '';
  bool _showScrollToTop = false;
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _precacheVisible());
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    final atEnd = position.maxScrollExtent > 64 &&
        position.pixels >= position.maxScrollExtent - 40;
    if (atEnd != _showScrollToTop) {
      setState(() => _showScrollToTop = atEnd);
    }
  }

  Future<void> _scrollToTop() async {
    if (!_scroll.hasClients) return;
    await _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _precacheVisible() {
    if (!mounted) return;
    final catalog = context.read<CatalogCubit>().state;
    if (catalog.products.isEmpty && catalog.banners.isEmpty) return;
    final sig = catalog.banners.map((b) => b.imageUrl).join('|');
    if (_didPrecache && sig == _precacheSig) return;
    _didPrecache = true;
    _precacheSig = sig;
    final urls = <String>{};
    for (final b in catalog.banners) {
      if (b.imageUrl.trim().isNotEmpty) urls.add(b.imageUrl);
    }
    for (final p in catalog.offers.take(4)) {
      if (p.imageUrl.trim().isNotEmpty) urls.add(p.imageUrl);
    }
    for (final p in catalog.discounts.take(4)) {
      if (p.imageUrl.trim().isNotEmpty) urls.add(p.imageUrl);
    }
    for (final p in catalog.products.take(8)) {
      if (p.imageUrl.trim().isNotEmpty) urls.add(p.imageUrl);
    }
    for (final url in urls) {
      final resolved = AppNetworkImage.resolveUrl(url);
      final provider = CachedNetworkImageProvider(
        resolved,
        headers: AppNetworkImage.headersFor(resolved),
      );
      unawaited(
        precacheImage(
          provider,
          context,
          onError: (_, _) {
            // Local/storage 403 or missing file — card handles fallback.
          },
        ),
      );
    }
  }

  List<ProductModel> _filteredProducts(CatalogState catalog) {
    var list = catalog.products;
    if (_selectedCategory != null) {
      final ids = catalog.categoryTreeIds(_selectedCategory!);
      return list.where((p) => ids.contains(p.categoryId)).toList();
    }
    return list;
  }

  void _openHomeSectionBrowse(HomeSectionModel section) {
    Navigator.of(context).pushNamed(
      AppRouter.homeSectionBrowse,
      arguments: HomeSectionBrowseArgs(
        sectionKey: section.key,
        initial: section,
      ),
    );
  }

  void _openSearch() {
    Navigator.of(context).pushNamed(AppRouter.search);
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final scale = AppScale.of(context);

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.25,
      child: BlocBuilder<CatalogCubit, CatalogState>(
        buildWhen: (prev, next) =>
            prev.loading != next.loading ||
            prev.refreshing != next.refreshing ||
            prev.offline != next.offline ||
            prev.error != next.error ||
            prev.feed != next.feed,
        builder: (context, catalog) {
          if (catalog.products.isNotEmpty || catalog.banners.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _precacheVisible(),
            );
          }
          final filtered = _filteredProducts(catalog);
          final browsingHome = _selectedCategory == null;
          final isInitialLoad = catalog.loading && catalog.products.isEmpty;
          final isRefreshing = catalog.refreshing;
          final showFullHomeLoading = isInitialLoad;
          final showRefreshShimmer = isRefreshing && browsingHome;
          final slides = _promoSlidesFor(catalog);
          final noBannerHome = !showFullHomeLoading && slides.isEmpty;

          return Stack(
            children: [
              TopPullRefreshDetector(
                scrollController: _scroll,
                onRefresh: () async {
                  await Future.wait([
                    context.read<CatalogCubit>().load(refresh: true),
                    context.read<NotificationsCubit>().load(silent: true),
                  ]);
                },
                child: CardStepperScrollScope(
                  child: CustomScrollView(
                  controller: _scroll,
                  cacheExtent: 480,
                  physics: noGapScrollPhysics,
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _HomeMagicHeaderDelegate(
                        topPad: topPad,
                        bannerH: scale.bannerHeight,
                        searchH: scale.searchH,
                        logoRow: scale.logoRow,
                        bannerBlend: scale.bannerBlend,
                        bannerFadeHeight: scale.s(28),
                        onSearchTap: _openSearch,
                        slides: slides,
                        loading: isInitialLoad,
                      ),
                    ),
                    if (catalog.error != null && catalog.products.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyState(
                          query: catalog.error!,
                          onClear: () => context.read<CatalogCubit>().load(),
                        ),
                      )
                    else ...[
                      if (noBannerHome)
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _ExploreCategoriesPinnedDelegate(
                            selectedId: _selectedCategory,
                            categories: catalog.categories,
                            height: _ExploreCategoriesStrip.extentHeight(
                              scale,
                              compact: true,
                            ),
                            onViewAll: () =>
                                MainShellScope.read(context).selectTab(1),
                            onSelect: (id) => setState(() {
                              if (id == '__all__') {
                                _selectedCategory = null;
                              } else {
                                _selectedCategory =
                                    _selectedCategory == id ? null : id;
                              }
                            }),
                          ),
                        ),
                      DecoratedSliver(
                        decoration: const BoxDecoration(color: Colors.white),
                        sliver: SliverMainAxisGroup(
                          slivers: [
                            if (catalog.offline)
                              const SliverToBoxAdapter(child: _OfflineBanner()),
                            if (showFullHomeLoading)
                              const SliverToBoxAdapter(
                                child: _CategoriesShimmer(),
                              )
                            else if (!noBannerHome)
                              SliverToBoxAdapter(
                                child: _ExploreCategoriesStrip(
                                  selectedId: _selectedCategory,
                                  categories: catalog.categories,
                                  compact: true,
                                  onViewAll: () =>
                                      MainShellScope.read(context).selectTab(1),
                                  onSelect: (id) => setState(() {
                                    if (id == '__all__') {
                                      _selectedCategory = null;
                                    } else {
                                      _selectedCategory =
                                          _selectedCategory == id ? null : id;
                                    }
                                  }),
                                ),
                              ),
                            if (!showFullHomeLoading &&
                                !showRefreshShimmer &&
                                browsingHome &&
                                catalog.store.showDiscountsAsBanner &&
                                catalog.discounts.isNotEmpty)
                              SliverToBoxAdapter(
                                child: _CurvedProductCarouselSection(
                                  title: 'خصومات اليوم',
                                  subtitle: 'أسعار مخفّضة على منتجات مختارة',
                                  products: catalog.discounts,
                                  gradientColors: const [
                                    Color(0xFFFFF1F1),
                                    Color(0xFFFFE3E3),
                                  ],
                                  titleColor: const Color(0xFFC62828),
                                  subtitleColor: const Color(0xFFB71C1C),
                                  curveTop: false,
                                  curveBottom: true,
                                ),
                              ),
                            if (!showFullHomeLoading &&
                                !showRefreshShimmer &&
                                browsingHome &&
                                catalog.store.showOffersAsBanner &&
                                catalog.offers.isNotEmpty)
                              SliverToBoxAdapter(
                                child: _CurvedProductCarouselSection(
                                  title: 'عروض خاصة',
                                  subtitle: 'عروض ترويجية لفترة محدودة',
                                  products: catalog.offers,
                                  gradientColors: const [
                                    Color(0xFFFFF6ED),
                                    Color(0xFFFFE8CC),
                                  ],
                                  titleColor: const Color(0xFFE65100),
                                  subtitleColor: const Color(0xFFBF360C),
                                  curveTop: false,
                                  curveBottom: true,
                                ),
                              ),
                            if (!showFullHomeLoading &&
                                !showRefreshShimmer &&
                                browsingHome)
                              ...catalog.sections.map((section) {
                                final titleColor = homeSectionTextColor(
                                  section.titleColor,
                                  AppTheme.primaryDark,
                                );
                                final subtitleColor = homeSectionTextColor(
                                  section.subtitleColor,
                                  AppTheme.mutedText,
                                );
                                final autoScroll = section.autoScrollCards;

                                if (section.showsBundles) {
                                  return SliverToBoxAdapter(
                                    child: BundleBannerSection(
                                      title: section.title,
                                      subtitle: section.subtitle,
                                      bundles: section.bundles,
                                      gradientColors: section.gradientColors,
                                      backgroundImageUrl:
                                          section.backgroundImageUrl,
                                      titleColor: titleColor,
                                      subtitleColor: subtitleColor,
                                      autoScrollCards: section.autoScrollCards,
                                      titleFontSize: section.titleFontSize,
                                      subtitleFontSize:
                                          section.subtitleFontSize,
                                      cardWidth: section.cardWidth,
                                      rowHeight: section.rowHeight,
                                      itemSpacing: section.itemSpacing,
                                      paddingTop: section.paddingTop,
                                      paddingBottom: section.paddingBottom,
                                      curveTop:
                                          catalog.sections.first == section,
                                    ),
                                  );
                                }
                                return SliverToBoxAdapter(
                                  child: _CurvedProductCarouselSection(
                                    title: section.title,
                                    subtitle: section.subtitle,
                                    subtitleStyle: section.emphasizeSubtitle
                                        ? TextStyle(
                                            fontSize: section.subtitleFontSize,
                                            fontWeight: FontWeight.w800,
                                            color: subtitleColor ??
                                                AppTheme.primary,
                                            height: 1.25,
                                          )
                                        : null,
                                    titleLeading: section.showTitleIcon
                                        ? const _SectionFireIcon()
                                        : null,
                                    ticker: autoScroll,
                                    products: section.products,
                                    gradientColors: section.gradientColors,
                                    backgroundImageUrl:
                                        section.backgroundImageUrl,
                                    titleColor: titleColor,
                                    subtitleColor: subtitleColor,
                                    titleFontSize: section.titleFontSize,
                                    subtitleFontSize: section.subtitleFontSize,
                                    cardWidth: section.cardWidth,
                                    rowHeight: section.rowHeight,
                                    itemSpacing: section.itemSpacing,
                                    paddingTop: section.paddingTop,
                                    paddingBottom: section.paddingBottom,
                                    curveTop: catalog.sections.first == section,
                                    curveBottom: true,
                                    onViewAll: () =>
                                        _openHomeSectionBrowse(section),
                                  ),
                                );
                              }),
                            if (!showFullHomeLoading &&
                                !showRefreshShimmer &&
                                browsingHome &&
                                filtered.isNotEmpty)
                              const SliverToBoxAdapter(
                                child: _HomeRestProductsDivider(),
                              ),
                            if (showFullHomeLoading || showRefreshShimmer)
                              const SliverPadding(
                                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                                sliver: ProductShimmerSliverGrid(),
                              )
                            else if (filtered.isEmpty && !browsingHome)
                              SliverToBoxAdapter(
                                child: _EmptyState(
                                  query: '',
                                  onClear: () => setState(() {
                                    _selectedCategory = null;
                                  }),
                                ),
                              )
                            else if (filtered.isNotEmpty)
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                                sliver: SliverGrid(
                                  delegate: SliverChildBuilderDelegate(
                                    (ctx, i) => ProductCard(
                                      product: filtered[i],
                                      heroTag:
                                          'home_grid_${i}_${filtered[i].id}',
                                      compactFooter: true,
                                      tightFooterTop: true,
                                      footerTextScale: 1.08,
                                      imageInset: 4,
                                      imageInsetTop: 4,
                                      imageInsetBottom: 4,
                                      imageAlignment: Alignment.center,
                                      imageScale: 1.28,
                                      cartButtonSize: 30,
                                      cartButtonStartInset: 12,
                                      cartButtonBottomInset: 20,
                                    ),
                                    childCount: filtered.length,
                                  ),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        AppScale.homeGridCrossAxisCount,
                                    mainAxisSpacing: scale.homeGridMainAxisSpacing,
                                    crossAxisSpacing: scale.s(10),
                                    childAspectRatio:
                                        AppScale.homeGridCardAspect,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _HomeScrollToTopButton(
                    visible: _showScrollToTop,
                    onTap: _scrollToTop,
                  ),
                ),
              ),
              TopScreenRefreshIndicator(
                visible: isRefreshing && browsingHome,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Promotion Banner — صورة خلفية كاملة + تدرج الهوية
// ══════════════════════════════════════════════════════════════════════════════
class _HomePromoSlider extends StatefulWidget {
  final List<_PromoSlide> slides;
  final double contentOpacity;
  final bool showDots;

  const _HomePromoSlider({
    super.key,
    required this.slides,
    required this.contentOpacity,
    required this.showDots,
  });

  @override
  State<_HomePromoSlider> createState() => _HomePromoSliderState();
}

class _HomePromoSliderState extends State<_HomePromoSlider> {
  /// مضاعف كبير لإبقاء PageView في حلقة سلسة يميناً ويساراً.
  static const int _loopCopies = 1000;

  PageController? _controller;
  int _current = 0;
  Timer? _timer;

  int get _count => widget.slides.length;

  int get _middlePage =>
      _count < 2 ? 0 : (_count * (_loopCopies ~/ 2));

  int _realIndex(int page) => _count == 0 ? 0 : page % _count;

  @override
  void initState() {
    super.initState();
    _setupController();
    _startAutoScroll();
  }

  @override
  void didUpdateWidget(covariant _HomePromoSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slides.length != widget.slides.length) {
      _timer?.cancel();
      _controller?.dispose();
      _current = 0;
      _setupController();
      _startAutoScroll();
    }
  }

  void _setupController() {
    final initial = _middlePage;
    _controller = PageController(initialPage: initial);
    _current = _realIndex(initial);
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || _count < 2) return;
      final controller = _controller;
      if (controller == null || !controller.hasClients) return;
      final currentPage = controller.page?.round() ?? _middlePage;
      controller.animateToPage(
        currentPage + 1,
        duration: const Duration(milliseconds: 620),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = widget.slides;
    if (slides.isEmpty) return const SizedBox.shrink();

    final loop = slides.length > 1;
    final controller = _controller;
    if (controller == null) return const SizedBox.shrink();

    return Stack(
      fit: StackFit.expand,
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            // أثناء السحب اليدوي نوقف المؤقت ثم نعيد تشغيله بعده.
            if (notification is ScrollStartNotification &&
                notification.dragDetails != null) {
              _timer?.cancel();
            } else if (notification is ScrollEndNotification) {
              _startAutoScroll();
            }
            return false;
          },
          child: PageView.builder(
            controller: controller,
            allowImplicitScrolling: true,
            itemCount: loop ? slides.length * _loopCopies : slides.length,
            onPageChanged: (i) => setState(() => _current = _realIndex(i)),
            itemBuilder: (_, i) =>
                _PromoBannerCard(slide: slides[_realIndex(i)]),
          ),
        ),
        if (widget.contentOpacity > 0.02)
          Positioned(
            left: 16,
            right: 16,
            bottom: widget.showDots ? 28 : 16,
            child: IgnorePointer(
              child: Opacity(
                opacity: widget.contentOpacity,
                child: _PromoSlideCaption(
                  slide: slides[_current.clamp(0, slides.length - 1)],
                ),
              ),
            ),
          ),
        if (widget.showDots && slides.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Opacity(
              opacity: widget.contentOpacity.clamp(0.0, 1.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(slides.length, (i) {
                  final active = _current == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ),
      ],
    );
  }
}

class _PromoBannerCard extends StatelessWidget {
  final _PromoSlide slide;

  const _PromoBannerCard({required this.slide});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: slide.pageId != null || slide.product != null
          ? () => _openPromoSlide(context, slide)
          : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: AppTheme.primary.withValues(alpha: 0.18),
            child: slide.imageUrl.trim().isEmpty
                ? const SizedBox.expand()
                : AppNetworkImage(
                    slide.imageUrl,
                    fit: BoxFit.cover,
                    width: 720,
                    placeholder: const ColoredBox(color: Color(0xFFD8F2E4)),
                    error: const ColoredBox(color: Color(0xFFD8F2E4)),
                  ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x59003399),
                  Color(0x24003399),
                  Color(0x00003399),
                ],
                stops: [0.0, 0.16, 0.4],
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color(0x660A1F4D),
                  Color(0x29000000),
                  Color(0x00000000),
                ],
                stops: [0.0, 0.3, 0.58],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoSlideCaption extends StatelessWidget {
  final _PromoSlide slide;

  const _PromoSlideCaption({required this.slide});

  @override
  Widget build(BuildContext context) {
    final product = slide.product;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (product?.hasDiscount == true)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PromoBadge(product: product!, fontSize: 10),
          ),
        if (slide.title.isNotEmpty)
          Text(
            slide.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: AppScale.of(context).s(16),
              height: 1.25,
              shadows: const [Shadow(color: Color(0x66000000), blurRadius: 8)],
            ),
          ),
        if (product != null) ...[
          const SizedBox(height: 6),
          PriceLine(
            price: product.effectivePrice,
            originalPrice: product.hasDiscount ? product.price : null,
            color: Colors.white,
            priceSize: 15,
            currencySize: 17,
            alignment: AlignmentDirectional.centerStart,
          ),
        ],
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Profile Tab
// ══════════════════════════════════════════════════════════════════════════════
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) => const ProfileScreen();
}

// ══════════════════════════════════════════════════════════════════════════════
// Shimmer Skeletons
// ══════════════════════════════════════════════════════════════════════════════
class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFDCF5EA),
      highlightColor: const Color(0xFFF0FFF6),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class _PromoShimmer extends StatelessWidget {
  final bool fill;

  const _PromoShimmer({this.fill = false});

  @override
  Widget build(BuildContext context) {
    final box = Shimmer.fromColors(
      baseColor: const Color(0xFFDCF5EA),
      highlightColor: const Color(0xFFF0FFF6),
      child: const ColoredBox(color: Colors.white),
    );
    if (fill) return SizedBox.expand(child: box);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: SizedBox(height: 190, width: double.infinity, child: box),
      ),
    );
  }
}

class _CategoriesShimmer extends StatelessWidget {
  const _CategoriesShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _ShimmerBox(width: 80, height: 16, radius: 8),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 108,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: 5,
            itemBuilder: (_, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Shimmer.fromColors(
                    baseColor: const Color(0xFFDCF5EA),
                    highlightColor: const Color(0xFFF0FFF6),
                    child: Container(
                      width: 66,
                      height: 66,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const _ShimmerBox(width: 50, height: 10, radius: 4),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _ProductGridShimmer extends StatelessWidget {
  const _ProductGridShimmer();

  @override
  Widget build(BuildContext context) => const ProductShimmerSliverGrid();
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          'تعمل بدون اتصال — تُعرض البيانات المحفوظة على الجهاز',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF8D6E00),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Empty State
// ══════════════════════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  final String query;
  final VoidCallback onClear;

  const _EmptyState({required this.query, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 72,
            color: AppTheme.mutedText.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 16),
          Text(
            query.isNotEmpty
                ? 'لا نتائج لـ "$query"'
                : 'لا توجد منتجات في هذا القسم',
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.mutedText,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              AppStrings.viewAll,
              style: AppTextStyles.viewAll.copyWith(
                color: AppTheme.primaryDark,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryDark,
              side: const BorderSide(color: AppTheme.primaryDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
