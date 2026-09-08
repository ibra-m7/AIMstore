import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_scale.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_count_badge.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/auth_flow.dart';
import '../../../auth/data/services/auth_session.dart';
import '../../../auth/presentation/manager/address_cubit.dart';
import '../../../auth/presentation/widgets/delivery_addresses_sheet.dart';
import '../../data/models/product_model.dart';
import '../../data/services/catalog_api.dart';
import '../../domain/entities/cart_bundle_line.dart';
import '../../domain/entities/cart_item.dart';
import '../manager/cart_cubit.dart';
import '../pages/bundle_details_screen.dart';
import '../widgets/cart_display_entries.dart';
import '../manager/catalog_cubit.dart';
import '../providers/cart_scope.dart';
import '../widgets/main_shell_scope.dart';
import '../widgets/checkout_action_bar.dart';
import '../widgets/legendary_beams.dart';
import '../widgets/bundle_cover_images.dart';
import '../widgets/price_line.dart';
import '../widgets/product_card.dart';
import '../widgets/product_preview_sheet.dart';
import '../widgets/stock_limit_snackbar.dart';

// ── الهوية البصرية (Mint Green) ───────────────────────────────────────────────
const _kDark = AppTheme.primaryDark;
const _kBg = AppTheme.background;
const _kSurface = AppTheme.surface;
const _kText = AppTheme.darkText;
const _kSubtext = AppTheme.mutedText;
const _kBorder = AppTheme.primaryLight;

// ══════════════════════════════════════════════════════════════════════════════
class CheckoutScreen extends StatelessWidget {
  static const routeName = '/checkout';
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CartBody();
  }
}

/// سلة التسوق كتبويب داخل [MainScreen] — بدون شريط تنقل مضاعف أو مسار منفصل.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CartBody(embeddedInMainShell: true);
  }
}

/// محتوى السلة — للاستخدام داخل الشيت أو التبويب أو المسار.
class CartBody extends StatelessWidget {
  final bool embeddedInMainShell;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;

