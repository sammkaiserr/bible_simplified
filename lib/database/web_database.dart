import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'bible_data.dart';

class WebDatabase {
  static final WebDatabase instance = WebDatabase._();
  WebDatabase._();

  List<Map<String, dynamic>> _bookmarks = [];
  List<Map<String, dynamic>> _highlights = [];
  List<Map<String, dynamic>> _notes = [];
  bool _initialized = false;

  final Map<int, List<Map<String, dynamic>>> _loadedBooks = {};

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();

    final bookmarksJson = prefs.getString('web_bookmarks');
    if (bookmarksJson != null) {
      try {
        _bookmarks = List<Map<String, dynamic>>.from(json.decode(bookmarksJson));
      } catch (e) {
        debugPrint('Error loading web bookmarks: $e');
      }
    }

    final highlightsJson = prefs.getString('web_highlights');
    if (highlightsJson != null) {
      try {
        _highlights = List<Map<String, dynamic>>.from(json.decode(highlightsJson));
      } catch (e) {
        debugPrint('Error loading web highlights: $e');
      }
    }

    final notesJson = prefs.getString('web_notes');
    if (notesJson != null) {
      try {
        _notes = List<Map<String, dynamic>>.from(json.decode(notesJson));
      } catch (e) {
        debugPrint('Error loading web notes: $e');
      }
    }

