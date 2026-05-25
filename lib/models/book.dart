
class Book {
  final int id;
  final String name;
  final String nameEnglish;
  final String testament;
  final int totalChapters;
  final int orderIndex;

  const Book({
    required this.id,
    required this.name,
    required this.nameEnglish,
    required this.testament,
    required this.totalChapters,
    required this.orderIndex,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int,
      name: map['name'] as String,
      nameEnglish: map['nameEnglish'] as String,
      testament: map['testament'] as String,
      totalChapters: map['totalChapters'] as int,
      orderIndex: map['orderIndex'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameEnglish': nameEnglish,
      'testament': testament,
      'totalChapters': totalChapters,
      'orderIndex': orderIndex,
    };
  }

  Book copyWith({
    int? id,
    String? name,
    String? nameEnglish,
    String? testament,
    int? totalChapters,
    int? orderIndex,
  }) {
    return Book(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      testament: testament ?? this.testament,
      totalChapters: totalChapters ?? this.totalChapters,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  String toString() => 'Book($nameEnglish, $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Book && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
