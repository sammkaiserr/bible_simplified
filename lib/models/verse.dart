
class Verse {
  final int id;
  final int bookId;
  final int chapterNumber;
  final int verseNumber;
  final String originalText;
  final String? simpleText;
  final String? originalTextEnglish;
  final String? simpleTextEnglish;

  const Verse({
    required this.id,
    required this.bookId,
    required this.chapterNumber,
    required this.verseNumber,
    required this.originalText,
    this.simpleText,
    this.originalTextEnglish,
    this.simpleTextEnglish,
  });

  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(
      id: map['id'] as int,
      bookId: map['bookId'] as int,
      chapterNumber: map['chapterNumber'] as int,
      verseNumber: map['verseNumber'] as int,
      originalText: map['originalText'] as String,
      simpleText: map['simpleText'] as String?,
      originalTextEnglish: map['originalTextEnglish'] as String?,
      simpleTextEnglish: map['simpleTextEnglish'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'chapterNumber': chapterNumber,
      'verseNumber': verseNumber,
      'originalText': originalText,
      'simpleText': simpleText,
      'originalTextEnglish': originalTextEnglish,
      'simpleTextEnglish': simpleTextEnglish,
    };
  }

  Verse copyWith({
    int? id,
    int? bookId,
    int? chapterNumber,
    int? verseNumber,
    String? originalText,
    String? simpleText,
    String? originalTextEnglish,
    String? simpleTextEnglish,
  }) {
    return Verse(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      verseNumber: verseNumber ?? this.verseNumber,
      originalText: originalText ?? this.originalText,
      simpleText: simpleText ?? this.simpleText,
      originalTextEnglish: originalTextEnglish ?? this.originalTextEnglish,
      simpleTextEnglish: simpleTextEnglish ?? this.simpleTextEnglish,
    );
  }

  String get reference => '$bookId:$chapterNumber:$verseNumber';

  @override
  String toString() => 'Verse($bookId $chapterNumber:$verseNumber)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Verse && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
