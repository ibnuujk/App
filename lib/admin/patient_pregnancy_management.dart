import 'package:flutter/material.dart';
import '../utilities/safe_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/persalinan_model.dart';
import '../services/firebase_service.dart';

class PatientPregnancyManagementScreen extends StatefulWidget {
  final UserModel user;

  const PatientPregnancyManagementScreen({super.key, required this.user});

  @override
  State<PatientPregnancyManagementScreen> createState() =>
      _PatientPregnancyManagementScreenState();
}

class _PatientPregnancyManagementScreenState
    extends State<PatientPregnancyManagementScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _patientsWithExaminations = [];
  List<PersalinanModel> _persalinanData = [];
  bool _isLoading = true;

  StreamSubscription<List<Map<String, dynamic>>>? _examinationsSubscription;
  StreamSubscription<List<PersalinanModel>>? _persalinanSubscription;

  @override
  void initState() {
    super.initState();
    _loadPatientsWithExaminations();
    _loadPersalinanData();
  }

  @override
  void dispose() {
    _examinationsSubscription?.cancel();
    _persalinanSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadPatientsWithExaminations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _examinationsSubscription?.cancel();
      _examinationsSubscription = _firebaseService
          .getPemeriksaanIbuHamilStream()
          .timeout(const Duration(seconds: 30))
          .listen(
            (examinations) async {
              if (mounted) {
                // Group examinations by patient
                Map<String, List<Map<String, dynamic>>> patientExaminations =
                    {};
                Map<String, Map<String, dynamic>> patientInfo = {};

                for (var examination in examinations) {
                  // Add null checks for examination data

                  String patientId = examination['pasienId']?.toString() ?? '';
                  if (patientId.isNotEmpty) {
                    if (!patientExaminations.containsKey(patientId)) {
                      patientExaminations[patientId] = [];
                      // Store patient info from first examination with null safety
                      patientInfo[patientId] = {
                        'nama':
                            examination['namaPasien']?.toString() ??
                            'Tidak diketahui',
                        'noHp': examination['noHp']?.toString() ?? '-',
                        'umur': examination['umur'] ?? 0,
                        'alamat':
                            examination['alamat']?.toString() ??
                            'Tidak diketahui',
                        'pasienId': patientId,
                      };
                    }
                    // Add comprehensive validation for required examination fields
                    if (_isValidExaminationData(examination)) {
                      patientExaminations[patientId]!.add(examination);
                    }
                  }
                }

                // Convert to list format
                List<Map<String, dynamic>> patientsData = [];
                for (var patientId in patientExaminations.keys) {
                  var examinations = patientExaminations[patientId]!;

                  // Skip if no valid examinations
                  if (examinations.isEmpty) continue;

                  // Sort examinations by date (newest first) with null safety
                  examinations.sort((a, b) {
                    try {
                      DateTime dateA = _parseExaminationDate(a['tanggalMasuk']);
                      DateTime dateB = _parseExaminationDate(b['tanggalMasuk']);
                      return dateB.compareTo(dateA);
                    } catch (e) {
                      return 0; // Keep original order if dates can't be compared
                    }
                  });

                  patientsData.add({
                    'patientInfo': patientInfo[patientId],
                    'examinations': examinations,
                    'examinationCount': examinations.length,
                    'lastExamination': examinations.first,
                  });
                }

                // Sort patients by last examination date with null safety
                patientsData.sort((a, b) {
                  try {
                    DateTime dateA = _parseExaminationDate(
                      a['lastExamination']['tanggalMasuk'],
                    );
                    DateTime dateB = _parseExaminationDate(
                      b['lastExamination']['tanggalMasuk'],
                    );
                    return dateB.compareTo(dateA);
                  } catch (e) {
                    return 0; // Keep original order if dates can't be compared
                  }
                });

                setState(() {
                  _patientsWithExaminations = patientsData;
                  _isLoading = false;
                });
              }
            },
            onError: (error) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _patientsWithExaminations = [];
                });

                if (!error.toString().toLowerCase().contains('timeout') &&
                    !error.toString().toLowerCase().contains('time limit')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal memuat data: ${error.toString()}'),
                      backgroundColor: Colors.orange,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _patientsWithExaminations = [];
        });

        if (!e.toString().toLowerCase().contains('timeout') &&
            !e.toString().toLowerCase().contains('time limit')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memuat data: ${e.toString()}'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _loadPersalinanData() async {
    try {
      _persalinanSubscription?.cancel();
      _persalinanSubscription = _firebaseService.getPersalinanStream().listen(
        (persalinan) {
          if (mounted) {
            setState(() {
              _persalinanData = persalinan;
            });
          }
        },
        onError: (e) {
          print('Error loading persalinan data: $e');
        },
      );
    } catch (e) {
      print('Exception loading persalinan data: $e');
    }
  }

  bool _hasCompletedDelivery(String patientId) {
    return _persalinanData.any(
      (persalinan) => persalinan.pasienId == patientId,
    );
  }

  DateTime _parseExaminationDate(dynamic dateValue) {
    try {
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      } else if (dateValue is String) {
        // Try parsing different date formats
        try {
          // First try dd/MM/yyyy HH:mm format
          return DateFormat('dd/MM/yyyy HH:mm').parse(dateValue);
        } catch (e) {
          try {
            // Try dd/MM/yyyy format
            return DateFormat('dd/MM/yyyy').parse(dateValue);
          } catch (e) {
            try {
              // Try ISO 8601 format
              return DateTime.parse(dateValue);
            } catch (e) {
              // Default to current time if all parsing fails
              return DateTime.now();
            }
          }
        }
      } else if (dateValue is DateTime) {
        return dateValue;
      } else {
        return DateTime.now();
      }
    } catch (e) {
      print('Error parsing examination date: $e');
      return DateTime.now();
    }
  }

  bool _isValidExaminationData(Map<String, dynamic> examination) {
    // Check for essential fields
    if (examination['pasienId'] == null ||
        examination['pasienId'].toString().isEmpty) {
      return false;
    }

    if (examination['namaPasien'] == null ||
        examination['namaPasien'].toString().isEmpty) {
      return false;
    }

    if (examination['tanggalMasuk'] == null) {
      return false;
    }

    // Try to parse the date to ensure it's valid
    try {
      _parseExaminationDate(examination['tanggalMasuk']);
      return true;
    } catch (e) {
      print('Invalid date in examination data: ${examination['tanggalMasuk']}');
      return false;
    }
  }

  void _showExaminationHistory(Map<String, dynamic> patientData) {
    try {
      // Validate data before navigation
      if (patientData['patientInfo'] == null ||
          patientData['examinations'] == null ||
          (patientData['examinations'] as List).isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data pemeriksaan tidak lengkap'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  PatientExaminationHistoryScreen(patientData: patientData),
        ),
      ).catchError((error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka riwayat: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
          onPressed: () => NavigationHelper.safeNavigateBack(context),
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
                          child: const Icon(
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
                                'Pasien yang sudah melakukan pemeriksaan',
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
                          'Total Pasien',
                          _patientsWithExaminations.length,
                          Colors.white,
                        ),
                        const SizedBox(width: 12),
                        _buildStatusCard(
                          'Sudah Registrasi',
                          _patientsWithExaminations
                              .where(
                                (patient) => _hasCompletedDelivery(
                                  patient['patientInfo']['pasienId'],
                                ),
                              )
                              .length,
                          Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Patients List
              Expanded(
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFEC407A),
                          ),
                        )
                        : _patientsWithExaminations.isEmpty
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
                                child: const Icon(
                                  Icons.pregnant_woman_outlined,
                                  size: 60,
                                  color: Color(0xFFEC407A),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Belum ada data pasien',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Pasien yang sudah diperiksa akan muncul di sini',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: _patientsWithExaminations.length,
                          itemBuilder: (context, index) {
                            final patientData =
                                _patientsWithExaminations[index];
                            final patientInfo = patientData['patientInfo'];
                            final hasRegistration = _hasCompletedDelivery(
                              patientInfo['pasienId'],
                            );

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Patient Name
                                    Text(
                                      patientInfo['nama'] ??
                                          'Nama tidak tersedia',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2D3748),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Pasien Ibu Hamil',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: const Color(0xFFEC407A),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Patient Details
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildPatientDetailItem(
                                            Icons.phone_rounded,
                                            'No HP',
                                            patientInfo['noHp'] ?? '-',
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildPatientDetailItem(
                                            Icons.cake_rounded,
                                            'Umur',
                                            '${patientInfo['umur'] ?? '-'} tahun',
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    _buildPatientDetailItem(
                                      Icons.location_on_rounded,
                                      'Alamat',
                                      patientInfo['alamat'] ?? '-',
                                    ),

                                    // Registration Status
                                    if (hasRegistration) ...[
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.green.withValues(
                                              alpha: 0.3,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green[700],
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Registrasi berhasil',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.green[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.medical_services,
                                                  color: Colors.green[700],
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Pemeriksaan selesai',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.green[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],

                                    const SizedBox(height: 16),

                                    // History Button
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            () => _showExaminationHistory(
                                              patientData,
                                            ),
                                        icon: const Icon(
                                          Icons.history,
                                          size: 20,
                                        ),
                                        label: Text(
                                          'Riwayat Pemeriksaan (${patientData['examinationCount']})',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFEC407A,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 2,
                                        ),
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
    );
  }

  Widget _buildStatusCard(String label, int count, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: textColor.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFEC407A)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF2D3748),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// New screen to show examination history for a specific patient
class PatientExaminationHistoryScreen extends StatelessWidget {
  final Map<String, dynamic> patientData;

  const PatientExaminationHistoryScreen({super.key, required this.patientData});

  void _showExaminationDetail(
    BuildContext context,
    Map<String, dynamic> examination,
  ) {
    showDialog(
      context: context,
      builder: (context) => ExaminationDetailDialog(examination: examination),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientInfo = patientData['patientInfo'] as Map<String, dynamic>?;
    final examinationsRaw = patientData['examinations'];

    // Add null safety for examinations
    if (patientInfo == null || examinationsRaw == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFEC407A),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => NavigationHelper.safeNavigateBack(context),
          ),
          title: Text(
            'Riwayat Pemeriksaan',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        body: const Center(child: Text('Data tidak valid')),
      );
    }

    final examinations = examinationsRaw as List<Map<String, dynamic>>;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEC407A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => NavigationHelper.safeNavigateBack(context),
        ),
        title: Text(
          'Riwayat Pemeriksaan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Info Header
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
                          child: const Icon(
                            Icons.person_rounded,
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
                                patientInfo['nama'] ?? 'Nama tidak tersedia',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Riwayat pemeriksaan pasien',
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
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Examinations List
              Expanded(
                child: ListView.builder(
                  itemCount: examinations.length,
                  itemBuilder: (context, index) {
                    final examination = examinations[index];

                    // Parse examination date with multiple format support
                    DateTime examinationDate;
                    try {
                      examinationDate = _parseExaminationDateStatic(
                        examination['tanggalMasuk'],
                      );
                    } catch (e) {
                      print('Error parsing examination date: $e');
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.orange,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Data pemeriksaan tidak valid',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            Text(
                              'Tanggal: ${examination['tanggalMasuk'] ?? 'tidak tersedia'}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final examinationNumber = examinations.length - index;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date Header
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  color: const Color(0xFFEC407A),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat(
                                    'dd MMMM yyyy',
                                    'id_ID',
                                  ).format(examinationDate),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFEC407A),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Section Title
                            Text(
                              'Data Pemeriksaan',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2D3748),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Examination Data Grid
                            Row(
                              children: [
                                Expanded(
                                  child: _buildExaminationDetailItem(
                                    'Usia Kehamilan',
                                    '${examination['usiaKehamilan'] ?? '-'} minggu',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildExaminationDetailItem(
                                    'HPHT',
                                    _formatHphtDate(examination['hpht']),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildExaminationDetailItem(
                                    'Tekanan Darah',
                                    examination['tekananDarah'] ?? '-',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildExaminationDetailItem(
                                    'Berat Badan',
                                    '${examination['beratBadan'] ?? '-'} kg',
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildExaminationDetailItem(
                                    'Tinggi Badan',
                                    '${examination['tinggiBadan'] ?? '-'} cm',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildExaminationDetailItem(
                                    'HB',
                                    '${examination['hb'] ?? '-'} g/dL',
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Examination Number Badge and Detail Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
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
                                  ),
                                  child: Text(
                                    'Pemeriksaan ke: $examinationNumber',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFEC407A),
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed:
                                      () => _showExaminationDetail(
                                        context,
                                        examination,
                                      ),
                                  icon: const Icon(Icons.visibility, size: 16),
                                  label: Text(
                                    'Detail',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    minimumSize: const Size(0, 32),
                                  ),
                                ),
                              ],
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
    );
  }

  String _formatHphtDate(dynamic hphtData) {
    if (hphtData == null) return '-';

    try {
      if (hphtData is Timestamp) {
        return DateFormat('dd/MM/yyyy').format(hphtData.toDate());
      } else if (hphtData is DateTime) {
        return DateFormat('dd/MM/yyyy').format(hphtData);
      } else if (hphtData is String) {
        // Try to parse string dates
        try {
          DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(hphtData);
          return DateFormat('dd/MM/yyyy').format(parsedDate);
        } catch (e) {
          return hphtData; // Return original string if parsing fails
        }
      } else {
        return '-';
      }
    } catch (e) {
      print('Error formatting HPHT date: $e');
      return '-';
    }
  }

  static DateTime _parseExaminationDateStatic(dynamic dateValue) {
    try {
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      } else if (dateValue is String) {
        // Try parsing different date formats
        try {
          // First try dd/MM/yyyy HH:mm format
          return DateFormat('dd/MM/yyyy HH:mm').parse(dateValue);
        } catch (e) {
          try {
            // Try dd/MM/yyyy format
            return DateFormat('dd/MM/yyyy').parse(dateValue);
          } catch (e) {
            try {
              // Try ISO 8601 format
              return DateTime.parse(dateValue);
            } catch (e) {
              // Default to current time if all parsing fails
              return DateTime.now();
            }
          }
        }
      } else if (dateValue is DateTime) {
        return dateValue;
      } else {
        return DateTime.now();
      }
    } catch (e) {
      print('Error parsing examination date: $e');
      return DateTime.now();
    }
  }

  Widget _buildExaminationDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF2D3748),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Dialog for showing detailed examination information
class ExaminationDetailDialog extends StatelessWidget {
  final Map<String, dynamic> examination;

  const ExaminationDetailDialog({super.key, required this.examination});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEC407A), Color(0xFFE91E63)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.medical_information,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Pemeriksaan',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          examination['namaPasien'] ?? 'Nama tidak tersedia',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => NavigationHelper.safeNavigateBack(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tanggal Pemeriksaan
                    _buildDetailSection('Informasi Pemeriksaan', [
                      _buildDetailRow(
                        'Tanggal Masuk',
                        examination['tanggalMasuk']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Jenis Kunjungan',
                        examination['jenisKunjungan']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Usia Kehamilan',
                        '${examination['usiaKehamilan'] ?? '-'} minggu',
                      ),
                      _buildDetailRow(
                        'HPHT',
                        examination['hpht']?.toString() ?? '-',
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // Data Pasien
                    _buildDetailSection('Data Pasien', [
                      _buildDetailRow(
                        'Nama',
                        examination['namaPasien']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'No HP',
                        examination['noHp']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Umur',
                        '${examination['umur'] ?? '-'} tahun',
                      ),
                      _buildDetailRow(
                        'Alamat',
                        examination['alamat']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Agama',
                        examination['agama']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Pekerjaan',
                        examination['pekerjaan']?.toString() ?? '-',
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // Tanda Vital
                    _buildDetailSection('Tanda Vital', [
                      _buildDetailRow(
                        'Tekanan Darah',
                        examination['tekananDarah']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Suhu Badan',
                        '${examination['suhuBadan'] ?? '-'} °C',
                      ),
                      _buildDetailRow(
                        'Nadi',
                        '${examination['nadi'] ?? '-'} x/mnt',
                      ),
                      _buildDetailRow(
                        'Pernafasan',
                        '${examination['pernafasan'] ?? '-'} /mnt',
                      ),
                      _buildDetailRow(
                        'Berat Badan',
                        '${examination['beratBadan'] ?? '-'} kg',
                      ),
                      _buildDetailRow(
                        'Tinggi Badan',
                        '${examination['tinggiBadan'] ?? '-'} cm',
                      ),
                      _buildDetailRow(
                        'HB (Hemoglobin)',
                        '${examination['hb'] ?? '-'} g/dL',
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // Kondisi Umum
                    _buildDetailSection('Kondisi Umum', [
                      _buildDetailRow(
                        'Kesadaran',
                        examination['kesadaran']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Kepala',
                        examination['kepala']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Mata',
                        examination['mata']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Leher',
                        examination['leher']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Tangan',
                        examination['tangan']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Dada',
                        examination['dada']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Hidung',
                        examination['hidung']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Kulit',
                        examination['kulit']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Mulut',
                        examination['mulut']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Kaki',
                        examination['kaki']?.toString() ?? '-',
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // Status Obstetrik
                    _buildDetailSection('Status Obstetrik', [
                      _buildDetailRow(
                        'Posisi Janin',
                        examination['posisiJanin']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'TFU',
                        examination['tfu']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'HIS',
                        examination['his']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'DJJ Irama',
                        examination['djjIrama']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Letak Janin',
                        examination['letakJanin']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Presentasi Janin',
                        examination['presentasiJanin']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Sikap Janin',
                        examination['sikapJanin']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Pemeriksaan Dalam',
                        examination['pemeriksaanDalam']?.toString() ?? '-',
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // Anamnesis
                    _buildDetailSection('Anamnesis & Riwayat', [
                      _buildDetailRow(
                        'Pemeriksaan Antenatal',
                        examination['pemeriksaanAntenatal']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Jumlah Antenatal',
                        examination['jumlahAntenatal']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Riwayat Haid',
                        examination['riwayatHaid']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Perkawinan',
                        examination['perkawinan']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Alasan Dirawat',
                        examination['alasanDirawat']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Riwayat Kehamilan Dulu',
                        examination['riwayatKehamilanDulu']?.toString() ?? '-',
                      ),
                      _buildDetailRow(
                        'Kehamilan Sekarang',
                        examination['kehamilanSekarang']?.toString() ?? '-',
                      ),
                    ]),

                    if (examination['catatan'] != null &&
                        examination['catatan'].toString().isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildDetailSection('Catatan', [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Text(
                            examination['catatan']?.toString() ?? '-',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFF2D3748),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ]),
                    ],
                  ],
                ),
              ),
            ),

            // Footer with close button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => NavigationHelper.safeNavigateBack(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEC407A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Tutup',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
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
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4A5568),
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF2D3748),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
