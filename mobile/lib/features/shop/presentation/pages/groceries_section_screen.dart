import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/models/category_model.dart';
import '../../data/models/home_feed.dart';
import '../../data/models/product_model.dart';
import '../manager/cart_cubit.dart';
import '../manager/catalog_cubit.dart';
import '../widgets/product_card.dart';
import '../widgets/product_card_shimmer.dart';
import '../widgets/cart_sheet.dart';
import '../widgets/product_preview_sheet.dart';

/// وسيط المسار — منتجات قسم فرعي.
class GroceriesSubcategoryProductsArgs {
  final String sectionTitle;
  final String categoryId;

  const GroceriesSubcategoryProductsArgs({
    required this.sectionTitle,
    required this.categoryId,
  });
}

/// عنصر فرعي في أقسام العرض (صورة + تسمية).
class GroceriesSubcategoryItem {
  final String label;
  final String imageUrl;
  final String categoryId;

  const GroceriesSubcategoryItem({
    required this.label,
    required this.imageUrl,
    required this.categoryId,
  });

  factory GroceriesSubcategoryItem.fromCategory(CategoryModel category) {
    return GroceriesSubcategoryItem(
      label: category.name,
      imageUrl: category.displayImage,
      categoryId: category.id,
    );
  }
}

/// وسيط مسار تصفّح قسم مع تبويبات وتصنيف شرائح.
class CategorySubcategoriesBrowseArgs {
  final String sectionId;
  final String? initialCategoryId;
  final String appBarTitle;
  final List<GroceriesSubcategoryItem> items;

  const CategorySubcategoriesBrowseArgs({
    required this.sectionId,
    this.initialCategoryId,
    required this.appBarTitle,
    this.items = const [],
  });
}

/// شاشة القسم: تبويبات أعلى + شرائح تصفية + شبكة منتجات.
class CategorySubcategoriesBrowseScreen extends StatefulWidget {
  static const routeName = '/category-subcategories-browse';

  final CategorySubcategoriesBrowseArgs args;

  const CategorySubcategoriesBrowseScreen({super.key, required this.args});

  @override
  State<CategorySubcategoriesBrowseScreen> createState() =>
      _CategorySubcategoriesBrowseScreenState();
}

