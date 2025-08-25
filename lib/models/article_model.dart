class Article {
  final String id;
  final String title;
  final String
  description; // Changed from content to description for brief info
  final String websiteUrl; // New field for website link
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
    required this.description,
    required this.websiteUrl,
    required this.category,
    required this.readTime,
    required this.views,
    required this.isActive,
    required this.createdAt,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  factory Article.fromMap(Map<String, dynamic> map) {
    try {
      print('Parsing article from map: ${map.keys.toList()}');

      final id = map['id'] ?? '';
      final title = map['title'] ?? '';
      final description = map['description'] ?? map['content'] ?? '';
      final websiteUrl = map['websiteUrl'] ?? '';
      final category = map['category'] ?? '';
      final readTime = map['readTime'] ?? 0;
      final views = map['views'] ?? 0;
      final isActive = map['isActive'] ?? true;

      DateTime createdAt;
      try {
        createdAt =
            map['createdAt'] != null
                ? DateTime.parse(map['createdAt'])
                : DateTime.now();
      } catch (e) {
        print('Error parsing createdAt: $e, using current time');
        createdAt = DateTime.now();
      }

      final isLiked = map['isLiked'] ?? false;
      final isBookmarked = map['isBookmarked'] ?? false;

      print('Successfully parsed article: $title (ID: $id)');

      return Article(
        id: id,
        title: title,
        description: description,
        websiteUrl: websiteUrl,
        category: category,
        readTime: readTime,
        views: views,
        isActive: isActive,
        createdAt: createdAt,
        isLiked: isLiked,
        isBookmarked: isBookmarked,
      );
    } catch (e) {
      print('Error in Article.fromMap: $e');
      print('Map data: $map');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'websiteUrl': websiteUrl,
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
    String? description,
    String? websiteUrl,
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
      description: description ?? this.description,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      category: category ?? this.category,
      readTime: readTime ?? this.readTime,
      views: views ?? this.views,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Article &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.websiteUrl == websiteUrl &&
        other.category == category &&
        other.readTime == readTime &&
        other.views == views &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.isLiked == isLiked &&
        other.isBookmarked == isBookmarked;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        websiteUrl.hashCode ^
        category.hashCode ^
        readTime.hashCode ^
        views.hashCode ^
        isActive.hashCode ^
        createdAt.hashCode ^
        isLiked.hashCode ^
        isBookmarked.hashCode;
  }
}
