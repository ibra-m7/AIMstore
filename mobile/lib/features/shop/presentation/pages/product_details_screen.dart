import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_count_badge.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/product_thumbnail.dart';
import '../../data/models/product_model.dart';
import '../../data/services/catalog_api.dart';
import '../manager/cart_cubit.dart';
import '../manager/catalog_cubit.dart';
import '../manager/favorite_cubit.dart';
import '../widgets/card_cart_control.dart';
import '../widgets/celebrate_anchors.dart';
import '../widgets/price_line.dart';
import '../widgets/product_fly_overlay.dart';
import '../widgets/quantity_label_chip.dart';
import '../widgets/product_gift_overlay.dart';
import '../widgets/stock_limit_snackbar.dart';

// ── ثوابت ─────────────────────────────────────────────────────────────────────
const _kGreen      = Color(0xFF2E7D32);
const _kGreenLight = Color(0xFF4CAF50);
const _kGreenBg    = Color(0xFFF1F8F1);
const _kText       = Color(0xFF1A2E1A);
const _kSubtext    = Color(0xFF6B7B6B);
const _kSurface    = Color(0xFFFFFFFF);

/// وسيط فتح تفاصيل المنتج مع وسم Hero فريد حتى لا يتكرر نفس المنتج في الرئيسية.
class ProductDetailsArgs {
  final ProductModel product;
  final String? heroTag;

  const ProductDetailsArgs({required this.product, this.heroTag});
}

class ProductDetailsScreen extends StatefulWidget {
  static const routeName = '/product-details';

  final ProductModel product;
  final String heroTag;

  ProductDetailsScreen({
    super.key,
    required this.product,
    String? heroTag,
  }) : heroTag = heroTag ?? 'product_details_${product.id}';

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _cartCtrl;
  late final Animation<double> _cartScale;
  late final AnimationController _topCartBounceCtrl;
  late final Animation<double> _topCartBounceScale;
  late final AnimationController _topCartReleaseCtrl;
  late final Animation<double> _topCartReleaseScale;
  final GlobalKey _pageKey = GlobalKey();
  final GlobalKey _topCartKey = GlobalKey();
  final Object _productImageAnchor = Object();
  List<ProductModel> _boughtTogether = const [];
  List<ProductModel> _similar = const [];
  List<ProductModel> _suggested = const [];
  bool _recsLoaded = false;

  ProductModel get p => widget.product;

