import 'package:equatable/equatable.dart';
import 'product.dart';

class CartItem extends Equatable {
  final Product product;
  final int quantity;
  final bool isGift;
  final String? giftForProductId;
  final String? bundleLineId;
  final bool isBundleChild;

  const CartItem({
    required this.product,
    this.quantity = 1,
    this.isGift = false,
    this.giftForProductId,
    this.bundleLineId,
    this.isBundleChild = false,
  });

  bool get isStandalone =>
      !isGift && !isBundleChild && bundleLineId == null;

  String get cartKey {
    if (isBundleChild && bundleLineId != null) {
      if (isGift) {
        return 'bundle:$bundleLineId:gift:${giftForProductId ?? product.id}';
      }
      return 'bundle:$bundleLineId:paid:${product.id}';
    }
    if (isGift) return 'gift:${giftForProductId ?? product.id}';
    return 'paid:${product.id}';
  }

  double get totalPrice =>
      isGift ? 0 : product.effectivePrice * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
    bool? isGift,
    String? giftForProductId,
    String? bundleLineId,
    bool? isBundleChild,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      isGift: isGift ?? this.isGift,
      giftForProductId: giftForProductId ?? this.giftForProductId,
      bundleLineId: bundleLineId ?? this.bundleLineId,
      isBundleChild: isBundleChild ?? this.isBundleChild,
    );
  }

  @override
  List<Object?> get props => [cartKey, quantity, product.id];
}
