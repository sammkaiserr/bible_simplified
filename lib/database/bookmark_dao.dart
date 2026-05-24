import '../models/bookmark.dart';
import 'database_helper.dart';

class BookmarkDao {
  Future<List<Bookmark>> getAll() async {
    final maps = await DatabaseHelper.instance.rawQuery('''
      SELECT b.*, bk.name as bookName, bk.nameEnglish as bookNameEnglish, v.originalText as verseText, v.originalTextEnglish as verseTextEnglish
      FROM bookmarks b
      LEFT JOIN books bk ON b.bookId = bk.id
      LEFT JOIN verses v ON b.verseId = v.id
      ORDER BY b.createdAt DESC
    ''');
    return maps.map((m) => Bookmark.fromMap(m)).toList();
  }

  Future<bool> isBookmarked(int verseId) async {
    final r = await DatabaseHelper.instance.query('bookmarks', where: 'verseId = ?', whereArgs: [verseId]);
    return r.isNotEmpty;
  }

  Future<void> toggle(Bookmark bookmark) async {
    final existing = await DatabaseHelper.instance.query('bookmarks', where: 'verseId = ?', whereArgs: [bookmark.verseId]);
    if (existing.isNotEmpty) {
      await DatabaseHelper.instance.delete('bookmarks', where: 'verseId = ?', whereArgs: [bookmark.verseId]);
    } else {
      await DatabaseHelper.instance.insert('bookmarks', bookmark.toMap());
    }
  }

  Future<void> delete(int verseId) async {
    await DatabaseHelper.instance.delete('bookmarks', where: 'verseId = ?', whereArgs: [verseId]);
  }
}
