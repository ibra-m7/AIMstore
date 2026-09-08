import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product_model.dart';
import '../../data/services/catalog_api.dart';
import '../../data/services/search_history_store.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchState());

  Future<void> hydrate() async {
    if (state.ready) return;
    final recents = await SearchHistoryStore.load();
    emit(state.copyWith(recents: recents, ready: true));
  }

  void setQuery(String query) {
    emit(state.copyWith(query: query));
  }

  void clearQuery() {
    emit(state.copyWith(query: ''));
  }

  Future<void> submit(
    String query, {
    ProductModel? matchedProduct,
    int resultsCount = 0,
  }) async {
    final q = query.trim();
    emit(state.copyWith(query: q, searching: q.isNotEmpty));
    if (q.isEmpty) {
      emit(state.copyWith(searching: false));
      return;
    }
    final List<RecentSearchItem> recents;
    if (matchedProduct != null) {
      recents = await SearchHistoryStore.addItem(
        RecentSearchItem(
          query: matchedProduct.name.trim().isNotEmpty
              ? matchedProduct.name.trim()
              : q,
          productId: matchedProduct.id,
          imageUrl: matchedProduct.displayImage,
        ),
      );
    } else {
      recents = await SearchHistoryStore.add(q);
    }
    // تسجيل في الخادم (لا ينتظر حتى لا يبطئ الواجهة)
    // ignore: unawaited_futures
    CatalogApi.instance.logSearch(
      query: q,
      matchedProductId: matchedProduct?.id,
      resultsCount: resultsCount > 0
          ? resultsCount
          : (matchedProduct != null ? 1 : 0),
    );
    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (isClosed) return;
    emit(state.copyWith(recents: recents, searching: false, query: q));
  }

  Future<void> rememberProduct(ProductModel product) async {
    final recents = await SearchHistoryStore.addItem(
      RecentSearchItem(
        query: product.name,
        productId: product.id,
        imageUrl: product.displayImage,
      ),
    );
    if (isClosed) return;
    emit(state.copyWith(recents: recents));
  }

  Future<void> removeRecent(RecentSearchItem item) async {
    final recents = await SearchHistoryStore.remove(item);
    emit(state.copyWith(recents: recents));
  }

  Future<void> clearRecents() async {
    await SearchHistoryStore.clear();
    emit(state.copyWith(recents: const []));
  }
}
