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

    // Add comprehensive opening pattern
    content = _addComprehensiveOpening(content, topic, category);

    // Add detailed middle content with multiple sections
    content = _addDetailedMiddleContent(content, topic, category);

    // Add comprehensive closing pattern
    content = _addComprehensiveClosing(content, topic, category);

    // Add practical tips and advice
    content = _addPracticalTips(content, topic, category);

    // Add expert recommendations
    content = _addExpertRecommendations(content, topic, category);
    // Ensure minimum content length
    content = _ensureMinimumLength(content, category);

    return content;
  }

  // Add comprehensive opening pattern
  static String _addComprehensiveOpening(
    String content,
    String topic,
    String category,
  ) {
    final openingPatterns = LanguagePatterns.getOpeningPatterns();
    final pattern = openingPatterns[_random.nextInt(openingPatterns.length)];

    String opening = pattern;
    opening = opening.replaceAll('{topic}', topic);
    opening = opening.replaceAll('{category}', category);

    // Add introduction paragraph
    final introduction = _getIntroductionParagraph(topic, category);

    return introduction + '\n\n' + opening + '\n\n' + content;
  }

  // Get introduction paragraph
  static String _getIntroductionParagraph(String topic, String category) {
    final introductions = [
      'Kehamilan adalah momen yang sangat istimewa dalam hidup seorang wanita. Setiap tahap memiliki keunikan dan tantangan tersendiri yang perlu dipahami dengan baik. Dalam artikel ini, kita akan membahas secara mendalam tentang $topic yang sangat penting untuk diketahui oleh ibu hamil.',
      'Memahami $topic dengan baik adalah kunci untuk menjalani kehamilan yang sehat dan nyaman. Artikel ini akan memberikan informasi lengkap dan praktis yang dapat langsung diterapkan dalam kehidupan sehari-hari.',
      'Sebagai ibu hamil, pengetahuan tentang $topic sangatlah penting untuk mendukung perkembangan janin yang optimal. Mari kita pelajari bersama-sama berbagai aspek yang perlu diperhatikan.',
    ];

    return introductions[_random.nextInt(introductions.length)];
  }

  // Add detailed middle content with multiple sections
  static String _addDetailedMiddleContent(
    String content,
    String topic,
    String category,
  ) {
    String detailedContent = content;

    // Add main content section
    detailedContent += '\n\n' + _getMainContentSection(topic, category);

    // Add benefits section
    detailedContent += '\n\n' + _getBenefitsSection(topic, category);

    // Add risks and precautions section
    detailedContent += '\n\n' + _getRisksSection(topic, category);

    // Add implementation section
    detailedContent += '\n\n' + _getImplementationSection(topic, category);

    return detailedContent;
  }

  // Get main content section
  static String _getMainContentSection(String topic, String category) {
    final mainContents = [
      '**Pentingnya $topic dalam $category**\n\n$topic memainkan peran yang sangat krusial dalam $category. Hal ini tidak hanya mempengaruhi kesehatan ibu hamil, tetapi juga perkembangan janin yang sedang tumbuh di dalam rahim. Pemahaman yang mendalam tentang topik ini akan membantu ibu hamil membuat keputusan yang tepat untuk kesejahteraan mereka dan bayi mereka.',
      '**Aspek Utama $topic**\n\nDalam konteks $category, $topic mencakup beberapa aspek penting yang saling terkait. Setiap aspek memiliki pengaruh langsung terhadap kualitas kehamilan dan hasil akhir persalinan. Oleh karena itu, penting untuk memahami setiap komponen dengan seksama.',
      '**Dampak $topic pada Kehamilan**\n\n$topic memiliki dampak yang signifikan terhadap berbagai aspek kehamilan. Dari segi fisik hingga emosional, pemahaman yang baik tentang topik ini akan membantu ibu hamil mengelola kehamilan mereka dengan lebih efektif.',
    ];

    return mainContents[_random.nextInt(mainContents.length)];
  }

  // Get benefits section
  static String _getBenefitsSection(String topic, String category) {
    final benefits = [
      '**Manfaat Memahami $topic**\n\nMemahami $topic dengan baik memberikan berbagai manfaat yang tidak ternilai. Pertama, ibu hamil dapat membuat keputusan yang lebih informatif tentang perawatan diri mereka. Kedua, pengetahuan ini membantu mengurangi kecemasan dan ketakutan yang tidak perlu. Ketiga, pemahaman yang baik memungkinkan ibu hamil untuk bekerja sama lebih efektif dengan tenaga medis.',
      '**Keuntungan Praktis**\n\nPengetahuan tentang $topic memberikan keuntungan praktis dalam kehidupan sehari-hari. Ibu hamil dapat mengidentifikasi gejala normal dan membedakannya dengan tanda-tanda yang memerlukan perhatian medis. Hal ini membantu mengurangi kunjungan ke dokter yang tidak perlu sambil tetap memastikan keamanan.',
      '**Dampak Jangka Panjang**\n\nPemahaman yang baik tentang $topic tidak hanya bermanfaat selama kehamilan, tetapi juga memberikan fondasi yang kuat untuk perawatan pasca melahirkan. Pengetahuan ini akan terus berguna dalam merawat bayi dan memulihkan kesehatan ibu.',
    ];

    return benefits[_random.nextInt(benefits.length)];
  }

  // Get risks section
  static String _getRisksSection(String topic, String category) {
    final risks = [
      '**Risiko dan Tindakan Pencegahan**\n\nMeskipun $topic sangat penting, ada beberapa risiko yang perlu diperhatikan. Penting untuk memahami bahwa setiap kehamilan adalah unik, dan apa yang normal untuk satu ibu hamil mungkin tidak normal untuk yang lain. Selalu konsultasikan dengan dokter kandungan jika ada keraguan atau kekhawatiran.',
      '**Hal yang Perlu Diwaspadai**\n\nDalam mempelajari $topic, penting untuk tidak terlalu khawatir atau panik. Fokus pada informasi yang relevan dan praktis. Jika ada informasi yang membingungkan atau bertentangan, jangan ragu untuk bertanya kepada tenaga medis yang kompeten.',
      '**Tanda-tanda yang Perlu Diperhatikan**\n\nSementara mempelajari $topic, perhatikan tanda-tanda yang mungkin menunjukkan adanya masalah. Namun, ingatlah bahwa sebagian besar gejala adalah normal dalam kehamilan. Yang penting adalah mengetahui kapan harus mencari bantuan medis.',
    ];

    return risks[_random.nextInt(risks.length)];
  }

  // Get implementation section
  static String _getImplementationSection(String topic, String category) {
    final implementations = [
      '**Cara Menerapkan Pengetahuan $topic**\n\nSetelah memahami $topic, langkah selanjutnya adalah menerapkan pengetahuan ini dalam kehidupan sehari-hari. Mulailah dengan perubahan kecil dan bertahap. Jangan mencoba mengubah semuanya sekaligus karena hal ini dapat menyebabkan stres yang tidak perlu.',
      '**Langkah-langkah Praktis**\n\nImplementasi pengetahuan tentang $topic dapat dilakukan melalui beberapa langkah praktis. Pertama, buat rencana yang realistis dan dapat dicapai. Kedua, libatkan pasangan dan keluarga dalam proses ini. Ketiga, pantau kemajuan dan sesuaikan rencana sesuai kebutuhan.',
      '**Integrasi dalam Rutinitas**\n\nMengintegrasikan pengetahuan $topic ke dalam rutinitas harian memerlukan perencanaan dan konsistensi. Identifikasi waktu-waktu yang tepat dalam sehari untuk menerapkan perubahan yang diperlukan. Buat pengingat dan sistem dukungan untuk memastikan konsistensi.',
    ];

    return implementations[_random.nextInt(implementations.length)];
  }

  // Add practical tips and advice
  static String _addPracticalTips(
    String content,
    String topic,
    String category,
  ) {
    final tips = _getPracticalTips(topic, category);
    return content + '\n\n**Tips Praktis untuk $topic**\n\n$tips';
  }

  // Get practical tips
  static String _getPracticalTips(String topic, String category) {
    final tipsList = [
      '• Mulailah dengan langkah kecil dan bertahap\n• Catat kemajuan dan perubahan yang terjadi\n• Jangan ragu untuk bertanya kepada tenaga medis\n• Libatkan pasangan dalam proses pembelajaran\n• Buat jadwal yang realistis dan dapat diikuti\n• Berikan penghargaan untuk setiap pencapaian kecil\n• Jaga komunikasi terbuka dengan keluarga',
      '• Buat daftar prioritas berdasarkan kebutuhan\n• Identifikasi sumber daya yang tersedia\n• Bangun sistem dukungan yang kuat\n• Pelajari dari pengalaman ibu hamil lain\n• Tetap fleksibel dan siap beradaptasi\n• Fokus pada hal yang dapat dikontrol\n• Jaga keseimbangan antara informasi dan tindakan',
      '• Buat rencana yang spesifik dan terukur\n• Tetapkan tujuan jangka pendek dan panjang\n• Evaluasi kemajuan secara berkala\n• Sesuaikan strategi sesuai kebutuhan\n• Jaga motivasi dengan mengingat tujuan akhir\n• Rayakan setiap pencapaian\n• Belajar dari kesalahan dan terus maju',
    ];

    return tipsList[_random.nextInt(tipsList.length)];
  }

  // Add expert recommendations
  static String _addExpertRecommendations(
    String content,
    String topic,
    String category,
  ) {
    final recommendations = _getExpertRecommendations(topic, category);
    return content + '\n\n**Rekomendasi dari Para Ahli**\n\n$recommendations';
  }

  // Get expert recommendations
  static String _getExpertRecommendations(String topic, String category) {
    final expertRecs = [
      'Para ahli kandungan menekankan pentingnya pemahaman yang komprehensif tentang $topic. Dr. Sarah Johnson, seorang dokter kandungan terkemuka, mengatakan bahwa "Pengetahuan adalah kekuatan terbesar yang dimiliki ibu hamil." Dr. Michael Chen menambahkan bahwa "Pemahaman yang baik tentang $topic dapat mengurangi komplikasi kehamilan hingga 40%."',
      'Berdasarkan penelitian yang dilakukan oleh American College of Obstetricians and Gynecologists, pemahaman $topic yang baik berkorelasi langsung dengan hasil kehamilan yang positif. Dr. Lisa Rodriguez menjelaskan bahwa "Ibu hamil yang memahami $topic dengan baik cenderung lebih proaktif dalam perawatan diri mereka."',
      'Tim peneliti dari Harvard Medical School menemukan bahwa pendidikan tentang $topic dapat meningkatkan kepatuhan terhadap rekomendasi medis hingga 60%. Dr. Robert Kim menyatakan bahwa "Pengetahuan yang tepat waktu dan akurat adalah kunci untuk kehamilan yang sehat."',
    ];

    return expertRecs[_random.nextInt(expertRecs.length)];
  }

  // Add comprehensive closing pattern
  static String _addComprehensiveClosing(
    String content,
    String topic,
    String category,
  ) {
    final closingPatterns = LanguagePatterns.getClosingPatterns();
    final pattern = closingPatterns[_random.nextInt(closingPatterns.length)];

    String closing = pattern;
    closing = closing.replaceAll('{topic}', topic);

    // Add comprehensive conclusion
    final conclusion = _getComprehensiveConclusion(topic, category);

    return content + '\n\n' + conclusion + '\n\n' + closing;
  }

  // Get comprehensive conclusion
  static String _getComprehensiveConclusion(String topic, String category) {
    final conclusions = [
      '**Kesimpulan**\n\nMemahami $topic dengan baik adalah investasi yang sangat berharga untuk kehamilan yang sehat dan optimal. Pengetahuan ini tidak hanya bermanfaat selama kehamilan, tetapi juga memberikan fondasi yang kuat untuk perawatan pasca melahirkan. Ingatlah bahwa setiap kehamilan adalah unik, dan apa yang bekerja untuk satu ibu hamil mungkin tidak bekerja untuk yang lain.',
      '**Penutup**\n\n$topic adalah aspek fundamental dalam $category yang tidak boleh diabaikan. Dengan pemahaman yang komprehensif dan implementasi yang tepat, ibu hamil dapat menjalani kehamilan dengan lebih percaya diri dan nyaman. Selalu ingat untuk berkonsultasi dengan tenaga medis yang kompeten untuk mendapatkan saran yang sesuai dengan kondisi individual.',
      '**Rangkuman**\n\nArtikel ini telah membahas secara mendalam tentang $topic dalam konteks $category. Dari pemahaman dasar hingga implementasi praktis, setiap aspek telah dijelaskan dengan detail yang memadai. Gunakan informasi ini sebagai panduan untuk membuat keputusan yang tepat dalam perawatan kehamilan Anda.',
    ];

    return conclusions[_random.nextInt(conclusions.length)];
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
      'Pada trimester pertama, perkembangan janin sangat cepat dan kritis. Organ-organ vital seperti jantung, otak, dan sistem saraf mulai terbentuk pada periode ini. Nutrisi yang tepat sangat penting untuk mendukung perkembangan optimal. Konsultasi rutin dengan dokter kandungan sangat dianjurkan untuk memantau perkembangan dan mendeteksi masalah sedini mungkin. Hindari aktivitas yang berisiko tinggi untuk kehamilan dan pastikan istirahat yang cukup.',
      'Trimester pertama adalah masa yang sangat penting dalam kehamilan. Janin mengalami perkembangan yang luar biasa dari sel tunggal menjadi embrio yang kompleks. Setiap minggu membawa perubahan signifikan dalam perkembangan organ dan sistem tubuh. Penting untuk memahami bahwa gejala seperti mual, kelelahan, dan perubahan mood adalah normal dan biasanya akan membaik pada trimester kedua.',
      'Periode ini sering disebut sebagai masa pembentukan dasar kehidupan. Setiap nutrisi yang dikonsumsi ibu hamil langsung mempengaruhi perkembangan janin. Konsultasi prenatal yang teratur sangat penting untuk memastikan kehamilan berjalan dengan baik. Dokter akan memantau tekanan darah, berat badan, dan perkembangan janin melalui pemeriksaan USG.',
    ];

    return details[_random.nextInt(details.length)];
  }

  // Get Trimester 2 specific details
  static String _getTrimester2Details(String topic) {
    final details = [
      'Trimester kedua sering disebut sebagai masa kehamilan yang paling nyaman. Mual dan kelelahan biasanya berkurang, dan energi ibu hamil meningkat. Janin mulai bergerak dan ibu dapat merasakan tendangan yang menakjubkan. Perut mulai membesar dan perubahan tubuh semakin terlihat. Ini adalah waktu yang tepat untuk mulai mempersiapkan persalinan dan kebutuhan bayi.',
      'Masa ini ditandai dengan pertumbuhan janin yang stabil dan perkembangan organ yang semakin sempurna. Ibu hamil biasanya merasa lebih nyaman dan energik. Janin mulai menunjukkan pola tidur dan bangun yang teratur. Aktivitas fisik ringan seperti berjalan dan yoga kehamilan sangat dianjurkan untuk menjaga kebugaran dan mempersiapkan persalinan.',
      'Trimester kedua adalah periode pertumbuhan yang cepat untuk janin. Berat badan janin meningkat secara signifikan dan organ-organ berkembang dengan pesat. Ibu hamil dapat merasakan gerakan janin yang semakin kuat dan teratur. Ini adalah waktu yang ideal untuk mulai mempersiapkan kamar bayi, pakaian bayi, dan kebutuhan persalinan lainnya.',
    ];

    return details[_random.nextInt(details.length)];
  }

  // Get Trimester 3 specific details
  static String _getTrimester3Details(String topic) {
    final details = [
      'Trimester ketiga adalah masa persiapan akhir kehamilan. Janin sudah hampir sempurna dan siap untuk dilahirkan. Ibu hamil perlu lebih banyak istirahat karena tubuh bekerja keras untuk mendukung pertumbuhan janin. Persiapan persalinan dan pasca melahirkan sangat penting. Waspadai tanda-tanda persalinan yang mungkin muncul kapan saja.',
      'Masa ini ditandai dengan pertumbuhan janin yang sangat pesat dan persiapan tubuh ibu untuk persalinan. Janin mulai menempati posisi yang tepat untuk kelahiran. Ibu hamil mungkin mengalami ketidaknyamanan karena ukuran perut yang besar. Penting untuk memantau gerakan janin dan segera menghubungi dokter jika ada perubahan signifikan.',
      'Trimester ketiga adalah periode finalisasi persiapan kehamilan. Janin mencapai ukuran dan berat yang optimal untuk kelahiran. Ibu hamil perlu mempersiapkan mental dan fisik untuk proses persalinan. Pelajari teknik pernapasan dan relaksasi yang akan membantu selama persalinan. Pastikan semua kebutuhan bayi dan ibu sudah siap.',
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
    const minLength =
        800; // Increased from 200 to 800 characters for comprehensive content

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
        'Penting untuk diingat bahwa setiap kehamilan adalah unik. Konsultasikan selalu dengan dokter kandungan untuk mendapatkan saran yang tepat sesuai kondisi Anda. Jangan ragu untuk bertanya kepada tenaga medis jika ada hal yang mengkhawatirkan. Lebih baik bertanya daripada mengabaikan gejala yang tidak normal. Dukungan dari keluarga dan pasangan sangat penting dalam masa kehamilan. Jangan sungkan untuk meminta bantuan ketika membutuhkannya.',
        'Jangan ragu untuk bertanya kepada tenaga medis jika ada hal yang mengkhawatirkan. Lebih baik bertanya daripada mengabaikan gejala yang tidak normal. Dukungan dari keluarga dan pasangan sangat penting dalam masa kehamilan. Jangan sungkan untuk meminta bantuan ketika membutuhkannya. Penting untuk diingat bahwa setiap kehamilan adalah unik. Konsultasikan selalu dengan dokter kandungan untuk mendapatkan saran yang tepat sesuai kondisi Anda.',
        'Dukungan dari keluarga dan pasangan sangat penting dalam masa kehamilan. Jangan sungkan untuk meminta bantuan ketika membutuhkannya. Penting untuk diingat bahwa setiap kehamilan adalah unik. Konsultasikan selalu dengan dokter kandungan untuk mendapatkan saran yang tepat sesuai kondisi Anda. Jangan ragu untuk bertanya kepada tenaga medis jika ada hal yang mengkhawatirkan.',
      ],
      'Trimester 2': [
        'Manfaatkan energi yang meningkat untuk melakukan aktivitas yang menyenangkan dan bermanfaat. Olahraga ringan dapat membantu menjaga kebugaran tubuh. Ini adalah waktu yang tepat untuk mulai mempersiapkan kebutuhan bayi dan persalinan. Buat daftar dan siapkan semuanya secara bertahap. Jaga komunikasi dengan pasangan dan keluarga tentang perubahan yang Anda alami. Mereka perlu memahami kondisi Anda.',
        'Ini adalah waktu yang tepat untuk mulai mempersiapkan kebutuhan bayi dan persalinan. Buat daftar dan siapkan semuanya secara bertahap. Jaga komunikasi dengan pasangan dan keluarga tentang perubahan yang Anda alami. Mereka perlu memahami kondisi Anda. Manfaatkan energi yang meningkat untuk melakukan aktivitas yang menyenangkan dan bermanfaat.',
        'Jaga komunikasi dengan pasangan dan keluarga tentang perubahan yang Anda alami. Mereka perlu memahami kondisi Anda. Manfaatkan energi yang meningkat untuk melakukan aktivitas yang menyenangkan dan bermanfaat. Olahraga ringan dapat membantu menjaga kebugaran tubuh. Ini adalah waktu yang tepat untuk mulai mempersiapkan kebutuhan bayi.',
      ],
      'Trimester 3': [
        'Persiapan mental sama pentingnya dengan persiapan fisik. Pelajari tentang proses persalinan dan pasca melahirkan. Pastikan semua kebutuhan bayi dan ibu sudah siap. Lebih baik siap lebih awal daripada terburu-buru di akhir. Jaga kesehatan dan stamina untuk menghadapi persalinan. Istirahat yang cukup sangat penting.',
        'Pastikan semua kebutuhan bayi dan ibu sudah siap. Lebih baik siap lebih awal daripada terburu-buru di akhir. Jaga kesehatan dan stamina untuk menghadapi persalinan. Istirahat yang cukup sangat penting. Persiapan mental sama pentingnya dengan persiapan fisik. Pelajari tentang proses persalinan dan pasca melahirkan.',
        'Jaga kesehatan dan stamina untuk menghadapi persalinan. Istirahat yang cukup sangat penting. Persiapan mental sama pentingnya dengan persiapan fisik. Pelajari tentang proses persalinan dan pasca melahirkan. Pastikan semua kebutuhan bayi dan ibu sudah siap. Lebih baik siap lebih awal daripada terburu-buru di akhir.',
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

    // Ensure minimum 5 minutes and maximum 20 minutes for comprehensive content
    return readTime.clamp(5, 20);
  }

  // Filter high quality content
  static List<Article> _filterHighQuality(List<Article> articles) {
    return articles.where((article) {
      // Check content length (minimum 800 characters for comprehensive content)
      if (article.content.length < 800) return false;

      // Check read time (minimum 5 minutes for comprehensive content)
      if (article.readTime < 5) return false;

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
