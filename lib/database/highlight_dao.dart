import '../models/highlight.dart';
import 'database_helper.dart';

class HighlightDao {
  Future<List<Highlight>> getAll() async {
    final maps = await DatabaseHelper.instance.rawQuery('''
      SELECT h.*, bk.name as bookName, bk.nameEnglish as bookNameEnglish, v.originalText as verseText, v.originalTextEnglish as verseTextEnglish
      FROM highlights h
      LEFT JOIN books bk ON h.bookId = bk.id
      LEFT JOIN verses v ON h.verseId = v.id
      ORDER BY h.createdAt DESC
    ''');
    return maps.map((m) => Highlight.fromMap(m)).toList();
  }

  Future<Map<int, String>> getHighlightsForChapter(int bookId, int chapter) async {
    final maps = await DatabaseHelper.instance.rawQuery('''
      SELECT h.verseId, h.colorHex FROM highlights h
      INNER JOIN verses v ON h.verseId = v.id
      WHERE v.bookId = ? AND v.chapterNumber = ?
    ''', [bookId, chapter]);
    return {for (var m in maps) m['verseId'] as int: m['colorHex'] as String};
  }

  Future<void> setHighlight(Highlight highlight) async {
    await DatabaseHelper.instance.delete('highlights', where: 'verseId = ?', whereArgs: [highlight.verseId]);
    await DatabaseHelper.instance.insert('highlights', highlight.toMap());
  }

  Future<void> removeHighlight(int verseId) async {
    await DatabaseHelper.instance.delete('highlights', where: 'verseId = ?', whereArgs: [verseId]);
  }
}
