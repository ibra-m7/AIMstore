import '../../domain/entities/cart_bundle_line.dart';
import '../../domain/entities/cart_item.dart';

/// عنصر عرض في قائمة السلة — سلة توفير أو منتج مستقل.
sealed class CartDisplayEntry {
  const CartDisplayEntry();
}

class CartDisplayBundleEntry extends CartDisplayEntry {
  final CartBundleLine line;

  const CartDisplayBundleEntry(this.line);
}

class CartDisplayProductEntry extends CartDisplayEntry {
  final CartItem item;
  final List<CartItem> giftItems;

  const CartDisplayProductEntry({
    required this.item,
    this.giftItems = const [],
  });
}

List<CartDisplayEntry> buildCartDisplayEntries({
  required List<CartBundleLine> bundles,
  required List<CartItem> items,
  required List<String> displayOrder,
}) {
  final bundleById = {for (final b in bundles) b.id: b};
  final paidItems = items.where((i) => !i.isGift && i.isStandalone).toList();
  final paidById = {for (final p in paidItems) p.product.id: p};
  final usedBundles = <String>{};
  final usedProducts = <String>{};
  final entries = <CartDisplayEntry>[];

  void addBundle(CartBundleLine line) {
    if (usedBundles.add(line.id)) {
      entries.add(CartDisplayBundleEntry(line));
    }
  }

  void addProduct(CartItem item) {
    if (usedProducts.add(item.product.id)) {
      entries.add(
        CartDisplayProductEntry(
          item: item,
          giftItems: items
              .where(
                (g) => g.isGift && g.giftForProductId == item.product.id,
              )
              .toList(),
        ),
      );
    }
  }

  for (final key in displayOrder) {
    if (key.startsWith('bundle:')) {
      final id = key.substring('bundle:'.length);
      final line = bundleById[id];
      if (line != null) addBundle(line);
    } else if (key.startsWith('product:')) {
      final id = key.substring('product:'.length);
      final item = paidById[id];
      if (item != null) addProduct(item);
    }
  }

  for (final line in bundles) {
    addBundle(line);
  }
  for (final item in paidItems) {
    addProduct(item);
  }

  return entries;
}

List<CartItem> standalonePaidItems(List<CartItem> items) =>
    items.where((item) => !item.isGift && item.isStandalone).toList();

List<CartItem> giftItemsFor(List<CartItem> items, String parentId) => items
    .where((item) => item.isGift && item.giftForProductId == parentId)
    .toList();

List<String> allCartProductIds({
  required List<CartBundleLine> bundles,
  required List<CartItem> items,
}) {
  final ids = <String>{};
  for (final line in bundles) {
    for (final item in line.bundle.items) {
      ids.add(item.product.id);
    }
  }
  for (final item in items.where((i) => !i.isGift)) {
    ids.add(item.product.id);
  }
  return ids.toList()..sort();
}
