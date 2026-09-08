import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RecentSearchItem {
  final String query;
  final String? productId;
  final String? imageUrl;

  const RecentSearchItem({
    required this.query,
    this.productId,
    this.imageUrl,
  });

  String get key => (productId ?? query).trim().toLowerCase();

  bool get hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  RecentSearchItem copyWith({
    String? query,
    String? productId,
    String? imageUrl,
  }) {
    return RecentSearchItem(
      query: query ?? this.query,
      productId: productId ?? this.productId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'query': query,
        if (productId != null) 'productId': productId,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

  factory RecentSearchItem.fromJson(Map<String, dynamic> json) {
    return RecentSearchItem(
      query: (json['query'] ?? json['name'] ?? '').toString(),
      productId: json['productId']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
    );
  }
}

class SearchHistoryStore {
  SearchHistoryStore._();

  static const _key = 'search_recents';
  static const maxItems = 10;

  static Future<List<RecentSearchItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key);
    if (rawList == null || rawList.isEmpty) return <RecentSearchItem>[];

    final items = <RecentSearchItem>[];
    for (final raw in rawList) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith('{')) {
        try {
          final json = jsonDecode(trimmed);
          if (json is Map<String, dynamic>) {
            final item = RecentSearchItem.fromJson(json);
            if (item.query.isNotEmpty) items.add(item);
            continue;
          }
        } catch (_) {}
      }
      items.add(RecentSearchItem(query: trimmed));
    }
    return items;
  }

  static Future<List<RecentSearchItem>> add(String query) {
    return addItem(RecentSearchItem(query: query.trim()));
  }

  static Future<List<RecentSearchItem>> addItem(RecentSearchItem item) async {
    final q = item.query.trim();
    if (q.isEmpty) return load();

    final current = List<RecentSearchItem>.of(await load());
    current.removeWhere((existing) {
      if (item.productId != null && existing.productId == item.productId) {
        return true;
      }
      return existing.query.toLowerCase() == q.toLowerCase();
    });
    current.insert(0, item.copyWith(query: q));
    return _save(current.take(maxItems).toList());
  }

  static Future<List<RecentSearchItem>> remove(RecentSearchItem item) async {
    final current = List<RecentSearchItem>.of(await load());
    current.removeWhere((existing) {
      if (item.productId != null && existing.productId == item.productId) {
        return true;
      }
      return existing.query == item.query;
    });
    return _save(current);
  }

  static Future<List<RecentSearchItem>> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    return <RecentSearchItem>[];
  }

  static Future<List<RecentSearchItem>> _save(List<RecentSearchItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      items.map((item) => jsonEncode(item.toJson())).toList(),
    );
    return items;
  }
}
