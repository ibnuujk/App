import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/article_model.dart';

class ArticleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'articles';

  // Get all active articles (simplified to avoid composite index issues)
  Future<List<Article>> getActiveArticles() async {
    try {
      final snapshot =
          await _firestore
              .collection(_collection)
              .where('isActive', isEqualTo: true)
              .get();

      final articles =
          snapshot.docs
              .map((doc) => Article.fromMap({...doc.data(), 'id': doc.id}))
              .toList();

      // Sort locally to avoid composite index requirement
      articles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return articles;
    } catch (e) {
      print('Error getting active articles: $e');
      return [];
    }
  }

  // Get articles by category (simplified to avoid composite index issues)
  Future<List<Article>> getArticlesByCategory(String category) async {
    try {
      final snapshot =
          await _firestore
              .collection(_collection)
              .where('isActive', isEqualTo: true)
              .where('category', isEqualTo: category)
              .get();

      final articles =
          snapshot.docs
              .map((doc) => Article.fromMap({...doc.data(), 'id': doc.id}))
              .toList();

      // Sort locally to avoid composite index requirement
      articles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return articles;
    } catch (e) {
      print('Error getting articles by category: $e');
      return [];
    }
  }

  // Search articles
  Future<List<Article>> searchArticles(String query) async {
    try {
      final snapshot =
          await _firestore
              .collection(_collection)
              .where('isActive', isEqualTo: true)
              .get();

      return snapshot.docs
          .map((doc) => Article.fromMap({...doc.data(), 'id': doc.id}))
          .where(
            (article) =>
                article.title.toLowerCase().contains(query.toLowerCase()) ||
                article.content.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      print('Error searching articles: $e');
      return [];
    }
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

  // Increment view count and track unique user
  Future<int> incrementViews(String articleId, String userId) async {
    try {
      // Get current document to check if it exists
      final docRef = _firestore.collection(_collection).doc(articleId);
      final doc = await docRef.get();

      if (!doc.exists) {
        print('Article not found: $articleId');
        return 0;
      }

      // Check if this is an anonymous user (don't track anonymous users)
      bool isAnonymousUser = userId.startsWith('anonymous_');

      if (!isAnonymousUser) {
        // Check if this user has already read this article
        final userReadsRef = _firestore
            .collection('article_reads')
            .doc('${articleId}_${userId}');

        final userReadDoc = await userReadsRef.get();
        bool isNewReader = false;

        if (!userReadDoc.exists) {
          // This is a new reader - track the read
          await userReadsRef.set({
            'articleId': articleId,
            'userId': userId,
            'readAt': FieldValue.serverTimestamp(),
            'articleTitle': doc.data()?['title'] ?? 'Unknown',
          });
          isNewReader = true;
        }

        // Only increment views if this is a new reader
        if (isNewReader) {
          await docRef.update({'views': FieldValue.increment(1)});
        }
      } else {
        // For anonymous users, just increment the view count
        await docRef.update({'views': FieldValue.increment(1)});
      }

      // Get updated document to return new view count
      final updatedDoc = await docRef.get();
      final updatedViews = (updatedDoc.data()?['views'] ?? 0) as int;

      print(
        'Views incremented for article $articleId: ${updatedViews} (User: ${isAnonymousUser ? 'Anonymous' : 'Registered'})',
      );
      return updatedViews;
    } catch (e) {
      print('Error incrementing views: $e');
      rethrow;
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

  // Clear all articles (admin feature)
  Future<void> clearAllArticles() async {
    try {
      // Get all article documents
      final snapshot = await _firestore.collection(_collection).get();

      // Delete each document in batches
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      // Commit the batch
      await batch.commit();
      print('Successfully cleared all articles');
    } catch (e) {
      print('Error clearing all articles: $e');
      throw e; // Re-throw to handle in provider
    }
  }

  // Get article statistics
  Future<Map<String, dynamic>> getArticleStatistics() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();

      final totalArticles = snapshot.docs.length;
      int activeArticles = 0;
      int totalViews = 0;
      int totalReadTime = 0;
      final categoryDistribution = <String, int>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final isActive = data['isActive'] ?? false;
        final views = (data['views'] ?? 0) as int;
        final readTime = (data['readTime'] ?? 0) as int;
        final category = data['category'] ?? 'Unknown';

        if (isActive) activeArticles++;
        totalViews += views;
        totalReadTime += readTime;

        categoryDistribution[category] =
            (categoryDistribution[category] ?? 0) + 1;
      }

      final avgReadTime =
          totalArticles > 0 ? totalReadTime / totalArticles : 0.0;

      return {
        'totalArticles': totalArticles,
        'activeArticles': activeArticles,
        'totalViews': totalViews,
        'averageReadTime': avgReadTime.round(),
        'categoryDistribution': categoryDistribution,
      };
    } catch (e) {
      print('Error getting article statistics: $e');
      return {
        'totalArticles': 0,
        'activeArticles': 0,
        'totalViews': 0,
        'averageReadTime': 0,
        'categoryDistribution': {},
      };
    }
  }

  // Initialize article reads collection structure
  Future<void> initializeArticleReadsCollection() async {
    try {
      // Create a sample document to ensure the collection exists
      final sampleRef = _firestore.collection('article_reads').doc('sample');
      await sampleRef.set({
        'articleId': 'sample',
        'userId': 'sample',
        'readAt': FieldValue.serverTimestamp(),
        'articleTitle': 'Sample Article',
        'created': true,
      });

      // Delete the sample document
      await sampleRef.delete();

      print('Article reads collection initialized successfully');
    } catch (e) {
      print('Error initializing article reads collection: $e');
    }
  }

  // Get unique reader statistics
  Future<Map<String, dynamic>> getUniqueReaderStatistics() async {
    try {
      // Get all unique article reads
      final readsSnapshot = await _firestore.collection('article_reads').get();

      // Count unique users who have read articles (exclude anonymous users)
      final uniqueUsers = <String>{};
      final articleReads =
          <String, Set<String>>{}; // articleId -> Set of userIds

      for (final doc in readsSnapshot.docs) {
        final data = doc.data();
        final userId = data['userId'] as String?;
        final articleId = data['articleId'] as String?;

        if (userId != null &&
            articleId != null &&
            !userId.startsWith('anonymous_')) {
          uniqueUsers.add(userId);

          if (!articleReads.containsKey(articleId)) {
            articleReads[articleId] = <String>{};
          }
          articleReads[articleId]!.add(userId);
        }
      }

      // Calculate total unique readers across all articles
      final totalUniqueReaders = uniqueUsers.length;

      // Calculate average readers per article
      final avgReadersPerArticle =
          articleReads.isNotEmpty
              ? totalUniqueReaders / articleReads.length
              : 0.0;

      return {
        'totalUniqueReaders': totalUniqueReaders,
        'totalArticleReads': readsSnapshot.docs.length,
        'averageReadersPerArticle': avgReadersPerArticle.round(),
        'articlesWithReaders': articleReads.length,
      };
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
}
