import '../../domain/entities/cart_bundle_line.dart';
import '../../domain/entities/cart_item.dart';
List<CartItem> paidCartItems(List<CartItem> items) =>
    items.where((item) => !item.isGift && item.isStandalone).toList();

CartItem? giftCartItemFor(List<CartItem> items, String parentProductId) {
  for (final item in items) {
    if (item.isGift && item.giftForProductId == parentProductId) {
      return item;
    }
  }
  return null;
}

List<({CartItem paid, CartItem? gift})> groupedCartItems(List<CartItem> items) {
  final paidItems = paidCartItems(items);
  final gifts = items.where((item) => item.isGift && item.isStandalone).toList();
  final linkedGiftIds = <String>{};

  final groups = paidItems.map((paid) {
    CartItem? gift = giftCartItemFor(items, paid.product.id);
    if (gift != null) {
      linkedGiftIds.add(gift.product.id);
    }
    return (paid: paid, gift: gift);
  }).toList();

  if (gifts.length == 1 &&
      paidItems.length == 1 &&
      groups.first.gift == null) {
    return [(paid: paidItems.first, gift: gifts.first)];
  }

  return groups;
}

int paidCartProductCount({
  required List<CartItem> items,
  List<CartBundleLine> bundles = const [],
}) =>
    bundles.length + paidCartItems(items).length;

int paidCartQuantity({
  required List<CartItem> items,
  List<CartBundleLine> bundles = const [],
}) {
  final bundleQty = bundles.fold<int>(0, (sum, line) => sum + line.quantity);
  final productQty =
      paidCartItems(items).fold<int>(0, (sum, item) => sum + item.quantity);
  return bundleQty + productQty;
}

double cartListSubtotal({
  required List<CartItem> items,
  List<CartBundleLine> bundles = const [],
}) {
  final bundleTotal = bundles.fold<double>(
    0,
    (sum, line) => sum + line.bundle.originalPrice * line.quantity,
  );
  final productTotal = paidCartItems(items).fold<double>(
    0,
    (sum, item) => sum + item.product.price * item.quantity,
  );
  return bundleTotal + productTotal;
}

double cartProductDiscount({
  required List<CartItem> items,
  List<CartBundleLine> bundles = const [],
}) {
  final bundleDiscount = bundles.fold<double>(
    0,
    (sum, line) =>
        sum +
        (line.bundle.originalPrice - line.bundle.bundlePrice) * line.quantity,
  );
  final productDiscount = paidCartItems(items).fold<double>(
    0,
    (sum, item) {
      if (!item.product.hasDiscount) return sum;
      return sum +
          (item.product.price - item.product.effectivePrice) * item.quantity;
    },
  );
  return bundleDiscount + productDiscount;
}

String cartStateKey({
  required List<CartItem> items,
  required List<CartBundleLine> bundles,
}) {
  final bundlePart = bundles
      .map((line) => '${line.bundle.id}:${line.quantity}')
      .join(',');
  final productPart = paidCartItems(items)
      .map((item) => '${item.product.id}:${item.quantity}')
      .join(',');
  return '$bundlePart#$productPart';
}

List<CartItem> cartItemsForCouponApi({
  required List<CartItem> items,
  required List<CartBundleLine> bundles,
}) {
  final payload = <CartItem>[];
  for (final line in bundles) {
    for (final bundleItem in line.bundle.items) {
      payload.add(
        CartItem(
          product: bundleItem.product,
          quantity: bundleItem.quantity * line.quantity,
        ),
      );
    }
  }
  payload.addAll(paidCartItems(items));
  return payload;
}
