import 'dart:math';
import '../models/article_model.dart';
import '../data/content_templates.dart';
import '../data/topic_variations.dart';
import '../data/language_patterns.dart';

class EnhancedArticleGenerator {
  static final Random _random = Random();

  // Main generation method
  static Future<List<Article>> generateFreshArticles({
    int count = 25,
    String? specificCategory,
    bool highQualityOnly = true,
  }) async {
    List<Article> articles = [];

    if (specificCategory != null && specificCategory != 'Semua Jenis') {
      // Generate for specific category
      articles = _generateForSpecificCategory(specificCategory, count);
    } else {
      // Generate balanced mix for all categories
      articles = _generateBalancedMix(count);
    }

    // Apply quality filter if requested
    if (highQualityOnly) {
      articles = _filterHighQuality(articles);
    }

    // Ensure unique content
    articles = _ensureUniqueContent(articles);

    return articles;
  }

  // Generate balanced mix of articles
  static List<Article> _generateBalancedMix(int totalCount) {
    List<Article> articles = [];
    final categories = ['Trimester 1', 'Trimester 2', 'Trimester 3'];
    final articlesPerCategory = (totalCount / categories.length).ceil();

    for (String category in categories) {
      final categoryArticles = _generateForCategory(
        category,
        articlesPerCategory,
      );
      articles.addAll(categoryArticles);
    }

    // Trim to exact count if needed
    if (articles.length > totalCount) {
      articles = articles.take(totalCount).toList();
    }

    return articles;
  }

  // Generate articles for specific category
  static List<Article> _generateForSpecificCategory(
    String category,
    int count,
  ) {
    return _generateForCategory(category, count);
  }

  // Generate articles for a specific category
  static List<Article> _generateForCategory(String category, int count) {
    List<Article> articles = [];

    // Get templates for this category
    final templates = ContentTemplates.getTemplatesForCategory(category);

    for (int i = 0; i < count; i++) {
      // Select random template
      final template = templates[_random.nextInt(templates.length)];

      // Get random topic
      final topic = TopicVariations.getRandomTopicForCategory(category);

      // Generate article
      final article = _generateArticleFromTemplate(
        template,
        topic,
        category,
        i,
      );
      articles.add(article);
    }

    return articles;
  }

  // Generate article from template
  static Article _generateArticleFromTemplate(
    Map<String, dynamic> template,
    String topic,
    String category,
    int index,
  ) {
    // Generate title
    final title = _generateTitle(template['title'], topic, category);

    // Generate content
    final content = _generateContent(template['content'], topic, category);

    // Calculate read time
    final readTime = _calculateReadTime(content);

    // Generate random creation date (within last 30 days)
    final createdAt = DateTime.now().subtract(
      Duration(days: _random.nextInt(30)),
    );

    return Article(
      id: 'artikel_${DateTime.now().millisecondsSinceEpoch}_$index',
      title: title,
      content: content,
      category: category,
      readTime: readTime,
      views: _random.nextInt(100),
      isActive: true,
      createdAt: createdAt,
    );
  }

  // Generate title from template
  static String _generateTitle(String template, String topic, String category) {
    String title = template;

    // Replace placeholders
    title = title.replaceAll('{topic}', topic);
    title = title.replaceAll('{category}', category);

    // Add variety
    title = _addTitleVariety(title, category);

    return title;
  }

  // Generate content from template
  static String _generateContent(
    String template,
    String topic,
    String category,
  ) {
    String content = template;

    // Replace placeholders
    content = content.replaceAll('{topic}', topic);
    content = content.replaceAll('{category}', category);

    // Add opening pattern
    content = _addOpeningPattern(content, topic, category);

    // Add middle content
    content = _addMiddleContent(content, topic, category);

    // Add closing pattern
    content = _addClosingPattern(content, topic, category);

    // Ensure minimum content length
    content = _ensureMinimumLength(content, category);

    return content;
  }

  // Add opening pattern
  static String _addOpeningPattern(
    String content,
    String topic,
    String category,
  ) {
    final openingPatterns = LanguagePatterns.getOpeningPatterns();
    final pattern = openingPatterns[_random.nextInt(openingPatterns.length)];

    String opening = pattern;
    opening = opening.replaceAll('{topic}', topic);
    opening = opening.replaceAll('{category}', category);

    return opening + '\n\n' + content;
  }

  // Add middle content
  static String _addMiddleContent(
    String content,
    String topic,
    String category,
  ) {
    final middlePatterns = LanguagePatterns.getMiddlePatterns();
    final pattern = middlePatterns[_random.nextInt(middlePatterns.length)];

    String middle = pattern;
    middle = middle.replaceAll('{topic}', topic);

    // Add specific details based on category
    middle += _getCategorySpecificDetails(category, topic);

    return content + '\n\n' + middle;
  }

  // Add closing pattern
  static String _addClosingPattern(
    String content,
    String topic,
    String category,
  ) {
    final closingPatterns = LanguagePatterns.getClosingPatterns();
    final pattern = closingPatterns[_random.nextInt(closingPatterns.length)];

    String closing = pattern;
    closing = closing.replaceAll('{topic}', topic);

    return content + '\n\n' + closing;
  }

