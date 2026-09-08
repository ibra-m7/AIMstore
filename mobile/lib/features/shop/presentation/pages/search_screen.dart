import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_scale.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/typing_placeholder.dart';
import '../../data/models/dynamic_page_model.dart';
import '../../data/models/product_model.dart';
import '../../data/services/search_history_store.dart';
import '../manager/catalog_cubit.dart';
import '../manager/search_cubit.dart';
import '../widgets/card_cart_control.dart';
import '../widgets/legendary_beams.dart';
import '../widgets/price_line.dart';
import '../widgets/product_card.dart';
import '../widgets/product_card_shimmer.dart';
import '../widgets/product_preview_sheet.dart';
import '../widgets/section_title_row.dart';
import 'custom_dynamic_page_screen.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';

  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _focus = FocusNode();
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<SearchCubit>();
    _ctrl = TextEditingController(text: cubit.state.query);
    cubit.hydrate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _apply(String value, {bool submit = false}) {
    _ctrl.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    if (submit) {
      final catalog = context.read<CatalogCubit>().state;
      final match = _bestMatch(catalog, value);
      final results = catalog.search(value);
      context.read<SearchCubit>().submit(
            value,
            matchedProduct: match,
            resultsCount: results.length,
          );
      _focus.unfocus();
    } else {
      context.read<SearchCubit>().setQuery(value);
    }
  }

  ProductModel? _bestMatch(CatalogState catalog, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return null;
    final exact = catalog.products.cast<ProductModel?>().firstWhere(
      (p) => p!.name.trim().toLowerCase() == q,
      orElse: () => null,
    );
    if (exact != null) return exact;
    final results = catalog.search(query);
    return results.isEmpty ? null : results.first;
  }

  void _submitFromField(String value) {
    final catalog = context.read<CatalogCubit>().state;
    final match = _bestMatch(catalog, value);
    final results = catalog.search(value);
    context.read<SearchCubit>().submit(
          value,
          matchedProduct: match,
          resultsCount: results.length,
        );
    _focus.unfocus();
  }

  List<String> _trending(CatalogState catalog) => catalog.store.trendingSearchTerms;

  List<String> _smartSuggestions(CatalogState catalog) =>
      catalog.store.smartSearchSuggestions;

  void _openRecent(RecentSearchItem item, CatalogState catalog) {
    ProductModel? product;
    if (item.productId != null && item.productId!.isNotEmpty) {
      product = catalog.productById(item.productId!);
    }
    product ??= catalog.products.cast<ProductModel?>().firstWhere(
      (p) => p!.name.trim().toLowerCase() == item.query.trim().toLowerCase(),
      orElse: () => null,
    );
    if (product != null) {
      showProductPreview(
        context,
        product,
        heroTag: 'search_recent_${product.id}',
      );
      return;
    }
    _apply(item.query, submit: true);
  }

  void _openPage(DynamicPageModel page) {
    Navigator.of(context).pushNamed(
      AppRouter.dynamicPage,
      arguments: DynamicPageArgs(pageId: page.id, initial: page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: Column(
              children: [
                _SearchTopBar(
                  controller: _ctrl,
                  focusNode: _focus,
                  phrases: context
                      .watch<CatalogCubit>()
                      .state
                      .store
                      .searchHintPhrases,
                  onChanged: (v) => context.read<SearchCubit>().setQuery(v),
                  onSubmitted: _submitFromField,
                  onClear: () {
                    _ctrl.clear();
                    context.read<SearchCubit>().clearQuery();
                    _focus.requestFocus();
                  },
                ),
                Expanded(
                  child: BlocBuilder<SearchCubit, SearchState>(
                    builder: (context, search) {
                      return BlocBuilder<CatalogCubit, CatalogState>(
                        buildWhen: (prev, next) =>
                            prev.loading != next.loading ||
                            prev.feed != next.feed,
                        builder: (context, catalog) {
                          final q = search.query.trim();
                          final catalogLoading =
                              catalog.loading && catalog.products.isEmpty;
                          final showShimmer =
                              catalogLoading || search.searching;

                          if (q.isNotEmpty) {
                            if (showShimmer) {
                              return const _SearchResultsShimmer();
                            }
                            final results = catalog.search(q);
                            if (results.isEmpty) {
                              return const _SearchEmpty();
                            }
                            return _SearchResultsGrid(
                              products: results,
                              onOpened: (product) => context
                                  .read<SearchCubit>()
                                  .rememberProduct(product),
                            );
                          }

                          if (showShimmer || !search.ready) {
                            return const _SearchDiscoverShimmer();
                          }

                          return _SearchDiscover(
                            recents: search.recents,
                            catalog: catalog,
                            trending: _trending(catalog),
                            suggestions: _smartSuggestions(catalog),
                            bestOfferPages: catalog.pagesForPlacement(
                              DynamicPageModel.placementSearchBest,
                            ),
                            legendaryPages: catalog.pagesForPlacement(
                              DynamicPageModel.placementSearchLegendary,
                            ),
                            onChip: (term) => _apply(term, submit: true),
                            onOpenRecent: _openRecent,
                            onOpenPage: _openPage,
                            onClearRecents: () =>
                                context.read<SearchCubit>().clearRecents(),
                            onRemoveRecent: (item) =>
                                context.read<SearchCubit>().removeRecent(item),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchTopBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<String> phrases;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const _SearchTopBar({
    required this.controller,
    required this.focusNode,
    required this.phrases,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hintStyle = TextStyle(
      color: AppTheme.mutedText.withValues(alpha: 0.75),
      fontWeight: FontWeight.w500,
      fontSize: 13,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 12, 10),
      child: Row(
        children: [
          IconButton(
            tooltip: 'رجوع',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppTheme.darkText,
            ),
          ),
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0x1A6B8A76), width: 0.7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.028),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  final empty = value.text.trim().isEmpty;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      TextField(
                        controller: controller,
                        focusNode: focusNode,
                        autofocus: false,
                        textInputAction: TextInputAction.search,
                        textDirection: TextDirection.rtl,
                        onChanged: onChanged,
                        onSubmitted: onSubmitted,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkText,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppTheme.primary,
                            size: 22,
                          ),
                          suffixIcon: value.text.isNotEmpty
                              ? IconButton(
                                  onPressed: onClear,
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: AppTheme.mutedText,
                                    size: 18,
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      if (empty)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.only(
                                start: 48,
                                end: 16,
                              ),
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: TypingPlaceholder(
                                  phrases: phrases.isNotEmpty
                                      ? phrases
                                      : AppStrings.homeSearchHints,
                                  style: hintStyle,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchDiscover extends StatelessWidget {
  static const _bestOfferCardWidth = 108.0;
  static const _bestOfferCardHeight = 204.0;

  final List<RecentSearchItem> recents;
  final CatalogState catalog;
  final List<String> trending;
  final List<String> suggestions;
  final List<DynamicPageModel> bestOfferPages;
  final List<DynamicPageModel> legendaryPages;
  final ValueChanged<String> onChip;
  final void Function(RecentSearchItem item, CatalogState catalog) onOpenRecent;
  final ValueChanged<DynamicPageModel> onOpenPage;
  final VoidCallback onClearRecents;
  final ValueChanged<RecentSearchItem> onRemoveRecent;

  const _SearchDiscover({
    required this.recents,
    required this.catalog,
    required this.trending,
    required this.suggestions,
    required this.bestOfferPages,
    required this.legendaryPages,
    required this.onChip,
    required this.onOpenRecent,
    required this.onOpenPage,
    required this.onClearRecents,
    required this.onRemoveRecent,
  });

  String? _recentImage(RecentSearchItem item, CatalogState catalog) {
    if (item.hasImage) return item.imageUrl;
    ProductModel? product;
    if (item.productId != null && item.productId!.isNotEmpty) {
      product = catalog.productById(item.productId!);
    }
    product ??= catalog.products.cast<ProductModel?>().firstWhere(
      (p) => p!.name.trim().toLowerCase() == item.query.trim().toLowerCase(),
      orElse: () => null,
    );
    final url = product?.displayImage.trim() ?? '';
    return url.isEmpty ? null : url;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (recents.isNotEmpty)
          SliverToBoxAdapter(
            child: _ChipSection(
              title: AppStrings.searchRecent,
              trailing: TextButton(
                onPressed: onClearRecents,
                child: const Text(
                  AppStrings.searchClearRecents,
                  style: TextStyle(
                    color: AppTheme.mutedText,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              children: [
                for (final item in recents)
                  _RecentSearchChip(
                    label: item.query,
                    imageUrl: _recentImage(item, catalog),
                    onTap: () => onOpenRecent(item, catalog),
                    onRemove: () => onRemoveRecent(item),
                  ),
              ],
            ),
          ),
        SliverToBoxAdapter(
          child: _SearchTermGridSection(
            title: AppStrings.searchTrending,
            terms: trending,
            onChip: onChip,
          ),
        ),
        SliverToBoxAdapter(
          child: _SearchTermGridSection(
            title: AppStrings.searchSuggestions,
            terms: suggestions,
            onChip: onChip,
            sectionColor: const Color(0xFFE8F0EC),
            showSearchIcon: true,
            fadeVerticalEdges: true,
            marquee: true,
          ),
        ),
        for (final page in bestOfferPages)
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                final scale = AppScale.of(context);
                final cardW = scale.s(_bestOfferCardWidth);
                final cardH = scale.s(_bestOfferCardHeight);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionTitleRow(
                      title: page.title.isNotEmpty
                          ? page.title
                          : AppStrings.searchBestOffers,
                      onTap: () => onOpenPage(page),
                    ),
                    SizedBox(
                      height: cardH + scale.s(8),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          scale.pagePad,
                          0,
                          scale.pagePad,
                          scale.s(8),
                        ),
                        itemCount: page.products.length,
                        separatorBuilder: (_, _) => SizedBox(width: scale.s(8)),
                        itemBuilder: (context, i) => SizedBox(
                          width: cardW,
                          height: cardH,
                          child: ProductCard(
                            product: page.products[i],
                            heroTag:
                                'search_offer_${page.id}_${page.products[i].id}',
                            circularCartButton: true,
                            compactFooter: true,
                            compactGiftOverlay: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        if (bestOfferPages.isNotEmpty && legendaryPages.isNotEmpty)
          const SliverToBoxAdapter(
            child: ColoredBox(
              color: AppTheme.background,
              child: SizedBox(height: 16),
            ),
          ),
        for (final page in legendaryPages)
          SliverToBoxAdapter(
            child: _LegendaryOffers(
              title: page.title.isNotEmpty
                  ? page.title
                  : AppStrings.searchLegendary,
              products: page.products,
              onOpenAll: () => onOpenPage(page),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
      ],
    );
  }
}

class _ChipSection extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final List<Widget> children;

  const _ChipSection({
    required this.title,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.darkText,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: children),
        ],
      ),
    );
  }
}

class _SearchTermGridSection extends StatelessWidget {
  final String title;
  final List<String> terms;
  final ValueChanged<String> onChip;
  final Color? sectionColor;
  final bool showSearchIcon;
  final bool fadeVerticalEdges;
  final bool marquee;

  const _SearchTermGridSection({
    required this.title,
    required this.terms,
    required this.onChip,
    this.sectionColor,
    this.showSearchIcon = false,
    this.fadeVerticalEdges = false,
    this.marquee = false,
  });

  static const double _rowH = 24;
  static const double _chipRadius = 5;
  static const double _chipFontSize = 11;

  @override
  Widget build(BuildContext context) {
    if (terms.isEmpty) return const SizedBox.shrink();

    if (marquee) {
      return _SearchTermSectionShell(
        title: title,
        sectionColor: sectionColor,
        fadeVerticalEdges: fadeVerticalEdges,
        child: _SearchTermMarqueeTrack(
          terms: terms,
          onChip: onChip,
          showSearchIcon: showSearchIcon,
          rowHeight: _rowH,
          chipRadius: _chipRadius,
        ),
      );
    }

    if (terms.length == 1) {
      return _SearchTermSectionShell(
        title: title,
        sectionColor: sectionColor,
        fadeVerticalEdges: fadeVerticalEdges,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: _SearchTermChip(
            term: terms.first,
            onTap: () => onChip(terms.first),
            showSearchIcon: showSearchIcon,
            height: _rowH,
            radius: _chipRadius,
            fontSize: _chipFontSize,
          ),
        ),
      );
    }

    // صفين بالضبط: عدد الأعمدة = نصف العناصر (تقريباً).
    final columns = (terms.length / 2).ceil().clamp(1, 4);
    final rows = (terms.length / columns).ceil().clamp(1, 2);
    const gap = 8.0;
    final gridH = rows * _rowH + (rows - 1) * gap;

    return _SearchTermSectionShell(
      title: title,
      sectionColor: sectionColor,
      fadeVerticalEdges: fadeVerticalEdges,
      child: SizedBox(
        height: gridH,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: terms.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: gap,
            crossAxisSpacing: gap,
            mainAxisExtent: _rowH,
          ),
          itemBuilder: (context, i) => _SearchTermChip(
            term: terms[i],
            onTap: () => onChip(terms[i]),
            showSearchIcon: showSearchIcon,
            height: _rowH,
            radius: _chipRadius,
            fontSize: _chipFontSize,
          ),
        ),
      ),
    );
  }
}

class _SearchTermSectionShell extends StatelessWidget {
  final String title;
  final Color? sectionColor;
  final bool fadeVerticalEdges;
  final Widget child;

  const _SearchTermSectionShell({
    required this.title,
    this.sectionColor,
    this.fadeVerticalEdges = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final accent = sectionColor ?? const Color(0xFFE8F0EC);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: fadeVerticalEdges
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.background,
                  accent,
                  accent,
                  AppTheme.background,
                ],
                stops: const [0.0, 0.2, 0.8, 1.0],
              ),
            )
          : (sectionColor != null ? BoxDecoration(color: sectionColor) : null),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _SearchTermChip extends StatelessWidget {
  final String term;
  final VoidCallback onTap;
  final bool showSearchIcon;
  final double height;
  final double radius;
  final double fontSize;

  const _SearchTermChip({
    required this.term,
    required this.onTap,
    this.showSearchIcon = false,
    required this.height,
    required this.radius,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEEF1F0),
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          height: height,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: const Color(0xFFD5DBD8),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                term,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.darkText,
                  height: 1.1,
                ),
              ),
              if (showSearchIcon) ...[
                const SizedBox(width: 3),
                Icon(
                  Icons.search_rounded,
                  size: fontSize + 1,
                  color: AppTheme.mutedText,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchTermMarqueeTrack extends StatefulWidget {
  final List<String> terms;
  final ValueChanged<String> onChip;
  final bool showSearchIcon;
  final double rowHeight;
  final double chipRadius;

  const _SearchTermMarqueeTrack({
    required this.terms,
    required this.onChip,
    this.showSearchIcon = false,
    required this.rowHeight,
    required this.chipRadius,
  });

  @override
  State<_SearchTermMarqueeTrack> createState() => _SearchTermMarqueeTrackState();
}

class _SearchTermMarqueeTrackState extends State<_SearchTermMarqueeTrack> {
  static const double _rowGap = 6;
  static const Duration _holdDelay = Duration(milliseconds: 280);

  final _row1Key = GlobalKey<_SearchTermMarqueeRowState>();
  final _row2Key = GlobalKey<_SearchTermMarqueeRowState>();

  Timer? _holdTimer;
  bool _paused = false;
  double? _lastPointerX;

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    _lastPointerX = event.position.dx;
    _holdTimer?.cancel();
    _holdTimer = Timer(_holdDelay, () {
      if (!mounted) return;
      setState(() => _paused = true);
      _row1Key.currentState?.pause();
      _row2Key.currentState?.pause();
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_paused || _lastPointerX == null) return;
    final delta = _lastPointerX! - event.position.dx;
    _lastPointerX = event.position.dx;
    _row1Key.currentState?.scrollBy(delta);
    _row2Key.currentState?.scrollBy(delta);
  }

  void _onPointerEnd() {
    _holdTimer?.cancel();
    _lastPointerX = null;
    if (!_paused) return;
    setState(() => _paused = false);
    _row1Key.currentState?.resume();
    _row2Key.currentState?.resume();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.terms.isEmpty) return const SizedBox.shrink();

    final row1 = <String>[];
    final row2 = <String>[];
    for (var i = 0; i < widget.terms.length; i++) {
      (i.isEven ? row1 : row2).add(widget.terms[i]);
    }

    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: (_) => _onPointerEnd(),
      onPointerCancel: (_) => _onPointerEnd(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SearchTermMarqueeRow(
            key: _row1Key,
            terms: row1,
            onChip: widget.onChip,
            showSearchIcon: widget.showSearchIcon,
            rowHeight: widget.rowHeight,
            chipRadius: widget.chipRadius,
            paused: _paused,
          ),
          if (row2.isNotEmpty) ...[
            const SizedBox(height: _rowGap),
            _SearchTermMarqueeRow(
              key: _row2Key,
              terms: row2,
              onChip: widget.onChip,
              showSearchIcon: widget.showSearchIcon,
              rowHeight: widget.rowHeight,
              chipRadius: widget.chipRadius,
              paused: _paused,
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchTermMarqueeRow extends StatefulWidget {
  final List<String> terms;
  final ValueChanged<String> onChip;
  final bool showSearchIcon;
  final double rowHeight;
  final double chipRadius;
  final bool paused;

  const _SearchTermMarqueeRow({
    super.key,
    required this.terms,
    required this.onChip,
    this.showSearchIcon = false,
    required this.rowHeight,
    required this.chipRadius,
    this.paused = false,
  });

  @override
  State<_SearchTermMarqueeRow> createState() => _SearchTermMarqueeRowState();
}

class _SearchTermMarqueeRowState extends State<_SearchTermMarqueeRow> {
  final _scroll = ScrollController();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTicker());
  }

  @override
  void didUpdateWidget(covariant _SearchTermMarqueeRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.terms != widget.terms) {
      _stopTicker();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          final half = _scroll.position.maxScrollExtent / 2;
          if (half > 0) _scroll.jumpTo(half);
        }
        if (!widget.paused) _startTicker();
      });
      return;
    }
    if (oldWidget.paused != widget.paused) {
      if (widget.paused) {
        pause();
      } else {
        resume();
      }
    }
  }

  void pause() => _stopTicker();

  void scrollBy(double delta) {
    if (!_scroll.hasClients) return;
    final loop = _scroll.position.maxScrollExtent / 2;
    if (loop <= 0) return;

    var next = _scroll.offset + delta;
    while (next < 0) {
      next += loop;
    }
    while (next > loop) {
      next -= loop;
    }
    _scroll.jumpTo(next);
  }

  void resume() {
    if (!_scroll.hasClients) return;
    final loop = _scroll.position.maxScrollExtent / 2;
    if (loop > 0) {
      var offset = _scroll.offset % loop;
      if (offset < 0) offset += loop;
      _scroll.jumpTo(offset);
    }
    _startTicker();
  }

  @override
  void dispose() {
    _stopTicker();
    _scroll.dispose();
    super.dispose();
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _startTicker() {
    _stopTicker();
    if (!mounted || widget.terms.length < 2 || widget.paused) return;

    if (!_scroll.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startTicker());
      return;
    }

    final half = _scroll.position.maxScrollExtent / 2;
    if (half <= 0) return;

    if (_scroll.offset <= 0 || _scroll.offset > half) {
      _scroll.jumpTo(half);
    }

    _ticker = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted || !_scroll.hasClients) return;
      final loop = _scroll.position.maxScrollExtent / 2;
      if (loop <= 0) return;

      var next = _scroll.offset - 0.32;
      if (next <= 0) {
        next += loop;
      }
      _scroll.jumpTo(next);
    });
  }

  List<Widget> _chipChildren() {
    return [
      for (final term in widget.terms) ...[
        _SearchTermChip(
          term: term,
          onTap: () => widget.onChip(term),
          showSearchIcon: widget.showSearchIcon,
          height: widget.rowHeight,
          radius: widget.chipRadius,
          fontSize: _SearchTermGridSection._chipFontSize,
        ),
        const SizedBox(width: 8),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.terms.length == 1) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: _SearchTermChip(
          term: widget.terms.first,
          onTap: () => widget.onChip(widget.terms.first),
          showSearchIcon: widget.showSearchIcon,
          height: widget.rowHeight,
          radius: widget.chipRadius,
          fontSize: _SearchTermGridSection._chipFontSize,
        ),
      );
    }

    final chips = _chipChildren();
    return SizedBox(
      height: widget.rowHeight,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: ClipRect(
          child: ListView(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            physics: widget.paused
                ? const ClampingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [...chips, ...chips],
          ),
        ),
      ),
    );
  }
}

class _RecentSearchChip extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentSearchChip({
    required this.label,
    required this.onTap,
    required this.onRemove,
    this.imageUrl,
  });

  static const double _chipH = 30;
  static const double _imageW = 34;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: _chipH,
          padding: const EdgeInsetsDirectional.only(end: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD7E8DC), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadiusDirectional.only(
                  topEnd: Radius.circular(7),
                  bottomEnd: Radius.circular(7),
                ),
                child: SizedBox(
                  width: _imageW,
                  height: _chipH,
                  child: hasImage
                      ? AppNetworkImage(
                          imageUrl!,
                          width: _imageW,
                          height: _chipH,
                          fit: BoxFit.cover,
                          placeholder: const ColoredBox(
                            color: Color(0xFFF3FBF6),
                          ),
                          error: const ColoredBox(
                            color: Color(0xFFF3FBF6),
                            child: Icon(
                              Icons.history_rounded,
                              size: 15,
                              color: AppTheme.mutedText,
                            ),
                          ),
                        )
                      : const ColoredBox(
                          color: Color(0xFFF3FBF6),
                          child: Icon(
                            Icons.history_rounded,
                            size: 15,
                            color: AppTheme.mutedText,
                          ),
                        ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 132),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.darkText,
                    height: 1.15,
                  ),
                ),
              ),
              InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Icon(
                    Icons.close_rounded,
                    size: 13,
                    color: AppTheme.mutedText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? imageUrl;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _SearchChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.imageUrl,
    this.onRemove,
    this.accent = AppTheme.primaryDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: EdgeInsetsDirectional.only(
            start: 10,
            end: onRemove == null ? 12 : 4,
            top: 7,
            bottom: 7,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0x1A6B8A76), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imageUrl != null && imageUrl!.trim().isNotEmpty)
                SizedBox(
                  width: 22,
                  height: 22,
                  child: AppNetworkImage(
                    imageUrl!,
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                    placeholder: const SizedBox.shrink(),
                    error: Icon(icon, size: 16, color: accent),
                  ),
                )
              else
                Icon(icon, size: 16, color: accent),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.darkText,
                ),
              ),
              if (onRemove != null)
                InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: AppTheme.mutedText,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendaryOffers extends StatelessWidget {
  final String title;
  final List<ProductModel> products;
  final VoidCallback onOpenAll;

  const _LegendaryOffers({
    required this.title,
    required this.products,
    required this.onOpenAll,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpenAll,
      behavior: HitTestBehavior.translucent,
      child: ClipRect(
        child: SizedBox(
          height: 200,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              const Positioned.fill(
                child: LegendaryBeams(
                  turnsPerCycle: 0.22,
                  duration: Duration(seconds: 26),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitleRow(title: title, onTap: onOpenAll),
                  SizedBox(
                    height: 132,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: products.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, i) =>
                          _LegendaryTile(product: products[i]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendaryTile extends StatelessWidget {
  final ProductModel product;

  const _LegendaryTile({required this.product});

  static const double _imageSize = 72;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showProductPreview(
        context,
        product,
        heroTag: 'search_legend_${product.id}',
      ),
      child: SizedBox(
        width: _imageSize,
        child: Column(
          children: [
            SizedBox(
              width: _imageSize,
              height: _imageSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.22),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: AppNetworkImage(
                        product.displayImage,
                        fit: BoxFit.cover,
                        width: _imageSize,
                        height: _imageSize,
                        placeholder: const ColoredBox(color: Color(0xFFE8F8EC)),
                        error: const ColoredBox(color: Color(0xFFE8F8EC)),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    start: 0,
                    bottom: 0,
                    child: CardCartControl(
                      product: product,
                      size: 22,
                      circular: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.darkText,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            PriceLine(
              price: product.effectivePrice,
              originalPrice: product.hasDiscount ? product.price : null,
              color: const Color(0xFFE53935),
              priceSize: 13,
              currencySize: 15,
              alignment: AlignmentDirectional.centerStart,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultsGrid extends StatelessWidget {
  final List<ProductModel> products;
  final ValueChanged<ProductModel> onOpened;

  const _SearchResultsGrid({required this.products, required this.onOpened});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Text(
              '${products.length} ${AppStrings.searchResultsCount}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppTheme.mutedText,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, i) => ProductCard(
                product: products[i],
                heroTag: 'search_result_${products[i].id}',
                onOpened: () => onOpened(products[i]),
              ),
              childCount: products.length,
            ),
            gridDelegate: ProductShimmerGrid.sliverDelegate(context),
          ),
        ),
      ],
    );
  }
}

class _SearchEmpty extends StatelessWidget {
  const _SearchEmpty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: AppTheme.mutedText),
            SizedBox(height: 14),
            Text(
              AppStrings.searchNoResults,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppTheme.darkText,
              ),
            ),
            SizedBox(height: 8),
            Text(
              AppStrings.searchNoResultsHint,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.mutedText, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultsShimmer extends StatelessWidget {
  const _SearchResultsShimmer();

  @override
  Widget build(BuildContext context) {
    return const ProductShimmerGrid(
      itemCount: 9,
      padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
    );
  }
}

class _SearchDiscoverShimmer extends StatelessWidget {
  const _SearchDiscoverShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const _ShimmerLine(width: 120, height: 14),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(4, (_) => const _ShimmerChip()),
        ),
        const SizedBox(height: 22),
        const _ShimmerLine(width: 140, height: 14),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(5, (_) => const _ShimmerChip()),
        ),
        const SizedBox(height: 22),
        const _ShimmerLine(width: 100, height: 16),
        const SizedBox(height: 14),
        const ProductShimmerGrid(
          itemCount: 6,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: 20),
        Shimmer.fromColors(
          baseColor: ProductCardShimmer.baseColor,
          highlightColor: ProductCardShimmer.highlightColor,
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  final double width;
  final double height;

  const _ShimmerLine({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ProductCardShimmer.baseColor,
      highlightColor: ProductCardShimmer.highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

class _ShimmerChip extends StatelessWidget {
  const _ShimmerChip();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ProductCardShimmer.baseColor,
      highlightColor: ProductCardShimmer.highlightColor,
      child: Container(
        width: 92,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
