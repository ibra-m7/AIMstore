import 'category_model.dart';
import 'product_model.dart';

class DynamicPageModel {
  static const placementNone = 'none';
  static const placementSearchBest = 'search_best_offers';
  static const placementSearchLegendary = 'search_legendary';

  final String id;
  final String title;
  final bool showTitle;
  final String bannerImageUrl;
  final String appBarImageUrl;
  final String placement;
  final List<ProductModel> products;

  const DynamicPageModel({
    required this.id,
    required this.title,
    this.showTitle = false,
    this.bannerImageUrl = '',
    this.appBarImageUrl = '',
    this.placement = placementNone,
    this.products = const [],
  });

  String get headerImage {
    final appBar = appBarImageUrl.trim();
    if (appBar.isNotEmpty) return appBar;
    return bannerImageUrl.trim();
  }

  factory DynamicPageModel.fromJson(Map<String, dynamic> json) {
    return DynamicPageModel(
      id: '${json['id']}',
      title: (json['title'] as String?) ?? '',
      showTitle: json['show_title'] == true,
      bannerImageUrl: (json['banner_image_url'] as String?) ?? '',
      appBarImageUrl: (json['appbar_image_url'] as String?) ?? '',
      placement: (json['placement'] as String?) ?? placementNone,
      products: jsonMapList(json['products'], ProductModel.fromJson),
    );
  }
}
