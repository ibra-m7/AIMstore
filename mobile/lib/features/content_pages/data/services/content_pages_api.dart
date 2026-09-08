import '../../../../core/network/api_client.dart';

class ContentPage {
  final int id;
  final String slug;
  final String title;
  final String buttonLabel;
  final String placement;
  final int sortOrder;
  final String? content;

  const ContentPage({
    required this.id,
    required this.slug,
    required this.title,
    required this.buttonLabel,
    required this.placement,
    required this.sortOrder,
    this.content,
  });

  factory ContentPage.fromJson(Map<String, dynamic> json) {
    return ContentPage(
      id: (json['id'] as num?)?.toInt() ?? 0,
      slug: (json['slug'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      buttonLabel: (json['button_label'] as String?) ??
          (json['title'] as String?) ??
          '',
      placement: (json['placement'] as String?) ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      content: json['content'] as String?,
    );
  }
}

abstract class ContentPagePlacement {
  static const profileFooter = 'profile_footer';
  static const profileMenu = 'profile_menu';
  static const settings = 'settings';
  static const authTerms = 'auth_terms';
}

class ContentPagesApi {
  ContentPagesApi._();
  static final ContentPagesApi instance = ContentPagesApi._();

  List<ContentPage>? _cache;

  Future<List<ContentPage>> list({
    String? placement,
    bool force = false,
  }) async {
    if (force || _cache == null) {
      try {
        final json = await ApiClient.instance.get(
          '/content-pages',
          auth: false,
        );
        final raw = json['data'];
        final pages = <ContentPage>[];
        if (raw is List) {
          for (final item in raw) {
            if (item is Map) {
              pages.add(
                ContentPage.fromJson(Map<String, dynamic>.from(item)),
              );
            }
          }
        }
        _cache = pages;
      } catch (_) {
        return const [];
      }
    }

    final all = _cache ?? const <ContentPage>[];
    if (placement == null) return List.unmodifiable(all);
    return all
        .where((page) => page.placement == placement)
        .toList(growable: false);
  }

  Future<ContentPage?> show(String slug) async {
    try {
      final json = await ApiClient.instance.get(
        '/content-pages/${Uri.encodeComponent(slug)}',
        auth: false,
      );
      final data = json['data'];
      if (data is Map) {
        return ContentPage.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (_) {}
    return null;
  }

  void clearCache() => _cache = null;
}
