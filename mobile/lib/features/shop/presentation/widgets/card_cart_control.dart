import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/product.dart';
import '../manager/cart_cubit.dart';
import 'gift_celebrate_overlay.dart';
import 'celebrate_anchors.dart';
import 'product_fly_overlay.dart';
import 'stock_limit_snackbar.dart';

/// يدير زر الإضافة الموسّع: واحد فقط في الشاشة، ويُغلق باللمس خارجه.
class CardStepperFocus {
  CardStepperFocus._();

  static final Object tapGroup = Object();
  static final ValueNotifier<String?> active = ValueNotifier(null);
  static Timer? _scrollCollapseTimer;

  static void expand(String productId) => active.value = productId;

  static void collapse() {
    _scrollCollapseTimer?.cancel();
    active.value = null;
  }

  /// عند التمرير: يطوي العداد ثم يظهر الرقم بحركة أبطأ.
  static bool handleScrollNotification(ScrollNotification notification) {
    if (active.value == null) return false;
    if (notification is! ScrollUpdateNotification) return false;
    final delta = notification.scrollDelta;
    if (delta == null || delta.abs() < 0.5) return false;

    _scrollCollapseTimer?.cancel();
    _scrollCollapseTimer = Timer(const Duration(milliseconds: 140), collapse);
    return false;
  }
}

/// يلفّ قائمة/شاشة قابلة للتمرير ليطوي العداد عند السحب.
class CardStepperScrollScope extends StatelessWidget {
  final Widget child;

  const CardStepperScrollScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: CardStepperFocus.handleScrollNotification,
      child: child,
    );
  }
}

/// زر + على الكارد: يتوسّع لليسار ويبقى مثبتاً من جهة البداية (يمين في RTL).
class CardCartControl extends StatefulWidget {
  final Product product;
  final Color color;
  final double size;
  final bool circular;
  final Object? productImageAnchor;
  final Object? giftCelebrateAnchor;
  final bool flyToTopCart;
  final VoidCallback? onAfterAddedToCart;

  const CardCartControl({
    super.key,
    required this.product,
    this.color = AppTheme.primaryDark,
    this.size = 26,
    this.circular = false,
    this.productImageAnchor,
    this.giftCelebrateAnchor,
    this.flyToTopCart = false,
    this.onAfterAddedToCart,
  });

  @override
  State<CardCartControl> createState() => _CardCartControlState();
}

class _CardCartControlState extends State<CardCartControl> {
  String get _paidCartKey => 'paid:${widget.product.id}';

  static const _borderWidth = 1.1;
  static const _borderInset = _borderWidth * 2;

