/// SQLite database helper for Bible Simplified.
///
/// Handles database creation, migrations, schema setup (including FTS5),
/// and seeding of the complete Telugu Bible data.
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'web_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../core/constants.dart';
import 'bible_data.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._();

  DatabaseHelper._();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite Database is not supported on Web. Use wrapper methods on DatabaseHelper instead.');
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    if (kIsWeb) {
      return await WebDatabase.instance.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy);
    }
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    if (kIsWeb) {
      return await WebDatabase.instance.rawQuery(sql, arguments);
    }
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  Future<int> insert(String table, Map<String, Object?> values) async {
    if (kIsWeb) {
      return await WebDatabase.instance.insert(table, values);
    }
    final db = await database;
    return await db.insert(table, values);
  }

  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    if (kIsWeb) {
      return await WebDatabase.instance.delete(table, where: where, whereArgs: whereArgs);
    }
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    if (kIsWeb) {
      return await WebDatabase.instance.update(table, values, where: where, whereArgs: whereArgs);
    }
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // ─── Create tables ──────────────────────────────────────────
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        nameEnglish TEXT NOT NULL,
        testament TEXT NOT NULL,
        totalChapters INTEGER NOT NULL,
        orderIndex INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE verses (
        id INTEGER PRIMARY KEY,
        bookId INTEGER NOT NULL,
        chapterNumber INTEGER NOT NULL,
        verseNumber INTEGER NOT NULL,
        originalText TEXT NOT NULL,
        simpleText TEXT,
        originalTextEnglish TEXT,
        simpleTextEnglish TEXT,
        FOREIGN KEY (bookId) REFERENCES books(id)
      )
    ''');

    // Indexes for fast querying
    await db.execute(
      'CREATE INDEX idx_verses_book_chapter ON verses(bookId, chapterNumber)',
    );

    // FTS5 virtual table for fast full-text search
    await db.execute('''
      CREATE VIRTUAL TABLE IF NOT EXISTS verses_fts USING fts5(
        originalText, simpleText, originalTextEnglish, simpleTextEnglish, content=verses, content_rowid=id
      )
    ''');

    // Triggers to keep FTS in sync
    await db.execute('''
      CREATE TRIGGER verses_ai AFTER INSERT ON verses BEGIN
        INSERT INTO verses_fts(rowid, originalText, simpleText, originalTextEnglish, simpleTextEnglish) 
        VALUES (new.id, new.originalText, new.simpleText, new.originalTextEnglish, new.simpleTextEnglish);
      END
    ''');

    await db.execute('''
      CREATE TRIGGER verses_ad AFTER DELETE ON verses BEGIN
        INSERT INTO verses_fts(verses_fts, rowid, originalText, simpleText, originalTextEnglish, simpleTextEnglish) 
        VALUES('delete', old.id, old.originalText, old.simpleText, old.originalTextEnglish, old.simpleTextEnglish);
      END
    ''');

    await db.execute('''
      CREATE TRIGGER verses_au AFTER UPDATE ON verses BEGIN
        INSERT INTO verses_fts(verses_fts, rowid, originalText, simpleText, originalTextEnglish, simpleTextEnglish) 
        VALUES('delete', old.id, old.originalText, old.simpleText, old.originalTextEnglish, old.simpleTextEnglish);
        INSERT INTO verses_fts(rowid, originalText, simpleText, originalTextEnglish, simpleTextEnglish) 
        VALUES (new.id, new.originalText, new.simpleText, new.originalTextEnglish, new.simpleTextEnglish);
      END
    ''');

    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        verseId INTEGER NOT NULL,
        bookId INTEGER NOT NULL,
        chapterNumber INTEGER NOT NULL,
        verseNumber INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (verseId) REFERENCES verses(id)
      )
    ''');

    await db.execute(
      'CREATE UNIQUE INDEX idx_bookmarks_verse ON bookmarks(verseId)',
    );

    await db.execute('''
      CREATE TABLE highlights (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        verseId INTEGER NOT NULL,
        bookId INTEGER NOT NULL,
        chapterNumber INTEGER NOT NULL,
        verseNumber INTEGER NOT NULL,
        colorHex TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (verseId) REFERENCES verses(id)
      )
    ''');

    await db.execute(
      'CREATE UNIQUE INDEX idx_highlights_verse ON highlights(verseId)',
    );

    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        verseId INTEGER NOT NULL,
        bookId INTEGER NOT NULL,
        chapterNumber INTEGER NOT NULL,
        verseNumber INTEGER NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (verseId) REFERENCES verses(id)
      )
    ''');

    await db.execute(
      'CREATE UNIQUE INDEX idx_notes_verse ON notes(verseId)',
    );

    // ─── Seed data ──────────────────────────────────────────────
    await _seedData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      debugPrint('DatabaseHelper: Upgrading database from v$oldVersion to v$newVersion (Recreating tables)...');
      await db.execute('DROP TABLE IF EXISTS bookmarks');
      await db.execute('DROP TABLE IF EXISTS highlights');
      await db.execute('DROP TABLE IF EXISTS notes');
      await db.execute('DROP TABLE IF EXISTS verses_fts');
      await db.execute('DROP TRIGGER IF EXISTS verses_ai');
      await db.execute('DROP TRIGGER IF EXISTS verses_ad');
      await db.execute('DROP TRIGGER IF EXISTS verses_au');
      await db.execute('DROP TABLE IF EXISTS verses');
      await db.execute('DROP TABLE IF EXISTS books');
      await _onCreate(db, newVersion);
    }
  }

  /// Seeds the database with all 66 books and initial verse data.
  Future<void> _seedData(Database db) async {
    final batch = db.batch();

    // Insert all 66 books
    for (final book in BibleData.books) {
      batch.insert('books', book);
    }

    // Insert any initial static verses if present
    for (final verse in BibleData.verses) {
      batch.insert('verses', verse);
    }

    await batch.commit(noResult: true);
  }

  /// Loads a book by ID from its JSON asset, parses it, and seeds it into the database.
  Future<void> loadBookFromAssets(int bookId) async {
    if (kIsWeb) {
      await WebDatabase.instance.loadBookFromAssets(bookId);
      return;
    }

    final book = BibleData.books.firstWhere((b) => b['id'] == bookId, orElse: () => {});
    if (book.isEmpty) return;

    String bookName = book['nameEnglish'] as String;
    if (bookName == 'Song of Solomon') {
      bookName = 'Song of Songs';
    }

    try {
      final db = await database;

      // Check if already loaded
      final countResult = await db.rawQuery(
        'SELECT COUNT(*) as cnt FROM verses WHERE bookId = ?',
        [bookId],
      );
      final count = countResult.first['cnt'] as int? ?? 0;
      if (count > 0) {
        // Book is already loaded, skip inserting to save time
        return;
      }

      final jsonString = await rootBundle.loadString('assets/bible/$bookName.json');
      final Map<String, dynamic> parsed = json.decode(jsonString);
      final List<dynamic> chapters = parsed['chapters'];

      await db.transaction((txn) async {
        final batch = txn.batch();
        for (final chapterData in chapters) {
          final int chapterNumber = int.parse(chapterData['chapter'].toString());
          final List<dynamic> versesList = chapterData['verses'];
          for (final verseData in versesList) {
            final int verseNumber = int.parse(verseData['verse'].toString());
            final String text = verseData['text'] as String;
            
            // Unique, predictable ID
            final int id = bookId * 1000000 + chapterNumber * 1000 + verseNumber;

            final String lookupKey = '${bookId}_${chapterNumber}_${verseNumber}';
            final String? preSeeded = _preSeededSimpleTelugu[lookupKey];

            batch.insert(
              'verses',
              {
                'id': id,
                'bookId': bookId,
                'chapterNumber': chapterNumber,
                'verseNumber': verseNumber,
                'originalText': text,
                'simpleText': preSeeded,
                'originalTextEnglish': null,
                'simpleTextEnglish': null,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
        await batch.commit(noResult: true);
      });
      debugPrint('DatabaseHelper: Successfully loaded and seeded $bookName from assets.');
    } catch (e) {
      debugPrint('DatabaseHelper: Error loading book $bookId ($bookName) from assets: $e');
    }
  }

  /// Close the database connection.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  static const Map<String, String> _preSeededSimpleTelugu = {
    '43_3_16': 'దేవుడు ఈ లోకంలోని ప్రజలను ఎంతో ప్రేమించాడు. అందుకనే, తన ఏకైక కుమారుడిని (యేసును) లోకానికి ఇచ్చాడు. ఆయనను నమ్మే ప్రతి ఒక్కరూ నశించిపోకుండా శాశ్వత జీవాన్ని పొందుతారు.',
    '45_6_23': 'పాపం వల్ల వచ్చే జీతం చావు, కానీ దేవుడు మనకు ఉచితంగా ఇచ్చే బహుమతి మన ప్రభువైన క్రీస్తు యేసు ద్వారా లభించే నిత్యజీవితం.',
    '45_10_9': 'యేసుక్రీస్తే ప్రభువు అని నీ నోటితో ఒప్పుకుని, దేవుడు ఆయనను చనిపోయినవారిలో నుండి బ్రతికించాడని నీ హృదయంలో నమ్మితే నీకు రక్షణ లభిస్తుంది.',
    '1_1_1': 'మొదట్లో దేవుడు ఆకాశాన్ని, భూమిని సృష్టించాడు.',
    '1_1_2': 'భూమి ఖాళీగా, చీకటిగా ఉండేది. నీళ్ళ మీద చీకటి ఉండేది. దేవుని ఆత్మ నీళ్ళ మీద తిరుగుతూ ఉండేది.',
    '1_1_3': 'దేవుడు "వెలుగు రా" అని చెప్పాడు. వెంటనే వెలుగు వచ్చింది.',
    '19_23_4': 'చాలా కష్టమైన, చీకటి సమయాలలో కూడా నేను భయపడను. ఎందుకంటే దేవుడు నాతో ఉన్నాడు. ఆయన నన్ను కాపాడతాడు, ధైర్యం ఇస్తాడు.',
    '19_23_5': 'నా శత్రువుల ముందే దేవుడు నాకు విందు ఏర్పాటు చేస్తాడు. నన్ను గౌరవిస్తాడు. నాకు కావలసినవన్నీ పుష్కలంగా ఇస్తాడు.',
    '19_23_6': 'నా జీవితమంతా దేవుని మంచితనం, ప్రేమ నన్ను వెంటాడుతూ ఉంటాయి. నేను ఎప్పటికీ దేవుని ఇంటిలో ఉంటాను.',
    '1_2_1': 'ఆకాశం, భూమి, వాటిలో ఉన్నవన్నీ సృష్టించడం పూర్తయింది.',
    '1_2_2': 'దేవుడు తాను చేసిన సృష్టి పనిని ఏడవ రోజు నాటికి ముగించి, ఆ రోజున విశ్రాంతి తీసుకున్నాడు.',
    '1_3_6': 'ఆ చెట్టు పండ్లు ఆహారానికి రుచికరంగా, చూడటానికి అందంగా, జ్ఞానాన్ని ఇచ్చేవిగా ఉండటం చూసి, ఆ స్త్రీ వాటిలో కొన్ని కోసుకుని తిని, తన భర్తకు కూడా ఇచ్చింది, అతను కూడా తిన్నాడు.',
    '1_3_23': 'కాబట్టి, మనిషి ఏ మట్టి నుండి తయారు చేయబడ్డాడో, ఆ నేలను సాగు చేయడానికి దేవుడైన యెహోవా అతనిని ఏదెను తోటలో నుండి బయటకు పంపించేశాడు.',
    '40_5_1': 'యేసు ప్రజలను చూసి కొండపైకి వెళ్ళి కూర్చున్నాడు. ఆయన శిష్యులు ఆయన దగ్గరకు వచ్చారు.',
    '40_5_2': 'అప్పుడు ఆయన వారికి ఈ విధంగా బోధించడం ప్రారంభించాడు.',
    '40_5_3': 'నీతి కోసం హింసించబడేవారు ధన్యులు, ఎందుకంటే పరలోకరాజ్యం వారిదే.',
    '40_5_11': 'నా (యేసు) నిమిత్తం ప్రజలు మిమ్మల్ని నిందించి, హింసించి, మీ మీద అబద్ధాలు ప్రచారం చేసినప్పుడు మీరు ధన్యులు.',
    '40_5_12': 'సంతోషించి ఆనందించండి, ఎందుకంటే పరలోకంలో మీ బహుమతి చాలా పెద్దది. మీకంటే ముందున్న ప్రవక్తలను కూడా ప్రజలు ఇలాగే హింసించారు.',
  };
}
