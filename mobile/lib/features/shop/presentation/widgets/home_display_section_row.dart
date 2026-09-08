import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';
import '../../data/models/home_feed.dart';
import '../pages/groceries_section_screen.dart';
import 'section_title_row.dart';

/// قسم رئيسي في الرئيسية — عنوان قابل للضغط + أفقي للتصنيفات (نمط أفضل العروض).
class HomeDisplaySectionRow extends StatelessWidget {
  final DisplaySectionModel section;
  final EdgeInsetsGeometry titlePadding;

  const HomeDisplaySectionRow({
    super.key,
    required this.section,
    this.titlePadding = const EdgeInsets.fromLTRB(16, 18, 16, 12),
  });

  List<GroceriesSubcategoryItem> get _items => section.categories
      .map(GroceriesSubcategoryItem.fromCategory)
      .toList();

  void _openBrowse(BuildContext context, {String? categoryId}) {
    final items = _items;
    if (items.isEmpty) return;
    Navigator.of(context).pushNamed(
      AppRouter.categorySubcategoriesBrowse,
      arguments: CategorySubcategoriesBrowseArgs(
        sectionId: section.id,
        initialCategoryId: categoryId,
        appBarTitle: section.name,
        items: items,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items.isEmpty) return const SizedBox.shrink();

    final visible = items.length > 8 ? items.take(8).toList() : items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitleRow(
          title: section.name,
          emoji: section.emoji,
          padding: titlePadding,
          showViewAllLabel: true,
          onTap: () => _openBrowse(context),
        ),
        SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            itemCount: visible.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final item = visible[i];
              return SizedBox(
                width: 88,
                child: GroceriesCategoryCircleTile(
                  label: item.label,
                  imageUrl: item.imageUrl,
                  onTap: () => _openBrowse(context, categoryId: item.categoryId),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