  // Get category-specific details
  static String _getCategorySpecificDetails(String category, String topic) {
    switch (category) {
      case 'Trimester 1':
        return _getTrimester1Details(topic);
      case 'Trimester 2':
        return _getTrimester2Details(topic);
      case 'Trimester 3':
        return _getTrimester3Details(topic);
      default:
        return '';
    }
  }

  // Get Trimester 1 specific details
  static String _getTrimester1Details(String topic) {
    final details = [
      'Pada trimester pertama, perkembangan janin sangat cepat dan kritis.',
      'Organ-organ vital mulai terbentuk pada periode ini.',
      'Nutrisi yang tepat sangat penting untuk mendukung perkembangan optimal.',
      'Konsultasi rutin dengan dokter kandungan sangat dianjurkan.',
      'Hindari aktivitas yang berisiko tinggi untuk kehamilan.',
    ];

    return details[_random.nextInt(details.length)];
  }

  // Get Trimester 2 specific details
  static String _getTrimester2Details(String topic) {
    final details = [
      'Trimester kedua sering disebut sebagai masa kehamilan yang paling nyaman.',
      'Janin mulai bergerak dan ibu dapat merasakan tendangan.',
      'Perut mulai membesar dan perubahan tubuh semakin terlihat.',
      'Energi ibu hamil biasanya meningkat pada periode ini.',
      'Waktu yang tepat untuk mulai mempersiapkan persalinan.',
    ];

    return details[_random.nextInt(details.length)];
  }

  // Get Trimester 3 specific details
  static String _getTrimester3Details(String topic) {
    final details = [
      'Trimester ketiga adalah masa persiapan akhir kehamilan.',
      'Janin sudah hampir sempurna dan siap untuk dilahirkan.',
      'Ibu hamil perlu lebih banyak istirahat pada periode ini.',
      'Persiapan persalinan dan pasca melahirkan sangat penting.',
      'Waspadai tanda-tanda persalinan yang mungkin muncul.',
    ];

    return details[_random.nextInt(details.length)];
  }

  // Add title variety
  static String _addTitleVariety(String title, String category) {
    final varietySuffixes = [
      'yang Wajib Diketahui',
      'untuk Ibu Hamil',
      'yang Penting',
      'yang Harus Diperhatikan',
      'untuk Kehamilan Sehat',
      'yang Optimal',
      'untuk Janin Sehat',
      'yang Tepat',
    ];

    if (_random.nextBool()) {
      final suffix = varietySuffixes[_random.nextInt(varietySuffixes.length)];
      title += ': $suffix';
    }

    return title;
  }

  // Ensure minimum content length
  static String _ensureMinimumLength(String content, String category) {
    const minLength = 200; // Minimum 200 characters

    if (content.length >= minLength) {
      return content;
    }

    // Add more content to meet minimum length
    final additionalContent = _getAdditionalContent(category);
    return content + '\n\n' + additionalContent;
  }

  // Get additional content
  static String _getAdditionalContent(String category) {
    final additionalContents = {
      'Trimester 1': [
        'Penting untuk diingat bahwa setiap kehamilan adalah unik. Konsultasikan selalu dengan dokter kandungan untuk mendapatkan saran yang tepat sesuai kondisi Anda.',
        'Jangan ragu untuk bertanya kepada tenaga medis jika ada hal yang mengkhawatirkan. Lebih baik bertanya daripada mengabaikan gejala yang tidak normal.',
        'Dukungan dari keluarga dan pasangan sangat penting dalam masa kehamilan. Jangan sungkan untuk meminta bantuan ketika membutuhkannya.',
      ],
      'Trimester 2': [
        'Manfaatkan energi yang meningkat untuk melakukan aktivitas yang menyenangkan dan bermanfaat. Olahraga ringan dapat membantu menjaga kebugaran tubuh.',
        'Ini adalah waktu yang tepat untuk mulai mempersiapkan kebutuhan bayi dan persalinan. Buat daftar dan siapkan semuanya secara bertahap.',
        'Jaga komunikasi dengan pasangan dan keluarga tentang perubahan yang Anda alami. Mereka perlu memahami kondisi Anda.',
      ],
      'Trimester 3': [
        'Persiapan mental sama pentingnya dengan persiapan fisik. Pelajari tentang proses persalinan dan pasca melahirkan.',
        'Pastikan semua kebutuhan bayi dan ibu sudah siap. Lebih baik siap lebih awal daripada terburu-buru di akhir.',
        'Jaga kesehatan dan stamina untuk menghadapi persalinan. Istirahat yang cukup sangat penting.',
      ],
    };

    final contents =
        additionalContents[category] ?? additionalContents['Trimester 1']!;
    return contents[_random.nextInt(contents.length)];
  }

