import 'dart:math';

class TopicVariations {
  static final Random _random = Random();

  // Get random topic for specific category
  static String getRandomTopicForCategory(String category) {
    switch (category) {
      case 'Trimester 1':
        return _getRandomTrimester1Topic();
      case 'Trimester 2':
        return _getRandomTrimester2Topic();
      case 'Trimester 3':
        return _getRandomTrimester3Topic();
      default:
        return _getRandomGeneralTopic();
    }
  }

  // Get random topic for specific content type
  static String getRandomTopicForContentType(String contentType) {
    switch (contentType.toLowerCase()) {
      case 'nutrisi & gizi':
        return _getRandomNutritionTopic();
      case 'perkembangan janin':
        return _getRandomDevelopmentTopic();
      case 'tips kesehatan':
        return _getRandomTipsTopic();
      case 'pemeriksaan medis':
        return _getRandomMedicalTopic();
      case 'persiapan persalinan':
        return _getRandomPreparationTopic();
      case 'kesehatan mental':
        return _getRandomMentalHealthTopic();
      case 'olahraga & aktivitas':
        return _getRandomActivityTopic();
      default:
        return _getRandomGeneralTopic();
    }
  }

  // Trimester 1 specific topics
  static String _getRandomTrimester1Topic() {
    final topics = [
      'Asam Folat untuk Perkembangan Otak',
      'Protein untuk Pertumbuhan Sel',
      'Kalsium untuk Tulang dan Gigi',
      'Zat Besi untuk Mencegah Anemia',
      'Vitamin D untuk Kesehatan Tulang',
      'Serat untuk Pencernaan Sehat',
      'Air Putih untuk Hidrasi Optimal',
      'Omega-3 untuk Mata dan Otak',
      'Morning Sickness Management',
      'First Trimester Screening',
      'Early Pregnancy Symptoms',
      'Safe Medications',
      'Travel Safety',
      'Organ Formation',
      'Neural Tube Development',
      'Heart Development',
      'Limb Formation',
      'Placenta Development',
      'Hormonal Changes',
      'Body Temperature Changes',
      'Breast Changes',
      'Fatigue Management',
      'Sleep Patterns',
      'Emotional Changes',
      'Partner Support',
      'Family Communication',
      'Work Adjustments',
      'Exercise Guidelines',
      'Diet Modifications',
      'Stress Management',
    ];

    return topics[_random.nextInt(topics.length)];
  }

  // Trimester 2 specific topics
  static String _getRandomTrimester2Topic() {
    final topics = [
      'Perubahan Tubuh di Trimester Kedua',
      'Nutrisi Optimal untuk Pertumbuhan',
      'Aktivitas Fisik yang Aman',
      'Persiapan Persalinan Awal',
      'Kesehatan Mental dan Emosional',
      'Gender Reveal Options',
      'Second Trimester Energy',
      'Bonding with Baby',
      'Maternity Clothes',
      'Exercise Guidelines',
      'Weight Gain Management',
      'Skin Changes',
      'Hair Changes',
      'Nail Changes',
      'Breast Changes',
      'Belly Growth',
      'Baby Movements',
      'Kick Counting',
      'Sleep Position',
      'Back Pain Management',
      'Leg Cramps',
      'Swelling Management',
      'Heartburn Relief',
      'Constipation Management',
      'Urination Changes',
      'Breathing Exercises',
      'Pelvic Floor Exercises',
      'Prenatal Classes',
      'Hospital Tours',
      'Birth Plan Creation',
    ];

    return topics[_random.nextInt(topics.length)];
  }

  // Trimester 3 specific topics
  static String _getRandomTrimester3Topic() {
    final topics = [
      'Persiapan Akhir Kehamilan',
      'Tanda-tanda Persalinan',
      'Nutrisi Final untuk Janin',
      'Latihan Pernapasan',
      'Checklist Persalinan',
      'Hospital Bag Preparation',
      'Birth Plan Finalization',
      'Final Ultrasound',
      'Labor Signs',
      'Contraction Timing',
      'Water Breaking',
      'Bloody Show',
      'Lightning',
      'Nesting Instinct',
      'Final Doctor Visits',
      'Group B Strep Testing',
      'Rh Factor Testing',
      'Final Blood Tests',
      'Final Weight Check',
      'Blood Pressure Monitoring',
      'Baby Position Check',
      'Cervix Dilation',
      'Baby Engagement',
      'Final Exercise Guidelines',
      'Rest Requirements',
      'Final Diet Guidelines',
      'Hospital Registration',
      'Pediatrician Selection',
      'Postpartum Planning',
      'Breastfeeding Preparation',
      'Newborn Care Classes',
    ];

    return topics[_random.nextInt(topics.length)];
  }

