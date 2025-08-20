class Article {
  final String id;
  final String title;
  final String content;
  final String category; // "Trimester 1", "Trimester 2", "Trimester 3"
  final int readTime; // in minutes
  final int views; // view counter
  final bool isActive; // admin toggle
  final DateTime createdAt;
  final bool isLiked; // user liked this article
  final bool isBookmarked; // user bookmarked this article

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.readTime,
    required this.views,
    required this.isActive,
    required this.createdAt,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? '',
      readTime: map['readTime'] ?? 0,
      views: map['views'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt:
          map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
      isLiked: map['isLiked'] ?? false,
      isBookmarked: map['isBookmarked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'readTime': readTime,
      'views': views,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'isLiked': isLiked,
      'isBookmarked': isBookmarked,
    };
  }

  Article copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    int? readTime,
    int? views,
    bool? isActive,
    DateTime? createdAt,
    bool? isLiked,
    bool? isBookmarked,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      readTime: readTime ?? this.readTime,
      views: views ?? this.views,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