  // Calculate read time
  static int _calculateReadTime(String content) {
    // Average reading speed: 200 words per minute
    final words = content.split(' ').length;
    final readTime = (words / 200).ceil();

    // Ensure minimum 3 minutes and maximum 15 minutes
    return readTime.clamp(3, 15);
  }

  // Filter high quality content
  static List<Article> _filterHighQuality(List<Article> articles) {
    return articles.where((article) {
      // Check content length (minimum 200 characters)
      if (article.content.length < 200) return false;

      // Check read time (minimum 3 minutes)
      if (article.readTime < 3) return false;

      // Check title quality (not too short, not too long)
      if (article.title.length < 20 || article.title.length > 100) return false;

      return true;
    }).toList();
  }

  // Ensure unique content
  static List<Article> _ensureUniqueContent(List<Article> articles) {
    List<Article> uniqueArticles = [];
    Set<String> usedTitles = {};
    Set<String> usedContent = {};

    for (final article in articles) {
      // Check if title is unique
      String finalTitle = article.title;
      if (usedTitles.contains(article.title)) {
        finalTitle = _makeTitleUnique(article.title);
      }

      // Check if content is unique (at least 80% different)
      bool isContentUnique = true;
      for (final used in usedContent) {
        if (_calculateSimilarity(article.content, used) > 0.8) {
          isContentUnique = false;
          break;
        }
      }

      if (isContentUnique) {
        // Create new article with potentially modified title
        final uniqueArticle = Article(
          id: article.id,
          title: finalTitle,
          content: article.content,
          category: article.category,
          readTime: article.readTime,
          views: article.views,
          isActive: article.isActive,
          createdAt: article.createdAt,
        );
        uniqueArticles.add(uniqueArticle);
        usedTitles.add(finalTitle);
        usedContent.add(article.content);
      }
    }

    return uniqueArticles;
  }

  // Make title unique
  static String _makeTitleUnique(String title) {
    final suffixes = [
      ' - Panduan Lengkap',
      ' - Tips Terbaik',
      ' - Informasi Penting',
      ' - Yang Harus Diketahui',
      ' - Panduan Praktis',
    ];

    final suffix = suffixes[_random.nextInt(suffixes.length)];
    return title + suffix;
  }

  // Calculate content similarity (simple implementation)
  static double _calculateSimilarity(String content1, String content2) {
    final words1 = content1.toLowerCase().split(' ');
    final words2 = content2.toLowerCase().split(' ');

    final commonWords = words1.where((word) => words2.contains(word)).length;
    final totalWords = (words1.length + words2.length) / 2;

    return commonWords / totalWords;
  }

  // Generate articles with specific focus
  static Future<List<Article>> generateFocusedArticles({
    required String focus,
    int count = 10,
    String category = 'Semua Jenis',
  }) async {
    List<Article> articles = [];

    switch (focus.toLowerCase()) {
      case 'nutrisi':
        articles = _generateNutritionArticles(count, category);
        break;
      case 'perkembangan':
        articles = _generateDevelopmentArticles(count, category);
        break;
      case 'tips':
        articles = _generateTipsArticles(count, category);
        break;
      case 'pemeriksaan':
        articles = _generateMedicalArticles(count, category);
        break;
      case 'persiapan':
        articles = _generatePreparationArticles(count, category);
        break;
      default:
        articles = await generateFreshArticles(
          count: count,
          specificCategory: category,
        );
    }

    return articles;
  }

  // Generate nutrition-focused articles
  static List<Article> _generateNutritionArticles(int count, String category) {
    final nutritionTemplates = ContentTemplates.getNutritionTemplates();
    return _generateFromTemplates(nutritionTemplates, count, category);
  }

  // Generate development-focused articles
  static List<Article> _generateDevelopmentArticles(
    int count,
    String category,
  ) {
    final developmentTemplates = ContentTemplates.getDevelopmentTemplates();
    return _generateFromTemplates(developmentTemplates, count, category);
  }

  // Generate tips-focused articles
  static List<Article> _generateTipsArticles(int count, String category) {
    final tipsTemplates = ContentTemplates.getTipsTemplates();
    return _generateFromTemplates(tipsTemplates, count, category);
  }

  // Generate medical-focused articles
  static List<Article> _generateMedicalArticles(int count, String category) {
    final medicalTemplates = ContentTemplates.getMedicalTemplates();
    return _generateFromTemplates(medicalTemplates, count, category);
  }

  // Generate preparation-focused articles
  static List<Article> _generatePreparationArticles(
    int count,
    String category,
  ) {
    final preparationTemplates = ContentTemplates.getPreparationTemplates();
    return _generateFromTemplates(preparationTemplates, count, category);
  }

  // Generate from specific templates
  static List<Article> _generateFromTemplates(
    List<Map<String, dynamic>> templates,
    int count,
    String category,
  ) {
    List<Article> articles = [];

    for (int i = 0; i < count; i++) {
      final template = templates[i % templates.length];
      final topic = TopicVariations.getRandomTopicForCategory(category);
      final article = _generateArticleFromTemplate(
        template,
        topic,
        category,
        i,
      );
      articles.add(article);
    }

    return articles;
  }
}
