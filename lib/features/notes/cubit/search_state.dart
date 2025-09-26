part of 'search_cubit.dart';

sealed class SearchState<T> {}

final class SearchInitial<T> extends SearchState<T> {}

final class SearchLoading<T> extends SearchState<T> {}

final class SearchSuccess<T> extends SearchState<T> {
  final List<T> results;

  SearchSuccess(this.results);
}

final class SearchError<T> extends SearchState<T> {
  final String message;

  SearchError(this.message);
}

final class SearchEmpty<T> extends SearchState<T> {}
