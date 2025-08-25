import 'package:flutter/foundation.dart';
import '../models/article_model.dart';
import '../services/article_service.dart';

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
          article.description.toLowerCase().contains(lowercaseQuery) ||
          article.category.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Initialize articles
  Future<void> initializeArticles() async {
    try {
      print('ArticleProvider: Initializing articles...');
      _setLoading(true);
      _clearError();

      // Initialize the article reads collection structure
      await _articleService.initializeArticleReadsCollection();

      final articles = await _articleService.getActiveArticles();
      print(
        'ArticleProvider: Received ${articles.length} articles from service',
      );

      _articles = articles;
      print('ArticleProvider: Articles initialized successfully');

      _setLoading(false);
    } catch (e) {
      print('ArticleProvider: Error initializing articles: $e');
      print('ArticleProvider: Stack trace: ${StackTrace.current}');
      _setError(e.toString());
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
        description: article.description,
        websiteUrl: article.websiteUrl,
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

  // Increment views for an article
  Future<void> incrementViews(String articleId, String userId) async {
    try {
      // Get the new view count from the service
      final newViewCount = await _articleService.incrementViews(
        articleId,
        userId,
      );

      // Update the local article with the new view count
      final articleIndex = _articles.indexWhere(
        (article) => article.id == articleId,
      );
      if (articleIndex != -1) {
        final article = _articles[articleIndex];
        final updatedArticle = Article(
          id: article.id,
          title: article.title,
          description: article.description,
          websiteUrl: article.websiteUrl,
          category: article.category,
          readTime: article.readTime,
          views: newViewCount,
          isActive: article.isActive,
          createdAt: article.createdAt,
        );

        _articles[articleIndex] = updatedArticle;
        notifyListeners();
      }
    } catch (e) {
      print('Error incrementing views: $e');
      _setError('Error incrementing views: ${e.toString()}');
    }
  }

  // Get unique reader statistics
  Future<Map<String, dynamic>> getUniqueReaderStatistics() async {
    try {
      return await _articleService.getUniqueReaderStatistics();
    } catch (e) {
      print('Error getting unique reader statistics: $e');
      return {
        'totalUniqueReaders': 0,
        'totalArticleReads': 0,
        'averageReadersPerArticle': 0,
        'articlesWithReaders': 0,
      };
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
    // Note: We can't modify the article object directly, so this is conceptual

    // Sort by views (simplified approach)
    sortedArticles.sort((a, b) => b.views.compareTo(a.views));
    return sortedArticles.take(limit).toList();
  }

  // Get article statistics
  Future<Map<String, dynamic>> getArticleStatistics() async {
    try {
      // Get unique reader statistics
      final readerStats = await getUniqueReaderStatistics();

      final totalArticles = _articles.length;
      final activeArticles = _articles.where((a) => a.isActive).length;
      final totalViews = _articles.fold(
        0,
        (sum, article) => sum + article.views,
      );
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
        'totalUniqueReaders': readerStats['totalUniqueReaders'],
        'averageReadersPerArticle': readerStats['averageReadersPerArticle'],
        'averageReadTime': avgReadTime.round(),
        'categoryDistribution': categoryDistribution,
      };
    } catch (e) {
      print('Error getting article statistics: $e');
      return {
        'totalArticles': 0,
        'activeArticles': 0,
        'totalViews': 0,
        'totalUniqueReaders': 0,
        'averageReadersPerArticle': 0,
        'averageReadTime': 0,
        'categoryDistribution': {},
      };
    }
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

  // Refresh view counts from Firebase to ensure accuracy
  Future<void> refreshViewCounts() async {
    try {
      _setLoading(true);

      // Get fresh data from Firebase
      final freshArticles = await _articleService.getActiveArticles();

      // Update local articles with fresh view counts
      for (int i = 0; i < _articles.length; i++) {
        final freshArticle = freshArticles.firstWhere(
          (a) => a.id == _articles[i].id,
          orElse: () => _articles[i],
        );

        if (freshArticle.views != _articles[i].views) {
          _articles[i] = freshArticle;
        }
      }

      notifyListeners();
      print('View counts refreshed from Firebase');
    } catch (e) {
      print('Error refreshing view counts: $e');
      _setError('Error refreshing view counts: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Dispose
  @override
  void dispose() {
    super.dispose();
  }
}
