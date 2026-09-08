import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/cart_bundle_line.dart';
import '../../domain/entities/cart_item.dart';

/// صف منتج في ملخص السلة/الطلب — مع هدية متداخلة تحته.
class CartSummaryGroup extends StatelessWidget {
  final CartItem item;
  final CartItem? gift;
  final String? currency;
  final bool tableLayout;

  const CartSummaryGroup({
    super.key,
    required this.item,
    this.gift,
    this.currency,
    this.tableLayout = false,
  });

  static const _giftColor = Color(0xFFC77800);
  static const _giftArrow = '↲';

  static const _cellStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 12.5,
    color: AppTheme.darkText,
  );

  @override
  Widget build(BuildContext context) {
    if (tableLayout) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TableRow(
              name: item.product.name,
              unitPrice: item.product.effectivePrice,
              quantity: item.quantity,
              lineTotal: item.totalPrice,
            ),
            if (gift != null) ...[
              const SizedBox(height: 4),
              _GiftTableRow(
                name: gift!.product.name,
                quantity: gift!.quantity,
              ),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SimpleSummaryLine(
            name: item.product.name,
            quantity: item.quantity,
            amount: item.totalPrice,
            currency: currency,
          ),
          if (gift != null) ...[
            const SizedBox(height: 4),
            _SimpleGiftLine(
              name: gift!.product.name,
              quantity: gift!.quantity,
              currency: currency,
            ),
          ],
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final String name;
  final double unitPrice;
  final int quantity;
  final double lineTotal;

  const _TableRow({
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CartSummaryGroup._cellStyle,
          ),
        ),
        Expanded(
          child: Text(
            unitPrice.toStringAsFixed(1),
            textAlign: TextAlign.center,
            style: CartSummaryGroup._cellStyle,
          ),
        ),
        Expanded(
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: CartSummaryGroup._cellStyle,
          ),
        ),
        Expanded(
          child: Text(
            lineTotal.toStringAsFixed(1),
            textAlign: TextAlign.center,
            style: CartSummaryGroup._cellStyle,
          ),
        ),
      ],
    );
  }
}

class _GiftTableRow extends StatelessWidget {
  final String name;
  final int quantity;

  const _GiftTableRow({
    required this.name,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    const giftStyle = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 12,
      color: CartSummaryGroup._giftColor,
      height: 1.2,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '${CartSummaryGroup._giftArrow} ', style: giftStyle),
                TextSpan(text: name, style: giftStyle),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: Text(
            '0.0',
            textAlign: TextAlign.center,
            style: giftStyle.copyWith(
              decoration: TextDecoration.lineThrough,
              color: CartSummaryGroup._giftColor.withValues(alpha: 0.85),
            ),
          ),
        ),
        Expanded(
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: giftStyle,
          ),
        ),
        Expanded(
          child: Text(
            '0.0',
            textAlign: TextAlign.center,
            style: giftStyle.copyWith(
              decoration: TextDecoration.lineThrough,
              color: CartSummaryGroup._giftColor.withValues(alpha: 0.85),
            ),
          ),
        ),
      ],
    );
  }
}

class _SimpleSummaryLine extends StatelessWidget {
  final String name;
  final int quantity;
  final double amount;
  final String? currency;

