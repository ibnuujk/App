import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/persalinan_model.dart';
import '../services/firebase_service.dart';
import 'registrasi_persalinan_form.dart';

class PemeriksaanIbuHamilScreen extends StatefulWidget {
  final UserModel user;
  final Map<String, dynamic>?
  consultationSchedule; // Data dari jadwal konsultasi

  const PemeriksaanIbuHamilScreen({
    super.key,
    required this.user,
    this.consultationSchedule,
  });

  @override
  State<PemeriksaanIbuHamilScreen> createState() =>
      _PemeriksaanIbuHamilScreenState();
}

class _PemeriksaanIbuHamilScreenState extends State<PemeriksaanIbuHamilScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _pregnancyExaminations = [];
  List<PersalinanModel> _persalinanData = [];
  bool _isLoading = true;

  StreamSubscription<List<Map<String, dynamic>>>? _examinationsSubscription;
  StreamSubscription<List<PersalinanModel>>? _persalinanSubscription;

  @override
  void initState() {
    super.initState();
    _loadPregnancyExaminations();
    _loadPersalinanData();

    // Auto show form if there's consultation schedule data
    if (widget.consultationSchedule != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFormFromConsultation();
      });
    }
  }

  Future<void> _loadPregnancyExaminations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cancel existing subscription
      _examinationsSubscription?.cancel();

      // Create new subscription
      _examinationsSubscription = _firebaseService
          .getPemeriksaanIbuHamilStream()
          .listen(
            (examinations) {
              if (mounted) {
                setState(() {
                  _pregnancyExaminations = examinations;
                  _isLoading = false;
                });
                print(
                  'Loaded ${examinations.length} examinations',
                ); // Debug log
              }
            },
            onError: (e) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
                print('Error loading examinations: $e'); // Debug log
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Gagal memuat data pemeriksaan: ${e.toString()}',
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('Exception loading examinations: $e'); // Debug log
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data pemeriksaan: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadPersalinanData() async {
    try {
      // Cancel existing subscription
      _persalinanSubscription?.cancel();

      // Create new subscription
      _persalinanSubscription = _firebaseService.getPersalinanStream().listen(
        (persalinan) {
          if (mounted) {
            setState(() {
              _persalinanData = persalinan;
            });
            print('Loaded ${persalinan.length} persalinan data'); // Debug log
          }
        },
        onError: (e) {
          if (mounted) {
            print('Error loading persalinan data: $e'); // Debug log
          }
        },
      );
    } catch (e) {
      if (mounted) {
        print('Exception loading persalinan data: $e'); // Debug log
      }
    }
  }

  // Check if patient has completed delivery registration
  bool _hasCompletedDelivery(String patientId) {
    return _persalinanData.any(
      (persalinan) => persalinan.pasienId == patientId,
    );
  }

  @override
  void dispose() {
    _examinationsSubscription?.cancel();
    _persalinanSubscription?.cancel();
    super.dispose();
  }

  void _showAddExaminationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AddPregnancyExaminationDialog(
            consultationSchedule: widget.consultationSchedule,
          ),
    ).then((_) {
      // Reload data after dialog closes
      _loadPregnancyExaminations();
    });
  }

  void _showFormFromConsultation() {
    if (widget.consultationSchedule != null) {
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent closing by tapping outside
        builder:
            (context) => AddPregnancyExaminationDialog(
              consultationSchedule: widget.consultationSchedule,
            ),
      ).then((_) {
        // Reload data after dialog closes
        _loadPregnancyExaminations();
      });
    }
  }

  void _showDetailDialog(Map<String, dynamic> examination) {
    showDialog(
      context: context,
      builder:
          (context) =>
              PregnancyExaminationDetailDialog(examination: examination),
    );
  }

  void _navigateToRegistrasiPersalinan(Map<String, dynamic> examination) {
    showDialog(
      context: context,
      builder:
          (context) =>
              RegistrasiPersalinanFormDialog(examinationData: examination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEC407A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFEC407A),
                      const Color(0xFFEC407A).withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEC407A).withValues(alpha: 0.3),
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
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.medical_services_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kelola Pemeriksaan Ibu Hamil',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Input dan kelola data pemeriksaan kehamilan',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Status Summary
                    Row(
                      children: [
                        _buildStatusCard(
                          'Total',
                          _pregnancyExaminations.length,
                          Colors.white,
                        ),
                        const SizedBox(width: 12),
                        _buildStatusCard(
                          'Hari Ini',
                          _getTodayCount(),
                          Colors.white,
                        ),
                        const SizedBox(width: 12),
                        _buildStatusCard(
                          'Minggu Ini',
                          _getThisWeekCount(),
                          Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Examinations List
              Expanded(
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFEC407A),
                          ),
                        )
                        : _pregnancyExaminations.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFEC407A,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                child: Icon(
                                  Icons.pregnant_woman_outlined,
                                  size: 60,
                                  color: const Color(0xFFEC407A),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Belum ada data pemeriksaan',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tambahkan pemeriksaan pertama Anda',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _pregnancyExaminations.length,
                          itemBuilder: (context, index) {
                            final examination = _pregnancyExaminations[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Patient Information Container
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFEC407A),
                                            Color(0xFFE91E63),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  Icons.pregnant_woman_rounded,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      examination['namaPasien'] ??
                                                          'Nama tidak tersedia',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 18,
                                                            color: Colors.white,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Pasien Ibu Hamil',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            color: Colors.white
                                                                .withValues(
                                                                  alpha: 0.8,
                                                                ),
                                                          ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    // Show examination status
                                                    if (_hasCompletedDelivery(
                                                      examination['pasienId'],
                                                    ))
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.green
                                                              .withValues(
                                                                alpha: 0.2,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          border: Border.all(
                                                            color: Colors.green
                                                                .withValues(
                                                                  alpha: 0.4,
                                                                ),
                                                            width: 1,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .check_circle,
                                                              color:
                                                                  Colors.green,
                                                              size: 12,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              'Pemeriksaan Selesai',
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    Colors
                                                                        .green,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          // Patient Details Grid
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildPatientDetailItem(
                                                  Icons.phone_rounded,
                                                  'No HP',
                                                  examination['noHp'] ?? '-',
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: _buildPatientDetailItem(
                                                  Icons.cake_rounded,
                                                  'Umur',
                                                  '${examination['umur'] ?? '-'} tahun',
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          _buildPatientDetailItem(
                                            Icons.location_on_rounded,
                                            'Alamat',
                                            examination['alamat'] ?? '-',
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Examination Overview Container
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey[200]!,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.medical_services_rounded,
                                                color: const Color(0xFFEC407A),
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Data Pemeriksaan',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: const Color(
                                                    0xFF2D3748,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildOverviewRow(
                                                  'Usia Kehamilan',
                                                  '${examination['usiaKehamilan'] ?? '-'} minggu',
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: _buildOverviewRow(
                                                  'HPHT',
                                                  examination['hpht'] ?? '-',
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildOverviewRow(
                                                  'Tekanan Darah',
                                                  examination['tekananDarah'] ??
                                                      '-',
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: _buildOverviewRow(
                                                  'Berat Badan',
                                                  '${examination['beratBadan'] ?? '-'} kg',
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildOverviewRow(
                                                  'Tinggi Badan',
                                                  '${examination['tinggiBadan'] ?? '-'} cm',
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: _buildOverviewRow(
                                                  'Tanggal Masuk',
                                                  examination['tanggalMasuk'] ??
                                                      '-',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Action Buttons
                                    Row(
                                      children: [
                                        // Check if delivery registration is already completed
                                        if (examination['pregnancyStatus'] !=
                                            'miscarriage') ...[
                                          if (_hasCompletedDelivery(
                                            examination['pasienId'],
                                          ))
                                            // Show "Registrasi Berhasil" status if delivery is completed
                                            Expanded(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 16,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.green
                                                        .withValues(alpha: 0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green,
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Registrasi Berhasil',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.green,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          else
                                            // Show "Lakukan Registrasi Persalinan" button if not completed
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed:
                                                    () =>
                                                        _navigateToRegistrasiPersalinan(
                                                          examination,
                                                        ),
                                                icon: Icon(
                                                  Icons.assignment_add,
                                                  size: 18,
                                                  color: Colors.white,
                                                ),
                                                label: Text(
                                                  'Lakukan Registrasi Persalinan',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                    0xFFEC407A,
                                                  ),
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 16,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          const SizedBox(width: 12),
                                        ],
                                        PopupMenuButton<String>(
                                          icon: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFFEC407A,
                                              ).withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.more_vert_rounded,
                                              color: const Color(0xFFEC407A),
                                              size: 20,
                                            ),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          onSelected: (value) {
                                            if (value == 'detail') {
                                              _showDetailDialog(examination);
                                            } else if (value == 'edit') {
                                              if (_hasCompletedDelivery(
                                                examination['pasienId'],
                                              )) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Pemeriksaan sudah selesai, tidak dapat diedit',
                                                      style:
                                                          GoogleFonts.poppins(),
                                                    ),
                                                    backgroundColor:
                                                        Colors.orange,
                                                    duration: const Duration(
                                                      seconds: 2,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                _showEditDialog(examination);
                                              }
                                            } else if (value == 'delete') {
                                              if (_hasCompletedDelivery(
                                                examination['pasienId'],
                                              )) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Pemeriksaan sudah selesai, tidak dapat dihapus',
                                                      style:
                                                          GoogleFonts.poppins(),
                                                    ),
                                                    backgroundColor:
                                                        Colors.orange,
                                                    duration: const Duration(
                                                      seconds: 2,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                _deleteExamination(
                                                  examination['id'],
                                                );
                                              }
                                            }
                                          },
                                          itemBuilder:
                                              (context) => [
                                                PopupMenuItem(
                                                  value: 'detail',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .visibility_rounded,
                                                        color: const Color(
                                                          0xFFEC407A,
                                                        ),
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        'Detail',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              color:
                                                                  const Color(
                                                                    0xFFEC407A,
                                                                  ),
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (_hasCompletedDelivery(
                                                  examination['pasienId'],
                                                ))
                                                  PopupMenuItem(
                                                    value: 'edit',
                                                    enabled: false,
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.check_circle,
                                                          color: Colors.grey,
                                                          size: 20,
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        Text(
                                                          'Pemeriksaan Selesai',
                                                          style:
                                                              GoogleFonts.poppins(
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                else
                                                  PopupMenuItem(
                                                    value: 'edit',
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.edit_rounded,
                                                          color: Colors.orange,
                                                          size: 20,
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        Text(
                                                          'Edit',
                                                          style:
                                                              GoogleFonts.poppins(
                                                                color:
                                                                    Colors
                                                                        .orange,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                if (_hasCompletedDelivery(
                                                  examination['pasienId'],
                                                ))
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    enabled: false,
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.block,
                                                          color: Colors.grey,
                                                          size: 20,
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        Text(
                                                          'Tidak Dapat Dihapus',
                                                          style:
                                                              GoogleFonts.poppins(
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                else
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.delete_rounded,
                                                          color: Colors.red,
                                                          size: 20,
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        Text(
                                                          'Hapus',
                                                          style:
                                                              GoogleFonts.poppins(
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Examination Date
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFEC407A,
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(
                                            0xFFEC407A,
                                          ).withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.calendar_today_rounded,
                                            color: const Color(0xFFEC407A),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatExaminationDate(
                                              examination['tanggalPemeriksaan'],
                                            ),
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: const Color(0xFFEC407A),
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
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEC407A).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showAddExaminationDialog,
          backgroundColor: const Color(0xFFEC407A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> examination) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditExaminationDialog(
          examination: examination,
          firebaseService: _firebaseService,
          onSaved: () {
            _loadPregnancyExaminations(); // Refresh the list
          },
        );
      },
    );
  }

  Future<void> _deleteExamination(String examinationId) async {
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Hapus Pemeriksaan',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus pemeriksaan ini?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Hapus', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _firebaseService.deletePemeriksaanIbuHamil(examinationId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pemeriksaan berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus pemeriksaan: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildOverviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4A5568),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: const Color(0xFF2D3748),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientDetailItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.8)),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Status count methods
  int _getTodayCount() {
    final today = DateTime.now();
    return _pregnancyExaminations.where((examination) {
      final examinationDate = examination['tanggalPemeriksaan'];
      DateTime? date;

      if (examinationDate is Timestamp) {
        date = examinationDate.toDate();
      } else if (examinationDate is String) {
        try {
          date = DateTime.parse(examinationDate);
        } catch (e) {
          return false;
        }
      } else if (examinationDate is DateTime) {
        date = examinationDate;
      } else {
        return false;
      }

      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).length;
  }

  int _getThisWeekCount() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return _pregnancyExaminations.where((examination) {
      final examinationDate = examination['tanggalPemeriksaan'];
      DateTime? date;

      if (examinationDate is Timestamp) {
        date = examinationDate.toDate();
      } else if (examinationDate is String) {
        try {
          date = DateTime.parse(examinationDate);
        } catch (e) {
          return false;
        }
      } else if (examinationDate is DateTime) {
        date = examinationDate;
      } else {
        return false;
      }

      return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          date.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).length;
  }

  // Helper method to format examination date safely
  String _formatExaminationDate(
    dynamic dateValue, [
    String format = 'dd MMM yyyy',
  ]) {
    try {
      DateTime date;

      if (dateValue is Timestamp) {
        date = dateValue.toDate();
      } else if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return '-';
      }

      return DateFormat(format).format(date);
    } catch (e) {
      print('Error formatting date: $e');
      return 'Format tanggal tidak valid';
    }
  }

  // Status card widget
  Widget _buildStatusCard(String title, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddPregnancyExaminationDialog extends StatefulWidget {
  final Map<String, dynamic>? consultationSchedule;

  const AddPregnancyExaminationDialog({super.key, this.consultationSchedule});

  @override
  State<AddPregnancyExaminationDialog> createState() =>
      _AddPregnancyExaminationDialogState();
}

class _AddPregnancyExaminationDialogState
    extends State<AddPregnancyExaminationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();

  // Patient data from consultation schedule
  String? _pasienId;
  String? _namaPasien;
  String? _noHp;
  String? _umur;
  String? _alamat;
  DateTime? _hpht;
  int _usiaKehamilan = 0;

  // Form controllers
  final _namaController = TextEditingController();
  final _noHpController = TextEditingController();
  final _umurController = TextEditingController();
  final _alamatController = TextEditingController();
  final _agamaController = TextEditingController();
  final _pekerjaanController = TextEditingController();

  // Examination data
  final _usiaKehamilanController = TextEditingController();
  final _hphtController = TextEditingController();

  // Anamnesis
  final _tanggalMasukController = TextEditingController();

  String _jenisKunjungan = 'UMUM';

  // Tanda Vital
  final _tekananDarahController = TextEditingController();
  final _suhuBadanController = TextEditingController();
  final _nadiController = TextEditingController();
  final _beratBadanController = TextEditingController();
  final _pernafasanController = TextEditingController();
  final _tinggiBadanController = TextEditingController();

  // Penanggung Jawab
  final _namaPenanggungController = TextEditingController();
  final _umurPenanggungController = TextEditingController();
  final _alamatPenanggungController = TextEditingController();
  final _agamaPenanggungController = TextEditingController();
  final _pekerjaanPenanggungController = TextEditingController();

  // Kondisi Umum
  String _kesadaran = 'NORMAL';
  String _kepala = 'NORMAL';
  String _mata = 'NORMAL';
  String _leher = 'NORMAL';
  String _tangan = 'NORMAL';
  String _dada = 'NORMAL';
  String _hidung = 'NORMAL';
  String _kulit = 'NORMAL';
  String _mulut = 'NORMAL';
  String _kaki = 'NORMAL';
  String _pemeriksaanAntenatal = 'ya';
  final _jumlahAntenatalController = TextEditingController();
  final _riwayatHaidController = TextEditingController();
  final _perkawinanController = TextEditingController();
  final _alasanDirawatController = TextEditingController();
  final _riwayatKehamilanDuluController = TextEditingController();
  final _kehamilanSekarangController = TextEditingController();

  // Status Obstetric
  String _posisiJanin = 'puki';
  final _tfuController = TextEditingController();
  final _hisController = TextEditingController();
  String _djjIrama = 'teratur';
  String _letakJanin = 'memanjang';
  String _presentasiJanin = 'kepala';
  String _sikapJanin = 'fleksi';
  final _hbController = TextEditingController();
  final _pemeriksaanDalamController = TextEditingController();

  // Diagnosis Kebidanan
  final _catatanController = TextEditingController();

  // Pregnancy Status
  String _pregnancyStatus = 'active';
  String? _pregnancyEndReason;
  final _pregnancyEndDateController = TextEditingController();
  final _pregnancyNotesController = TextEditingController();

  // Screening questions
  Map<String, bool> _screeningQuestions = {
    'riwayat_bedah_sesar': false,
    'pendarahan_pervaginaan': false,
    'persalinan_kurang_bulan': false,
    'ketuban_pecah_mekonium': false,
    'ketuban_pecah_kurang_bulan': false,
    'ketuban_pecah_lama': false,
    'anemia_berat': false,
    'tanda_infeksi': false,
    'ikterius': false,
    'pre_eklampsia': false,
    'tinggi_fundus_40': false,
    'gawat_janin': false,
    'primpara_fase_aktif': false,
    'presentasi_bukan_belakang_kepala': false,
    'presentasi_ganda': false,
    'kehamilan_ganda': false,
    'tali_pusat_menumbung': false,
    'shock': false,
  };

  bool _isLoading = false;
  bool _isLoadingPatientData = false;

  @override
  void initState() {
    super.initState();
    _tanggalMasukController.text = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(DateTime.now());

    // Extract patient data from consultation schedule and load complete patient data
    if (widget.consultationSchedule != null) {
      _pasienId = widget.consultationSchedule!['pasienId'];
      _namaPasien = widget.consultationSchedule!['namaPasien'];
      _noHp = widget.consultationSchedule!['noHp'];
      _umur = widget.consultationSchedule!['umur']?.toString();
      _alamat = widget.consultationSchedule!['alamat'];

      // Auto-fill form with consultation data
      _namaController.text = _namaPasien ?? '';
      _noHpController.text = _noHp ?? '';
      _umurController.text = _umur ?? '';
      _alamatController.text = _alamat ?? '';
      _alasanDirawatController.text =
          widget.consultationSchedule!['keluhan'] ?? '';

      // Load complete patient data including HPHT and other patient info
      _loadPatientData();
    }
  }

  Future<void> _loadPatientData() async {
    try {
      setState(() {
        _isLoadingPatientData = true;
      });

      if (_pasienId != null) {
        final userDoc = await _firebaseService.getUserById(_pasienId!);
        if (userDoc != null) {
          setState(() {
            // Update patient data with complete user data
            _namaPasien = userDoc.nama;
            _noHp = userDoc.noHp;
            _umur = userDoc.umur.toString();
            _alamat = userDoc.alamat;

            // Update form controllers with complete patient data
            _namaController.text = _namaPasien ?? '';
            _noHpController.text = _noHp ?? '';
            _umurController.text = _umur ?? '';
            _alamatController.text = _alamat ?? '';
            _agamaController.text = userDoc.agamaPasien ?? '';
            _pekerjaanController.text = userDoc.pekerjaanPasien ?? '';

            // Load HPHT and calculate pregnancy age
            _hpht = userDoc.hpht;
            if (_hpht != null) {
              _usiaKehamilan = _calculatePregnancyAge(_hpht!);
              _hphtController.text = DateFormat('dd/MM/yyyy').format(_hpht!);
              _usiaKehamilanController.text = _usiaKehamilan.toString();
            }
          });
        }
      }
    } catch (e) {
      print('Error loading patient data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data pasien: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isLoadingPatientData = false;
      });
    }
  }

  int _calculatePregnancyAge(DateTime hpht) {
    final now = DateTime.now();
    final difference = now.difference(hpht);
    final weeks = (difference.inDays / 7).floor();
    return weeks;
  }

  Widget _buildScreeningQuestion(String question, String key) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              question,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF2D3748),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: _screeningQuestions[key] ?? false,
            onChanged: (value) {
              setState(() {
                _screeningQuestions[key] = value;
              });
            },
            activeColor: const Color(0xFFEC407A),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noHpController.dispose();
    _umurController.dispose();
    _alamatController.dispose();
    _usiaKehamilanController.dispose();
    _hphtController.dispose();
    _tanggalMasukController.dispose();
    _agamaController.dispose();
    _pekerjaanController.dispose();
    _tekananDarahController.dispose();
    _suhuBadanController.dispose();
    _nadiController.dispose();
    _beratBadanController.dispose();
    _pernafasanController.dispose();
    _tinggiBadanController.dispose();
    _namaPenanggungController.dispose();
    _umurPenanggungController.dispose();
    _alamatPenanggungController.dispose();
    _agamaPenanggungController.dispose();
    _pekerjaanPenanggungController.dispose();
    _jumlahAntenatalController.dispose();
    _riwayatHaidController.dispose();
    _perkawinanController.dispose();
    _alasanDirawatController.dispose();
    _riwayatKehamilanDuluController.dispose();
    _kehamilanSekarangController.dispose();
    _tfuController.dispose();
    _hisController.dispose();
    _hbController.dispose();
    _pemeriksaanDalamController.dispose();
    _catatanController.dispose();
    _pregnancyEndDateController.dispose();
    _pregnancyNotesController.dispose();
    super.dispose();
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEC407A), Color(0xFFE91E63)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionDropdown(
    String label,
    String value,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(
          Icons.health_and_safety_rounded,
          color: const Color(0xFFEC407A),
        ),
      ),
      items:
          ['NORMAL', 'ADA KELAINAN'].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _saveExamination() async {
    if (!_formKey.currentState!.validate() || _pasienId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua data'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final examinationData = {
        'tanggalMasuk': _tanggalMasukController.text,
        'id': _firebaseService.generateId(),
        'pasienId': _pasienId,
        'namaPasien': _namaPasien,
        'noHp': _noHp,
        'umur': int.tryParse(_umur ?? '0') ?? 0,
        'alamat': _alamat,
        'usiaKehamilan': _usiaKehamilan,
        'hpht': _hpht != null ? DateFormat('dd/MM/yyyy').format(_hpht!) : '',
        'agama': _agamaController.text,
        'pekerjaan': _pekerjaanController.text,
        'jenisKunjungan': _jenisKunjungan,

        // Anamnesis

        // 'tanggalKeluar' field removed as per requirements

        // Tanda Vital
        'tekananDarah': _tekananDarahController.text,
        'suhuBadan': _suhuBadanController.text,
        'nadi': _nadiController.text,
        'beratBadan': double.tryParse(_beratBadanController.text) ?? 0.0,
        'pernafasan': _pernafasanController.text,
        'tinggiBadan': double.tryParse(_tinggiBadanController.text) ?? 0.0,

        // Penanggung Jawab
        'namaPenanggung': _namaPenanggungController.text,
        'umurPenanggung': _umurPenanggungController.text,
        'alamatPenanggung': _alamatPenanggungController.text,
        'agamaPenanggung': _agamaPenanggungController.text,
        'pekerjaanPenanggung': _pekerjaanPenanggungController.text,

        // Kondisi Umum
        'kesadaran': _kesadaran,
        'kepala': _kepala,
        'mata': _mata,
        'leher': _leher,
        'tangan': _tangan,
        'dada': _dada,
        'hidung': _hidung,
        'kulit': _kulit,
        'mulut': _mulut,
        'kaki': _kaki,
        'pemeriksaanAntenatal': _pemeriksaanAntenatal,
        'jumlahAntenatal': _jumlahAntenatalController.text,
        'riwayatHaid': _riwayatHaidController.text,
        'perkawinan': _perkawinanController.text,
        'alasanDirawat': _alasanDirawatController.text,
        'riwayatKehamilanDulu': _riwayatKehamilanDuluController.text,
        'kehamilanSekarang': _kehamilanSekarangController.text,

        // Status Obstetric
        'posisiJanin': _posisiJanin,
        'tfu': _tfuController.text,
        'his': _hisController.text,
        'djjIrama': _djjIrama,
        'letakJanin': _letakJanin,
        'presentasiJanin': _presentasiJanin,
        'sikapJanin': _sikapJanin,
        'hb': _hbController.text,
        'pemeriksaanDalam': _pemeriksaanDalamController.text,

        // Diagnosis Kebidanan
        'catatan': _catatanController.text,

        // Pregnancy Status
        'pregnancyStatus': _pregnancyStatus,
        'pregnancyEndReason': _pregnancyEndReason,
        'pregnancyEndDate':
            _pregnancyEndDateController.text.isNotEmpty
                ? DateFormat(
                  'dd/MM/yyyy',
                ).parse(_pregnancyEndDateController.text)
                : null,
        'pregnancyNotes': _pregnancyNotesController.text,

        'screeningQuestions': _screeningQuestions,
        'tanggalPemeriksaan': DateTime.now(), // Required for Firebase orderBy
        'createdAt': DateTime.now(),
      };

      // Save examination data
      await _firebaseService.createPemeriksaanIbuHamil(examinationData);

      // Mark consultation schedule as completed if it exists
      if (widget.consultationSchedule != null) {
        try {
          await _firebaseService.markConsultationScheduleAsCompleted(
            widget.consultationSchedule!['id'],
          );
        } catch (e) {
          print(
            'Warning: Could not mark consultation schedule as completed: $e',
          );
          // Don't fail the examination save if this fails
        }
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data pemeriksaan berhasil disimpan'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }

      // Close dialog and return to previous screen
      Navigator.of(context).pop();
    } catch (e) {
      print('Error saving examination: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.pregnant_woman_rounded,
                    color: const Color(0xFFEC407A),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Tambah Pemeriksaan',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Patient Info (Read-only from consultation)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFEC407A,
                          ).withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFFEC407A,
                            ).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ANAMNESIS Section Header
                            _buildSectionHeader(
                              'ANAMNESIS',
                              Icons.medical_services_rounded,
                            ),
                            const SizedBox(height: 16),

                            // Tanggal Masuk
                            TextFormField(
                              controller: _tanggalMasukController,
                              decoration: InputDecoration(
                                labelText: 'Tanggal Masuk/Jam *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(
                                  Icons.access_time_rounded,
                                  color: const Color(0xFFEC407A),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Masukkan tanggal masuk';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Data Pasien Section Header
                            Row(
                              children: [
                                Icon(
                                  Icons.person_rounded,
                                  color: const Color(0xFFEC407A),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Data Pasien',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2D3748),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _namaController,
                              decoration: InputDecoration(
                                labelText: 'Nama Pasien',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabled: false,
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _noHpController,
                              decoration: InputDecoration(
                                labelText: 'No HP',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabled: false,
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _umurController,
                              decoration: InputDecoration(
                                labelText: 'Umur',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabled: false,
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _alamatController,
                              decoration: InputDecoration(
                                labelText: 'Alamat',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabled: false,
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _agamaController,
                              enabled:
                                  false, // Disable editing since it's from patient data
                              decoration: InputDecoration(
                                labelText: 'Agama',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),

                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _pekerjaanController,
                              enabled:
                                  false, // Disable editing since it's from patient data
                              decoration: InputDecoration(
                                labelText: 'Pekerjaan',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Usia Kehamilan dan HPHT (Auto-filled from patient data)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFEC407A,
                          ).withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFFEC407A,
                            ).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.pregnant_woman_rounded,
                                  color: const Color(0xFFEC407A),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Data Kehamilan',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2D3748),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _isLoadingPatientData
                                ? Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: const Color(0xFFEC407A),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Memuat data kehamilan...',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: const Color(0xFF4A5568),
                                      ),
                                    ),
                                  ],
                                )
                                : Column(
                                  children: [
                                    TextFormField(
                                      controller: _hphtController,
                                      decoration: InputDecoration(
                                        labelText: 'HPHT',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        enabled: false,
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                        prefixIcon: Icon(
                                          Icons.calendar_today_rounded,
                                          color: const Color(0xFFEC407A),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _usiaKehamilanController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Usia Kehamilan (minggu)',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        enabled: false,
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                        prefixIcon: Icon(
                                          Icons.pregnant_woman_rounded,
                                          color: const Color(0xFFEC407A),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<String>(
                                      value: _jenisKunjungan,
                                      decoration: InputDecoration(
                                        labelText: 'Jenis Kunjungan *',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        prefixIcon: Icon(
                                          Icons.category_rounded,
                                          color: const Color(0xFFEC407A),
                                        ),
                                      ),
                                      items:
                                          ['UMUM', 'PBI', 'NON PBI'].map((
                                            String value,
                                          ) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _jenisKunjungan = newValue!;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Pilih jenis kunjungan';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // TANDA VITAL Section
                      _buildSectionHeader(
                        'TANDA VITAL',
                        Icons.favorite_rounded,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tekananDarahController,
                              decoration: InputDecoration(
                                labelText: 'Tekanan Darah (mmHg) *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(
                                  Icons.favorite_rounded,
                                  color: const Color(0xFFEC407A),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Masukkan tekanan darah';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _suhuBadanController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Suhu Badan (°C) *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(
                                  Icons.thermostat_rounded,
                                  color: const Color(0xFFEC407A),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Masukkan suhu badan';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nadiController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Nadi (d/mnt) *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(
                                  Icons.timeline_rounded,
                                  color: const Color(0xFFEC407A),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Masukkan nadi';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _beratBadanController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Berat Badan (kg) *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(
                                  Icons.monitor_weight_rounded,
                                  color: const Color(0xFFEC407A),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Masukkan berat badan';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _pernafasanController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Pernafasan (/mnt) *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(
                                  Icons.air_rounded,
                                  color: const Color(0xFFEC407A),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Masukkan pernafasan';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _tinggiBadanController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Tinggi Badan (cm) *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(
                                  Icons.height_rounded,
                                  color: const Color(0xFFEC407A),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Masukkan tinggi badan';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // PENANGGUNG JAWAB Section
                      _buildSectionHeader(
                        'PENANGGUNG JAWAB',
                        Icons.person_add_rounded,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _namaPenanggungController,
                        decoration: InputDecoration(
                          labelText: 'Nama *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.person_rounded,
                            color: const Color(0xFFEC407A),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan nama penanggung jawab';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _umurPenanggungController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Umur *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(
                                  Icons.cake_rounded,
                                  color: const Color(0xFFEC407A),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Masukkan umur';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _agamaPenanggungController,
                              decoration: InputDecoration(
                                labelText: 'Agama *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(
                                  Icons.church_rounded,
                                  color: const Color(0xFFEC407A),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Masukkan agama';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _alamatPenanggungController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Alamat *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.location_on_rounded,
                            color: const Color(0xFFEC407A),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan alamat';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _pekerjaanPenanggungController,
                        decoration: InputDecoration(
                          labelText: 'Pekerjaan *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.work_rounded,
                            color: const Color(0xFFEC407A),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan pekerjaan';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // KONDISI UMUM Section
                      _buildSectionHeader(
                        'KONDISI UMUM',
                        Icons.health_and_safety_rounded,
                      ),
                      const SizedBox(height: 16),

                      _buildConditionDropdown('Kesadaran', _kesadaran, (value) {
                        setState(() => _kesadaran = value!);
                      }),
                      const SizedBox(height: 12),

                      _buildConditionDropdown('Kepala', _kepala, (value) {
                        setState(() => _kepala = value!);
                      }),
                      const SizedBox(height: 12),

                      _buildConditionDropdown('Mata', _mata, (value) {
                        setState(() => _mata = value!);
                      }),
                      const SizedBox(height: 12),

                      _buildConditionDropdown('Leher', _leher, (value) {
                        setState(() => _leher = value!);
                      }),
                      const SizedBox(height: 12),

                      _buildConditionDropdown('Tangan', _tangan, (value) {
                        setState(() => _tangan = value!);
                      }),
                      const SizedBox(height: 12),

                      _buildConditionDropdown('Dada', _dada, (value) {
                        setState(() => _dada = value!);
                      }),
                      const SizedBox(height: 12),

                      _buildConditionDropdown('Hidung', _hidung, (value) {
                        setState(() => _hidung = value!);
                      }),
                      const SizedBox(height: 12),

                      _buildConditionDropdown('Kulit', _kulit, (value) {
                        setState(() => _kulit = value!);
                      }),
                      const SizedBox(height: 12),

                      _buildConditionDropdown('Mulut', _mulut, (value) {
                        setState(() => _mulut = value!);
                      }),
                      const SizedBox(height: 12),

                      _buildConditionDropdown('Kaki', _kaki, (value) {
                        setState(() => _kaki = value!);
                      }),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _pemeriksaanAntenatal,
                              decoration: InputDecoration(
                                labelText: 'Pemeriksaan Antenatal',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(
                                  Icons.pregnant_woman_rounded,
                                  color: const Color(0xFFEC407A),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items:
                                  ['ya', 'tidak'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value.toUpperCase()),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _pemeriksaanAntenatal = newValue!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _jumlahAntenatalController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Kali',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _riwayatHaidController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Riwayat Haid/Siklus (hari)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.calendar_month_rounded,
                            color: const Color(0xFFEC407A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _perkawinanController,
                        decoration: InputDecoration(
                          labelText: 'Perkawinan',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.favorite_rounded,
                            color: const Color(0xFFEC407A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _alasanDirawatController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Alasan Dirawat *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.medical_services_rounded,
                            color: const Color(0xFFEC407A),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan alasan dirawat';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _riwayatKehamilanDuluController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Riwayat Kehamilan Dulu',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.history_rounded,
                            color: const Color(0xFFEC407A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _kehamilanSekarangController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Kehamilan Sekarang',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.pregnant_woman_rounded,
                            color: const Color(0xFFEC407A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // STATUS OBSTETRIK Section
                      _buildSectionHeader(
                        'STATUS OBSTETRIK',
                        Icons.baby_changing_station_rounded,
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Pemeriksaan Luar',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _posisiJanin,
                              decoration: InputDecoration(
                                labelText: 'Posisi Janin',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(
                                  Icons.baby_changing_station_rounded,
                                  color: const Color(0xFFEC407A),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items:
                                  ['puki', 'puka'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value.toUpperCase(),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _posisiJanin = newValue!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _tfuController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'TFU (cm)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(
                                  Icons.straighten_rounded,
                                  color: const Color(0xFFEC407A),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _hisController,
                              decoration: InputDecoration(
                                labelText: 'His',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(
                                  Icons.waves_rounded,
                                  color: const Color(0xFFEC407A),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _djjIrama,
                              decoration: InputDecoration(
                                labelText: 'DJJ/Irama',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(
                                  Icons.favorite_rounded,
                                  color: const Color(0xFFEC407A),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items:
                                  ['teratur', 'tidak'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value.toUpperCase()),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _djjIrama = newValue!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _letakJanin,
                              decoration: InputDecoration(
                                labelText: 'Letak Janin',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(
                                  Icons.baby_changing_station_rounded,
                                  color: const Color(0xFFEC407A),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items:
                                  ['memanjang', 'melintang'].map((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value.toUpperCase(),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _letakJanin = newValue!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _presentasiJanin,
                              decoration: InputDecoration(
                                labelText: 'Presentasi Janin',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(
                                  Icons.baby_changing_station_rounded,
                                  color: const Color(0xFFEC407A),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items:
                                  ['kepala', 'bokong', 'bahu', 'kaki'].map((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value.toUpperCase(),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _presentasiJanin = newValue!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _sikapJanin,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Sikap Janin',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(
                                Icons.baby_changing_station_rounded,
                                color: const Color(0xFFEC407A),
                              ),
                            ),
                            items:
                                [
                                  'fleksi',
                                  'defleksi ringan',
                                  'defleksi sedang',
                                  'defleksi maksimal',
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value.toUpperCase(),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _sikapJanin = newValue!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _hbController,
                            decoration: InputDecoration(
                              labelText: 'HB',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(
                                Icons.bloodtype_rounded,
                                color: const Color(0xFFEC407A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _pemeriksaanDalamController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Pemeriksaan Dalam (Bimanual)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.medical_services_rounded,
                            color: const Color(0xFFEC407A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // DIAGNOSIS KEBIDANAN Section
                      _buildSectionHeader(
                        'DIAGNOSIS KEBIDANAN',
                        Icons.medical_information_rounded,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _catatanController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Catatan *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.note_rounded,
                            color: const Color(0xFFEC407A),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan catatan diagnosis';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Screening Questions Section
                      _buildSectionHeader(
                        'PENAPISAN IBU BERSALIN',
                        Icons.health_and_safety_rounded,
                      ),
                      const SizedBox(height: 16),

                      // Screening Questions
                      _buildScreeningQuestion(
                        'Riwayat bedah sesar',
                        'riwayat_bedah_sesar',
                      ),
                      const SizedBox(height: 12),

                      _buildScreeningQuestion(
                        'Pendarahan pervaginam',
                        'pendarahan_pervaginaan',
                      ),
                      const SizedBox(height: 12),

                      _buildScreeningQuestion(
                        'Persalinan kurang bulan',
                        'persalinan_kurang_bulan',
                      ),
                      const SizedBox(height: 12),

                      _buildScreeningQuestion(
                        'Ketuban pecah dengan mekonium',
                        'ketuban_pecah_mekonium',
                      ),
                      const SizedBox(height: 12),

                      _buildScreeningQuestion(
                        'Ketuban pecah kurang bulan',
                        'ketuban_pecah_kurang_bulan',
                      ),
                      const SizedBox(height: 12),

                      _buildScreeningQuestion(
                        'Ketuban pecah lama',
                        'ketuban_pecah_lama',
                      ),
                      const SizedBox(height: 12),

                      _buildScreeningQuestion('Anemia berat', 'anemia_berat'),
                      const SizedBox(height: 12),

                      _buildScreeningQuestion('Tanda infeksi', 'tanda_infeksi'),
                      const SizedBox(height: 12),

                      _buildScreeningQuestion('Ikterus', 'ikterius'),
                      const SizedBox(height: 12),

                      _buildScreeningQuestion('Pre-eklampsia', 'pre_eklampsia'),
                      const SizedBox(height: 12),

                      _buildScreeningQuestion(
                        'Tinggi fundus 40 cm',
                        'tinggi_fundus_40',
                      ),
                      const SizedBox(height: 12),

                      _buildScreeningQuestion('Gawat janin', 'gawat_janin'),
                      const SizedBox(height: 12),

                      _buildScreeningQuestion(
                        'Primipara fase aktif',
                        'primpara_fase_aktif',
                      ),
                      const SizedBox(height: 12),

                      _buildScreeningQuestion(
                        'Presentasi bukan belakang kepala',
                        'presentasi_bukan_belakang_kepala',
                      ),
                      const SizedBox(height: 12),

                      _buildScreeningQuestion(
                        'Presentasi ganda',
                        'presentasi_ganda',
                      ),
                      const SizedBox(height: 12),

                      _buildScreeningQuestion(
                        'Kehamilan ganda',
                        'kehamilan_ganda',
                      ),
                      const SizedBox(height: 12),

                      _buildScreeningQuestion(
                        'Tali pusat menumbung',
                        'tali_pusat_menumbung',
                      ),
                      const SizedBox(height: 12),

                      _buildScreeningQuestion('Shock', 'shock'),
                      const SizedBox(height: 24),

                      const SizedBox(height: 24),

                      // STATUS KEHAMILAN Section
                      _buildSectionHeader(
                        'STATUS KEHAMILAN',
                        Icons.pregnant_woman_rounded,
                      ),
                      const SizedBox(height: 16),

                      // Pregnancy Status
                      DropdownButtonFormField<String>(
                        value: _pregnancyStatus,
                        decoration: InputDecoration(
                          labelText: 'Status Kehamilan *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.pregnant_woman_rounded,
                            color: const Color(0xFFEC407A),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'active',
                            child: Text('Kehamilan Aktif'),
                          ),
                          DropdownMenuItem(
                            value: 'miscarriage',
                            child: Text('Keguguran'),
                          ),
                          DropdownMenuItem(
                            value: 'complication',
                            child: Text('Komplikasi Serius'),
                          ),
                          DropdownMenuItem(
                            value: 'completed',
                            child: Text('Kehamilan Selesai'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _pregnancyStatus = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pilih status kehamilan';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Pregnancy End Reason (if not active)
                      if (_pregnancyStatus != 'active') ...[
                        DropdownButtonFormField<String>(
                          value: _pregnancyEndReason,
                          decoration: InputDecoration(
                            labelText: 'Alasan Pengakhiran *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.info_rounded,
                              color: const Color(0xFFEC407A),
                            ),
                          ),
                          items: _getPregnancyEndReasonItems(),
                          onChanged: (value) {
                            setState(() {
                              _pregnancyEndReason = value!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Pilih alasan pengakhiran';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Pregnancy End Date
                        TextFormField(
                          controller: _pregnancyEndDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Tanggal Pengakhiran *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.calendar_today_rounded,
                              color: const Color(0xFFEC407A),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.calendar_month_rounded),
                              onPressed: () => _selectPregnancyEndDate(),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Pilih tanggal pengakhiran';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Pregnancy Notes
                        TextFormField(
                          controller: _pregnancyNotesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Catatan Tambahan',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.note_rounded,
                              color: const Color(0xFFEC407A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveExamination,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEC407A),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              'Simpan',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Get pregnancy end reason items based on status
  List<DropdownMenuItem<String>> _getPregnancyEndReasonItems() {
    switch (_pregnancyStatus) {
      case 'miscarriage':
        return [
          DropdownMenuItem(value: 'miscarriage', child: Text('Keguguran')),
        ];
      case 'complication':
        return [
          DropdownMenuItem(
            value: 'complication',
            child: Text('Komplikasi Medis'),
          ),
        ];
      case 'completed':
        return [DropdownMenuItem(value: 'birth', child: Text('Kelahiran'))];
      default:
        return [
          DropdownMenuItem(value: 'miscarriage', child: Text('Keguguran')),
          DropdownMenuItem(
            value: 'complication',
            child: Text('Komplikasi Medis'),
          ),
          DropdownMenuItem(value: 'birth', child: Text('Kelahiran')),
        ];
    }
  }

  // Select pregnancy end date
  Future<void> _selectPregnancyEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _pregnancyEndDateController.text = DateFormat(
          'dd/MM/yyyy',
        ).format(picked);
      });
    }
  }
}

class PregnancyExaminationDetailDialog extends StatelessWidget {
  final Map<String, dynamic> examination;

  const PregnancyExaminationDetailDialog({
    super.key,
    required this.examination,
  });

  // Helper method to format examination date safely
  String _formatExaminationDate(
    dynamic dateValue, [
    String format = 'dd/MM/yyyy',
  ]) {
    try {
      DateTime date;

      if (dateValue is Timestamp) {
        date = dateValue.toDate();
      } else if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return '-';
      }

      return DateFormat(format).format(date);
    } catch (e) {
      print('Error formatting date: $e');
      return 'Format tanggal tidak valid';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.visibility_rounded,
                    color: const Color(0xFFEC407A),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Detail Pemeriksaan Ibu Hamil',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection('Data Pasien', [
                      _buildDetailRow('Nama', examination['namaPasien'] ?? '-'),
                      _buildDetailRow('No HP', examination['noHp'] ?? '-'),
                      _buildDetailRow(
                        'Umur',
                        '${examination['umur'] ?? '-'} tahun',
                      ),
                      _buildDetailRow('Alamat', examination['alamat'] ?? '-'),
                    ]),

                    const SizedBox(height: 16),

                    _buildDetailSection('Data Pemeriksaan', [
                      _buildDetailRow(
                        'Tanggal',
                        _formatExaminationDate(
                          examination['tanggalPemeriksaan'],
                        ),
                      ),
                      _buildDetailRow(
                        'Usia Kehamilan',
                        '${examination['usiaKehamilan']} minggu',
                      ),
                      _buildDetailRow(
                        'Berat Badan',
                        '${examination['beratBadan']} kg',
                      ),
                      _buildDetailRow(
                        'Tekanan Darah',
                        examination['tekananDarah'] ?? '-',
                      ),
                      _buildDetailRow(
                        'Tinggi Badan',
                        '${examination['tinggiBadan']} cm',
                      ),
                      _buildDetailRow(
                        'Lingkar Lengan',
                        '${examination['lingkarLengan']} cm',
                      ),
                      _buildDetailRow(
                        'Hemoglobin',
                        '${examination['hemoglobin']} g/dL',
                      ),
                      _buildDetailRow(
                        'Protein Urin',
                        examination['proteinUrin'] ?? '-',
                      ),
                      _buildDetailRow(
                        'Gula Darah',
                        '${examination['gulaDarah']} mg/dL',
                      ),
                      _buildDetailRow(
                        'Status Gizi',
                        examination['statusGizi'] ?? '-',
                      ),
                    ]),

                    const SizedBox(height: 16),

                    _buildDetailSection('Diagnosa & Tindakan', [
                      _buildDetailRow('Keluhan', examination['keluhan'] ?? '-'),
                      _buildDetailRow(
                        'Diagnosa',
                        examination['diagnosa'] ?? '-',
                      ),
                      _buildDetailRow(
                        'Tindakan',
                        examination['tindakan'] ?? '-',
                      ),
                      _buildDetailRow('Bidan', examination['namaBidan'] ?? '-'),
                    ]),

                    const SizedBox(height: 16),

                    _buildDetailSection('Penapisan Pasien Ibu Bersalin', [
                      ...(examination['screeningQuestions']
                                  as Map<String, dynamic>? ??
                              {})
                          .entries
                          .map((entry) {
                            return _buildDetailRow(
                              _getScreeningQuestionText(entry.key),
                              entry.value ? 'Ya' : 'Tidak',
                            );
                          })
                          .toList(),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEC407A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Tutup', style: GoogleFonts.poppins()),
              ),
            ),
          ],
        ),
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFEC407A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value, style: GoogleFonts.poppins())),
        ],
      ),
    );
  }

  String _getScreeningQuestionText(String key) {
    switch (key) {
      case 'riwayat_bedah_sesar':
        return 'Riwayat bedah sesar';
      case 'pendarahan_pervaginaan':
        return 'Pendarahan pervaginaan';
      case 'persalinan_kurang_bulan':
        return 'Persalinan kurang bulan';
      case 'ketuban_pecah_mekonium':
        return 'Ketuban pecah mekonium kental';
      case 'ketuban_pecah_kurang_bulan':
        return 'Ketuban pecah kurang bulan';
      case 'ketuban_pecah_lama':
        return 'Ketuban pecah lama';
      case 'anemia_berat':
        return 'Anemia berat';
      case 'tanda_infeksi':
        return 'Tanda infeksi';
      case 'ikterius':
        return 'Ikterius';
      case 'pre_eklampsia':
        return 'Pre-eklampsia';
      case 'tinggi_fundus_40':
        return 'Tinggi fundus 40 cm+';
      case 'gawat_janin':
        return 'Gawat janin';
      case 'primpara_fase_aktif':
        return 'Primpara fase aktif';
      case 'presentasi_bukan_belakang_kepala':
        return 'Presentasi bukan belakang kepala';
      case 'presentasi_ganda':
        return 'Presentasi ganda';
      case 'kehamilan_ganda':
        return 'Kehamilan ganda';
      case 'tali_pusat_menumbung':
        return 'Tali pusat menumbung';
      case 'shock':
        return 'Shock';
      default:
        return key;
    }
  }
}

class EditExaminationDialog extends StatefulWidget {
  final Map<String, dynamic> examination;
  final FirebaseService firebaseService;
  final VoidCallback onSaved;

  const EditExaminationDialog({
    super.key,
    required this.examination,
    required this.firebaseService,
    required this.onSaved,
  });

  @override
  State<EditExaminationDialog> createState() => _EditExaminationDialogState();
}

class _EditExaminationDialogState extends State<EditExaminationDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers for text fields
  late TextEditingController _namaPasienController;
  late TextEditingController _noHpController;
  late TextEditingController _umurController;
  late TextEditingController _alamatController;
  late TextEditingController _usiaKehamilanController;
  late TextEditingController _tekananDarahController;
  late TextEditingController _suhuBadanController;
  late TextEditingController _nadiController;
  late TextEditingController _beratBadanController;
  late TextEditingController _pernafasanController;
  late TextEditingController _tinggiBadanController;
  late TextEditingController _catatanController;

  // Dropdown values
  String _kesadaran = 'NORMAL';
  String _kepala = 'NORMAL';
  String _mata = 'NORMAL';
  String _leher = 'NORMAL';
  String _tangan = 'NORMAL';
  String _dada = 'NORMAL';
  String _hidung = 'NORMAL';
  String _kulit = 'NORMAL';
  String _mulut = 'NORMAL';
  String _kaki = 'NORMAL';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final exam = widget.examination;

    _namaPasienController = TextEditingController(
      text: exam['namaPasien'] ?? '',
    );
    _noHpController = TextEditingController(text: exam['noHp'] ?? '');
    _umurController = TextEditingController(
      text: exam['umur']?.toString() ?? '',
    );
    _alamatController = TextEditingController(text: exam['alamat'] ?? '');
    _usiaKehamilanController = TextEditingController(
      text: exam['usiaKehamilan']?.toString() ?? '',
    );
    _tekananDarahController = TextEditingController(
      text: exam['tekananDarah'] ?? '',
    );
    _suhuBadanController = TextEditingController(text: exam['suhuBadan'] ?? '');
    _nadiController = TextEditingController(text: exam['nadi'] ?? '');
    _beratBadanController = TextEditingController(
      text: exam['beratBadan']?.toString() ?? '',
    );
    _pernafasanController = TextEditingController(
      text: exam['pernafasan'] ?? '',
    );
    _tinggiBadanController = TextEditingController(
      text: exam['tinggiBadan']?.toString() ?? '',
    );
    _catatanController = TextEditingController(text: exam['catatan'] ?? '');

    // Initialize dropdown values
    _kesadaran = exam['kesadaran'] ?? 'NORMAL';
    _kepala = exam['kepala'] ?? 'NORMAL';
    _mata = exam['mata'] ?? 'NORMAL';
    _leher = exam['leher'] ?? 'NORMAL';
    _tangan = exam['tangan'] ?? 'NORMAL';
    _dada = exam['dada'] ?? 'NORMAL';
    _hidung = exam['hidung'] ?? 'NORMAL';
    _kulit = exam['kulit'] ?? 'NORMAL';
    _mulut = exam['mulut'] ?? 'NORMAL';
    _kaki = exam['kaki'] ?? 'NORMAL';
  }

  @override
  void dispose() {
    _namaPasienController.dispose();
    _noHpController.dispose();
    _umurController.dispose();
    _alamatController.dispose();
    _usiaKehamilanController.dispose();
    _tekananDarahController.dispose();
    _suhuBadanController.dispose();
    _nadiController.dispose();
    _beratBadanController.dispose();
    _pernafasanController.dispose();
    _tinggiBadanController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _updateExamination() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedData = {
        ...widget.examination, // Keep existing data
        // Update with new values
        'namaPasien': _namaPasienController.text,
        'noHp': _noHpController.text,
        'umur': int.tryParse(_umurController.text) ?? 0,
        'alamat': _alamatController.text,
        'usiaKehamilan': int.tryParse(_usiaKehamilanController.text) ?? 0,
        'tekananDarah': _tekananDarahController.text,
        'suhuBadan': _suhuBadanController.text,
        'nadi': _nadiController.text,
        'beratBadan': double.tryParse(_beratBadanController.text) ?? 0.0,
        'pernafasan': _pernafasanController.text,
        'tinggiBadan': double.tryParse(_tinggiBadanController.text) ?? 0.0,
        'catatan': _catatanController.text,
        'kesadaran': _kesadaran,
        'kepala': _kepala,
        'mata': _mata,
        'leher': _leher,
        'tangan': _tangan,
        'dada': _dada,
        'hidung': _hidung,
        'kulit': _kulit,
        'mulut': _mulut,
        'kaki': _kaki,
        'updatedAt': DateTime.now(),
      };

      await widget.firebaseService.updatePemeriksaanIbuHamil(updatedData);

      Navigator.pop(context);
      widget.onSaved();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pemeriksaan berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error memperbarui pemeriksaan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(Icons.edit, color: const Color(0xFFEC407A)),
        ),
        validator:
            required
                ? (value) {
                  if (value == null || value.isEmpty) {
                    return '$label tidak boleh kosong';
                  }
                  return null;
                }
                : null,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(
            Icons.health_and_safety_rounded,
            color: const Color(0xFFEC407A),
          ),
        ),
        items:
            ['NORMAL', 'ADA KELAINAN'].map((String val) {
              return DropdownMenuItem<String>(value: val, child: Text(val));
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Pemeriksaan',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFEC407A),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data Pasien',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEC407A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Nama Pasien',
                        _namaPasienController,
                        required: true,
                      ),
                      _buildTextField('No HP', _noHpController),
                      _buildTextField('Umur', _umurController),
                      _buildTextField('Alamat', _alamatController),
                      _buildTextField(
                        'Usia Kehamilan (minggu)',
                        _usiaKehamilanController,
                      ),

                      const SizedBox(height: 24),
                      Text(
                        'Tanda Vital',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEC407A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Tekanan Darah', _tekananDarahController),
                      _buildTextField('Suhu Badan', _suhuBadanController),
                      _buildTextField('Nadi', _nadiController),
                      _buildTextField(
                        'Berat Badan (kg)',
                        _beratBadanController,
                      ),
                      _buildTextField('Pernafasan', _pernafasanController),
                      _buildTextField(
                        'Tinggi Badan (cm)',
                        _tinggiBadanController,
                      ),

                      const SizedBox(height: 24),
                      Text(
                        'Kondisi Umum',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEC407A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        'Kesadaran',
                        _kesadaran,
                        (value) => setState(() => _kesadaran = value!),
                      ),
                      _buildDropdown(
                        'Kepala',
                        _kepala,
                        (value) => setState(() => _kepala = value!),
                      ),
                      _buildDropdown(
                        'Mata',
                        _mata,
                        (value) => setState(() => _mata = value!),
                      ),
                      _buildDropdown(
                        'Leher',
                        _leher,
                        (value) => setState(() => _leher = value!),
                      ),
                      _buildDropdown(
                        'Tangan',
                        _tangan,
                        (value) => setState(() => _tangan = value!),
                      ),
                      _buildDropdown(
                        'Dada',
                        _dada,
                        (value) => setState(() => _dada = value!),
                      ),
                      _buildDropdown(
                        'Hidung',
                        _hidung,
                        (value) => setState(() => _hidung = value!),
                      ),
                      _buildDropdown(
                        'Kulit',
                        _kulit,
                        (value) => setState(() => _kulit = value!),
                      ),
                      _buildDropdown(
                        'Mulut',
                        _mulut,
                        (value) => setState(() => _mulut = value!),
                      ),
                      _buildDropdown(
                        'Kaki',
                        _kaki,
                        (value) => setState(() => _kaki = value!),
                      ),

                      const SizedBox(height: 24),
                      Text(
                        'Catatan',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEC407A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _catatanController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Catatan Pemeriksaan',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.note_add,
                            color: const Color(0xFFEC407A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateExamination,
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
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            'Simpan Perubahan',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
