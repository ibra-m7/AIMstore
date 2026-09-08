part of 'cart_cubit.dart';

class CartState extends Equatable {
  final List<CartItem> items;
  final List<CartBundleLine> bundles;
  final List<String> displayOrder;
  final String? lastAddedProductName;

  const CartState({
    this.items = const [],
    this.bundles = const [],
    this.displayOrder = const [],
    this.lastAddedProductName,
  });

  List<CartDisplayEntry> get displayEntries => buildCartDisplayEntries(
        bundles: bundles,
        items: items,
        displayOrder: displayOrder,
      );

  int get count =>
      bundles.length +
      items.where((item) => !item.isGift && item.isStandalone).length;

  int get distinctCount => count;

  int get totalQuantity {
    final bundleQty = bundles.fold<int>(0, (sum, line) => sum + line.quantity);
    final productQty = items
        .where((item) => !item.isGift && item.isStandalone)
        .fold<int>(0, (sum, i) => sum + i.quantity);
    return bundleQty + productQty;
  }

  double get total {
    final bundleTotal =
        bundles.fold<double>(0, (sum, line) => sum + line.totalPrice);
    final productTotal = items
        .where((item) => !item.isGift && item.isStandalone)
        .fold<double>(0, (sum, i) => sum + i.totalPrice);
    return bundleTotal + productTotal;
  }

  bool get isEmpty => items.isEmpty && bundles.isEmpty;
  bool get isNotEmpty => !isEmpty;

  CartState copyWith({
    List<CartItem>? items,
    List<CartBundleLine>? bundles,
    List<String>? displayOrder,
    String? lastAddedProductName,
    bool clearNotification = false,
  }) {
    return CartState(
      items: items ?? this.items,
      bundles: bundles ?? this.bundles,
      displayOrder: displayOrder ?? this.displayOrder,
      lastAddedProductName: clearNotification
          ? null
          : (lastAddedProductName ?? this.lastAddedProductName),
    );
  }

  @override
  List<Object?> get props => [items, bundles, displayOrder, lastAddedProductName];
}
