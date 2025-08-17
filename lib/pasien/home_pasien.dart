import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';
import '../../routes/route_helper.dart';
import 'jadwal_pasien.dart';
import 'profile.dart';

class HomePasienScreen extends StatefulWidget {
  final UserModel user;

  const HomePasienScreen({super.key, required this.user});

  @override
  State<HomePasienScreen> createState() => _HomePasienScreenState();
}

class _HomePasienScreenState extends State<HomePasienScreen>
    with TickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Fetal information variables
  int? _gestationalAgeWeeks;
  int? _gestationalAgeDays;
  DateTime? _estimatedDueDate;
  String? _fetalSize;
  String? _trimester;
  String? _developmentInfo;
  double? _fetalLength;
  double? _fetalWeight;

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

    // Debug print untuk memeriksa data user
    print('=== USER DATA DEBUG ===');
    print('User ID: ${widget.user.id}');
    print('User Email: ${widget.user.email}');
    print('User Nama: ${widget.user.nama}');
    print('User Role: ${widget.user.role}');
    print('User HPHT: ${widget.user.hpht}');
    print('========================');
  }

  @override
  void didUpdateWidget(HomePasienScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload fetal information if HPHT data changes
    if (oldWidget.user.hpht != widget.user.hpht) {
      _loadFetalInformation();
    }
  }

  void _loadFetalInformation() {
    if (widget.user.hpht != null) {
      final now = DateTime.now();
      final hpht = widget.user.hpht!;

      // Calculate gestational age from HPHT (Hari Pertama Haid Terakhir)
      // Dalam dunia medis, usia kehamilan dihitung dari HPHT
      // HPHT adalah hari pertama haid terakhir, bukan hari pembuahan
      // Usia kehamilan = selisih hari dari HPHT
      final difference = now.difference(hpht);

      // Jika HPHT lebih dari hari ini, berarti belum hamil
      if (difference.inDays < 0) {
        _gestationalAgeWeeks = 0;
        _gestationalAgeDays = 0;
        print('HPHT is in the future - not pregnant yet');
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

      // Determine fetal size comparison
      _fetalSize = _getFetalSizeComparison(_gestationalAgeWeeks!);

      // Calculate fetal length and weight
      _fetalLength = _getFetalLength(_gestationalAgeWeeks!);
      _fetalWeight = _getFetalWeight(_gestationalAgeWeeks!);

      // Get development information
      _developmentInfo = _getDevelopmentInfo(_gestationalAgeWeeks!);

      // Debug information
      print('=== FETAL INFORMATION DEBUG ===');
      print('HPHT: ${hpht.toString()}');
      print('Today: ${now.toString()}');
      print('Days difference: ${difference.inDays}');
      print(
        'Gestational Age: $_gestationalAgeWeeks weeks $_gestationalAgeDays days',
      );
      print('Trimester: $_trimester');
      print('Fetal Size: $_fetalSize');
      print('Fetal Length: $_fetalLength cm');
      print('Fetal Weight: $_fetalWeight gram');
      print('Estimated Due Date: ${_estimatedDueDate.toString()}');
      print('Development Info: $_developmentInfo');
      print('==============================');
    } else {
      print('No HPHT data available for user: ${widget.user.nama}');
      // Reset all fetal information
      _gestationalAgeWeeks = null;
      _gestationalAgeDays = null;
      _estimatedDueDate = null;
      _fetalSize = null;
      _trimester = null;
      _fetalLength = null;
      _fetalWeight = null;
      _developmentInfo = null;
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
    // Panjang janin dalam cm (CRL - Crown Rump Length)
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
    if (weeks < 21) return 26.7; // Mulai menggunakan FL (Femur Length)
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
    // Berat janin dalam gram
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
    if (weeks < 4) return 'Pembentukan sel telur dan sperma';
    if (weeks < 5) return 'Implantasi sel telur di rahim';
    if (weeks < 6) return 'Pembentukan kantung kehamilan';
    if (weeks < 7) return 'Jantung mulai berdetak';
    if (weeks < 8) return 'Pembentukan organ utama';
    if (weeks < 9) return 'Jari tangan dan kaki mulai terbentuk';
    if (weeks < 10) return 'Organ genital mulai berkembang';
    if (weeks < 11) return 'Kepala dan otak berkembang pesat';
    if (weeks < 12) return 'Semua organ utama terbentuk';
    if (weeks < 13) return 'Trimester pertama selesai';
    if (weeks < 14) return 'Janin mulai bergerak';
    if (weeks < 15) return 'Tulang mulai mengeras';
    if (weeks < 16) return 'Janin dapat menelan';
    if (weeks < 17) return 'Lemak mulai terbentuk';
    if (weeks < 18) return 'Janin dapat mendengar suara';
    if (weeks < 19) return 'Rambut mulai tumbuh';
    if (weeks < 20) return 'Pertengahan kehamilan';
    if (weeks < 21) return 'Janin lebih aktif bergerak';
    if (weeks < 22) return 'Alis dan bulu mata terbentuk';
    if (weeks < 23) return 'Kulit mulai menebal';
    if (weeks < 24) return 'Paru-paru mulai matang';
    if (weeks < 25) return 'Janin dapat merespon suara';
    if (weeks < 26) return 'Mata mulai terbuka';
    if (weeks < 27) return 'Trimester kedua selesai';
    if (weeks < 28) return 'Otak berkembang pesat';
    if (weeks < 29) return 'Janin dapat bermimpi (REM)';
    if (weeks < 30) return 'Sistem kekebalan berkembang';
    if (weeks < 31) return 'Janin dapat bernapas';
    if (weeks < 32) return 'Kuku jari terbentuk sempurna';
    if (weeks < 33) return 'Janin dapat membedakan terang/gelap';
    if (weeks < 34) return 'Paru-paru hampir matang';
    if (weeks < 35) return 'Janin mulai menambah berat';
    if (weeks < 36) return 'Janin siap lahir';
    if (weeks < 37) return 'Kehamilan cukup bulan';
    if (weeks < 38) return 'Janin terus berkembang';
    if (weeks < 39) return 'Persiapan kelahiran';
    return 'Siap untuk dilahirkan';
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),
          _buildScheduleScreen(),
          _buildProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                Icons.home_rounded,
                'Beranda',
                0,
              ), //gunakan icon home.png
              _buildNavItem(
                Icons.calendar_today_rounded,
                'Jadwal',
                1,
              ), //gunakan icon calendar.png
              _buildNavItem(Icons.person_rounded, 'Profil', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEC407A) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section with enhanced design
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${widget.user.nama.isNotEmpty ? widget.user.nama : 'Pasien'}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _buildHeaderIcon(Icons.notifications_rounded, () {
                            // Notification action
                          }),
                          const SizedBox(width: 12),
                          _buildHeaderIcon(Icons.person_rounded, () {
                            _showLogoutDialog();
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.user.hpht != null && _gestationalAgeWeeks != null
                      ? 'Minggu $_gestationalAgeWeeks Kehamilan'
                      : 'Minggu 0 Kehamilan',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 24),

                // Calendar Component
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
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
                  child: _buildCalendar(),
                ),
                const SizedBox(height: 30),

                // Enhanced Fetal Information Card
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
                      // Top Section with Icon and Description
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
                                width: 60,
                                height: 60,
                                color: const Color(0xFFEC407A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  widget.user.hpht != null && _fetalSize != null
                                      ? 'Bayimu sekarang $_fetalSize'
                                      : 'Belum ada data HPHT',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2D3748),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (widget.user.hpht != null &&
                          _gestationalAgeWeeks != null) ...[
                        const SizedBox(height: 24),
                        // Bottom Section with 3 columns
                        Row(
                          children: [
                            Expanded(
                              child: _buildFetalInfoColumn(
                                'Panjang Bayi',
                                '${_fetalLength?.toStringAsFixed(1) ?? '0.0'} cm',
                              ),
                            ),
                            Expanded(
                              child: _buildFetalInfoColumn(
                                'Berat Bayi',
                                '${_fetalWeight?.toStringAsFixed(0) ?? '0'} gr',
                              ),
                            ),
                            Expanded(
                              child: _buildFetalInfoColumn(
                                'Prakiraan Lahir',
                                _formatDate(_estimatedDueDate!),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFCDD2).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFEC407A).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_rounded,
                                    color: const Color(0xFFEC407A),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Data HPHT Belum Tersedia',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF2D3748),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Untuk melihat informasi janin yang lengkap, silakan isi data HPHT di fitur Kehamilanku.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () {
                                  RouteHelper.navigateToHPHTForm(
                                    context,
                                    widget.user,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEC407A),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Isi HPHT',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildActionButton(
                      Icons.pregnant_woman_rounded,
                      'Kehamilanku',
                      () {
                        RouteHelper.navigateToKehamilanku(context, widget.user);
                      },
                    ),
                    _buildActionButton(
                      Icons.medical_services_rounded,
                      'Riwayat\nPemeriksaan',
                      () {
                        RouteHelper.navigateToRiwayatPemeriksaan(
                          context,
                          widget.user,
                        );
                      },
                    ),
                    _buildActionButton(
                      Icons.calendar_today_rounded,
                      'Temu Janji',
                      () {
                        RouteHelper.navigateToTemuJanji(context, widget.user);
                      },
                    ),
                    _buildActionButton(Icons.emergency_rounded, 'Darurat', () {
                      RouteHelper.navigateToDarurat(context, widget.user);
                    }),
                    _buildActionButton(
                      Icons.chat_rounded,
                      'Chat dengan\nBidan',
                      () {
                        RouteHelper.navigateToChatPasien(context, widget.user);
                      },
                    ),
                    _buildActionButton(Icons.school_rounded, 'Edukasi', () {
                      RouteHelper.navigateToEdukasi(context, widget.user);
                    }),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleScreen() {
    return JadwalPasienScreen(user: widget.user);
  }

  Widget _buildProfileScreen() {
    return ProfileScreen(user: widget.user);
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFCDD2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFFEC407A), size: 20),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFFEC407A).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: const Color(0xFFEC407A), size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF2D3748),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFetalInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          Text(
            ': $value',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFetalInfoColumn(String label, String value) {
    return Column(
      children: [
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

  Widget _buildCalendar() {
    final now = DateTime.now();
    final today = now.weekday; // 1 = Monday, 7 = Sunday

    return Row(
      children: List.generate(7, (index) {
        final date = now.add(Duration(days: index));
        final dayName = _getDayName(date.weekday);
        final dayNumber = date.day.toString();
        final isToday = index == 0; // First day is today

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: index < 6 ? 8 : 0, // No margin for last item
            ),
            child: Column(
              children: [
                // Day name
                Text(
                  dayName,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isToday ? Colors.white : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 6),
                // Day number with larger block for today
                Container(
                  width: isToday ? 40 : 32,
                  height: isToday ? 40 : 32,
                  decoration: BoxDecoration(
                    color:
                        isToday ? const Color(0xFFEC407A) : Colors.transparent,
                    borderRadius: BorderRadius.circular(isToday ? 20 : 16),
                  ),
                  child: Center(
                    child: Text(
                      dayNumber,
                      style: GoogleFonts.poppins(
                        fontSize: isToday ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: isToday ? Colors.white : const Color(0xFF2D3748),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Sen';
      case 2:
        return 'Sel';
      case 3:
        return 'Rab';
      case 4:
        return 'Kam';
      case 5:
        return 'Jum';
      case 6:
        return 'Sab';
      case 7:
        return 'Min';
      default:
        return '';
    }
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.logout_rounded, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Logout',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              'Apakah Anda yakin ingin keluar dari aplikasi?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  RouteHelper.navigateToLogin(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Logout', style: GoogleFonts.poppins()),
              ),
            ],
          ),
    );
  }
}
