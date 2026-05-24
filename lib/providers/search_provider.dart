import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/bible_dao.dart';
import '../models/verse.dart';
import '../models/book.dart';

class SearchState {
  final String query;
  final List<VerseSearchResult> results;
  final bool isLoading;
  final String? error;

  SearchState({
    required this.query,
    required this.results,
    required this.isLoading,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<VerseSearchResult>? results,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class VerseSearchResult {
  final Verse verse;
  final Book book;

  VerseSearchResult({
    required this.verse,
    required this.book,
  });
}

class SearchNotifier extends StateNotifier<SearchState> {
  final BibleDao _bibleDao = BibleDao();

  SearchNotifier()
      : super(SearchState(
          query: '',
          results: [],
          isLoading: false,
        ));

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = SearchState(query: '', results: [], isLoading: false);
      return;
    }

    state = state.copyWith(query: query, isLoading: true, error: null);

    try {
      final verses = await _bibleDao.searchVerses(query);
      final books = await _bibleDao.getBooks();

      final List<VerseSearchResult> results = [];
      for (final v in verses) {
        final book = books.firstWhere((b) => b.id == v.bookId, orElse: () => books.first);
        results.add(VerseSearchResult(verse: v, book: book));
      }

      state = state.copyWith(results: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'శోధనలో లోపం ఏర్పడింది: ${e.toString()}',
      );
    }
  }

  void clear() {
    state = SearchState(query: '', results: [], isLoading: false);
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});
