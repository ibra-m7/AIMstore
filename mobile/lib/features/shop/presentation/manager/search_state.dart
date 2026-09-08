part of 'search_cubit.dart';

class SearchState extends Equatable {
  final String query;
  final List<RecentSearchItem> recents;
  final bool ready;
  final bool searching;

  const SearchState({
    this.query = '',
    this.recents = const [],
    this.ready = false,
    this.searching = false,
  });

  SearchState copyWith({
    String? query,
    List<RecentSearchItem>? recents,
    bool? ready,
    bool? searching,
  }) {
    return SearchState(
      query: query ?? this.query,
      recents: recents ?? this.recents,
      ready: ready ?? this.ready,
      searching: searching ?? this.searching,
    );
  }

  @override
  List<Object?> get props => [query, recents, ready, searching];
}
