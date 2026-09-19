import 'category_model.dart';
import 'product_model.dart';

class BundleItemModel {
  final ProductModel product;
  final int quantity;

  const BundleItemModel({
    required this.product,
    this.quantity = 1,
  });

  factory BundleItemModel.fromJson(Map<String, dynamic> json) {
    final productRaw = json['product'];
    return BundleItemModel(
      product: productRaw is Map
          ? ProductModel.fromJson(Map<String, dynamic>.from(productRaw))
          : const ProductModel(
              id: '',
              name: '',
              description: '',
              price: 0,
              imageUrl: '',
              categoryId: '',
              stock: 0,
            ),
      quantity: (json['quantity'] as num?)?.toInt().clamp(1, 99) ?? 1,
    );
  }
}

class BundleModel {
  final String id;
  final String name;
  final String? summary;
  final String? description;
  final String? imageUrl;
  final List<String> apiPreviewUrls;
  final double discountPercent;
  final double bundlePrice;
  final double originalPrice;
  final int itemCount;
  final bool isAvailable;
  final List<BundleItemModel> items;

  const BundleModel({
    required this.id,
    required this.name,
    this.summary,
    this.description,
    this.imageUrl,
    this.apiPreviewUrls = const [],
    this.discountPercent = 0,
    required this.bundlePrice,
    required this.originalPrice,
    this.itemCount = 0,
    this.isAvailable = true,
    this.items = const [],
  });

  bool get hasDiscount =>
      discountPercent > 0 && originalPrice > bundlePrice;

  int get displayDiscountPercent {
    if (discountPercent > 0) return discountPercent.round();
    if (originalPrice <= 0 || bundlePrice >= originalPrice) return 0;
    return ((1 - bundlePrice / originalPrice) * 100).round();
  }

  List<String> get productPreviewUrls {
    final seen = <String>{};
    final urls = <String>[];
    for (final item in items) {
      if (item.product.id.isEmpty) continue;
      final url = item.product.displayImage.trim();
      if (url.isEmpty || !seen.add(url)) continue;
      urls.add(url);
      if (urls.length >= 3) break;
    }
    return urls;
  }

  List<String> get previewImageUrls {
    final cover = imageUrl?.trim() ?? '';
    if (cover.isNotEmpty) return [cover];
    if (apiPreviewUrls.isNotEmpty) return apiPreviewUrls;
    return productPreviewUrls;
  }

  String get flyImageUrl {
    final urls = previewImageUrls;
    if (urls.isNotEmpty) return urls.first;
    return items.isNotEmpty ? items.first.product.displayImage : '';
  }

  factory BundleModel.fromJson(Map<String, dynamic> json) {
    return BundleModel(
      id: '${json['id']}',
      name: (json['name'] as String?) ?? '',
      summary: json['summary'] as String?,
      description: json['description'] as String?,
      imageUrl: (json['image_url'] as String?)?.trim(),
      apiPreviewUrls: _stringList(json['preview_image_urls']),
      discountPercent: (json['discount_percent'] as num?)?.toDouble() ?? 0,
      bundlePrice: (json['bundle_price'] as num?)?.toDouble() ?? 0,
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? 0,
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
      isAvailable: json['is_available'] != false,
      items: jsonMapList(json['items'], BundleItemModel.fromJson)
          .where((item) => item.product.id.isNotEmpty)
          .toList(),
    );
  }
}

List<String> _stringList(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map((item) => item?.toString().trim() ?? '')
      .where((url) => url.isNotEmpty)
      .toList();
}
