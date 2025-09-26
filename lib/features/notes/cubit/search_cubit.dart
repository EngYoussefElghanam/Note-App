import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'search_state.dart';

class SearchCubit<T> extends Cubit<SearchState<T>> {
  Timer? _debounce;
  String? _lastQuery;

  SearchCubit() : super(SearchInitial<T>());

  Future<void> search(
    String query,
    Future<List<T>> Function(String) fetch, // pass a fetch function
  ) async {
    _debounce?.cancel();

    if (query.isEmpty) {
      _lastQuery = null;
      emit(SearchInitial<T>());
      return;
    }

    _lastQuery = query;
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      emit(SearchLoading<T>());
      try {
        final results = await fetch(query);

        // Prevent stale or cleared results from overriding
        if (_lastQuery != query) return;

        if (results.isEmpty) {
          emit(SearchEmpty<T>());
        } else {
          emit(SearchSuccess<T>(results));
        }
      } catch (e) {
        emit(SearchError<T>(e.toString()));
      }
    });
  }
}
