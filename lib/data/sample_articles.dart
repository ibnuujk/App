import '../models/article_model.dart';

class SampleArticles {
  static List<Article> getArticles() {
    return [
      // TRIMESTER 1 (5 artikel)
      Article(
        id: 'artikel_001',
        title: 'Nutrisi Penting Trimester Pertama',
        content:
            'Trimester pertama adalah periode krusial dalam kehamilan. Pada masa ini, janin mengalami perkembangan yang sangat cepat. Nutrisi yang diperlukan meliputi asam folat untuk mencegah cacat tabung saraf, zat besi untuk mencegah anemia, dan protein untuk pertumbuhan sel. Konsumsi makanan bergizi seimbang sangat penting untuk mendukung perkembangan janin yang optimal.',
        category: 'Trimester 1',
        readTime: 5,
        views: 0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),

      Article(
        id: 'artikel_002',
        title: 'Perkembangan Janin Minggu 1-12',
        content:
            'Minggu pertama hingga ke-12 adalah masa pembentukan organ-organ vital janin. Dimulai dari sel telur yang dibuahi, berkembang menjadi embrio, hingga terbentuknya semua organ utama. Pada minggu ke-4, jantung mulai berdetak. Minggu ke-8, semua organ utama sudah terbentuk. Minggu ke-12, janin sudah memiliki bentuk manusia yang lengkap.',
        category: 'Trimester 1',
        readTime: 6,
        views: 0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),

      Article(
        id: 'artikel_003',
        title: 'Tips Mengatasi Morning Sickness',
        content:
            'Morning sickness adalah gejala umum pada trimester pertama yang dialami 70-80% ibu hamil. Gejala ini bisa diatasi dengan makan dalam porsi kecil tapi sering, menghindari makanan berlemak, minum air putih yang cukup, dan istirahat yang cukup. Konsultasikan dengan dokter jika gejala sangat berat atau mengganggu aktivitas sehari-hari.',
        category: 'Trimester 1',
        readTime: 4,
        views: 0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),

      Article(
        id: 'artikel_004',
        title: 'Vitamin dan Suplemen Kehamilan',
        content:
            'Suplemen yang direkomendasikan untuk ibu hamil meliputi asam folat 400-800 mcg per hari, zat besi 30 mg per hari, kalsium 1000 mg per hari, dan vitamin D 600 IU per hari. Konsultasikan dengan dokter untuk dosis yang tepat sesuai kondisi kesehatan masing-masing.',
        category: 'Trimester 1',
        readTime: 5,
        views: 0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),

      Article(
        id: 'artikel_005',
        title: 'Pantangan Makanan Ibu Hamil',
        content:
            'Beberapa makanan yang sebaiknya dihindari selama kehamilan: daging mentah atau setengah matang, telur mentah, susu yang tidak dipasteurisasi, ikan dengan kandungan merkuri tinggi, dan alkohol. Makanan ini berisiko menyebabkan infeksi atau gangguan perkembangan janin.',
        category: 'Trimester 1',
        readTime: 4,
        views: 0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),

      // TRIMESTER 2 (5 artikel)
      Article(
        id: 'artikel_006',
        title: 'Perkembangan Janin Minggu 13-26',
        content:
            'Trimester kedua adalah masa yang paling nyaman bagi ibu hamil. Janin mengalami pertumbuhan yang pesat, mulai dari ukuran 7 cm menjadi 35 cm. Organ-organ sudah terbentuk sempurna dan mulai berfungsi. Ibu hamil akan merasakan gerakan janin pertama kali (quickening) sekitar minggu ke-18-20.',
        category: 'Trimester 2',
        readTime: 6,
        views: 0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),

      Article(
        id: 'artikel_007',
        title: 'Olahraga Aman untuk Ibu Hamil',
        content:
            'Olahraga ringan sangat bermanfaat untuk ibu hamil, seperti jalan kaki, berenang, yoga prenatal, dan pilates. Olahraga membantu menjaga kebugaran, mengurangi keluhan kehamilan, dan mempersiapkan tubuh untuk persalinan. Hindari olahraga yang berisiko jatuh atau benturan.',
        category: 'Trimester 2',
        readTime: 5,
        views: 0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),

      Article(
        id: 'artikel_008',
        title: 'Persiapan USG dan Pemeriksaan Rutin',
        content:
            'USG pada trimester kedua dilakukan untuk memeriksa perkembangan janin, mendeteksi kelainan kongenital, dan menentukan jenis kelamin. Pemeriksaan rutin meliputi tekanan darah, berat badan, dan tes laboratorium. Jangan lewatkan jadwal pemeriksaan untuk memastikan kehamilan berjalan lancar.',
        category: 'Trimester 2',
        readTime: 4,
        views: 0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),

      Article(
        id: 'artikel_009',
        title: 'Nutrisi Trimester Kedua',
        content:
            'Kebutuhan kalori meningkat 300-500 kalori per hari pada trimester kedua. Fokus pada protein berkualitas tinggi, karbohidrat kompleks, lemak sehat, dan serat. Konsumsi sayuran hijau, buah-buahan, dan sumber protein seperti ikan, daging, dan kacang-kacangan.',
        category: 'Trimester 2',
        readTime: 5,
        views: 0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
      ),

      Article(
        id: 'artikel_010',
        title: 'Perubahan Tubuh Normal Trimester 2',
        content:
            'Perubahan tubuh yang normal meliputi perut yang membesar, payudara yang membesar dan sensitif, pigmentasi kulit, dan stretch mark. Perubahan ini adalah bagian normal dari kehamilan dan akan membaik setelah melahirkan. Gunakan pelembab untuk mengurangi stretch mark.',
        category: 'Trimester 2',
        readTime: 4,
        views: 0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),

      // TRIMESTER 3 (5 artikel)
      Article(
        id: 'artikel_011',
        title: 'Persiapan Persalinan Lengkap',
        content:
            'Persiapan persalinan meliputi persiapan fisik, mental, dan material. Latihan pernapasan, teknik relaksasi, dan kelas persiapan persalinan sangat membantu. Siapkan tas persalinan sejak minggu ke-36. Diskusikan rencana persalinan dengan dokter dan keluarga.',
        category: 'Trimester 3',
        readTime: 7,
        views: 0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 11)),
      ),

