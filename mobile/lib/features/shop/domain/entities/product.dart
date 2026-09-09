import 'package:equatable/equatable.dart';

import 'product_gift_summary.dart';
import 'product_promo_type.dart';

class Product extends Equatable {
  // ── الحقول الأساسية ────────────────────────────────────────────────────
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final ProductPromoType promoType;
  final int discountPercent;
  final String imageUrl;
  final List<String> imageUrls;
  final String categoryId;
  final int stock;
  final int? pieceCount;
  final String quantityLabel;
  final int soldCount;
  final double rating;
  final int reviewCount;

  // ── حقول الذكاء الاصطناعي ─────────────────────────────────────────────
  /// فوائد المنتج — يستخدمها Gemini لصياغة ردود مقنعة
  final List<String> benefits;

  /// كلمات دلالية للبحث الطبيعي والـ Function Calling
  final List<String> keywords;

  /// طريقة الاستخدام — يشرحها المساعد عند الطلب
  final String usageInstructions;

  /// موقع داخل المحل (ممر / رف / ملاحظة) — للمساعد كدليل ماركت.
  final String storeAisle;
  final String storeShelf;
  final String storeLocationNote;

  /// منتج هدية يُضاف مجاناً عند شراء هذا المنتج.
  final ProductGiftSummary? giftProduct;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    this.promoType = ProductPromoType.none,
    this.discountPercent = 0,
    required this.imageUrl,
    this.imageUrls = const [],
    required this.categoryId,
    required this.stock,
    this.pieceCount,
    this.quantityLabel = '',
    this.soldCount = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.benefits = const [],
    this.keywords = const [],
    this.usageInstructions = '',
    this.storeAisle = '',
    this.storeShelf = '',
    this.storeLocationNote = '',
    this.giftProduct,
  });

  static String fallbackImageUrl = '';

  String get displayImage {
    final url = imageUrl.trim();
    if (url.isNotEmpty) return url;
    return fallbackImageUrl;
  }

  List<String> get displayImages {
    final urls = [
      ...imageUrls.where((url) => url.trim().isNotEmpty),
    ];
    if (imageUrl.trim().isNotEmpty && !urls.contains(imageUrl)) {
      urls.insert(0, imageUrl);
    }
    if (urls.isEmpty && fallbackImageUrl.isNotEmpty) {
      return [fallbackImageUrl];
    }
    return urls;
  }

  bool get isAvailable => stock > 0;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  bool get isDiscountPromo =>
      hasDiscount && promoType != ProductPromoType.offer;
  bool get isOfferPromo => hasDiscount && promoType == ProductPromoType.offer;
  bool get hasGiftProduct => giftProduct != null && giftProduct!.isAvailable;
  double get effectivePrice => discountPrice ?? price;
  String? get promoBadgeLabel =>
      promoType.badgeLabel(hasDiscount: hasDiscount, discountPercent: discountPercent);

  /// العدد الظاهر: 1 افتراضياً، أو الرقم من لوحة التحكم إن وُجد.
  int get displayPieceCount {
    final count = pieceCount ?? 0;
    return count > 0 ? count : 1;
  }

  bool get hasPackPieces => true;

  /// شارة فوق السعر وبجانب سعر البطاقة: «العدد 1» أو «العدد 4».
  String get packDisplayLabel => 'العدد $displayPieceCount';

  double get discountPercentage => discountPercent > 0
      ? discountPercent.toDouble()
      : (hasDiscount
          ? ((price - discountPrice!) / price * 100).roundToDouble()
          : 0);

  String get soldLabel {
    if (soldCount <= 0) return '';
    if (soldCount >= 1000) {
      final k = soldCount / 1000;
      final text = k == k.roundToDouble()
          ? k.toInt().toString()
          : k.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
      return 'اشتراه +${text}K عميل';
    }
    return 'اشتراه +$soldCount عميل';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        discountPrice,
        promoType,
        discountPercent,
        categoryId,
        stock,
        pieceCount,
        quantityLabel,
        soldCount,
        rating,
        benefits,
        keywords,
        storeAisle,
        storeShelf,
        storeLocationNote,
        giftProduct,
      ];
}