    _initialized = true;
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('web_bookmarks', json.encode(_bookmarks));
  }

  Future<void> _saveHighlights() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('web_highlights', json.encode(_highlights));
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('web_notes', json.encode(_notes));
  }

  Future<void> loadBookFromAssets(int bookId) async {
    if (_loadedBooks.containsKey(bookId)) return;

    final book = BibleData.books.firstWhere((b) => b['id'] == bookId, orElse: () => {});
    if (book.isEmpty) return;

    String bookName = book['nameEnglish'] as String;
    if (bookName == 'Song of Solomon') {
      bookName = 'Song of Songs';
    }

    try {
      final jsonString = await rootBundle.loadString('assets/bible/$bookName.json');
      final Map<String, dynamic> parsed = json.decode(jsonString);
      final List<dynamic> chapters = parsed['chapters'];

      final List<Map<String, dynamic>> versesList = [];
      for (final chapterData in chapters) {
        final int chapterNumber = int.parse(chapterData['chapter'].toString());
        final List<dynamic> versesData = chapterData['verses'];
        for (final verseData in versesData) {
          final int verseNumber = int.parse(verseData['verse'].toString());
          final String text = verseData['text'] as String;
          final String? simpleTextFromJson = verseData['simpleText'] as String?;

          final int id = bookId * 1000000 + chapterNumber * 1000 + verseNumber;

          final String lookupKey = '${bookId}_${chapterNumber}_${verseNumber}';
          final String? preSeeded = _preSeededSimpleTelugu[lookupKey];

          versesList.add({
            'id': id,
            'bookId': bookId,
            'chapterNumber': chapterNumber,
            'verseNumber': verseNumber,
            'originalText': (simpleTextFromJson != null && simpleTextFromJson.isNotEmpty) ? simpleTextFromJson : (preSeeded ?? text),
            'simpleText': null,
            'originalTextEnglish': null,
            'simpleTextEnglish': null,
          });
        }
      }
      _loadedBooks[bookId] = versesList;
      debugPrint('WebDatabase: Successfully loaded $bookName from assets.');
    } catch (e) {
      debugPrint('WebDatabase: Error loading book $bookId ($bookName) from assets: $e');
    }
  }

  List<Map<String, dynamic>> _allLoadedVerses() {
    final List<Map<String, dynamic>> list = [];
    for (final bookList in _loadedBooks.values) {
      list.addAll(bookList);
    }
    return list;
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    await init();

    if (table == 'books') {
      var list = List<Map<String, dynamic>>.from(BibleData.books);
      if (where != null && whereArgs != null) {
        if (where.contains('testament = ?')) {
          final val = whereArgs[0] as String;
          list = list.where((b) => b['testament'] == val).toList();
        } else if (where.contains('id = ?')) {
          final val = whereArgs[0] as int;
          list = list.where((b) => b['id'] == val).toList();
        }
      }
      if (orderBy == 'orderIndex') {
        list.sort((a, b) => (a['orderIndex'] as int).compareTo(b['orderIndex'] as int));
      }
      return list;
    }

    if (table == 'verses') {
      if (where != null && whereArgs != null) {
        if (where.contains('bookId = ? AND chapterNumber = ?')) {
          final bookId = whereArgs[0] as int;
          final chapter = whereArgs[1] as int;

          await loadBookFromAssets(bookId);

          var list = List<Map<String, dynamic>>.from(_loadedBooks[bookId] ?? []);
          list = list.where((v) => v['chapterNumber'] == chapter).toList();

          if (orderBy == 'verseNumber') {
            list.sort((a, b) => (a['verseNumber'] as int).compareTo(b['verseNumber'] as int));
          }
          return list;
        } else if (where.contains('id = ?')) {
          final val = whereArgs[0] as int;
          final bookId = val ~/ 1000000;

          await loadBookFromAssets(bookId);

          var list = List<Map<String, dynamic>>.from(_loadedBooks[bookId] ?? []);
          list = list.where((v) => v['id'] == val).toList();
          return list;
        }
      }
      return [];
    }

    if (table == 'bookmarks') {
      var list = List<Map<String, dynamic>>.from(_bookmarks);
      if (where != null && whereArgs != null) {
        if (where.contains('verseId = ?')) {
          final val = whereArgs[0] as int;
          list = list.where((b) => b['verseId'] == val).toList();
        }
      }
      return list;
    }

    if (table == 'notes') {
      var list = List<Map<String, dynamic>>.from(_notes);
      if (where != null && whereArgs != null) {
        if (where.contains('verseId = ?')) {
          final val = whereArgs[0] as int;
          list = list.where((n) => n['verseId'] == val).toList();
        }
      }
      return list;
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    await init();

    final sqlLower = sql.toLowerCase();

    if (sqlLower.contains('order by random()')) {

      await loadBookFromAssets(43);
      final list = _loadedBooks[43] ?? [];
      if (list.isEmpty) return [];
      final idx = Random().nextInt(list.length);
      return [list[idx]];
    }

    if (sqlLower.contains('select count(*)') && sqlLower.contains('from verses')) {
      if (arguments != null && arguments.length >= 2) {
        final bookId = arguments[0] as int;
        final chapter = arguments[1] as int;

        await loadBookFromAssets(bookId);

        final count = (_loadedBooks[bookId] ?? [])
            .where((v) => v['chapterNumber'] == chapter)
            .length;
        return [{'cnt': count}];
      }
      return [{'cnt': 0}];
    }

    if (sqlLower.contains('from verses v') && sqlLower.contains('verses_fts match')) {
      if (arguments != null && arguments.isNotEmpty) {
        final queryStr = (arguments[0] as String).replaceAll('"', '').toLowerCase().trim();
        if (queryStr.isEmpty) return [];

        final list = _allLoadedVerses().where((v) {
          final oText = (v['originalText'] as String? ?? '').toLowerCase();
          final sText = (v['simpleText'] as String? ?? '').toLowerCase();
          final oEng = (v['originalTextEnglish'] as String? ?? '').toLowerCase();
          final sEng = (v['simpleTextEnglish'] as String? ?? '').toLowerCase();

          return oText.contains(queryStr) ||
                 sText.contains(queryStr) ||
                 oEng.contains(queryStr) ||
                 sEng.contains(queryStr);
        }).toList();

        final results = list.take(50).toList();
        return results;
      }
      return [];
    }

    if (sqlLower.contains('from bookmarks b')) {
      var list = List<Map<String, dynamic>>.from(_bookmarks);

      final books = {for (var b in BibleData.books) b['id'] as int: b};
      final verses = {for (var v in _allLoadedVerses()) v['id'] as int: v};

      final joined = list.map((b) {
        final bookId = b['bookId'] as int;
        final verseId = b['verseId'] as int;

        final book = books[bookId];
        final verse = verses[verseId];

        return {
          ...b,
          'bookName': book != null ? book['name'] : '',
          'verseText': verse != null ? verse['originalText'] : '',
        };
      }).toList();

      joined.sort((a, b) {
        final aTime = a['createdAt'] as String? ?? '';
        final bTime = b['createdAt'] as String? ?? '';
        return bTime.compareTo(aTime);
      });

      return joined;
    }

    if (sqlLower.contains('from highlights h')) {
      if (sqlLower.contains('where v.bookid = ?')) {

        if (arguments != null && arguments.length >= 2) {
          final bookId = arguments[0] as int;
          final chapter = arguments[1] as int;

          final versesInChapter = _allLoadedVerses()
              .where((v) => v['bookId'] == bookId && v['chapterNumber'] == chapter)
              .map((v) => v['id'] as int)
              .toSet();

          final filtered = _highlights
              .where((h) => versesInChapter.contains(h['verseId'] as int))
              .map((h) => {'verseId': h['verseId'], 'colorHex': h['colorHex']})
              .toList();

          return filtered;
        }
        return [];
      } else {

        var list = List<Map<String, dynamic>>.from(_highlights);
        final books = {for (var b in BibleData.books) b['id'] as int: b};
        final verses = {for (var v in _allLoadedVerses()) v['id'] as int: v};

        final joined = list.map((h) {
          final bookId = h['bookId'] as int;
          final verseId = h['verseId'] as int;
          final book = books[bookId];
          final verse = verses[verseId];

          return {
            ...h,
            'bookName': book != null ? book['name'] : '',
            'verseText': verse != null ? verse['originalText'] : '',
          };
        }).toList();

        joined.sort((a, b) {
          final aTime = a['createdAt'] as String? ?? '';
          final bTime = b['createdAt'] as String? ?? '';
          return bTime.compareTo(aTime);
        });

        return joined;
      }
    }

    if (sqlLower.contains('from notes n')) {
      if (sqlLower.contains('where v.bookid = ?')) {

        if (arguments != null && arguments.length >= 2) {
          final bookId = arguments[0] as int;
          final chapter = arguments[1] as int;

          final versesInChapter = _allLoadedVerses()
              .where((v) => v['bookId'] == bookId && v['chapterNumber'] == chapter)
              .map((v) => v['id'] as int)
              .toSet();

          final filtered = _notes
              .where((n) => versesInChapter.contains(n['verseId'] as int))
              .toList();

          return filtered;
        }
        return [];
      } else {
        var list = List<Map<String, dynamic>>.from(_notes);
        final books = {for (var b in BibleData.books) b['id'] as int: b};
        final verses = {for (var v in _allLoadedVerses()) v['id'] as int: v};

        final joined = list.map((n) {
          final bookId = n['bookId'] as int;
          final verseId = n['verseId'] as int;
          final book = books[bookId];
          final verse = verses[verseId];

          return {
            ...n,
            'bookName': book != null ? book['name'] : '',
            'verseText': verse != null ? verse['originalText'] : '',
          };
        }).toList();

        joined.sort((a, b) {
          final aTime = a['updatedAt'] as String? ?? '';
          final bTime = b['updatedAt'] as String? ?? '';
          return bTime.compareTo(aTime);
        });

        return joined;
      }
    }

    return [];
  }

  Future<int> insert(String table, Map<String, Object?> values) async {
    await init();

    final valMap = Map<String, dynamic>.from(values);

    if (table == 'bookmarks') {
      _bookmarks.removeWhere((b) => b['verseId'] == valMap['verseId']);
      _bookmarks.add(valMap);
      await _saveBookmarks();
      return 1;
    }

    if (table == 'highlights') {
      _highlights.removeWhere((h) => h['verseId'] == valMap['verseId']);
      _highlights.add(valMap);
      await _saveHighlights();
      return 1;
    }

    if (table == 'notes') {
      _notes.removeWhere((n) => n['verseId'] == valMap['verseId']);
      _notes.add(valMap);
      await _saveNotes();
      return 1;
    }

    return 0;
  }

  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    await init();

    if (where != null && whereArgs != null && where.contains('verseId = ?')) {
      final verseId = whereArgs[0] as int;

      if (table == 'bookmarks') {
        final lengthBefore = _bookmarks.length;
        _bookmarks.removeWhere((b) => b['verseId'] == verseId);
        if (_bookmarks.length != lengthBefore) {
          await _saveBookmarks();
          return 1;
        }
      }

      if (table == 'highlights') {
        final lengthBefore = _highlights.length;
        _highlights.removeWhere((h) => h['verseId'] == verseId);
        if (_highlights.length != lengthBefore) {
          await _saveHighlights();
          return 1;
        }
      }

      if (table == 'notes') {
        final lengthBefore = _notes.length;
        _notes.removeWhere((n) => n['verseId'] == verseId);
        if (_notes.length != lengthBefore) {
          await _saveNotes();
          return 1;
        }
      }
    }

    return 0;
  }

  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    await init();

    if (table == 'notes' && where != null && whereArgs != null && where.contains('verseId = ?')) {
      final verseId = whereArgs[0] as int;
      final idx = _notes.indexWhere((n) => n['verseId'] == verseId);
      if (idx != -1) {
        _notes[idx] = {
          ..._notes[idx],
          ...values,
        };
        await _saveNotes();
        return 1;
      } else {

        return await insert(table, values);
      }
    }

    return 0;
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
