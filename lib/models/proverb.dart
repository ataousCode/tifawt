class Proverb {
  final String id;
  final String text;
  final String author;
  final String categoryId;
  final String backgroundImageUrl;
  final DateTime createdAt;
  final int viewCount;
  final bool isActive;

  Proverb({
    required this.id,
    required this.text,
    required this.author,
    required this.categoryId,
    required this.backgroundImageUrl,
    required this.createdAt,
    this.viewCount = 0,
    this.isActive = true,
  });

  factory Proverb.fromJson(Map<String, dynamic> json) {
    return Proverb(
      id: json['id'] as String,
      text: json['text'] as String,
      author: json['author'] as String,
      categoryId: json['categoryId'] as String,
      backgroundImageUrl: json['backgroundImageUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      viewCount: json['viewCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'categoryId': categoryId,
      'backgroundImageUrl': backgroundImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'viewCount': viewCount,
      'isActive': isActive,
    };
  }

  Proverb copyWith({
    String? id,
    String? text,
    String? author,
    String? categoryId,
    String? backgroundImageUrl,
    DateTime? createdAt,
    int? viewCount,
    bool? isActive,
  }) {
    return Proverb(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      categoryId: categoryId ?? this.categoryId,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      createdAt: createdAt ?? this.createdAt,
      viewCount: viewCount ?? this.viewCount,
      isActive: isActive ?? this.isActive,
    );
  }
}
