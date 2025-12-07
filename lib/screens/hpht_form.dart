import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../routes/route_helper.dart';
import '../utilities/pregnancy_calculator.dart';
import '../utilities/safe_navigation.dart';

class HPHTFormScreen extends StatefulWidget {
  final UserModel user;

  const HPHTFormScreen({super.key, required this.user});

  @override
  State<HPHTFormScreen> createState() => _HPHTFormScreenState();
}

class _HPHTFormScreenState extends State<HPHTFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();
  DateTime? _selectedHPHT;
  bool _isLoading = false;

  Future<void> _selectHPHT() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 30)),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now, // Maksimal hari ini, tidak bisa memilih hari esok
    );
    if (picked != null && picked != _selectedHPHT) {
      // Validasi tambahan: pastikan HPHT tidak melebihi hari ini
      if (picked.isAfter(now)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('HPHT tidak boleh melebihi hari ini'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedHPHT = picked;
      });
    }
  }

  Future<void> _submitHPHT() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedHPHT == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih tanggal HPHT'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if user had miscarriage and this is a new pregnancy
      if (widget.user.pregnancyStatus == 'miscarriage' &&
          widget.user.hpht != null) {
        // This is a new pregnancy after miscarriage
        await _firebaseService.addNewHPHTForNextPregnancy(
          widget.user.id,
          _selectedHPHT!,
        );

        // Get updated user data
        final updatedUser = widget.user.copyWith(
          hpht: _selectedHPHT,
          pregnancyStatus: 'active',
          pregnancyEndDate: null,
          pregnancyEndReason: null,
          pregnancyNotes: null,
        );

        // Show success message for new pregnancy
        if (mounted) {
          _showNewPregnancySuccessDialog(updatedUser);
        }
      } else {
        // This is the first pregnancy or normal HPHT update
        final updatedUser = widget.user.copyWith(hpht: _selectedHPHT);
        await _firebaseService.updateUser(updatedUser);

        // Automatically create child data from HPHT
        try {
          await _firebaseService.createChildFromHPHT(
            widget.user.id,
            _selectedHPHT!,
          );
          print('Child data created automatically from HPHT');
        } catch (e) {
          print('Error creating child data: $e');
          // Don't fail the whole process if child creation fails
        }

        // Show success message for first pregnancy
        if (mounted) {
          _showFirstPregnancySuccessDialog(updatedUser);
        }
      }
    } catch (e) {
      String errorMessage = 'Terjadi kesalahan saat menyimpan HPHT';

      if (e.toString().contains('permission-denied')) {
        errorMessage = 'Akses ditolak. Silakan coba lagi atau hubungi admin.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Koneksi internet bermasalah. Silakan coba lagi';
      } else if (e.toString().contains('Tidak dapat terhubung')) {
        errorMessage = e.toString();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Show success dialog for new pregnancy after miscarriage
  void _showNewPregnancySuccessDialog(UserModel updatedUser) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              Text(
                'Kehamilan Baru Berhasil Dibuat',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat! Kehamilan baru Anda telah berhasil dibuat dengan data:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'HPHT Baru',
                PregnancyCalculator.formatDate(_selectedHPHT!),
              ),
              _buildInfoRow('Status', 'Kehamilan Aktif'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_rounded, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Data kehamilan sebelumnya telah disimpan dalam riwayat dan data anak baru telah dibuat otomatis',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                RouteHelper.navigateToHomePasien(context, updatedUser);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF20B2AA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Lanjut ke Dashboard',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show success dialog for first pregnancy
  void _showFirstPregnancySuccessDialog(UserModel updatedUser) {
    // Calculate pregnancy information
    final gestationalAge = PregnancyCalculator.calculateGestationalAge(
      _selectedHPHT!,
    );
    final dueDate = PregnancyCalculator.calculateDueDate(_selectedHPHT!);
    final trimester = PregnancyCalculator.getTrimester(
      gestationalAge['weeks']!,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              Text(
                'HPHT Disimpan',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data HPHT Anda telah berhasil disimpan dan akan digunakan untuk:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'HPHT',
                PregnancyCalculator.formatDate(_selectedHPHT!),
              ),
              _buildInfoRow(
                'Usia Kehamilan',
                '${gestationalAge['weeks']} minggu ${gestationalAge['days']} hari',
              ),
              _buildInfoRow('Trimester', trimester),
              _buildInfoRow(
                'Perkiraan Lahir',
                PregnancyCalculator.formatDate(dueDate),
              ),
              _buildInfoRow(
                'Ukuran Janin',
                PregnancyCalculator.getFetalSizeComparison(
                  gestationalAge['weeks']!,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_rounded, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Data ini akan otomatis digunakan di fitur Kehamilanku dan informasi janin',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                RouteHelper.navigateToHomePasien(context, updatedUser);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF20B2AA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Lanjut ke Dashboard',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF2D3748),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'HPHT (Hari Pertama Haid Terakhir)',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF20B2AA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => NavigationHelper.safeNavigateBack(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Informasi Kehamilan',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masukkan tanggal HPHT untuk menghitung usia kehamilan',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Information Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Apa itu HPHT?',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'HPHT adalah Hari Pertama Haid Terakhir. Tanggal ini digunakan untuk menghitung usia kehamilan dan perkiraan tanggal lahir.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // HPHT Date Field
              GestureDetector(
                onTap: _selectHPHT,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedHPHT == null
                              ? 'Pilih Tanggal HPHT *'
                              : DateFormat('dd/MM/yyyy').format(_selectedHPHT!),
                          style: GoogleFonts.poppins(
                            color:
                                _selectedHPHT == null
                                    ? Colors.grey[600]
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Validation
              if (_selectedHPHT != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Kehamilan:',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Builder(
                        builder: (context) {
                          final gestationalAge =
                              PregnancyCalculator.calculateGestationalAge(
                                _selectedHPHT!,
                              );
                          final dueDate = PregnancyCalculator.calculateDueDate(
                            _selectedHPHT!,
                          );
                          final trimester = PregnancyCalculator.getTrimester(
                            gestationalAge['weeks']!,
                          );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• Usia Kehamilan: ${gestationalAge['weeks']} minggu ${gestationalAge['days']} hari',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              Text(
                                '• Trimester: $trimester',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              Text(
                                '• Perkiraan Lahir: ${PregnancyCalculator.formatDate(dueDate)}',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              Text(
                                '• Ukuran Janin: ${PregnancyCalculator.getFetalSizeComparison(gestationalAge['weeks']!)}',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitHPHT,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF20B2AA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Text(
                            'SIMPAN HPHT',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 20),

              // Skip Button
              Center(
                child: TextButton(
                  onPressed: () {
                    RouteHelper.navigateToHomePasien(context, widget.user);
                  },
                  child: Text(
                    'Lewati untuk sekarang',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