  // Nutrition-focused topics
  static String _getRandomNutritionTopic() {
    final topics = [
      'Asam Folat untuk Perkembangan Otak',
      'Protein untuk Pertumbuhan Sel',
      'Kalsium untuk Tulang dan Gigi',
      'Zat Besi untuk Mencegah Anemia',
      'Vitamin D untuk Kesehatan Tulang',
      'Omega-3 untuk Mata dan Otak',
      'Serat untuk Pencernaan Sehat',
      'Air Putih untuk Hidrasi Optimal',
      'Vitamin C untuk Kekebalan Tubuh',
      'Vitamin B12 untuk Saraf',
      'Magnesium untuk Otot',
      'Zinc untuk Pertumbuhan',
      'Iodium untuk Tiroid',
      'Selenium untuk Antioksidan',
      'Kolin untuk Otak',
      'Biotin untuk Rambut dan Kuku',
      'Vitamin K untuk Pembekuan Darah',
      'Fosfor untuk Tulang',
      'Kalium untuk Jantung',
      'Natrium untuk Keseimbangan Cairan',
      'Karbohidrat Kompleks',
      'Lemak Sehat',
      'Protein Hewani',
      'Protein Nabati',
      'Sayuran Hijau',
      'Buah-buahan',
      'Kacang-kacangan',
      'Biji-bijian',
      'Susu dan Produk Olahan',
      'Ikan dan Seafood',
      'Daging dan Unggas',
    ];

    return topics[_random.nextInt(topics.length)];
  }

  // Development-focused topics
  static String _getRandomDevelopmentTopic() {
    final topics = [
      'Perkembangan Otak Janin',
      'Pembentukan Jantung',
      'Sistem Saraf',
      'Jari Tangan dan Kaki',
      'Organ Vital',
      'Sistem Pencernaan',
      'Sistem Pernapasan',
      'Sistem Kekebalan',
      'Sistem Reproduksi',
      'Sistem Urinaria',
      'Sistem Muskuloskeletal',
      'Sistem Kardiovaskular',
      'Sistem Endokrin',
      'Sistem Limfatik',
      'Sistem Integumen',
      'Perkembangan Mata',
      'Perkembangan Telinga',
      'Perkembangan Hidung',
      'Perkembangan Mulut',
      'Perkembangan Leher',
      'Perkembangan Dada',
      'Perkembangan Perut',
      'Perkembangan Panggul',
      'Perkembangan Ekstremitas',
      'Perkembangan Tulang Belakang',
      'Perkembangan Tengkorak',
      'Perkembangan Otot',
      'Perkembangan Kulit',
      'Perkembangan Rambut',
      'Perkembangan Kuku',
    ];

    return topics[_random.nextInt(topics.length)];
  }

  // Tips-focused topics
  static String _getRandomTipsTopic() {
    final topics = [
      'Istirahat yang Cukup',
      'Olahraga Ringan',
      'Konsumsi Air Putih',
      'Hindari Makanan Mentah',
      'Kontrol Rutin ke Dokter',
      'Kelola Stres',
      'Pola Tidur Sehat',
      'Hindari Rokok dan Alkohol',
      'Jaga Kebersihan',
      'Gunakan Pakaian Nyaman',
      'Jaga Postur Tubuh',
      'Lakukan Peregangan',
      'Jaga Suhu Tubuh',
      'Hindari Bahan Kimia',
      'Jaga Kesehatan Gigi',
      'Lakukan Pemeriksaan Mata',
      'Jaga Kesehatan Kulit',
      'Lakukan Pijat Ringan',
      'Jaga Kesehatan Rambut',
      'Lakukan Meditasi',
      'Jaga Hubungan dengan Pasangan',
      'Komunikasi dengan Keluarga',
      'Persiapkan Keuangan',
      'Pelajari Parenting',
      'Ikuti Kelas Prenatal',
      'Persiapkan Rumah',
      'Pilih Dokter Anak',
      'Persiapkan Transportasi',
      'Pelajari Pertolongan Pertama',
      'Persiapkan Dokumentasi',
    ];

    return topics[_random.nextInt(topics.length)];
  }

