import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/persalinan_model.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';
import 'laporan_persalinan.dart';
import 'dart:async'; // Added for StreamSubscription

class RegistrasiPersalinanScreen extends StatefulWidget {
  const RegistrasiPersalinanScreen({super.key});

  @override
  State<RegistrasiPersalinanScreen> createState() =>
      _RegistrasiPersalinanScreenState();
}

class _RegistrasiPersalinanScreenState
    extends State<RegistrasiPersalinanScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();

  List<PersalinanModel> _allReports = [];
  List<PersalinanModel> _filteredReports = [];
  List<UserModel> _patients = [];
  bool _isLoading = true;
  bool _isLoadingPatients = true;
  bool _isLoadingReports = true;
  String _searchQuery = '';
  String? _errorMessage;

  // Stream subscriptions for proper cleanup
  StreamSubscription<List<UserModel>>? _patientsSubscription;
  StreamSubscription<List<PersalinanModel>>? _reportsSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _patientsSubscription?.cancel();
    _reportsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isLoadingPatients = true;
      _isLoadingReports = true;
      _errorMessage = null;
    });

    try {
      // Load patients with better error handling
      _loadPatients();

      // Load reports with better error handling
      _loadReports();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading data: $e';
      });
      _showErrorSnackBar('Error loading data: $e');
    }
  }

  void _loadPatients() {
    try {
      _patientsSubscription?.cancel();
      _patientsSubscription = _firebaseService
          .getUsersStream(limit: 1000, role: 'pasien')
          .timeout(const Duration(seconds: 20))
          .listen(
            (patients) {
              if (mounted) {
                setState(() {
                  _patients = patients;
                  _isLoadingPatients = false;
                  _errorMessage = null; // Clear any previous errors
                  _checkAllDataLoaded();
                });
              }
            },
            onError: (error) {
              if (mounted) {
                setState(() {
                  _isLoadingPatients = false;
                  _errorMessage = 'Error loading patients: $error';
                  _checkAllDataLoaded();
                });

                // Only show error for non-timeout errors
                if (!error.toString().contains('TimeoutException')) {
                  _showErrorSnackBar('Error loading patients: $error');
                }

                // Auto-retry after 5 seconds for timeout errors
                if (error.toString().contains('TimeoutException')) {
                  Future.delayed(const Duration(seconds: 5), () {
                    if (mounted) {
                      print('Retrying patient data load after timeout...');
                      _loadPatients();
                    }
                  });
                }
              }
            },
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPatients = false;
          _errorMessage = 'Error loading patients: $e';
          _checkAllDataLoaded();
        });
        _showErrorSnackBar('Error loading patients: $e');
      }
    }
  }

  void _loadReports() {
    try {
      _reportsSubscription?.cancel();
      _reportsSubscription = _firebaseService
          .getPersalinanStream()
          .timeout(const Duration(seconds: 20))
          .listen(
            (reports) {
              if (mounted) {
                setState(() {
                  _allReports = reports;
                  _filterReports();
                  _isLoadingReports = false;
                  _errorMessage = null; // Clear any previous errors
                  _checkAllDataLoaded();
                });
              }
            },
            onError: (error) {
              if (mounted) {
                setState(() {
                  _isLoadingReports = false;
                  _errorMessage = 'Error loading reports: $error';
                  _checkAllDataLoaded();
                });

                // Only show error for non-timeout errors
                if (!error.toString().contains('TimeoutException')) {
                  _showErrorSnackBar('Error loading reports: $error');
                }

                // Auto-retry after 5 seconds for timeout errors
                if (error.toString().contains('TimeoutException')) {
                  Future.delayed(const Duration(seconds: 5), () {
                    if (mounted) {
                      print('Retrying reports data load after timeout...');
                      _loadReports();
                    }
                  });
                }
              }
            },
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingReports = false;
          _errorMessage = 'Error loading reports: $e';
          _checkAllDataLoaded();
        });
        _showErrorSnackBar('Error loading reports: $e');
      }
    }
  }

  void _checkAllDataLoaded() {
    if (!_isLoadingPatients && !_isLoadingReports) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFEC407A),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // Refresh data with loading indicators
  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _isLoadingPatients = true;
      _isLoadingReports = true;
      _errorMessage = null;
    });

    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // Reduced delay for better UX

    try {
      _loadPatients();
      _loadReports();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil diperbarui'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error refreshing data: $e';
      });
      _showErrorSnackBar('Error refreshing data: $e');
    }
  }

  // Enhanced CRUD operations for patient data
  Future<void> _createPatient(UserModel patient) async {
    try {
      await _firebaseService.createUser(patient);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pasien berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error menambah data pasien: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updatePatient(UserModel patient) async {
    try {
      await _firebaseService.updateUser(patient);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pasien berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error memperbarui data pasien: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deletePatient(String patientId) async {
    try {
      // Check if patient has any delivery records
      final hasRecords = _allReports.any(
        (report) => report.pasienId == patientId,
      );

      if (hasRecords) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tidak dapat menghapus pasien yang memiliki data persalinan',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      await _firebaseService.deleteUser(patientId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pasien berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error menghapus data pasien: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Enhanced CRUD operations for delivery registration
  Future<void> _createDeliveryRegistration(PersalinanModel registration) async {
    try {
      await _firebaseService.createPersalinan(registration);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi persalinan berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error menambah registrasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateDeliveryRegistration(PersalinanModel registration) async {
    try {
      await _firebaseService.updatePersalinan(registration);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi persalinan berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error memperbarui registrasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteDeliveryRegistration(String registrationId) async {
    try {
      await _firebaseService.deletePersalinan(registrationId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi persalinan berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error menghapus registrasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterReports() {
    if (_searchQuery.isEmpty) {
      _filteredReports = _allReports;
    } else {
      _filteredReports =
          _allReports.where((report) {
            return report.pasienNama.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                report.pasienNoHp.contains(_searchQuery) ||
                report.pasienAlamat.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                report.namaSuami.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                report.pekerjaanSuami.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                report.agamaPasien.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                report.pekerjaanPasien.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }).toList();
    }
  }

  void _showAddEditDialog([PersalinanModel? report]) {
    final _formKey = GlobalKey<FormState>();
    UserModel? _selectedPatient =
        report != null
            ? _patients.firstWhere(
              (p) => p.id == report.pasienId,
              orElse: () => _patients.first,
            )
            : null;

    final _namaSuamiController = TextEditingController(
      text: report?.namaSuami ?? '',
    );
    final _pekerjaanSuamiController = TextEditingController(
      text: report?.pekerjaanSuami ?? '',
    );
    final _umurSuamiController = TextEditingController(
      text: report?.umurSuami.toString() ?? '',
    );
    final _agamaSuamiController = TextEditingController(
      text: report?.agamaSuami ?? '',
    );
    final _agamaPasienController = TextEditingController(
      text: report?.agamaPasien ?? '',
    );
    final _pekerjaanPasienController = TextEditingController(
      text: report?.pekerjaanPasien ?? '',
    );
    final _diagnosaController = TextEditingController(
      text: report?.diagnosaKebidanan ?? '',
    );
    final _tindakanController = TextEditingController(
      text: report?.tindakan ?? '',
    );
    final _rujukanController = TextEditingController(
      text: report?.rujukan ?? '',
    );
    final _penolongController = TextEditingController(
      text: report?.penolongPersalinan ?? '',
    );

    DateTime _tanggalMasuk = report?.tanggalMasuk ?? DateTime.now();
    String _fasilitas = report?.fasilitas ?? 'umum';
    bool _isLoading = false;

    // Function to load patient data when patient is selected
    void _loadPatientData(UserModel? patient) {
      if (patient != null) {
        setState(() {
          // Populate husband data from patient's profile
          if (patient.namaSuami != null && patient.namaSuami!.isNotEmpty) {
            _namaSuamiController.text = patient.namaSuami!;
          }
          if (patient.pekerjaanSuami != null &&
              patient.pekerjaanSuami!.isNotEmpty) {
            _pekerjaanSuamiController.text = patient.pekerjaanSuami!;
          }
          if (patient.umurSuami != null) {
            _umurSuamiController.text = patient.umurSuami.toString();
          }
          if (patient.agamaSuami != null && patient.agamaSuami!.isNotEmpty) {
            _agamaSuamiController.text = patient.agamaSuami!;
          }
          if (patient.agamaPasien != null && patient.agamaPasien!.isNotEmpty) {
            _agamaPasienController.text = patient.agamaPasien!;
          }
          if (patient.pekerjaanPasien != null &&
              patient.pekerjaanPasien!.isNotEmpty) {
            _pekerjaanPasienController.text = patient.pekerjaanPasien!;
          }
        });
      }
    }

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
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
                                color: const Color(
                                  0xFFEC407A,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                report == null
                                    ? Icons.add_rounded
                                    : Icons.edit_rounded,
                                color: const Color(0xFFEC407A),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                report == null
                                    ? 'Tambah Registrasi Persalinan'
                                    : 'Edit Registrasi Persalinan',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2D3748),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Info note
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFEC407A,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(
                                          0xFFEC407A,
                                        ).withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_rounded,
                                          color: const Color(0xFFEC407A),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Setelah memilih pasien, informasi suami dan pasien akan diisi otomatis dari database',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: const Color(0xFFEC407A),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Patient Selection
                                  DropdownButtonFormField<UserModel>(
                                    value: _selectedPatient,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      labelText: 'Pilih Pasien',
                                      prefixIcon: Icon(
                                        Icons.person_rounded,
                                        color: const Color(0xFFEC407A),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFEC407A),
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                    ),
                                    items:
                                        _patients.map((patient) {
                                          return DropdownMenuItem(
                                            value: patient,
                                            child: Text(
                                              '${patient.nama} - ${patient.noHp}',
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPatient = value;
                                        _loadPatientData(value);
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Pilih pasien';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Patient Information Section
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.blue[200]!,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Informasi Pasien',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue[700],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[100],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'Otomatis',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.blue[700],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller:
                                                    _agamaPasienController,
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  labelText: 'Agama Pasien',
                                                  prefixIcon: Icon(
                                                    Icons.church_rounded,
                                                    color: const Color(
                                                      0xFFEC407A,
                                                    ),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    borderSide: BorderSide(
                                                      color: Colors.grey[300]!,
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color:
                                                              Colors.grey[300]!,
                                                        ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color: Color(
                                                                0xFFEC407A,
                                                              ),
                                                              width: 2,
                                                            ),
                                                      ),
                                                  filled: true,
                                                  fillColor: Colors.grey[100],
                                                  hintText:
                                                      'Akan diisi otomatis dari data pasien',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: TextFormField(
                                                controller:
                                                    _pekerjaanPasienController,
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  labelText: 'Pekerjaan Pasien',
                                                  prefixIcon: Icon(
                                                    Icons.work_rounded,
                                                    color: const Color(
                                                      0xFFEC407A,
                                                    ),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    borderSide: BorderSide(
                                                      color: Colors.grey[300]!,
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color:
                                                              Colors.grey[300]!,
                                                        ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color: Color(
                                                                0xFFEC407A,
                                                              ),
                                                              width: 2,
                                                            ),
                                                      ),
                                                  filled: true,
                                                  fillColor: Colors.grey[100],
                                                  hintText:
                                                      'Akan diisi otomatis dari data pasien',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Husband Information Section
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.green[200]!,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Informasi Suami',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green[700],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.green[100],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'Otomatis',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.green[700],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        TextFormField(
                                          controller: _namaSuamiController,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            labelText: 'Nama Suami',
                                            prefixIcon: Icon(
                                              Icons.person_rounded,
                                              color: const Color(0xFFEC407A),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFEC407A),
                                                width: 2,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            hintText:
                                                'Akan diisi otomatis dari data pasien',
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller:
                                                    _pekerjaanSuamiController,
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  labelText: 'Pekerjaan Suami',
                                                  prefixIcon: Icon(
                                                    Icons.work_rounded,
                                                    color: const Color(
                                                      0xFFEC407A,
                                                    ),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    borderSide: BorderSide(
                                                      color: Colors.grey[300]!,
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color:
                                                              Colors.grey[300]!,
                                                        ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color: Color(
                                                                0xFFEC407A,
                                                              ),
                                                              width: 2,
                                                            ),
                                                      ),
                                                  filled: true,
                                                  fillColor: Colors.grey[100],
                                                  hintText:
                                                      'Akan diisi otomatis dari data pasien',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: TextFormField(
                                                controller:
                                                    _umurSuamiController,
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  labelText: 'Umur Suami',
                                                  prefixIcon: Icon(
                                                    Icons.cake_rounded,
                                                    color: const Color(
                                                      0xFFEC407A,
                                                    ),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    borderSide: BorderSide(
                                                      color: Colors.grey[300]!,
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color:
                                                              Colors.grey[300]!,
                                                        ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color: Color(
                                                                0xFFEC407A,
                                                              ),
                                                              width: 2,
                                                            ),
                                                      ),
                                                  filled: true,
                                                  fillColor: Colors.grey[100],
                                                  hintText:
                                                      'Akan diisi otomatis dari data pasien',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          controller: _agamaSuamiController,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            labelText: 'Agama Suami',
                                            prefixIcon: Icon(
                                              Icons.church_rounded,
                                              color: const Color(0xFFEC407A),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFEC407A),
                                                width: 2,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            hintText:
                                                'Akan diisi otomatis dari data pasien',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDatePickerTile(
                                    'Tanggal Masuk',
                                    DateFormat(
                                      'dd/MM/yyyy HH:mm',
                                    ).format(_tanggalMasuk),
                                    () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: _tanggalMasuk,
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime.now(),
                                      );
                                      if (date != null) {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.fromDateTime(
                                            _tanggalMasuk,
                                          ),
                                        );
                                        if (time != null) {
                                          setState(() {
                                            _tanggalMasuk = DateTime(
                                              date.year,
                                              date.month,
                                              date.day,
                                              time.hour,
                                              time.minute,
                                            );
                                          });
                                        }
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Facility Type
                                  DropdownButtonFormField<String>(
                                    value: _fasilitas,
                                    decoration: InputDecoration(
                                      labelText: 'Fasilitas',
                                      prefixIcon: Icon(
                                        Icons.local_hospital_rounded,
                                        color: const Color(0xFFEC407A),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFEC407A),
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'umum',
                                        child: Text('Umum'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'bpjs',
                                        child: Text('BPJS'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _fasilitas = value!;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Diagnosis
                                  TextFormField(
                                    controller: _diagnosaController,
                                    maxLines: 2,
                                    decoration: InputDecoration(
                                      labelText: 'Diagnosa Kebidanan',
                                      prefixIcon: Icon(
                                        Icons.medical_services_rounded,
                                        color: const Color(0xFFEC407A),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFEC407A),
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Diagnosa tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Action
                                  TextFormField(
                                    controller: _tindakanController,
                                    maxLines: 2,
                                    decoration: InputDecoration(
                                      labelText: 'Tindakan',
                                      prefixIcon: Icon(
                                        Icons.healing_rounded,
                                        color: const Color(0xFFEC407A),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFEC407A),
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Tindakan tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Referral (Optional)
                                  TextFormField(
                                    controller: _rujukanController,
                                    decoration: InputDecoration(
                                      labelText: 'Rujukan (Opsional)',
                                      prefixIcon: Icon(
                                        Icons.transfer_within_a_station_rounded,
                                        color: const Color(0xFFEC407A),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFEC407A),
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Birth Assistant
                                  TextFormField(
                                    controller: _penolongController,
                                    decoration: InputDecoration(
                                      labelText: 'Penolong Persalinan',
                                      prefixIcon: Icon(
                                        Icons.people_rounded,
                                        color: const Color(0xFFEC407A),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFEC407A),
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Penolong persalinan tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),
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
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    _isLoading
                                        ? null
                                        : () async {
                                          if (!_formKey.currentState!
                                              .validate())
                                            return;

                                          setState(() {
                                            _isLoading = true;
                                          });

                                          try {
                                            final newReport = PersalinanModel(
                                              id:
                                                  report?.id ??
                                                  _firebaseService.generateId(),
                                              pasienId: _selectedPatient!.id,
                                              pasienNama:
                                                  _selectedPatient!.nama,
                                              pasienNoHp:
                                                  _selectedPatient!.noHp,
                                              pasienUmur:
                                                  _selectedPatient!.umur,
                                              pasienAlamat:
                                                  _selectedPatient!.alamat,
                                              namaSuami:
                                                  _namaSuamiController.text
                                                      .trim(),
                                              pekerjaanSuami:
                                                  _pekerjaanSuamiController.text
                                                      .trim(),
                                              umurSuami:
                                                  int.tryParse(
                                                    _umurSuamiController.text
                                                        .trim(),
                                                  ) ??
                                                  0,
                                              agamaSuami:
                                                  _agamaSuamiController.text
                                                      .trim(),
                                              agamaPasien:
                                                  _agamaPasienController.text
                                                      .trim(),
                                              pekerjaanPasien:
                                                  _pekerjaanPasienController
                                                      .text
                                                      .trim(),
                                              tanggalMasuk: _tanggalMasuk,
                                              fasilitas: _fasilitas,
                                              diagnosaKebidanan:
                                                  _diagnosaController.text
                                                      .trim(),
                                              tindakan:
                                                  _tindakanController.text
                                                      .trim(),
                                              rujukan:
                                                  _rujukanController.text
                                                          .trim()
                                                          .isEmpty
                                                      ? null
                                                      : _rujukanController.text
                                                          .trim(),
                                              penolongPersalinan:
                                                  _penolongController.text
                                                      .trim(),
                                              createdAt:
                                                  report?.createdAt ??
                                                  DateTime.now(),
                                            );

                                            if (report == null) {
                                              await _createDeliveryRegistration(
                                                newReport,
                                              );
                                            } else {
                                              await _updateDeliveryRegistration(
                                                newReport,
                                              );
                                            }
                                            Navigator.pop(context);
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text('Error: $e'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          } finally {
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          }
                                        },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEC407A),
                                  foregroundColor: Colors.white,
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
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                        : Text(
                                          report == null ? 'Tambah' : 'Simpan',
                                          style: GoogleFonts.poppins(),
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  Widget _buildDatePickerTile(
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
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
    );
  }

  void _navigateToLaporanPersalinan(PersalinanModel report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LaporanPersalinanScreen(registrasiData: report),
      ),
    );
  }

  void _showDetailDialog(PersalinanModel report) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
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
                        'Detail Registrasi Persalinan',
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
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailSection('Data Pasien', [
                            _buildDetailRow('Nama Pasien', report.pasienNama),
                            _buildDetailRow('No HP', report.pasienNoHp),
                            _buildDetailRow(
                              'Umur',
                              '${report.pasienUmur} tahun',
                            ),
                            _buildDetailRow('Alamat', report.pasienAlamat),
                            _buildDetailRow('Agama', report.agamaPasien),
                            _buildDetailRow(
                              'Pekerjaan',
                              report.pekerjaanPasien,
                            ),
                          ]),
                          const SizedBox(height: 16),
                          _buildDetailSection('Data Suami', [
                            _buildDetailRow('Nama Suami', report.namaSuami),
                            _buildDetailRow(
                              'Pekerjaan Suami',
                              report.pekerjaanSuami,
                            ),
                            _buildDetailRow(
                              'Umur Suami',
                              '${report.umurSuami} tahun',
                            ),
                            _buildDetailRow('Agama Suami', report.agamaSuami),
                          ]),
                          const SizedBox(height: 16),
                          _buildDetailSection('Data Persalinan', [
                            _buildDetailRow(
                              'Tanggal Masuk',
                              DateFormat(
                                'dd/MM/yyyy HH:mm',
                              ).format(report.tanggalMasuk),
                            ),
                            _buildDetailRow(
                              'Fasilitas',
                              report.fasilitas == 'umum' ? 'Umum' : 'BPJS',
                            ),
                          ]),
                          const SizedBox(height: 16),
                          _buildDetailSection('Diagnosa & Tindakan', [
                            _buildDetailRow(
                              'Diagnosa',
                              report.diagnosaKebidanan,
                            ),
                            _buildDetailRow('Tindakan', report.tindakan),
                            if (report.rujukan != null)
                              _buildDetailRow('Rujukan', report.rujukan!),
                            _buildDetailRow(
                              'Penolong',
                              report.penolongPersalinan,
                            ),
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

  // Patient Management Dialog
  void _showPatientManagementDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
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
                          Icons.people_rounded,
                          color: const Color(0xFFEC407A),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Kelola',
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
                    child:
                        _isLoadingPatients
                            ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Color(0xFFEC407A),
                                    strokeWidth: 3,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Memuat data pasien...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : _patients.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline_rounded,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Belum ada data pasien',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tambahkan',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              itemCount: _patients.length,
                              itemBuilder: (context, index) {
                                final patient = _patients[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(
                                        0xFFEC407A,
                                      ).withValues(alpha: 0.1),
                                      child: Text(
                                        patient.nama[0].toUpperCase(),
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFFEC407A),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      patient.nama,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${patient.noHp} • ${patient.umur} tahun',
                                        ),
                                        if (patient.alamat.isNotEmpty)
                                          Text(
                                            patient.alamat,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      icon: Icon(
                                        Icons.more_vert_rounded,
                                        color: const Color(0xFFEC407A),
                                      ),
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showAddEditPatientDialog(patient);
                                        } else if (value == 'delete') {
                                          _showDeletePatientConfirmation(
                                            patient,
                                          );
                                        }
                                      },
                                      itemBuilder:
                                          (context) => [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.edit_rounded,
                                                    color: Colors.orange,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Edit',
                                                    style:
                                                        GoogleFonts.poppins(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.delete_rounded,
                                                    color: Colors.red,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Hapus',
                                                    style:
                                                        GoogleFonts.poppins(),
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Tutup',
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _refreshData,
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          label: Text(
                            'Refresh',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.grey[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showAddEditPatientDialog();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEC407A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Tambah Pasien Baru',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Add/Edit Patient Dialog
  void _showAddEditPatientDialog([UserModel? patient]) {
    final _formKey = GlobalKey<FormState>();
    final _namaController = TextEditingController(text: patient?.nama ?? '');
    final _noHpController = TextEditingController(text: patient?.noHp ?? '');
    final _umurController = TextEditingController(
      text: patient?.umur.toString() ?? '',
    );
    final _alamatController = TextEditingController(
      text: patient?.alamat ?? '',
    );
    final _namaSuamiController = TextEditingController(
      text: patient?.namaSuami ?? '',
    );
    final _pekerjaanSuamiController = TextEditingController(
      text: patient?.pekerjaanSuami ?? '',
    );
    final _umurSuamiController = TextEditingController(
      text: patient?.umurSuami?.toString() ?? '',
    );
    final _agamaSuamiController = TextEditingController(
      text: patient?.agamaSuami ?? '',
    );
    final _agamaPasienController = TextEditingController(
      text: patient?.agamaPasien ?? '',
    );
    final _pekerjaanPasienController = TextEditingController(
      text: patient?.pekerjaanPasien ?? '',
    );

    DateTime _tanggalLahir = patient?.tanggalLahir ?? DateTime.now();
    bool _isLoading = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
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
                                color: const Color(
                                  0xFFEC407A,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                patient == null
                                    ? Icons.person_add_rounded
                                    : Icons.edit_rounded,
                                color: const Color(0xFFEC407A),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              patient == null
                                  ? 'Tambah Pasien Baru'
                                  : 'Edit Data Pasien',
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
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Basic Patient Information
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.blue[200]!,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Informasi Dasar Pasien',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        TextFormField(
                                          controller: _namaController,
                                          decoration: InputDecoration(
                                            labelText: 'Nama Lengkap',
                                            prefixIcon: Icon(
                                              Icons.person_rounded,
                                              color: const Color(0xFFEC407A),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Nama tidak boleh kosong';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller: _noHpController,
                                                decoration: InputDecoration(
                                                  labelText: 'No HP',
                                                  prefixIcon: Icon(
                                                    Icons.phone_rounded,
                                                    color: const Color(
                                                      0xFFEC407A,
                                                    ),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'No HP tidak boleh kosong';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _umurController,
                                                decoration: InputDecoration(
                                                  labelText: 'Umur',
                                                  prefixIcon: Icon(
                                                    Icons.cake_rounded,
                                                    color: const Color(
                                                      0xFFEC407A,
                                                    ),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Umur tidak boleh kosong';
                                                  }
                                                  if (int.tryParse(value) ==
                                                      null) {
                                                    return 'Umur harus berupa angka';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          controller: _alamatController,
                                          maxLines: 2,
                                          decoration: InputDecoration(
                                            labelText: 'Alamat',
                                            prefixIcon: Icon(
                                              Icons.location_on_rounded,
                                              color: const Color(0xFFEC407A),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Alamat tidak boleh kosong';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Husband Information
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.green[200]!,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Informasi Suami',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        TextFormField(
                                          controller: _namaSuamiController,
                                          decoration: InputDecoration(
                                            labelText: 'Nama Suami',
                                            prefixIcon: Icon(
                                              Icons.person_rounded,
                                              color: const Color(0xFFEC407A),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller:
                                                    _pekerjaanSuamiController,
                                                decoration: InputDecoration(
                                                  labelText: 'Pekerjaan Suami',
                                                  prefixIcon: Icon(
                                                    Icons.work_rounded,
                                                    color: const Color(
                                                      0xFFEC407A,
                                                    ),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: TextFormField(
                                                controller:
                                                    _umurSuamiController,
                                                decoration: InputDecoration(
                                                  labelText: 'Umur Suami',
                                                  prefixIcon: Icon(
                                                    Icons.cake_rounded,
                                                    color: const Color(
                                                      0xFFEC407A,
                                                    ),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          controller: _agamaSuamiController,
                                          decoration: InputDecoration(
                                            labelText: 'Agama Suami',
                                            prefixIcon: Icon(
                                              Icons.church_rounded,
                                              color: const Color(0xFFEC407A),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Patient Additional Information
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.orange[200]!,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Informasi Tambahan Pasien',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange[700],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller:
                                                    _agamaPasienController,
                                                decoration: InputDecoration(
                                                  labelText: 'Agama Pasien',
                                                  prefixIcon: Icon(
                                                    Icons.church_rounded,
                                                    color: const Color(
                                                      0xFFEC407A,
                                                    ),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: TextFormField(
                                                controller:
                                                    _pekerjaanPasienController,
                                                decoration: InputDecoration(
                                                  labelText: 'Pekerjaan Pasien',
                                                  prefixIcon: Icon(
                                                    Icons.work_rounded,
                                                    color: const Color(
                                                      0xFFEC407A,
                                                    ),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
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
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    _isLoading
                                        ? null
                                        : () async {
                                          if (!_formKey.currentState!
                                              .validate())
                                            return;

                                          setState(() => _isLoading = true);

                                          try {
                                            final newPatient = UserModel(
                                              id:
                                                  patient?.id ??
                                                  _firebaseService.generateId(),
                                              nama: _namaController.text.trim(),
                                              email:
                                                  patient?.email ??
                                                  '${_namaController.text.trim().toLowerCase().replaceAll(' ', '')}@example.com',
                                              password:
                                                  patient?.password ??
                                                  'password123',
                                              noHp: _noHpController.text.trim(),
                                              umur:
                                                  int.tryParse(
                                                    _umurController.text.trim(),
                                                  ) ??
                                                  0,
                                              alamat:
                                                  _alamatController.text.trim(),
                                              tanggalLahir: _tanggalLahir,
                                              role: patient?.role ?? 'pasien',
                                              namaSuami:
                                                  _namaSuamiController.text
                                                          .trim()
                                                          .isEmpty
                                                      ? null
                                                      : _namaSuamiController
                                                          .text
                                                          .trim(),
                                              pekerjaanSuami:
                                                  _pekerjaanSuamiController.text
                                                          .trim()
                                                          .isEmpty
                                                      ? null
                                                      : _pekerjaanSuamiController
                                                          .text
                                                          .trim(),
                                              umurSuami:
                                                  _umurSuamiController.text
                                                          .trim()
                                                          .isEmpty
                                                      ? null
                                                      : int.tryParse(
                                                        _umurSuamiController
                                                            .text
                                                            .trim(),
                                                      ),
                                              agamaSuami:
                                                  _agamaSuamiController.text
                                                          .trim()
                                                          .isEmpty
                                                      ? null
                                                      : _agamaSuamiController
                                                          .text
                                                          .trim(),
                                              agamaPasien:
                                                  _agamaPasienController.text
                                                          .trim()
                                                          .isEmpty
                                                      ? null
                                                      : _agamaPasienController
                                                          .text
                                                          .trim(),
                                              pekerjaanPasien:
                                                  _pekerjaanPasienController
                                                          .text
                                                          .trim()
                                                          .isEmpty
                                                      ? null
                                                      : _pekerjaanPasienController
                                                          .text
                                                          .trim(),
                                              createdAt:
                                                  patient?.createdAt ??
                                                  DateTime.now(),
                                            );

                                            if (patient == null) {
                                              await _createPatient(newPatient);
                                            } else {
                                              await _updatePatient(newPatient);
                                            }

                                            Navigator.pop(context);
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text('Error: $e'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          } finally {
                                            setState(() => _isLoading = false);
                                          }
                                        },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEC407A),
                                  foregroundColor: Colors.white,
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
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                        : Text(
                                          patient == null ? 'Tambah' : 'Simpan',
                                          style: GoogleFonts.poppins(),
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  // Delete Patient Confirmation
  void _showDeletePatientConfirmation(UserModel patient) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Konfirmasi Hapus',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus data pasien "${patient.nama}"?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _deletePatient(patient.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Hapus', style: GoogleFonts.poppins()),
              ),
            ],
          ),
    );
  }

  // Delete Delivery Registration Confirmation
  void _showDeleteDeliveryConfirmation(PersalinanModel registration) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Konfirmasi Hapus',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus registrasi persalinan untuk pasien "${registration.pasienNama}"?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _deleteDeliveryRegistration(registration.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Hapus', style: GoogleFonts.poppins()),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Registrasi Persalinan',
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
                            Icons.assignment_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Connection Status Indicator
                    if (_errorMessage != null &&
                        _errorMessage!.contains('TimeoutException'))
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_off,
                              color: Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Koneksi lambat, mencoba lagi...',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Status Summary
                    Row(
                      children: [
                        _buildStatusCard(
                          'Total',
                          _isLoading ? '...' : _allReports.length.toString(),
                          Colors.white,
                        ),
                        const SizedBox(width: 12),
                        _buildStatusCard(
                          'UMUM',
                          _isLoading
                              ? '...'
                              : _allReports
                                  .where((r) => r.fasilitas == 'umum')
                                  .length
                                  .toString(),
                          Colors.white,
                        ),
                        const SizedBox(width: 12),
                        _buildStatusCard(
                          'BPJS',
                          _isLoading
                              ? '...'
                              : _allReports
                                  .where((r) => r.fasilitas == 'bpjs')
                                  .length
                                  .toString(),
                          Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Action Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                _isLoading
                                    ? null
                                    : () => _showPatientManagementDialog(),
                            icon:
                                _isLoading
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Color(0xFFEC407A),
                                            ),
                                      ),
                                    )
                                    : const Icon(
                                      Icons.people_rounded,
                                      size: 20,
                                    ),
                            label: Text(
                              _isLoading ? 'Memuat...' : 'Kelola',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFEC407A),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                _isLoading ? null : () => _showAddEditDialog(),
                            icon:
                                _isLoading
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Color(0xFFEC407A),
                                            ),
                                      ),
                                    )
                                    : const Icon(Icons.add_rounded, size: 20),
                            label: Text(
                              _isLoading ? 'Memuat...' : 'Tambah',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFEC407A),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        hintText:
                            _isLoading
                                ? 'Memuat data...'
                                : 'Cari berdasarkan nama pasien, no HP, alamat, nama suami, pekerjaan, atau agama...',
                        prefixIcon:
                            _isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFEC407A),
                                    ),
                                  ),
                                )
                                : Icon(
                                  Icons.search_rounded,
                                  color: const Color(0xFFEC407A),
                                ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFEC407A),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor:
                            _isLoading ? Colors.grey[100] : Colors.grey[50],
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _filterReports();
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Reports List
              Expanded(child: _buildReportsList()),
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
          onPressed: () => _showAddEditDialog(),
          backgroundColor: const Color(0xFFEC407A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(String title, dynamic count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color == Colors.white ? Colors.white : color,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color:
                    color == Colors.white
                        ? Colors.white.withValues(alpha: 0.9)
                        : color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build reports list with proper loading states
  Widget _buildReportsList() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_filteredReports.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredReports.length,
      itemBuilder: (context, index) {
        final report = _filteredReports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFFEC407A),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat data...',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          if (_isLoadingPatients || _isLoadingReports)
            Text(
              _isLoadingPatients && _isLoadingReports
                  ? 'Memuat data pasien dan registrasi...'
                  : _isLoadingPatients
                  ? 'Memuat data pasien...'
                  : 'Memuat data registrasi...',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.red[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Terjadi Kesalahan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'Gagal memuat data',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              'Coba Lagi',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC407A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
              color: const Color(0xFFEC407A),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isEmpty
                ? 'Belum ada data registrasi persalinan'
                : 'Tidak ada hasil pencarian',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Tambahkan registrasi persalinan pertama'
                : 'Coba kata kunci yang berbeda',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddEditDialog(),
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'Tambah Registrasi',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC407A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReportCard(PersalinanModel report) {
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
            Row(
              children: [
                // Patient Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFEC407A).withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.medical_services_rounded,
                    color: const Color(0xFFEC407A),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Patient Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.pasienNama,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.phone_rounded, report.pasienNoHp),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        Icons.cake_rounded,
                        '${report.pasienUmur} tahun',
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        Icons.location_on_rounded,
                        report.pasienAlamat,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                // Action Menu
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: const Color(0xFFEC407A),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'detail') {
                      _showDetailDialog(report);
                    } else if (value == 'edit') {
                      _showAddEditDialog(report);
                    } else if (value == 'delete') {
                      _showDeleteDeliveryConfirmation(report);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'detail',
                          child: Row(
                            children: [
                              Icon(
                                Icons.visibility_rounded,
                                color: const Color(0xFFEC407A),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Detail',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFEC407A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Edit',
                                style: GoogleFonts.poppins(
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_rounded,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Hapus',
                                style: GoogleFonts.poppins(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToLaporanPersalinan(report),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(
                  'Tambah Laporan Persalinan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEC407A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
