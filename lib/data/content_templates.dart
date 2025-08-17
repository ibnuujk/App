class ContentTemplates {
  // Get templates for specific category
  static List<Map<String, dynamic>> getTemplatesForCategory(String category) {
    switch (category) {
      case 'Trimester 1':
        return _trimester1Templates;
      case 'Trimester 2':
        return _trimester2Templates;
      case 'Trimester 3':
        return _trimester3Templates;
      default:
        return _allTemplates;
    }
  }

  // Get nutrition-focused templates
  static List<Map<String, dynamic>> getNutritionTemplates() {
    return _nutritionTemplates;
  }

  // Get development-focused templates
  static List<Map<String, dynamic>> getDevelopmentTemplates() {
    return _developmentTemplates;
  }

  // Get tips-focused templates
  static List<Map<String, dynamic>> getTipsTemplates() {
    return _tipsTemplates;
  }

  // Get medical-focused templates
  static List<Map<String, dynamic>> getMedicalTemplates() {
    return _medicalTemplates;
  }

  // Get preparation-focused templates
  static List<Map<String, dynamic>> getPreparationTemplates() {
    return _preparationTemplates;
  }

  // All templates combined
  static List<Map<String, dynamic>> get _allTemplates {
    List<Map<String, dynamic>> all = [];
    all.addAll(_trimester1Templates);
    all.addAll(_trimester2Templates);
    all.addAll(_trimester3Templates);
    all.addAll(_nutritionTemplates);
    all.addAll(_tipsTemplates);
    all.addAll(_medicalTemplates);
    return all;
  }

  // Trimester 1 Templates
  static const List<Map<String, dynamic>> _trimester1Templates = [
    {
      'title': 'Nutrisi Penting {topic} di {category}',
      'content':
          'Trimester pertama adalah periode kritis dalam kehamilan. Pada masa ini, janin mengalami perkembangan yang sangat cepat dan organ-organ vital mulai terbentuk. {topic} menjadi hal yang sangat penting untuk mendukung proses perkembangan ini.',
      'keywords': ['nutrisi', 'perkembangan', 'organ vital'],
      'readTime': 5,
    },
    {
      'title': 'Perkembangan Janin: {topic} di {category}',
      'content':
          'Memasuki {category}, janin mulai membentuk struktur dasar tubuh. {topic} adalah salah satu aspek perkembangan yang sangat penting untuk dipahami oleh ibu hamil.',
      'keywords': ['perkembangan', 'janin', 'struktur tubuh'],
      'readTime': 6,
    },
    {
      'title': 'Tips Kesehatan: {topic} untuk {category}',
      'content':
          'Trimester pertama sering kali menjadi masa yang menantang bagi ibu hamil. {topic} adalah salah satu hal yang perlu diperhatikan untuk menjaga kesehatan ibu dan janin.',
      'keywords': ['tips', 'kesehatan', 'ibu hamil'],
      'readTime': 4,
    },
    {
      'title': 'Pemeriksaan Rutin: {topic} di {category}',
      'content':
          'Pemeriksaan rutin sangat penting dilakukan pada {category}. {topic} adalah salah satu pemeriksaan yang wajib dilakukan untuk memastikan kehamilan berjalan dengan baik.',
      'keywords': ['pemeriksaan', 'rutin', 'kehamilan'],
      'readTime': 5,
    },
    {
      'title': 'Perubahan Tubuh: {topic} pada {category}',
      'content':
          'Tubuh ibu hamil mengalami berbagai perubahan pada {category}. {topic} adalah salah satu perubahan yang normal terjadi dan perlu dipahami.',
      'keywords': ['perubahan', 'tubuh', 'normal'],
      'readTime': 4,
    },
  ];

  // Trimester 2 Templates
  static const List<Map<String, dynamic>> _trimester2Templates = [
    {
      'title': 'Nutrisi Optimal: {topic} di {category}',
      'content':
          'Trimester kedua adalah masa yang nyaman bagi kebanyakan ibu hamil. Energi mulai meningkat dan nafsu makan membaik. {topic} menjadi sangat penting untuk mendukung pertumbuhan janin yang optimal.',
      'keywords': ['nutrisi', 'optimal', 'pertumbuhan'],
      'readTime': 6,
    },
    {
      'title': 'Perkembangan Janin: {topic} di {category}',
      'content':
          'Pada {category}, janin mulai bergerak dan ibu dapat merasakan tendangan. {topic} adalah salah satu perkembangan yang menarik untuk dipantau.',
      'keywords': ['perkembangan', 'gerakan', 'tendangan'],
      'readTime': 5,
    },
    {
      'title': 'Aktivitas Fisik: {topic} untuk {category}',
      'content':
          'Energi yang meningkat pada {category} memungkinkan ibu hamil untuk melakukan berbagai aktivitas. {topic} adalah salah satu aktivitas yang aman dan bermanfaat.',
      'keywords': ['aktivitas', 'fisik', 'aman'],
      'readTime': 5,
    },
    {
      'title': 'Persiapan Persalinan: {topic} di {category}',
      'content':
          'Meskipun masih beberapa bulan lagi, {category} adalah waktu yang tepat untuk mulai mempersiapkan persalinan. {topic} adalah salah satu hal yang perlu disiapkan.',
      'keywords': ['persiapan', 'persalinan', 'perencanaan'],
      'readTime': 6,
    },
    {
      'title': 'Kesehatan Mental: {topic} pada {category}',
      'content':
          'Kesehatan mental sama pentingnya dengan kesehatan fisik. Pada {category}, {topic} menjadi hal yang perlu diperhatikan untuk kesejahteraan ibu hamil.',
      'keywords': ['kesehatan', 'mental', 'kesejahteraan'],
      'readTime': 5,
    },
  ];

  // Trimester 3 Templates
  static const List<Map<String, dynamic>> _trimester3Templates = [
    {
      'title': 'Nutrisi Final: {topic} di {category}',
      'content':
          'Trimester ketiga adalah masa persiapan akhir kehamilan. {topic} menjadi sangat penting untuk memastikan janin mendapatkan nutrisi yang cukup sebelum lahir.',
      'keywords': ['nutrisi', 'final', 'persiapan'],
      'readTime': 6,
    },
    {
      'title': 'Persiapan Persalinan: {topic} di {category}',
      'content':
          'Persalinan sudah semakin dekat pada {category}. {topic} adalah salah satu hal yang harus disiapkan dengan matang.',
      'keywords': ['persiapan', 'persalinan', 'matang'],
      'readTime': 7,
    },
    {
      'title': 'Tanda-tanda Persalinan: {topic}',
      'content':
          'Memasuki {category}, ibu hamil perlu mengenali berbagai tanda persalinan. {topic} adalah salah satu tanda yang perlu dipahami.',
      'keywords': ['tanda', 'persalinan', 'pemahaman'],
      'readTime': 5,
    },
    {
      'title': 'Latihan Pernapasan: {topic} untuk {category}',
      'content':
          'Latihan pernapasan sangat penting untuk persalinan. Pada {category}, {topic} menjadi latihan yang wajib dikuasai.',
      'keywords': ['latihan', 'pernapasan', 'persalinan'],
      'readTime': 4,
    },
    {
      'title': 'Checklist Persalinan: {topic}',
      'content':
          'Persiapan persalinan harus dilakukan dengan sistematis. {topic} adalah salah satu item yang tidak boleh terlewat dalam checklist.',
      'keywords': ['checklist', 'persiapan', 'sistematis'],
      'readTime': 5,
    },
  ];

  // Nutrition-focused Templates
  static const List<Map<String, dynamic>> _nutritionTemplates = [
    {
      'title': 'Nutrisi Penting: {topic} untuk Kehamilan Sehat',
      'content':
          'Nutrisi yang tepat sangat penting untuk kehamilan yang sehat. {topic} adalah salah satu nutrisi yang wajib dipenuhi oleh ibu hamil.',
      'keywords': ['nutrisi', 'penting', 'wajib'],
      'readTime': 6,
    },
    {
      'title': 'Makanan Sehat: {topic} yang Dianjurkan',
      'content':
          'Pemilihan makanan yang tepat sangat penting selama kehamilan. {topic} adalah salah satu makanan yang sangat dianjurkan untuk dikonsumsi.',
      'keywords': ['makanan', 'sehat', 'dianjurkan'],
      'readTime': 5,
    },
    {
      'title': 'Suplemen Kehamilan: {topic} yang Diperlukan',
      'content':
          'Suplemen dapat membantu memenuhi kebutuhan nutrisi selama kehamilan. {topic} adalah salah satu suplemen yang sering direkomendasikan.',
      'keywords': ['suplemen', 'kehamilan', 'direkomendasikan'],
      'readTime': 5,
    },
    {
      'title': 'Hidrasi: {topic} untuk Ibu Hamil',
      'content':
          'Hidrasi yang cukup sangat penting selama kehamilan. {topic} adalah salah satu aspek hidrasi yang perlu diperhatikan.',
      'keywords': ['hidrasi', 'cukup', 'penting'],
      'readTime': 4,
    },
    {
      'title': 'Pola Makan: {topic} yang Sehat',
      'content':
          'Pola makan yang sehat sangat penting untuk kehamilan yang optimal. {topic} adalah salah satu prinsip pola makan yang perlu diterapkan.',
      'keywords': ['pola', 'makan', 'sehat'],
      'readTime': 5,
    },
  ];

  // Development-focused Templates
  static const List<Map<String, dynamic>> _developmentTemplates = [
    {
      'title': 'Perkembangan Janin: {topic} yang Menakjubkan',
      'content':
          'Perkembangan janin adalah proses yang menakjubkan. {topic} adalah salah satu tahap perkembangan yang sangat menarik untuk dipantau.',
      'keywords': ['perkembangan', 'janin', 'menakjubkan'],
      'readTime': 6,
    },
    {
      'title': 'Minggu ke Minggu: {topic} Perkembangan',
      'content':
          'Perkembangan janin terjadi minggu ke minggu. {topic} adalah salah satu milestone perkembangan yang penting.',
      'keywords': ['minggu', 'perkembangan', 'milestone'],
      'readTime': 7,
    },
    {
      'title': 'Organ Vital: {topic} yang Terbentuk',
      'content':
          'Organ-organ vital janin terbentuk secara bertahap. {topic} adalah salah satu organ yang sangat penting untuk dipahami perkembangannya.',
      'keywords': ['organ', 'vital', 'terbentuk'],
      'readTime': 6,
    },
    {
      'title': 'Sistem Tubuh: {topic} yang Berkembang',
      'content':
          'Berbagai sistem tubuh janin berkembang secara bersamaan. {topic} adalah salah satu sistem yang perlu dipantau perkembangannya.',
      'keywords': ['sistem', 'tubuh', 'berkembang'],
      'readTime': 5,
    },
    {
      'title': 'Gerakan Janin: {topic} yang Dirasakan',
      'content':
          'Gerakan janin adalah tanda bahwa bayi berkembang dengan baik. {topic} adalah salah satu gerakan yang dapat dirasakan ibu.',
      'keywords': ['gerakan', 'janin', 'dirasakan'],
      'readTime': 4,
    },
  ];

  // Tips-focused Templates
  static const List<Map<String, dynamic>> _tipsTemplates = [
    {
      'title': 'Tips Kehamilan: {topic} yang Efektif',
      'content':
          'Tips kehamilan dapat membantu ibu hamil menjalani masa kehamilan dengan lebih nyaman. {topic} adalah salah satu tips yang sangat efektif.',
      'keywords': ['tips', 'kehamilan', 'efektif'],
      'readTime': 5,
    },
    {
      'title': 'Kesehatan Ibu: {topic} yang Perlu Diperhatikan',
      'content':
          'Kesehatan ibu hamil sangat penting untuk kesehatan janin. {topic} adalah salah satu aspek kesehatan yang perlu diperhatikan.',
      'keywords': ['kesehatan', 'ibu', 'diperhatikan'],
      'readTime': 5,
    },
    {
      'title': 'Kenyamanan: {topic} untuk Ibu Hamil',
      'content':
          'Kenyamanan ibu hamil sangat penting untuk kesejahteraan. {topic} adalah salah satu cara untuk meningkatkan kenyamanan.',
      'keywords': ['kenyamanan', 'ibu hamil', 'meningkatkan'],
      'readTime': 4,
    },
    {
      'title': 'Aktivitas Sehari-hari: {topic} yang Aman',
      'content':
          'Aktivitas sehari-hari perlu disesuaikan dengan kondisi kehamilan. {topic} adalah salah satu aktivitas yang aman dilakukan.',
      'keywords': ['aktivitas', 'sehari-hari', 'aman'],
      'readTime': 5,
    },
    {
      'title': 'Istirahat: {topic} yang Berkualitas',
      'content':
          'Istirahat yang berkualitas sangat penting selama kehamilan. {topic} adalah salah satu cara untuk mendapatkan istirahat yang optimal.',
      'keywords': ['istirahat', 'berkualitas', 'optimal'],
      'readTime': 4,
    },
  ];

  // Medical-focused Templates
  static const List<Map<String, dynamic>> _medicalTemplates = [
    {
      'title': 'Pemeriksaan Medis: {topic} yang Wajib',
      'content':
          'Pemeriksaan medis rutin sangat penting selama kehamilan. {topic} adalah salah satu pemeriksaan yang wajib dilakukan.',
      'keywords': ['pemeriksaan', 'medis', 'wajib'],
      'readTime': 6,
    },
    {
      'title': 'Tes Laboratorium: {topic} yang Diperlukan',
      'content':
          'Tes laboratorium dapat memberikan informasi penting tentang kondisi kehamilan. {topic} adalah salah satu tes yang sering diperlukan.',
      'keywords': ['tes', 'laboratorium', 'diperlukan'],
      'readTime': 5,
    },
    {
      'title': 'Ultrasonografi: {topic} yang Dipantau',
      'content':
          'Ultrasonografi adalah pemeriksaan penting untuk memantau perkembangan janin. {topic} adalah salah satu aspek yang dipantau.',
      'keywords': ['ultrasonografi', 'pemantauan', 'perkembangan'],
      'readTime': 6,
    },
    {
      'title': 'Konsultasi Dokter: {topic} yang Perlu Ditanyakan',
      'content':
          'Konsultasi rutin dengan dokter sangat penting. {topic} adalah salah satu hal yang perlu ditanyakan kepada dokter.',
      'keywords': ['konsultasi', 'dokter', 'ditanyakan'],
      'readTime': 5,
    },
    {
      'title': 'Gejala Kehamilan: {topic} yang Normal',
      'content':
          'Berbagai gejala dapat muncul selama kehamilan. {topic} adalah salah satu gejala yang normal terjadi.',
      'keywords': ['gejala', 'kehamilan', 'normal'],
      'readTime': 5,
    },
  ];

  // Preparation-focused Templates
  static const List<Map<String, dynamic>> _preparationTemplates = [
    {
      'title': 'Persiapan Persalinan: {topic} yang Matang',
      'content':
          'Persiapan persalinan harus dilakukan dengan matang. {topic} adalah salah satu hal yang perlu disiapkan dengan baik.',
      'keywords': ['persiapan', 'persalinan', 'matang'],
      'readTime': 6,
    },
    {
      'title': 'Kebutuhan Bayi: {topic} yang Harus Disiapkan',
      'content':
          'Kebutuhan bayi harus disiapkan sebelum persalinan. {topic} adalah salah satu kebutuhan yang tidak boleh terlewat.',
      'keywords': ['kebutuhan', 'bayi', 'disiapkan'],
      'readTime': 5,
    },
    {
      'title': 'Kebutuhan Ibu: {topic} untuk Pasca Melahirkan',
      'content':
          'Ibu juga membutuhkan berbagai persiapan untuk pasca melahirkan. {topic} adalah salah satu kebutuhan yang penting.',
      'keywords': ['kebutuhan', 'ibu', 'pasca melahirkan'],
      'readTime': 5,
    },
    {
      'title': 'Rencana Persalinan: {topic} yang Perlu Dipertimbangkan',
      'content':
          'Rencana persalinan harus dibuat dengan matang. {topic} adalah salah satu aspek yang perlu dipertimbangkan.',
      'keywords': ['rencana', 'persalinan', 'dipertimbangkan'],
      'readTime': 6,
    },
    {
      'title': 'Dukungan Keluarga: {topic} yang Penting',
      'content':
          'Dukungan keluarga sangat penting untuk persalinan yang lancar. {topic} adalah salah satu bentuk dukungan yang diperlukan.',
      'keywords': ['dukungan', 'keluarga', 'diperlukan'],
      'readTime': 5,
    },
  ];
}
