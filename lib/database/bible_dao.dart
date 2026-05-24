import '../models/book.dart';
import '../models/verse.dart';
import 'database_helper.dart';

class BibleDao {
  Future<List<Book>> getBooks() async {
    final maps = await DatabaseHelper.instance.query('books', orderBy: 'orderIndex');
    return maps.map((m) => Book.fromMap(m)).toList();
  }

  Future<List<Book>> getBooksByTestament(String testament) async {
    final maps = await DatabaseHelper.instance.query('books', where: 'testament = ?', whereArgs: [testament], orderBy: 'orderIndex');
    return maps.map((m) => Book.fromMap(m)).toList();
  }

  Future<Book?> getBook(int bookId) async {
    final maps = await DatabaseHelper.instance.query('books', where: 'id = ?', whereArgs: [bookId]);
    if (maps.isEmpty) return null;
    return Book.fromMap(maps.first);
  }

  Future<List<Verse>> getVerses(int bookId, int chapter) async {
    var maps = await DatabaseHelper.instance.query('verses',
      where: 'bookId = ? AND chapterNumber = ?',
      whereArgs: [bookId, chapter],
      orderBy: 'verseNumber',
    );
    
    if (maps.isEmpty) {
      await DatabaseHelper.instance.loadBookFromAssets(bookId);
      maps = await DatabaseHelper.instance.query('verses',
        where: 'bookId = ? AND chapterNumber = ?',
        whereArgs: [bookId, chapter],
        orderBy: 'verseNumber',
      );
    }
    return maps.map((m) => Verse.fromMap(m)).toList();
  }

  Future<Verse?> getVerse(int verseId) async {
    final maps = await DatabaseHelper.instance.query('verses', where: 'id = ?', whereArgs: [verseId]);
    if (maps.isEmpty) return null;
    return Verse.fromMap(maps.first);
  }

  Future<Verse?> getRandomVerse() async {
    final maps = await DatabaseHelper.instance.rawQuery('SELECT * FROM verses ORDER BY RANDOM() LIMIT 1');
    if (maps.isEmpty) return null;
    return Verse.fromMap(maps.first);
  }

  Future<int> getVerseCount(int bookId, int chapter) async {
    final result = await DatabaseHelper.instance.rawQuery(
      'SELECT COUNT(*) as cnt FROM verses WHERE bookId = ? AND chapterNumber = ?',
      [bookId, chapter],
    );
    if (result.isEmpty) return 0;
    return result.first['cnt'] as int? ?? 0;
  }

  Future<List<Verse>> searchVerses(String query) async {
    final maps = await DatabaseHelper.instance.rawQuery('''
      SELECT v.* FROM verses v
      INNER JOIN verses_fts fts ON v.id = fts.rowid
      WHERE verses_fts MATCH ?
      LIMIT 50
    ''', ['"$query"']);
    return maps.map((m) => Verse.fromMap(m)).toList();
  }
}
