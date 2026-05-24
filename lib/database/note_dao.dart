import '../models/note.dart';
import 'database_helper.dart';

class NoteDao {
  Future<List<Note>> getAll() async {
    final maps = await DatabaseHelper.instance.rawQuery('''
      SELECT n.*, bk.name as bookName, bk.nameEnglish as bookNameEnglish, v.originalText as verseText, v.originalTextEnglish as verseTextEnglish
      FROM notes n
      LEFT JOIN books bk ON n.bookId = bk.id
      LEFT JOIN verses v ON n.verseId = v.id
      ORDER BY n.updatedAt DESC
    ''');
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  Future<Note?> getNoteForVerse(int verseId) async {
    final maps = await DatabaseHelper.instance.query('notes', where: 'verseId = ?', whereArgs: [verseId]);
    if (maps.isEmpty) return null;
    return Note.fromMap(maps.first);
  }

  Future<Map<int, Note>> getNotesForChapter(int bookId, int chapter) async {
    final maps = await DatabaseHelper.instance.rawQuery('''
      SELECT n.* FROM notes n
      INNER JOIN verses v ON n.verseId = v.id
      WHERE v.bookId = ? AND v.chapterNumber = ?
    ''', [bookId, chapter]);
    return {for (var m in maps) m['verseId'] as int: Note.fromMap(m)};
  }

  Future<void> saveNote(Note note) async {
    final existing = await DatabaseHelper.instance.query('notes', where: 'verseId = ?', whereArgs: [note.verseId]);
    if (existing.isNotEmpty) {
      await DatabaseHelper.instance.update('notes', note.toMap(), where: 'verseId = ?', whereArgs: [note.verseId]);
    } else {
      await DatabaseHelper.instance.insert('notes', note.toMap());
    }
  }

  Future<void> deleteNote(int verseId) async {
    await DatabaseHelper.instance.delete('notes', where: 'verseId = ?', whereArgs: [verseId]);
  }
}
