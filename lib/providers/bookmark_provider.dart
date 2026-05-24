import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/bookmark_dao.dart';
import '../models/bookmark.dart';

class BookmarkNotifier extends StateNotifier<List<Bookmark>> {
  final BookmarkDao _bookmarkDao = BookmarkDao();

  BookmarkNotifier() : super([]) {
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    final list = await _bookmarkDao.getAll();
    state = list;
  }

  Future<void> toggleBookmark({
    required int verseId,
    required int bookId,
    required int chapterNumber,
    required int verseNumber,
  }) async {
    final isFav = await _bookmarkDao.isBookmarked(verseId);
    if (isFav) {
      await _bookmarkDao.delete(verseId);
    } else {
      final b = Bookmark(
        verseId: verseId,
        bookId: bookId,
        chapterNumber: chapterNumber,
        verseNumber: verseNumber,
        createdAt: DateTime.now().toIso8601String(),
      );
      await _bookmarkDao.toggle(b);
    }
    await loadBookmarks();
  }

  Future<bool> isBookmarked(int verseId) async {
    return await _bookmarkDao.isBookmarked(verseId);
  }

  Future<void> deleteBookmark(int verseId) async {
    await _bookmarkDao.delete(verseId);
    await loadBookmarks();
  }
}

final bookmarkProvider = StateNotifierProvider<BookmarkNotifier, List<Bookmark>>((ref) {
  return BookmarkNotifier();
});

final isBookmarkedProvider = FutureProvider.family<bool, int>((ref, verseId) async {
  final bookmarkNotifier = ref.watch(bookmarkProvider.notifier);
  return await bookmarkNotifier.isBookmarked(verseId);
});
