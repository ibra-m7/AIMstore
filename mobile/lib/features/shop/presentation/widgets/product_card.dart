import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_scale.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/product_thumbnail.dart';
import '../../data/models/product_model.dart';
import 'card_cart_control.dart';
import 'celebrate_anchors.dart';
import 'price_line.dart';
import 'product_gift_overlay.dart';
import 'product_preview_sheet.dart';
import 'promo_badge.dart';
import 'quantity_label_chip.dart';
import 'sold_proof_line.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final String heroTag;
  final VoidCallback? onOpened;
  final bool circularCartButton;

  /// لون خلفية حاوية الصورة فقط (وليس قسم النص).
  final Color? imageWellColor;

  /// هامش داخل حاوية الصورة (أصغر = صورة أكبر).
  final double? imageInset;

  /// فراغ علوي داخل حاوية الصورة (لرفع الصورة قليلاً).
  final double? imageInsetTop;

  /// فراغ سفلي داخل حاوية الصورة.
  final double? imageInsetBottom;

  /// محاذاة صورة المنتج داخل الحاوية.
  final Alignment imageAlignment;

  /// تكبير محتوى الصورة داخل الحاوية دون تغيير حجم الكارد.
  final double imageScale;

  /// حجم زر الإضافة على الكارد.
  final double? cartButtonSize;

  /// إزاحة زر الإضافة من جهة البداية (يمين في RTL) — أكبر = أقرب لليسار.
  final double? cartButtonStartInset;

  /// إزاحة زر الإضافة من أسفل حاوية الصورة.
  final double? cartButtonBottomInset;

  /// تقليل مساحة النص لإعطاء الصورة مساحة أكبر (بدون تكبير الكارد).
  final bool compactFooter;

  /// تكبير خفيف لنصوص الفوتر (الاسم/الكمية/السعر).
  final double footerTextScale;

  /// إلغاء الفراغ الزائد بين المنطقة الرمادية والنص عند عدم وجود سطر المبيعات.
  final bool tightFooterTop;

  /// تقليل الفراغ تحت السعر ومساحة صف السعر قليلاً.
  final bool densePriceArea;

  /// شريط وصندوق الهدية أصغر (مثلاً كروت البحث الضيقة).
  final bool compactGiftOverlay;

  /// يُستدعى بعد إضافة المنتج من زر السلة على الكارد.
  final VoidCallback? onAfterAddedToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.heroTag,
    this.onOpened,
    this.circularCartButton = false,
    Color? imageWellColor,
    Color? cardColor,
    this.imageInset,
    this.imageInsetTop,
    this.imageInsetBottom,
    this.imageAlignment = Alignment.center,
    this.imageScale = 1,
    this.cartButtonSize,
    this.cartButtonStartInset,
    this.cartButtonBottomInset,
    this.compactFooter = false,
    this.footerTextScale = 1,
    this.tightFooterTop = false,
    this.densePriceArea = false,
    this.compactGiftOverlay = false,
    this.onAfterAddedToCart,
  }) : imageWellColor = imageWellColor ?? cardColor;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final Object _giftCelebrateAnchor = Object();
  final Object _productImageAnchor = Object();

  void _openDetails(BuildContext context) {
    widget.onOpened?.call();
    showProductPreview(
      context,
      widget.product,
      heroTag: widget.heroTag,
    );
  }

  static const _cartButtonInset = 6.0;
  /// الرئيسية المضغوطة — أقرب لأسفل حاوية الصورة.
  static const _cartButtonBottomCompact = 18.0;
  /// الأقسام / غير مضغوط — زاوية حاوية الصورة من الأسفل.
  static const _cartButtonBottomSection = 6.0;

  double _compactFooterHeight(AppScale scale, {required bool showSold}) {
    final t = widget.footerTextScale;
    final soldBlock = showSold || !widget.tightFooterTop
        ? (scale.s(13) + scale.s(1)) * t
        : 0.0;
    final priceBlock =
        scale.s(widget.densePriceArea ? 28 : 34) * t;
    final bottomPad = scale.s(widget.densePriceArea ? 0 : 2);
    return scale.s(widget.tightFooterTop ? 4 : 1) +
        soldBlock +
        scale.s(20) * t +
        scale.s(widget.compactFooter ? 0 : 2) +
        scale.s(14) * t +
        scale.s(widget.densePriceArea ? 1 : 2) +
        priceBlock +
        bottomPad;
  }

  static const _defaultImageInset = 8.0;

  Widget _buildProductImage({
    required AppScale scale,
    required String heroTag,
    required ProductModel product,
    required Color wellColor,
    required BorderRadius wellRadius,
  }) {
    final thumb = ProductThumbnail(
      imageUrl: product.displayImage,
      heroTag: heroTag,
      inset: widget.imageInset ?? _defaultImageInset,
      insetTop: widget.imageInsetTop,
      insetBottom: widget.imageInsetBottom,
      alignment: widget.imageAlignment,
      backgroundColor: wellColor,
      borderRadius: wellRadius,
    );

    return CelebrateAnchor(
      anchor: _productImageAnchor,
      child: widget.imageScale == 1
          ? thumb
          : Transform.scale(
              scale: widget.imageScale,
              alignment: widget.imageAlignment,
              child: thumb,
            ),
    );
  }

  Widget _buildPriceRow({
    required AppScale scale,
    required ProductModel product,
    required double priceH,
    required VoidCallback onOpenDetails,
  }) {
    // كروت الأقسام: نفس شكل سعر «تكمل سلتك» في السلة.
    if (!widget.compactFooter) {
      return SizedBox(
        height: priceH,
        width: double.infinity,
        child: GestureDetector(
          onTap: onOpenDetails,
          behavior: HitTestBehavior.opaque,
          child: PriceLine(
            price: product.effectivePrice,
            originalPrice: product.hasDiscount ? product.price : null,
            color: const Color(0xFFE53935),
            priceSize: 17.5,
            currencySize: 18,
            alignment: AlignmentDirectional.centerStart,
          ),
        ),
      );
    }

    return SizedBox(
      height: priceH,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onOpenDetails,
              behavior: HitTestBehavior.opaque,
              child: PriceLine(
                price: product.effectivePrice,
                originalPrice: product.hasDiscount ? product.price : null,
                alignment: AlignmentDirectional.centerStart,
                priceSize: scale.s(21 * widget.footerTextScale),
                maxHeight: priceH,
              ),
            ),
          ),
          if (product.displayPieceCount > 1) ...[
            SizedBox(width: scale.s(4)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: scale.s(6),
                vertical: scale.s(3),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8A3D),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                product.packDisplayLabel,
                style: TextStyle(
                  fontSize: scale.s(9),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardFooter({
    required AppScale scale,
    required ProductModel product,
    required double soldH,
    required double nameH,
    required double quantityH,
    required double priceH,
    required VoidCallback onOpenDetails,
  }) {
    final quantityLabel = product.quantityLabel.trim();
    final quantityText = quantityLabel.isNotEmpty
        ? quantityLabel
        : (product.displayPieceCount > 1 ? product.packDisplayLabel : '');

    return Padding(
      padding: EdgeInsets.fromLTRB(
        scale.s(6),
        scale.s(
          widget.tightFooterTop
              ? 4
              : (widget.compactFooter ? 1 : 3),
        ),
        scale.s(6),
        scale.s(widget.compactFooter
            ? (widget.densePriceArea ? 0 : 2)
            : 4),
      ),
      child: GestureDetector(
        onTap: onOpenDetails,
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ارتفاع ثابت حتى لا يختلف شكل الكروت.
            if (soldH > 0) ...[
              SizedBox(
                height: soldH,
                child: product.soldCount > 0
                    ? SoldProofLine(
                        soldCount: product.soldCount,
                        fontSize: scale.s(
                          (widget.compactFooter ? 9 : 8.5) *
                              widget.footerTextScale,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              SizedBox(height: scale.s(widget.compactFooter ? 1 : 2)),
            ],
            SizedBox(
              height: nameH,
              child: ProductNameText(
                product.name,
                baseSize: scale.s(
                  (widget.compactFooter ? 13.5 : 13) * widget.footerTextScale,
                ),
                fontWeight: widget.compactFooter
                    ? FontWeight.w400
                    : FontWeight.w600,
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: scale.s(widget.compactFooter ? 0 : 2)),
            // ارتفاع ثابت لوصف الكمية حتى لو فارغ.
            SizedBox(
              height: quantityH,
              child: widget.compactFooter
                  ? (quantityLabel.isNotEmpty
                      ? QuantityLabelChip(
                          product: product,
                          fontSize: scale.s(12 * widget.footerTextScale),
                          compact: true,
                        )
                      : const SizedBox.shrink())
                  : (quantityText.isEmpty
                      ? const SizedBox.shrink()
                      : Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            quantityText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: scale.s(10.5 * widget.footerTextScale),
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6B7280),
                              height: 1.25,
                            ),
                          ),
                        )),
            ),
            SizedBox(height: scale.s(widget.densePriceArea ? 1 : 2)),
            _buildPriceRow(
              scale: scale,
              product: product,
              priceH: priceH,
              onOpenDetails: onOpenDetails,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final heroTag = widget.heroTag;
    final scale = AppScale.of(context);
    final textScale = widget.footerTextScale;
    final showSold = p.soldCount > 0;
    final soldH = (!showSold && widget.tightFooterTop)
        ? 0.0
        : scale.s(widget.compactFooter ? 13 : 12) * textScale;
    final nameH = scale.s(widget.compactFooter ? 18 : 16) * textScale;
    final quantityH = scale.s(widget.compactFooter ? 14 : 13) * textScale;
    final priceH = (widget.compactFooter
            ? scale.s(widget.densePriceArea ? 28 : 34)
            : 20.0) *
        textScale;
    final hasGift = p.hasGiftProduct;
    final wellRadius = BorderRadius.circular(scale.s(8));
    final wellColor = widget.imageWellColor ?? AppTheme.productImageWell;
    final giftBadgeSize = widget.compactGiftOverlay ? 20.0 : 26.0;
    final giftStripHeight =
        widget.compactGiftOverlay ? 13.0 : ProductGiftCardStrip.stripHeight;
    final giftStripFontSize = widget.compactGiftOverlay ? 7.0 : 8.0;
    final giftStripIconSize = widget.compactGiftOverlay ? 9.0 : 12.0;
    final giftOverlayInset = widget.compactGiftOverlay ? 4.0 : 6.0;

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: () => _openDetails(context),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: wellColor,
                        borderRadius: wellRadius,
                      ),
                      child: ClipRRect(
                        borderRadius: wellRadius,
                        child: Stack(
                          fit: StackFit.expand,
                          clipBehavior: Clip.hardEdge,
                          children: [
                            Positioned.fill(
                              child: _buildProductImage(
                                scale: scale,
                                heroTag: heroTag,
                                product: p,
                                wellColor: wellColor,
                                wellRadius: wellRadius,
                              ),
                            ),
                            if (p.hasDiscount)
                              PositionedDirectional(
                                top: giftOverlayInset,
                                start: giftOverlayInset,
                                child: PromoBadge(product: p),
                              ),
                            if (hasGift && p.giftProduct != null)
                              PositionedDirectional(
                                top: giftOverlayInset,
                                end: giftOverlayInset,
                                child: ProductGiftBadge(
                                  positionAnchor: _giftCelebrateAnchor,
                                  gift: p.giftProduct!,
                                  size: giftBadgeSize,
                                ),
                              ),
                            if (!p.isAvailable)
                              Positioned.fill(
                                child: ColoredBox(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  child: const Center(
                                    child: Text(
                                      AppStrings.productOutOfStock,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (hasGift)
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: ProductGiftCardStrip(
                                  fullWidth: true,
                                  embedded: true,
                                  height: giftStripHeight,
                                  fontSize: giftStripFontSize,
                                  iconSize: giftStripIconSize,
                                  horizontalPadding:
                                      widget.compactGiftOverlay ? 4 : 6,
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: scale.s(
                    widget.cartButtonStartInset ?? _cartButtonInset,
                  ),
                  bottom: scale.s(
                    widget.cartButtonBottomInset ??
                        (widget.compactFooter
                            ? _cartButtonBottomCompact
                            : _cartButtonBottomSection),
                  ),
                  child: CardCartControl(
                    product: p,
                    size: widget.cartButtonSize ?? 26,
                    circular: widget.circularCartButton,
                    productImageAnchor: _productImageAnchor,
                    giftCelebrateAnchor:
                        hasGift ? _giftCelebrateAnchor : null,
                    onAfterAddedToCart: widget.onAfterAddedToCart,
                  ),
                ),
              ],
            ),
          ),
          if (widget.compactFooter)
            SizedBox(
              height: _compactFooterHeight(scale, showSold: showSold),
              child: ClipRect(
                child: _buildCardFooter(
                  scale: scale,
                  product: p,
                  soldH: soldH,
                  nameH: nameH,
                  quantityH: quantityH,
                  priceH: priceH,
                  onOpenDetails: () => _openDetails(context),
                ),
              ),
            )
          else
            _buildCardFooter(
              scale: scale,
              product: p,
              soldH: soldH,
              nameH: nameH,
              quantityH: quantityH,
              priceH: priceH,
              onOpenDetails: () => _openDetails(context),
            ),
        ],
      ),
    );
  }
}