class _CategorySubcategoriesBrowseScreenState
    extends State<CategorySubcategoriesBrowseScreen> {
  static const _accent = Color(0xFF2E9B57);

  late String? _tabId;
  String? _chipId;
  PageController? _pageController;
  final _tabsScrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabId = widget.args.initialCategoryId;
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _tabsScrollCtrl.dispose();
    super.dispose();
  }

  DisplaySectionModel? _sectionOf(CatalogState catalog) {
    for (final section in catalog.displaySections) {
      if (section.id == widget.args.sectionId) return section;
    }
    return catalog.displayBySlug(widget.args.sectionId);
  }

  List<CategoryModel> _tabs(DisplaySectionModel? section) {
    if (section != null && section.categories.isNotEmpty) {
      return section.categories;
    }
    return widget.args.items
        .map(
          (item) => CategoryModel(
            id: item.categoryId,
            name: item.label,
            iconUrl: item.imageUrl,
            imageUrl: item.imageUrl,
          ),
        )
        .toList();
  }

  CategoryModel? _tabOf(List<CategoryModel> tabs) {
    if (tabs.isEmpty) return null;
    for (final tab in tabs) {
      if (tab.id == _tabId) return tab;
    }
    return tabs.first;
  }

  int _indexOfTab(List<CategoryModel> tabs, String? id) {
    if (id == null) return 0;
    final i = tabs.indexWhere((t) => t.id == id);
    return i < 0 ? 0 : i;
  }

  void _ensurePageController(List<CategoryModel> tabs) {
    final initial = _indexOfTab(tabs, _tabId ?? widget.args.initialCategoryId);
    if (_pageController == null) {
      _pageController = PageController(initialPage: initial);
      return;
    }
  }

  void _selectTab(List<CategoryModel> tabs, String id, {bool animate = true}) {
    final index = _indexOfTab(tabs, id);
    setState(() {
      _tabId = id;
      _chipId = null;
    });
    final ctrl = _pageController;
    if (ctrl == null || !ctrl.hasClients) return;
    if (animate) {
      ctrl.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      ctrl.jumpToPage(index);
    }
  }

  void _openSearch() {
    Navigator.of(context).pushNamed(AppRouter.search);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<CatalogCubit, CatalogState>(
        builder: (context, catalog) {
          final section = _sectionOf(catalog);
          final tabs = _tabs(section);
          _ensurePageController(tabs);
          final tab = _tabOf(tabs);
          final chips = tab?.children ?? const <CategoryModel>[];
          final title = section?.name ?? widget.args.appBarTitle;
          final heading = () {
            if (_chipId != null) {
              for (final c in chips) {
                if (c.id == _chipId) return c.name;
              }
            }
            return tab?.name;
          }();

          return Scaffold(
            backgroundColor: AppTheme.background,
            appBar: AppBar(
              backgroundColor: AppTheme.background,
              foregroundColor: AppTheme.darkText,
              elevation: 0,
              centerTitle: true,
              title: Text(
                title,
                style: AppTextStyles.appBarTitle.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'بحث',
                  onPressed: _openSearch,
                  icon: const Icon(Icons.search_rounded),
                ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CategoryTabs(
                  tabs: tabs,
                  selectedId: tab?.id,
                  scrollController: _tabsScrollCtrl,
                  onSelect: (id) => _selectTab(tabs, id),
                ),
                if (chips.isNotEmpty)
                  _SubcategoryChips(
                    chips: chips,
                    selectedId: _chipId,
                    onSelect: (id) => setState(() => _chipId = id),
                  ),
                if (heading != null && heading.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                    child: Text(
                      heading,
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: _accent,
                        height: 1.25,
                      ),
                    ),
                  ),
                Expanded(
                  child: tabs.isEmpty
                      ? Center(
                          child: Text(
                            catalog.loading
                                ? ''
                                : AppStrings.homeNoProductsInCategory,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppTheme.mutedText),
                          ),
                        )
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: tabs.length,
                          onPageChanged: (index) {
                            if (index < 0 || index >= tabs.length) return;
                            setState(() {
                              _tabId = tabs[index].id;
                              _chipId = null;
                            });
                          },
                          itemBuilder: (context, index) {
                            final pageTab = tabs[index];
                            final isCurrent = pageTab.id == tab?.id;
                            final filterId = isCurrent
                                ? (_chipId ?? pageTab.id)
                                : pageTab.id;
                            final products =
                                catalog.productsForCategory(filterId);
                            if (products.isEmpty) {
                              return catalog.loading
                                  ? const ProductShimmerGrid()
                                  : Center(
                                      child: Text(
                                        AppStrings.homeNoProductsInCategory,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: AppTheme.mutedText,
                                        ),
                                      ),
                                    );
                            }
                            return GridView.builder(
                              key: PageStorageKey<String>(
                                'section_grid_${pageTab.id}_$filterId',
                              ),
                              padding:
                                  const EdgeInsets.fromLTRB(16, 0, 16, 88),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 0.56,
                              ),
                              itemCount: products.length,
                              itemBuilder: (context, i) {
                                final p = products[i];
                                return ProductCard(
                                  product: p,
                                  heroTag:
                                      'section_${filterId}_${p.id}_$i',
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
            bottomNavigationBar: const _MiniCartBar(),
          );
        },
      ),
    );
  }
}

class _CategoryTabs extends StatefulWidget {
  final List<CategoryModel> tabs;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final ScrollController? scrollController;

  const _CategoryTabs({
    required this.tabs,
    required this.selectedId,
    required this.onSelect,
    this.scrollController,
  });

  @override
  State<_CategoryTabs> createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<_CategoryTabs> {
  final Map<String, GlobalKey> _itemKeys = {};

  GlobalKey _keyFor(String id) =>
      _itemKeys.putIfAbsent(id, GlobalKey.new);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(covariant _CategoryTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedId != widget.selectedId) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  void _scrollToSelected() {
    final id = widget.selectedId;
    if (id == null) return;
    final ctx = _keyFor(id).currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        controller: widget.scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: widget.tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 4),
        itemBuilder: (context, i) {
          final tab = widget.tabs[i];
          final selected = tab.id == widget.selectedId;
          return KeyedSubtree(
            key: _keyFor(tab.id),
            child: GestureDetector(
              onTap: () => widget.onSelect(tab.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected
                          ? const Color(0xFF2E9B57)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tab.name,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? const Color(0xFF2E9B57)
                        : AppTheme.mutedText,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SubcategoryChips extends StatelessWidget {
  final List<CategoryModel> chips;
  final String? selectedId;
  final ValueChanged<String?> onSelect;

  const _SubcategoryChips({
    required this.chips,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final items = <({String? id, String label})>[
      (id: null, label: 'الكل'),
      ...chips.map((c) => (id: c.id, label: c.name)),
    ];
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(14, 2, 14, 2),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final item = items[i];
          final selected = selectedId == item.id;
          const green = Color(0xFF2E9B57);
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelect(item.id),
              borderRadius: BorderRadius.circular(8),
              splashColor: green.withValues(alpha: 0.10),
              highlightColor: Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                decoration: BoxDecoration(
                  color: selected ? null : Colors.white,
                  gradient: selected
                      ? LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white,
                            green.withValues(alpha: 0.06),
                            green.withValues(alpha: 0.20),
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected
                        ? green.withValues(alpha: 0.50)
                        : const Color(0xFFE8F0EA),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11,
                    height: 1.15,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? green : AppTheme.darkText,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MiniCartBar extends StatelessWidget {
  const _MiniCartBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cart) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Material(
              color: const Color(0xFF3A3A3A),
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: () => showCartSheet(context),
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        '${cart.total.toStringAsFixed(2)} ${AppStrings.currency}',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.shopping_bag_outlined,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'عرض السلة',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// قائمة منتجات قسم فرعي ضمن المقاضي.
class GroceriesSubcategoryProductsScreen extends StatelessWidget {
  static const routeName = '/groceries-subcategory-products';

  final GroceriesSubcategoryProductsArgs args;

  const GroceriesSubcategoryProductsScreen({super.key, required this.args});

  void _openProduct(BuildContext context, ProductModel product) {
    showProductPreview(context, product);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogCubit>().state;
    final products = catalog.productsForCategory(args.categoryId);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(args.sectionTitle)),
      body: products.isEmpty
          ? catalog.loading
              ? const ProductShimmerGrid()
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      AppStrings.homeNoProductsInCategory,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppTheme.mutedText),
                    ),
                  ),
                )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final p = products[index];
                return Material(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _openProduct(context, p),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AppNetworkImage(
                              p.imageUrl,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              error: Container(
                                width: 72,
                                height: 72,
                                color: AppTheme.primarySurface,
                                child: const Icon(
                                  Icons.inventory_2_outlined,
                                  color: AppTheme.mutedText,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.darkText,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    '${p.effectivePrice.toStringAsFixed(2)} ${AppStrings.currency}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.primary,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppTheme.mutedText,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// شاشة «عرض الكل» لقسم المقاضي — تُفتح عبر [AppRouter.groceriesSection].
class GroceriesSectionScreen extends StatelessWidget {
  static const routeName = '/groceries-section';

  const GroceriesSectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogCubit>().state;
    final section = catalog.displayBySlug('groceries');
    final items = (section?.categories ?? const [])
        .map(GroceriesSubcategoryItem.fromCategory)
        .toList();

    return CategorySubcategoriesBrowseScreen(
      args: CategorySubcategoriesBrowseArgs(
        sectionId: section?.id ?? 'groceries',
        appBarTitle: section?.name ?? AppStrings.categoriesGroceriesSection,
        items: items,
      ),
    );
  }
}

/// مربع موحّد + صورة + تسمية — حجم الكارد ثابت مهما اختلفت أبعاد الصورة.
class GroceriesCategoryCircleTile extends StatelessWidget {
  final String label;
  final String imageUrl;
  final VoidCallback? onTap;

  const GroceriesCategoryCircleTile({
    super.key,
    required this.label,
    required this.imageUrl,
    this.onTap,
  });

  static const _radius = 18.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_radius),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryLight,
                      AppTheme.primarySurface,
                      const Color(0xFFFAFEFC),
                    ],
                    stops: const [0.0, 0.42, 1.0],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;
                      return AppNetworkImage(
                        imageUrl,
                        width: w,
                        height: h,
                        fit: BoxFit.contain,
                        placeholder: SizedBox(
                          width: w,
                          height: h,
                          child: Shimmer.fromColors(
                            baseColor: AppTheme.primarySurface,
                            highlightColor: const Color(0xFFF5FFF9),
                            child: const ColoredBox(color: Colors.white),
                          ),
                        ),
                        error: SizedBox(width: w, height: h),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 28,
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkText,
                    height: 1.2,
                    fontSize: 11,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
