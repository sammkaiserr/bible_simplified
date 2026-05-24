/// Shared key model representing a specific chapter in a book,
/// used to index database notes, highlights, and annotations.
class ChapterKey {
  final int bookId;
  final int chapter;

  const ChapterKey(this.bookId, this.chapter);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterKey &&
          runtimeType == other.runtimeType &&
          bookId == other.bookId &&
          chapter == other.chapter;

  @override
  int get hashCode => bookId.hashCode ^ chapter.hashCode;
}
