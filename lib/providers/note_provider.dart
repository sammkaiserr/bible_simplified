import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/note_dao.dart';
import '../models/note.dart';
import '../models/chapter_key.dart';

class NoteNotifier extends StateNotifier<List<Note>> {
  final NoteDao _noteDao = NoteDao();

  NoteNotifier() : super([]) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    final list = await _noteDao.getAll();
    state = list;
  }

  Future<void> saveNote({
    required int verseId,
    required int bookId,
    required int chapterNumber,
    required int verseNumber,
    required String content,
  }) async {
    final now = DateTime.now().toIso8601String();
    
    // Check if note exists
    final existing = await _noteDao.getNoteForVerse(verseId);
    
    final note = Note(
      id: existing?.id,
      verseId: verseId,
      bookId: bookId,
      chapterNumber: chapterNumber,
      verseNumber: verseNumber,
      content: content,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    await _noteDao.saveNote(note);
    await loadNotes();
  }

  Future<void> deleteNote(int verseId) async {
    await _noteDao.deleteNote(verseId);
    await loadNotes();
  }

  Future<Note?> getNoteForVerse(int verseId) async {
    return await _noteDao.getNoteForVerse(verseId);
  }

  Future<Map<int, Note>> getChapterNotes(int bookId, int chapter) async {
    return await _noteDao.getNotesForChapter(bookId, chapter);
  }
}

final noteProvider = StateNotifierProvider<NoteNotifier, List<Note>>((ref) {
  return NoteNotifier();
});

final verseNoteProvider = FutureProvider.family<Note?, int>((ref, verseId) async {
  final notifier = ref.watch(noteProvider.notifier);
  return await notifier.getNoteForVerse(verseId);
});

final chapterNotesProvider = FutureProvider.family<Map<int, Note>, ChapterKey>((ref, key) async {
  final notifier = ref.watch(noteProvider.notifier);
  return await notifier.getChapterNotes(key.bookId, key.chapter);
});