  // Medical-focused topics
  static String _getRandomMedicalTopic() {
    final topics = [
      'Pemeriksaan Rutin',
      'Tes Darah',
      'Tes Urin',
      'Ultrasonografi',
      'Tes Gula Darah',
      'Tes Tekanan Darah',
      'Tes Berat Badan',
      'Tes Denyut Jantung',
      'Tes Pernapasan',
      'Tes Refleks',
      'Tes Kekuatan Otot',
      'Tes Keseimbangan',
      'Tes Koordinasi',
      'Tes Sensasi',
      'Tes Penglihatan',
      'Tes Pendengaran',
      'Tes Penciuman',
      'Tes Pengecapan',
      'Tes Perabaan',
      'Tes Suhu Tubuh',
      'Tes Kolesterol',
      'Tes Asam Urat',
      'Tes Fungsi Hati',
      'Tes Fungsi Ginjal',
      'Tes Fungsi Tiroid',
      'Tes Hormon',
      'Tes Infeksi',
      'Tes Alergi',
      'Tes Genetik',
      'Tes Kanker',
    ];

    return topics[_random.nextInt(topics.length)];
  }

  // Preparation-focused topics
  static String _getRandomPreparationTopic() {
    final topics = [
      'Persiapan Persalinan',
      'Persiapan Rumah',
      'Persiapan Keuangan',
      'Persiapan Transportasi',
      'Persiapan Dokumentasi',
      'Persiapan Pakaian',
      'Persiapan Makanan',
      'Persiapan Obat-obatan',
      'Persiapan Peralatan',
      'Persiapan Kamar Bayi',
      'Persiapan Pakaian Bayi',
      'Persiapan Popok',
      'Persiapan Susu Formula',
      'Persiapan Botol Susu',
      'Persiapan Mainan',
      'Persiapan Buku',
      'Persiapan Musik',
      'Persiapan Foto',
      'Persiapan Video',
      'Persiapan Kenangan',
      'Persiapan Keluarga',
      'Persiapan Teman',
      'Persiapan Kerja',
      'Persiapan Cuti',
      'Persiapan Pengganti',
      'Persiapan Komunikasi',
      'Persiapan Darurat',
      'Persiapan Evakuasi',
      'Persiapan Keamanan',
      'Persiapan Asuransi',
    ];

    return topics[_random.nextInt(topics.length)];
  }

  // Mental health topics
  static String _getRandomMentalHealthTopic() {
    final topics = [
      'Manajemen Stres',
      'Teknik Relaksasi',
      'Meditasi',
      'Yoga',
      'Pernapasan Dalam',
      'Visualisasi',
      'Mindfulness',
      'Gratitude Practice',
      'Journaling',
      'Art Therapy',
      'Music Therapy',
      'Nature Therapy',
      'Social Support',
      'Professional Help',
      'Support Groups',
      'Family Therapy',
      'Couple Therapy',
      'Individual Therapy',
      'Cognitive Behavioral Therapy',
      'Dialectical Behavior Therapy',
      'Acceptance and Commitment Therapy',
      'Mindfulness-Based Therapy',
      'Interpersonal Therapy',
      'Psychodynamic Therapy',
      'Group Therapy',
      'Online Therapy',
      'Teletherapy',
      'Crisis Intervention',
      'Suicide Prevention',
      'Depression Management',
      'Anxiety Management',
    ];

    return topics[_random.nextInt(topics.length)];
  }

  // Activity topics
  static String _getRandomActivityTopic() {
    final topics = [
      'Jalan Kaki',
      'Berenang',
      'Yoga Prenatal',
      'Pilates',
      'Stretching',
      'Kegel Exercises',
      'Pelvic Tilts',
      'Cat-Cow Stretches',
      'Butterfly Stretches',
      'Squats',
      'Lunges',
      'Wall Push-ups',
      'Arm Circles',
      'Leg Lifts',
      'Hip Circles',
      'Ankle Rotations',
      'Wrist Stretches',
      'Neck Stretches',
      'Shoulder Rolls',
      'Back Stretches',
      'Side Stretches',
      'Forward Bends',
      'Twists',
      'Balance Exercises',
      'Coordination Exercises',
      'Flexibility Training',
      'Strength Training',
      'Cardio Training',
      'Endurance Training',
      'Recovery Exercises',
    ];

    return topics[_random.nextInt(topics.length)];
  }

  // General topics (fallback)
  static String _getRandomGeneralTopic() {
    final topics = [
      'Kesehatan Kehamilan',
      'Perkembangan Janin',
      'Nutrisi Ibu Hamil',
      'Pemeriksaan Kehamilan',
      'Persiapan Persalinan',
      'Tips Kehamilan',
      'Perubahan Tubuh',
      'Gejala Kehamilan',
      'Komplikasi Kehamilan',
      'Perawatan Kehamilan',
      'Olahraga Kehamilan',
      'Diet Kehamilan',
      'Suplemen Kehamilan',
      'Obat-obatan Aman',
      'Aktivitas Aman',
      'Perjalanan Aman',
      'Pekerjaan Aman',
      'Hubungan Seksual',
      'Kesehatan Mental',
      'Dukungan Keluarga',
      'Persiapan Finansial',
      'Persiapan Rumah',
      'Persiapan Bayi',
      'Persiapan Pasca Melahirkan',
      'Menyusui',
      'Perawatan Bayi',
      'Kesehatan Ibu Pasca Melahirkan',
      'Depresi Pasca Melahirkan',
      'Pemulihan Pasca Melahirkan',
      'Kembali ke Pekerjaan',
    ];

    return topics[_random.nextInt(topics.length)];
  }