      Article(
        id: 'artikel_012',
        title: 'Tanda-tanda Melahirkan',
        content:
            'Tanda-tanda melahirkan meliputi kontraksi yang teratur dan semakin kuat, pecahnya ketuban, dan pembukaan serviks. Kontraksi Braxton Hicks adalah kontraksi latihan yang normal. Jika mengalami tanda-tanda persalinan, segera hubungi dokter atau bidan.',
        category: 'Trimester 3',
        readTime: 5,
        views: 0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),

      Article(
        id: 'artikel_013',
        title: 'Posisi Tidur yang Baik Ibu Hamil',
        content:
            'Posisi tidur terbaik adalah miring ke kiri dengan bantal di antara lutut dan di bawah perut. Hindari tidur telentang karena dapat menekan pembuluh darah besar. Gunakan bantal khusus kehamilan untuk kenyamanan maksimal.',
        category: 'Trimester 3',
        readTime: 4,
        views: 0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 13)),
      ),

      Article(
        id: 'artikel_014',
        title: 'Persiapan Menyusui Sejak Hamil',
        content:
            'Persiapan menyusui dimulai sejak kehamilan dengan mempelajari teknik menyusui yang benar, mempersiapkan payudara, dan mencari informasi tentang ASI eksklusif. Konsultasi dengan konselor laktasi sangat membantu untuk keberhasilan menyusui.',
        category: 'Trimester 3',
        readTime: 6,
        views: 0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
      ),

      Article(
        id: 'artikel_015',
        title: 'Checklist Hospital Bag',
        content:
            'Barang yang perlu disiapkan: pakaian ganti, pembalut khusus nifas, pakaian dalam, sandal, toiletries, charger HP, buku catatan, dan dokumen penting. Siapkan juga pakaian dan perlengkapan bayi. Packing sejak minggu ke-36 untuk menghindari ketergesa-gesaan.',
        category: 'Trimester 3',
        readTime: 4,
        views: 0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }
}
