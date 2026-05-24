/// Note model for personal verse notes.
class Note {
  final int? id;
  final int verseId;
  final int bookId;
  final int chapterNumber;
  final int verseNumber;
  final String content;
  final String createdAt;
  final String updatedAt;

  // Joined fields
  final String? bookName;
  final String? bookNameEnglish;
  final String? verseText;
  final String? verseTextEnglish;

  const Note({
    this.id,
    required this.verseId,
    required this.bookId,
    required this.chapterNumber,
    required this.verseNumber,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.bookName,
    this.bookNameEnglish,
    this.verseText,
    this.verseTextEnglish,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      verseId: map['verseId'] as int,
      bookId: map['bookId'] as int,
      chapterNumber: map['chapterNumber'] as int,
      verseNumber: map['verseNumber'] as int,
      content: map['content'] as String,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
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
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Note copyWith({String? content, String? updatedAt}) {
    return Note(
      id: id,
      verseId: verseId,
      bookId: bookId,
      chapterNumber: chapterNumber,
      verseNumber: verseNumber,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bookName: bookName,
      bookNameEnglish: bookNameEnglish,
      verseText: verseText,
      verseTextEnglish: verseTextEnglish,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Note && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
