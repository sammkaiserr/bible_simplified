import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/highlight_dao.dart';
import '../models/highlight.dart';
import '../models/chapter_key.dart';

class HighlightNotifier extends StateNotifier<List<Highlight>> {
  final HighlightDao _highlightDao = HighlightDao();

  HighlightNotifier() : super([]) {
    loadHighlights();
  }

  Future<void> loadHighlights() async {
    final list = await _highlightDao.getAll();
    state = list;
  }

  Future<void> setHighlight({
    required int verseId,
    required int bookId,
    required int chapterNumber,
    required int verseNumber,
    required String colorHex,
  }) async {
    final h = Highlight(
      verseId: verseId,
      bookId: bookId,
      chapterNumber: chapterNumber,
      verseNumber: verseNumber,
      colorHex: colorHex,
      createdAt: DateTime.now().toIso8601String(),
    );
    await _highlightDao.setHighlight(h);
    await loadHighlights();
  }

  Future<void> removeHighlight(int verseId) async {
    await _highlightDao.removeHighlight(verseId);
    await loadHighlights();
  }

  Future<Map<int, String>> getChapterHighlights(int bookId, int chapter) async {
    return await _highlightDao.getHighlightsForChapter(bookId, chapter);
  }
}

final highlightProvider = StateNotifierProvider<HighlightNotifier, List<Highlight>>((ref) {
  return HighlightNotifier();
});

final chapterHighlightsProvider = FutureProvider.family<Map<int, String>, ChapterKey>((ref, key) async {
  final notifier = ref.watch(highlightProvider.notifier);
  return await notifier.getChapterHighlights(key.bookId, key.chapter);
});
