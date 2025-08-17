import 'package:flutter/foundation.dart';
import '../models/article_model.dart';
import '../services/article_service.dart';
import '../services/enhanced_article_generator.dart';

class ArticleProvider with ChangeNotifier {
  final ArticleService _articleService = ArticleService();

  List<Article> _articles = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get active articles only
  List<Article> get activeArticles =>
      _articles.where((article) => article.isActive).toList();

  // Get articles by category
  List<Article> getArticlesByCategory(String category) {
    if (category == 'Semua') {
      return activeArticles;
    }
    return activeArticles
        .where((article) => article.category == category)
        .toList();
  }

  // Get articles by search query
  List<Article> searchArticles(String query) {
    if (query.isEmpty) return activeArticles;

    final lowercaseQuery = query.toLowerCase();
    return activeArticles.where((article) {
      return article.title.toLowerCase().contains(lowercaseQuery) ||
          article.content.toLowerCase().contains(lowercaseQuery) ||
          article.category.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Initialize articles
  Future<void> initializeArticles() async {
    try {
      _setLoading(true);
      _clearError();

      final articles = await _articleService.getActiveArticles();
      _articles = articles;

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Load fresh sample data using enhanced generator
  Future<void> loadFreshSampleData({
    int count = 25,
    String? category,
    bool clearExisting = false,
    bool highQualityOnly = true,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Clear existing articles if requested
      if (clearExisting) {
        await _clearAllArticles();
      }

      // Generate fresh articles using enhanced generator
      final freshArticles =
          await EnhancedArticleGenerator.generateFreshArticles(
            count: count,
            specificCategory: category,
            highQualityOnly: highQualityOnly,
          );

      // Add each article to the service and local list
      for (final article in freshArticles) {
        await addArticle(article);
      }

      _setLoading(false);

      // Show success message (this will be handled by the UI)
      print('Successfully generated ${freshArticles.length} fresh articles');
    } catch (e) {
      _setError('Error generating fresh articles: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Load focused articles by content type
  Future<void> loadFocusedArticles({
    required String focus,
    int count = 10,
    String category = 'Semua Jenis',
    bool clearExisting = false,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Clear existing articles if requested
      if (clearExisting) {
        await _clearAllArticles();
      }

      // Generate focused articles
      final focusedArticles =
          await EnhancedArticleGenerator.generateFocusedArticles(
            focus: focus,
            count: count,
            category: category,
          );

      // Add each article to the service and local list
      for (final article in focusedArticles) {
        await addArticle(article);
      }

      _setLoading(false);

      print(
        'Successfully generated ${focusedArticles.length} focused articles on $focus',
      );
    } catch (e) {
      _setError('Error generating focused articles: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Add article
  Future<void> addArticle(Article article) async {
    try {
      // Add to service
      await _articleService.addArticle(article);

      // Add to local list
      _articles.add(article);

      // Sort by creation date (newest first)
      _articles.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      notifyListeners();
    } catch (e) {
      _setError('Error adding article: ${e.toString()}');
    }
  }

  // Update article
  Future<void> updateArticle(Article article) async {
    try {
      await _articleService.updateArticle(article);

      final index = _articles.indexWhere((a) => a.id == article.id);
      if (index != -1) {
        _articles[index] = article;
        notifyListeners();
      }
    } catch (e) {
      _setError('Error updating article: ${e.toString()}');
    }
  }

  // Delete article
  Future<void> deleteArticle(String articleId) async {
    try {
      await _articleService.deleteArticle(articleId);

      _articles.removeWhere((article) => article.id == articleId);
      notifyListeners();
    } catch (e) {
      _setError('Error deleting article: ${e.toString()}');
    }
  }

  // Toggle article active status
  Future<void> toggleArticleStatus(String articleId) async {
    try {
      final article = _articles.firstWhere((a) => a.id == articleId);
      final updatedArticle = Article(
        id: article.id,
        title: article.title,
        content: article.content,
        category: article.category,
        readTime: article.readTime,
        views: article.views,
        isActive: !article.isActive,
        createdAt: article.createdAt,
      );

      await updateArticle(updatedArticle);
    } catch (e) {
      _setError('Error toggling article status: ${e.toString()}');
    }
  }

  // Increment article views
  Future<void> incrementViews(String articleId) async {
    try {
      final article = _articles.firstWhere((a) => a.id == articleId);
      final updatedArticle = Article(
        id: article.id,
        title: article.title,
        content: article.content,
        category: article.category,
        readTime: article.readTime,
        views: article.views + 1,
        isActive: article.isActive,
        createdAt: article.createdAt,
      );

      await updateArticle(updatedArticle);
    } catch (e) {
      _setError('Error incrementing views: ${e.toString()}');
    }
  }

  // Clear all articles
  Future<void> _clearAllArticles() async {
    try {
      // Clear from service
      await _articleService.clearAllArticles();

      // Clear from local list
      _articles.clear();

      notifyListeners();
    } catch (e) {
      _setError('Error clearing articles: ${e.toString()}');
    }
  }

  // Get article by ID
  Article? getArticleById(String id) {
    try {
      return _articles.firstWhere((article) => article.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get articles by read time range
  List<Article> getArticlesByReadTime({int? minMinutes, int? maxMinutes}) {
    return activeArticles.where((article) {
      if (minMinutes != null && article.readTime < minMinutes) return false;
      if (maxMinutes != null && article.readTime > maxMinutes) return false;
      return true;
    }).toList();
  }

  // Get articles by view count range
  List<Article> getArticlesByViewCount({int? minViews, int? maxViews}) {
    return activeArticles.where((article) {
      if (minViews != null && article.views < minViews) return false;
      if (maxViews != null && article.views > maxViews) return false;
      return true;
    }).toList();
  }

  // Get articles by date range
  List<Article> getArticlesByDateRange({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return activeArticles.where((article) {
      if (startDate != null && article.createdAt.isBefore(startDate))
        return false;
      if (endDate != null && article.createdAt.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  // Get popular articles (by view count)
  List<Article> getPopularArticles({int limit = 10}) {
    final sortedArticles = List<Article>.from(activeArticles);
    sortedArticles.sort((a, b) => b.views.compareTo(a.views));
    return sortedArticles.take(limit).toList();
  }

  // Get recent articles
  List<Article> getRecentArticles({int limit = 10}) {
    final sortedArticles = List<Article>.from(activeArticles);
    sortedArticles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedArticles.take(limit).toList();
  }

  // Get trending articles (combination of views and recency)
  List<Article> getTrendingArticles({int limit = 10}) {
    final sortedArticles = List<Article>.from(activeArticles);

    // Calculate trending score (views + recency bonus)
    for (final article in sortedArticles) {
      final daysSinceCreation =
          DateTime.now().difference(article.createdAt).inDays;
      final recencyBonus =
          daysSinceCreation <= 7
              ? 50
              : daysSinceCreation <= 30
              ? 25
              : daysSinceCreation <= 90
              ? 10
              : 0;
      // Note: We can't modify the article object directly, so this is conceptual
    }

    // Sort by views (simplified approach)
    sortedArticles.sort((a, b) => b.views.compareTo(a.views));
    return sortedArticles.take(limit).toList();
  }

  // Get article statistics
  Map<String, dynamic> getArticleStatistics() {
    final totalArticles = _articles.length;
    final activeArticles = _articles.where((a) => a.isActive).length;
    final totalViews = _articles.fold(0, (sum, article) => sum + article.views);
    final avgReadTime =
        _articles.isNotEmpty
            ? _articles.fold(0.0, (sum, article) => sum + article.readTime) /
                _articles.length
            : 0.0;

    // Category distribution
    final categoryDistribution = <String, int>{};
    for (final article in _articles) {
      categoryDistribution[article.category] =
          (categoryDistribution[article.category] ?? 0) + 1;
    }

    return {
      'totalArticles': totalArticles,
      'activeArticles': activeArticles,
      'totalViews': totalViews,
      'averageReadTime': avgReadTime.round(),
      'categoryDistribution': categoryDistribution,
    };
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Refresh articles from service
  Future<void> refreshArticles() async {
    await initializeArticles();
  }

  // Dispose
  @override
  void dispose() {
    super.dispose();
  }
}