  BoxDecoration _decoration({
    required bool idle,
    required bool circular,
    required double height,
  }) {
    final radius = circular ? height / 2 : 8.0;
    return BoxDecoration(
      color: idle ? AppTheme.primarySurface : AppTheme.primaryDark,
      borderRadius: BorderRadius.circular(radius),
      border: idle
          ? const Border.fromBorderSide(
              BorderSide(color: AppTheme.primaryDark, width: _borderWidth),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final disabled = !p.isAvailable;
    final size = widget.size;
    final circular = widget.circular;
    final stepperWidth = size * 3.15;

    return ValueListenableBuilder<String?>(
      valueListenable: CardStepperFocus.active,
      builder: (context, activeId, _) {
        return BlocBuilder<CartCubit, CartState>(
          builder: (context, cart) {
            final qty = _qty(cart);
            final canPlus = !disabled && qty < p.stock;
            final expanded = qty > 0 && activeId == p.id;

        void add() {
          if (disabled || !canPlus) {
            showProductUnavailableSnackBar(context);
            return;
          }
          HapticFeedback.selectionClick();
          final celebrateGift =
              p.hasGiftProduct && p.giftProduct != null && qty == 0;
          context.read<CartCubit>().addToCart(p);
          widget.onAfterAddedToCart?.call();
          if (qty == 0) {
            CardStepperFocus.expand(p.id);
          }
          final box = context.findRenderObject();
          final fallback = box is RenderBox && box.hasSize
              ? box.localToGlobal(box.size.center(Offset.zero))
              : null;
          final flyEnd = resolveFlyEnd(
            context,
            preferTopCart: widget.flyToTopCart,
            boundsKey: CartNavAnchor.detailsBoundsKey,
          );
          ProductFlyController.play(
            context: context,
            imageUrl: p.displayImage,
            productAnchor: widget.productImageAnchor,
            fallbackStart: fallback,
            overrideEnd: flyEnd,
            pingDetailsCart: widget.flyToTopCart,
            onComplete: celebrateGift
                ? () {
                    Future.delayed(const Duration(milliseconds: 180), () {
                      if (!context.mounted) return;
                      GiftCelebrateController.play(
                        context: context,
                        giftAnchor: widget.giftCelebrateAnchor,
                        giftImageUrl: p.giftProduct!.displayImage,
                        fallbackStart: fallback,
                        overrideEnd: flyEnd,
                        pingDetailsCart: widget.flyToTopCart,
                      );
                    });
                  }
                : null,
          );
        }

        void remove() {
          if (qty <= 0) return;
          context.read<CartCubit>().updateQuantity(p.id, qty - 1);
          if (qty - 1 <= 0 && CardStepperFocus.active.value == p.id) {
            CardStepperFocus.collapse();
          }
          final box = context.findRenderObject();
          final fallback = box is RenderBox && box.hasSize
              ? box.localToGlobal(box.size.center(Offset.zero))
              : null;
          ProductFlyController.playReverse(
            context: context,
            imageUrl: p.displayImage,
            productAnchor: widget.productImageAnchor,
            fallbackEnd: fallback,
            flyFromTopCart: widget.flyToTopCart,
            boundsKey: CartNavAnchor.detailsBoundsKey,
            releaseDetailsCart: widget.flyToTopCart,
          );
        }

        final hasBorder = qty == 0 || !expanded;
        final borderExtra = hasBorder ? _borderInset : 0.0;
        final width = qty == 0
            ? size + borderExtra
            : (expanded ? stepperWidth : size + borderExtra);
        final decoration = _decoration(
          idle: hasBorder,
          circular: circular,
          height: size,
        );

        return TapRegion(
          groupId: CardStepperFocus.tapGroup,
          onTapOutside: (_) {
            if (CardStepperFocus.active.value == p.id) {
              CardStepperFocus.collapse();
            }
          },
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: AnimatedContainer(
              duration: expanded
                  ? const Duration(milliseconds: 220)
                  : const Duration(milliseconds: 480),
              curve: expanded ? Curves.easeOutCubic : Curves.easeInOutCubic,
              width: width,
              height: size,
              decoration: decoration,
              clipBehavior: Clip.antiAlias,
              child: qty == 0
                  ? _buildIdlePlus(
                      disabled: disabled,
                      size: size,
                      circular: circular,
                      onAdd: add,
                    )
                  : OverflowBox(
                      alignment: AlignmentDirectional.centerStart,
                      minWidth: size,
                      maxWidth: stepperWidth,
                      child: SizedBox(
                        width: stepperWidth,
                        height: size,
                        child: _buildQtyRow(
                          size: size,
                          stepperWidth: stepperWidth,
                          qty: qty,
                          expanded: expanded,
                          circular: circular,
                          canPlus: canPlus,
                          onAdd: add,
                          onRemove: remove,
                          onExpand: () {
                            HapticFeedback.selectionClick();
                            CardStepperFocus.expand(p.id);
                          },
                        ),
                      ),
                    ),
            ),
          ),
        );
          },
        );
      },
    );
  }

  int _qty(CartState cart) {
    return cart.items
        .where((item) => item.cartKey == _paidCartKey)
        .fold<int>(0, (sum, item) => sum + item.quantity);
  }

  double _plusIconSize(double buttonSize) =>
      (buttonSize * 0.72).clamp(18.0, 26.0);

  Widget _buildIdlePlus({
    required bool disabled,
    required double size,
    required bool circular,
    required VoidCallback onAdd,
  }) {
    return _SquareTap(
      size: size,
      circular: circular,
      onTap: onAdd,
      semanticsLabel: 'إضافة للسلة',
      child: Icon(
        Icons.add_rounded,
        color: disabled ? const Color(0xFFC5D4CB) : AppTheme.primaryDark,
        size: _plusIconSize(size),
      ),
    );
  }

  /// الصف بعرض ثابت؛ الحاوية تقصّه من اليسار عند الطي دون تحريك الخلية الأولى.
  Widget _buildQtyRow({
    required double size,
    required double stepperWidth,
    required int qty,
    required bool expanded,
    required bool circular,
    required bool canPlus,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
    required VoidCallback onExpand,
  }) {
    final middleWidth = stepperWidth - (size * 2);

    return Row(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            layoutBuilder: (currentChild, previousChildren) => Stack(
              alignment: Alignment.center,
              children: [
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            ),
            child: expanded
                ? _SquareTap(
                    key: const ValueKey('stepper-plus'),
                    size: size,
                    circular: circular,
                    onTap: onAdd,
                    semanticsLabel: 'زيادة الكمية',
                    child: Icon(
                      Icons.add_rounded,
                      color: canPlus
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      size: _plusIconSize(size),
                    ),
                  )
                : _SquareTap(
                    key: const ValueKey('stepper-qty'),
                    size: size,
                    circular: circular,
                    onTap: onExpand,
                    semanticsLabel: 'تعديل الكمية',
                    child: Text(
                      '$qty',
                      style: const TextStyle(
                        color: AppTheme.primaryDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
          ),
        ),
        IgnorePointer(
          ignoring: !expanded,
          child: SizedBox(
            width: middleWidth,
            height: size,
            child: Center(
              child: AnimatedOpacity(
                opacity: expanded ? 1 : 0,
                duration: expanded
                    ? const Duration(milliseconds: 180)
                    : const Duration(milliseconds: 320),
                curve: Curves.easeInOut,
                child: Text(
                  '$qty',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
        IgnorePointer(
          ignoring: !expanded,
          child: SizedBox(
            width: size,
            height: size,
            child: _SquareTap(
              size: size,
              circular: false,
              onTap: onRemove,
              semanticsLabel:
                  qty == 1 ? 'حذف من السلة' : 'تقليل الكمية',
              child: Icon(
                qty == 1
                    ? Icons.delete_outline_rounded
                    : Icons.remove_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SquareTap extends StatelessWidget {
  final double size;
  final bool circular;
  final VoidCallback? onTap;
  final Widget child;
  final String? semanticsLabel;

  const _SquareTap({
    super.key,
    required this.size,
    this.circular = false,
    required this.onTap,
    required this.child,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(circular ? size / 2 : 8),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: child),
        ),
      ),
    );
  }
}
