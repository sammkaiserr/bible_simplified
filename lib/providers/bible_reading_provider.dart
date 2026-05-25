import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../database/bible_dao.dart';
import '../database/database_helper.dart';
import '../models/book.dart';
import '../models/verse.dart';

class BibleReadingState {
  final List<Book> books;
  final Book? currentBook;
  final int currentChapter;
  final List<Verse> verses;
  final bool isLoading;
  final List<Book> recentlyOpened;

  BibleReadingState({
    required this.books,
    this.currentBook,
    required this.currentChapter,
    required this.verses,
    required this.isLoading,
    required this.recentlyOpened,
  });

  BibleReadingState copyWith({
    List<Book>? books,
    Book? currentBook,
    int? currentChapter,
    List<Verse>? verses,
    bool? isLoading,
    List<Book>? recentlyOpened,
  }) {
    return BibleReadingState(
      books: books ?? this.books,
      currentBook: currentBook ?? this.currentBook,
      currentChapter: currentChapter ?? this.currentChapter,
      verses: verses ?? this.verses,
      isLoading: isLoading ?? this.isLoading,
      recentlyOpened: recentlyOpened ?? this.recentlyOpened,
    );
  }
}

class BibleReadingNotifier extends StateNotifier<BibleReadingState> {
  final BibleDao _bibleDao = BibleDao();
  static const String _keyRecentlyOpened = 'recently_opened_books_json';

  BibleReadingNotifier()
      : super(BibleReadingState(
          books: [],
          currentChapter: 1,
          verses: [],
          isLoading: true,
          recentlyOpened: [],
        )) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    final booksList = await _bibleDao.getBooks();

    final prefs = await SharedPreferences.getInstance();

    final lastBookId = prefs.getInt(AppConstants.keyLastBookId) ?? 1;
    final lastChapter = prefs.getInt(AppConstants.keyLastChapter) ?? 1;

    Book? currentBook = booksList.firstWhere(
      (b) => b.id == lastBookId,
      orElse: () => booksList.isNotEmpty ? booksList.first : Book(id: 1, name: 'ఆదికాండము', nameEnglish: 'Genesis', testament: 'OT', totalChapters: 50, orderIndex: 1),
    );

    await DatabaseHelper.instance.loadBookFromAssets(currentBook.id);
    await DatabaseHelper.instance.loadBookFromAssets(1);
    await DatabaseHelper.instance.loadBookFromAssets(40);
    await DatabaseHelper.instance.loadBookFromAssets(43);
    await DatabaseHelper.instance.loadBookFromAssets(19);

    final versesList = await _bibleDao.getVerses(currentBook.id, lastChapter);
    final recently = await _loadRecentlyOpened(booksList);

    state = BibleReadingState(
      books: booksList,
      currentBook: currentBook,
      currentChapter: lastChapter,
      verses: versesList,
      isLoading: false,
      recentlyOpened: recently,
    );
  }

  Future<void> navigateToChapter(Book book, int chapter) async {
    state = state.copyWith(isLoading: true);
    final versesList = await _bibleDao.getVerses(book.id, chapter);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyLastBookId, book.id);
    await prefs.setInt(AppConstants.keyLastChapter, chapter);

    await _addToRecentlyOpened(book);
    final recently = await _loadRecentlyOpened(state.books);

    state = state.copyWith(
      currentBook: book,
      currentChapter: chapter,
      verses: versesList,
      isLoading: false,
      recentlyOpened: recently,
    );
  }

  Future<void> nextChapter() async {
    final curBook = state.currentBook;
    if (curBook == null) return;

    if (state.currentChapter < curBook.totalChapters) {
      await navigateToChapter(curBook, state.currentChapter + 1);
    } else {

      final nextBookIndex = state.books.indexWhere((b) => b.id == curBook.id) + 1;
      if (nextBookIndex < state.books.length) {
        await navigateToChapter(state.books[nextBookIndex], 1);
      }
    }
  }

  Future<void> previousChapter() async {
    final curBook = state.currentBook;
    if (curBook == null) return;

    if (state.currentChapter > 1) {
      await navigateToChapter(curBook, state.currentChapter - 1);
    } else {

      final prevBookIndex = state.books.indexWhere((b) => b.id == curBook.id) - 1;
      if (prevBookIndex >= 0) {
        final prevBook = state.books[prevBookIndex];
        await navigateToChapter(prevBook, prevBook.totalChapters);
      }
    }
  }

  Future<List<Book>> _loadRecentlyOpened(List<Book> allBooks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyRecentlyOpened);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final List<dynamic> list = json.decode(jsonStr);
      final List<int> ids = list.cast<int>();
      return ids
          .map((id) => allBooks.firstWhere((b) => b.id == id, orElse: () => allBooks.first))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _addToRecentlyOpened(Book book) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await _loadRecentlyOpened(state.books);

    current.removeWhere((b) => b.id == book.id);
    current.insert(0, book);

    if (current.length > 5) {
      current.removeLast();
    }

    final ids = current.map((b) => b.id).toList();
    await prefs.setString(_keyRecentlyOpened, json.encode(ids));
  }
}

final bibleReadingProvider = StateNotifierProvider<BibleReadingNotifier, BibleReadingState>((ref) {
  return BibleReadingNotifier();
});
