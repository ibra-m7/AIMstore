import 'package:equatable/equatable.dart';

import '../../data/models/bundle_model.dart';

/// سطر سلة توفير مستقل في السلة — مع لقطة من بيانات السلة.
class CartBundleLine extends Equatable {
  final String id;
  final BundleModel bundle;
  final int quantity;

  const CartBundleLine({
    required this.id,
    required this.bundle,
    this.quantity = 1,
  });

  double get totalPrice => bundle.bundlePrice * quantity;

  CartBundleLine copyWith({
    String? id,
    BundleModel? bundle,
    int? quantity,
  }) {
    return CartBundleLine(
      id: id ?? this.id,
      bundle: bundle ?? this.bundle,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'quantity': quantity,
        'bundle': {
          'id': bundle.id,
          'name': bundle.name,
          'summary': bundle.summary,
          'description': bundle.description,
          'image_url': bundle.imageUrl,
          'discount_percent': bundle.discountPercent,
          'bundle_price': bundle.bundlePrice,
          'original_price': bundle.originalPrice,
          'item_count': bundle.itemCount,
          'is_available': bundle.isAvailable,
          'items': bundle.items
              .map(
                (item) => {
                  'quantity': item.quantity,
                  'product': item.product.toJson(),
                },
              )
              .toList(),
        },
      };

  factory CartBundleLine.fromJson(Map<String, dynamic> json) {
    final bundleRaw = json['bundle'];
    return CartBundleLine(
      id: json['id']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt().clamp(1, 99) ?? 1,
      bundle: bundleRaw is Map
          ? BundleModel.fromJson(Map<String, dynamic>.from(bundleRaw))
          : const BundleModel(
              id: '',
              name: '',
              bundlePrice: 0,
              originalPrice: 0,
            ),
    );
  }

  @override
  List<Object?> get props => [id, bundle.id, quantity];
}
