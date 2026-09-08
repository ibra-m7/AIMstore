import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/models/product_model.dart';
import 'product_card.dart';
import 'product_card_shimmer.dart';

/// شيت موحّد لعرض منتجات أي قسم — نفس تصميم أفضل العروض.
class ProductBrowseSheetScreen extends StatefulWidget {
  final String headerImageUrl;
  final List<ProductModel> products;
  final String heroTagPrefix;
  final bool loading;
  final String? error;
  final VoidCallback? onRetry;
  final String emptyMessage;

  const ProductBrowseSheetScreen({
    super.key,
    this.headerImageUrl = '',
    this.products = const [],
    required this.heroTagPrefix,
    this.loading = false,
    this.error,
    this.onRetry,
    this.emptyMessage = AppStrings.dynamicPageEmpty,
  });

  static const gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    childAspectRatio: 0.62,
  );

  static const sheetRadius = 22.0;

  @override
  State<ProductBrowseSheetScreen> createState() =>
      _ProductBrowseSheetScreenState();
}

class _ProductBrowseSheetScreenState extends State<ProductBrowseSheetScreen> {
  late final ScrollController _scrollCtrl;
  double _dismissDy = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  bool _tracksDismiss(Offset delta) {
    if (delta.dx.abs() > delta.dy.abs() && _dismissDy == 0) return false;
    final atTop = !_scrollCtrl.hasClients || _scrollCtrl.offset <= 0.5;
    return atTop || _dismissDy > 0;
  }

  void _onDismissPointerMove(PointerMoveEvent event) {
    if (!_tracksDismiss(event.delta)) return;
    final next = (_dismissDy + event.delta.dy).clamp(0.0, 640.0);
    if (next == _dismissDy) return;
    setState(() => _dismissDy = next);
  }

  void _onDismissPointerEnd(PointerEvent event) {
    if (_dismissDy >= 90) {
      Navigator.of(context).maybePop();
      return;
    }
    if (_dismissDy != 0) {
      setState(() => _dismissDy = 0);
    }
  }

  double get _pageTopRadius {
    final t = (_dismissDy / 70).clamp(0.0, 1.0);
    return Curves.easeOut.transform(t) * 32;
  }

  double get _barrierAlpha {
    final t = (_dismissDy / 280).clamp(0.0, 1.0);
    return 0.42 * (1.0 - Curves.easeOut.transform(t));
  }

  Widget _hero(String header) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (header.isNotEmpty)
          AppNetworkImage(
            header,
            fit: BoxFit.cover,
            width: 900,
            placeholder: const ColoredBox(color: Color(0xFF1B3A2D)),
            error: const ColoredBox(color: Color(0xFF1B3A2D)),
          )
        else
          const ColoredBox(color: Color(0xFF1B3A2D)),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x66000000),
                Color(0x14000000),
                Color(0x22000000),
              ],
              stops: [0, 0.45, 1],
            ),
          ),
        ),
      ],
    );
  }

  Widget _productsBody() {
    if (widget.error != null && widget.products.isEmpty && !widget.loading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.mutedText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (widget.onRetry != null) ...[
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: widget.onRetry,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark,
                  ),
                  child: const Text(AppStrings.dynamicPageRetry),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (widget.loading && widget.products.isEmpty) {
      return GridView.builder(
        controller: _scrollCtrl,
        physics: _dismissDy > 0
            ? const NeverScrollableScrollPhysics()
            : const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
        gridDelegate: ProductBrowseSheetScreen.gridDelegate,
        itemCount: 9,
        itemBuilder: (_, _) => const ProductCardShimmer(),
      );
    }

    if (widget.products.isEmpty) {
      return Center(
        child: Text(
          widget.emptyMessage,
          style: const TextStyle(
            color: AppTheme.mutedText,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return GridView.builder(
      controller: _scrollCtrl,
      physics: _dismissDy > 0
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
      gridDelegate: ProductBrowseSheetScreen.gridDelegate,
      itemCount: widget.products.length,
      itemBuilder: (context, i) => ProductCard(
        product: widget.products[i],
        heroTag: '${widget.heroTagPrefix}_${widget.products[i].id}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final header = widget.headerImageUrl.trim();
    final topPad = MediaQuery.paddingOf(context).top;
    final height = MediaQuery.sizeOf(context).height;
    const heroH = 168.0;
    const overlap = 28.0;
    final heroTotal = topPad + heroH;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedContainer(
                    duration: _dismissDy == 0
                        ? const Duration(milliseconds: 180)
                        : Duration.zero,
                    color: Colors.black.withValues(alpha: _barrierAlpha),
                  ),
                ),
              ),
              Listener(
                onPointerMove: _onDismissPointerMove,
                onPointerUp: _onDismissPointerEnd,
                onPointerCancel: _onDismissPointerEnd,
                child: AnimatedSlide(
                  offset: Offset(0, _dismissDy / height),
                  duration: _dismissDy == 0
                      ? const Duration(milliseconds: 180)
                      : Duration.zero,
                  curve: Curves.easeOutCubic,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(_pageTopRadius),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: heroTotal,
                          child: _hero(header),
                        ),
                        Positioned(
                          top: heroTotal - overlap,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Material(
                            color: AppTheme.background,
                            elevation: 10,
                            shadowColor: Colors.black.withValues(alpha: 0.2),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(
                                ProductBrowseSheetScreen.sheetRadius,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _productsBody(),
                          ),
                        ),
                        Positioned(
                          top: topPad + 6,
                          right: 10,
                          child: Material(
                            color: Colors.white,
                            elevation: 6,
                            shadowColor: Colors.black.withValues(alpha: 0.32),
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: () => Navigator.of(context).maybePop(),
                              customBorder: const CircleBorder(),
                              child: const SizedBox(
                                width: 30,
                                height: 30,
                                child: Icon(
                                  Icons.chevron_left_rounded,
                                  size: 22,
                                  color: AppTheme.darkText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
