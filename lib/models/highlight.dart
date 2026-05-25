
class Highlight {
  final int? id;
  final int verseId;
  final int bookId;
  final int chapterNumber;
  final int verseNumber;
  final String colorHex;
  final String createdAt;

  final String? bookName;
  final String? bookNameEnglish;
  final String? verseText;
  final String? verseTextEnglish;

  const Highlight({
    this.id,
    required this.verseId,
    required this.bookId,
    required this.chapterNumber,
    required this.verseNumber,
    required this.colorHex,
    required this.createdAt,
    this.bookName,
    this.bookNameEnglish,
    this.verseText,
    this.verseTextEnglish,
  });

  factory Highlight.fromMap(Map<String, dynamic> map) {
    return Highlight(
      id: map['id'] as int?,
      verseId: map['verseId'] as int,
      bookId: map['bookId'] as int,
      chapterNumber: map['chapterNumber'] as int,
      verseNumber: map['verseNumber'] as int,
      colorHex: map['colorHex'] as String,
      createdAt: map['createdAt'] as String,
      bookName: map['bookName'] as String?,
      bookNameEnglish: map['bookNameEnglish'] as String?,
      verseText: map['verseText'] as String?,
      verseTextEnglish: map['verseTextEnglish'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'verseId': verseId,
      'bookId': bookId,
      'chapterNumber': chapterNumber,
      'verseNumber': verseNumber,
      'colorHex': colorHex,
      'createdAt': createdAt,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Highlight && verseId == other.verseId;

  @override
  int get hashCode => verseId.hashCode;
}
