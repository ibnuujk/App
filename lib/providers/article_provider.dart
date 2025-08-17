import 'package:flutter/foundation.dart';
import '../models/article_model.dart';
import '../services/article_service.dart';

class ArticleProvider with ChangeNotifier {
  final ArticleService _articleService = ArticleService();

  List<Article> _articles = [];
  List<Article> _filteredArticles = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Article> get articles => _articles;
  List<Article> get filteredArticles => _filteredArticles;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize articles
  void initializeArticles() {
    _loadArticles();
  }

  // Load all articles
  void _loadArticles() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _articleService.getActiveArticles().listen(
      (articles) {
        _articles = articles;
        _applyFilters();
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Filter articles by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Search articles
  void searchArticles(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters and search
  void _applyFilters() {
    _filteredArticles =
        _articles.where((article) {
          bool categoryMatch =
              _selectedCategory == 'All' ||
              article.category == _selectedCategory;

          bool searchMatch =
              _searchQuery.isEmpty ||
              article.title.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              article.content.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );

          return categoryMatch && searchMatch;
        }).toList();
  }

  // Get articles by category
  List<Article> getArticlesByCategory(String category) {
    return _articles.where((article) => article.category == category).toList();
  }

  // Get categories
  List<String> get categories {
    List<String> cats = ['All'];
    cats.addAll(_articles.map((article) => article.category).toSet().toList());
    return cats;
  }

  // Increment view count
  Future<void> incrementViews(String articleId) async {
    await _articleService.incrementViews(articleId);
    // Update local article
    final index = _articles.indexWhere((article) => article.id == articleId);
    if (index != -1) {
      _articles[index] = _articles[index].copyWith(
        views: _articles[index].views + 1,
      );
      _applyFilters();
      notifyListeners();
    }
  }

  // Toggle article visibility (admin)
  Future<void> toggleArticleVisibility(String articleId, bool isActive) async {
    await _articleService.toggleArticleVisibility(articleId, isActive);
    // Update local article
    final index = _articles.indexWhere((article) => article.id == articleId);
    if (index != -1) {
      _articles[index] = _articles[index].copyWith(isActive: isActive);
      _applyFilters();
      notifyListeners();
    }
  }

  // Add new article (admin)
  Future<void> addArticle(Article article) async {
    await _articleService.addArticle(article);
    // Reload articles to get the new one
    _loadArticles();
  }

  // Update article (admin)
  Future<void> updateArticle(Article article) async {
    await _articleService.updateArticle(article);
    // Reload articles to get the updated one
    _loadArticles();
  }

  // Delete article (admin)
  Future<void> deleteArticle(String articleId) async {
    await _articleService.deleteArticle(articleId);
    // Remove from local list
    _articles.removeWhere((article) => article.id == articleId);
    _applyFilters();
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }
}