  // Get multiple random topics
  static List<String> getMultipleRandomTopics(String category, int count) {
    final topics = <String>{};
    final maxAttempts = count * 3; // Prevent infinite loop
    int attempts = 0;

    while (topics.length < count && attempts < maxAttempts) {
      topics.add(getRandomTopicForCategory(category));
      attempts++;
    }

    return topics.toList();
  }

  // Get topics by difficulty level
  static String getTopicByDifficulty(String category, String difficulty) {
    final easyTopics = _getEasyTopics(category);
    final mediumTopics = _getMediumTopics(category);
    final hardTopics = _getHardTopics(category);

    switch (difficulty.toLowerCase()) {
      case 'easy':
        return easyTopics[_random.nextInt(easyTopics.length)];
      case 'hard':
        return hardTopics[_random.nextInt(hardTopics.length)];
      default: // medium
        return mediumTopics[_random.nextInt(mediumTopics.length)];
    }
  }

  // Easy topics (basic information)
  static List<String> _getEasyTopics(String category) {
    switch (category) {
      case 'Trimester 1':
        return [
          'Asam Folat untuk Perkembangan Otak',
          'Protein untuk Pertumbuhan Sel',
          'Kalsium untuk Tulang dan Gigi',
          'Air Putih untuk Hidrasi Optimal',
          'Istirahat yang Cukup',
        ];
      case 'Trimester 2':
        return [
          'Perubahan Tubuh di Trimester Kedua',
          'Nutrisi Optimal untuk Pertumbuhan',
          'Aktivitas Fisik yang Aman',
          'Bonding with Baby',
          'Exercise Guidelines',
        ];
      case 'Trimester 3':
        return [
          'Persiapan Akhir Kehamilan',
          'Tanda-tanda Persalinan',
          'Nutrisi Final untuk Janin',
          'Hospital Bag Preparation',
          'Final Doctor Visits',
        ];
      default:
        return [
          'Kesehatan Kehamilan',
          'Perkembangan Janin',
          'Nutrisi Ibu Hamil',
          'Tips Kehamilan',
          'Perubahan Tubuh',
        ];
    }
  }

  // Medium topics (detailed information)
  static List<String> _getMediumTopics(String category) {
    switch (category) {
      case 'Trimester 1':
        return [
          'Morning Sickness Management',
          'First Trimester Screening',
          'Early Pregnancy Symptoms',
          'Safe Medications',
          'Organ Formation',
        ];
      case 'Trimester 2':
        return [
          'Gender Reveal Options',
          'Second Trimester Energy',
          'Weight Gain Management',
          'Skin Changes',
          'Baby Movements',
        ];
      case 'Trimester 3':
        return [
          'Labor Signs',
          'Contraction Timing',
          'Water Breaking',
          'Final Ultrasound',
          'Birth Plan Finalization',
        ];
      default:
        return [
          'Pemeriksaan Kehamilan',
          'Komplikasi Kehamilan',
          'Perawatan Kehamilan',
          'Olahraga Kehamilan',
          'Diet Kehamilan',
        ];
    }
  }

  // Hard topics (advanced information)
  static List<String> _getHardTopics(String category) {
    switch (category) {
      case 'Trimester 1':
        return [
          'Neural Tube Development',
          'Heart Development',
          'Placenta Development',
          'Hormonal Changes',
          'Genetic Testing',
        ];
      case 'Trimester 2':
        return [
          'Kick Counting',
          'Sleep Position',
          'Pelvic Floor Exercises',
          'Prenatal Classes',
          'Hospital Tours',
        ];
      case 'Trimester 3':
        return [
          'Cervix Dilation',
          'Baby Engagement',
          'Group B Strep Testing',
          'Rh Factor Testing',
          'Postpartum Planning',
        ];
      default:
        return [
          'Suplemen Kehamilan',
          'Obat-obatan Aman',
          'Komplikasi Kehamilan',
          'Persiapan Finansial',
          'Kembali ke Pekerjaan',
        ];
    }
  }
}
