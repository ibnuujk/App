import 'package:intl/intl.dart';

class PregnancyCalculator {
  // Calculate gestational age in weeks and days
  static Map<String, int> calculateGestationalAge(DateTime hpht) {
    final DateTime today = DateTime.now();
    final Duration difference = today.difference(hpht);
    final int totalDays = difference.inDays;
    final int weeks = totalDays ~/ 7;
    final int days = totalDays % 7;

    return {
      'weeks': weeks,
      'days': days,
      'totalDays': totalDays,
    };
  }

  // Calculate estimated due date (40 weeks from HPHT)
  static DateTime calculateDueDate(DateTime hpht) {
    return hpht.add(const Duration(days: 280)); // 40 weeks = 280 days
  }

  // Get trimester based on gestational age
  static String getTrimester(int weeks) {
    if (weeks < 13) {
      return 'Trimester 1';
    } else if (weeks < 27) {
      return 'Trimester 2';
    } else {
      return 'Trimester 3';
    }
  }

  // Get fetal size comparison (fruit/vegetable comparisons)
  static String getFetalSizeComparison(int weeks) {
    if (weeks < 4) {
      return 'Belum terdeteksi';
    } else if (weeks < 6) {
      return 'Seukuran biji wijen';
    } else if (weeks < 8) {
      return 'Seukuran biji delima';
    } else if (weeks < 10) {
      return 'Seukuran buah anggur';
    } else if (weeks < 12) {
      return 'Seukuran buah stroberi';
    } else if (weeks < 14) {
      return 'Seukuran buah lemon';
    } else if (weeks < 16) {
      return 'Seukuran buah apel';
    } else if (weeks < 18) {
      return 'Seukuran buah pir';
    } else if (weeks < 20) {
      return 'Seukuran buah pisang';
    } else if (weeks < 22) {
      return 'Seukuran wortel';
    } else if (weeks < 24) {
      return 'Seukuran jagung';
    } else if (weeks < 26) {
      return 'Seukuran kembang kol';
    } else if (weeks < 28) {
      return 'Seukuran terong';
    } else if (weeks < 30) {
      return 'Seukuran kubis';
    } else if (weeks < 32) {
      return 'Seukuran nanas';
    } else if (weeks < 34) {
      return 'Seukuran melon';
    } else if (weeks < 36) {
      return 'Seukuran selada romaine';
    } else if (weeks < 38) {
      return 'Seukuran daun bawang';
    } else if (weeks < 40) {
      return 'Seukuran semangka kecil';
    } else {
      return 'Siap lahir';
    }
  }

  // Get nutrition tips based on trimester
  static List<String> getNutritionTips(String trimester) {
    switch (trimester) {
      case 'Trimester 1':
        return [
          'Konsumsi asam folat untuk perkembangan otak dan tulang belakang',
          'Makan makanan kaya zat besi untuk mencegah anemia',
          'Konsumsi protein untuk pertumbuhan sel',
          'Minum air putih minimal 8 gelas per hari',
          'Hindari makanan mentah dan alkohol',
          'Konsumsi vitamin C untuk penyerapan zat besi',
        ];
      case 'Trimester 2':
        return [
          'Tingkatkan asupan kalsium untuk pertumbuhan tulang',
          'Konsumsi omega-3 untuk perkembangan otak',
          'Makan makanan kaya serat untuk mencegah sembelit',
          'Konsumsi protein untuk pertumbuhan janin',
          'Minum susu atau produk susu rendah lemak',
          'Konsumsi sayuran hijau untuk vitamin K',
        ];
      case 'Trimester 3':
        return [
          'Tingkatkan asupan kalori untuk persiapan persalinan',
          'Konsumsi makanan kaya kalsium untuk persiapan menyusui',
          'Makan makanan kaya serat untuk mencegah sembelit',
          'Konsumsi protein untuk pertumbuhan otot',
          'Minum air putih lebih banyak untuk mencegah dehidrasi',
          'Konsumsi makanan kaya vitamin C untuk kekebalan tubuh',
        ];
      default:
        return [
          'Konsumsi makanan bergizi seimbang',
          'Minum air putih yang cukup',
          'Hindari makanan yang tidak aman untuk ibu hamil',
        ];
    }
  }

  // Get pregnancy week information
  static Map<String, String> getPregnancyWeekInfo(int weeks) {
    if (weeks < 1) {
      return {
        'title': 'Minggu 1-4: Awal Kehamilan',
        'description':
            'Sel telur yang telah dibuahi akan menempel pada dinding rahim. Gejala awal kehamilan mungkin belum terasa.',
      };
    } else if (weeks < 13) {
      return {
        'title': 'Trimester Pertama',
        'description':
            'Masa pembentukan organ-organ penting janin. Perlu asupan asam folat yang cukup.',
      };
    } else if (weeks < 27) {
      return {
        'title': 'Trimester Kedua',
        'description':
            'Masa pertumbuhan dan perkembangan janin yang pesat. Ibu hamil biasanya merasa lebih nyaman.',
      };
    } else if (weeks < 40) {
      return {
        'title': 'Trimester Ketiga',
        'description':
            'Masa persiapan persalinan. Janin terus bertumbuh dan berkembang.',
      };
    } else {
      return {
        'title': 'Masa Persalinan',
        'description':
            'Janin sudah siap untuk dilahirkan. Perhatikan tanda-tanda persalinan.',
      };
    }
  }

  // Format date for display
  static String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  // Calculate days until due date
  static int daysUntilDueDate(DateTime dueDate) {
    final DateTime today = DateTime.now();
    final Duration difference = dueDate.difference(today);
    return difference.inDays;
  }

  // Get pregnancy progress percentage
  static double getPregnancyProgress(int weeks) {
    if (weeks >= 40) return 100.0;
    return (weeks / 40) * 100;
  }
}