  const _SimpleSummaryLine({
    required this.name,
    required this.quantity,
    required this.amount,
    this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final priceText = currency == null
        ? amount.toStringAsFixed(2)
        : '${amount.toStringAsFixed(2)} $currency';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          priceText,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
            color: AppTheme.darkText,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            'x$quantity $name',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              color: AppTheme.darkText,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

class _SimpleGiftLine extends StatelessWidget {
  final String name;
  final int quantity;
  final String? currency;

  const _SimpleGiftLine({
    required this.name,
    required this.quantity,
    this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final priceText = currency == null ? '0.00' : '0.00 $currency';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          priceText,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: AppTheme.mutedText,
            decoration: TextDecoration.lineThrough,
            decorationColor: AppTheme.mutedText.withValues(alpha: 0.7),
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '${CartSummaryGroup._giftArrow} ',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                    color: CartSummaryGroup._giftColor,
                  ),
                ),
                TextSpan(
                  text: 'x$quantity $name',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: CartSummaryGroup._giftColor,
                    height: 1.25,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

/// صف منتج في تفاصيل الطلب — مع صورة وهدية متداخلة.
class OrderItemGroupRow extends StatelessWidget {
  final CartItem item;
  final CartItem? gift;
  final Widget Function(String url, double size) imageBuilder;

  const OrderItemGroupRow({
    super.key,
    required this.item,
    this.gift,
    required this.imageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _OrderPaidRow(item: item, imageBuilder: imageBuilder),
          if (gift != null) ...[
            const SizedBox(height: 4),
            _OrderGiftRow(gift: gift!, imageBuilder: imageBuilder),
          ],
        ],
      ),
    );
  }
}

class _OrderPaidRow extends StatelessWidget {
  final CartItem item;
  final Widget Function(String url, double size) imageBuilder;

  const _OrderPaidRow({
    required this.item,
    required this.imageBuilder,
  });

  static const _text = Color(0xFF1A1A1A);
  static const _subtext = Color(0xFF6B7280);
  static const _dark = Color(0xFF1B4332);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: imageBuilder(item.product.imageUrl, 48),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: _text,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${item.product.effectivePrice.toStringAsFixed(2)} \u{20C1} × ${item.quantity}',
                style: const TextStyle(
                  fontSize: 11,
                  color: _subtext,
                  fontWeight: FontWeight.w400,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${item.totalPrice.toStringAsFixed(2)} \u{20C1}',
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: _dark,
          ),
        ),
      ],
    );
  }
}

class _OrderGiftRow extends StatelessWidget {
  final CartItem gift;
  final Widget Function(String url, double size) imageBuilder;

  const _OrderGiftRow({
    required this.gift,
    required this.imageBuilder,
  });

  static const _giftColor = Color(0xFFC77800);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            CartSummaryGroup._giftArrow,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
              color: _giftColor,
              height: 1.1,
            ),
          ),
          const SizedBox(width: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageBuilder(gift.product.imageUrl, 36),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gift.product.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _giftColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'هدية × ${gift.quantity}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _giftColor.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '0.00 \u{20C1}',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: _giftColor.withValues(alpha: 0.85),
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }
}

class CartSummaryBundleGroup extends StatelessWidget {
  final CartBundleLine line;
  final bool tableLayout;

  const CartSummaryBundleGroup({
    super.key,
    required this.line,
    this.tableLayout = false,
  });

  @override
  Widget build(BuildContext context) {
    final bundle = line.bundle;
    if (!tableLayout) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SimpleSummaryLine(
              name: bundle.name,
              quantity: line.quantity,
              amount: line.totalPrice,
            ),
            for (final item in bundle.items) ...[
              const SizedBox(height: 4),
              _BundleChildLine(
                name: item.product.name,
                quantity: item.quantity * line.quantity,
              ),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TableRow(
            name: bundle.name,
            unitPrice: bundle.bundlePrice,
            quantity: line.quantity,
            lineTotal: line.totalPrice,
          ),
          for (final item in bundle.items) ...[
            const SizedBox(height: 4),
            _BundleChildTableRow(
              name: item.product.name,
              quantity: item.quantity * line.quantity,
            ),
          ],
        ],
      ),
    );
  }
}

class _BundleChildLine extends StatelessWidget {
  final String name;
  final int quantity;

  const _BundleChildLine({required this.name, required this.quantity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Text(
        '${CartSummaryGroup._giftArrow} $name × $quantity',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.mutedText,
        ),
      ),
    );
  }
}

class _BundleChildTableRow extends StatelessWidget {
  final String name;
  final int quantity;

  const _BundleChildTableRow({required this.name, required this.quantity});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 12,
      color: AppTheme.mutedText,
      height: 1.2,
    );

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            '${CartSummaryGroup._giftArrow} $name',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        const Expanded(child: SizedBox()),
        Expanded(
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: style,
          ),
        ),
        const Expanded(child: SizedBox()),
      ],
    );
  }
}