  const CartBody({
    super.key,
    this.embeddedInMainShell = false,
    this.scrollController,
    this.scrollPhysics,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: _CartView(
        embeddedInMainShell: embeddedInMainShell,
        scrollController: scrollController,
        scrollPhysics: scrollPhysics,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// العرض الرئيسي للسلة
// ══════════════════════════════════════════════════════════════════════════════
class _CartView extends StatelessWidget {
  final bool embeddedInMainShell;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;

  const _CartView({
    required this.embeddedInMainShell,
    this.scrollController,
    this.scrollPhysics,
  });

  @override
  Widget build(BuildContext context) {
    // فقط عند الانتقال من/إلى السلة الفارغة يُعاد بناء الجذر بالكامل
    return BlocBuilder<CartCubit, CartState>(
      buildWhen: (prev, curr) => prev.isEmpty != curr.isEmpty,
      builder: (context, cart) {
        if (cart.isEmpty) {
          return _EmptyCartScreen(
            embeddedInMainShell: embeddedInMainShell,
            scrollController: scrollController,
            scrollPhysics: scrollPhysics,
          );
        }
        return _CartContent(
          embeddedInMainShell: embeddedInMainShell,
          scrollController: scrollController,
          scrollPhysics: scrollPhysics,
        );
      },
    );
  }
}

/// محتوى السلة — كل قسم يستمع لـ [CartCubit] عبر [BlocSelector]
/// لتحديث الإجمالي وشريط التوصيل فوراً دون إعادة بناء الصفحة كاملة.
class _CartContent extends StatelessWidget {
  final bool embeddedInMainShell;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;

  const _CartContent({
    required this.embeddedInMainShell,
    this.scrollController,
    this.scrollPhysics,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          Column(
            children: [
              BlocSelector<CartCubit, CartState, int>(
                selector: (s) => s.count,
                builder: (context, count) => _CartAppBar(
                  itemCount: count,
                  showLeading: true,
                  useCloseIcon: !embeddedInMainShell,
                  onBack: embeddedInMainShell
                      ? () => MainShellScope.read(context).selectTab(0)
                      : () => Navigator.of(context).pop(),
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  controller: scrollController,
                  physics: scrollPhysics ?? const BouncingScrollPhysics(),
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    SliverToBoxAdapter(
                      child: BlocSelector<CartCubit, CartState, CartState>(
                        selector: (s) => s,
                        builder: (context, cart) =>
                            _UpsellingSection(cartState: cart),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    SliverToBoxAdapter(
                      child: BlocSelector<CartCubit, CartState, List<CartDisplayEntry>>(
                        selector: (s) => s.displayEntries,
                        builder: (context, entries) =>
                            _CartItemsList(entries: entries),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: BlocSelector<CartCubit, CartState, CartState>(
                        selector: (s) => s,
                        builder: (context, cart) =>
                            _SuggestedSection(cartState: cart),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 116)),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BlocSelector<CartCubit, CartState, ({double total, int count})>(
              selector: (s) => (total: s.total, count: s.count),
              builder: (context, data) => CheckoutActionBar(
                label: AppStrings.cartProceedToCheckout,
                total: data.total,
                onTap: () => openCheckoutSheet(context),
                leading: AppCountBadge.pill3d(count: data.count),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// يفتح ورقة الدفع مع ربط صريح بـ [CartCubit] (مزود السلة في التطبيق).
void openCheckoutSheet(BuildContext context) {
  if (!AuthSession.instance.isLoggedIn) {
    AuthFlow.requireLogin(context, message: AppStrings.guestCheckoutMessage);
    return;
  }

  Navigator.of(context).pushNamed(AppRouter.invoice);
}

// ══════════════════════════════════════════════════════════════════════════════
// AppBar السلة
// ══════════════════════════════════════════════════════════════════════════════
class _CartAppBar extends StatelessWidget {
  final int itemCount;
  final bool showLeading;
  final bool useCloseIcon;
  final VoidCallback onBack;

  const _CartAppBar({
    required this.itemCount,
    this.showLeading = true,
    this.useCloseIcon = false,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _kBg,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      AppStrings.cartTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: _kText,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.cartItemCount(itemCount),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: _kSubtext,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (showLeading)
                      _RoundIconButton(
                        icon: useCloseIcon
                            ? Icons.close_rounded
                            : Icons.chevron_right_rounded,
                        onTap: onBack,
                      )
                    else
                      const SizedBox(width: 30),
                    const Spacer(),
                    _ShareCartButton(onTap: () => _shareCart(context)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x14000000), width: 0.5),
          ),
          child: Icon(
            icon,
            size: 22,
            color: _kText,
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  }
}

class _ShareCartButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ShareCartButton({required this.onTap});

  static const double _radius = 5;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
        side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.55)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_radius),
        child: const Padding(
          padding: EdgeInsetsDirectional.fromSTEB(6, 4, 7, 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.ios_share_rounded, size: 11.5, color: _kText),
              SizedBox(width: 3),
              Text(
                AppStrings.cartShare,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: _kText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _shareCart(BuildContext context) async {
  final cart = context.read<CartCubit>().state;
  if (cart.isEmpty) return;
  final buffer = <String>[];
  for (final entry in cart.displayEntries) {
    switch (entry) {
      case CartDisplayBundleEntry(:final line):
        buffer.add('• ${line.bundle.name} × ${line.quantity}');
        for (final item in line.bundle.items) {
          final qty = item.quantity * line.quantity;
          buffer.add('  ↲ ${item.product.name} × $qty');
          final gift = item.product.giftProduct;
          if (gift != null && gift.isAvailable) {
            buffer.add('    ↲ ${gift.name} × $qty (هدية)');
          }
        }
      case CartDisplayProductEntry(:final item, :final giftItems):
        final base = '• ${item.product.name} × ${item.quantity}';
        if (giftItems.isEmpty) {
          buffer.add(base);
        } else {
          buffer.add(
            '$base\n  ↲ ${giftItems.first.product.name} × ${giftItems.first.quantity} (هدية)',
          );
        }
    }
  }
  final lines = buffer.join('\n');
  final box = context.findRenderObject() as RenderBox?;
  await Share.share(
    'سلتي في ${AppStrings.appName}\n$lines\n'
    '${AppStrings.cartTotal}: ${cart.total.toStringAsFixed(2)} ${AppStrings.currency}',
    sharePositionOrigin: box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size,
  );
}

void _confirmClearCart(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      buttonPadding: EdgeInsets.zero,
      title: Text(
        AppStrings.cartClearTitle,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _kText.withValues(alpha: 0.85),
          height: 1.3,
        ),
      ),
      content: Text(
        AppStrings.cartClearBody,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
          color: _kText.withValues(alpha: 0.65),
          height: 1.4,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kText.withValues(alpha: 0.7),
                    minimumSize: const Size.fromHeight(36),
                    side: BorderSide(
                      color: _kText.withValues(alpha: 0.28),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  child: const Text(AppStrings.cancel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<CartCubit>().clearCart();
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE57373),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(36),
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFE4ECE6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  child: const Text(AppStrings.cartClearAll),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CartItemsList extends StatelessWidget {
  final List<CartDisplayEntry> entries;
  const _CartItemsList({required this.entries});

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    final iconPx = (28 * MediaQuery.devicePixelRatioOf(context)).round();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: scale.pagePad),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/cart.png',
                width: 28,
                height: 28,
                cacheWidth: iconPx,
                cacheHeight: iconPx,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  AppStrings.cartProductsInCart,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _kText,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _confirmClearCart(context),
                style: TextButton.styleFrom(
                  foregroundColor: _kSubtext,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 15),
                    SizedBox(width: 2),
                    Text(
                      AppStrings.cartClearAll,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final entry in entries) ...[
            switch (entry) {
              CartDisplayBundleEntry(:final line) => _CartBundleCard(line: line),
              CartDisplayProductEntry(:final item, :final giftItems) =>
                _CartItemCard(item: item, giftItems: giftItems),
            },
            SizedBox(height: scale.s(10)),
          ],
        ],
      ),
    );
  }
}

class _CartBundleCard extends StatelessWidget {
  final CartBundleLine line;

  const _CartBundleCard({required this.line});

  void _openDetails(BuildContext context) {
    Navigator.of(context).pushNamed(
      AppRouter.bundleDetails,
      arguments: BundleDetailsArgs(bundle: line.bundle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.cart;
    final bundle = line.bundle;
    final scale = AppScale.of(context);
    final imageSize = scale.s(64);
    final itemCount = bundle.itemCount > 0
        ? bundle.itemCount
        : bundle.items.fold<int>(0, (sum, item) => sum + item.quantity);

    return Material(
      color: _kSurface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => _openDetails(context),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: imageSize,
                height: imageSize,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ColoredBox(
                    color: AppTheme.productImageWell,
                    child: Center(
                      child: BundleCoverImages(
                        bundle: bundle,
                        singleSize: scale.s(56),
                        stackWidth: scale.s(64),
                        stackHeight: scale.s(52),
                        thumbSize: scale.s(34),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bundle.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: _kText,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    PriceLine(
                      price: bundle.bundlePrice,
                      originalPrice:
                          bundle.hasDiscount ? bundle.originalPrice : null,
                      color: const Color(0xFFE53935),
                      priceSize: 14.5,
                      currencySize: 15,
                      alignment: AlignmentDirectional.centerStart,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primarySurface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        AppStrings.bundleItemCount(itemCount),
                        style: TextStyle(
                          fontSize: scale.s(11),
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              _QtyPill(
                quantity: line.quantity,
                onDecrement: () =>
                    cubit.updateBundleQuantity(line.id, line.quantity - 1),
                onIncrement: () =>
                    cubit.updateBundleQuantity(line.id, line.quantity + 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final List<CartItem> giftItems;

  const _CartItemCard({
    required this.item,
    this.giftItems = const [],
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.cart;
    final p = item.product;
    final model = p is ProductModel ? p : ProductModel.fromEntity(p);
    final scale = AppScale.of(context);
    final imageSize = scale.s(64);

    return Material(
      color: _kSurface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => showProductPreview(context, model),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AppNetworkImage(
                      p.displayImage,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                      error: SizedBox(
                        width: imageSize,
                        height: imageSize,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: _kSubtext,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: _kText,
                            height: 1.2,
                          ),
                        ),
                        if (p.quantityLabel.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            p.quantityLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6B7280),
                              height: 1.25,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        PriceLine(
                          price: p.effectivePrice,
                          originalPrice: p.hasDiscount ? p.price : null,
                          color: const Color(0xFFE53935),
                          priceSize: 14.5,
                          currencySize: 15,
                          alignment: AlignmentDirectional.centerStart,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  _QtyPill(
                    quantity: item.quantity,
                    onDecrement: () =>
                        cubit.updateQuantity(p.id, item.quantity - 1),
                    onIncrement: () =>
                        cubit.updateQuantity(p.id, item.quantity + 1),
                  ),
                ],
              ),
              if (giftItems.isNotEmpty) ...[
                SizedBox(height: scale.s(8)),
                for (var i = 0; i < giftItems.length; i++) ...[
                  if (i > 0) SizedBox(height: scale.s(6)),
                  _CartGiftStrip(giftItem: giftItems[i]),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CartGiftStrip extends StatelessWidget {
  final CartItem giftItem;

  const _CartGiftStrip({required this.giftItem});

  static const _goldHi = Color(0xFFFFF3C4);
  static const _gold = Color(0xFFE8C547);
  static const _goldMid = Color(0xFFD4AF37);
  static const _goldDeep = Color(0xFFB8860B);

  @override
  Widget build(BuildContext context) {
    final gift = giftItem.product;
    final scale = AppScale.of(context);
    final imageSize = scale.s(38);
    final originalPrice =
        context.read<CatalogCubit>().state.productsById[gift.id]?.price;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [_goldDeep, _goldMid, _gold, _goldHi],
          stops: [0.0, 0.32, 0.68, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: _goldMid.withValues(alpha: 0.5),
            blurRadius: 14,
            spreadRadius: 0.6,
            offset: const Offset(4, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: AppNetworkImage(
                gift.displayImage,
                fit: BoxFit.cover,
                error: const ColoredBox(
                  color: Colors.white,
                  child: Icon(
                    Icons.card_giftcard_rounded,
                    color: _goldDeep,
                    size: 17,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                gift.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.15,
                  shadows: [
                    Shadow(
                      color: Color(0x33000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.card_giftcard_rounded,
                        size: 11,
                        color: _goldDeep,
                      ),
                      SizedBox(width: 3),
                      Text(
                        'هدية مجانية',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: _goldDeep,
                        ),
                      ),
                    ],
                  ),
                ),
                if (originalPrice != null && originalPrice > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${originalPrice.toStringAsFixed(2)} ${AppStrings.currency}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: _goldDeep,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: _goldDeep,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyPill extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QtyPill({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final qtyWidth = quantity >= 100
        ? 30.0
        : quantity >= 10
            ? 22.0
            : 18.0;

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4ECE6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyIconButton(
            icon: Icons.add_rounded,
            color: _kText,
            onTap: onIncrement,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: SizedBox(
              key: ValueKey('qty-w-$qtyWidth'),
              width: qtyWidth,
              child: Text(
                '$quantity',
                key: ValueKey(quantity),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: quantity >= 100 ? 12 : 13,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                  color: _kText,
                ),
              ),
            ),
          ),
          _QtyIconButton(
            icon: quantity <= 1
                ? Icons.delete_outline_rounded
                : Icons.remove_rounded,
            color: const Color(0xFFE53935),
            onTap: onDecrement,
          ),
        ],
      ),
    );
  }
}

class _QtyIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QtyIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 30,
        height: 32,
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

class _UpsellingSection extends StatefulWidget {
  final CartState cartState;
  const _UpsellingSection({super.key, required this.cartState});

  @override
  State<_UpsellingSection> createState() => _UpsellingSectionState();
}

class _UpsellingSectionState extends State<_UpsellingSection>
    with AutomaticKeepAliveClientMixin {
  List<ProductModel> _complete = const [];
  List<ProductModel> _visible = const [];
  String _idsKey = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _maybeLoad();
  }

  @override
  void didUpdateWidget(covariant _UpsellingSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeLoad();
  }

  List<String> get _cartIds => allCartProductIds(
        bundles: widget.cartState.bundles,
        items: widget.cartState.items,
      );

  void _maybeLoad() {
    final key = _cartIds.join(',');
    if (key == _idsKey) return;
    _idsKey = key;
    _load();
  }

  Future<void> _load() async {
    final ids = _cartIds;
    if (ids.isEmpty) {
      if (mounted) {
        setState(() {
          _complete = const [];
          _visible = const [];
        });
      }
      return;
    }
    try {
      final recs = await CatalogApi.instance.cartRecommendations(ids);
      if (!mounted || _idsKey != ids.join(',')) return;
      final next = recs.completeCart;
      setState(() {
        _complete = next;
        if (next.isNotEmpty) {
          _visible = next;
        }
      });
    } catch (_) {}
  }

  List<ProductModel> _fallback(BuildContext context) {
    final catalog = context.read<CatalogCubit>().state;
    final paidItems =
        widget.cartState.items.where((i) => !i.isGift && i.isStandalone);
    final cartProductIds = allCartProductIds(
      bundles: widget.cartState.bundles,
      items: widget.cartState.items,
    ).toSet();
    final categoriesInCart = paidItems.map((i) => i.product.categoryId).toSet();
    return catalog.suggestions(
      excludeIds: cartProductIds,
      excludeCategoryIds: categoriesInCart,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_complete.isNotEmpty || _visible.isNotEmpty) return;
    final fallback = _fallback(context);
    if (fallback.isEmpty) return;
    setState(() => _visible = fallback);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final fallback = _fallback(context);
    final suggestions = _complete.isNotEmpty
        ? _complete
        : (_visible.isNotEmpty ? _visible : fallback);
    if (suggestions.isEmpty) return const SizedBox.shrink();
    final scale = AppScale.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: ColoredBox(
        color: const Color(0xFFEAF7EE),
        child: Stack(
          children: [
            const Positioned.fill(
              child: LegendaryBeams(
                hubYFactor: 0.5,
                turnsPerCycle: 0.5,
                beamWidthScale: 2.2,
                duration: Duration(seconds: 28),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, scale.s(8), 0, scale.s(6)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: scale.s(12),
                      end: scale.s(12),
                    ),
                    child: Text(
                      AppStrings.cartCompleteYourCart,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: scale.s(14),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ),
                  SizedBox(height: scale.s(4)),
                  SizedBox(
                    height: _MiniProductCard.compactListHeight,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      clipBehavior: Clip.none,
                      padding: EdgeInsetsDirectional.only(
                        start: scale.s(12),
                        end: scale.s(16),
                      ),
                      itemCount: suggestions.length,
                      separatorBuilder: (_, _) => SizedBox(width: scale.s(6)),
                      itemBuilder: (_, i) => _MiniProductCard(
                        product: suggestions[i],
                        heroPrefix: 'cart_upsell',
                        textBand: true,
                        compact: true,
                        listHeight: _MiniProductCard.compactListHeight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniProductCard extends StatelessWidget {
  final ProductModel product;
  final String heroPrefix;
  final bool textBand;
  final bool compact;
  final double? listHeight;

  const _MiniProductCard({
    required this.product,
    required this.heroPrefix,
    this.textBand = false,
    this.compact = false,
    this.listHeight,
  });

  static const double _width = 112;
  static const double _imageSize = 86;
  static const double _nameH = 16;
  static const double _unitH = 13;
  static const double _priceBandH = 20;
  /// ارتفاع قائمة التمرير فقط — لا يُقيَّد ارتفاع الكرت نفسه.
  static const double upsellListHeight = 168;
  static const double compactListHeight = 168;

  static List<String> _subtitleLines(ProductModel product, {bool compact = false}) {
    final lines = <String>[];
    final label = product.quantityLabel.trim();
    if (label.isNotEmpty) lines.add(label);
    if (product.displayPieceCount > 1) {
      lines.add(product.packDisplayLabel);
    }
    if (compact && lines.length > 1) {
      return lines.take(1).toList();
    }
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final subtitles = _subtitleLines(product, compact: compact);
    final card = InkWell(
      onTap: () => showProductPreview(
        context,
        product,
        heroTag: '${heroPrefix}_${product.id}',
      ),
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: _width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: _width,
              height: _imageSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AppNetworkImage(
                        product.displayImage,
                        width: _width,
                        height: _imageSize,
                        fit: BoxFit.cover,
                        error: const ColoredBox(
                          color: Color(0xFFF3FBF6),
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: _kSubtext,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // داخل الكرت بمسافة كافية حتى لا يُقص من اليمين (RTL start).
                  PositionedDirectional(
                    bottom: 6,
                    start: 6,
                    child: _MiniAddButton(product: product),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            DecoratedBox(
              decoration: BoxDecoration(
                color: textBand
                    ? const Color(0xB3E8F8EC)
                    : const Color(0xF2F3FBF6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: _nameH,
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: _kText,
                          height: 1.15,
                        ),
                      ),
                    ),
                    if (subtitles.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      for (var i = 0; i < subtitles.length; i++) ...[
                        if (i > 0) const SizedBox(height: 2),
                        SizedBox(
                          height: _unitH,
                          child: Text(
                            subtitles[i],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6B7280),
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 4),
                    SizedBox(
                      height: _priceBandH,
                      child: PriceLine(
                        price: product.effectivePrice,
                        originalPrice:
                            product.hasDiscount ? product.price : null,
                        color: const Color(0xFFE53935),
                        priceSize: 17.5,
                        currencySize: 18,
                        alignment: AlignmentDirectional.centerStart,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!compact) return card;

    // عرض ثابت فقط — لا نقيّد الارتفاع حتى لا يحدث RenderFlex overflow
    // عندما يكون ارتفاع القائمة أصغر من محتوى الكرت (خصوصاً مع textScaler).
    return SizedBox(
      width: _width,
      child: card,
    );
  }
}

class _MiniAddButton extends StatelessWidget {
  final ProductModel product;

  const _MiniAddButton({required this.product});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          final qty = context.read<CartCubit>().state.items
              .where((i) => i.product.id == product.id && !i.isGift)
              .fold<int>(0, (sum, i) => sum + i.quantity);
          if (!product.isAvailable || qty >= product.stock) {
            showProductUnavailableSnackBar(context);
            return;
          }
          HapticFeedback.selectionClick();
          context.read<CartCubit>().addToCart(product);
        },
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryDark, width: 1.3),
          ),
          child: const Icon(
            Icons.add_rounded,
            size: 16,
            color: AppTheme.primaryDark,
          ),
        ),
      ),
    );
  }
}

class _SuggestedSection extends StatelessWidget {
  final CartState cartState;
  const _SuggestedSection({required this.cartState});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogCubit>().state;
    final exclude = allCartProductIds(
      bundles: cartState.bundles,
      items: cartState.items,
    ).toSet();
    final products = catalog.suggested
        .where((p) => !exclude.contains(p.id))
        .toList();
    final list = products.isNotEmpty
        ? products
        : catalog.suggestions(excludeIds: exclude);
    if (list.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(28)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 12, 14, 6),
                child: Text(
                  AppStrings.cartSuggested,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _kText,
                  ),
                ),
              ),
              SizedBox(
                height: _MiniProductCard.upsellListHeight + 8,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.none,
                  padding: const EdgeInsetsDirectional.only(
                    start: 14,
                    end: 18,
                    bottom: 8,
                  ),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (_, i) => _MiniProductCard(
                    product: list[i],
                    heroPrefix: 'cart_suggested',
                    textBand: true,
                    compact: true,
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

// ══════════════════════════════════════════════════════════════════════════════
// شاشة السلة الفارغة
// ══════════════════════════════════════════════════════════════════════════════

/// أيقونة سلة مع عنصر يتقافز فوقها بلا توقف.
class _BouncingCartIcon extends StatefulWidget {
  final double size;
  final Color color;

  const _BouncingCartIcon({
    required this.size,
    required this.color,
  });

  @override
  State<_BouncingCartIcon> createState() => _BouncingCartIconState();
}

class _BouncingCartIconState extends State<_BouncingCartIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _bounce = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final bagSize = size * 0.42;
    final travel = size * 0.28;

    return SizedBox(
      width: size,
      height: size + travel * 0.35,
      child: AnimatedBuilder(
        animation: _bounce,
        builder: (context, _) {
          final dy = -travel * _bounce.value;
          return Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: size,
                color: widget.color,
              ),
              Positioned(
                top: size * 0.02 + (travel * 0.35) + dy,
                child: Icon(
                  Icons.shopping_bag_rounded,
                  size: bagSize,
                  color: widget.color,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyCartScreen extends StatelessWidget {
  final bool embeddedInMainShell;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;

  const _EmptyCartScreen({
    required this.embeddedInMainShell,
    this.scrollController,
    this.scrollPhysics,
  });

  void _goShop(BuildContext context) {
    if (embeddedInMainShell) {
      MainShellNavigation.goToTab(context, MainShellTabs.home);
    } else {
      MainShellNavigation.popAndSelectTab(context, MainShellTabs.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    final catalog = context.watch<CatalogCubit>().state;
    final products = <ProductModel>[];
    final seen = <String>{};
    for (final product in [
      ...catalog.suggested,
      ...catalog.products,
      ...catalog.productsById.values,
    ]) {
      if (seen.add(product.id)) products.add(product);
    }

    final media = MediaQuery.of(context);
    final crossSpacing = scale.s(10);
    final horizontalPad = scale.s(16) * 2;
    final cardWidth = (media.size.width - horizontalPad - crossSpacing) /
        AppScale.homeGridCrossAxisCount;
    final cardHeight = cardWidth / AppScale.homeGridCardAspect;
    final titleBlock = scale.s(40);
    final bottomPad = scale.s(24);
    final oneRowPeek = titleBlock + cardHeight + bottomPad;
    final usableHeight = media.size.height -
        media.padding.top -
        kToolbarHeight -
        media.padding.bottom;
    final heroHeight =
        (usableHeight - oneRowPeek).clamp(140.0, usableHeight * 0.55);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            embeddedInMainShell
                ? Icons.chevron_right_rounded
                : Icons.close_rounded,
            size: 20,
            color: _kText,
            textDirection: TextDirection.ltr,
          ),
          onPressed: () => _goShop(context),
        ),
        title: const Text(
          AppStrings.cartTitle,
          style: TextStyle(
            fontSize: 21.5,
            fontWeight: FontWeight.w900,
            color: _kText,
          ),
        ),
      ),
      body: CustomScrollView(
        controller: scrollController,
        physics: scrollPhysics ?? const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: heroHeight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: scale.s(24)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: scale.s(60),
                      color: const Color(0xFFC5D0C9),
                    ),
                    SizedBox(height: scale.s(8)),
                    const Text(
                      AppStrings.cartEmpty,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9AA8A0),
                      ),
                    ),
                    SizedBox(height: scale.s(10)),
                    ElevatedButton(
                      onPressed: () => _goShop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kDark,
                        foregroundColor: Colors.white,
                        minimumSize: Size(scale.s(200), 40),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _BouncingCartIcon(size: 22, color: Colors.white),
                          SizedBox(width: 8),
                          Text(AppStrings.cartStartShopping),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (products.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  scale.s(16),
                  0,
                  scale.s(16),
                  scale.s(8),
                ),
                child: const Text(
                  AppStrings.cartSuggested,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _kDark,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                scale.s(16),
                0,
                scale.s(16),
                scale.s(24),
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: AppScale.homeGridCrossAxisCount,
                  mainAxisSpacing: scale.homeGridMainAxisSpacing,
                  crossAxisSpacing: crossSpacing,
                  childAspectRatio: AppScale.homeGridCardAspect,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final product = products[i];
                    return ProductCard(
                      product: product,
                      heroTag: 'empty_cart_${product.id}',
                      compactFooter: true,
                    );
                  },
                  childCount: products.length,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// حوار النجاح
// ══════════════════════════════════════════════════════════════════════════════
class OrderSuccessDialog extends StatefulWidget {
  const OrderSuccessDialog({super.key});

  @override
  State<OrderSuccessDialog> createState() => _OrderSuccessDialogState();
}

class _OrderSuccessDialogState extends State<OrderSuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _circleSc;
  late Animation<double> _checkFd;
  late Animation<double> _textFd;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _circleSc = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    );
    _checkFd = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.4, 0.75, curve: Curves.easeOut),
    );
    _textFd = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop<String>();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _circleSc,
              child: FadeTransition(
                opacity: _checkFd,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _kDark.withValues(alpha: 0.35),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            FadeTransition(
              opacity: _textFd,
              child: Column(
                children: [
                  const Text(
                    'تم الطلب بنجاح! 🎉',
                    style: TextStyle(
                      fontSize: 23.5,
                      fontWeight: FontWeight.w900,
                      color: _kText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'سيتم تأكيد طلبك وتوصيله في أقرب وقت ممكن.',
                    style: TextStyle(
                      fontSize: 15.5,
                      color: _kSubtext,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _StepIcon(
                        icon: Icons.check_circle_rounded,
                        color: _kDark,
                        label: 'مؤكد',
                      ),
                      _StepArrow(),
                      const _StepIcon(
                        icon: Icons.local_shipping_rounded,
                        color: Colors.orange,
                        label: 'جاري التحضير',
                      ),
                      _StepArrow(),
                      const _StepIcon(
                        icon: Icons.home_rounded,
                        color: Colors.blueAccent,
                        label: 'التوصيل',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // زر تتبع الطلب
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop<String>('orders');
                      },
                      icon: const Icon(Icons.track_changes_rounded, size: 18),
                      label: const Text('تتبع الطلب'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _StepIcon({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11.5, color: _kSubtext)),
      ],
    );
  }
}

class _StepArrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Icon(
      Icons.arrow_forward_ios_rounded,
      size: 14,
      color: Colors.grey[400],
    ),
  );
}
