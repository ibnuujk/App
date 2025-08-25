import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/pdf_service.dart';

class PemeriksaanScreen extends StatefulWidget {
  final UserModel user;

  const PemeriksaanScreen({super.key, required this.user});

  @override
  State<PemeriksaanScreen> createState() => _PemeriksaanScreenState();
}

class _PemeriksaanScreenState extends State<PemeriksaanScreen>
    with TickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isDownloading = false;

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
      appBar: AppBar(
        title: Text(
          'Riwayat Pemeriksaan',
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
          child: SafeArea(
            child: Column(
              children: [
                // Header Info Card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.medical_services_rounded,
                          color: const Color(0xFFEC407A),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pemeriksaan Kehamilan',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                            Text(
                              'Riwayat pemeriksaan dan data kesehatan',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Download Button
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _firebaseService
                            .getPemeriksaanIbuHamilByPasienStream(
                              widget.user.id,
                            ),
                        builder: (context, snapshot) {
                          final pemeriksaanList = snapshot.data ?? [];
                          return _buildDownloadButton(pemeriksaanList);
                        },
                      ),
                    ],
                  ),
                ),

                // Pemeriksaan List
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _firebaseService
                        .getPemeriksaanIbuHamilByPasienStream(widget.user.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFEC407A),
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_rounded,
                                size: 60,
                                color: Colors.red[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Terjadi kesalahan',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tidak dapat memuat data pemeriksaan',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final pemeriksaanList = snapshot.data ?? [];

                      if (pemeriksaanList.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: pemeriksaanList.length,
                        itemBuilder: (context, index) {
                          final pemeriksaan = pemeriksaanList[index];
                          return _buildPemeriksaanCard(pemeriksaan, index);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.medical_services_outlined,
                size: 60,
                color: const Color(0xFFEC407A).withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Pemeriksaan',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Riwayat pemeriksaan kehamilan Anda akan muncul di sini setelah bidan melakukan pemeriksaan.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
                          'Informasi Pemeriksaan',
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
                    'Pemeriksaan kehamilan rutin sangat penting untuk memantau kesehatan ibu dan janin. Pastikan untuk melakukan jadwal kontrol sesuai anjuran bidan.',
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
    );
  }

  Widget _buildPemeriksaanCard(Map<String, dynamic> pemeriksaan, int index) {
    final tanggalPemeriksaan = DateTime.tryParse(
      pemeriksaan['tanggalPemeriksaan']?.toString() ?? '',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showPemeriksaanDetail(pemeriksaan),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan tanggal dan nomor pemeriksaan
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        color: const Color(0xFFEC407A),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pemeriksaan #${index + 1}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2D3748),
                            ),
                          ),
                          Text(
                            tanggalPemeriksaan != null
                                ? _formatDate(tanggalPemeriksaan)
                                : 'Tanggal tidak tersedia',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Data Vital Signs
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Data Fisik
                      Row(
                        children: [
                          Expanded(
                            child: _buildVitalInfo(
                              'Berat Badan',
                              '${pemeriksaan['beratBadan']?.toString() ?? '-'} kg',
                              Icons.monitor_weight_rounded,
                            ),
                          ),
                          Expanded(
                            child: _buildVitalInfo(
                              'Tinggi Badan',
                              '${pemeriksaan['tinggiBadan']?.toString() ?? '-'} cm',
                              Icons.straighten_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Tanda Vital
                      Row(
                        children: [
                          Expanded(
                            child: _buildVitalInfo(
                              'Tekanan Darah',
                              pemeriksaan['tekananDarah']?.toString() ?? '-',
                              Icons.favorite_rounded,
                            ),
                          ),
                          Expanded(
                            child: _buildVitalInfo(
                              'HB (Hemoglobin)',
                              '${pemeriksaan['hb']?.toString() ?? '-'} g/dL',
                              Icons.bloodtype_rounded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Keluhan (jika ada)
                if (pemeriksaan['keluhan'] != null &&
                    pemeriksaan['keluhan'].toString().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFFCC02).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_rounded,
                          color: const Color(0xFFFF8F00),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Keluhan: ${pemeriksaan['keluhan']}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF8C6A00),
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
        ),
      ),
    );
  }

  Widget _buildVitalInfo(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFEC407A).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFEC407A), size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPemeriksaanDetail(Map<String, dynamic> pemeriksaan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            expand: false,
            builder:
                (context, scrollController) =>
                    _buildDetailContent(pemeriksaan, scrollController),
          ),
    );
  }

  Widget _buildDetailContent(
    Map<String, dynamic> pemeriksaan,
    ScrollController scrollController,
  ) {
    final tanggalPemeriksaan = DateTime.tryParse(
      pemeriksaan['tanggalPemeriksaan']?.toString() ?? '',
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.medical_services_rounded,
                          color: const Color(0xFFEC407A),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Detail Pemeriksaan',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                            Text(
                              tanggalPemeriksaan != null
                                  ? _formatDate(tanggalPemeriksaan)
                                  : 'Tanggal tidak tersedia',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Data Lengkap
                  _buildDetailSection('Data Fisik', [
                    _buildDetailItem(
                      'Berat Badan',
                      '${pemeriksaan['beratBadan']?.toString() ?? '-'} kg',
                      Icons.monitor_weight_rounded,
                    ),
                    _buildDetailItem(
                      'Tinggi Badan',
                      '${pemeriksaan['tinggiBadan']?.toString() ?? '-'} cm',
                      Icons.height_rounded,
                    ),
                    _buildDetailItem(
                      'Lingkar Lengan',
                      '${pemeriksaan['lingkarLengan']?.toString() ?? '-'} cm',
                      Icons.straighten_rounded,
                    ),
                  ]),

                  const SizedBox(height: 20),

                  _buildDetailSection('Tanda Vital', [
                    _buildDetailItem(
                      'Tekanan Darah',
                      pemeriksaan['tekananDarah']?.toString() ?? '-',
                      Icons.favorite_rounded,
                    ),
                    _buildDetailItem(
                      'Denyut Nadi',
                      '${pemeriksaan['denyutNadi']?.toString() ?? '-'} bpm',
                      Icons.monitor_heart_rounded,
                    ),
                    _buildDetailItem(
                      'Tinggi Fundus',
                      '${pemeriksaan['tinggiFundus']?.toString() ?? '-'} cm',
                      Icons.pregnant_woman_rounded,
                    ),
                  ]),

                  const SizedBox(height: 20),

                  _buildDetailSection('Catatan', [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        pemeriksaan['catatan']?.toString() ??
                            'Tidak ada catatan',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF6A1B9A),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ]),

                  if (pemeriksaan['keluhan'] != null &&
                      pemeriksaan['keluhan'].toString().isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildDetailSection('Keluhan', [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFFFFCC02,
                            ).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          pemeriksaan['keluhan'].toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF8C6A00),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ]),
                  ],

                  if (pemeriksaan['diagnosis'] != null &&
                      pemeriksaan['diagnosis'].toString().isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildDetailSection('Diagnosis', [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFF2196F3,
                            ).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          pemeriksaan['diagnosis'].toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF1565C0),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ]),
                  ],

                  if (pemeriksaan['tindakan'] != null &&
                      pemeriksaan['tindakan'].toString().isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildDetailSection('Tindakan', [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFF4CAF50,
                            ).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          pemeriksaan['tindakan'].toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF2E7D32),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ]),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEC407A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFEC407A), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
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
    );
  }

  Widget _buildDownloadButton(List<Map<String, dynamic>> pemeriksaanList) {
    return GestureDetector(
      onTap:
          pemeriksaanList.isNotEmpty && !_isDownloading
              ? () => _handleDownload('summary', pemeriksaanList)
              : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              pemeriksaanList.isNotEmpty
                  ? const Color(0xFFEC407A)
                  : Colors.grey[400],
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            _isDownloading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
                : Icon(Icons.download_rounded, color: Colors.white, size: 20),
      ),
    );
  }

  Future<void> _handleDownload(
    String type,
    List<Map<String, dynamic>> pemeriksaanList,
  ) async {
    if (pemeriksaanList.isEmpty) {
      _showSnackBar('Belum ada data pemeriksaan untuk diunduh', isError: true);
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      // Show progress message
      _showSnackBar('Sedang memproses PDF...', isError: false);

      // Generate PDF summary report
      await PdfService.generatePemeriksaanReport(
        user: widget.user,
        pemeriksaanList: pemeriksaanList,
      );
      _showSnackBar('✅ Ringkasan pemeriksaan berhasil diunduh!');
    } catch (e) {
      print('Error downloading PDF: $e');

      // Show more helpful error messages
      String errorMessage = 'Gagal membuat PDF';
      if (e.toString().contains('permission')) {
        errorMessage =
            'Izin akses file diperlukan. Silakan coba lagi dan berikan izin.';
      } else if (e.toString().contains('space')) {
        errorMessage =
            'Ruang penyimpanan tidak cukup. Silakan kosongkan beberapa file.';
      } else if (e.toString().contains('network') ||
          e.toString().contains('internet')) {
        errorMessage =
            'Masalah koneksi internet. Silakan periksa koneksi Anda.';
      } else {
        errorMessage =
            'Terjadi kesalahan. Silakan coba lagi dalam beberapa saat.';
      }

      _showSnackBar(errorMessage, isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red[600] : const Color(0xFFEC407A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 4 : 3),
      ),
    );
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
}
