import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../data/models/dynamic_page_model.dart';
import '../../data/services/catalog_api.dart';
import '../manager/catalog_cubit.dart';
import '../widgets/product_browse_sheet_screen.dart';

class DynamicPageArgs {
  final String pageId;
  final DynamicPageModel? initial;

  const DynamicPageArgs({
    required this.pageId,
    this.initial,
  });
}

class CustomDynamicPageScreen extends StatefulWidget {
  static const routeName = '/dynamic-page';

  final String pageId;
  final DynamicPageModel? initial;

  const CustomDynamicPageScreen({
    super.key,
    required this.pageId,
    this.initial,
  });

  @override
  State<CustomDynamicPageScreen> createState() =>
      _CustomDynamicPageScreenState();
}

class _CustomDynamicPageScreenState extends State<CustomDynamicPageScreen> {
  DynamicPageModel? _page;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final cached = widget.initial ??
        context.read<CatalogCubit>().state.pageById(widget.pageId);
    if (cached != null) {
      _page = cached;
      _loading = cached.products.isEmpty;
    }
    _load();
  }

  Future<void> _load() async {
    try {
      final page = await CatalogApi.instance.dynamicPage(widget.pageId);
      if (!mounted) return;
      if (page == null) {
        setState(() {
          _loading = false;
          _error ??= AppStrings.dynamicPageFailed;
        });
        return;
      }
      setState(() {
        _page = page;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (_page == null) _error = AppStrings.dynamicPageFailed;
      });
    }
  }

  void _retry() {
    setState(() {
      _loading = true;
      _error = null;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final page = _page;

    return ProductBrowseSheetScreen(
      headerImageUrl: page?.headerImage ?? '',
      products: page?.products ?? const [],
      heroTagPrefix: 'dynamic_${widget.pageId}',
      loading: _loading,
      error: _error,
      onRetry: _retry,
    );
  }
}
