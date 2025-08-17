class LanguagePatterns {
  // Get opening patterns for articles
  static List<String> getOpeningPatterns() {
    return _openingPatterns;
  }

  // Get middle content patterns
  static List<String> getMiddlePatterns() {
    return _middlePatterns;
  }

  // Get closing patterns
  static List<String> getClosingPatterns() {
    return _closingPatterns;
  }

  // Get transition phrases
  static List<String> getTransitionPhrases() {
    return _transitionPhrases;
  }

  // Get emphasis phrases
  static List<String> getEmphasisPhrases() {
    return _emphasisPhrases;
  }

  // Get conclusion phrases
  static List<String> getConclusionPhrases() {
    return _conclusionPhrases;
  }

  // Opening patterns for articles
  static const List<String> _openingPatterns = [
    'Pada {category}, {topic} menjadi hal yang sangat penting untuk diperhatikan oleh ibu hamil.',
    'Memasuki {category}, {topic} adalah salah satu aspek yang wajib dipahami dengan baik.',
    'Trimester ini merupakan masa kritis dimana {topic} memainkan peran yang sangat signifikan.',
    'Salah satu hal yang tidak boleh diabaikan pada {category} adalah {topic}.',
    'Untuk mendukung perkembangan optimal janin, {topic} harus mendapat perhatian khusus.',
    'Pada periode {category}, {topic} menjadi fokus utama dalam perawatan kehamilan.',
    'Memahami {topic} pada {category} sangat penting untuk kesehatan ibu dan janin.',
    'Salah satu kunci keberhasilan kehamilan di {category} adalah {topic}.',
    'Pada masa {category}, {topic} menjadi prioritas utama yang harus dipenuhi.',
    'Untuk memastikan kehamilan yang sehat, {topic} tidak boleh diabaikan.',
    'Memasuki {category}, ibu hamil perlu memahami pentingnya {topic}.',
    'Salah satu aspek fundamental pada {category} adalah {topic}.',
    'Untuk mendukung pertumbuhan janin yang optimal, {topic} sangat diperlukan.',
    'Pada {category}, {topic} menjadi hal yang wajib diketahui oleh setiap ibu hamil.',
    'Memahami {topic} pada {category} dapat membantu mencegah berbagai komplikasi.',
  ];

  // Middle content patterns
  static const List<String> _middlePatterns = [
    'Hal ini penting karena {topic} mempengaruhi perkembangan janin secara langsung.',
    'Manfaat dari {topic} meliputi berbagai aspek kesehatan yang sangat diperlukan.',
    'Beberapa tips untuk {topic} yang dapat diterapkan adalah sebagai berikut.',
    'Perlu diingat bahwa {topic} harus dilakukan dengan cara yang tepat dan aman.',
    'Penting untuk memahami bahwa {topic} memerlukan konsistensi dan kesabaran.',
    'Berbagai penelitian menunjukkan bahwa {topic} sangat bermanfaat untuk kehamilan.',
    'Salah satu cara efektif untuk {topic} adalah dengan mengikuti panduan yang benar.',
    'Untuk mendapatkan hasil optimal dari {topic}, diperlukan pemahaman yang mendalam.',
    'Berbagai ahli merekomendasikan {topic} sebagai bagian dari perawatan kehamilan.',
    'Penting untuk diketahui bahwa {topic} memiliki berbagai variasi dan pilihan.',
    'Salah satu kunci keberhasilan {topic} adalah konsistensi dalam penerapannya.',
    'Untuk memastikan {topic} berjalan dengan baik, diperlukan perencanaan yang matang.',
    'Berbagai sumber menyebutkan bahwa {topic} sangat penting untuk kesehatan janin.',
    'Penting untuk dipahami bahwa {topic} memerlukan pendekatan yang sistematis.',
    'Salah satu hal yang perlu diperhatikan dalam {topic} adalah timing yang tepat.',
  ];

  // Closing patterns for articles
  static const List<String> _closingPatterns = [
    'Dengan memperhatikan {topic}, perkembangan janin akan berjalan dengan optimal.',
    'Konsultasikan dengan dokter kandungan untuk informasi lebih lanjut tentang {topic}.',
    'Jangan ragu untuk bertanya kepada tenaga medis jika ada hal yang mengkhawatirkan.',
    'Ingat, setiap kehamilan adalah unik dan memerlukan pendekatan yang berbeda.',
    'Dengan menerapkan {topic} dengan benar, kehamilan akan berjalan dengan lancar.',
    'Penting untuk selalu mengikuti saran dokter dalam menerapkan {topic}.',
    'Dengan pemahaman yang baik tentang {topic}, kehamilan akan lebih menyenangkan.',
    'Jangan lupa untuk selalu menjaga kesehatan dan kebugaran selama kehamilan.',
    'Dengan perhatian yang tepat pada {topic}, janin akan berkembang dengan baik.',
    'Penting untuk selalu memantau perkembangan kehamilan secara rutin.',
    'Dengan persiapan yang matang untuk {topic}, persalinan akan berjalan lancar.',
    'Jangan ragu untuk mencari dukungan dari keluarga dan teman terdekat.',
    'Dengan pengetahuan yang cukup tentang {topic}, kehamilan akan lebih aman.',
    'Penting untuk selalu menjaga pola hidup sehat selama kehamilan.',
    'Dengan perawatan yang tepat untuk {topic}, kesehatan ibu dan janin akan terjaga.',
  ];

  // Transition phrases for smooth content flow
  static const List<String> _transitionPhrases = [
    'Selain itu,',
    'Di samping itu,',
    'Lebih lanjut,',
    'Selanjutnya,',
    'Berikutnya,',
    'Selain hal tersebut,',
    'Tidak hanya itu,',
    'Lebih dari itu,',
    'Yang tidak kalah penting,',
    'Hal lain yang perlu diperhatikan,',
    'Sementara itu,',
    'Pada saat yang sama,',
    'Bersamaan dengan itu,',
    'Sejalan dengan hal tersebut,',
    'Seiring dengan perkembangan tersebut,',
    'Sejalan dengan pertumbuhan janin,',
    'Berdasarkan penelitian terbaru,',
    'Menurut para ahli,',
    'Berdasarkan pengalaman klinis,',
    'Dari berbagai studi yang dilakukan,',
    'Berdasarkan rekomendasi medis,',
    'Menurut panduan kesehatan,',
    'Berdasarkan standar perawatan,',
    'Dari berbagai sumber terpercaya,',
    'Berdasarkan bukti ilmiah,',
    'Menurut praktik terbaik,',
  ];

  // Emphasis phrases to highlight important points
  static const List<String> _emphasisPhrases = [
    'Sangat penting untuk diingat bahwa',
    'Hal yang tidak boleh diabaikan adalah',
    'Poin kunci yang harus diperhatikan adalah',
    'Yang paling penting adalah',
    'Tidak boleh dilupakan bahwa',
    'Harus selalu diingat bahwa',
    'Penting untuk dipahami bahwa',
    'Yang wajib diketahui adalah',
    'Tidak boleh diabaikan bahwa',
    'Harus diperhatikan dengan seksama bahwa',
    'Penting untuk selalu mengingat bahwa',
    'Yang tidak boleh terlewat adalah',
    'Harus selalu diperhatikan bahwa',
    'Penting untuk dipahami dengan baik bahwa',
    'Yang wajib diperhatikan adalah',
    'Tidak boleh dianggap remeh bahwa',
    'Harus selalu diingat dengan baik bahwa',
    'Penting untuk tidak mengabaikan bahwa',
    'Yang harus selalu diperhatikan adalah',
    'Tidak boleh dilupakan sama sekali bahwa',
  ];

  // Conclusion phrases for article endings
  static const List<String> _conclusionPhrases = [
    'Dengan demikian,',
    'Oleh karena itu,',
    'Berdasarkan penjelasan di atas,',
    'Dari uraian tersebut,',
    'Berdasarkan hal-hal yang telah dijelaskan,',
    'Dengan memperhatikan semua aspek tersebut,',
    'Berdasarkan berbagai pertimbangan,',
    'Dari berbagai informasi yang telah disampaikan,',
    'Berdasarkan pemahaman yang mendalam,',
    'Dengan mempertimbangkan semua faktor,',
    'Berdasarkan analisis yang komprehensif,',
    'Dari berbagai sudut pandang,',
    'Berdasarkan pengalaman dan penelitian,',
    'Dengan memperhatikan rekomendasi medis,',
    'Berdasarkan standar perawatan terkini,',
    'Dari berbagai sumber terpercaya,',
    'Berdasarkan bukti ilmiah yang ada,',
    'Dengan mempertimbangkan praktik terbaik,',
    'Berdasarkan panduan kesehatan resmi,',
    'Dari berbagai aspek yang telah dibahas,',
  ];

  // Get random opening pattern
  static String getRandomOpeningPattern() {
    return _openingPatterns[DateTime.now().millisecond %
        _openingPatterns.length];
  }

  // Get random middle pattern
  static String getRandomMiddlePattern() {
    return _middlePatterns[DateTime.now().millisecond % _middlePatterns.length];
  }

  // Get random closing pattern
  static String getRandomClosingPattern() {
    return _closingPatterns[DateTime.now().millisecond %
        _closingPatterns.length];
  }

  // Get random transition phrase
  static String getRandomTransitionPhrase() {
    return _transitionPhrases[DateTime.now().millisecond %
        _transitionPhrases.length];
  }

  // Get random emphasis phrase
  static String getRandomEmphasisPhrase() {
    return _emphasisPhrases[DateTime.now().millisecond %
        _emphasisPhrases.length];
  }

  // Get random conclusion phrase
  static String getRandomConclusionPhrase() {
    return _conclusionPhrases[DateTime.now().millisecond %
        _conclusionPhrases.length];
  }

  // Get patterns by category
  static List<String> getPatternsByCategory(String category) {
    switch (category) {
      case 'Trimester 1':
        return _getTrimester1Patterns();
      case 'Trimester 2':
        return _getTrimester2Patterns();
      case 'Trimester 3':
        return _getTrimester3Patterns();
      default:
        return _openingPatterns;
    }
  }

  // Trimester 1 specific patterns
  static List<String> _getTrimester1Patterns() {
    return [
      'Pada trimester pertama yang kritis ini, {topic} menjadi hal yang sangat fundamental.',
      'Memasuki masa awal kehamilan, {topic} adalah aspek yang tidak boleh diabaikan.',
      'Pada periode pembentukan organ vital, {topic} memainkan peran yang sangat penting.',
      'Trimester pertama adalah masa yang menentukan dimana {topic} harus diperhatikan.',
      'Pada masa perkembangan awal janin, {topic} menjadi kunci keberhasilan kehamilan.',
    ];
  }

  // Trimester 2 specific patterns
  static List<String> _getTrimester2Patterns() {
    return [
      'Memasuki trimester kedua yang nyaman, {topic} menjadi lebih mudah diterapkan.',
      'Pada masa pertumbuhan janin yang pesat, {topic} sangat diperlukan.',
      'Trimester kedua adalah waktu yang tepat untuk fokus pada {topic}.',
      'Pada periode energi yang meningkat, {topic} dapat dilakukan dengan optimal.',
      'Memasuki masa yang stabil, {topic} menjadi lebih penting untuk diperhatikan.',
    ];
  }

  // Trimester 3 specific patterns
  static List<String> _getTrimester3Patterns() {
    return [
      'Memasuki trimester akhir, {topic} menjadi persiapan penting untuk persalinan.',
      'Pada masa persiapan akhir kehamilan, {topic} harus disiapkan dengan matang.',
      'Trimester ketiga adalah waktu untuk memastikan {topic} sudah optimal.',
      'Pada periode menjelang persalinan, {topic} menjadi hal yang kritis.',
      'Memasuki masa final kehamilan, {topic} harus diperhatikan dengan seksama.',
    ];
  }

  // Get professional medical phrases
  static List<String> getProfessionalMedicalPhrases() {
    return [
      'Berdasarkan rekomendasi medis terkini,',
      'Menurut standar perawatan kehamilan,',
      'Berdasarkan panduan klinis,',
      'Menurut praktik terbaik dalam obstetri,',
      'Berdasarkan bukti ilmiah yang ada,',
      'Menurut rekomendasi organisasi kesehatan,',
      'Berdasarkan konsensus medis,',
      'Menurut standar internasional,',
      'Berdasarkan penelitian terkini,',
      'Menurut panduan profesional,',
    ];
  }

  // Get patient-friendly phrases
  static List<String> getPatientFriendlyPhrases() {
    return [
      'Untuk memudahkan pemahaman,',
      'Agar lebih mudah dipahami,',
      'Untuk membantu ibu hamil,',
      'Agar lebih praktis diterapkan,',
      'Untuk kenyamanan ibu hamil,',
      'Agar lebih mudah diikuti,',
      'Untuk memudahkan penerapan,',
      'Agar lebih praktis dilakukan,',
      'Untuk membantu dalam perawatan,',
      'Agar lebih mudah dipraktikkan,',
    ];
  }

  // Get warning phrases
  static List<String> getWarningPhrases() {
    return [
      'Penting untuk diingat bahwa',
      'Harus diperhatikan bahwa',
      'Tidak boleh diabaikan bahwa',
      'Perlu diwaspadai bahwa',
      'Harus selalu diingat bahwa',
      'Tidak boleh dilupakan bahwa',
      'Penting untuk diperhatikan bahwa',
      'Harus diingat dengan baik bahwa',
      'Tidak boleh dianggap remeh bahwa',
      'Perlu selalu diperhatikan bahwa',
    ];
  }

  // Get encouragement phrases
  static List<String> getEncouragementPhrases() {
    return [
      'Jangan khawatir,',
      'Tidak perlu cemas,',
      'Yang penting adalah',
      'Yang perlu diingat adalah',
      'Yang harus diperhatikan adalah',
      'Yang tidak boleh dilupakan adalah',
      'Yang wajib diketahui adalah',
      'Yang perlu dipahami adalah',
      'Yang harus selalu diingat adalah',
      'Yang tidak boleh diabaikan adalah',
    ];
  }
}
