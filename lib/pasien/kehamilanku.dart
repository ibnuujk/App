import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';
import '../../routes/route_helper.dart';

class KehamilankuScreen extends StatefulWidget {
  final UserModel user;

  const KehamilankuScreen({super.key, required this.user});

  @override
  State<KehamilankuScreen> createState() => _KehamilankuScreenState();
}

class _KehamilankuScreenState extends State<KehamilankuScreen>
    with TickerProviderStateMixin {
  // Fetal information variables
  int? _gestationalAgeWeeks;
  int? _gestationalAgeDays;
  DateTime? _estimatedDueDate;
  String? _fetalSize;
  String? _trimester;
  String? _developmentInfo;
  double? _fetalLength;
  double? _fetalWeight;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
    _loadFetalInformation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadFetalInformation() {
    if (widget.user.hpht != null) {
      final now = DateTime.now();
      final hpht = widget.user.hpht!;

      // Calculate gestational age from HPHT
      final difference = now.difference(hpht);

      if (difference.inDays < 0) {
        _gestationalAgeWeeks = 0;
        _gestationalAgeDays = 0;
      } else {
        _gestationalAgeWeeks = difference.inDays ~/ 7;
        _gestationalAgeDays = difference.inDays % 7;
      }

      // Calculate estimated due date (40 weeks from HPHT)
      _estimatedDueDate = hpht.add(const Duration(days: 280));

      // Determine trimester
      if (_gestationalAgeWeeks! < 13) {
        _trimester = 'Trimester 1';
      } else if (_gestationalAgeWeeks! < 27) {
        _trimester = 'Trimester 2';
      } else {
        _trimester = 'Trimester 3';
      }

      // Get fetal information
      _fetalSize = _getFetalSizeComparison(_gestationalAgeWeeks!);
      _fetalLength = _getFetalLength(_gestationalAgeWeeks!);
      _fetalWeight = _getFetalWeight(_gestationalAgeWeeks!);
      _developmentInfo = _getDevelopmentInfo(_gestationalAgeWeeks!);
    }
  }

  String _getFetalSizeComparison(int weeks) {
    if (weeks < 4) return 'Seukuran biji poppy';
    if (weeks < 5) return 'Seukuran biji wijen';
    if (weeks < 6) return 'Seukuran biji delima';
    if (weeks < 7) return 'Seukuran blueberry';
    if (weeks < 8) return 'Seukuran kacang merah';
    if (weeks < 9) return 'Seukuran anggur';
    if (weeks < 10) return 'Seukuran kumquat';
    if (weeks < 11) return 'Seukuran stroberi';
    if (weeks < 12) return 'Seukuran lemon';
    if (weeks < 13) return 'Seukuran jeruk nipis';
    if (weeks < 14) return 'Seukuran lemon';
    if (weeks < 15) return 'Seukuran apel';
    if (weeks < 16) return 'Seukuran alpukat';
    if (weeks < 17) return 'Seukuran pir';
    if (weeks < 18) return 'Seukuran paprika';
    if (weeks < 19) return 'Seukuran tomat';
    if (weeks < 20) return 'Seukuran pisang';
    if (weeks < 21) return 'Seukuran wortel';
    if (weeks < 22) return 'Seukuran labu kecil';
    if (weeks < 23) return 'Seukuran mangga';
    if (weeks < 24) return 'Seukuran jagung';
    if (weeks < 25) return 'Seukuran kembang kol';
    if (weeks < 26) return 'Seukuran selada';
    if (weeks < 27) return 'Seukuran brokoli';
    if (weeks < 28) return 'Seukuran terong';
    if (weeks < 29) return 'Seukuran labu';
    if (weeks < 30) return 'Seukuran kubis';
    if (weeks < 31) return 'Seukuran nanas';
    if (weeks < 32) return 'Seukuran labu besar';
    if (weeks < 33) return 'Seukuran nanas';
    if (weeks < 34) return 'Seukuran melon';
    if (weeks < 35) return 'Seukuran melon';
    if (weeks < 36) return 'Seukuran selada romaine';
    if (weeks < 37) return 'Seukuran seledri';
    if (weeks < 38) return 'Seukuran daun bawang';
    if (weeks < 39) return 'Seukuran semangka mini';
    return 'Seukuran semangka';
  }

  double _getFetalLength(int weeks) {
    if (weeks < 8) return 0.0;
    if (weeks < 9) return 1.6;
    if (weeks < 10) return 2.3;
    if (weeks < 11) return 3.1;
    if (weeks < 12) return 4.1;
    if (weeks < 13) return 5.4;
    if (weeks < 14) return 7.4;
    if (weeks < 15) return 8.7;
    if (weeks < 16) return 10.1;
    if (weeks < 17) return 11.6;
    if (weeks < 18) return 13.0;
    if (weeks < 19) return 14.2;
    if (weeks < 20) return 15.3;
    if (weeks < 21) return 26.7;
    if (weeks < 22) return 27.8;
    if (weeks < 23) return 28.9;
    if (weeks < 24) return 30.0;
    if (weeks < 25) return 31.1;
    if (weeks < 26) return 32.2;
    if (weeks < 27) return 33.3;
    if (weeks < 28) return 34.4;
    if (weeks < 29) return 35.5;
    if (weeks < 30) return 36.6;
    if (weeks < 31) return 37.7;
    if (weeks < 32) return 38.8;
    if (weeks < 33) return 39.9;
    if (weeks < 34) return 41.0;
    if (weeks < 35) return 42.1;
    if (weeks < 36) return 43.2;
    if (weeks < 37) return 44.3;
    if (weeks < 38) return 45.4;
    if (weeks < 39) return 46.5;
    if (weeks < 40) return 47.6;
    return 48.0;
  }

  double _getFetalWeight(int weeks) {
    if (weeks < 8) return 0.0;
    if (weeks < 9) return 1.0;
    if (weeks < 10) return 4.0;
    if (weeks < 11) return 7.0;
    if (weeks < 12) return 14.0;
    if (weeks < 13) return 23.0;
    if (weeks < 14) return 43.0;
    if (weeks < 15) return 70.0;
    if (weeks < 16) return 100.0;
    if (weeks < 17) return 140.0;
    if (weeks < 18) return 190.0;
    if (weeks < 19) return 240.0;
    if (weeks < 20) return 300.0;
    if (weeks < 21) return 360.0;
    if (weeks < 22) return 430.0;
    if (weeks < 23) return 501.0;
    if (weeks < 24) return 600.0;
    if (weeks < 25) return 660.0;
    if (weeks < 26) return 760.0;
    if (weeks < 27) return 875.0;
    if (weeks < 28) return 1005.0;
    if (weeks < 29) return 1153.0;
    if (weeks < 30) return 1319.0;
    if (weeks < 31) return 1502.0;
    if (weeks < 32) return 1702.0;
    if (weeks < 33) return 1918.0;
    if (weeks < 34) return 2146.0;
    if (weeks < 35) return 2383.0;
    if (weeks < 36) return 2622.0;
    if (weeks < 37) return 2859.0;
    if (weeks < 38) return 3083.0;
    if (weeks < 39) return 3288.0;
    if (weeks < 40) return 3462.0;
    return 3500.0;
  }

  String _getDevelopmentInfo(int weeks) {
    if (weeks < 4)
      return 'Minggu 3-4: Pada minggu awal, sesungguhnya adalah hari mentruasimu karena prakiraan hari lahir dihitung dari hari pertama haid terakhir';
    if (weeks < 5)
      return 'Minggu 4-5: Implantasi sel telur di rahim, pembentukan blastokista dan embrio awal';
    if (weeks < 6)
      return 'Minggu 5-6: Pembentukan kantung kehamilan, embrio mulai berkembang dengan ukuran 2-4mm';
    if (weeks < 7)
      return 'Minggu 6-7: Jantung mulai berdetak, pembentukan plasenta awal, ukuran embrio 4-7mm';
    if (weeks < 8)
      return 'Minggu 7-8: Pembentukan organ utama (jantung, otak, paru-paru), embrio menjadi janin, ukuran 7-11mm';
    if (weeks < 9)
      return 'Minggu 8-9: Jari tangan dan kaki mulai terbentuk, kepala membesar, ukuran janin 11-14mm';
    if (weeks < 10)
      return 'Minggu 9-10: Organ genital mulai berkembang, kuku mulai tumbuh, ukuran janin 14-18mm';
    if (weeks < 11)
      return 'Minggu 10-11: Kepala dan otak berkembang pesat, mata mulai terbentuk, ukuran janin 18-22mm';
    if (weeks < 12)
      return 'Minggu 11-12: Semua organ utama terbentuk, janin mulai bergerak, ukuran janin 22-28mm';
    if (weeks < 13)
      return 'Minggu 12-13: Trimester pertama selesai, janin lebih aktif, ukuran janin 28-35mm';
    if (weeks < 14)
      return 'Minggu 13-14: Janin mulai bergerak (quickening), rambut halus tumbuh, ukuran janin 35-42mm';
    if (weeks < 15)
      return 'Minggu 14-15: Tulang mulai mengeras, kulit transparan, ukuran janin 42-50mm';
    if (weeks < 16)
      return 'Minggu 15-16: Janin dapat menelan, sistem pencernaan berkembang, ukuran janin 50-60mm';
    if (weeks < 17)
      return 'Minggu 16-17: Lemak mulai terbentuk, janin dapat mendengar suara, ukuran janin 60-70mm';
    if (weeks < 18)
      return 'Minggu 17-18: Janin dapat mendengar suara, sistem kekebalan berkembang, ukuran janin 70-80mm';
    if (weeks < 19)
      return 'Minggu 18-19: Rambut mulai tumbuh, kuku jari terbentuk, ukuran janin 80-90mm';
    if (weeks < 20)
      return 'Minggu 19-20: Pertengahan kehamilan, janin dapat merasakan sentuhan, ukuran janin 90-100mm';
    if (weeks < 21)
      return 'Minggu 20-21: Janin lebih aktif bergerak, sistem saraf berkembang, ukuran janin 100-110mm';
    if (weeks < 22)
      return 'Minggu 21-22: Alis dan bulu mata terbentuk, kulit mulai menebal, ukuran janin 110-120mm';
    if (weeks < 23)
      return 'Minggu 22-23: Kulit mulai menebal, lemak tubuh bertambah, ukuran janin 120-130mm';
    if (weeks < 24)
      return 'Minggu 23-24: Paru-paru mulai matang, janin dapat merespon suara, ukuran janin 130-140mm';
    if (weeks < 25)
      return 'Minggu 24-25: Janin dapat merespon suara, sistem pernapasan berkembang, ukuran janin 140-150mm';
    if (weeks < 26)
      return 'Minggu 25-26: Mata mulai terbuka, janin dapat membedakan terang/gelap, ukuran janin 150-160mm';
    if (weeks < 27)
      return 'Minggu 26-27: Trimester kedua selesai, otak berkembang pesat, ukuran janin 160-170mm';
    if (weeks < 28)
      return 'Minggu 27-28: Otak berkembang pesat, janin dapat bermimpi (REM), ukuran janin 170-180mm';
    if (weeks < 29)
      return 'Minggu 28-29: Janin dapat bermimpi (REM), sistem kekebalan berkembang, ukuran janin 180-190mm';
    if (weeks < 30)
      return 'Minggu 29-30: Sistem kekebalan berkembang, janin dapat bernapas, ukuran janin 190-200mm';
    if (weeks < 31)
      return 'Minggu 30-31: Janin dapat bernapas, kuku jari terbentuk sempurna, ukuran janin 200-210mm';
    if (weeks < 32)
      return 'Minggu 31-32: Kuku jari terbentuk sempurna, janin dapat membedakan terang/gelap, ukuran janin 210-220mm';
    if (weeks < 33)
      return 'Minggu 32-33: Janin dapat membedakan terang/gelap, paru-paru hampir matang, ukuran janin 220-230mm';
    if (weeks < 34)
      return 'Minggu 33-34: Paru-paru hampir matang, janin mulai menambah berat, ukuran janin 230-240mm';
    if (weeks < 35)
      return 'Minggu 34-35: Janin mulai menambah berat, sistem kekebalan matang, ukuran janin 240-250mm';
    if (weeks < 36)
      return 'Minggu 35-36: Janin siap lahir, semua sistem berfungsi baik, ukuran janin 250-260mm';
    if (weeks < 37)
      return 'Minggu 36-37: Kehamilan cukup bulan, janin optimal untuk kelahiran, ukuran janin 260-270mm';
    if (weeks < 38)
      return 'Minggu 37-38: Janin terus berkembang, persiapan kelahiran, ukuran janin 270-280mm';
    if (weeks < 39)
      return 'Minggu 38-39: Persiapan kelahiran, janin siap dilahirkan, ukuran janin 280-290mm';
    return 'Minggu 39-40: Siap untuk dilahirkan, semua sistem optimal, ukuran janin 290-300mm';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Kehamilanku',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEC407A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child:
              widget.user.hpht != null && _gestationalAgeWeeks != null
                  ? _buildContent()
                  : _buildNoDataContent(),
        ),
      ),
    );
  }

  Widget _buildNoDataContent() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFEC407A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.pregnant_woman_rounded,
                size: 60,
                color: const Color(0xFFEC407A).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Data HPHT Belum Tersedia',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Untuk melihat informasi kehamilan yang lengkap, Anda perlu mengisi data HPHT (Hari Pertama Haid Terakhir) terlebih dahulu.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_rounded,
                        color: const Color(0xFFEC407A),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Mengapa HPHT Penting?',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'HPHT digunakan untuk menghitung usia kehamilan, trimester, perkiraan lahir, dan informasi perkembangan janin yang akurat.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                RouteHelper.navigateToHPHTForm(context, widget.user);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC407A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Isi Data HPHT Sekarang',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFCDD2),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: const Color(0xFFEC407A).withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Image.asset(
                            'assets/icons/bayi.png',
                            width: 48,
                            height: 48,
                            color: const Color(0xFFEC407A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bayimu sekarang',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.user.hpht != null && _fetalSize != null
                                  ? _fetalSize!
                                  : 'Belum ada data',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEC407A).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(
                                    0xFFEC407A,
                                  ).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Minggu $_gestationalAgeWeeks',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFEC407A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Information Grid
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        // First row
                        Row(
                          children: [
                            Expanded(
                              child: _buildFetalInfoColumn(
                                'Panjang Bayi',
                                '${_fetalLength?.toStringAsFixed(1) ?? '0.0'} cm',
                                Icons.straighten_rounded,
                              ),
                            ),
                            Expanded(
                              child: _buildFetalInfoColumn(
                                'Berat Bayi',
                                '${_fetalWeight?.toStringAsFixed(0) ?? '0'} gr',
                                Icons.monitor_weight_rounded,
                              ),
                            ),
                            Expanded(
                              child: _buildFetalInfoColumn(
                                'Prakiraan Lahir',
                                _formatDate(_estimatedDueDate!),
                                Icons.calendar_today_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Second row
                        Row(
                          children: [
                            Expanded(
                              child: _buildFetalInfoColumn(
                                'Trimester',
                                _trimester!,
                                Icons.pregnant_woman_rounded,
                              ),
                            ),
                            Expanded(
                              child: _buildFetalInfoColumn(
                                'Umur Janin',
                                '$_gestationalAgeWeeks minggu $_gestationalAgeDays hari',
                                Icons.timer_rounded,
                              ),
                            ),
                            Expanded(
                              child: _buildFetalInfoColumn(
                                'Hari Tersisa',
                                '${_calculateRemainingDays()} hari',
                                Icons.schedule_rounded,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Development Information
            Text(
              'Informasi Perkembangan',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.psychology_rounded,
                        color: const Color(0xFFEC407A),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Perkembangan Janin',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current week development info
                        _buildDevelopmentTimelineItem(
                          'Perkembangan Saat Ini',
                          _developmentInfo!,
                          const Color(0xFFEC407A),
                        ),
                        const SizedBox(height: 20),
                        // Previous weeks development
                        if (_gestationalAgeWeeks! > 4) ...[
                          _buildDevelopmentTimelineItem(
                            'Minggu ${_gestationalAgeWeeks! - 1}',
                            _getPreviousWeekInfo(_gestationalAgeWeeks! - 1),
                            const Color(0xFFF48FB1),
                          ),
                          const SizedBox(height: 20),
                        ],
                        if (_gestationalAgeWeeks! > 5) ...[
                          _buildDevelopmentTimelineItem(
                            'Minggu ${_gestationalAgeWeeks! - 2}',
                            _getPreviousWeekInfo(_gestationalAgeWeeks! - 2),
                            const Color(0xFFF48FB1),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Pregnancy Tips
            Text(
              'Tips Kehamilan',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sesuai dengan $_trimester Anda',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            _buildPregnancyTips(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFetalInfoColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFEC407A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFEC407A).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(icon, color: const Color(0xFFEC407A), size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3748),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  int _calculateRemainingDays() {
    if (_estimatedDueDate == null) return 0;
    final now = DateTime.now();
    final difference = _estimatedDueDate!.difference(now);
    return difference.inDays > 0 ? difference.inDays : 0;
  }

  String _getPreviousWeekInfo(int week) {
    if (week < 4)
      return 'Pada minggu awal, sesungguhnya adalah hari mentruasimu karena prakiraan hari lahir dihitung dari hari pertama haid terakhir';
    if (week < 5)
      return 'Implantasi sel telur di rahim, pembentukan blastokista dan embrio awal';
    if (week < 6)
      return 'Pembentukan kantung kehamilan, embrio mulai berkembang dengan ukuran 2-4mm';
    if (week < 7)
      return 'Jantung mulai berdetak, pembentukan plasenta awal, ukuran embrio 4-7mm';
    if (week < 8)
      return 'Pembentukan organ utama (jantung, otak, paru-paru), embrio menjadi janin, ukuran 7-11mm';
    if (week < 9)
      return 'Jari tangan dan kaki mulai terbentuk, kepala membesar, ukuran janin 11-14mm';
    if (week < 10)
      return 'Organ genital mulai berkembang, kuku mulai tumbuh, ukuran janin 14-18mm';
    if (week < 11)
      return 'Kepala dan otak berkembang pesat, mata mulai terbentuk, ukuran janin 18-22mm';
    if (week < 12)
      return 'Semua organ utama terbentuk, janin mulai bergerak, ukuran janin 22-28mm';
    if (week < 13)
      return 'Trimester pertama selesai, janin lebih aktif, ukuran janin 28-35mm';
    if (week < 14)
      return 'Janin mulai bergerak (quickening), rambut halus tumbuh, ukuran janin 35-42mm';
    if (week < 15)
      return 'Tulang mulai mengeras, kulit transparan, ukuran janin 42-50mm';
    if (week < 16)
      return 'Janin dapat menelan, sistem pencernaan berkembang, ukuran janin 50-60mm';
    if (week < 17)
      return 'Lemak mulai terbentuk, janin dapat mendengar suara, ukuran janin 60-70mm';
    if (week < 18)
      return 'Janin dapat mendengar suara, sistem kekebalan berkembang, ukuran janin 70-80mm';
    if (week < 19)
      return 'Rambut mulai tumbuh, kuku jari terbentuk, ukuran janin 80-90mm';
    if (week < 20)
      return 'Pertengahan kehamilan, janin dapat merasakan sentuhan, ukuran janin 90-100mm';
    if (week < 21)
      return 'Janin lebih aktif bergerak, sistem saraf berkembang, ukuran janin 100-110mm';
    if (week < 22)
      return 'Alis dan bulu mata terbentuk, kulit mulai menebal, ukuran janin 110-120mm';
    if (week < 23)
      return 'Kulit mulai menebal, lemak tubuh bertambah, ukuran janin 120-130mm';
    if (week < 24)
      return 'Paru-paru mulai matang, janin dapat merespon suara, ukuran janin 130-140mm';
    if (week < 25)
      return 'Janin dapat merespon suara, sistem pernapasan berkembang, ukuran janin 140-150mm';
    if (week < 26)
      return 'Mata mulai terbuka, janin dapat membedakan terang/gelap, ukuran janin 150-160mm';
    if (week < 27)
      return 'Trimester kedua selesai, otak berkembang pesat, ukuran janin 160-170mm';
    if (week < 28)
      return 'Otak berkembang pesat, janin dapat bermimpi (REM), ukuran janin 170-180mm';
    if (week < 29)
      return 'Janin dapat bermimpi (REM), sistem kekebalan berkembang, ukuran janin 180-190mm';
    if (week < 30)
      return 'Sistem kekebalan berkembang, janin dapat bernapas, ukuran janin 190-200mm';
    if (week < 31)
      return 'Janin dapat bernapas, kuku jari terbentuk sempurna, ukuran janin 200-210mm';
    if (week < 32)
      return 'Kuku jari terbentuk sempurna, janin dapat membedakan terang/gelap, ukuran janin 210-220mm';
    if (week < 33)
      return 'Janin dapat membedakan terang/gelap, paru-paru hampir matang, ukuran janin 220-230mm';
    if (week < 34)
      return 'Paru-paru hampir matang, janin mulai menambah berat, ukuran janin 230-240mm';
    if (week < 35)
      return 'Janin mulai menambah berat, sistem kekebalan matang, ukuran janin 240-250mm';
    if (week < 36)
      return 'Janin siap lahir, semua sistem berfungsi baik, ukuran janin 250-260mm';
    if (week < 37)
      return 'Kehamilan cukup bulan, janin optimal untuk kelahiran, ukuran janin 260-270mm';
    if (week < 38)
      return 'Janin terus berkembang, persiapan kelahiran, ukuran janin 270-280mm';
    if (week < 39)
      return 'Persiapan kelahiran, janin siap dilahirkan, ukuran janin 280-290mm';
    return 'Siap untuk dilahirkan, semua sistem optimal, ukuran janin 290-300mm';
  }

  Widget _buildDevelopmentTimelineItem(
    String title,
    String description,
    Color bulletColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bullet point and vertical line
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: bulletColor,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 60,
              color: bulletColor.withOpacity(0.3),
            ),
          ],
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF2D3748),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPregnancyTips() {
    List<Map<String, dynamic>> tips = [];

    switch (_trimester) {
      case 'Trimester 1':
        tips = [
          {
            'title': 'Asam Folat',
            'description':
                'Konsumsi 400-800 mcg asam folat per hari untuk mencegah cacat tabung saraf',
            'icon': Icons.medication_rounded,
            'color': Colors.blue,
          },
          {
            'title': 'Morning Sickness',
            'description':
                'Makan dalam porsi kecil tapi sering, hindari makanan berlemak',
            'icon': Icons.sick_rounded,
            'color': Colors.orange,
          },
          {
            'title': 'Istirahat Cukup',
            'description': 'Tidur 8-10 jam per hari, hindari aktivitas berat',
            'icon': Icons.bedtime_rounded,
            'color': Colors.purple,
          },
        ];
        break;
      case 'Trimester 2':
        tips = [
          {
            'title': 'Nutrisi Seimbang',
            'description': 'Tingkatkan asupan protein, kalsium, dan zat besi',
            'icon': Icons.restaurant_rounded,
            'color': Colors.green,
          },
          {
            'title': 'Olahraga Ringan',
            'description':
                'Lakukan jalan kaki atau yoga prenatal 30 menit per hari',
            'icon': Icons.directions_walk_rounded,
            'color': Colors.blue,
          },
          {
            'title': 'Posisi Tidur',
            'description':
                'Tidur miring ke kiri untuk aliran darah yang lebih baik',
            'icon': Icons.hotel_rounded,
            'color': Colors.purple,
          },
        ];
        break;
      case 'Trimester 3':
        tips = [
          {
            'title': 'Persiapan Persalinan',
            'description':
                'Siapkan tas untuk rumah sakit dan rencana transportasi',
            'icon': Icons.local_hospital_rounded,
            'color': Colors.red,
          },
          {
            'title': 'Tanda Persalinan',
            'description':
                'Kenali tanda-tanda persalinan: kontraksi teratur, pecah ketuban',
            'icon': Icons.warning_rounded,
            'color': Colors.orange,
          },
          {
            'title': 'Istirahat Total',
            'description':
                'Hindari aktivitas berat, fokus pada persiapan kelahiran',
            'icon': Icons.weekend_rounded,
            'color': Colors.purple,
          },
        ];
        break;
    }

    return Column(
      children:
          tips
              .map(
                (tip) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: tip['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(tip['icon'], color: tip['color'], size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tip['title'],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tip['description'],
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }
}