  @override
  void initState() {
    super.initState();
    _cartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
    );
    _cartScale = _cartCtrl;
    _topCartBounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _topCartBounceScale = Tween<double>(begin: 1, end: 1.26).animate(
      CurvedAnimation(parent: _topCartBounceCtrl, curve: Curves.elasticOut),
    );
    _topCartReleaseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _topCartReleaseScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.92),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.92, end: 1),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(parent: _topCartReleaseCtrl, curve: Curves.easeInOut),
    );
    CartNavAnchor.detailsBounce.addListener(_onTopCartPing);
    CartNavAnchor.detailsRelease.addListener(_onTopCartRelease);
    CartNavAnchor.detailsBoundsKey = _pageKey;
    WidgetsBinding.instance.addPostFrameCallback((_) => _bindTopCart());
    _loadRecommendations();
  }

  void _onTopCartPing() {
    if (!mounted) return;
    _topCartBounceCtrl.forward(from: 0);
  }

  void _onTopCartRelease() {
    if (!mounted) return;
    _topCartReleaseCtrl.forward(from: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.isCurrent == true) {
      CartNavAnchor.detailsBoundsKey = _pageKey;
      WidgetsBinding.instance.addPostFrameCallback((_) => _bindTopCart());
    }
  }

  Future<void> _loadRecommendations() async {
    final id = p.id;
    try {
      final recs = await CatalogApi.instance.productRecommendations(id);
      if (!mounted) return;
      setState(() {
        _boughtTogether = recs.boughtTogether;
        _similar = recs.similar;
        _suggested = recs.suggested;
        _recsLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _recsLoaded = true);
    }
  }

  void _bindTopCart() {
    if (!mounted) return;
    CelebratePositions.bind(
      CartNavAnchor.detailsCartAnchor,
      () => celebrateGlobalCenter(_topCartKey),
    );
  }

  @override
  void dispose() {
    CartNavAnchor.detailsBounce.removeListener(_onTopCartPing);
    CartNavAnchor.detailsRelease.removeListener(_onTopCartRelease);
    if (CartNavAnchor.detailsBoundsKey == _pageKey) {
      CartNavAnchor.detailsBoundsKey = null;
    }
    CelebratePositions.unbind(CartNavAnchor.detailsCartAnchor);
    _topCartReleaseCtrl.dispose();
    _topCartBounceCtrl.dispose();
    _cartCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogCubit>().state;
    final similar = _resolveSimilarProducts(
      product: p,
      fromApi: _similar,
      recsLoaded: _recsLoaded,
      catalog: catalog,
    );
    final suggested = _resolveSuggestedProducts(
      product: p,
      fromApi: _suggested,
      recsLoaded: _recsLoaded,
      catalog: catalog,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: _kGreenBg,
          body: Stack(
            key: _pageKey,
            children: [
              // ── المحتوى القابل للتمرير ───────────────────────────────────
              CustomScrollView(
                slivers: [
                  _ProductHeroHeader(
                    product: p,
                    heroTag: widget.heroTag,
                    productImageAnchor: _productImageAnchor,
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── بيانات المنتج الأساسية ─────────────────────────
                        _ProductInfoSection(product: p),

                        const SizedBox(height: 12),

                        // ── نصيحة المساعد الذكي ────────────────────────────
                        if (p.benefits.isNotEmpty)
                          _AiTipsSection(benefits: p.benefits),

                        const SizedBox(height: 12),

                        // ── الوصف الكامل ───────────────────────────────────
                        _DescriptionSection(description: p.description),

                        if (p.hasGiftProduct) ...[
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ProductGiftDetailCard(gift: p.giftProduct!),
                          ),
                        ],

                        const SizedBox(height: 12),

                        // ── طريقة الاستخدام ────────────────────────────────
                        if (p.usageInstructions.isNotEmpty)
                          _UsageSection(instructions: p.usageInstructions),

                        // ── مساحة للزر الثابت في الأسفل ───────────────────
                        if (_boughtTogether.isNotEmpty)
                          _DetailsRecsRow(
                            title: 'يُشترى معه',
                            products: _boughtTogether,
                            highlighted: true,
                          ),
                        if (similar.isNotEmpty)
                          _DetailsRecsRow(
                            title: 'منتجات مشابهة',
                            products: similar,
                          ),
                        if (suggested.isNotEmpty)
                          _DetailsRecsRow(
                            title: 'منتجات مقترحة',
                            products: suggested,
                          ),
                        const SizedBox(height: 110),
                      ],
                    ),
                  ),
                ],
              ),

              // ── سلة ثابتة أعلى يسار الصفحة ───────────────────────────────
              Positioned(
                top: MediaQuery.paddingOf(context).top + 6,
                left: 10,
                child: ScaleTransition(
                  scale: _topCartReleaseScale,
                  child: ScaleTransition(
                    scale: _topCartBounceScale,
                    child: BlocBuilder<CartCubit, CartState>(
                      buildWhen: (p, c) => p.count != c.count,
                      builder: (context, cart) => AppCountBadge.wrap(
                        count: cart.count,
                        offset: const Offset(4, -4),
                        child: _GlassButton(
                          measureKey: _topCartKey,
                          icon: Icons.shopping_bag_outlined,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── زر "أضف للسلة" الثابت ───────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _AddToCartBar(
                  product: p,
                  scaleAnim: _cartScale,
                  productImageAnchor: _productImageAnchor,
                  pageKey: _pageKey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Hero Image Header
// ══════════════════════════════════════════════════════════════════════════════
class _ProductHeroHeader extends StatelessWidget {
  final ProductModel product;
  final String heroTag;
  final Object productImageAnchor;

  const _ProductHeroHeader({
    required this.product,
    required this.heroTag,
    required this.productImageAnchor,
  });

  @override
  Widget build(BuildContext context) {
    final heroTag = this.heroTag;
    return SliverAppBar(
      expandedHeight: 248,
      pinned: true,
      elevation: 0,
      backgroundColor: _kGreen,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: _GlassButton(
          icon: Icons.arrow_forward_ios_rounded,
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: _GlassButton(
            icon: Icons.share_outlined,
            onTap: () {},
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            CelebrateAnchor(
              anchor: productImageAnchor,
              child: Hero(
                tag: heroTag,
                child: AppNetworkImage(
                  product.displayImage,
                  fit: BoxFit.cover,
                  placeholder: Shimmer.fromColors(
                    baseColor: const Color(0xFFE0E0E0),
                    highlightColor: const Color(0xFFF5F5F5),
                    child: Container(color: Colors.white),
                  ),
                  error: Container(
                    color: _kGreenBg,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      size: 64,
                      color: _kSubtext,
                    ),
                  ),
                ),
              ),
            ),
            // تدرج في الأسفل لتمرير النص فوقه
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      _kGreenBg,
                      _kGreenBg.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            // شارة الخصم
            if (product.hasDiscount)
              Positioned(
                top: 80,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    'خصم ${product.discountPercentage.toInt()}٪',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
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

// ══════════════════════════════════════════════════════════════════════════════
// قسم المعلومات الأساسية
// ══════════════════════════════════════════════════════════════════════════════
class _ProductInfoSection extends StatelessWidget {
  final ProductModel product;
  const _ProductInfoSection({required this.product});

  @override
  Widget build(BuildContext context) {
    final p = product;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // اسم المنتج (سطر واحد) + القلب على اليسار
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w500,
                    color: _kText,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              BlocBuilder<FavoriteCubit, FavoriteState>(
                buildWhen: (prev, curr) =>
                    prev.contains(p.id) != curr.contains(p.id),
                builder: (context, fav) {
                  final on = fav.contains(p.id);
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.read<FavoriteCubit>().toggle(p.id);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          on
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 24,
                          color: on ? Colors.redAccent : _kSubtext,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          if (p.quantityLabel.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            QuantityLabelChip(product: p),
          ],

          const SizedBox(height: 12),

          // التقييم والمراجعات والمخزون
          Row(
            children: [
              _StarRating(rating: p.rating),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${p.rating}  (${p.reviewCount} تقييم)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: _kText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: p.isAvailable
                          ? _kGreen.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      p.isAvailable
                          ? 'متوفر · ${p.stock} قطعة'
                          : AppStrings.productOutOfStock,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: p.isAvailable ? _kGreen : Colors.redAccent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // السعر
          if (p.hasPackPieces) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8A3D),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                p.packDisplayLabel,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            p.effectivePrice.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 33.5,
                              fontWeight: FontWeight.w900,
                              color: _kGreen,
                              height: 1.0,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsetsDirectional.only(bottom: 2, start: 6),
                            child: Text(
                              '\u{20C1}',
                              style: TextStyle(
                                fontFamily: 'SaudiRiyal',
                                fontSize: 31.5,
                                fontWeight: FontWeight.w400,
                                color: _kGreen,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (p.hasDiscount) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${p.price.toStringAsFixed(2)} \u{20C1}',
                          style: TextStyle(
                            fontSize: 15.5,
                            color: _kSubtext.withValues(alpha: 0.7),
                            decoration: TextDecoration.lineThrough,
                            decorationColor: _kSubtext,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // التوفير في الخصم
              if (p.hasDiscount)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _kGreen.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'توفيرك',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: _kGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${(p.price - p.effectivePrice).toStringAsFixed(2)} \u{20C1}',
                        style: const TextStyle(
                          fontSize: 15.5,
                          color: _kGreen,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// نصيحة المساعد الذكي — القسم المميز
// ══════════════════════════════════════════════════════════════════════════════
class _AiTipsSection extends StatefulWidget {
  final List<String> benefits;
  const _AiTipsSection({required this.benefits});

  @override
  State<_AiTipsSection> createState() => _AiTipsSectionState();
}

class _AiTipsSectionState extends State<_AiTipsSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerCtrl;
  bool _expanded = true;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF0D47A1),
            Color(0xFF1565C0),
            Color(0xFF1976D2),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── الهيدر ───────────────────────────────────────────────────
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      // أيقونة المساعد المتحركة
                      AnimatedBuilder(
                        animation: _shimmerCtrl,
                        builder: (_, _) {
                          final glow = (0.5 + 0.5 * _shimmerCtrl.value);
                          return Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  Colors.white.withValues(alpha: 0.15 * glow),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white
                                      .withValues(alpha: 0.2 * glow),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              AppStrings.productAiTips,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'روعة توصي بهذا المنتج لهذه الأسباب',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),

              // ── قائمة الفوائد ─────────────────────────────────────────────
              AnimatedCrossFade(
                firstChild: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      Divider(
                        color: Colors.white.withValues(alpha: 0.15),
                        height: 1,
                      ),
                      const SizedBox(height: 12),
                      ...widget.benefits.asMap().entries.map(
                            (e) => _BenefitRow(
                              index: e.key + 1,
                              text: e.value,
                            ),
                          ),
                    ],
                  ),
                ),
                secondChild: const SizedBox.shrink(),
                crossFadeState: _expanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final int index;
  final String text;

  const _BenefitRow({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsetsDirectional.only(end: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// قسم الوصف الكامل
// ══════════════════════════════════════════════════════════════════════════════
class _DescriptionSection extends StatefulWidget {
  final String description;
  const _DescriptionSection({required this.description});

  @override
  State<_DescriptionSection> createState() => _DescriptionSectionState();
}

class _DescriptionSectionState extends State<_DescriptionSection> {
  bool _expanded = false;
  static const _maxLines = 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.description_outlined,
            title: AppStrings.productDescription,
            color: _kGreen,
          ),
          const SizedBox(height: 12),
          AnimatedCrossFade(
            firstChild: Text(
              widget.description,
              style: const TextStyle(
                fontSize: 15.5,
                color: _kSubtext,
                height: 1.7,
              ),
            ),
            secondChild: Text(
              widget.description,
              maxLines: _maxLines,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15.5,
                color: _kSubtext,
                height: 1.7,
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? '${AppStrings.productReadLess} ▲' : '${AppStrings.productReadMore} ▼',
              style: const TextStyle(
                color: _kGreen,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// قسم طريقة الاستخدام
// ══════════════════════════════════════════════════════════════════════════════
class _UsageSection extends StatelessWidget {
  final String instructions;
  const _UsageSection({required this.instructions});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.info_outline_rounded,
            title: AppStrings.productUsage,
            color: Color(0xFFE64A19),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE64A19).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE64A19).withValues(alpha: 0.15),
              ),
            ),
            child: Text(
              instructions,
              style: const TextStyle(
                fontSize: 15,
                color: _kText,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// شريط "أضف للسلة" الثابت في الأسفل
// ══════════════════════════════════════════════════════════════════════════════
class _AddToCartBar extends StatefulWidget {
  final ProductModel product;
  final Animation<double> scaleAnim;
  final Object productImageAnchor;
  final GlobalKey pageKey;

  const _AddToCartBar({
    required this.product,
    required this.scaleAnim,
    required this.productImageAnchor,
    required this.pageKey,
  });

  @override
  State<_AddToCartBar> createState() => _AddToCartBarState();
}

class _AddToCartBarState extends State<_AddToCartBar> {
  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final scaleAnim = widget.scaleAnim;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            16,
            10,
            16,
            10 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: _kSurface.withValues(alpha: 0.95),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: BlocBuilder<CartCubit, CartState>(
            builder: (context, cart) {
              final qty = cart.items
                  .where((item) => item.product.id == product.id)
                  .fold<int>(0, (sum, item) => sum + item.quantity);
              final available = product.isAvailable;
              final canPlus = available && qty < product.stock;
              final total = product.effectivePrice * (qty > 0 ? qty : 1);

              void addOne() {
                if (!canPlus) {
                  showProductUnavailableSnackBar(context);
                  return;
                }
                HapticFeedback.mediumImpact();
                context.read<CartCubit>().addToCart(product);
                final cartTop = resolveFlyEnd(
                  context,
                  preferTopCart: true,
                  boundsKey: widget.pageKey,
                );
                var imageStart = CelebratePositions.read(
                  widget.productImageAnchor,
                );
                if (imageStart == null ||
                    !isPointInsideBounds(imageStart, widget.pageKey,
                        margin: 20)) {
                  final box = widget.pageKey.currentContext?.findRenderObject();
                  if (box is RenderBox && box.hasSize) {
                    final topLeft = box.localToGlobal(Offset.zero);
                    imageStart = Offset(
                      topLeft.dx + box.size.width / 2,
                      topLeft.dy + box.size.height - 72,
                    );
                  }
                }
                ProductFlyController.play(
                  context: context,
                  imageUrl: product.displayImage,
                  productAnchor: widget.productImageAnchor,
                  fallbackStart: imageStart,
                  overrideEnd: cartTop,
                  pingDetailsCart: true,
                );
              }

              void removeOne() {
                if (qty <= 0) return;
                context.read<CartCubit>().updateQuantity(product.id, qty - 1);
                final fallbackEnd = fallbackProductFlyEnd(
                  context,
                  boundsKey: widget.pageKey,
                );
                ProductFlyController.playReverse(
                  context: context,
                  imageUrl: product.displayImage,
                  productAnchor: widget.productImageAnchor,
                  fallbackEnd: fallbackEnd,
                  flyFromTopCart: true,
                  boundsKey: widget.pageKey,
                  releaseDetailsCart: true,
                );
              }

              return ScaleTransition(
                scale: scaleAnim,
                child: Row(
                  children: [
                    SizedBox(
                      width: qty == 0 ? 148 : 128,
                      height: 42,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: available ? _kGreen : const Color(0xFFC5D4CB),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: !available
                            ? const Center(
                                child: Text(
                                  AppStrings.productOutOfStock,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5,
                                  ),
                                ),
                              )
                            : qty == 0
                                ? InkWell(
                                    onTap: addOne,
                                    borderRadius: BorderRadius.circular(14),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          AppStrings.productAddToCart,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.add_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  )
                                : Row(
                                    children: [
                                      _QtyButton(
                                        icon: Icons.add_rounded,
                                        onTap: addOne,
                                        light: true,
                                      ),
                                      Expanded(
                                        child: Text(
                                          '$qty',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 17.5,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      _QtyButton(
                                        icon: qty == 1
                                            ? Icons.delete_outline_rounded
                                            : Icons.remove_rounded,
                                        onTap: removeOne,
                                        light: true,
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (product.hasPackPieces)
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF8A3D),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              product.packDisplayLabel,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Text(
                          '${total.toStringAsFixed(2)} ${AppStrings.currency}',
                          style: const TextStyle(
                            fontSize: 21.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFE53935),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool light;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: onTap != null
              ? (light
                  ? Colors.white.withValues(alpha: 0.14)
                  : _kGreen.withValues(alpha: 0.1))
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: onTap != null
              ? (light ? Colors.white : _kGreen)
              : (light
                  ? Colors.white.withValues(alpha: 0.35)
                  : _kSubtext.withValues(alpha: 0.3)),
          size: 16,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// مساعدات مشتركة
// ══════════════════════════════════════════════════════════════════════════════
class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final GlobalKey? measureKey;

  const _GlassButton({
    required this.icon,
    required this.onTap,
    this.measureKey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              key: measureKey,
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 15),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 17.5,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _StarRating extends StatelessWidget {
  final double rating;
  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating;
        return Icon(
          filled
              ? Icons.star_rounded
              : half
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
          color: const Color(0xFFFFC107),
          size: 16,
        );
      }),
    );
  }
}

// ── مساعد توصيات المنتج (fallback من الكatalog إذا API فارغ) ─────────────────
List<ProductModel> _resolveSimilarProducts({
  required ProductModel product,
  required List<ProductModel> fromApi,
  required bool recsLoaded,
  required CatalogState catalog,
}) {
  if (fromApi.isNotEmpty) return fromApi;
  if (!recsLoaded) {
    return catalog.products
        .where(
          (item) => item.id != product.id && item.categoryId == product.categoryId,
        )
        .take(8)
        .toList();
  }
  return const [];
}

List<ProductModel> _resolveSuggestedProducts({
  required ProductModel product,
  required List<ProductModel> fromApi,
  required bool recsLoaded,
  required CatalogState catalog,
}) {
  if (fromApi.isNotEmpty) return fromApi;
  if (!recsLoaded) {
    return catalog.suggestions(excludeIds: {product.id});
  }
  return const [];
}

// ══════════════════════════════════════════════════════════════════════════════
// صفحة المنتج المكدّسة — تنزلق من اليسار وتنطوي عند الإغلاق
// ══════════════════════════════════════════════════════════════════════════════

/// يفتح صفحة تفاصيل منتج مكدّسة فوق الحالية، تنزلق من اليسار.
void pushStackedProduct(BuildContext context, ProductModel product) {
  Navigator.of(context, rootNavigator: true).push(
    _StackedProductRoute(product: product),
  );
}

class _StackedProductRoute extends PageRouteBuilder<void> {
  _StackedProductRoute({required ProductModel product})
      : super(
          opaque: false,
          barrierDismissible: false,
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 360),
          pageBuilder: (context, animation, secondaryAnimation) =>
              _StackedProductPage(
                product: product,
                heroTag:
                    'stacked_${product.id}_${DateTime.now().microsecondsSinceEpoch}',
              ),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) =>
                  _StackedPageTransition(animation: animation, child: child),
        );
}

class _StackedPageTransition extends AnimatedWidget {
  final Widget child;

  const _StackedPageTransition({
    required Animation<double> animation,
    required this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    final t = animation.value;
    final size = MediaQuery.sizeOf(context);

    // Entry (forward / completed / dismissed-at-start): slide in from left
    if (animation.status != AnimationStatus.reverse) {
      final slide = 1.0 - Curves.easeOutCubic.transform(t);
      return Transform.translate(
        offset: Offset(-size.width * slide, 0),
        child: child,
      );
    }

    // Exit (reverse): fold toward bottom-left corner
    final foldT = Curves.easeIn.transform(1.0 - t);
    final scale = 1.0 - foldT * 0.82;
    final tx = -size.width * 0.36 * foldT;
    final ty = size.height * 0.36 * foldT;

    return Opacity(
      opacity: (1.0 - foldT * 0.55).clamp(0.0, 1.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26 * foldT),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translateByDouble(tx, ty, 0.0, 1.0)
            ..rotateZ(-foldT * 0.10)
            ..scaleByDouble(scale, scale, 1.0, 1.0),
          child: child,
        ),
      ),
    );
  }
}

class _StackedProductPage extends StatefulWidget {
  final ProductModel product;
  final String heroTag;

  const _StackedProductPage({
    required this.product,
    required this.heroTag,
  });

  @override
  State<_StackedProductPage> createState() => _StackedProductPageState();
}

class _StackedProductPageState extends State<_StackedProductPage>
    with TickerProviderStateMixin {
  // Cart animations
  late final AnimationController _cartCtrl;
  late final Animation<double> _cartScale;
  late final AnimationController _topCartBounceCtrl;
  late final Animation<double> _topCartBounceScale;
  late final AnimationController _topCartReleaseCtrl;
  late final Animation<double> _topCartReleaseScale;

  // Shimmer entry
  late final AnimationController _shimmerCtrl;

  // Related products
  List<ProductModel> _boughtTogether = const [];
  List<ProductModel> _similar = const [];
  List<ProductModel> _suggested = const [];
  bool _recsLoaded = false;

  // Keys & anchors
  final GlobalKey _pageKey = GlobalKey();
  final GlobalKey _topCartKey = GlobalKey();
  final Object _productImageAnchor = Object();
  final ScrollController _scrollCtrl = ScrollController();

  // Drag-to-dismiss
  Offset _dragStart = Offset.zero;
  bool _dragActive = false;

  ProductModel get p => widget.product;

  @override
  void initState() {
    super.initState();
    _cartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
    );
    _cartScale = _cartCtrl;
    _topCartBounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _topCartBounceScale = Tween<double>(begin: 1, end: 1.26).animate(
      CurvedAnimation(parent: _topCartBounceCtrl, curve: Curves.elasticOut),
    );
    _topCartReleaseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _topCartReleaseScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 0.92), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 0.92, end: 1), weight: 50),
    ]).animate(CurvedAnimation(
        parent: _topCartReleaseCtrl, curve: Curves.easeInOut));

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    CartNavAnchor.detailsBounce.addListener(_onCartPing);
    CartNavAnchor.detailsRelease.addListener(_onCartRelease);
    CartNavAnchor.detailsBoundsKey = _pageKey;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bindTopCart();
      // Start shimmer fade-out after route entry animation settles
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _shimmerCtrl.forward();
      });
    });

    _loadRecommendations();
  }

  void _onCartPing() {
    if (!mounted) return;
    _topCartBounceCtrl.forward(from: 0);
  }

  void _onCartRelease() {
    if (!mounted) return;
    _topCartReleaseCtrl.forward(from: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.isCurrent == true) {
      CartNavAnchor.detailsBoundsKey = _pageKey;
      WidgetsBinding.instance.addPostFrameCallback((_) => _bindTopCart());
    }
  }

  void _bindTopCart() {
    if (!mounted) return;
    CelebratePositions.bind(
      CartNavAnchor.detailsCartAnchor,
      () => celebrateGlobalCenter(_topCartKey),
    );
  }

  Future<void> _loadRecommendations() async {
    final id = p.id;
    try {
      final recs = await CatalogApi.instance.productRecommendations(id);
      if (!mounted) return;
      setState(() {
        _boughtTogether = recs.boughtTogether;
        _similar = recs.similar;
        _suggested = recs.suggested;
        _recsLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _recsLoaded = true);
    }
  }

  @override
  void dispose() {
    CartNavAnchor.detailsBounce.removeListener(_onCartPing);
    CartNavAnchor.detailsRelease.removeListener(_onCartRelease);
    if (CartNavAnchor.detailsBoundsKey == _pageKey) {
      CartNavAnchor.detailsBoundsKey = null;
    }
    CelebratePositions.unbind(CartNavAnchor.detailsCartAnchor);
    _shimmerCtrl.dispose();
    _topCartReleaseCtrl.dispose();
    _topCartBounceCtrl.dispose();
    _cartCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  bool _atScrollTop() =>
      !_scrollCtrl.hasClients || _scrollCtrl.offset <= 1.0;

  void _onPointerDown(PointerDownEvent e) {
    _dragStart = e.position;
    _dragActive = false;
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (!_atScrollTop() && !_dragActive) return;
    final dist = (e.position - _dragStart).distance;
    if (!_dragActive && dist > 14) _dragActive = true;
  }

  void _onPointerUp(PointerUpEvent e) {
    if (!_dragActive) return;
    _dragActive = false;
    final dist = (e.position - _dragStart).distance;
    if (dist > 55) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      child: _buildPageWithShimmer(context),
    );
  }

  Widget _buildPageWithShimmer(BuildContext context) {
    final page = _buildPage(context);

    return AnimatedBuilder(
      animation: _shimmerCtrl,
      builder: (_, child) {
        if (_shimmerCtrl.isCompleted) return child!;
        return Stack(
          children: [
            child!,
            Positioned.fill(
              child: IgnorePointer(
                child: FadeTransition(
                  opacity: Tween<double>(begin: 1, end: 0).animate(
                    CurvedAnimation(
                        parent: _shimmerCtrl, curve: Curves.easeOut),
                  ),
                  child: _buildShimmerOverlay(context),
                ),
              ),
            ),
          ],
        );
      },
      child: page,
    );
  }

  Widget _buildShimmerOverlay(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    return Container(
      color: _kGreenBg,
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE0EEE5),
        highlightColor: const Color(0xFFF5FAF6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: h * 0.35,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(double.infinity, 22),
                  const SizedBox(height: 8),
                  _shimmerBox(160, 16),
                  const SizedBox(height: 16),
                  _shimmerBox(double.infinity, 90, radius: 20),
                  const SizedBox(height: 12),
                  _shimmerBox(double.infinity, 60, radius: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(double w, double h, {double radius = 8}) {
    return Container(
      width: w,
      height: h,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    final catalog = context.watch<CatalogCubit>().state;
    final similar = _resolveSimilarProducts(
      product: p,
      fromApi: _similar,
      recsLoaded: _recsLoaded,
      catalog: catalog,
    );
    final suggested = _resolveSuggestedProducts(
      product: p,
      fromApi: _suggested,
      recsLoaded: _recsLoaded,
      catalog: catalog,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: _kGreenBg,
          body: Stack(
            key: _pageKey,
            children: [
              // ── المحتوى القابل للتمرير ────────────────────────────────
              CustomScrollView(
                controller: _scrollCtrl,
                slivers: [
                  _ProductHeroHeader(
                    product: p,
                    heroTag: widget.heroTag,
                    productImageAnchor: _productImageAnchor,
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProductInfoSection(product: p),
                        const SizedBox(height: 12),
                        if (p.benefits.isNotEmpty)
                          _AiTipsSection(benefits: p.benefits),
                        const SizedBox(height: 12),
                        _DescriptionSection(description: p.description),
                        if (p.hasGiftProduct) ...[
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ProductGiftDetailCard(gift: p.giftProduct!),
                          ),
                        ],
                        const SizedBox(height: 12),
                        if (p.usageInstructions.isNotEmpty)
                          _UsageSection(instructions: p.usageInstructions),
                        // ── المنتجات المقترحة ──────────────────────────
                        if (_boughtTogether.isNotEmpty)
                          _DetailsRecsRow(
                            title: 'يُشترى معه',
                            products: _boughtTogether,
                            highlighted: true,
                          ),
                        if (similar.isNotEmpty)
                          _DetailsRecsRow(
                            title: 'منتجات مشابهة',
                            products: similar,
                          ),
                        if (suggested.isNotEmpty)
                          _DetailsRecsRow(
                            title: 'منتجات مقترحة',
                            products: suggested,
                          ),
                        const SizedBox(height: 110),
                      ],
                    ),
                  ),
                ],
              ),

              // ── زر رجوع أعلى اليسار ──────────────────────────────────
              Positioned(
                top: MediaQuery.paddingOf(context).top + 6,
                left: 10,
                child: ScaleTransition(
                  scale: _topCartReleaseScale,
                  child: ScaleTransition(
                    scale: _topCartBounceScale,
                    child: BlocBuilder<CartCubit, CartState>(
                      buildWhen: (a, b) => a.count != b.count,
                      builder: (context, cart) => AppCountBadge.wrap(
                        count: cart.count,
                        offset: const Offset(4, -4),
                        child: _GlassButton(
                          measureKey: _topCartKey,
                          icon: Icons.arrow_forward_ios_rounded,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── زر "أضف للسلة" الثابت ────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _AddToCartBar(
                  product: p,
                  scaleAnim: _cartScale,
                  productImageAnchor: _productImageAnchor,
                  pageKey: _pageKey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// صف المنتجات المقترحة في صفحة التفاصيل
// ══════════════════════════════════════════════════════════════════════════════
class _DetailsRecsRow extends StatelessWidget {
  final String title;
  final List<ProductModel> products;
  final bool highlighted;

  const _DetailsRecsRow({
    required this.title,
    required this.products,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: _kText,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 188,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            cacheExtent: 200,
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final product = products[index];
              return _DetailsRecsTile(
                product: product,
                onOpen: () => pushStackedProduct(context, product),
              );
            },
          ),
        ),
      ],
    );

    if (!highlighted) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
        child: content,
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 18, bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _kGreen.withValues(alpha: 0.08),
            _kGreenBg,
            const Color(0x00F0FAF3),
          ],
          stops: const [0, 0.45, 1],
        ),
      ),
      child: content,
    );
  }
}

class _DetailsRecsTile extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onOpen;

  const _DetailsRecsTile({required this.product, required this.onOpen});

  @override
  State<_DetailsRecsTile> createState() => _DetailsRecsTileState();
}

class _DetailsRecsTileState extends State<_DetailsRecsTile> {
  final Object _productImageAnchor = Object();

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return SizedBox(
      width: 118,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onOpen,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CelebrateAnchor(
                          anchor: _productImageAnchor,
                          child: ProductThumbnail(
                            imageUrl: product.displayImage,
                            backgroundColor: AppTheme.productImageWell,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        start: 0,
                        bottom: 0,
                        child: CardCartControl(
                          product: product,
                          productImageAnchor: _productImageAnchor,
                          flyToTopCart: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                PriceLine(
                  price: product.effectivePrice,
                  originalPrice:
                      product.hasDiscount ? product.price : null,
                  priceSize: 13,
                  currencySize: 15,
                  alignment: AlignmentDirectional.centerStart,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
