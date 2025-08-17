import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/article_model.dart';

class ArticleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'articles';

  // Get all active articles (simplified to avoid composite index issues)
  Stream<List<Article>> getActiveArticles() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final articles =
              snapshot.docs
                  .map((doc) => Article.fromMap({...doc.data(), 'id': doc.id}))
                  .toList();
          // Sort locally to avoid composite index requirement
          articles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return articles;
        });
  }

  // Get articles by category (simplified to avoid composite index issues)
  Stream<List<Article>> getArticlesByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
          final articles =
              snapshot.docs
                  .map((doc) => Article.fromMap({...doc.data(), 'id': doc.id}))
                  .toList();
          // Sort locally to avoid composite index requirement
          articles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return articles;
        });
  }

  // Search articles
  Stream<List<Article>> searchArticles(String query) {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Article.fromMap({...doc.data(), 'id': doc.id}))
              .where(
                (article) =>
                    article.title.toLowerCase().contains(query.toLowerCase()) ||
                    article.content.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
        });
  }

  // Get article by ID
  Future<Article?> getArticleById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Article.fromMap({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Error getting article: $e');
      return null;
    }
  }

  // Increment view count
  Future<void> incrementViews(String articleId) async {
    try {
      await _firestore.collection(_collection).doc(articleId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing views: $e');
    }
  }

  // Toggle article visibility (admin feature)
  Future<void> toggleArticleVisibility(String articleId, bool isActive) async {
    try {
      await _firestore.collection(_collection).doc(articleId).update({
        'isActive': isActive,
      });
    } catch (e) {
      print('Error toggling visibility: $e');
    }
  }

  // Add new article (admin feature)
  Future<void> addArticle(Article article) async {
    try {
      await _firestore.collection(_collection).add(article.toMap());
    } catch (e) {
      print('Error adding article: $e');
    }
  }

  // Update article (admin feature)
  Future<void> updateArticle(Article article) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(article.id)
          .update(article.toMap());
    } catch (e) {
      print('Error updating article: $e');
    }
  }

  // Delete article (admin feature)
  Future<void> deleteArticle(String articleId) async {
    try {
      await _firestore.collection(_collection).doc(articleId).delete();
    } catch (e) {
      print('Error deleting article: $e');
    }
  }
}
